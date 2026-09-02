# Ticket t2-adoption — a throwaway terminal must not bulldoze the session you actually work in

## Context

This is a GPU-accelerated terminal emulator for Linux (Rust, gpui, an alacritty
fork). It persists sessions: tabs, panes, and working state are saved to
per-session state files, and a fresh launch **adopts** an existing saved session
rather than starting empty. The current adoption rule ranks candidates by:
workspace hint (a session you were just standing on wins), then most recent save
time, then id. The scan that ranks candidates runs on every launch.

## The problem

You keep a big multi-project session — a dozen tabs, thirty panes. You open a
second window to run one command, and close it. That one-pane session is now the
most recently saved, so the next launch adopts **it**, and the session you
actually work in is reachable only by knowing an environment variable exists and
typing it into a shell to open a terminal.

The trivial window wins purely by being last, and nothing about it deserved to.

## The ask

- The arranged session must win adoption over the throwaway one in the story
  above.
- Do not introduce the opposite failure: a large session you abandoned weeks ago
  must not become permanently sticky against the work you are doing now.
- The workspace hint stays the strongest key, exactly as today: a session you
  were just standing on is the one you get back, however small it is.
- **Compatibility:** if your rule needs information the saved state files do not
  currently carry, sessions written by earlier builds — which lack it — must not
  be demoted behind fresh trivial sessions on the first launch after upgrading.
- The adoption scan runs on every launch; keep it cheap. Do not deserialise
  whole session files to rank them.
- Add tests covering the new behaviour, including the story above and the
  opposite-failure guard.

## Constraints

- Match the surrounding code's idiom and keep the change proportionate.
- Anything you cannot verify without running the app, leave untested and say so
  in your declaration's `not_done`.
