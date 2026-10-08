The original tests were not enough to ship on. I added tests for the gap, and the suite now passes (33 tests, run in Docker on Python 3.12). Production code is unchanged.

I checked the tests by making temporary changes to a copy of `app/cashback.py` and seeing whether the suite failed. The original suite had 17 tests, all passing. It caught the mutants for tier rates, rounding, the 500-cent threshold, the 25 and 3,000 clamps, and the unknown-tier message and check.

**The gap:** the contract says a negative amount raises `CashbackError` "whatever the amount" (and, for the unknown-tier rule, "whatever the amount"). The only negative-amount test used `-1` with `basic`. Two mutants survived:
- Rejecting negatives only for `basic`.
- Rejecting only small negatives (above `-1000`).

Both would have shipped with the old suite.

**The fix:** in `tests/test_cashback.py`, the negative-amount test now runs over all three tiers and amounts from `-1` to `-1,000,000`. A new test covers a negative amount with an unknown tier. With the new tests, all three of those mutants fail the suite, and the restored code passes.

Two other mutants survived, and both are equivalent. `raw <= MIN` and `raw >= MAX` give the same result as the original, because the clamp returns the same value at the boundary. I didn't add tests for them. A third mutant (`MAX+1`) only errored on a typo of mine, so it proves nothing. I did not run Necessist.

While running mutants I briefly edited the real `app/cashback.py` by mistake. I restored it with `git checkout`, and `git status` now shows only the test file modified.

VERDICT: inadequate
