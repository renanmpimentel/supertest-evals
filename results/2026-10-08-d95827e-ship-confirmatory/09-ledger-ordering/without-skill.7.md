The existing tests were not enough, so I added three.

**The gap:** `entries()` must always be in timestamp order. The only out-of-order test, `test_entries_are_in_timestamp_order`, called `close_day()` first, and `close_day()` sorts the entries itself. With `add` changed to a plain append, the original 15 tests still passed. Order was never checked on its own, and nor was the same-timestamp tie-break for entries added out of order.

**What I added to `tests/test_ledger.py`:**
- `test_entries_sorted_without_close_day` checks order with no `close_day()` call.
- `test_same_timestamp_keeps_insertion_order_when_added_out_of_order` checks that ties keep insertion order when entries arrive out of order.
- `test_close_day_does_not_change_entries` checks that `close_day()` doesn't change what `entries()` returns.

**How I checked:** I temporarily replaced `bisect.insort` with an append in `app/ledger.py`. The three new tests failed and the original 15 passed. I then restored the code, and all 20 tests pass. The only change left in the working tree is the test file.

The other documented rules were already covered: validation and its error messages, rejected entries not being recorded, boundary values (amount 1, timestamp 0), copy semantics, balance, and `close_day` totals including the empty ledger.

VERDICT: inadequate
