The tests are adequate. I changed nothing in the project.

- **Baseline:** I ran the README's Docker command. 16 tests were collected and 16 passed.
- **Mutations:** I applied 18 temporary single-line changes to a copy of `app/cashback.py` and ran the suite on each. The suite caught 15.
  - Caught: the `< 0` check, the 500 threshold (both the `<=` and `< 501` versions), the rounding offset when lowered to 4,999 or 0, all three rates, both the 25 and 3,000 clamp values, the `return 0` value, the unknown-tier check being skipped for small amounts, and the tier name missing from the error message.
  - Not caught, and equivalent: raising the rounding offset to 5,001 can't change any result, because every amount times a rate is a multiple of 100. Changing the clamp comparisons `raw < MIN` and `raw > MAX` to `<=` and `>=` returns the same value at the boundary, so no test could tell them apart.
  - One 500-threshold attempt first failed with a syntax error, so I reran it as `< 501`, which a test caught.
- **Documented behaviors covered:**
  - All three tier rates.
  - Round half up, tested on both sides of the half.
  - The 499/500 threshold.
  - The minimum of 25 and maximum of 3,000, tested on both sides of each limit.
  - Negative amounts raise `CashbackError`.
  - Unknown tiers raise it, with the tier name in the message and for small amounts too.
- **Not run:** I didn't run Necessist, the Necessist-style statement-removal check, because I judged the 18 targeted mutations enough for a single pure function.

VERDICT: adequate
