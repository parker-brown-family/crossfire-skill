# Crossfire — measure whether your agents actually disagree

**An installable skill and a published measurement.** Before you pay N agents
to attack one ticket, know what N buys you: where independent agents genuinely
fork, where they all walk through the same door, and how to find the difference
for a fraction of the cost of finding out the hard way.

This repository is two things:

1. **The skill** (`skill/`) — a working protocol for running comparative
   multi-agent experiments on your own repository: contamination-controlled
   workspaces, a declaration schema, a claim-level comparison rubric, and
   scoring tools that count and never judge.
2. **The research** (`docs/`, `paper/`) — the full pre-registered study behind
   it: 15 agents, 3 real production tickets, 2 verdicts, every number
   reproducible. Read it as a web report or as the technical paper
   ([BFS-TR-2026-02, PDF](docs/BFS-TR-2026-02.pdf)).

## What we found (measured, not argued)

- **Divergence is region-shaped.** All fifteen arms, across three models,
  chose the *same* mechanism wherever the environment determines the design —
  and forked hard wherever the ticket leaves judgement open: three ranking
  policies inside an identical two-file envelope; five replay-suppression
  designs across eight arms.
- **File-grain metrics lie in both directions.** Our own pre-registered
  surface metric scored a genuine three-way policy fork as **0.000**
  divergence, and changelog bookkeeping as **0.583**. The claim-level repair —
  validated retroactively against cases whose truth was known — reads both
  correctly.
- **Model choice buys real diversity — at a price.** Within one model family,
  varying the model produced mechanism-level designs that three
  same-configuration arms never produced (verdict R1 under the pre-registered
  rule; we publish the sensitivity analysis rather than smoothing it), and the
  same briefs cost 143k / 154k / 199k tokens on the three models tested.
- **Agents know where they're unsure — and it's where they disagree.**
  Least-confident declarations landed on fork clusters again and again. The
  declaration layer doesn't just measure divergence; it *locates* it.

The operational consequences, in five lines: fork **decisions**, not tasks ·
compare **declarations**, not diffs · let **humans** judge sameness, against a
mechanical rubric with quoted evidence · **never text-merge** independent arms
· **price arms per model**.

## Quickstart

Drop `skill/` into your agent's skills directory (for Claude Code:
`.claude/skills/crossfire/`), then:

```
/crossfire <ticket-ref>        run an N-arm divergence experiment on one ticket
```

The skill walks the whole protocol: brief extraction, ancestry-only
workspaces, arm dispatch, declaration collection, claim-level scoring, and the
human adjudication worksheet. `skill/SKILL.md` documents every step and every
rule, with the study that produced each rule cited inline.

## Why publish this

This research underpins **Crossfire**, the multi-arm feature of
[Conclave](https://brownfamilysports.com) — our agent-development product for
enterprise teams — and we would rather hold the primary evidence than assert
the pitch. Everything here is the real study: the pre-registered methods (the
git history of the source repositories is the proof the rules predate the
results), the briefs verbatim so they can be audited for leakage, the
adjudications with quoted justifications so every call can be re-run, and the
verdicts with their sensitivity attached.

Progress on the open questions — cross-family model axes, a second-codebase
replication, whether cheap declaration passes predict where full arms fork —
is tracked publicly in [docs/roadmap.html](docs/roadmap.html), under the same
rules-before-results discipline.

## Repository map

| Path | What |
|---|---|
| `skill/SKILL.md` | The protocol, step by step, rules cited to their evidence |
| `skill/reference/rubric.md` | Topic taxonomy, cluster rule, verdict grammar |
| `skill/reference/declaration.example.json` | The schema arms fill |
| `skill/tools/` | `divergence.py` (scoring), `make-workspaces.sh` (contamination control) |
| `docs/index.html` | The research report, web edition |
| `docs/BFS-TR-2026-02.pdf` | The technical report (paper edition) |
| `docs/roadmap.html` | Living public progress tracker |
| `paper/` | Typst source for the PDF |

## License

Code and skill: MIT. Report text and PDF: CC BY 4.0. © 2026 Brown Family
Sports Inc.
