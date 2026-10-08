The tests already protect the documented behavior, so I changed nothing.

**Baseline:** the suite ran in Docker (python:3.12 with pytest 8.3.3) and gave 17 passed, 0 failed and 0 skipped. I ran everything on a copy; the project tree is still clean.

**Detection check:** I applied 19 temporary regressions to the copy and ran the suite on each. 15 were caught, and the other 4 are equivalent mutants, so they don't violate the contract:
- **Caught:**
  - the 0 and 500 cent boundaries;
  - the rounding offset (`+4999` and `+0`);
  - the 25 and 3,000 cent limits, including dropping either clamp;
  - each tier's rate;
  - the unknown-tier check when the amount is under 500;
  - the unknown-tier error message.
- **Equivalent:**
  - `raw <= 25` and `raw >= 3000` return the same values at those exact points.
  - `+5001` can't change results, because `amount × rate` is always a multiple of 100.
  - Skipping the negative-amount check when the tier is unknown still raises `CashbackError`. The contract only requires an error, not which one.

**Not covered:** I did not run Necessist, only the manual mutations above. Rounding and clamping are only tested for some tiers, but the code is shared across tiers, so I don't see that as a real gap.

VERDICT: adequate
