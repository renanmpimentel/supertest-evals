The tests were not adequate, so I added three tests. They passed before I touched the code, but they would have missed two off-by-one changes to the 25 and 3,000 cashback limits.

I ran the suite in Docker with `python:3.12-slim`, as the README describes. The baseline was 17 passed. I then ran a temporary change in a throwaway copy of the repo for each limit, shifted one unit down and one unit up:

| Limit | Shift | Result |
| --- | --- | --- |
| Negative amount (`< 0`) | down, up | caught |
| 500-cent minimum purchase | down, up | caught |
| 25-cent minimum cashback | up | no valid input changes (equivalent) |
| 25-cent minimum cashback | down | **survived** |
| 3,000-cent maximum cashback | down | no valid input changes (equivalent) |
| 3,000-cent maximum cashback | up | **survived** |

The suite only tried cashback amounts exactly at the minimum (25) or far from the cap. It never tried one cent below 25 or one cent above 3,000.

I added these to `tests/test_cashback.py`:
- **2,400 basic:** the raw 24 is raised to 25.
- **2,600 basic:** 26 is kept.
- **100,034 premium:** the raw 3,001 is capped to 3,000.

With them, both surviving changes now fail, the equivalent ones still pass, and the unmodified code passes all 20 tests.

I did not run Necessist or a full mutation tool. I only ran the boundary probes plus a rounding-offset check.

My first probe run was wrong because Python reused cached bytecode, so I disabled caching and reran everything. The cleanup `git worktree remove` failed with a permission error, so the temporary copy is still at `/tmp/tmp.jnnivNyqcm/w`. The only change in the original repo is the added tests, uncommitted.

VERDICT: inadequate
