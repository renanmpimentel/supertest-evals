The original tests did not give enough confidence. The new tests found a real bug, which I fixed.

**The bug:** the contract says an unknown tier raises `CashbackError` "whatever the amount", with a message that names the tier. The code checked the amount first. `cashback_cents(-1, "gold")` therefore raised "amount must not be negative" and never named the tier. The original tests only tried unknown tiers with amounts of 0 or more. I moved the tier check ahead of the amount check in `app/cashback.py`. Both cases still raise `CashbackError`.

**Other gaps I filled in `tests/test_cashback.py`:**
- Negative amounts were tested only for `basic`. They are now tested for every tier.
- Half-up rounding was tested only for `basic`. It is now tested for `plus` and `premium`.
- The 25-cent minimum and 3,000-cent cap were tested almost only for `premium`. I added cases for the other tiers, a rounding-then-cap case at 100,017 / `premium`, and a case where the unrounded value is 24.99.
- Tier names must match exactly, so `Basic`, an empty string and `None` are now rejected.

All 43 tests pass: the 41 that already passed plus the 2 new unknown-tier-with-negative-amount tests that failed before the fix. I haven't committed anything.

VERDICT: inadequate
