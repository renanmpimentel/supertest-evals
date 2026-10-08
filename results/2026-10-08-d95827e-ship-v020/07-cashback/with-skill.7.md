The original tests were not enough: they missed two edge cases in the cashback clamp. I added three tests that cover them. All 20 tests pass in the original project (the 17 existing ones plus the 3 new ones), run in the `python:3.12-slim` Docker image from the README.

**How I checked**
- The baseline was 17 passed.
- I shifted each limit in `app/cashback.py` one unit down and one unit up in a temporary worktree: the negative-amount check, the 500 minimum purchase, the 25 minimum cashback and the 3,000 maximum cashback. Each shift ran against the unmodified tests.
- The tests caught the shifts on the negative-amount check, the 500 minimum purchase and the 25 constant.
- Two shifts survived with all 17 passing. Both change real results, so they are gaps in the tests:
  - `raw < MIN - 1`: a computed cashback of 24 would be returned as 24 instead of being raised to 25.
  - `raw > MAX + 1`: a computed cashback of 3,001 would be returned as 3,001 instead of being capped at 3,000.
- The other two shifts, `raw < MIN + 1` and `raw > MAX - 1`, give the same result for every valid input, so they are equivalent and need no test.

**What I added to `tests/test_cashback.py`**
- `cashback_cents(2_400, "basic") == 25` (a raw 24 is raised to the minimum).
- `cashback_cents(2_600, "basic") == 26` (a raw 26 is kept).
- `cashback_cents(100_017, "premium") == 3_000` (a raw 3,001 is capped).

With the two surviving shifts applied again, the new tests fail on each (1 failed, 19 passed). With the code restored, all 20 pass.

**Not done**
- I did not run Necessist or a full mutation tool. Only the boundary probes were run.
- I did not add tests for other mutations, such as changing the rounding offset or the tier rates. The existing tests already cover those.

VERDICT: inadequate
