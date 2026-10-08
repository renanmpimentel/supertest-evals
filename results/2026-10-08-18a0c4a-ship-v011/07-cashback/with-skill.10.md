The existing tests are adequate. They protect the documented behavior, and I didn't change any tests.

**Method.** I ran the suite in Docker (python:3.12-slim, the README command): 17 passed, 0 failed, 0 skipped. In an isolated copy I then applied 17 temporary regressions to `app/cashback.py`. They covered:
- the tier rates and the rounding offset;
- the 500 purchase threshold;
- the 25 minimum and 3,000 maximum;
- the negative-amount check;
- the unknown-tier check and its message.

**Result.** 15 of the 17 were caught by an assertion failure, not an error. The other two survived, and both are equivalent mutants:
- **`+ 5_001` instead of `+ 5_000`:** all rates are multiples of 100 bps, so `amount × rate` is always a multiple of 100. The remainder can never be 4999 or 5001, so the output never changes.
- **Negative-amount check skipped when the tier is unknown:** a negative amount with an unknown tier still raises `CashbackError` from the tier check. The contract says nothing about which message applies in that case.

**Not done.** I did not run Necessist or an automated mutation tool. The 17 regressions were hand-picked, so this is a targeted check rather than a full audit.

**A mistake of mine.** My first mutation attempt accidentally edited the real `app/cashback.py` because the scratch copy failed to create. I restored it with `git checkout`, and `git status` is clean. The rerun used a separate copy.

VERDICT: adequate
