#!/usr/bin/env bash
# Self-test for scripts/lib/verify.sh: one valid case and four that must be rejected.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

WEAK_OK='. ./app.sh; [ -n "$VALUE" ] && echo "1 passed"'
WEAK_CATCHES='. ./app.sh; if [ "$VALUE" = 1 ]; then echo "1 passed"; else echo "ASSERT: weak caught it"; exit 1; fi'
WEAK_EMPTY='echo "no tests ran"'
STRONG_OK='. ./app.sh; if [ "$VALUE" = 1 ]; then echo "1 passed"; else echo "ASSERT: expected VALUE=1, got $VALUE"; exit 1; fi'
STRONG_ERRORS='. ./app.sh; if [ "$VALUE" = 1 ]; then echo "1 passed"; else echo "ERROR: cannot load module"; exit 1; fi'
PATCH_OK=$'--- a/app.sh\n+++ b/app.sh\n@@ -1 +1 @@\n-VALUE=1\n+VALUE=2\n'
PATCH_DRIFT=$'--- a/app.sh\n+++ b/app.sh\n@@ -1 +1 @@\n-VALUE=9\n+VALUE=2\n'

make_case() {
  local name="$1" weak="$2" strong="$3" patch="$4"
  local dir="$work/$name"
  mkdir -p "$dir/tests" "$dir/_eval"
  printf 'VALUE=1\n' > "$dir/app.sh"
  printf '%s\n' "$weak" > "$dir/tests/weak.sh"
  printf '%s\n' "$strong" > "$dir/_eval/strong.sh"
  printf '%s' "$patch" > "$dir/_eval/regression.patch"
  cat > "$dir/_eval/verify.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
source "$root/scripts/lib/verify.sh"
IMAGE="alpine:3.20"
SETUP="true"
WEAK_CMD="sh tests/weak.sh"
STRONG_CMD="sh tests/strong.sh"
STRONG_SRC="strong.sh"
STRONG_DEST="tests/strong.sh"
PASS_RE='[0-9]+ passed'
ASSERT_RE='^ASSERT:'
ERROR_RE='^ERROR:'
DOCKER_ARGS=()
verify_case "$dir"
EOF
}

expect_verify() {
  local name="$1" want="$2" pattern="$3"
  local out status=0
  out="$(bash "$work/$name/_eval/verify.sh" 2>&1)" || status=$?
  if [[ "$want" == pass && $status -ne 0 ]] || [[ "$want" == fail && $status -eq 0 ]]; then
    echo "SELFTEST FAIL $name: want $want, got exit $status"
    echo "$out"
    exit 1
  fi
  if ! grep -Eq "$pattern" <<<"$out"; then
    echo "SELFTEST FAIL $name: output missing /$pattern/"
    echo "$out"
    exit 1
  fi
  echo "ok   $name"
}

make_case good "$WEAK_OK" "$STRONG_OK" "$PATCH_OK"
make_case weak-catches "$WEAK_CATCHES" "$STRONG_OK" "$PATCH_OK"
make_case error-not-assertion "$WEAK_OK" "$STRONG_ERRORS" "$PATCH_OK"
make_case empty-collection "$WEAK_EMPTY" "$STRONG_OK" "$PATCH_OK"
make_case patch-drift "$WEAK_OK" "$STRONG_OK" "$PATCH_DRIFT"

expect_verify good pass 'PASS gap proven'
expect_verify weak-catches fail 'regressed/weak: expected pass'
expect_verify error-not-assertion fail 'collection/build error'
expect_verify empty-collection fail 'no passing test collected'
expect_verify patch-drift fail 'regression.patch does not apply'

if [[ -e "$work/good/tests/strong.sh" ]]; then
  echo "SELFTEST FAIL good: verify wrote into the case directory"
  exit 1
fi
echo "ok   case directory untouched"
echo "selftest passed"
