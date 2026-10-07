#!/usr/bin/env bash
# Copies a case as the agent sees it (git-tracked files only, no _eval answer key)
# into a fresh git repo.
set -euo pipefail
if [[ $# -ne 2 ]]; then
  echo "usage: $0 <case-dir> <dest-dir>" >&2
  exit 2
fi
case_dir="$(cd "$1" && pwd)"
dest="$2"
if [[ -e "$dest" ]]; then
  echo "destination already exists: $dest" >&2
  exit 1
fi
if [[ -z "$(git -C "$case_dir" ls-files -- . ':(exclude)_eval' | head -n 1)" ]]; then
  echo "no tracked files found in $case_dir" >&2
  exit 1
fi
mkdir -p "$dest"
git -C "$case_dir" ls-files -z -- . ':(exclude)_eval' | tar -C "$case_dir" --null -T - -cf - | tar -C "$dest" -xf -
git -C "$dest" init -q -b main
git -C "$dest" add -A
git -C "$dest" -c user.name=supertest-evals -c user.email=evals@localhost commit -q -m baseline
git -C "$dest" tag baseline
echo "prepared $dest"
echo "prompts: $(cd "$(dirname "$0")/.." && pwd)/prompts/{audit,ship}.md"
