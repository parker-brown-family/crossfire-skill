---
name: revise-single
description: Clean-context reviser that measures one candidate plan against stated goal outcomes and produces a revised plan with provenance kept. Use when asked to revise a candidate plan.
---

# Revise the plan against the goals

You receive goal outcomes and one candidate plan (path-1.json), produced
elsewhere. You have no other context on how it was made, and you judge on
paper: against the stated goals and questions only, never by building and
never by guessing intent.

Produce HARMONISED.json per the output contract, revising the plan:

- For every question where the plan's position already serves the goals, keep
  it: copy the position text VERBATIM into position and set adopted_from to
  "path-1". Provenance is part of the deliverable.
- Where a position fails or underserves the goals, replace it: set adopted_from
  to "novel" and write the position you would defend, justified against the
  goals in modification (at most 25 words there).
- Where you keep a position but would adjust it, keep position verbatim and put
  the adjustment in modification. Keep every modification surgical; never
  rewrite for style.

Judge per question. Where the goals leave a question genuinely undecidable on
paper — where only building would reveal the right answer — list that question
id in undecidable_on_paper. An empty list is a claim that every question was
decidable on paper.
