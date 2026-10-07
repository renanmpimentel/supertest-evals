#!/usr/bin/env bash
# Independent check of an agent's test changes: applies the agent's diff to a
# fresh copy of the case and runs the case's whole suite on correct code (must
# pass) and with the reference regression (must fail, not by a build error).
set -euo pipefail
if [[ $# -ne 3 ]]; then
  echo "usage: $0 <results-dir> <case> <arm>" >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
results="$(cd "$1" && pwd)"
case="$2"
arm="$3"
case_dir="$root/cases/$case"
diff_file="$results/$case/$arm.diff"
if [[ ! -f "$diff_file" ]]; then
  echo "missing $diff_file" >&2
  exit 2
fi

export VERIFY_DRY=1
# shellcheck source=/dev/null
source "$case_dir/_eval/verify.sh"
: "${SUITE_CMD:?SUITE_CMD not set in $case/_eval/verify.sh}"
: "${SUITE_FAIL_RE:?SUITE_FAIL_RE not set in $case/_eval/verify.sh}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
for variant in correct regressed; do
  bash "$root/scripts/prepare-run.sh" "$case_dir" "$work/$variant" >/dev/null
  if [[ -s "$diff_file" ]]; then
    git -C "$work/$variant" apply "$diff_file"
  fi
done
git -C "$work/regressed" apply "$case_dir/_eval/regression.patch"

status=0
run_tests "$work/correct" "$SUITE_CMD" "$work/correct.log" || status=$?
if (( status == 0 )) && grep -Eq "$PASS_RE" "$work/correct.log"; then
  correct=pass
else
  correct=FAIL
fi
status=0
run_tests "$work/regressed" "$SUITE_CMD" "$work/regressed.log" || status=$?
if (( status == 0 )); then
  regressed="PASS (regression missed)"
elif grep -Eq "$ERROR_RE" "$work/regressed.log"; then
  regressed="ERROR (build or collection error)"
elif grep -Eq "$SUITE_FAIL_RE" "$work/regressed.log"; then
  regressed="fail (regression caught)"
else
  regressed="ERROR (no test failure observed)"
fi
echo "$case $arm: correct code -> $correct; reference regression -> $regressed"
[[ "$correct" == pass && "$regressed" == "fail (regression caught)" ]]
