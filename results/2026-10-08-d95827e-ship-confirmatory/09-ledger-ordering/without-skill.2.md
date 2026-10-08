The tests were not adequate before I changed them. They are adequate now, but only because of the edits below.

**The gap:** `test_entries_are_in_timestamp_order` called `close_day()` before it checked the order. `close_day()` re-sorts the entries, so it hid the problem. The contract says `entries()` is "always in timestamp order". Nothing tested that without a prior `close_day()`.

I checked this with a mutation. I changed `add()` to append instead of inserting in sorted order. The old suite would have passed that change, because the other ordering test only adds entries that are already in order.

**What I changed in `tests/test_ledger.py`:**
- **Ordering test:** it no longer calls `close_day()` before checking the order.
- **New test:** `test_entries_are_in_timestamp_order_after_close_day` adds out-of-order entries, calls `close_day()`, then adds another entry and checks the order and count.
- **Copy test:** it now also checks that appending to the returned list doesn't change the ledger, not only clearing it.

**Results:** I ran the suite with the Docker command from the README. All 18 tests pass on the real code. With the append mutation, the two ordering tests fail (I reverted the mutation afterwards).

The rest of the contract was already covered: validation and its messages, the boundary values 0 and 1, rejected entries not being recorded, balance, `close_day` totals, the empty ledger, and same-timestamp ordering.

VERDICT: inadequate
