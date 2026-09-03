#!/usr/bin/env bash
# Phase-0 preflight: everything that must hold before a single arm is spent.
# Halts (nonzero) on any failure. Spends nothing beyond one smoke prompt.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BASE="$(dirname "$HERE")"
OUT="$BASE/outputs"
TD_SOURCE="${TD_SOURCE:-$HOME/Work/terminal-delight}"
TD_PIN="${TD_PIN:?set TD_PIN to the pinned terminal-delight commit}"
HARNESS="${HARNESS:-$HOME/Projects/agent-skill-eval}"
MODEL="${MODEL:-claude-fable-5}"

mkdir -p "$OUT"

echo "== 1/6 auditor selftest (registered halt condition) =="
python3 "$HERE/audit.py" selftest

echo "== 2/6 harness venv =="
if [[ ! -x "$OUT/ase-venv/bin/agent-skill-eval" ]]; then
  python3 -m venv "$OUT/ase-venv"
  "$OUT/ase-venv/bin/pip" install --quiet -e "$HARNESS"
fi
"$OUT/ase-venv/bin/agent-skill-eval" --version

echo "== 3/6 isolated claude config (no user hooks, no user CLAUDE.md, no MCP) =="
CFG="$OUT/claude-config"
mkdir -p "$CFG"
cp -f "$HOME/.claude/.credentials.json" "$CFG/.credentials.json"
if [[ ! -f "$CFG/.claude.json" ]]; then
  printf '{"hasCompletedOnboarding": true, "bypassPermissionsModeAccepted": true}\n' > "$CFG/.claude.json"
fi
export CLAUDE_CONFIG_DIR="$CFG"

echo "== 4/6 smoke: model reachable under isolation =="
smoke=$(cd "$OUT" && claude -p --output-format json --model "$MODEL" \
  --dangerously-skip-permissions 'Reply with exactly: OK' 2>"$OUT/smoke-stderr.log")
echo "$smoke" > "$OUT/smoke.json"
python3 - "$OUT/smoke.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
res = d.get("result", "")
assert "OK" in res, f"smoke result unexpected: {res!r}"
print(f"smoke ok - result {res!r}, cost_usd {d.get('total_cost_usd')}")
PY

echo "== 5/6 frozen source at the pin =="
FROZEN="$OUT/frozen-td"
if [[ ! -d "$FROZEN/.git" ]]; then
  git clone --quiet "$TD_SOURCE" "$FROZEN"
fi
git -C "$FROZEN" checkout --quiet -B pilot-base "$TD_PIN"
bash "$HERE/verify_unimplemented.sh" "$FROZEN" "$TD_PIN"

echo "== 6/6 evals reproducible from goals (registered = generated) =="
tmp=$(mktemp -d)
cp -r "$BASE/evals" "$tmp/evals-committed"
python3 "$HERE/build_evals.py" >/dev/null
if ! diff -rq "$tmp/evals-committed" "$BASE/evals" >/dev/null; then
  echo "FAIL: committed evals differ from regenerated evals" >&2
  diff -r "$tmp/evals-committed" "$BASE/evals" | head -20 >&2
  exit 1
fi
echo "PASS: evals reproduce byte-for-byte"

echo "PREFLIGHT COMPLETE"
