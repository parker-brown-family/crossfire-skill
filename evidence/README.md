# Evidence — the audit layer, published in full

Everything needed to check the report's claims, exactly as produced by the
studies. Nothing here is summarised or re-typed; these are the files the
scorers ran on.

| Path | What |
|---|---|
| `METHOD.md` | Studies 1 and 2's complete rules, with the pre-registration hash chain |
| `PREREGISTRATION-study3-declaration-pass.md` | **Study 3, registered and unrun**: hypothesis, frozen ground-truth cluster set, three-conjunct decision rule, limitations — committed here before any arm was dispatched |
| `briefs/` | The three ticket briefs, verbatim — audit them for approach leakage |
| `declarations/stage0/` | All nine same-configuration arm declarations |
| `declarations/model-axis/` | All six probe arm declarations (Opus, Sonnet) |
| `adjudication/stage0.json` | 28 clusters: question, topic, verdict, members, quoted justification |
| `adjudication/model-axis.json` | Per-cluster probe stances — including the flagged borderline call (`t2-adoption`/`c5`) and the flagged correlated pair (`t3-bell`/`c1`+`c2`) that the report's sensitivity table turns on |
| `outputs/` | Per-arm costs, deviation logs, collection summaries |

Re-run any number: the scoring tools in `../skill/tools/` consume exactly these
files, and they count — every judgement lives here, quoted, where you can
disagree with it.

## The boundary, stated rather than implied

**Published: everything needed to audit the claims. Withheld: everything only
needed to reproduce the code.** The fifteen raw implementation diffs and the
fifteen full session transcripts are not in this repository: the diffs carry
verbatim source context from a private production codebase, and the
transcripts carry wholesale file reads of it. No claim in the report rests on
either — the decision layer above is the evidence chain. Both are retained in
the private corpus and are available on request for bona fide review.
