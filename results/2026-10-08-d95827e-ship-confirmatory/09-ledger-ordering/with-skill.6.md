The original tests did not give enough confidence, and I've fixed that.

Baseline was 17 passed under the README's Docker command.

**The gap:** `test_entries_are_in_timestamp_order` called `close_day()` before checking the order. `close_day()` re-sorts the entries, so it hid whether `add()` keeps them in order, and the contract says `entries()` is always in timestamp order. I replaced `bisect.insort` in `add()` with `append`, and all 17 original tests still passed. A ledger that returns entries unsorted until the day is closed would have shipped.

**The fix** (in `tests/test_ledger.py`):
- The ordering test no longer calls `close_day()`.
- A new test, `test_close_day_does_not_reorder_or_drop_entries`, checks that `close_day()` leaves the entries in the same order as before.

With the `append` regression in place, the corrected ordering test fails (1 failed, 17 passed). With the code restored, all 18 pass. The final Docker run on the original project also gives 18 passed.

**Boundary probes:** I shifted each limit down and then up by one: `amount_cents <= 0` and `timestamp < 0`. All four shifts were caught by the existing tests (1–2 failures each), so those limits are well covered.

**Not done:** I did not run Necessist or a full mutation-testing tool. Beyond the boundary probes and the `append` regression, I read the code and tests by hand.

I used a temporary git worktree for the regressions. Docker could not delete it (permission denied), so I pruned it from git. The leftover directory under `/tmp` is harmless.

VERDICT: inadequate
