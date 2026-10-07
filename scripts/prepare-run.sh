#!/usr/bin/env bash
# Copies a case as the agent sees it (no _eval answer key) into a fresh git repo.
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
mkdir -p "$dest"
tar -C "$case_dir" --exclude=./_eval --exclude=./node_modules -cf - . | tar -C "$dest" -xf -
git -C "$dest" init -q -b main
git -C "$dest" add -A
git -C "$dest" -c user.name=supertest-evals -c user.email=evals@localhost commit -q -m baseline
echo "prepared $dest"
echo "prompt: $case_dir/_eval/prompt.md"
