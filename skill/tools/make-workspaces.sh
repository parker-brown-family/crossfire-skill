#!/usr/bin/env bash
# make-workspaces.sh <repo-path> <base-sha> <n> [dest-root]
#
# Build N contamination-controlled arm workspaces for one Crossfire experiment.
#
# The control is constructional, not instructional: `git fetch <repo> <sha>`
# transfers that commit and its ANCESTRY only. The shipped fix — a descendant
# of the base — is unreachable from the fetched tip, so no arm can leak it,
# whatever the arm decides to read. The past stays visible on purpose: the
# original implementer had history too.
#
# Each workspace is verified before it counts: tip == base, and reachable
# object count == ancestry count (no stray refs smuggled anything newer).
set -euo pipefail

REPO=${1:?usage: make-workspaces.sh <repo-path> <base-sha> <n> [dest-root]}
BASE=${2:?base sha required}
N=${3:?arm count required}
ROOT=${4:-"$PWD/crossfire-arms"}

mkdir -p "$ROOT"
letters=(a b c d e f g h i j k l)

for i in $(seq 1 "$N"); do
  arm=${letters[$((i-1))]}
  w="$ROOT/arm-$arm/repo"
  mkdir -p "$w"
  git -C "$w" init -q
  git -C "$w" fetch -q "$REPO" "$BASE"
  git -C "$w" checkout -q FETCH_HEAD
  git -C "$w" switch -q -c work
  git -C "$w" config user.email crossfire-arm@localhost
  git -C "$w" config user.name  "crossfire arm $arm"

  tip=$(git -C "$w" rev-parse HEAD)
  hist=$(git -C "$w" rev-list --count HEAD)
  all=$(git -C "$w" rev-list --all | wc -l)
  echo "arm-$arm  tip=${tip:0:8} (want ${BASE:0:8})  history=$hist  reachable=$all"
  [ "$tip" = "$BASE" ]  || { echo "FATAL: tip mismatch in $w" >&2; exit 1; }
  [ "$hist" = "$all" ]  || { echo "FATAL: objects beyond ancestry in $w" >&2; exit 1; }
done

echo "---"
echo "$N workspace(s) ready under $ROOT — the future is absent by construction."
echo "Give each arm ONLY its own arm-<x>/ path; arms collect deliverables one"
echo "level above their repo/ (implementation.diff, declaration.json)."
