The existing tests are enough to ship this module on. They protect the documented behavior in `CONTRACT.md`, so I changed nothing.

- **Baseline:** 17 tests collected and passed, run in the `python:3.12-slim` container from the README. The host has no pytest, so I used Docker.
- **Coverage:** the tests cover the tier rates, half-up rounding and the 500-cent eligibility boundary (499 gives 0, 500 gives 25). They also cover the 25 and 3,000 clamps with values on and next to each bound, the negative-amount error, and the unknown-tier error with its message. The unknown-tier error is checked at amounts 0, 100 and 10,000, and the negative-amount error is checked with a valid tier.
- **Regression probes:** I made 20 temporary single-line changes to `app/cashback.py` in an isolated copy of the module and reran the tests on each. The tests failed on 18 of them. The changes included flipped comparison operators, shifted constants, altered rates, a missing tier check and a broken error message.
- **The two survivors are equivalent changes, not gaps.** Changing `raw < 25` to `raw <= 25`, or `raw > 3000` to `raw >= 3000`, gives the same output for every input. At the boundary the clamp returns the same value the unclamped result already has.
- **Not run:** I did not run Necessist or an automated mutation tool. The probes were hand-written, so a defect outside those 20 cases could still exist.

The working tree is still clean.

VERDICT: adequate
