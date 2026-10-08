Yes, the tests protect the documented behavior, so I changed nothing.

**Baseline:** 17 tests collected and passed (pytest 8.3.3, Python 3.12 in Docker, as the README specifies).

**Contract coverage:**
- **Tier rates:** all three tiers are checked.
- **Purchase threshold:** 0, 499 and 500 are covered.
- **Rounding:** 4,050 rounds up to 41 and 4,049 rounds down to 40.
- **Minimum and maximum cashback:** raw values of 20 and 25 are covered at the minimum. At the maximum, 2,999, 3,000 and a well-over case are covered.
- **Negative amounts:** −1 is rejected.
- **Unknown tier:** it is rejected at amounts 0, 100 and 10,000, and the message is checked to name the tier.

**Mutation check:** I made 15 temporary changes to a copy of the module and ran the full suite on each. The tests failed on 13 of them. Those covered the negative-amount and 500-cent boundaries, the rounding offset, all three rates, the clamp return values, the tier check and the error message.

The two that passed were the clamp comparisons, `raw < 25` changed to `<=` and `raw > 3000` changed to `>=`. When `raw` equals the bound, both versions return the same value, so no valid input can tell them apart. No test can catch them.

I did not run Necessist. Each test is a single call plus an assertion, so there are no setup statements to remove. The copy in `/tmp/iso` has the original module restored. The repo is untouched.

VERDICT: adequate
