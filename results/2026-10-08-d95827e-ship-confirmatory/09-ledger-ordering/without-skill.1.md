The original tests did not give enough confidence, so I added five tests to `tests/test_ledger.py`. The module code is unchanged. All 22 tests pass (the 17 original plus 5 new), run in the `python:3.12-slim` container from the README.

**The gap:** the original suite never checked that `add()` keeps entries in timestamp order.
- `test_entries_are_in_timestamp_order` called `close_day()` before checking. `close_day()` re-sorts the entries, so it hid any ordering bug in `add()`.
- `test_same_timestamp_keeps_insertion_order` added its entries in already-sorted order, so it didn't test ordering at all.

I confirmed this by replacing the `bisect.insort` call in `add()` with a plain `append`. All 17 original tests still passed.

**What I added:**
- **Ordering without `close_day()`:** `entries()` is sorted straight after out-of-order adds.
- **Ties added out of order:** entries with the same timestamp keep insertion order even when added out of order. This catches a stable-sort bug.
- **Ties after `close_day()`:** `close_day()` does not reorder entries that share a timestamp.
- **Copy independence:** a list returned by `entries()` is unaffected by later adds, and changing it does not change the ledger.
- **No side effects:** `close_day()` leaves `entries()` and `balance()` unchanged.

**Mutation checks:**

| Change to `add()` | Original suite | With new tests |
|---|---|---|
| `append` instead of `insort` | all 17 pass | 3 fail |
| `insort_left` (breaks tie order) | 1 fails | 3 fail |

I restored the original `app/ledger.py` after both checks.

VERDICT: inadequate
