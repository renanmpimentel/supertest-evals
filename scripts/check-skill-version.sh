#!/usr/bin/env bash
# Confirms the installed Supertest skill matches SUPERTEST_VERSION (fails closed).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
sha="${SUPERTEST_SHA:-$(tr -d '[:space:]' < "$root/SUPERTEST_VERSION")}"
repo="${SUPERTEST_REPO:-$HOME/export/supertest}"
installed="${SUPERTEST_INSTALLED:-$HOME/.claude/skills/supertest}"

if [[ -z "$sha" ]] || ! git -C "$repo" cat-file -e "$sha^{commit}" 2>/dev/null; then
  echo "cannot resolve pinned commit '$sha' in $repo"
  exit 1
fi
if [[ ! -f "$installed/SKILL.md" ]]; then
  echo "skill not installed at $installed"
  exit 1
fi
pinned="$(git -C "$repo" ls-tree -r --name-only "$sha" -- SKILL.md references)"
if ! grep -qx 'SKILL.md' <<< "$pinned"; then
  echo "pinned commit $sha has no SKILL.md"
  exit 1
fi

status=0
while IFS= read -r file; do
  if ! git -C "$repo" show "$sha:$file" | diff -q - "$installed/$file" >/dev/null 2>&1; then
    echo "differs from $sha: $file"
    status=1
  fi
done <<< "$pinned"
while IFS= read -r file; do
  if ! grep -qxF "$file" <<< "$pinned"; then
    echo "not in $sha: $file"
    status=1
  fi
done < <(cd "$installed" && find SKILL.md references -type f 2>/dev/null | sort)
if (( status == 0 )); then
  echo "installed skill matches $sha"
fi
exit "$status"
