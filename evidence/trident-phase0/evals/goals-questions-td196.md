# Goal outcomes - No way to reach a saved session that isn't the newest

The plan that goes forward must take a clear position on every question:

- q1: Where does the affordance for reaching a non-newest saved session live (which UI surface or entry point, named concretely)?
- q2: How does a user learn that other saved sessions exist at all — what breaks the current silence, and is it passive (always visible) or active (summoned)?
- q3: How is an individual saved session identified to a human — exactly what is shown per session (id, working directories, timestamp, pane count, title, preview)?
- q4: What is the end-to-end interaction sequence to open a session that is not the newest, from launch (or from a running instance) to that session being live?
- q5: When another saved session is opened from a running Terminal Delight, what happens to the currently adopted session (replaced in place, new window, saved and closed)?
- q6: Does opening a saved session claim it exclusively, and what prevents two running instances from adopting the same saved session?
- q7: What is the behaviour with zero saved sessions and with exactly one — does the affordance appear at all in each case?
- q8: In what order are sessions presented, and what rule decides it?
- q9: How many sessions are shown before an overflow behaviour applies, and what is the overflow behaviour? The plan must name a concrete number.
- q10: Does any state introduced by this feature persist across restarts (and where), or is the affordance stateless per launch?
- q11: Can the whole flow be completed without setting any environment variable?
- q12: Is the existing cold-launch default — adopting the most recently saved free session with no interaction — preserved unchanged?
Where a question demands a named number, record it in the thresholds field: t1 (A named maximum number of sessions shown before overflow behaviour applies (q9). Any concrete number satisfies the check; absence fails it.)

Out of scope (a plan touching one must say so): Changing the saved-session file format; Changing the ranking rule inside resolve_session (hooking into it is in scope; reordering its policy is not); Removing or breaking the existing TD_SESSION environment variable; Cross-machine or remote session sync; A general session-management redesign beyond reaching a non-newest saved session
