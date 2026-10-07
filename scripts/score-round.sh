#!/usr/bin/env bash
# Scores a round without human judgment. Writes <results-dir>/runs.csv (one row
# per run) and <results-dir>/summary.md (rates per case and arm).
# Usage: score-round.sh <results-dir>   Env: MAX_PARALLEL (default 4).
#
# Per run:
#   verdict        last "VERDICT: adequate|inadequate" line of the final report
#   verdict_ok     gap cases expect "inadequate"; control cases expect "adequate"
#   fix_check      scripts/check-agent-fix.sh: the agent's tests pass on correct
#                  code and fail with the reference regression
#   prod_intact    every changed file is a test file
#   test_lines     lines added by the agent's diff
#   skill_loaded   the transcript shows the Supertest skill being invoked
#   cost_usd, turns, seconds   from Claude Code's final result message
set -euo pipefail
if [[ $# -ne 1 ]]; then
  echo "usage: $0 <results-dir>" >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
results="$(cd "$1" && pwd)"
max_parallel="${MAX_PARALLEL:-4}"
test_re='(^|/)tests?/|_test\.go$|\.test\.ts$|(^|/)test_[^/]*\.py$'
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

mapfile -t runs < <(cd "$results" && find . -mindepth 2 -maxdepth 2 -name '*.md' -printf '%P\n' \
  | grep -E '^[^/]+/(with|without)-skill\.[0-9]+\.md$' | sed 's/\.md$//' | sort)
if (( ${#runs[@]} == 0 )); then
  echo "no runs found in $results" >&2
  exit 1
fi

# Independent fix checks run in parallel; each writes pass/fail to its own file.
for run in "${runs[@]}"; do
  printf '%s\n' "$run"
done | xargs -P "$max_parallel" -I{} bash -c '
  run="$1"; case="${run%%/*}"; id="${run#*/}"
  if bash "$2/scripts/check-agent-fix.sh" "$3" "$case" "$id" > "$4/${case}.${id}.log" 2>&1; then
    echo pass > "$4/${case}.${id}.fix"
  else
    echo fail > "$4/${case}.${id}.fix"
  fi' _ {} "$root" "$results" "$work"

csv="$results/runs.csv"
echo "case,kind,arm,run,verdict,verdict_ok,fix_check,prod_intact,test_lines,skill_loaded,cost_usd,turns,seconds" > "$csv"
for run in "${runs[@]}"; do
  case="${run%%/*}"
  id="${run#*/}"
  arm="${id%.*}"
  n="${id##*.}"
  base="$results/$case/$id"
  if grep -q '^verify_control_case ' "$root/cases/$case/_eval/verify.sh"; then
    kind=control
    expected=adequate
  else
    kind=gap
    expected=inadequate
  fi
  verdict="$(grep -oiE 'VERDICT:[*` ]*(adequate|inadequate)' "$base.md" | tail -1 \
    | grep -oiE '(in)?adequate' | tr '[:upper:]' '[:lower:]' || true)"
  verdict="${verdict:-none}"
  [[ "$verdict" == "$expected" ]] && verdict_ok=yes || verdict_ok=no
  fix_check="$(cat "$work/$case.$id.fix")"
  prod_intact=yes
  while read -r _ path; do
    [[ -z "$path" ]] && continue
    if ! grep -qE "$test_re" <<< "$path"; then
      prod_intact=no
    fi
  done < "$base.status"
  test_lines="$(grep -cE '^\+[^+]|^\+$' "$base.diff" || true)"
  if jq -e 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Skill" and (.input.skill | test("supertest")))' \
      "$base.transcript.jsonl" >/dev/null 2>&1; then
    skill_loaded=yes
  else
    skill_loaded=no
  fi
  read -r cost turns ms < <(jq -r 'select(.type=="result") | "\(.total_cost_usd // 0) \(.num_turns // 0) \(.duration_ms // 0)"' \
    "$base.transcript.jsonl" | tail -1)
  echo "$case,$kind,$arm,$n,$verdict,$verdict_ok,$fix_check,$prod_intact,$test_lines,$skill_loaded,${cost:-0},${turns:-0},$(( ${ms:-0} / 1000 ))" >> "$csv"
done

summary="$results/summary.md"
{
  echo "# Round summary"
  echo
  sed 's/^/    /' "$results/round.txt" 2>/dev/null || true
  echo
  echo "Gap cases expect \`VERDICT: inadequate\` and a fix that catches the reference regression; the control case expects \`VERDICT: adequate\`. Rates are runs meeting the criterion / runs."
  echo
  echo "| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |"
  echo "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
  LC_ALL=C awk -F, 'NR>1 {
      k=$1 FS $3; n[k]++; v[k]+=($6=="yes"); f[k]+=($7=="pass"); p[k]+=($8=="yes")
      s[k]+=($10=="yes"); l[k]+=$9; c[k]+=$11; t[k]+=$13; kind[k]=$2
    }
    END {
      for (k in n) {
        split(k, a, FS)
        label = (kind[k]=="control") ? a[1] " (control)" : a[1]
        printf "| %s | %s | %d/%d | %d/%d | %d/%d | %d/%d | %.0f | %.2f | %.0f |\n",
          label, a[2], v[k], n[k], f[k], n[k], p[k], n[k], s[k], n[k], l[k]/n[k], c[k]/n[k], t[k]/n[k]
      }
    }' "$csv" | sort
  echo
  echo "## Totals per arm"
  echo
  echo "| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |"
  echo "| --- | --- | --- | --- | --- | --- |"
  LC_ALL=C awk -F, 'NR>1 {
      k=$3 FS $2; n[k]++; v[k]+=($6=="yes"); f[k]+=($7=="pass"); p[k]+=($8=="yes"); c[k]+=$11
    }
    END {
      for (k in n) {
        split(k, a, FS)
        printf "| %s | %s | %d/%d | %d/%d | %d/%d | %.2f |\n", a[1], a[2], v[k], n[k], f[k], n[k], p[k], n[k], c[k]
      }
    }' "$csv" | sort
} > "$summary"
cat "$summary"
