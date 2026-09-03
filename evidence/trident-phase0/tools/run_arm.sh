#!/usr/bin/env bash
# One harness invocation = one stage arm plus its no-skill baseline.
# Usage: run_arm.sh <skill-dir> <evals-file> <workspace-dir> [source-repo]
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BASE="$(dirname "$HERE")"
OUT="$BASE/outputs"
MODEL="${MODEL:-claude-fable-5}"
TIMEOUT="${ARM_TIMEOUT:-1800}"

SKILL="${1:?skill dir}"
EVALS="${2:?evals file}"
WS="${3:?workspace dir}"
SOURCE="${4:-}"

export CLAUDE_CONFIG_DIR="$OUT/claude-config"

args=(
  run
  --skill "$SKILL"
  --evals "$EVALS"
  --agents claude-code
  --agent-model "claude-code=$MODEL"
  --workspace "$WS"
  --timeout "$TIMEOUT"
  --runs 1
  --iteration 1
  --concurrency 1
)
if [[ -n "$SOURCE" ]]; then
  args+=(--source-repo "$SOURCE")
fi

exec "$OUT/ase-venv/bin/agent-skill-eval" "${args[@]}"
