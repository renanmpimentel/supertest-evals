The original tests were not adequate. I added three tests to `tests/test_cashback.py`, and the suite now catches both gaps.

**Baseline:** the suite ran in Docker, as the README describes. 17 passed, 0 failed, 0 skipped.

**What the tests already covered:** I shifted each limit in `app/cashback.py` one unit down and one unit up, running the unmodified tests each time. These shifts were caught:
- The 500-cent purchase threshold, both ways.
- The negative-amount check, both ways.

**Two shifts survived with the original tests (all 17 still passed):**
- **Minimum of 25 cents, shifted down to 24:** a raw cashback of 24 would be paid as 24 instead of being raised to 25. No test used a raw value just under the minimum.
- **Maximum of 3,000 cents, shifted up to 3,001:** a raw cashback of 3,001 would be paid uncapped. No test used a raw value just over the maximum.

**Equivalent shifts (no valid input behaves differently, so no test needed):** minimum shifted up to 26, and maximum shifted down to 2,999.

**Tests added:**
- `2_400 basic` returns 25, because the raw value is 24 and gets raised to the minimum.
- `2_600 basic` returns 26, because the raw value is above the minimum and is kept.
- `100_034 premium` returns 3,000, because the raw value is 3,001 and gets capped.

**Verification:** with the new tests, each of the two surviving shifts now fails one test (1 failed, 19 passed). With the original code restored, all 20 pass.

**Limits of this audit:**
- I did not run Necessist or full mutation testing. I only ran the limit-shift checks, and I did not audit the rate or rounding logic beyond reading it.
- The temporary worktree at `/tmp/wt_probe` couldn't be deleted (permission denied). It's already unregistered from git, so only the leftover directory remains.
- The test changes are uncommitted in the working tree.

VERDICT: inadequate
