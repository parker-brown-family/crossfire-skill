---
name: crossfire
description: Run a comparative multi-agent divergence experiment on one completed ticket — N independent arms in contamination-controlled workspaces, declaration-level comparison, claim-level scoring, and a human adjudication worksheet. Use when asked to "crossfire" a ticket, measure agent divergence, compare independent implementations, or evaluate whether N arms or N models buy real diversity on this codebase.
---

# Crossfire — comparative agent combat, done honestly

You are running a controlled experiment, not a race. The output that matters is
not N implementations; it is a defensible answer to *where independent agents
diverge on this ticket* — with every judgement recorded so a disagreeing reader
can re-run it. Every rule below exists because a published measurement showed
the cheaper alternative produces a wrong number; the study is in this
repository's `docs/`.

## The protocol

### 1 · Pick the ticket and write the brief

Choose a **completed** ticket: a single non-merge commit, roughly 60–600
changed lines, with genuine design latitude (a policy, a threshold, a signal —
not a mechanical rename). Write the brief from the ticket's *problem*
statement only. Never include the approach taken, the files the real fix
touched, or the fix's vocabulary. Commit the brief before launching any arm —
it is audit material for leakage, and briefs steer arms more than anything
else in the setup.

### 2 · Build contamination-controlled workspaces

One per arm, via `tools/make-workspaces.sh <repo> <base-sha> <n>`:

```
git init && git fetch <repo> <base-sha> && git checkout FETCH_HEAD
```

Fetching a sha brings its **ancestry only** — the real fix is a descendant and
does not exist in the arm's universe. Absence by construction beats absence by
instruction. Verify each workspace before launch: tip == base, and
`rev-list --count HEAD` == total reachable objects. Arms additionally get the
instruction-level rules: stay in the workspace, no network, no other copies of
the project, no sub-agents, and **no builds** unless you deliberately choose a
build tier for all arms uniformly.

### 3 · Pre-register before you launch

Commit, in a commit containing **no results**: the metrics you will compute,
the thresholds you will read them against, the exclusion/repair policy for
malformed outputs, and what each outcome will mean. The git ordering — a
rules-commit with no data, then data-commits with no new rules — is your proof
the criteria predate the results. A judgement call made after seeing the data
is made by someone who already knows which answer it produces.

### 4 · Dispatch N identical arms

Fresh context per arm (independence is the point — never fork a conversation
that has seen another arm). Identical prompt: the brief, the workspace path,
the rules, and the declaration contract (`reference/declaration.example.json`,
shape copied exactly). Vary exactly one axis per experiment: nothing
(same-config), model, effort, or framing. Record per-arm cost from the
harness, never self-reported.

### 5 · Collect and validate mechanically

Per arm: `implementation.diff` (staged diff) and `declaration.json`. Apply the
pre-registered policy exactly: unparseable declaration → arm excluded;
trailing-comma repair only; header fields corrected to known-true values;
everything logged to a deviations file. Parse diff file-sets from
`diff --git` header lines (mnemonic prefixes broke the naive `+++ b/` parser
in the original study; the deviation log caught it).

### 6 · Score at claim grain, count only

Run `tools/divergence.py score` for the pre-registered surface metrics — then
treat them as the coarse layer they are. The study's central instrument
finding: **file-grain metrics lie in both directions** (a real three-way
policy fork scored 0.000; changelog bookkeeping scored 0.583). The real
comparison is claim-level: cluster claims across arms by design question,
assign each cluster a topic and a verdict per `reference/rubric.md`, and
compute fork share = fork clusters / clusters with ≥2 arms.

Hard rule: **no model — and no free-form human — ever answers "are these two
decisions the same?"** Sameness is decided against the rubric's mechanical
criteria (different shape/interface/signal, or ≥2× on a constant, = fork),
with a quoted justification per verdict. METR showed self-assessment inverts;
an LLM judge reimports exactly that confound.

### 7 · The human layer

Emit the adjudication worksheet: every contested cluster, every arm's claim
quoted. The human's calls — and only the human's calls — settle borderline
cases, and each call is recorded with its evidence. If a call changes the
experiment's verdict, ship the verdict **with a sensitivity table** showing
every reading. A verdict more confident than its judgement calls is
overclaiming.

### 8 · Never merge; brief and rebuild

If the goal was a best implementation rather than a measurement: pick the
winning approach, write a **brief** naming it plus the specific threads worth
pulling from other arms, and have a *fresh* arm implement the brief once.
Pooling independent outputs measurably underperforms a single agent
(AgentRoom, 2026). The declarations, not the diffs, are what the brief is
written from.

## Reading the results — what the study licenses you to expect

- Expect **convergence on environment-determined mechanism** and **forks on
  policy, thresholds and signals**. If you see the opposite, check the brief
  for leakage first.
- Expect arms' `least_confident` entries to point at the fork clusters. That
  co-location is the cheapest fork-locator known to us — use it to decide
  where a second opinion is worth buying.
- If you vary models: expect real additional design diversity (R1 in our
  probe, sensitivity attached) and materially different token bills for
  identical briefs. Budget per model, not per arm.

## What this skill does not do

It does not run your builds (choose a build tier deliberately), it does not
generalise beyond your corpus (n is whatever you ran), and it does not replace
the human layer with a model. Those are features.
