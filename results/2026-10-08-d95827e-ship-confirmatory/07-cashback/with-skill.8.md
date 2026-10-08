The original tests were not enough to ship on. They passed, but two boundary regressions went undetected. I added tests for them, and the suite now catches both.

**Baseline.** The original suite had 17 tests, all passing. I ran everything in the `python:3.12-slim` container from the README, because the host has no pytest.

**Gaps found.** I shifted each limit comparison in `app/cashback.py` one unit down and one unit up, running the original tests each time:
- **Minimum cashback (`raw < 25` → `raw < 24`):** all 17 original tests still passed. A raw cashback of 24 would be returned as 24 instead of being raised to 25, which breaks the documented "kept between 25 and 3,000". The tests only checked raw values 5, 20 and 25.
- **Maximum cashback (`raw > 3000` → `raw > 3001`):** all 17 original tests still passed. A raw cashback of 3,001 would be returned uncapped. The tests only checked 3,000 exactly and values far above it.

**Tests added.** Both are in `tests/test_cashback.py`:
- `test_minimum_applies_only_below_25` covers raw values 23, 24, 25, 26 and 27 on the basic tier. It includes the half-up rounding edges at 2,450 and 2,650.
- `test_cashback_just_above_maximum_is_capped` uses 100,017 on premium, which gives a raw 3,001 and must return 3,000.

**Verification.** With the new tests, both shifts fail, and the restored code passes 24 of 24. The other limit shifts, on the 500-cent purchase threshold and the negative-amount check, were caught by the original tests as well.

**Equivalent shifts.** Two shifts change no valid result, so I left them alone: `raw < 26` and `raw > 2999`. In both cases the boundary value is returned unchanged either way.

**Not run.** I did not run Necessist or a full mutation tool. The audit covered only the boundary probes, 8 regressions in total, within the 30-regression budget.

VERDICT: inadequate
