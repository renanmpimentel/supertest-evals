#!/usr/bin/env bash
# Runs one eval round with headless Claude Code: every selected case, both arms,
# REPEATS times each, in shuffled order. Usage: run-round.sh <prompt> [case...]
#
# Both arms run in the same clean environment: --setting-sources project,local
# (no user settings, plugins, hooks, permission rules or global CLAUDE.md) and
# --strict-mcp-config (no MCP servers). The only difference is the treatment:
# the with-skill arm loads the Supertest skill, built from the commit in
# SUPERTEST_VERSION, as a session-only plugin (--plugin-dir). Nothing under
# ~/.claude is modified.
#
# Env: MODEL (default sonnet), REPEATS (default 1), MAX_PARALLEL (default 3),
#      SUPERTEST_REPO (default ~/export/supertest), ROUND_SUFFIX (appended to the
#      results folder name), RESUME=1 (rerun only the runs of an existing round
#      folder that have no successful result, e.g. after a usage limit).
# When a run hits the account usage limit, no further runs are launched.
# Evidence per run in results/<date>-<sha>-<prompt>/<case>/<arm>.<n>.*;
# score it with scripts/score-round.sh. Exits non-zero if any run failed.
# Cleanup (INT, TERM, EXIT): each agent runs in its own session (setsid) and its
# PID is written to $out/.pids; cleanup kills exactly those process groups.
set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "usage: $0 <prompt> [case...]" >&2
  exit 2
fi
root="$(cd "$(dirname "$0")/.." && pwd)"
prompt_name="$1"
shift
prompt_file="$root/prompts/$prompt_name.md"
if [[ ! -f "$prompt_file" ]]; then
  echo "unknown prompt: $prompt_file" >&2
  exit 2
