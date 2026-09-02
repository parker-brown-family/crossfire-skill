# Method record — public edition

The complete rules of both studies, as they were fixed **before** the data they
govern existed. The original pre-registration lives as ordered commits in the
private source repositories; the commit hashes are disclosed below so the
ordering claim is auditable under access, and — as the roadmap states — future
waves pre-register **in this public repository** so the ordering is verifiable
by anyone.

## Pre-registration chain (private repositories, hashes disclosed)

| Boundary | What the commit contains | Hash |
|---|---|---|
| Study 1 rules | method, briefs, deviation policy, collector — zero results | `e2fe458` |
| Study 1 results | scores and artifacts — zero new rules | `712e21b` |
| Claim-level rubric + validation criteria | taxonomy, verdict grammar, P1/P2 — zero tags | `bb3fdd1` |
| Model-axis probe rule | stances, the 13-cluster enumeration, R1/R2 — zero probe arms | `7bbde2c` |

## Study 1 — nine same-configuration arms

- **Design:** 3 completed tickets × 3 arms; one model, identical briefs
  (published verbatim in `briefs/`), shared base commit per ticket, fresh
  context per arm.
- **Ticket selection criteria (written first):** single non-merge commit;
  60–600 changed lines; problem statement separable from approach; genuine
  design latitude. One candidate rejected for size (32 lines), recorded.
- **Contamination control:** workspaces built by
  `git init && git fetch <repo> <base-sha> && checkout FETCH_HEAD` — ancestry
  only, so the shipped fix is unreachable by construction; verified per
  workspace (tip == base; reachable == ancestry). Plus instruction-level
  rules: no network, no other project copies, no sub-agents, no builds.
- **Metrics (pre-registered):** surface divergence (mean pairwise Jaccard
  distance over declared surfaces), contested-surface share, confidence
  consensus; declaration-independent file-set Jaccard from the diffs as a
  secondary.
- **Decision rule:** divergence < 0.15 ∧ contested > 0.80 on **all** tickets →
  converge; > 0.40 on all → diverge; otherwise mixed, reported as mixed.
- **Deviation policy:** unparseable declaration → arm excluded; permitted
  repair = trailing commas only; header fields corrected to known-true values;
  everything logged (`outputs/deviations-*.json`). Surface normalisation:
  whitespace trim and a leading `./` strip — no fuzzy matching anywhere.

## The claim-level instrument (registered between studies, before any tag)

- **Taxonomy** (one topic per claim): mechanism · policy · threshold · compat
  · presentation · verification. A claim bundling shape and constant may be
  split; every split recorded.
- **Clustering:** claims across arms answering the same design question; the
  adjudicator names the question, assigns topic and verdict **with a quoted
  justification**; single-arm questions are uncontested and excluded from all
  denominators.
- **Verdicts:** fork = different interface/signal/shape or ≥2× on a constant;
  same = wording/incidental; complementary = disjoint, non-conflicting.
- **Retro-validation criteria:** P1 — the known hidden fork of t2 must
  register (fork share > 0, ranking cluster = fork); P2 — amended fork shares
  must order t2 > t1, inverting the file-grain ordering. Failure of either
  halts the programme.

## Study 2 — the model axis

- **Design:** +1 Opus and +1 Sonnet arm per ticket (6 arms), identical briefs
  and bases, fresh ancestry-only workspaces, blind to study 1.
- **Stances:** per study-1 cluster, each probe arm scored `aligned` (matches
  the study-1 modal design), `fork` (same criteria as above), `unaddressed`.
- **Criterial quantity:** *mechanism flips* — probe forks on the 13 study-1
  clusters that were mechanism-topic and unanimous (enumerated in the
  registration; the scorer refuses to run if the derived set disagrees).
- **Rule:** R1 (heterogeneity load-bearing) on ≥2 flips **or** ≥1 cluster
  where both probe models agree with each other against the study-1 consensus;
  R2 otherwise. The two partition all outcomes.
- **Registered limitations:** within-family models only (lower bound); one arm
  per model per ticket (the ≥2 threshold exists so a single idiosyncratic arm
  cannot decide R1); probe arms' effort setting inherited and unverified.

## Adjudicator position, stated

The adjudicator wrote the briefs, had read the real fixes, and had seen the
interim numbers. Mitigations: criteria committed before tagging; every verdict
quotes its claims; the criterial calls are mechanically re-runnable. This is a
limitation, not a solved problem, and the two calls that affect the study-2
verdict are flagged inside `adjudication/model-axis.json` at the moment they
were made.
