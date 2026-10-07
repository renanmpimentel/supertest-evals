#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../../../scripts/lib/verify.sh"

IMAGE="node:24-slim"
SETUP="npm ci --no-audit --no-fund --loglevel=error"
WEAK_CMD="npx vitest run tests/breaker.test.ts"
STRONG_CMD="npx vitest run tests/breaker.strong.test.ts"
SUITE_CMD="npx vitest run"
SUITE_FAIL_RE='Tests +[0-9]+ failed'
STRONG_SRC="breaker.strong.test.ts"
STRONG_DEST="tests/breaker.strong.test.ts"
PASS_RE='Tests +[0-9]+ passed'
ASSERT_RE='^ FAIL +tests/breaker\.strong\.test\.ts > .*does not call the gateway while the circuit is open'
ERROR_RE='(Failed to load|Failed to resolve|SyntaxError|Transform failed|No test files found)'
DOCKER_ARGS=(-v supertest-evals-npm:/root/.npm)

verify_case "$here/.."
