#!/usr/bin/env bash
# Confirms the installed Supertest skill matches SUPERTEST_VERSION.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
sha="$(tr -d '[:space:]' < "$root/SUPERTEST_VERSION")"
repo="${SUPERTEST_REPO:-$HOME/export/supertest}"
installed="${SUPERTEST_INSTALLED:-$HOME/.claude/skills/supertest}"

if [[ ! -f "$installed/SKILL.md" ]]; then
  echo "skill not installed at $installed"
  exit 1
fi
status=0
while IFS= read -r file; do
  if ! git -C "$repo" show "$sha:$file" | diff -q - "$installed/$file" >/dev/null 2>&1; then
    echo "differs from $sha: $file"
    status=1
  fi
done < <(git -C "$repo" ls-tree -r --name-only "$sha" -- SKILL.md references)
if (( status == 0 )); then
  echo "installed skill matches $sha"
fi
exit "$status"
