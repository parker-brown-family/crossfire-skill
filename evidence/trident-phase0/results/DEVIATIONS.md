# Phase-0 deviations log

Running record, appended at the moment each deviation happened. Rules-neutral:
nothing here changes a registered threshold, key, prompt, or falsifier.

## D1 — driver flag wrong; caught before any spend

`tools/run_arm.sh` as registered passed `--agents`; the harness takes
`--agent`. The first dispatch of Run A failed at argument parsing, before any
agent invocation. Fixed in the driver; no arm ran, no cost.

## D2 — Run A dispatched once without workspace retention; declarations lost

The harness deletes every eval workspace after grading unless the environment
variable `ASE_KEEP_WORKSPACE` is set (`runner.py:593` at the pinned commit).
This appears in no CLI help text and was found only when Run A's first
completed dispatch (both configs, all four deterministic assertions passing,
cost 6.53 USD, 559.8 s for the pair) left no PLAN files to audit. The
declarations from that sample are unrecoverable — the trajectory records no
tool payloads — and its grading evidence, summary and timing are preserved
untouched under `outputs/ws-a-attempt1-workspaces-lost/`.

Run A was re-dispatched with workspaces kept. No audit ran on the lost
sample; the floor gate runs on the second sample only, and the second sample
replaces the first wholesale (the registration's single repetition), with
this note as the record that a first sample existed.

Classified as the pilot doing its job: a plumbing property of the harness
that phase A must know (`ASE_KEEP_WORKSPACE=1`), surfaced at pilot cost.
