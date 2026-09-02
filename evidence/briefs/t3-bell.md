# Ticket t3-bell — a beep from a working agent is not a finished turn

## Context

This is a GPU-accelerated terminal emulator for Linux (Rust, gpui, an alacritty
fork). It watches panes running coding agents and announces a **finished turn**:
a sound, a badge on the tab, an `AgentDone` event, and a system notification
with click-to-jump.

Two mechanisms currently detect a finish. A periodic screen-scan heuristic,
which over time has grown several guards (a real-spell test, a not-thinking
debounce, a scroll-settle gate so scrollback navigation cannot trip a false
finish). And a **BEL arm**: many agent CLIs ring the terminal bell when a turn
completes, so a bell byte can announce the finish faster than the next scan
would.

## The problem

Two reports, and they share a root.

1. **Scrolling back through an in-flight agent's history rings the finish.**
   Sound plays, the badge latches, `AgentDone` fires, the system notification
   goes out — while the agent is plainly still working. A terminal UI beeps for
   its own reasons, and scrollback through a busy agent's history is the case
   that gets hit in practice. Reported as persistent since bell notifications
   were introduced.

2. **Opening a new window announces a burst of completions.** A new window
   restores the session; each resumed pane replays its transcript; every bell
   already inside that transcript replays with it — so a fresh window announces
   finishes for turns that actually completed hours earlier.

## The ask

- A bell must never announce a finish for an agent that is demonstrably still
  working, and a restored window must not announce finishes for turns that are
  long over.
- Genuine finishes that arrive with a bell should still be announced. The
  product stance on the trade-off: a **delayed** genuine announcement is
  acceptable, a **lost** one is not, and a **false** one is the worst outcome —
  it interrupts a person, clears the tab's state, and lies about an agent that
  is still going.
- The screen-scan path and its existing guards keep their current behaviour.
- Add tests where the logic is testable in isolation. If a scenario genuinely
  needs a live PTY and a real agent to exercise, say so in your declaration's
  `not_done` rather than faking a verification.

## Constraints

- Match the surrounding code's idiom and keep the change proportionate.
