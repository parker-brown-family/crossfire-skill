#!/usr/bin/env python3
"""
divergence.py — the surface-layer scoring instrument of the Crossfire protocol.

    divergence.py score  <run-dir>...       one ticket, N arms -> the three metrics
    divergence.py sweep  <corpus-dir>       every ticket, grouped by axis
    divergence.py schema                    print the declaration schema

Each arm declares, alongside its diff:

    - what it decided to do, in a handful of lines
    - the decisions it was least confident about
    - what it deliberately did not do

Divergence is measured at that declaration layer, never at the diff:
two spellings of one idea produce different text.

The trap in measuring it is that deciding whether two sentences are the same
decision is itself a judgement, and a model asked to make it introduces exactly
the self-assessment confound METR (2025) measured: self-assessment inverts.
So this reports three numbers with three different trust levels, and never blends
them into one score:

  SURFACE DIVERGENCE     fully objective. Jaccard distance over the set of
                         surfaces each arm decided about. Two arms that touched
                         disjoint surfaces did not solve one problem twice.

  CONTESTED SURFACES     objective given the declarations. Surfaces that more
                         than one arm decided about — the only places a genuine
                         fork can live. Everything else is arms doing different
                         work, not disagreeing.

  CONFIDENCE CONSENSUS   objective, and the sleeper metric. Do arms independently
                         name the SAME decision as the one they were least sure
                         of? Convergence here is strong evidence of a real fork,
                         because it is agreement about where the difficulty is
                         rather than about what to do.

The last one makes this instrument a fork-locator as well as a divergence
meter: aggregated `least_confident` declarations point at the regions worth a
second opinion, measured from arms that actually attempted the work.

WHAT THIS TOOL DOES NOT DO: decide whether two differently-worded claims about
one surface are the same decision. That is the human layer — expensive, last,
and run only on what survived. It emits the adjudication worksheet instead.
"""

import argparse
import itertools
import json
import os
import sys
from collections import Counter, defaultdict

SCHEMA = {
    "run_id": "string, unique per arm",
    "ticket": "string, the shared task identifier",
    "base_sha": "string, the commit all arms started from",
    "config": {
        "model": "string",
        "effort": "string",
        "framing": "string — the prompt variation, e.g. 'readability'",
        "axis": "one of: same-config | model | effort | framing",
    },
    "decided": [{
        "id": "d1",
        "surface": "the file, module or named interface this decision is about",
        "claim": "one line: what was decided",
    }],
    "least_confident": [{"ref": "d1", "why": "one line"}],
    "not_done": [{"claim": "one line", "why": "one line"}],
    "cost": {"input_tokens": 0, "output_tokens": 0, "wall_clock_s": 0},
}


def load(run_dir):
    p = os.path.join(run_dir, "declaration.json")
    with open(p) as fh:
        d = json.load(fh)
    d["_dir"] = run_dir
    return d


def surfaces(arm):
    return {d["surface"] for d in arm.get("decided", []) if d.get("surface")}


def jaccard(a, b):
    if not a and not b:
        return 0.0
    return 1.0 - len(a & b) / len(a | b)


