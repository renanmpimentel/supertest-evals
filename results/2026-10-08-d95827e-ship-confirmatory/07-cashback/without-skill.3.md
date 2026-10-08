The original tests didn't cover enough of the documented behavior to ship on, so I added tests. The module already matches `CONTRACT.md`: all 47 tests pass, the 12 original ones and 35 new cases, with no changes to `app/cashback.py`.

The original tests did check the 500-cent threshold, the 25 and 3,000 clamps, the `premium` cap and the unknown-tier message. They left these gaps:
- **Rounding:** half-up rounding was only tested for `basic`. I added `plus` and `premium` cases, including the exact half-way points.
- **Cap:** the 3,000 cap was only tested for `premium`. I added `basic` and `plus` cases on both sides of the cap.
- **Negative amounts:** these were only tested as -1 with `basic`. I added several negative values across all three tiers. I also added a negative amount with an unknown tier, since the contract says it raises whatever the amount.
- **Tier names:** I added a check that tier names must match exactly, so `Basic`, `PREMIUM` and the empty string are rejected.
- **Exception type:** `CashbackError` is checked to be a `ValueError`. This is my addition, since the contract doesn't state it.

One of my new cases failed at first because I had worked out the expected value wrong: 149,975 at 2% is 2,999.5, which rounds up to 3,000. I corrected the test. The module was right.

VERDICT: inadequate
