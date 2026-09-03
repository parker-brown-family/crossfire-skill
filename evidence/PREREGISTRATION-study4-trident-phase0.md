# Pre-registration — Study 4, phase 0: a falsification pilot for instructed divergence ("Trident")

**Status: registered, unrun.** No arm of this study has been dispatched. As with
Study 3, this registration lands in the public repository in a commit that
precedes all data, so the ordering claim — rules before results — is verifiable
from git history by anyone.

Everything the study needs is committed beside this document under
`trident-phase0/`: the task briefs (verbatim snapshots), the goal outcomes and
answer keys, every arm's instruction text, the eval suites and the generator
that reproduces them, the auditor with its controls, and the run scripts. The
results will land in a later commit that adds no rules.

## The idea under test

One agent is instructed to produce three deliberately distinct paths through a
ticket at plan level. A second agent, with fresh context, measures the three
against goal outcomes written in advance and composes the plan that goes
forward, citing which path each decision came from. The bet is that instructed
divergence surfaces real alternatives cheaply, and that a clean-context
harmoniser extracts more from them than picking a winner would.

**This is a falsification study, not a significance study.** It runs at low
resource, to break the idea if it can be broken. Its falsifiers are built to be
categorical — checkable mechanically at n=1 — because at this scale effect
sizes drown in sampling noise and prove nothing in either direction.

**Pre-commitment, registered before any data:** if no falsifier fires, we will
not claim the approach works, will not ship it as a default on this evidence,
and will not call any playbook earned. We will say it survived a small hostile
test, and name what a real test would require.

**Stated limitation, verbatim in every write-up:** we do not claim the
harmoniser is context-free. It reads three artifacts that contain their own
reasoning, and it runs on a stochastic system. What the design removes is
*structured* leakage — the generator's framing about which path deserves to
win, the ordering, the provenance. Any residual carry-through is chaos in the
substrate, and we name it rather than pretending it away.

## Who wrote this, and their stake

The experiment was designed in one session and is registered and run by a
different one, which read the design's issue record and none of the designing
session's conversation. The falsifiers below are mechanical precisely so that
adjudication is nearly automatic; the one place a human reads raw output (the
trio read under F1-soft) records a disposition, never a verdict.

## Tasks

Both tasks are **open** tickets in `parker-brown-family/terminal-delight`,
snapshotted verbatim into `trident-phase0/briefs/` and verified unimplemented
at the pinned base commit `9707696` immediately before dispatch
(`tools/verify_unimplemented.sh` — a registered run-time precondition).
Choosing open tickets is deliberate: there is no shipped answer in repository
history to leak into a workspace, which dissolves the ancestry-isolation
requirement completed tickets would carry. The price is that no ground-truth
fix exists — and no falsifier below needs one.

| Role | Task | Why |
|---|---|---|
| Latitude task | `terminal-delight#196` — no way to reach a saved session that isn't the newest | Problem cleanly separated from approach; the fork space (picker overlay, first-paint strip, menu entry, CLI subcommand, tab affordance) is genuinely open; goal outcomes were enumerable in advance |
| No-latitude control | `terminal-delight#178` — implement the xdg-terminal-exec contract | Looks substantial; has no material latitude. The substantive answers are dictated by a published desktop-entry contract and by the issue's own reproduce and done-when blocks |

The control is deliberately not a trivial task. A visibly trivial ticket (a
missing favicon, an EPIPE fix) invites a refusal out of proportion rather than
an honest latitude judgement, which would pass F1 without testing it. `#178`
is the honest trap: meaty surface, dictated answers.

Rejected candidates, logged: `terminal-delight#172` (an approach is baked into
the issue body — "Suggested shape" — violating problem/approach separation);
`terminal-delight#236` and `#146` (usable, held in reserve for phase A); one
non-code candidate rejected on a licensing boundary its own text imposes, with
the general non-code criterion cut from the pilot as a planned reduction — an
exploratory result that cannot falsify anything is colour, and phase 0 buys
none.

## Goal outcomes

Written before any path existed, committed here: `trident-phase0/goals/`.

