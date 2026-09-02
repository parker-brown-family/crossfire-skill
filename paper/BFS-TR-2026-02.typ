// BFS-TR-2026-02 — Decision-Level Divergence of Independent Coding Agents
// House style: two-column technical report, after BFS-TR-2026-01.
#set text(font: "New Computer Modern", size: 9pt)
#set page(
  paper: "us-letter",
  margin: (x: 1.7cm, top: 1.9cm, bottom: 2.1cm),
  footer: context [
    #set text(size: 7.5pt, fill: rgb(60,60,60))
    Brown Family Sports Inc. --- Technical Report BFS-TR-2026-02
    #h(1fr)
    #counter(page).display()
  ],
)
#set par(justify: true, leading: 0.6em)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => [
  #v(0.7em)
  #set text(size: 10.5pt, weight: "bold")
  #it
  #v(0.25em)
]
#show heading.where(level: 2): it => [
  #v(0.5em)
  #set text(size: 9.5pt, weight: "bold", style: "italic")
  #it
  #v(0.2em)
]
#set math.equation(numbering: "(1)")

// ---------- title block, full width ----------
#align(center)[
  #set text(size: 7.5pt, tracking: 1.5pt)
  #smallcaps[Brown Family Sports Inc. #h(0.8em) · #h(0.8em) Technical Report BFS-TR-2026-02]
]
#v(0.9em)
#align(center)[
  #set text(size: 17pt, weight: "bold")
  Decision-Level Divergence of\ Independent Coding Agents
]
#v(0.4em)
#align(center)[
  #set text(size: 10pt, style: "italic")
  A pre-registered measurement of where agents disagree --- across arms and across models --- with an instrument that had to survive its own failure
]
#v(0.6em)
#align(center)[
  #set text(size: 8.5pt)
  Brown Family Sports Editorial #h(0.6em) · #h(0.6em) Kelowna, British Columbia, Canada
]
#align(center)[
  #set text(size: 8pt)
  Correspondence: parker\@brownfamilysports.com #h(0.6em) · #h(0.6em) 2 September 2026
]
#v(0.9em)

#block(
  width: 100%, inset: 10pt, stroke: 0.6pt, fill: rgb(248, 246, 240),
)[
  #smallcaps[#text(size: 8pt, tracking: 1pt)[Abstract]]
  #v(0.3em)
  #set text(size: 8.6pt)
  Multi-agent coding tools rest on an unmeasured premise: that independent
  agents given the same task produce usefully different solutions rather than
  N spellings of one solution. We measured it. Fifteen agents re-implemented
  three completed tickets from a production Rust codebase, from pre-fix states
  in which the shipped fix was unreachable _by construction_; nine arms shared
  one model and configuration, and six varied the model. Divergence was scored
  at the _declaration_ layer --- what each arm says it decided --- never the
  diff, under rules committed to version control before any result existed.
  Three findings. First, divergence is _region-shaped_: arms converge wherever
  the environment determines the design (all fifteen arms chose the same
  system interface for the same feature) and fork wherever the ticket
  underdetermines it (three ranking policies inside an identical two-file
  envelope; five replay-suppression designs across eight arms). Second,
  file-grain metrics lie in both directions --- our pre-registered surface
  metric scored a genuine three-way policy fork as 0.000 divergence and
  changelog bookkeeping as 0.583 --- and a claim-level repair, validated
  retroactively against cases whose truth was known, inverted the ordering
  correctly. Third, varying the model within one family produced
  mechanism-level designs that three same-configuration arms never produced
  (verdict R1 under the pre-registered rule, with a sensitivity analysis that
  we publish rather than smooth away), at materially different token prices
  for identical briefs. The practical consequence for tooling: fork
  _decisions_, not tasks; compare declarations, not diffs; let humans, not
  models, judge whether two decisions are the same. The method ships as an
  installable skill in the repository accompanying this report.
]
#v(0.8em)

#show: rest => columns(2, gutter: 13pt, rest)

= Introduction

A team that dispatches several agents against one ticket is making a bet: that
the agents will disagree in ways worth paying for. If they converge, the
elimination and comparison machinery downstream has nothing to work on, and the
N-fold token bill purchased one opinion. If they diverge, the follow-up
questions decide the tooling's whole shape: _where_ do they diverge, can the
divergence be located cheaply, and does adding model diversity buy disagreement
that same-configuration sampling cannot?

