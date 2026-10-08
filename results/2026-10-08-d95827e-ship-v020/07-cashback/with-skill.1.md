The original tests didn't give enough confidence. They missed two boundary bugs, so I added three tests that catch them.

**Baseline.** All 17 original tests passed. I ran them in Docker, because the host has no pytest.

**Boundary probes.** I shifted each of the five limits in `app/cashback.py` (0, 500, 25, 3,000, and the rounding offset) one unit down and one unit up, against the unmodified tests:
- **Floor of 25, shifted down** (`raw < 24`): this survived. A raw cashback of 24 would be paid as 24 instead of 25, and no test covered it.
- **Cap of 3,000, shifted up** (`raw > 3001`): this survived. A raw cashback of 3,001 would be paid in full instead of being capped at 3,000.
- **Equivalent shifts** (no valid result changes):
  - Floor shifted up to `raw < 26`.
  - Cap shifted down to `raw > 2999`.
  - Rounding offset `+5001`. Every product `amount × rate` is a multiple of 100, so the extra 1 never changes the rounded result.
- **Caught by the original tests:** both shifts of the 0 and 500 limits, and the `4999` rounding offset.

**Tests added** (`tests/test_cashback.py`):
- 2,400 cents on `basic` gives 25.
- 2,600 cents on `basic` gives 26.
- 100,034 cents on `premium` gives 3,000.

With these in place the two surviving shifts now fail the suite. The equivalent ones still pass, as expected.

**Final run.** 20 passed on the real project.

**Not done:**
- I ran only the boundary probes, with no Necessist or full mutation run.
- The rounding rule is tested only on the `basic` tier.
- The unknown-tier message is checked only for `gold`.

VERDICT: inadequate
