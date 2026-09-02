# Ticket t1-reveal — a printed path should be revealable, not only openable

## Context

This is a GPU-accelerated terminal emulator for Linux (Rust, gpui, an alacritty
fork under `alacritty_terminal`). Panes are full of printed file paths — an
agent's links table, a build log, a report an agent just wrote. The pane already
recognises link-like text under the pointer and turns a modified click into a
resolved absolute path for its open-on-click behaviour (Shift- or Ctrl-click
opens the target); find and build on that machinery rather than re-deriving it.

## The problem

Only one of the two things you want from a printed path is a click away.
"Open it" is. "Show me where it lives, and what else is beside it" is not — that
means selecting the path with the mouse, switching to a file manager, and
pasting into its location bar.

## The ask

- **Super+Ctrl-click on a printed path reveals it in the system file manager
  with that item selected.** Shift- and Ctrl-click keep opening the target
  exactly as they do today.
- The **right-click link menu** gains an equivalent reveal action whenever the
  link under the cursor names something on this disk.
- Printed targets arrive in at least two shapes: a **bare absolute path** and a
  **`file://` URI** (agents' links tables print the latter). Both must reveal
  correctly, including names containing spaces or other awkward characters. A
  web URL must not offer or attempt reveal — it keeps the existing open
  behaviour.
- Work across the common Linux desktops and file managers rather than assuming
  one specific file manager is installed. If the environment offers no way to
  select an item, degrade to the nearest useful behaviour rather than failing
  silently.
- The UI thread must not block waiting on whatever performs the reveal.

## Constraints

- Match the surrounding code's idiom and keep the change proportionate.
- Add tests for whatever pure logic your change introduces. Anything you cannot
  verify without a running compositor or desktop session, leave untested and say
  so in your declaration's `not_done`.
