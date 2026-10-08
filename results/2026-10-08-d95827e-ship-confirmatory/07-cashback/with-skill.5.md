The original tests were not enough, so I added two. Nothing in the module's code was wrong.

**Baseline:** 17 tests passed. I ran them in `python:3.12-slim` through Docker, because the host has no pytest.

**What the original tests covered:** the tier rates, half-up rounding, the 500-cent threshold (499 and 500), negative amounts, and the unknown-tier error and message. They also covered the cap at 3,000 cents and the 25-cent floor, but only at the exact limits.

**Boundary probes:** I shifted each limit one unit down and one unit up in an isolated worktree, against the original tests.

| Limit | Shift | Result |
| --- | --- | --- |
| Negative amount (`< 0`) | down and up | caught |
| 500-cent threshold | down and up | caught |
| 25-cent floor | up (`< 26`) | equivalent: a raw value of 25 still returns 25 |
| 25-cent floor | down (`< 24`) | **survived** |
| 3,000-cent cap | down (`> 2999`) | equivalent: a raw value of 3,000 still returns 3,000 |
| 3,000-cent cap | up (`> 3001`) | **survived** |

The two survivors change a valid result:
- With the floor shifted down, a purchase whose raw cashback is 24 would return 24 instead of 25.
- With the cap shifted up, a purchase whose raw cashback is 3,001 would return 3,001 instead of 3,000.

**Fix:** I added two tests to `tests/test_cashback.py`:
- `2_400, "basic"` gives 25 (raw 24, raised to the floor).
- `100_033, "premium"` gives 3,000 (raw 3,001, capped).

Under the same shifts, the first new test fails on the floor shift and the second fails on the cap shift. The suite passes on the original code: 19 passed.

**Not done:**
- No Necessist run and no broader mutation testing. This was a progressive audit, so it isn't a full-audit approval.
- I did not test a negative amount combined with an unknown tier, because the contract doesn't say which error wins. Both raise `CashbackError`.
- The probe worktree under `/tmp/tmp.BGcMeTiULS/w` is still there. Docker created root-owned files in it, so I couldn't remove it. Only `tests/test_cashback.py` is modified in the project.

VERDICT: inadequate
