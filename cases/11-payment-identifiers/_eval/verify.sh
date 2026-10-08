#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../../../scripts/lib/verify.sh"

IMAGE="node:24-slim"
SETUP="npm ci --no-audit --no-fund --loglevel=error"
WEAK_CMD="npx vitest run tests/validators.test.ts"
STRONG_CMD="npx vitest run tests/validators.strong.test.ts"
SUITE_CMD="npx vitest run"
SUITE_FAIL_RE='Tests +[0-9]+ failed'
STRONG_SRC="validators.strong.test.ts"
STRONG_DEST="tests/validators.strong.test.ts"
PASS_RE='Tests +[0-9]+ passed'
ASSERT_RE='^ FAIL +tests/validators\.strong\.test\.ts > .*rejects a URL with a user name or a password embedded'
ERROR_RE='(Failed to load|Failed to resolve|SyntaxError|Transform failed|No test files found)'
DOCKER_ARGS=(-v supertest-evals-npm:/root/.npm)

verify_case "$here/.."
