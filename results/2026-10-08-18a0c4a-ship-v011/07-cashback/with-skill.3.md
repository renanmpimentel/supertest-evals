The original tests were not enough to ship on. I added tests for the gap, and the suite now passes (27 tests, up from 17).

**What I ran.** I ran the tests in Docker as the README describes, and the baseline was 17 passed. Then I ran about 20 hand-made mutations of `app/cashback.py` against the suite, in a copy. I did not run Necessist.

**What the original tests already caught.** They caught changes to the tier rates, the rounding, the 500 purchase threshold, the 25 and 3,000 limits, and the unknown-tier message.

**The gap.** The contract says a negative amount raises `CashbackError` "whatever the amount". The only negative-amount test was `-1` with `basic`, so two broken versions of the code still passed:
- Rejecting negatives only for `basic`. Negative amounts on `plus` or `premium` would have returned 0 instead of raising.
- Rejecting only negatives smaller than −1000. Small negative amounts would have returned 0.

**The fix.** In `tests/test_cashback.py`, I replaced the single negative-amount test with one covering −1, −499 and −10,000 across all three tiers. I also added a test for negative amounts with an unknown tier. With those, the "`basic` only" mutation fails 6 tests, the small-negative mutation is caught, and the unmodified code passes all 27.

**Survivors I judged harmless:**
- `raw <= MIN` and `raw >= MAX` are equivalent mutations, because the result is the same at exactly those values.
- Rejecting negatives only for known tiers still raises `CashbackError` for an unknown tier. The contract doesn't specify the message in that case, so I left it.

The changes are in the working tree and not committed.

VERDICT: inadequate
