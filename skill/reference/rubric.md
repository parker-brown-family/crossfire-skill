# The claim-level rubric

Validated in the study this repository publishes: applied retroactively to
nine declarations whose truth was known, it registered the hidden fork the
file-grain metric scored as 0.000 and inverted the file-grain ordering
correctly (criteria P1/P2, fixed before any tag existed).

## Topics — one per claim, by the claim's primary commitment

| Topic | A claim about |
|---|---|
| `mechanism` | how an effect is achieved — interfaces called, data structures, algorithms, threading, control flow |
| `policy` | what the system should do where the design space allows several behaviours — ranking rules, precedence, suppression conditions, defaults |
| `threshold` | a numeric constant placing a point on a continuum — durations, counts, windows |
| `compat` | behaviour toward artifacts or states produced by other versions — upgrades, legacy files, replay |
| `presentation` | the user-visible surface — wording, menus, localisation, docs, changelog |
| `verification` | tests, what was left unverified, how correctness is argued |

A claim bundling a design shape and a numeric constant may be split into two
tagged aspects during clustering; record every split.

## Clustering

Claims from different arms that answer the **same design question** form a
cluster. The adjudicator names the question, assigns one topic, and issues one
verdict **with a one-line justification quoting the claims**. A question only
one arm addressed is *uncontested* and excluded from every denominator.

## Verdicts — mechanical criteria

| Verdict | Criterion |
|---|---|
| **fork** | implementing the claims as stated yields materially different behaviour: a different interface, signal, data shape or control structure — or the same shape with a constant differing by **≥ 2×** |
| **same** | differences are wording, granularity, or incidental detail; behaviour materially identical |
| **complementary** | claims address disjoint aspects of the question and do not conflict |

## Computed reads (counting only — the scorer never judges)

- **Fork share** = fork clusters ÷ clusters with ≥ 2 arms, overall and per
  topic. Report per-topic: the study's separations lived at topic level when
  the scalar margin was thin.
- **Confidence consensus** = ≥ 2 arms' `least_confident` entries resolving
  into the same cluster. Consensus points landing on fork clusters are your
  fork-locator.
- **Cross-condition stances** (when comparing against a baseline set of arms):
  per cluster, each new arm is `aligned` with the baseline-modal design,
  `fork` against it (same criteria as above), or `unaddressed`.

## The discipline around the rubric

- Criteria and thresholds committed **before** tagging exists.
- Every verdict quotes its evidence; a disagreeing reader can re-run any call.
- Flag borderline calls and correlated calls *at the moment of the call*, and
  ship any verdict they affect with a sensitivity table.
- Do not invent new rules (de-duplication clauses, threshold adjustments)
  after seeing that they would change the verdict. If a rule was wrong, say
  so, fix it, and re-register **between** experiments — never inside one.
