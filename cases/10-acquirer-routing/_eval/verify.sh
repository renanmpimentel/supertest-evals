#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../../../scripts/lib/verify.sh"

IMAGE="golang:1.27"
SETUP="true"
WEAK_CMD="go test -count=1 -v -skip '^TestEightDigitEntryOverridesSixDigitEntry\$' ./..."
STRONG_CMD="go test -count=1 -v -run '^TestEightDigitEntryOverridesSixDigitEntry\$' ./..."
SUITE_CMD="go test -count=1 -v ./..."
SUITE_FAIL_RE='^--- FAIL: '
STRONG_SRC="routing_strong_test.go"
STRONG_DEST="routing_strong_test.go"
PASS_RE='^--- PASS: '
ASSERT_RE='8-digit entry ignored: acquirer = delta, want golf'
ERROR_RE='(\[build failed\]|\[setup failed\]|^panic:)'
DOCKER_ARGS=(-v supertest-evals-gomod:/go/pkg/mod -v supertest-evals-gobuild:/root/.cache/go-build)

verify_case "$here/.."
