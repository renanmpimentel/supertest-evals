The original tests were not enough. Two boundary gaps let wrong behavior through, so I added two tests.

**Baseline:** 16 tests passed under Docker with `python:3.12-slim` and pytest 8.3.3. I ran 20 hand-written changes to the module in a scratch copy, each one breaking the code on purpose.

**Gaps found:** two changes slipped past the original suite.
- **Minimum clamp:** with the check changed to `raw < MIN - 1`, a raw cashback of 24 cents came back as 24 instead of 25. The existing tests never produced a raw value of exactly 24.
- **Maximum clamp:** with the check changed to `raw > MAX + 1`, a raw 3,001 came back uncapped. The existing tests never went past 3,000.

**Fix:** I added two tests in `tests/test_cashback.py`:
- `cashback_cents(2_400, "basic") == 25`
- `cashback_cents(100_034, "premium") == 3_000`

Both changes now fail the suite, and the real code passes all 18 tests.

**Remaining survivors:** four changes still pass, and none of them changes behavior for any valid input:
- `+ 5_001` in the rounding: rates are multiples of 100, so a remainder of 4,999 can't occur.
- `raw <= MIN` and `raw >= MAX`: both return the same value at the boundary.
- A negative amount with an unknown tier: it raises either way.

**Not run:** I didn't run Necessist. In the last run, two changes showed "no tests ran" because of a flaky scratch directory. Both were caught in the earlier run, and the added tests don't affect them.

VERDICT: inadequate