These questions are empirical, and to our knowledge nobody had answered them at
the level that matters --- the decisions agents make, rather than the text they
emit. Two spellings of one idea produce different diffs; a diff-level or
file-level comparison therefore measures prose variance, not judgement
variance. We built and validated an instrument for the decision level, ran two
pre-registered studies against it, and report everything, including the failure
of our own first metric and the sensitivity of our headline verdict to two
flagged adjudication calls.

This report accompanies a working method --- the _Crossfire_ protocol, released
as an installable agent skill --- and underpins the Crossfire feature of
Conclave, our agent-development product for enterprise teams. The research is
published so that the claims the tooling makes can be checked against the
measurements that produced them, and so that progress on the open questions in
@roadmap is trackable in public.

= Related work

*Effective false positives.* Sadowski et al. describe Google's operating rule
for analysis surfaces at code review: below 10% _effective_ false positives ---
defined behaviourally, as findings after which "developers did not take some
positive action" --- or the surface is dismissed and disabled [1]. We
adopt both the definition and the discipline: our instrument's own first
version failed behaviourally and was repaired under pre-registered criteria.

*Self-report is inverted.* METR's randomised trial found experienced
developers were 19% slower with AI assistance while believing themselves 20%
faster [2]. This is why no step of our pipeline asks a model (or a
person) whether two decisions are "really the same" as a free-form judgement:
sameness is decided by a mechanical rubric with quoted evidence, or by a human
against that rubric, never by an unstructured model call.

*Coordination beats merging.* The AgentRoom preprint measured concurrent
multi-agent coding under a file-claim protocol and found that pooling
independent outputs --- parallel-merge --- scored _below a single agent
working alone_, while coordinated agents scored above [3]. Our
protocol therefore never text-merges arms: comparison happens at the
declaration layer and recombination happens by a written brief that a fresh
run implements once.

= Method

== Corpus and tickets

Three completed tickets were selected from the history of a production
GPU-accelerated terminal emulator (Rust, roughly 41 kLOC, several hundred
commits), against written criteria: a single non-merge commit; 60--600 changed
lines; a commit message whose _problem_ statement is separable from its
_approach_; and genuine design latitude. One candidate from a second codebase
was rejected for size (32 changed lines), recorded as a limitation rather than
silently swapped. The tickets: a reveal-in-file-manager feature (`t1`), a
session-adoption ranking bug (`t2`), and a false-completion notification bug
(`t3`).

== Contamination control by construction

Each arm received a fresh workspace built as
`git init; git fetch <repo> <base-sha>; checkout FETCH_HEAD`. Fetching a
commit brings its ancestry only; the shipped fix is a _descendant_ of the base
and therefore does not exist in the arm's universe --- absence by
construction, not by instruction. Every workspace was verified before launch:
tip equals base, and reachable objects equal ancestry count. Arms were further
instructed not to read other copies of the project, use the network, or spawn
sub-agents, and these weaker instruction-level controls are recorded as such.

The ticket briefs were written from the problem halves of the real commit
messages by an author who had read the real fixes; the briefs are published
verbatim in the repository precisely so they can be audited for approach
leakage, and the one place a brief most plausibly steered the arms is named in
@threats.

== The declaration layer

Each arm ships, beside its diff, a structured declaration: `decided` entries
`{id, surface, claim}` --- one line per significant decision, anchored to a
file path or named concern; `least_confident` references into `decided`; and
`not_done`. Arms did not compile or run anything (a uniform scope choice that
keeps arms cheap and comparable) and were required to declare unverified
surface rather than fake verification.

== Pre-registration by commit ordering

Every rule --- ticket selection criteria, metrics, exclusion and repair
policy, decision thresholds, and later the repaired instrument and the
model-axis criteria --- was committed to version control _before_ the data it
governs existed. The proof of ordering is the git history itself: a commit
containing rules and no results, followed by commits containing results and no
new rules. Four such boundaries exist across the two studies.

== Metrics

The pre-registered primary metric was surface divergence: mean pairwise
Jaccard distance over declared surfaces,

$ D(A, B) = 1 - (lr(|S_A inter S_B|)) / (lr(|S_A union S_B|)), $ <jac>

averaged over arm pairs, with contested-surface share and
confidence-consensus alongside, and a declaration-independent secondary
computed from the diffs' file sets. The decision rule, fixed in advance:
divergence below 0.15 with contested share above 0.80 on all tickets reads
_converge_; above 0.40 on all tickets reads _diverge_; anything mixed is
reported as mixed.

== The claim-level instrument

