#!/usr/bin/env bash
# Proves a case's test gap in Docker:
#   1. original code: weak test passes
#   2. original code: strong test passes
#   3. regression applied: weak test still passes (the gap)
#   4. regression applied: strong test fails by assertion
# The case's _eval/verify.sh sets IMAGE, SETUP, WEAK_CMD, STRONG_CMD,
# STRONG_SRC, STRONG_DEST, PASS_RE, ASSERT_RE, ERROR_RE and DOCKER_ARGS,
# then calls: verify_case <case dir>

WORK=""

fail() {
  echo "FAIL $1" >&2
  if [[ -n "${2:-}" && -f "$2" ]]; then
    echo "--- last lines of $2" >&2
    tail -n 40 "$2" >&2
  fi
  exit 1
}

make_workspace() {
  local case_dir="$1" dest="$2" with_regression="$3"
  mkdir -p "$dest"
  tar -C "$case_dir" --exclude=./_eval --exclude=./node_modules -cf - . | tar -C "$dest" -xf -
  cp "$case_dir/_eval/$STRONG_SRC" "$dest/$STRONG_DEST"
  if [[ "$with_regression" == yes ]]; then
    if ! (cd "$dest" && git apply "$case_dir/_eval/regression.patch") 2>"$WORK/patch.log"; then
      fail "regression.patch does not apply to $(basename "$case_dir")" "$WORK/patch.log"
    fi
  fi
}

run_tests() {
  local workspace="$1" cmd="$2" log="$3"
  local status=0
  docker run --rm -v "$workspace:/work" -w /work \
    -e NO_COLOR=1 -e FORCE_COLOR=0 -e CI=1 \
    "${DOCKER_ARGS[@]}" "$IMAGE" \
    sh -c "$SETUP && $cmd; rc=\$?; chown -R $(id -u):$(id -g) /work; exit \$rc" \
    >"$log" 2>&1 || status=$?
  return "$status"
}

expect_pass() {
  local label="$1" workspace="$2" cmd="$3"
  local log="$WORK/logs/${label//\//-}.log"
  if ! run_tests "$workspace" "$cmd" "$log"; then
    fail "$label: expected pass, got non-zero exit" "$log"
  fi
  if ! grep -Eq "$PASS_RE" "$log"; then
    fail "$label: exit 0 but no passing test collected" "$log"
  fi
  echo "ok   $label"
}

expect_assertion_failure() {
  local label="$1" workspace="$2" cmd="$3"
  local log="$WORK/logs/${label//\//-}.log"
  if run_tests "$workspace" "$cmd" "$log"; then
    fail "$label: expected failure, but tests passed" "$log"
  fi
  if grep -Eq "$ERROR_RE" "$log"; then
    fail "$label: failed with a collection/build error, not an assertion" "$log"
  fi
  if ! grep -Eq "$ASSERT_RE" "$log"; then
    fail "$label: failure output has no assertion marker" "$log"
  fi
  echo "ok   $label"
}

verify_case() {
  local case_dir
  case_dir="$(cd "$1" && pwd)"
  WORK="$(mktemp -d)"
  trap 'rm -rf "$WORK"' EXIT
  mkdir -p "$WORK/logs"
  echo "case $(basename "$case_dir")"
  make_workspace "$case_dir" "$WORK/original" no
  make_workspace "$case_dir" "$WORK/regressed" yes
  expect_pass "original/weak" "$WORK/original" "$WEAK_CMD"
  expect_pass "original/strong" "$WORK/original" "$STRONG_CMD"
  expect_pass "regressed/weak" "$WORK/regressed" "$WEAK_CMD"
  expect_assertion_failure "regressed/strong" "$WORK/regressed" "$STRONG_CMD"
  echo "PASS gap proven: weak test misses the regression, strong test catches it"
}
