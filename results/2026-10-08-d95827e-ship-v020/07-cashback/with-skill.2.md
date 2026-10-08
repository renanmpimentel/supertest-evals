The original tests weren't enough, so I added two. The suite now has 19 tests, all passing in the project's Docker command.

**What I did.** I ran the baseline: 17 passed. Then I ran the boundary probes in an isolated worktree. Each probe shifted one limit in `app/cashback.py` up or down by one and re-ran the original tests.

| Limit | Shift | Result |
| --- | --- | --- |
| 500-cent purchase minimum | down, up | caught by both |
| negative-amount check | down, up | caught by both |
| 25-cent cashback floor | up (equivalent) | survived, but gives identical results for every valid input |
| 25-cent cashback floor | down (`raw < 24`) | **survived**: a raw cashback of 24 (for example 2,400 cents at `basic`) returns 24 instead of 25 |
| 3,000-cent cashback cap | down (equivalent) | survived, but gives identical results for every valid input |
| 3,000-cent cashback cap | up (`raw > 3001`) | **survived**: a raw cashback of 3,001 (100,034 cents at `premium`) returns 3,001 instead of 3,000 |

The existing tests only checked the floor and cap exactly at their limits or far from them, never one unit away.

**What I changed.** I added two tests to `tests/test_cashback.py`:
- `cashback_cents(2_400, "basic") == 25`
- `cashback_cents(100_034, "premium") == 3_000`

Each new test fails under its regression, and everything passes once the code is restored.

**Not done.** I did not run full-suite mutation testing or Necessist. The audit covered only the boundary probes plus a read of the tests against `CONTRACT.md`.

**Cleanup.** The temporary worktree at `/tmp/wt_cb` couldn't be removed (permission denied). It is outside the project, and `git status` shows only the test file changed.

VERDICT: inadequate
