# td196 planning notes — reaching a non-newest saved session

Grounding (base commit 9707696):

- `app/src/instance.rs` — `scan_sessions()` already reads id, mtime,
  `last_workspace`, `panes` via a cheap top-level line scan; `rank()` is the
  tested adoption order; `claim_in()` is a kernel flock (`LOCK_EX|LOCK_NB`),
  the sole ownership arbiter. `resolve_session()` precedence: `$TD_SESSION` →
  ranked free session → fresh id.
- `app/src/main.rs` — established detached self-spawn pattern
  (`std::env::current_exe()` + `Command.env(...)` + `pre_exec(setsid)`), used
  for demo windows (~line 2934) and the Ctrl+Alt+T quick window (~17704).
  Help panel chord rows ~14605–14674; strings localized in `app/src/lang.rs`
  (nine languages — new picker strings need all nine).
- Ctrl+Shift+S is currently unbound. Lesson from #277/#278: bind it on the
  pane-chord path (like Ctrl+Shift+U), not only `on_key`, and consider whether
  an input method claims it on any locale before shipping.

Key design calls and why:

1. **Open in a new window via programmatic `TD_SESSION`** rather than in-place
   swap. In-place would need: save + `release()` + re-claim + full workspace
   teardown/restore inside a live gpui app — exactly the release/claim/save
   ordering that #189 and #195's comments warn about. The child process path
   reuses `resolve_session`'s precedence #1 unmodified (hooking in, which the
   ticket allows; no ranking change).
2. **Exclusivity is the existing flock.** The picker's "live" badge comes from
   a non-destructive probe (open, `LOCK_NB` try, drop fd immediately — same
   shape as `legacy_master_live_at`). Advisory only; the child's real claim is
   authoritative. Losing the race lands in today's TD_SESSION-taken behaviour.
3. **Tab count without touching the file format**: count `[[tabs]]` headers in
   the same line scan `toml_top_level_usize` uses. No new written field —
   "changing the saved-session file format" is out of scope and we don't.
4. **Ordering reuses `rank()`** so the picker's top row is literally what
   adoption picked — the list explains the default instead of contradicting it.
5. **Numbers**: strip shows ≤2 inline (ticket sketch), then a count line;
   picker shows 8 rows then scrolls (t1 = 8).
6. **Statelessness**: nothing persists; rescan on paint/chord. Strip appears
   only when ≥1 *other free* saved session exists (so never with 0 or 1 saved).

New code lands as: a `pub fn` in `instance.rs` exposing ranked
`SessionListing` entries (id, saved, panes, tabs, workspace, live, current);
strip + picker overlay + chord wiring + spawn helper in `main.rs`; strings in
`lang.rs`; help-panel row. Tests: listing excludes self and debris files,
probe is non-destructive, spawn env composition, strip visibility matrix
(0/1/≥2 sessions).
