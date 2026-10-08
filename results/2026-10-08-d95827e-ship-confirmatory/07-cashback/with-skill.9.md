The original tests were not enough. I added two tests, and the suite now passes 19 of 19 in the original project.

**Baseline:** 17 passed, 0 failed, 0 skipped, run in Docker (`python:3.12-slim`).

**What I did:** I shifted each limit in `app/cashback.py` one unit down and one unit up in an isolated worktree, then ran the unmodified tests against each shift.

- **Missed by the old tests:**
  - **Minimum floor:** `raw < MIN_CASHBACK_CENTS - 1` passed all 17 tests. A purchase whose raw cashback is 24 cents (2,400 basic) would have returned 24 instead of the documented 25.
  - **Maximum cap:** `raw > MAX_CASHBACK_CENTS + 1` passed all 17 tests. A raw cashback of 3,001 (100,034 premium) would have returned 3,001 instead of the 3,000 cap.
- **Caught by the old tests:**
  - **500-cent threshold:** both shifts fail.
  - **Negative-amount check:** both shifts fail.
- **Equivalent shifts, no test needed:** `raw < 26` and `raw > 2999` give the same result for every valid input.

**What I added** to `tests/test_cashback.py`:
- `test_raw_cashback_just_below_minimum_is_raised_to_minimum` covers 2,400 basic, expecting 25.
- `test_raw_cashback_just_above_maximum_is_capped` covers 100,034 premium, expecting 3,000.

With the new tests, both missed shifts now fail (1 failed, 18 passed each). The other shifts behave as before, and the restored code passes 19 of 19.

**Not run:** I did not run application mutation testing or Necessist, only the boundary probes plus the final suite run. I found no pytest-specific lint or typecheck config in the repo.

VERDICT: inadequate
