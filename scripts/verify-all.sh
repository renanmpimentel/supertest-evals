#!/usr/bin/env bash
# Runs every case's verify.sh and reports which ones failed.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
failed=()
for script in "$root"/cases/*/_eval/verify.sh; do
  [[ -e "$script" ]] || continue
  if ! env -u VERIFY_DRY bash "$script"; then
    failed+=("$(basename "$(dirname "$(dirname "$script")")")")
  fi
  echo
done
if (( ${#failed[@]} )); then
  echo "failed cases: ${failed[*]}"
  exit 1
fi
echo "all cases verified"
