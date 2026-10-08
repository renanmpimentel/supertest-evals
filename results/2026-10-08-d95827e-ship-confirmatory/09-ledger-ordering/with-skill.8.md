The tests were not adequate. I found one gap: nothing checked that `entries()` returns entries in timestamp order unless `close_day()` had been called. I fixed it in `tests/test_ledger.py`.

**Baseline:** 17 tests passed in Docker, using the README command.

**Regressions I tried in an isolated worktree**
- **Caught by the original tests:** `insort_left`, the amount limit shifted down and up, the timestamp limit shifted down and up, `entries()` returning the internal list, and `close_day()` reordering entries.
- **Not caught:** replacing the sorted insert in `add()` with a plain append left all 17 tests green. This breaks the documented rule that `entries()` is always in timestamp order.
- **Why it slipped through:** `test_entries_are_in_timestamp_order` called `close_day()` before checking order, and `close_day()` sorts the list. Every other test added entries in order already, so none of them noticed.
- **Equivalent change:** removing the sort from `close_day()` changes nothing, because `add()` already keeps the list sorted. I left it alone.

**Fix**
- I removed the `close_day()` call from the order test, so it now checks `entries()` directly.
- I added `test_out_of_order_adds_with_ties_are_sorted_stably`. It adds entries out of order with tied timestamps and checks the exact order before and after `close_day()`.
- With the append regression, 2 tests now fail. With the original code restored, all 18 pass.

**Limits**
- I did not run Necessist or full application mutation testing, only the manual regressions above.
- Git was missing inside the container, so my first probe run didn't restore the file between regressions and its results were invalid. I reran everything with a file copy as the reset.
- I couldn't delete the temporary worktree (permission denied), so it is still at `/tmp/tmp.AOHLx43rCw/w`. The project itself only has the test file modified.

VERDICT: inadequate
