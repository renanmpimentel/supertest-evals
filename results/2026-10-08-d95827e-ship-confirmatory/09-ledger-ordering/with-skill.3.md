The original tests did not give enough confidence. They missed one documented rule: `entries()` is always in timestamp order. I added tests for it, and the suite now passes (18 tests).

**The gap:** I replaced `bisect.insort` with a plain `append` in a copy of the project, and all 17 original tests still passed.
- The test named for timestamp order called `close_day()` first, and `close_day()` sorts the list itself, so the sorting in `add()` was never checked.
- The same-timestamp test added its entries already in order, so it couldn't fail either.

**What I changed in `tests/test_ledger.py`:**
- I removed the `close_day()` call from `test_entries_are_in_timestamp_order`.
- I added `test_same_timestamp_keeps_insertion_order_when_added_out_of_order`, which adds entries out of order with several sharing a timestamp.
- With the `append` change back in place, both tests now fail. With the code restored, all 18 pass.

**Other probes:** each of the following was caught by an existing test.
- **Amount limit:** shifting it down one and up one, so `0` and `1` are each tested at the edge.
- **Timestamp limit:** the same shift down and up.
- **Copy rule:** returning the internal list from `entries()` instead of a copy.

**Left alone:** removing the sort in `close_day()` passes all tests. That is equivalent behavior, because `add()` already keeps the list sorted, so I didn't add a test for it.

**Limits of this check:**
- I ran the tests in Docker (`python:3.12-slim`), as the README says.
- I did not run Necessist or a full mutation tool. The checks were the boundary shifts plus a few hand-picked changes, so this doesn't prove the module has no bugs.
- The temporary worktree at `/tmp/tmp.B2Uq5OzNLu/wt` couldn't be removed (permission denied). It is only a temp copy, but git still lists it.
- Your project directory has one uncommitted change: the edited test file.

VERDICT: inadequate
