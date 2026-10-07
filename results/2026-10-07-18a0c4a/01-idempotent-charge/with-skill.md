The original tests did not protect the contract. I strengthened them. All 3 pass against the unmodified production code, and each of two deliberate breaks of that code now makes one of them fail.

**Gaps found**
1. **Single gateway charge per key:** `FakeGateway` returned an ID based only on the amount, and nothing counted gateway calls. A service that charged twice for the same key still passed.
2. **Different keys:** this contract line had no test at all.

**Proof (isolated copy in `/tmp/iso`, Docker `python:3.12-slim`, pytest 8.3.3)**

| Run | Result |
|---|---|
| Baseline, original tests, original code | 2 passed |
| Regression A (idempotency check disabled), original tests | 2 passed, so the double charge went undetected |
| Regression A, new tests | 1 failed: `assert [5000, 5000] == [5000]` |
| Regression B (cache keyed on a constant instead of the key), new tests | 1 failed: `assert [5000] == [5000, 7000]` |
| Production code restored, new tests | 3 passed |

**Fix (tests only)**
- `tests/test_charge.py` now has a `FakeGateway` that records its calls and returns a unique ID per call.
- The same-key test asserts exactly one gateway call and that the second result equals the first.
- A new test covers different keys: two gateway calls and two distinct charges.
- `app/payments.py` was already correct and is untouched. `git status` shows only `tests/test_charge.py` modified.

**Commands**
- Baseline and each regression run: `docker run --rm -v /tmp/iso:/work -w /work python:3.12-slim sh run.sh`. That script installs `requirements.txt` and runs `python -m pytest -q`.
- Host `pytest` isn't installed, so I used the README's Docker route.

**Limitations**
- This was a progressive audit with manual regressions on the single module. I didn't run an automated mutation tool or Necessist, so this is not a full-audit approval.
- I only checked each of the three contract lines with regression A or B. I didn't test other variants, such as the amount or status of the returned charge.
- I didn't commit the change.
