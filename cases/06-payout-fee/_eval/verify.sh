#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../../../scripts/lib/verify.sh"

IMAGE="golang:1.27"
SETUP="true"
TEST_CMD="go test -count=1 -v ./..."
SUITE_CMD="go test -count=1 -v ./..."
SUITE_FAIL_RE='^--- FAIL: '
PASS_RE='^--- PASS: '
ASSERT_RE='^--- FAIL: TestFee'
ERROR_RE='(\[build failed\]|\[setup failed\]|^panic:)'
DOCKER_ARGS=(-v supertest-evals-gomod:/go/pkg/mod -v supertest-evals-gobuild:/root/.cache/go-build)

verify_control_case "$here/.."
