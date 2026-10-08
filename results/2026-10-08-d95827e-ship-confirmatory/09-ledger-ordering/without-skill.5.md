No, the original tests didn't give enough confidence. The module already behaves as documented, and all 22 tests now pass against it.

**The gap:** the only test of timestamp ordering called `close_day()` before checking, and `close_day()` re-sorts the entries itself. The same-timestamp test only added entries that were already in order. So if `add()` just appended instead of keeping entries sorted, the old tests would still pass. I confirmed this by making that change. The contract says `entries()` is "always in timestamp order", and that wasn't actually protected.

**What I added** (5 tests in `tests/test_ledger.py`):
- Ordering is checked without calling `close_day()` first.
- Entries with the same timestamp keep insertion order when added out of order.
- `close_day()` doesn't disturb that order or the entry count.
- `close_day()` gives the right totals for unsorted, mixed credits and debits.
- A rejected entry leaves earlier entries intact.

With `add()` changed to append, 2 of the new tests fail. I restored `app/ledger.py` afterwards, and `tests/test_ledger.py` is the only modified file.

**One other thing:** `close_day()` sorts the entries again, which is redundant because `add()` already keeps them in order. It's harmless but could be removed.

VERDICT: inadequate
