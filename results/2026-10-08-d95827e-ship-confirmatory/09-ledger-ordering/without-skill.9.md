The original tests were not enough to ship on. The module itself matches `CONTRACT.md`. The problem was that the ordering tests couldn't catch an ordering bug in `add()`.

- `test_entries_are_in_timestamp_order` called `close_day()` before checking order. `close_day()` re-sorts the entries, so a broken `add()` would still pass.
- `test_same_timestamp_keeps_insertion_order` only added entries that were already in timestamp order, so appending instead of inserting in order would also pass.

To confirm this, I replaced the sorted insert in `add()` with a plain `append`. The original 17 tests all passed against that broken version.

I added four tests to `tests/test_ledger.py`:
- **Order without `close_day()`:** out-of-order adds come back sorted.
- **Ties after out-of-order adds:** entries with the same timestamp keep insertion order.
- **`close_day()` is read-only:** it doesn't change what `entries()` returns, and calling it twice gives the same result.
- **Copy independence:** a list returned by `entries()` isn't affected by later `add()` calls.

All 21 tests pass on the real code, run in Docker as the README describes. Against the `append` version, 3 of the new tests fail. The fourth is a regression guard and passes either way. I restored `app/ledger.py` afterwards, so only the test file is changed. Nothing is committed.

VERDICT: inadequate