fi
if (( $# )); then
  cases=("$@")
else
  mapfile -t cases < <(find "$root/cases" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
fi
for c in "${cases[@]}"; do
  if [[ ! -d "$root/cases/$c" ]]; then
    echo "unknown case: $c" >&2
    exit 2
  fi
done
for tool in claude jq git tar setsid timeout shuf; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "required tool not found on PATH: $tool" >&2
    exit 2
  fi
done
model="${MODEL:-sonnet}"
repeats="${REPEATS:-1}"
max_parallel="${MAX_PARALLEL:-3}"
repo="${SUPERTEST_REPO:-$HOME/export/supertest}"
sha="$(tr -d '[:space:]' < "$root/SUPERTEST_VERSION")"
if ! git -C "$repo" cat-file -e "$sha^{commit}" 2>/dev/null; then
  echo "cannot resolve Supertest commit '$sha' in $repo (set SUPERTEST_REPO)" >&2
  exit 2
fi
out="$root/results/$(date +%F)-$sha-$prompt_name${ROUND_SUFFIX:+-$ROUND_SUFFIX}"
resume="${RESUME:-}"
if [[ -n "$resume" ]]; then
  if [[ ! -f "$out/round.txt" ]]; then
    echo "nothing to resume: $out/round.txt not found" >&2
    exit 2
  fi
  read -r -a cases <<< "$(sed -n 's/^cases=//p' "$out/round.txt")"
  repeats="$(sed -n 's/.* repeats=\([0-9]*\).*/\1/p' "$out/round.txt")"
elif [[ -e "$out" ]]; then
  echo "results folder already exists: $out" >&2
  exit 1
fi

# Session-only plugin holding the pinned skill (outside the agent's workspace).
plugin="$(mktemp -d)/supertest-eval"
mkdir -p "$plugin/.claude-plugin" "$plugin/skills/supertest"
printf '{"name":"supertest-eval","version":"0.0.0","description":"Supertest %s for evaluation"}\n' "$sha" \
  > "$plugin/.claude-plugin/plugin.json"
git -C "$repo" archive "$sha" SKILL.md references | tar -x -C "$plugin/skills/supertest"

kill_agents() {
  local f pid
  for f in "$out"/.pids/*; do
    [[ -f "$f" ]] || continue
    pid="$(cat "$f")" || continue
    kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
  done
  wait 2>/dev/null || true
}
cleanup() {
  trap - EXIT INT TERM
  kill_agents
  rm -rf "$(dirname "$plugin")"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

run_one() {
  set +e
  local case="$1" arm="$2" n="$3"
  local id="$arm.$n" dir="$out/$case" copy status=0 start errs="" prefix=""
  local extra=()
  if [[ "$arm" == with-skill ]]; then
    prefix=$'Load the Supertest skill.\n\n'
    extra=(--plugin-dir "$plugin")
  fi
  start=$(date +%s)
  copy="$(mktemp -d)/project"
  if bash "$root/scripts/prepare-run.sh" "$root/cases/$case" "$copy" >/dev/null; then
    echo "$id $copy" >> "$dir/arms.txt"
    (cd "$copy" && exec setsid timeout 2700 claude -p "${prefix}$(cat "$prompt_file")" --model "$model" \
        --setting-sources project,local --strict-mcp-config \
        --permission-mode bypassPermissions --no-session-persistence \
        --output-format stream-json --verbose "${extra[@]}" \
        > "$dir/$id.transcript.jsonl" 2> "$dir/$id.stderr") &
    echo $! > "$out/.pids/$case.$id"
    wait $!
    status=$?
    rm -f "$out/.pids/$case.$id"
    jq -r 'select(.type=="result") | .result // empty' "$dir/$id.transcript.jsonl" > "$dir/$id.md" || errs="$errs report"
    if grep -qiE "hit your (session|usage) limit|usage limit reached" "$dir/$id.md"; then
      errs="$errs usage_limit"
      touch "$out/.limit"
    fi
    git -C "$copy" add -A || errs="$errs add"
    git -C "$copy" diff --cached --binary baseline > "$dir/$id.diff" || errs="$errs diff"
    git -C "$copy" status --porcelain -uall > "$dir/$id.status" || errs="$errs status"
  else
    errs=" prepare"
  fi
  echo "$case $id exit=$status seconds=$(( $(date +%s) - start )) error=${errs# }" | sed 's/error=$/error=none/' | tee -a "$out/runs.log"
}

mkdir -p "$out/.pids"
rm -f "$out/.limit"
if [[ -z "$resume" ]]; then
  : > "$out/runs.log"
  {
    echo "date=$(date -Is) supertest=$sha model=$model repeats=$repeats prompt=$prompt_name"
    echo "claude=$(claude --version 2>/dev/null | head -1)"
    echo "cases=${cases[*]}"
  } > "$out/round.txt"
fi
done_ok() {
  grep -qE "^$1 $2 exit=0 seconds=[0-9]+ error=none$" "$out/runs.log"
}
jobs_list=()
for case in "${cases[@]}"; do
  mkdir -p "$out/$case"
  [[ -n "$resume" ]] || : > "$out/$case/arms.txt"
  for n in $(seq 1 "$repeats"); do
    for arm in without-skill with-skill; do
      done_ok "$case" "$arm.$n" && continue
      rm -f "$out/$case/$arm.$n".*
      jobs_list+=("$case $arm $n")
    done
  done
done
if [[ -n "$resume" ]]; then
  # Keep failed attempts for the record, then drop them from runs.log.
  grep -vE 'exit=0 seconds=[0-9]+ error=none$' "$out/runs.log" >> "$out/retries.log" || true
  grep -E 'exit=0 seconds=[0-9]+ error=none$' "$out/runs.log" > "$out/runs.log.tmp" || true
  mv "$out/runs.log.tmp" "$out/runs.log"
  echo "resuming: ${#jobs_list[@]} runs to go"
fi
if (( ${#jobs_list[@]} == 0 )); then
  echo "nothing to run"
  exit 0
fi
mapfile -t jobs_list < <(printf '%s\n' "${jobs_list[@]}" | shuf)

running=0
for job in "${jobs_list[@]}"; do
  if [[ -e "$out/.limit" ]]; then
    echo "usage limit reached: no further runs launched; rerun with RESUME=1 after it resets" >&2
    break
  fi
  read -r j_case j_arm j_n <<< "$job"
  run_one "$j_case" "$j_arm" "$j_n" &
  running=$((running + 1))
  if (( running >= max_parallel )); then
    wait -n || true
    running=$((running - 1))
  fi
done
wait || true

echo "results: $out"
expected=$(( ${#cases[@]} * repeats * 2 ))
ok="$(grep -cE 'exit=0 seconds=[0-9]+ error=none$' "$out/runs.log" || true)"
echo "summary: $ok of $expected runs succeeded"
(( ok == expected ))
