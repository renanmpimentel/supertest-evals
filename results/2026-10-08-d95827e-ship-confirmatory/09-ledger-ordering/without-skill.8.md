The original tests weren't enough to ship on, so I added six. All 23 tests pass in Docker, using the README's command, against the unchanged `app/ledger.py`.

**The gap:** the only test that checked `entries()` ordering with out-of-order input called `close_day()` first. `close_day()` re-sorts the list, so that call hid any ordering bug in `add()`. If `add()` just appended, `entries()` would return entries unsorted and the original suite would still pass.

**What I added to `tests/test_ledger.py`:**
- `entries()` is in timestamp order without `close_day()` being called.
- Same-timestamp entries added out of order keep their insertion order, both before and after `close_day()`.
- `close_day()` doesn't clear or change the ledger, and calling it twice gives the same result.
- `close_day()` returns a fresh dict, so editing it doesn't affect later calls.
- Adding an entry after `close_day()` is recorded, and the totals update.
- `balance()` agrees with `close_day()["balance"]`.

I also checked that the new tests catch a real bug. I swapped `insort` for `insort_left` in `add()`, which breaks the same-timestamp rule, and two tests failed. I restored the file afterward, so `app/ledger.py` is unchanged.

The module code itself matches `CONTRACT.md`. I found no bugs in it.

VERDICT: inadequate