Because @results-stage0 shows the surface metric failing, a claim-level layer
was defined and pre-registered between studies. Claims from different arms
answering the same design question form a _cluster_; each cluster carries one
topic from a fixed taxonomy (mechanism, policy, threshold, compat,
presentation, verification) and one verdict:

- _fork_ --- the claims commit to materially different behaviour: a different
  interface, signal, or control structure, or the same shape with a constant
  differing by at least 2$times$;
- _same_ --- differences are wording or incidental detail;
- _complementary_ --- disjoint, non-conflicting aspects.

Fork share is forks over clusters with at least two arms,

$ F = ("fork clusters") / ("clusters with" >= 2 "arms"). $ <forkshare>

Every verdict is recorded with a quoted justification so that a disagreeing
reader can re-run the call. The retroactive validation criteria, fixed before
any tag existed: the amended metric must read the known hidden fork of `t2` as
divergence (P1), and must order `t2` above `t1`, inverting the file-grain
ordering (P2). Failure of either would have halted the programme.

= Results

== Study 1: nine same-configuration arms <results-stage0>

Nine arms (three per ticket; one frontier model, identical briefs, shared base
commits, fresh context each) produced nine valid declarations --- no
exclusions, no repairs. Mean cost 143,197 tokens per arm (range
126k--172k), 1.29M total, within 5% of the estimate.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, right, right, left),
    stroke: 0.4pt,
    [*Ticket*], [*Surface div.*], [*Contested*], [*Rule side*],
    [t1-reveal], [0.583], [50%], [diverge],
    [t2-adoption], [0.000], [100%], [converge],
    [t3-bell], [0.333], [50%], [between],
  ),
  caption: [Pre-registered surface metric, study 1. Three tickets, three
  sides: the stopping rule required unanimity and did not fire.],
) <tab1>

The instructive result is not the mixed verdict but the metric's double
failure. `t2-adoption` scored 0.000 --- textbook convergence --- while its
declarations record three different ranking policies (a 72-hour save-time
handicap; a hard substance tier inside a 7-day window; a 7-day handicap)
inside an identical two-file envelope. `t1-reveal` scored 0.583 --- the
"diverge" side --- while all three arms independently selected the same
system interface, threading model, authority rule, and fallback; the score was
driven by whether an arm listed the changelog among its surfaces, and the
file-set secondary reads t1 at 0.167. A file-grain metric measures what arms
choose to _declare_, not what they _decided_.

== Study 1b: the repaired instrument, validated on known truth

The claim-level layer clustered the nine declarations into 28 design
questions. Both pre-registered criteria passed:

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, right, right, left),
    stroke: 0.4pt,
    [*Ticket*], [*Clusters*], [*Fork share*], [*Where the forks are*],
    [t1-reveal], [12], [0.167], [decode semantics only],
    [t2-adoption], [9], [0.222], [ranking policy; its constant],
    [t3-bell], [7], [0.286], [claim lifetime; replay signal],
  ),
  caption: [Claim-level re-scoring of study 1. P1: the hidden `t2` fork
  registers (0.222 vs the file-grain 0.000). P2: the ordering `t2 > t1`
  inverts the file-grain ordering.],
) <tab2>

Confidence consensus moved from one degenerate point per ticket (always the
ticket's main file) to ten cluster-grain points, _four of which sit exactly on
fork clusters_: arms were least confident precisely where they disagreed. The
declaration layer does not merely measure forks; it locates them.

== Study 2: the model axis <results-model>

Six further arms --- one Opus and one Sonnet per ticket, identical briefs and
bases, blind to study 1 --- were scored against study 1's clusters, each arm's
stance per cluster being _aligned_, _fork_, or _unaddressed_ relative to the
study-1 modal design. The pre-registered criterial quantity: forks on the 13
clusters that were mechanism-topic and unanimous across the study-1 arms.
Rule: at least 2 such flips, or any cluster where both probe models agree with
each other _against_ the study-1 consensus, reads R1 (model heterogeneity is
load-bearing); otherwise R2.

*Result: 3 flips; zero agreement-against-consensus clusters; verdict R1.* The
flips: a bounded 4 KiB head-read replacing a whole-file read (`t2`, Opus); a
stateless gate-and-drop bell where all three study-1 arms built
defer-and-resolve (`t3`, Sonnet); and, in consequence of the same design, the
absence of the 300 ms idle hold every study-1 arm kept (`t3`, Sonnet).

*Sensitivity, published rather than smoothed:* the first flip is borderline
(the rubric's letter says fork; a stricter reader says optimisation), and the
two Sonnet flips share one root. Under the rule as registered the verdict is
R1 at 3 flips; de-duplicating the correlated pair leaves R1 at the threshold;
de-duplicating _and_ re-scoring the borderline call yields R2. We do not
invent a de-duplication clause after seeing that it would matter --- that is
the move pre-registration exists to prevent --- but the verdict travels with
this table, and the single call that grades it is published for audit.

Beyond the criterial count, the probe widened exactly the regions study 1
called underdetermined: replay suppression ended with five distinct designs
across eight arms (one probe arm's declaration explicitly argues against the
design the other probe arm chose), while every environment-determined cluster
stayed converged across all three models.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    stroke: 0.4pt,
    [*Model*], [*Mean tokens/arm*], [*Arms*],
    [Fable (study 1)], [143,197], [9],
    [Opus], [154,286], [3],
    [Sonnet], [199,386], [3],
  ),
  caption: [Cost of identical briefs by model. The 39% Sonnet premium makes
  per-model accounting a first-class requirement of any dispatching tool.],
) <tab3>