def score(arms, quiet=False):
    if len(arms) < 2:
        print("need at least two arms", file=sys.stderr)
        return None
    ticket = arms[0].get("ticket", "?")
    bases = {a.get("base_sha") for a in arms}
    if len(bases) > 1:
        print(f"REFUSING: arms do not share a base commit: {bases}", file=sys.stderr)
        return None

    S = {a["run_id"]: surfaces(a) for a in arms}
    pairs = list(itertools.combinations(arms, 2))
    dists = [jaccard(S[x["run_id"]], S[y["run_id"]]) for x, y in pairs]
    surface_divergence = sum(dists) / len(dists)

    seen = Counter()
    for a in arms:
        for s in S[a["run_id"]]:
            seen[s] += 1
    contested = {s for s, n in seen.items() if n > 1}
    union = set().union(*S.values()) if S else set()

    # where each arm says the hard part was
    hard = defaultdict(set)
    for a in arms:
        by_id = {d["id"]: d for d in a.get("decided", [])}
        for lc in a.get("least_confident", []):
            d = by_id.get(lc.get("ref"))
            if d and d.get("surface"):
                hard[d["surface"]].add(a["run_id"])
    consensus = {s: sorted(v) for s, v in hard.items() if len(v) > 1}

    out = {
        "ticket": ticket,
        "base_sha": arms[0].get("base_sha"),
        "arms": len(arms),
        "axis": arms[0].get("config", {}).get("axis", "unspecified"),
        "surface_divergence": round(surface_divergence, 3),
        "surfaces_union": len(union),
        "surfaces_contested": len(contested),
        "contested_share": round(len(contested) / len(union), 3) if union else 0.0,
        "confidence_consensus_points": len(consensus),
        "confidence_consensus": consensus,
        "contested": sorted(contested),
        "cost_tokens": sum(a.get("cost", {}).get("input_tokens", 0)
                           + a.get("cost", {}).get("output_tokens", 0) for a in arms),
    }
    if quiet:
        return out

    print(f"ticket {ticket}   axis={out['axis']}   arms={len(arms)}   base={out['base_sha'][:8] if out['base_sha'] else '?'}")
    print(f"  SURFACE DIVERGENCE    {out['surface_divergence']:.3f}   "
          f"(0 = identical surfaces, 1 = disjoint)")
    print(f"  CONTESTED SURFACES    {out['surfaces_contested']}/{out['surfaces_union']} "
          f"= {out['contested_share']:.0%}   <- the only places a fork can live")
    print(f"  CONFIDENCE CONSENSUS  {out['confidence_consensus_points']} point(s) "
          f"named by more than one arm")
    for s, who in sorted(consensus.items()):
        print(f"      {s}   named by {', '.join(who)}")
    print(f"  cost                  {out['cost_tokens']:,} tokens across {len(arms)} arms")

    if contested:
        print("\n  ADJUDICATION WORKSHEET — the human layer.")
        print("  For each surface: same decision differently worded, or a real fork?")
        for s in sorted(contested):
            print(f"\n  [ ] {s}")
            for a in arms:
                for d in a.get("decided", []):
                    if d.get("surface") == s:
                        print(f"        {a['run_id']}: {d.get('claim','')}")
    return out


def sweep(corpus):
    """Every ticket under corpus/<ticket>/<arm>/declaration.json, by axis."""
    by_axis = defaultdict(list)
    for ticket in sorted(os.listdir(corpus)):
        tdir = os.path.join(corpus, ticket)
        if not os.path.isdir(tdir):
            continue
        arms = []
        for arm in sorted(os.listdir(tdir)):
            adir = os.path.join(tdir, arm)
            if os.path.exists(os.path.join(adir, "declaration.json")):
                arms.append(load(adir))
        if len(arms) < 2:
            continue
        r = score(arms, quiet=True)
        if r:
            by_axis[r["axis"]].append(r)

    if not by_axis:
        print(f"no runs found under {corpus}")
        print("expected layout: <corpus>/<ticket>/<arm>/declaration.json")
        return 1

    print(f"{'axis':<14} {'n':>3} {'surf.div':>9} {'contested':>10} {'consensus':>10} {'tokens':>12}")
    for axis, rows in sorted(by_axis.items()):
        n = len(rows)
        sd = sum(r["surface_divergence"] for r in rows) / n
        cs = sum(r["contested_share"] for r in rows) / n
        cc = sum(r["confidence_consensus_points"] for r in rows) / n
        tk = sum(r["cost_tokens"] for r in rows)
        print(f"{axis:<14} {n:>3} {sd:>9.3f} {cs:>9.0%} {cc:>10.1f} {tk:>12,}")

    print("\nREADING THIS TABLE — an example pre-registered decision rule:")
    print("  same-config surface divergence < 0.15 AND contested share > 0.80")
    print("    -> arms converge: same-config sampling buys spellings, not opinions;")
    print("       buy diversity elsewhere (models, or region-scoped dispatch).")
    print("  same-config surface divergence > 0.40")
    print("    -> arms diverge unprompted: same-config sampling is already buying")
    print("       opinions.")
    print("  between the two -> inconclusive at this n. Report it as inconclusive.")
    return 0


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd")
    s = sub.add_parser("score"); s.add_argument("runs", nargs="+")
    w = sub.add_parser("sweep"); w.add_argument("corpus")
    sub.add_parser("schema")
    a = ap.parse_args()

    if a.cmd == "schema":
        print(json.dumps(SCHEMA, indent=2))
        return 0
    if a.cmd == "score":
        return 0 if score([load(r) for r in a.runs]) else 1
    if a.cmd == "sweep":
        return sweep(a.corpus)
    ap.print_help()
    return 2


if __name__ == "__main__":
    sys.exit(main())