Each task's goals are a set of **question-keyed** outcomes. Questions are
`open` (genuine latitude) or `dictated` (the ticket or a published contract
fixes the answer; the key records regex accept/contra patterns and what
dictates them). td196: ten open questions, one demanding a named threshold,
two dictated. td178: six dictated, two deliberately open implementation
questions — an honest arm has somewhere legitimate to differ while flagging
the overall latitude as immaterial.

**Arms see question text only.** The open/dictated markings and the answer
keys never enter a prompt; a marked question would tell an arm which answers
are fixed, which is exactly what F1 tests. All arm-visible text is generated
from the goals by `tools/build_evals.py`; the preflight refuses to run if the
committed evals differ from regenerated ones.

Declarations are keyed by question id rather than shaped as arrays because the
harness's deterministic `json_path` assertions walk dotted paths with no
search: "did the plan take a position on q1" is checkable at
`answers.q1.position` and not checkable at all against an array whose order
varies. This is also why the primary completeness checks are deterministic —
no LLM grader runs anywhere in phase 0.

## Arms and instructions

Every arm's full instruction text is committed under `trident-phase0/skills/`
(word counts: trident-generate 225, trident-harmonise 241, pick-best 202,
revise-single 191). The shared eval prompt — identical bytes across arms of a
stage, carrying the ticket, the questions, and the output contract — carries
all common care; a skill adds only its mechanism. The chance-divergence
comparator (G1) has no instruction text **by definition**: its mechanism is
the absence of one, sampled as independent baseline runs (`--runs N`), so
prompt-quality asymmetry against it cannot arise. pick-best and revise-single
are registered now, unrun in phase 0, so their texts predate any data they
will ever be compared on.

The generator instruction carries an explicit out: on a ticket with no
material latitude, declare it and produce one path. F1 tests the instruction
*with* that out — an instructed pipeline that cannot decline is not the design
under test. The symmetric hazard (over-declining on a real latitude task) is
what the sanity floor catches. This pair is the validity argument for both.

## The runs

Six agent invocations, all `claude-code` CLI at model `claude-fable-5`,
per-invocation timeout 1800 s, one repetition (`--runs 1`), workspaces retained
for audit, isolated agent config (no user hooks, no user instruction files, no
MCP servers — `tools/preflight.sh` builds it; the smoke prompt is the only
spend outside the runs). Arms are instructed not to use the network. Harness:
`tardigrde/agent-skill-eval` pinned at `59de161`; its comparison axis is a
hard skill-on/skill-off boolean, so each arm is one harness invocation whose
built-in baseline is the bare agent on the same prompt — the one-plan control
arrives free and freshly sampled in every run.

| Run | Skill | Eval | Workspace | Yields |
|---|---|---|---|---|
| A | trident-generate | stage1-td196 | frozen TD clone at `9707696` | G2 trio + G0 baseline |
| B | trident-generate | stage1-td178 | frozen TD clone at `9707696` | F1 arm + G0 baseline (baseline doubles as an answer-key validation datum) |
| C | trident-harmonise | stage2-td196 (assembled) | fresh repo, fixture files only | H2 harmonised + uninstructed-reduction baseline |

Between A and C the handoff is assembled mechanically
(`tools/assemble_handoff.py`): paths verbatim, order shuffled with a recorded
seed (**the sha of the commit that lands this registration**, written into
`mapping.json`), provenance stripped — including each path's latitude field,
which carries the generator's framing about its own instruction — goals
attached, nothing else. The harmoniser receives no repository: it judges on
paper, which is the design's claim about it.

## Falsifiers, and the order they run

**Sanity floor first, before anything may be credited.** On td196 the
generator arm must produce three parseable declarations, schema-valid, each
answering ≥ 80% of the questions, latitude declared genuine, with at least two
questions contested across the trio. Failure is an instrument failure: halt
for repair, no further spend, nothing concluded about the idea.

**F1 — fabricated divergence** *(categorical, n=1, run second)*. On td178,
F1-hard fires iff the arm claims genuine latitude AND at least two dictated
questions carry a path classified `contra` — a manufactured alternative to a
published contract. Producing one path with latitude declared not genuine is
the instruction behaving. Three spec-conforming paths under a claimed genuine
latitude with fewer than two contra questions is **F1-soft**: flagged for a
human trio read, disposition recorded as OPEN, never a verdict. If more than
one third of (dictated question × path) cells are unclassifiable by the keys,
the keys are too weak: halt for repair, no F1 verdict either way.

