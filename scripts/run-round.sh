#!/usr/bin/env bash
# Runs one eval round: every selected case in both arms with headless Claude Code.
# The without-skill arm parks the installed Supertest skill outside the skills
# folder and restores it on exit. Usage: run-round.sh <prompt> [case...]
# Env: MODEL (default sonnet), MAX_PARALLEL (default 3), SUPERTEST_INSTALLED.
# Exits non-zero if any run failed, after both arms ran and the skill was restored.
# Cleanup (INT, TERM, EXIT): each agent runs in its own session (setsid) and its
# PID is written to $out/.pids; cleanup kills exactly those process groups (never
# by name, so other claude sessions are untouched), then restores the skill.
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
for tool in claude jq setsid timeout; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "required tool not found on PATH: $tool" >&2
    exit 2
  fi
done
model="${MODEL:-sonnet}"
max_parallel="${MAX_PARALLEL:-3}"
skill="${SUPERTEST_INSTALLED:-$HOME/.claude/skills/supertest}"
parked="$(dirname "$(dirname "$skill")")/supertest-skill-parked"
sha="$(tr -d '[:space:]' < "$root/SUPERTEST_VERSION")"
out="$root/results/$(date +%F)-$sha-$prompt_name"
if [[ -e "$out" ]]; then
  echo "results folder already exists: $out" >&2
  exit 1
fi
if [[ -e "$parked" ]]; then
  echo "parked skill dir already exists: $parked (restore or remove it first)" >&2
  exit 2
fi
bash "$root/scripts/check-skill-version.sh"

kill_agents() {
  local f pid
  for f in "$out"/.pids/*; do
    [[ -f "$f" ]] || continue
    pid="$(cat "$f")" || continue
    kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
  done
  wait 2>/dev/null || true
}

restore_skill() {
  if [[ -d "$parked" && ! -e "$skill" ]]; then
    mv "$parked" "$skill"
    echo "skill restored"
  elif [[ -d "$parked" && -e "$skill" ]]; then
    echo "WARNING: both parked skill ($parked) and skill dir ($skill) exist; nothing moved, resolve manually" >&2
  fi
}
cleanup() {
  trap - EXIT INT TERM
  kill_agents
  restore_skill
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

run_arm() {
  set +e
  local case="$1" arm="$2" prefix="$3"
  local dir="$out/$case" copy status=0 start errs=""
  start=$(date +%s)
  copy="$(mktemp -d)/project"
  if bash "$root/scripts/prepare-run.sh" "$root/cases/$case" "$copy" >/dev/null; then
    echo "$arm $copy" >> "$dir/arms.txt"
    (cd "$copy" && exec setsid timeout 2700 claude -p "${prefix}$(cat "$prompt_file")" --model "$model" \
        --permission-mode bypassPermissions --strict-mcp-config --no-session-persistence \
        --output-format stream-json --verbose \
        > "$dir/$arm.transcript.jsonl" 2> "$dir/$arm.stderr") &
    echo $! > "$out/.pids/$case.$arm"
    wait $!
    status=$?
    rm -f "$out/.pids/$case.$arm"
    jq -r 'select(.type=="result") | .result // empty' "$dir/$arm.transcript.jsonl" > "$dir/$arm.md" || errs="$errs report"
    jq -r 'select(.type=="system" and .subtype=="hook_response")
           | "\(.hook_name // .hook_event) exit=\(.exit_code // "n/a")\n\(.stdout // "")"' \
        "$dir/$arm.transcript.jsonl" > "$dir/$arm.hooks.txt" || errs="$errs hooks"
    git -C "$copy" add -A || errs="$errs add"
    git -C "$copy" diff --cached --binary baseline > "$dir/$arm.diff" || errs="$errs diff"
    git -C "$copy" status --porcelain -uall > "$dir/$arm.status" || errs="$errs status"
  else
    errs=" prepare"
  fi
  echo "$case $arm exit=$status seconds=$(( $(date +%s) - start )) error=${errs# }" | sed 's/error=$/error=none/' | tee -a "$out/runs.log"
}

run_all() {
  local arm="$1" prefix="$2" running=0 case
  for case in "${cases[@]}"; do
    run_arm "$case" "$arm" "$prefix" &
    running=$((running + 1))
    if (( running >= max_parallel )); then
      wait -n || true
      running=$((running - 1))
    fi
  done
  wait || true
}

mkdir -p "$out/.pids"
: > "$out/runs.log"
for case in "${cases[@]}"; do
  mkdir -p "$out/$case"
  : > "$out/$case/arms.txt"
done

echo "== without-skill"
mv "$skill" "$parked"
run_all without-skill ""
restore_skill
bash "$root/scripts/check-skill-version.sh"

echo "== with-skill"
run_all with-skill $'Load the Supertest skill.\n\n'
restore_skill
echo "results: $out"
failed="$(grep -vc 'exit=0 seconds=[0-9]* error=none$' "$out/runs.log" || true)"
total="$(wc -l < "$out/runs.log")"
echo "summary: $total runs, $failed failed"
(( failed == 0 ))
