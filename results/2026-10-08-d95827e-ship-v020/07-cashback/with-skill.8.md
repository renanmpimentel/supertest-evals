The existing tests were not enough. I added two tests that close the gaps, and the suite now passes (19 tests).

The original 17 tests passed, but they missed two defects at the edges of the 25-cent minimum and the 3,000-cent cap. I checked this by shifting each limit in `app/cashback.py` one unit up and one unit down, then running the unchanged tests.

| Shift | Result with the original tests |
| --- | --- |
| 500-cent minimum purchase, down or up | caught |
| Negative-amount check, down or up | caught |
| Minimum cashback lowered to 24 | **survived** |
| Minimum cashback raised to 26 | no valid input changes, so equivalent |
| Cap lowered to 2,999 | no valid input changes, so equivalent |
| Cap raised to 3,001 | **survived** |

- **Minimum:** no test used a raw cashback of 24, so lowering the minimum would have let 24 cents through instead of 25.
- **Cap:** no test went just past the cap. Raising it would have let 3,001 cents through instead of 3,000.

I added `test_cashback_just_below_minimum_is_raised` (2,400 cents on `basic` gives 25) and `test_cashback_just_above_maximum_is_capped` (100,033 cents on `premium` gives 3,000). With the same two temporary regressions, each now fails. After restoring the code, all 19 tests pass in Docker, both in the isolated copy and in the original project.

I did not run Necessist or full application mutation testing. This was the standard review plus the limit-shift probes. The production code is unchanged, and the new tests are in `tests/test_cashback.py` but not committed.

The temporary git worktree at `/tmp/tmp.0QcXj2Feek/w` couldn't be removed because Docker created files in it as root. It is safe to delete by hand.

VERDICT: inadequate
