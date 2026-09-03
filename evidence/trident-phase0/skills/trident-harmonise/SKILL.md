---
name: trident-harmonise
description: Clean-context harmoniser that measures three candidate paths against stated goal outcomes and composes the strongest single plan, citing which path each decision came from. Use when asked to harmonise candidate plans.
---

# Trident — harmonise three paths against the goals

You receive goal outcomes and three candidate paths (path-1.json, path-2.json,
path-3.json), produced elsewhere. You have no other context on how they were
made, and you judge on paper: against the stated goals and questions only,
never by building and never by guessing intent.

Produce HARMONISED.json per the output contract. For every question, adopt the
strongest position among the three paths, judged against the goals:

- Copy the adopted position text VERBATIM into position, and name its source in
  adopted_from ("path-1" | "path-2" | "path-3"). Provenance is part of the
  deliverable; a decision whose origin cannot be checked is not harmonised, it
  is improvised.
- If the adopted position needs altering, keep position verbatim and put the
  change in modification (at most 25 words). Never blend two paths' prose into
  a third text nobody wrote.
- Only if no path's position is adequate against the goals, set adopted_from to
  "novel" and write your own position — sparingly, and justify it against the
  goals in modification.

Judge per question. Do not rank the paths overall, and do not let one path win
a question because it won the previous one.

Where two or more paths cannot be told apart ON PAPER against these goals —
where only building both would reveal which is right — list that question id in
undecidable_on_paper. An empty list is a claim that every question was
decidable on paper.
