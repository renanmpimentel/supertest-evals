#!/usr/bin/env bash
# Guards the skill against overfitting to these cases: flags every distinctive
# term from the cases (identifiers and numbers in production code, tests and
# CONTRACT.md) that appears in the skill under evaluation but did not appear in
# the baseline skill, written before any case existed.
# Usage: check-skill-overfit.sh [sha]   Env: SUPERTEST_REPO, SKILL_BASELINE (18a0c4a).
# Exits 1 when a term leaked.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
repo="${SUPERTEST_REPO:-$HOME/export/supertest}"
sha="${1:-$(tr -d '[:space:]' < "$root/SUPERTEST_VERSION")}"
baseline="${SKILL_BASELINE:-18a0c4a}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

skill_text() {
  git -C "$repo" archive "$1" SKILL.md references | tar -x -O
}
terms() {
  # identifiers of 4+ characters (split on camelCase and snake_case) and numbers of 2+ digits
  tr -c 'A-Za-z0-9_,' '\n' \
    | sed -E 's/([a-z])([A-Z])/\1\n\2/g; s/_/\n/g' \
    | sed -E 's/,([0-9]{3})/\1/g' \
    | tr 'A-Z' 'a-z' \
    | grep -E '^([a-z]{4,}|[0-9]{2,})$' | sort -u
}

git -C "$root" ls-files -- cases | grep -vE '/_eval/|lock|\.sum$|\.gitignore$' \
  | while read -r f; do cat "$root/$f"; done | terms > "$work/cases"
skill_text "$baseline" | terms > "$work/baseline"
skill_text "$sha" | terms > "$work/skill"

comm -12 "$work/cases" "$work/skill" | comm -23 - "$work/baseline" > "$work/leaked"
if [[ -s "$work/leaked" ]]; then
  echo "terms from the cases that entered the skill after $baseline:"
  sed 's/^/  /' "$work/leaked"
  echo "review each: replace case-derived examples with generic ones, or allow a genuinely generic word in scripts/overfit-allow.txt"
  if [[ -f "$root/scripts/overfit-allow.txt" ]]; then
    comm -23 "$work/leaked" <(grep -v "^#" "$root/scripts/overfit-allow.txt" | sort -u) > "$work/unallowed"
    if [[ ! -s "$work/unallowed" ]]; then
      echo "all listed terms are allowed"
      exit 0
    fi
  fi
  exit 1
fi
echo "no case-specific terms entered the skill ($baseline -> $sha)"
