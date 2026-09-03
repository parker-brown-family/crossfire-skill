#!/usr/bin/env bash
# Run-time precondition, registered: both tasks must be unimplemented in the
# frozen source at the pinned commit immediately before dispatch. Selecting
# OPEN tickets is what dissolved the ancestry-only workspace requirement; this
# check is the price of that simplification.
set -euo pipefail

REPO="${1:?usage: verify_unimplemented.sh <repo> <pin>}"
PIN="${2:?usage: verify_unimplemented.sh <repo> <pin>}"

head=$(git -C "$REPO" rev-parse HEAD)
if [[ "$head" != "$PIN"* ]]; then
  echo "FAIL: HEAD $head is not the pinned $PIN" >&2
  exit 1
fi
echo "PASS: frozen source at $head"

fail=0
check_absent() {
  local label="$1" pattern="$2"
  if hits=$(grep -rniE "$pattern" "$REPO/app/src" --include='*.rs' 2>/dev/null | head -3) && [[ -n "$hits" ]]; then
    echo "FAIL: $label already present:" >&2
    echo "$hits" >&2
    fail=1
  else
    echo "PASS: $label absent"
  fi
}

# td196 - a session picker UI (pick_session_by_birth is internal ranking, not UI)
check_absent "td196 session picker UI" 'session_picker|SessionPicker|session_menu|pick_a_session'
# td178 - the xdg-terminal-exec CLI surface
check_absent "td178 CLI exec surface" '"-e"|set_app_id|X-TerminalArg|--working-directory'

exit $fail
