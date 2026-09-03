# Study 4, phase 0 — results

Run 2026-09-03, same day as the registration and after it: rules at
`804075f` (the registration commit, whose sha is also the recorded shuffle
seed), arms at `claude-fable-5` through `agent-skill-eval` pinned `59de161`,
source frozen at terminal-delight `9707696` and verified unimplemented for
both tasks immediately before dispatch. Six agent invocations plus one smoke
prompt; per-run artifacts in `declarations/` and `audits/` here, raw
workspaces and logs retained on the machine, outside git. Deviations — two,
both plumbing, neither touching a registered rule — in `DEVIATIONS.md`.

## Outcome, under the registered three-outcome rule

**No falsifier fired. One flag stands OPEN.** Per the pre-commitment: this is
**not** evidence the approach works. It survived a small hostile test at
pilot scale, with one repetition of one task per stage. What phase 0 was
actually for — the instruments — validated end to end, and returned two
findings sharper than a survival.

## Findings

**1 — The sanity floor passed, so the falsifiers were live.** The generator
arm produced three schema-valid plans on the latitude task, each answering
all twelve questions, contested-by-string on all twelve. The trio is real
design divergence, not rewording: a transient first-paint strip plus picker
chord, a modal picker in the style of an existing internal component, and a
persistent badge with a drop-down menu — with the latitude field correctly
naming where the codebase forces agreement.

**2 — F1 did not fire, and the flag it left is a finding about task
selection, not about the instruction.** On the dictated task the arm
produced three paths claiming genuine latitude — but with **zero contract
contradictions across every dictated cell**, at an unclassified rate of 0.0
(the regex keys classified everything, on the forced arm and the unforced
baseline alike). Its three-ness lives in exec semantics, parser choice, and
three genuinely different session-adoption policies. The decisive datum: the
**uninstructed baseline also judged the task's latitude genuine, naming the
same dimensions**. The control task carried more real latitude than the
goals modelled. The F1-soft disposition stays OPEN for the registered human
trio read; the transferable lesson is that phase A's no-latitude control
must be *verified* no-latitude — an uninstructed probe agreeing there is
nothing to debate — before it can serve as F1's instrument.

**3 — The harmoniser selected; it did not synthesise.** Given three paths
and freedom to combine per question, it adopted **one path whole** — every
one of twelve adoptions from the same path, zero modifications, zero novel
answers, and every citation verbatim-honest. And the uninstructed baseline
reducer, same handoff, no instruction, **independently selected the same
path whole**. Two clean-context agents, one told to harmonise and one told
nothing, converged on wholesale selection of the same winner. At n=1 this
fires nothing and generalises to nothing — but it points exactly at the
registered selection-not-synthesis outcome (the design's T3), it suggests
the selection itself was signal rather than noise, and it is the single
observation phase A most needs to pressure-test.

**4 — The escalation clause found nothing to escalate.** Both reducers
returned `undecidable_on_paper: []` — every question decidable on paper for
this task. The playbook's Crossfire-as-escalation clause rests on that flag
being non-empty somewhere; phase A should include at least one task expected
to produce genuine on-paper undecidability, or the clause goes untested.

**5 — Instruments and plumbing, validated and priced.** The auditor's
controls (hand-built positive, decorative-citation negative, degradation,
malformed, fail-closed floor) all called correctly before any real audit.
The verbatim-adoption citation contract was followed perfectly by the model,
which makes the mechanical citation audit cheap and trustworthy at phase-A
scale. Deterministic-only grading runs with no grader key, exactly as
designed. The harness deletes workspaces after grading unless
`ASE_KEEP_WORKSPACE=1` — undocumented, cost one sample (deviation D2) — and
takes `--agent`, not `--agents` (D1). Fixture files land at workspace root
with the `files/` prefix stripped. The binary comparison axis drives an
N-configuration study cleanly as one invocation per arm, each with its free
baseline.

## Cost and timing, measured

| Run | What | Wall | Cost (USD) |
|---|---|---|---|
| smoke | isolation probe, 4 output tokens | ~3 s | 0.24 |
| A (first dispatch, lost) | G2 + baseline, td196 | 560 s | 6.53 |
| A2 | G2 + baseline, td196 | ~510 s | 6.53 |
| B | G2 + baseline, td178 | 433 s | 4.40 |
| C | H2 + baseline, td196 handoff | 298 s | 2.58 |
| **Total** | | ~30 min | **20.28** |

A stage-1 arm-plus-baseline pair costs 4.4–6.5 USD against this repository;
a stage-2 pair, 2.6. Phase A width should be costed from these numbers, not
estimated.

## What phase 0 licenses, and does not

Licenses: running phase A on these instruments, with the task-selection
repair from finding 2 and the undecidability coverage from finding 4; a
fork-coding codebook built from these outputs (which never enter phase A
denominators). Does not license: any claim that instructed divergence works,
that harmonisation adds value over selection, or that the escalation clause
earns its place. The strongest true sentence today: *the pipeline ran end to
end under registered rules, its instruments call known cases correctly, and
its first real datum came back selection-shaped.*