**F2 — zero synthesis** *(categorical, mechanical)*. The harmoniser must copy
each adopted position verbatim and cite its source path; the audit
(`tools/audit.py synthesis`) verifies each citation by normalized string
equality against the cited path, reattributes provably-miscited answers where
exactly one source matches, and counts false citations. Synthesis is credited
iff honest adoptions on **creditable** questions (where at least one other
path's position differs) span ≥ 2 distinct paths. Phase 0 cannot fire F2 as a
study verdict at n=1; it validates the measure and reports the datum.

**F3 — synthesis degrades** *(categorical, mechanical)*. A degradation event:
a dictated question where every input path classified `correct` and the
harmonised position classifies `contra`. Any event at any n is reportable as
itself; `unclassified` downgrades are logged as suspects, never as events.

**F4 — instruction adds nothing over chance** — **not evaluable in phase 0**,
registered so it cannot be improvised later. It requires the chance
comparator (independent baseline samples) under the *same* instrument. The
published spontaneous fork rate of 0.214 was measured at implementation level
with a different instrument; it is a reference gradient, not a comparator, and
will not be presented as one.

**The instrument itself is under test before any of this is read.** The
auditor ships with hand-built controls whose correct verdicts are known: a
true synthesis (must credit), a reworded single path with decorative citations
(must not credit, must surface false citations), a degradation case (must
count exactly one event), a malformed declaration (must fail schema), and an
empty directory (floor must fail closed). `tools/audit.py selftest` is a
registered halt condition and runs in preflight.

## Halt conditions, all registered

1. Auditor selftest mismatch.
2. Committed evals fail byte-reproduction from the goals.
3. Frozen source not at the pin, or either task already implemented there.
4. Sanity floor failure.
5. Answer keys unclassifiable above one third on dictated cells.
6. F1-hard fires: the premise is dead at the cheapest possible price; stage-2
   machinery may still be exercised on the td196 trio, labelled
   plumbing-only, and nothing downstream is credited.

## What phase 0 may conclude, and may not

It may: fire F1; halt on any instrument failure; validate or reject the
synthesis measure and the answer keys against controls; report whether the
claim-and-cluster rubric's assumptions transferred to question-keyed plans or
the instrument must be treated as new; report per-arm cost and timing from
the harness's own accounting; and state plumbing findings about driving
N-configuration studies through a binary-comparison harness.

It may not: credit survival as evidence the idea works; compare arms
statistically; read the H2-vs-baseline delta as anything but plumbing; or
promote any exploratory observation to a finding. One repetition of one task
per stage is an anecdote everywhere except where a categorical falsifier
speaks.

Borderline classification calls are flagged inside the audit artifacts at the
moment they are made, and the readings under which any conclusion would not
hold are published beside it.

## Phase A, gated

Phase A (full plan-level width: chance comparator via repeated baseline
sampling, pick-best vs harmonise, the revision premise-check, both tasks and
repetitions) is a separate spend decision, costed from phase 0's measured
numbers, and requires explicit approval. A coding codebook for open-question
fork detection will be built from phase 0 outputs and applied in phase A;
phase 0 data never enters phase A denominators. The arm texts phase A needs
are registered above, before any data existed to tune them against.

## Known weaknesses, stated now

Single model, single repetition. Normalized string equality over-counts
contested questions (wording differences read as contests) — an upper bound,
used only where over-counting is conservative or immaterial to a categorical
check. Answer keys are regexes written from the ticket and a published
contract; their sufficiency is itself measured (halt condition 5) and one
baseline arm doubles as a key probe. The questions are arm-visible by design,
so divergence is measured over a stated decision surface, not discovered
structure — a deliberate trade, registered here. This registration is public
before the arms run and the arms are instructed not to use the network;
transcripts are retained. A residual risk that an arm has seen this document
cannot be excluded and is stated rather than waved away.

## Context

Follows Studies 1–3 (BFS-TR-2026-02) and their method: criteria before data,
public registration, deviations logged, negative results published. The full
design history, including the adversarial pass that replaced the original
primary comparison and the falsification reframing that replaced the decision
table, lives in the programme's private tracker; everything needed to run,
audit, or attack this study is in this repository.