= Threats to validity <threats>

_Sample._ Three tickets, one codebase, one model family. Nothing here
generalises beyond that without replication; the roadmap (@roadmap) exists
because of this row.

_Adjudicator position._ The clustering and verdicts were made by the same
author who wrote the briefs, had read the real fixes, and had seen the interim
numbers. Mitigations: criteria and rubric committed before tagging; every
verdict quotes its claims; the two calls that decide anything are re-runnable
mechanically. The residual bias is a limitation, not a solved problem.

_Brief leakage._ The `t2` brief's requirement that a stale session "must not
become permanently sticky" is the place brief wording most plausibly steered
arms --- all five arms across both studies engineered a bound the shipped fix
lacks. The briefs are published so this can be audited.

_No builds._ Arms verified by reading; whether compile-fix loops would
tighten or loosen convergence is unknown, and the cost figures exclude them.

_Within-family models only._ Study 2 is a lower bound on heterogeneity;
cross-family measurement is open.

= The method as a practice

The accompanying repository packages the protocol as an installable agent
skill: ancestry-only workspace construction; the declaration schema; the
clustering rubric and verdict grammar; the scoring tools (which count and
never judge); and the pre-registration-by-commit-ordering discipline. The
operational shape that the findings recommend to any multi-agent tool:

+ _Fork decisions, not tasks._ Locate underdetermined regions (cheap
  declaration passes plus confidence consensus find them) and spend arms
  there; the determined majority of a ticket re-buys the same answer N times.
+ _Compare declarations, not diffs_ --- at claim grain, with a fixed topic
  taxonomy; file grain lies in both directions.
+ _Let humans judge sameness_ against a mechanical rubric with quoted
  evidence; never a free-form model call.
+ _Never text-merge arms_; recombine by brief, implement once.
+ _Price arms per model_, and publish verdicts with their sensitivity.

= Roadmap <roadmap>

Open, tracked publicly in the repository: cross-family model axes;
replication on a second codebase (a TypeScript application corpus is
prepared); whether cheap declaration-only passes predict where full arms fork
(the load-bearing question for region-scoped dispatch); and an
interruption-surface study governed by the effective-false-positive
definition of ref. [1]. Updates land as dated entries with the same
rules-before-results discipline used here.

#v(0.6em)
#line(length: 40%, stroke: 0.4pt)
#set text(size: 8pt)

*References*

#set par(hanging-indent: 1em)
[1] C. Sadowski, E. Aftandilian, A. Eagle, L. Miller-Cushon, C. Jaspan.
"Lessons from Building Static Analysis Tools at Google." _CACM_ 61(4), 2018;
restated in _Software Engineering at Google_, ch. 20.

[2] METR. "Measuring the Impact of Early-2025 AI on Experienced Open-Source
Developer Productivity." 2025.

[3] "AgentRoom: Concurrent Multi-Agent Coding in a CRDT-Merged Shared
Filesystem." arXiv:2608.23740, 2026. Preprint.

[4] R. Parasuraman, V. Riley. "Humans and Automation: Use, Misuse, Disuse,
Abuse." _Human Factors_ 39(2), 1997.

[5] Brown Family Sports Inc. Study artifacts: pre-registered methods, briefs,
declarations, adjudications with quoted verdicts, scoring tools, and per-arm
costs. Published in the repository accompanying this report.
