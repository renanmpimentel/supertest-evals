The tests did not protect one documented rule, so I improved them.

**The gap:** `entries()` must always be in timestamp order. The old ordering test called `close_day()` before checking, and `close_day()` re-sorts the list. The same-timestamp test only used input that was already sorted. So I replaced `bisect.insort` with a plain `append` in `add()`, and all 17 tests still passed. That would have shipped a ledger whose `entries()` is unsorted until the day is closed.

**The fix:** I added two tests to `tests/test_ledger.py`:
- One adds out-of-order entries and checks `entries()` without calling `close_day()`.
- One adds entries out of order with duplicate timestamps, to check that insertion order is kept within a timestamp.

With the `append` change in place, the two new tests fail. With the original code restored, all 19 tests pass. I ran everything in Docker, since there's no local Python.

**Boundary probes:** I shifted each limit down one and up one against the old tests. All four were caught:

| Limit | Probe | Result |
|---|---|---|
| Amount `<= 0` | `< 0` | caught |
| Amount `<= 0` | `<= 1` | caught |
| Timestamp `< 0` | `< -1` | caught |
| Timestamp `< 0` | `< 1` | caught |

**Not done:** I did not run Necessist or a full application mutation sweep, so I only checked the limits and that one hand-picked mutation. The other tests (balance, `close_day` totals, validation, the copy returned by `entries()`, rejected entries not recorded) match the contract on reading. I did not mutation-check them beyond the limit shifts.

**Cleanup:** the temporary worktree at `/tmp/tmp.YhFdQe6IO1/w` could not be removed (permission denied). It is still there and is only a scratch copy.

VERDICT: inadequate
