#!/usr/bin/env bash
# Checks that prepare-run.sh never hands the answer key to the agent: for every
# case, the prepared copy has no _eval/, no file identical to an _eval file, no
# mention of the strong test file, and a `baseline` tag to diff against.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

failed=0
case_failed=0
leak() {
  echo "LEAK $1: $2"
  failed=1
  case_failed=1
}

for case_dir in "$root"/cases/*/; do
  name="$(basename "$case_dir")"
  case_failed=0
  copy="$work/$name"
  bash "$root/scripts/prepare-run.sh" "$case_dir" "$copy" >/dev/null

  [[ -e "$copy/_eval" ]] && leak "$name" "_eval/ copied"

  while IFS= read -r -d '' answer; do
    while IFS= read -r -d '' file; do
      if cmp -s "$answer" "$file"; then
        leak "$name" "${file#"$copy"/} is identical to _eval/$(basename "$answer")"
      fi
    done < <(find "$copy" -path "$copy/.git" -prune -o -type f -print0)
  done < <(find "$case_dir/_eval" -type f -print0)

  if grep -q '^verify_control_case ' "$case_dir/_eval/verify.sh"; then
    : # control case: no strong test to leak
  else
    strong="$(sed -n "s/^STRONG_SRC=[\"']\{0,1\}\([^\"']*\)[\"']\{0,1\}$/\1/p" "$case_dir/_eval/verify.sh")"
    if [[ -z "$strong" ]]; then
      leak "$name" "cannot read STRONG_SRC from _eval/verify.sh"
    elif grep -rqF --exclude-dir=.git "${strong%.*}" "$copy" || [[ -n "$(find "$copy" -name "$strong")" ]]; then
      leak "$name" "copy mentions the strong test file $strong"
    fi
  fi

  git -C "$copy" rev-parse -q --verify refs/tags/baseline >/dev/null || leak "$name" "missing baseline tag"

  if (( case_failed == 0 )); then
    echo "ok   $name"
  fi
done

if (( failed )); then
  exit 1
fi
echo "no answer-key leaks"
