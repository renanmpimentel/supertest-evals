The original tests were not enough. I found one gap, fixed it in `tests/test_ledger.py`, and the suite now passes with 19 tests. The temporary worktree at `/tmp/tmp.qiY0j00n9p/p` couldn't be removed because of a permissions error. It is outside the repo and harmless.

**Method.** I ran the suite in the `python:3.12-slim` container from the README (17 passed), then made temporary breaking changes to `app/ledger.py` in an isolated worktree. I restored the code after each one.

**What the tests already caught:**
- **Amount limit:** shifting `amount_cents <= 0` down to `< 0` or up to `<= 1` made a test fail.
- **Timestamp limit:** shifting `timestamp < 0` to `< -1` or `< 1` made a test fail.
- **Same-timestamp order:** switching `insort` to `insort_left` made a test fail.
- **Copy semantics:** returning the internal list from `entries()` made a test fail.
- **Totals:** a wrong `count` in `close_day()` made a test fail.

**The gap.** If `add()` stopped keeping entries sorted and just appended, all 17 tests still passed. `test_entries_are_in_timestamp_order` called `close_day()` before checking, and `close_day()` sorts the list as a side effect. That hid the bug. The other order tests only added entries that were already in order. The contract says `entries()` is always in timestamp order, and that wasn't actually tested.

**Fix:**
- I removed the `close_day()` call from the ordering test.
- I added a test that adds entries out of order with duplicate timestamps and checks timestamp order, with insertion order kept within a timestamp.
- I added a test that `close_day()` leaves the order unchanged.

With the append-only version of `add()`, two tests now fail. With the real code restored, all 19 pass, both in the isolated copy and in the original project.

I did not run Necessist or a full mutation tool. The audit was the contract review plus the boundary and targeted breaking changes above.

VERDICT: inadequate
