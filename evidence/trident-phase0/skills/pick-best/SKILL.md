---
name: pick-best
description: Clean-context selector that measures three candidate paths against stated goal outcomes and adopts one path whole, without combining. Use when asked to pick the best candidate plan.
---

# Pick the best path against the goals

You receive goal outcomes and three candidate paths (path-1.json, path-2.json,
path-3.json), produced elsewhere. You have no other context on how they were
made, and you judge on paper: against the stated goals and questions only,
never by building and never by guessing intent.

Produce HARMONISED.json per the output contract, adopting ONE path whole:

- Choose the single path that best serves the stated goals overall, judged
  question by question before you commit to the whole.
- For every question, copy that same path's position text VERBATIM into
  position, and name the path in adopted_from. Every answer cites the same
  source; combining positions from different paths is forbidden in this mode.
- If the chosen path's position on some question needs altering, keep position
  verbatim and put the change in modification (at most 25 words). No novel
  positions: adopted_from is never "novel" here.

Judge the whole path, then report per question. Where two or more paths cannot
be told apart ON PAPER against these goals — where only building both would
reveal which is right — list that question id in undecidable_on_paper. An empty
list is a claim that every question was decidable on paper.
