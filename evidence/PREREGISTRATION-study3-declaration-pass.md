# Pre-registration — Study 3: does a cheap declaration pass predict where full arms fork?

**Status: registered, unrun.** No arm of this study has been dispatched. This
document exists so that the ordering claim the roadmap makes — *rules before
results, in public* — is verifiable by anyone from this repository's own git
history rather than from disclosed hashes in a private one.

Studies 1 and 2 were pre-registered privately and their commit hashes disclosed
in `METHOD.md`. That is auditable only under access. From this study forward the
registration lands here first, and the results land in a later commit that adds
no rules.

## The question

Within an existing plan, can inexpensive planning-only arms locate the same fork
clusters that expensive full implementation arms produce?

This is the load-bearing question for region-scoped dispatch. Study 1 found
divergence is region-shaped: arms converge where the environment decides and fork
where the ticket leaves judgement open. If a cheap pass can find those regions,
the expensive mode is only ever needed where the cheap mode points, and Crossfire
stops being a flat multiplier on every run.

## Hypothesis

**H:** planning-only arms fork on the same design questions that full arms forked
on, at a rate high enough to use as a dispatch gate, and at a cost low enough for
the gate to be worth running.

The three clauses are scored separately and all three must hold. A pass that
predicts well but costs as much as the thing it was meant to replace is not a
finding, it is a rounding error with a story attached.

## Design

- **Same three tickets** as Study 1, same base commits, same ancestry-only
  workspaces (`git init && git fetch <repo> <base-sha> && checkout FETCH_HEAD`),
  verified per workspace as before: tip == base, reachable == ancestry.
- **Three planning-only arms per ticket**, nine arms total.
- **One model**, the Study 1 model. The axis under test is pass depth, not model
  diversity; varying both at once would confound this study with Study 2.
- **Fresh context per arm.** No network, no other project copies, no sub-agents,
  no builds — the Study 1 instruction-level rules carry over unchanged.
- **The planning-only brief** is the Study 1 brief with the implementation
  instruction replaced by a declaration-only instruction. Both versions ship
  verbatim in `briefs/`, so the delta between them is auditable rather than
  described.
- **A planning-only arm produces a declaration and nothing else**: no diff, no
  tests, no implementation. An arm that writes code is a protocol violation, is
  excluded, and is logged.

## Ground truth

Study 1's adjudicated cluster set, frozen. Twenty-eight contested clusters, of
which **six are forks** — a base rate of 0.214. Enumerated here so the set cannot
drift after the fact:

| Ticket | Fork clusters | Contested total |
|---|---|---|
| `t1-reveal` | `c5`, `c6` | 12 |
| `t2-adoption` | `c1`, `c2` | 9 |
| `t3-bell` | `c3`, `c4` | 7 |

**The scorer refuses to run if the cluster set it derives from
`adjudication/stage0.json` disagrees with this table** — the same guard Study 2
used on its thirteen-cluster enumeration. A registration that can be quietly
re-derived is not a registration.

Single-arm questions were uncontested in Study 1 and stay excluded from every
denominator here.

## Scoring

Planning-only declarations are clustered against the frozen Study 1 cluster set,
not against a new one. Per cluster, each arm's stance is `aligned`, `fork` or
`unaddressed` by the Study 1 rubric, unchanged: **fork = different interface,
signal or shape, or ≥2× on a constant**. Every verdict carries a quoted
justification, as before.

A cluster is a **predicted fork** when the planning-only arms fork on it by that
rubric. Treating the Study 1 verdict as ground truth over the 28 contested
clusters:

- **recall** = predicted forks that are true forks / 6
- **precision** = predicted forks that are true forks / all predicted forks
- **cost** = mean tokens per planning-only arm, against Study 1's measured
  143k/arm mean

## Decision rule

Registered before any data exists. The two outcomes partition; which conjunct
failed is reported either way.

**P1 — the declaration pass predicts, and is worth running.** All three hold:

1. recall **≥ 4 of 6**
2. precision **≥ 0.40**
3. mean planning-only arm cost **≤ 71.5k tokens** (50% of the Study 1 mean)

**P2 — it does not.** Any conjunct fails.

### Why these numbers, set against data already published

**Recall ≥ 4/6.** A gate that misses more than a third of real forks sends the
cheap mode's blessing to regions that do fork, which is the failure that makes
region-scoped dispatch unsafe rather than merely inefficient. Missing a fork is
the expensive error here; flagging a non-fork only wastes an arm.

**Precision ≥ 0.40.** The base rate is 0.214. An arm that marked every cluster a
fork would score precision 0.214 and recall 1.0, so precision is the conjunct
that makes the rule non-trivial. 0.40 is a little under twice the base rate, and
at recall 4 it caps predicted forks at ten of twenty-eight clusters — meaning
full arms get dispatched to roughly a third of a plan instead of all of it. The
realised saving is reported as a derived quantity, not gated on.

**Cost ≤ 50% of the full-arm mean.** "Cheap" is in the hypothesis, so it is in
the rule. Study 1 measured 143k tokens per full arm and Study 2 measured
143k/154k/199k across three models on identical briefs; those are the numbers
this is set against.

**On the small n.** Six true forks means recall moves in steps of 0.167 and one
cluster changes it materially. The thresholds are stated as counts rather than
rates wherever a count is the honest unit, and no result from this study should
be read as precise to more than that step size.

## Deviation policy

Unchanged from Study 1. An unparseable declaration excludes the arm; the only
permitted repair is trailing commas; header fields are corrected to known-true
values; surface normalisation is whitespace trim and a leading `./` strip, with
no fuzzy matching anywhere. Everything is logged to
`outputs/deviations-study3.json`, including the final count when it is zero.

## Registered limitations

- **Planning-only arms cannot discover a fork that only appears once code is
  written.** This asymmetry is the hypothesis's own risk rather than a confound,
  and it is the most likely route to P2.
- **The ground truth was adjudicated by someone who had read the real fixes and
  seen the interim numbers.** Study 3 inherits that position unchanged. The
  mitigations are the same and remain partial: the cluster set is frozen before
  scoring, every verdict quotes its claims, and the criterial calls are
  mechanically re-runnable.
- **One codebase.** All three tickets come from one Rust repository, as in both
  earlier studies. The second-codebase replication remains open, and nothing here
  generalises past n=1 on the corpus axis.
- **One model.** This measures pass depth, not model diversity, and says nothing
  about whether a cross-model cheap pass would locate different regions.
- **Nine arms.** Three per ticket, matching Study 1's arm count so the comparison
  is like-for-like — not enough for an interval, enough for the registered rule.

## What lands, and when

Results land in a separate commit that adds no rules: the nine declarations
verbatim, the adjudication with quoted justifications, `costs-study3.tsv`, the
deviation log, and the verdict with its sensitivity if any call proves
borderline. If a call is borderline it is flagged inside the adjudication at the
moment it is made, as `t2/c5` was in Study 2, rather than smoothed away.

If the result is P2, it is published as P2.
