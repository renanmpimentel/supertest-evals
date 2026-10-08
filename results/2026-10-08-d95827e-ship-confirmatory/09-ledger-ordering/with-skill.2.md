The tests did not give enough confidence as written, so I changed them. They now cover the documented ordering behavior.

**The gap:** the existing tests would not have caught a broken ordering rule. `test_entries_are_in_timestamp_order` called `close_day()` before checking order. `close_day()` re-sorts the entries in place, so it hid whether `add()` kept them sorted. `test_same_timestamp_keeps_insertion_order` added its entries already in timestamp order, so it never exercised out-of-order insertion.

**How I checked:** I made a temporary change in an isolated worktree, replacing the sorted insert in `add()` with a plain append. The original 17 tests still passed.

**The fix, in `tests/test_ledger.py`:**
- I removed the `close_day()` call from the ordering test.
- I added a test that adds entries out of order with repeated timestamps and expects `[300, 400, 100, 200]`.

**After the fix:** with the same temporary change, 2 tests fail: the ordering test and the new one. With the code restored, all 18 pass in the original project too.

**Other checks:**
- **Limit checks:** I did not run the shifted-limit probes. By reading the code, the `amount <= 0` and `timestamp < 0` limits are already checked at the boundary. The tests cover 0, -1 and the smallest valid values (amount 1, timestamp 0).
- **Not run:** I did not run Necessist or a full mutation tool.
- **Other contracts:** I did not mutate any other documented rule. They read as adequately covered: validation messages, nothing recorded on rejection, `entries()` returning a copy, balance and `close_day` totals.
- **Cleanup:** the temporary worktree could not be removed (permission denied). It is at `/tmp/tmp.tDAW8u240A/w` and can be deleted manually.
- **Uncommitted:** the test changes are in the working tree and not committed.

VERDICT: inadequate
