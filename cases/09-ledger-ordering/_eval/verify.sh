#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../../../scripts/lib/verify.sh"

IMAGE="python:3.12-slim"
SETUP="pip install --quiet --root-user-action=ignore -r requirements.txt"
WEAK_CMD="python -m pytest -q -p no:cacheprovider tests/test_ledger.py"
STRONG_CMD="python -m pytest -q -p no:cacheprovider tests/test_ledger_strong.py"
SUITE_CMD="python -m pytest -q -p no:cacheprovider"
SUITE_FAIL_RE='[0-9]+ failed'
STRONG_SRC="test_ledger_strong.py"
STRONG_DEST="tests/test_ledger_strong.py"
PASS_RE='[0-9]+ passed'
ASSERT_RE='^FAILED tests/test_ledger_strong\.py::test_entries_are_in_timestamp_order_right_after_add'
ERROR_RE='(ERROR collecting|ImportError|ModuleNotFoundError|SyntaxError)'
DOCKER_ARGS=(-v supertest-evals-pip:/root/.cache/pip)

verify_case "$here/.."
