#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../../../scripts/lib/verify.sh"

IMAGE="golang:1.27"
SETUP="true"
WEAK_CMD="go test -count=1 -v -run '^TestCreatePayment(ReturnsCreated|RejectsInvalidAmount)\$' ./..."
STRONG_CMD="go test -count=1 -v -run '^TestCreatePaymentIsPersisted\$' ./..."
SUITE_CMD="go test -count=1 -v ./..."
SUITE_FAIL_RE='^--- FAIL: '
STRONG_SRC="payments_strong_test.go"
STRONG_DEST="payments_strong_test.go"
PASS_RE='^--- PASS: '
ASSERT_RE='payment pay_[0-9a-f]+ was not persisted'
ERROR_RE='(\[build failed\]|\[setup failed\]|^panic:)'
DOCKER_ARGS=(-v supertest-evals-gomod:/go/pkg/mod -v supertest-evals-gobuild:/root/.cache/go-build)

verify_case "$here/.."
