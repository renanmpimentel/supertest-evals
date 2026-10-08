The original tests did not give enough confidence. They left one documented rule unprotected: `entries()` must always return entries in timestamp order. I fixed that in `tests/test_ledger.py`.

**The gap.** `test_entries_are_in_timestamp_order` called `close_day()` before checking the order. `close_day()` sorts the entries itself, so it hid whether `add()` kept them in order. I swapped `bisect.insort` in `add()` for a plain `append`, and all 17 tests still passed.

**The fix.** I removed the `close_day()` call from that test. I also added a test that adds entries out of order with duplicate timestamps. It checks that `entries()` is sorted and that entries with the same timestamp keep the order they were added in.

**Evidence** (run in an isolated worktree, using the Docker command from the README):
- **Baseline:** 17 passed.
- **Old tests with the `append` change:** 17 passed, so the defect went undetected.
- **New tests with the `append` change:** 2 failed (the reworked ordering test and the new one).
- **New tests with the code restored:** 18 passed. The original project also gives 18 passed.

**Boundary probes.** I shifted each limit down and up by one, and every shift made a test fail:
- `amount_cents <= 0` became `< 0` and `<= 1`.
- `timestamp < 0` became `< -1` and `< 1`.

**Not covered.** Removing the `sort` in `close_day()` leaves everything passing. That sort is redundant because `add()` already keeps the list ordered, so I treated it as equivalent and wrote no test for it. I did not run Necessist or a full mutation-testing tool. The only regressions I ran were the four boundary shifts, the `append` change and the `close_day()` sort removal.

The worktree's directory was left behind because I couldn't delete it (permission denied). I pruned the git registration, so it no longer shows up in `git worktree list`.

VERDICT: inadequate
