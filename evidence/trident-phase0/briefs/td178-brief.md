# feat: implement the xdg-terminal-exec contract so TD can be quattro's default terminal

Source: https://github.com/parker-brown-family/terminal-delight/issues/178 — verbatim snapshot 2026-09-03, base commit 9707696.

## Problem
TD cannot run a command at launch (no `-e`), set a window app-id, or honor the `X-TerminalArg*` desktop-entry contract — so it cannot occupy Omarchy quattro's default-terminal slot (`~/.config/xdg-terminals.list`, consumed by `xdg-terminal-exec`) and `omarchy agent` / `omarchy-launch-tui` cannot land agents in TD panes. Surface: CLI handling in `app/src/main.rs`; `packaging/terminal-delight.desktop`.

## Proof it's real
- `terminal-delight --help` launches the GUI — there is no CLI arg surface at all (verified 2026-08-29; also bit the 2026-08-29 session-recovery work).
- `packaging/terminal-delight.desktop` carries only Type/Name/Exec/Icon/Categories — none of the `X-TerminalArgExec/AppId/Title/Dir` keys Omarchy's shipped terminal entries carry (compare `/usr/share/omarchy/applications/foot.desktop` on omarchy 4.0.1: `X-TerminalArgExec=-e`, `X-TerminalArgAppId=--app-id=`, `X-TerminalArgTitle=--title=`, `X-TerminalArgDir=--working-directory=`).
- The consuming contract is live on quattro: `/usr/bin/omarchy-launch-tui` execs `xdg-terminal-exec --app-id=$APP_ID -e "$1" …`; `omarchy-launch-terminal` passes `--dir=`.
- gpui already exposes the needed primitive (`Window::set_app_id`, present in the pinned checkout), and `term::spawn_in(cwd)` already exists — the gap is pure CLI plumbing + desktop keys.

## Reproduce
```
app/target/release/terminal-delight -e htop
```
htop does not run; TD opens its normal GUI with the default shell (the args are not parsed).

## Verify it IS a problem
`grep -nE '"-e"|app-id|working-directory|--title' app/src/main.rs` → no CLI handling of these args, and the desktop file has no `X-TerminalArg*` keys.
**Invalidate:** if a current build runs `terminal-delight -e htop` in its first pane AND the installed desktop entry carries the four `X-TerminalArg*` keys → this is already done; close `invalid` with the commit that shipped it.

## Done when
With `terminal-delight.desktop` first in `~/.config/xdg-terminals.list`:
- `xdg-terminal-exec --app-id=test.td --dir=/tmp -e htop` opens a TD window whose Wayland app-id is `test.td`, first pane cwd `/tmp`, running htop; and
- `omarchy-launch-tui --app-id=org.omarchy.agent claude` lands claude in a TD pane (i.e. `omarchy agent` works with TD as the default terminal).
(The `omarchy default terminal` *setter* whitelists four terminals — hand-written `xdg-terminals.list` works today; a 4-line PR to basecamp/omarchy adds TD to the case list. Track that separately once this lands.)

## Behaviour
Given Omarchy quattro with terminal-delight.desktop listed first in ~/.config/xdg-terminals.list
When the user runs `omarchy agent` (or any omarchy-launch-tui command)
Then the agent opens inside a Terminal Delight pane under app-id org.omarchy.agent, in the caller's working directory

## Context
Foundation interrogation 2026-08-29, §6 opportunity 1: `docs/2026-08-29-foundation-interrogation-zed-gpui-quickshell.md` (branch `docs/foundation-interrogation`). Related: #165 (AUR packaging — same desktop-entry surface). APES ticket: interrogate-the-zed-gpui-foundation-…-mteerrs6.

