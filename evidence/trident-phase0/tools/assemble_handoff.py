#!/usr/bin/env python3
"""Mechanically assemble the stage-2 handoff from a stage-1 trio.

The design's central contamination control: the generator never narrates the
handoff. This script carries the paths verbatim, shuffles their order with a
recorded seed, strips provenance (run identity, notes, and the latitude field,
which carries the generator's framing about its own instruction), attaches the
arm-visible goals, and nothing else.
"""

from __future__ import annotations

import argparse
import json
import random
import shutil
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASE = HERE.parent

KEEP_FIELDS = ("task", "answers", "thresholds", "out_of_scope_touched")


def sanitize(decl: dict) -> dict:
    return {k: decl[k] for k in KEEP_FIELDS if k in decl}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--plans", required=True, type=Path, help="dir holding PLAN-1..3.json")
    ap.add_argument("--seed", required=True, help="recorded shuffle seed (the registration commit sha)")
    ap.add_argument("--outdir", required=True, type=Path)
    args = ap.parse_args()

    sources = [args.plans / f"PLAN-{i}.json" for i in (1, 2, 3)]
    missing = [s.name for s in sources if not s.exists()]
    if missing:
        raise SystemExit(f"cannot assemble: missing {missing}")

    order = [1, 2, 3]
    random.Random(args.seed).shuffle(order)

    files_dir = args.outdir / "files"
    files_dir.mkdir(parents=True, exist_ok=True)

    assignment = {}
    for slot, src_n in enumerate(order, start=1):
        decl = json.loads((args.plans / f"PLAN-{src_n}.json").read_text())
        (files_dir / f"path-{slot}.json").write_text(json.dumps(sanitize(decl), indent=2) + "\n")
        assignment[f"path-{slot}"] = f"PLAN-{src_n}"

    shutil.copy2(BASE / "evals" / "goals-questions-td196.md", files_dir / "goals-questions.md")
    shutil.copy2(BASE / "evals" / "stage2-td196.evals.json", args.outdir / "stage2-td196.evals.json")

    (args.outdir / "mapping.json").write_text(
        json.dumps({"seed": args.seed, "assignment": assignment}, indent=2) + "\n"
    )
    print(f"assembled handoff in {args.outdir} (assignment {assignment})")


if __name__ == "__main__":
    main()
