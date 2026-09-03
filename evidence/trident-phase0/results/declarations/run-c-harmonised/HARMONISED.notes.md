# td196 harmonise — working notes

Goal: no way to reach a saved session that isn't the newest. Judged on paper only,
against goals-questions.md. Order of paths carries no meaning.

## The two architectural axes

**Switch model.** Paths 1 & 2: keep the current window, spawn a detached self-process
with `TD_SESSION=<id>` (existing demo-spawn pattern + existing explicit-session boot
path); one window per session. Path 3: in-place replacement — claim target flock,
save+release current, rebuild the window; requires refactoring instance's process
binding from set-once to rebindable (mutex-held key).

Decision: new-window spawn. Reasons decidable on paper:
- Reuses an existing end-to-end boot path; path 3 writes new mid-run restore
  machinery plus a named refactor of the core binding.
- Rebinding the process-wide session lock is exactly the machinery whose
  untouched-ness underwrites q12; the spawn model never touches it.
- Paths 1 and 2 *independently* cite instance.rs's module doc for the
  one-window-per-session / tiling-desktop model — corroborating evidence.
- q11 is still fully satisfied: the user sets no env var; TD_SESSION appears only
  in the child's environment (reuse ≠ the out-of-scope "removing or breaking").
  Path 3's "no env var even internally" is purer but only exists inside the
  in-place model, which loses on risk.

**Surface.** Path 1: persistent badge ('⧉ N') in the top-right icon row + dropdown
menu (chord Ctrl+Shift+S too). Path 2: transient ~8s first-paint strip + overlay
picker. Path 3: modal only, with a window-title suffix as the passive hint.

Decision: persistent badge (path 1). q2 asks what breaks the silence:
- Path 2's strip dismisses on keystroke/click/~8s — a user mid-launch misses it and
  silence returns (path 1's rationale states this rebuttal explicitly).
- Path 3's title suffix depends on the WM rendering titles and is off-window.
- The badge is passive, persistent, in-app, and disappears when nothing is
  actionable (q7), so it earns its pixels.
This pulls q1, q2, q7, q9 as a coherent cluster.

## Per-question

- q1 → path-1 (badge + menu; chord kept, so keyboard entry survives).
- q2 → path-1 (passive & persistent beats passive & transient; decidable).
- q3 → path-1: id, panes, relative age, last_workspace hint — all already in
  Candidate, zero new parsing; compact enough for a dropdown row. Path 3's tab
  count adds scan-time parsing a 5-row menu doesn't need (its no-format-change
  claim is credible, but the cost buys little here).
- q4 → path-1 (badge-coherent statement of the spawn flow).
- q5 → path-1 ≡ path-2 in substance (current window untouched, target in new
  window). Path 1's text adds "no rebinding of the process-wide session lock /
  cannot lose unsaved layout" — marginally more informative; substance decided,
  source choice by coherence. NOT undecidable: the answer itself is determined.
- q6 → path-1 over path-2: both keep the claim_in flock as sole arbiter with a
  non-stealing probe and a scratch-window message on a lost race. Differentiator:
  path 1 greys live sessions as 'live' (complete picture of *saved* sessions,
  explains absence), path 2 filters them out (count silently lies about what's on
  disk). Decidable in path 1's favour.
- q7 → path-1: zero-other-free (incl. the single-session install) hides the badge;
  chord still opens menu w/ empty state. Covers both cases q7 names.
- q8 → path-1: rank() order minus the adopted id — top row is what a cold launch
  would adopt next; greyed live rows sink to a tail (coheres with q6). Scope line
  explicitly blesses hooking rank(); path 3's pure-recency display would
  contradict actual adoption order and teach the wrong model. Decidable.
- q9 → path-1: 5 rows then '…and N more' expanding to a scroll list. The number is
  coupled to the surface (3 fits a strip, 9 a modal, 5 a dropdown); with the badge
  menu adopted, 5 is the coherent named threshold. t1 = 5.
- q10 → path-1: stateless, rescans on save + focus events — the refresh policy a
  standing badge actually needs (path 2's paint-time rescan presumes the strip).
- q11 → path-1: click-only flow possible; TD_SESSION only in the child env.
- q12 → path-1: adoption byte-for-byte unchanged; badge painted after
  resolve_session decided; never intercepts boot.

## Claims

- undecidable_on_paper: [] — every question resolved by a stated-goal argument or
  by coherence with a decidable architectural choice. Near-ties (q5, q10, q12)
  were substantively identical across paths, i.e. the *position* was determined;
  only provenance needed picking.
- out_of_scope_touched: [] — file format unchanged (existing Candidate fields
  only); rank() hooked, never reordered; TD_SESSION reused, not removed/broken;
  no cross-machine sync; single-purpose surface, not a session-management
  redesign.

Note on path-1 sweep: the outcome is 12/12 path-1, but each question was judged
individually; path 1 wins the surface cluster on q2's persistence argument and
shares the winning switch model with path 2, whose per-question texts lose only
on coherence (they narrate the strip). No overall ranking was applied.
