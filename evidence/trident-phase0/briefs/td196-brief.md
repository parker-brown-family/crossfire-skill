# No way to reach a saved session that isn't the newest

Source: https://github.com/parker-brown-family/terminal-delight/issues/196 — verbatim snapshot 2026-09-03, base commit 9707696.

## Problem

PR #195 makes a cold launch adopt the most-recently-saved free session, which
fixes the reopen case from #194. It does **not** give you a way to reach any
*other* saved session. If the one you want is second-newest, the only route is
knowing that `$TD_SESSION` exists and typing
`TD_SESSION=7 terminal-delight` — an env var, from a shell, to open a terminal.

The silence #194 identified as the real defect is therefore only half closed.
TD knows how many sessions exist and says nothing about any of them.

## Proof it's real

`resolve_session()` (`app/src/instance.rs`) ranks every candidate and returns the
first it can claim; the rest are discarded without ever being named in the UI.
There is no picker, no menu entry, and no first-paint hint. Verified on the
release binary during #195: a sandbox holding sessions `1` and `2` opened `2` and
gave no indication `1` existed.

## Reproduce

1. Have two saved sessions, e.g. `sessions/1.toml` and `sessions/2.toml`.
2. Launch TD. It opens the newer one.
3. Try to open the older one using only the UI. There is no way.

## Verify it IS a problem

**Confirm:** with ≥2 saved sessions and none live, launch TD and look for any
affordance naming the sessions you did not get. If there is none, it's real.

**Invalidate → close `invalid`:** if a picker, session menu, or first-paint strip
already lists saved sessions and can open one, this is done.

## Gherkin

```gherkin
Given three saved sessions and none of them live
 When I launch Terminal Delight
 Then it opens the most recent one
  And I can see that the other two exist
  And I can open either without setting an environment variable
```

## Sketch

A first-paint strip when other free sessions exist, and a picker behind a chord:

```
┌──────────────────────────────────────────┐
│  2 other saved sessions                  │
│  7 · 2 tabs · 19:04    1 · 1 tab · Aug 27│
└──────────────────────────────────────────┘
```

Wants `saved`/tab-count metadata that `scan_sessions()` already reads, so the data
layer exists — this is a UI surface, not new plumbing.

## Done when

With ≥2 saved sessions and none live, a launch names the ones it did not adopt
and can open any of them without `$TD_SESSION`.

