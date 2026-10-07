#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
source "$here/../../../scripts/lib/verify.sh"

IMAGE="python:3.12-slim"
SETUP="pip install --quiet --root-user-action=ignore -r requirements.txt"
WEAK_CMD="python -m pytest -q -p no:cacheprovider tests/test_charge.py"
STRONG_CMD="python -m pytest -q -p no:cacheprovider tests/test_charge_strong.py"
STRONG_SRC="test_charge_strong.py"
STRONG_DEST="tests/test_charge_strong.py"
PASS_RE='[0-9]+ passed'
ASSERT_RE='^E +(assert |AssertionError)'
ERROR_RE='(ERROR collecting|ImportError|ModuleNotFoundError|SyntaxError)'
DOCKER_ARGS=(-v supertest-evals-pip:/root/.cache/pip)

verify_case "$here/.."
