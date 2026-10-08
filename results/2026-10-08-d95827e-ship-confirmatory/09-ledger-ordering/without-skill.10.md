The existing tests were not enough to ship on. I added three tests that close the gap, and the suite now passes: 20 tests, the original 17 plus the new 3.

**The gap:** `entries()` must always be in timestamp order. The only out-of-order test called `close_day()` before checking, and `close_day()` re-sorts the entries itself. The other ordering tests added entries that were already in order. So if `add` stopped keeping entries sorted (say, a plain `append`), every original test still passed. I confirmed this by making that change, which gave 17 passed and 0 failed on the original tests. The contract says "always in timestamp order", and nothing checked it.

**Added tests:**
- Entries added out of order come back sorted, with no `close_day()` call first.
- Entries added out of order that share a timestamp keep their insertion order.
- `close_day()` doesn't change what `entries()` returns.

With the `append` change in place, all three new tests fail. I then put `app/ledger.py` back, so only the test file is modified.

The rest of the contract was already covered:
- Rejection of bad kind, amount and timestamp.
- The boundary values 0 and 1.
- That rejected entries aren't recorded.
- That `entries()` returns a copy.
- The balance and `close_day` totals.
- The empty-ledger case.

VERDICT: inadequate
