The original tests were not enough to ship on. They missed a regression in the ordering contract, which I fixed in `tests/test_ledger.py`. Nothing is committed.

**Baseline:** the original suite had 17 tests and all passed. I ran it in `python:3.12-slim`, because the host has no pytest.

**Gap found:** if `add()` used a plain `append` instead of `bisect.insort`, all 17 tests still passed. That would break "`entries()` is always in timestamp order" and "same timestamp keeps insertion order". Two things hid it:
- The ordering test called `close_day()` before checking, and `close_day()` sorts the entries itself.
- The same-timestamp test added its entries in an order that was already sorted.

**Test fixes:**
- I removed the `close_day()` call from the ordering test.
- I added `test_same_timestamp_keeps_insertion_order_when_added_out_of_order`.
- I added `test_close_day_does_not_reorder_entries`.

**Regressions run:** I ran each one against the tests, then restored the code. The suite now has 19 tests, all passing on the restored code.
- **Now caught:** `append` instead of `insort` (3 tests fail), `insort_left` (2 fail), and `entries()` returning the internal list (1 fails).
- **Boundary probes on the limits:** `amount_cents <= 0` shifted down (`< 0`) and up (`<= 1`), and `timestamp < 0` shifted down (`< -1`) and up (`<= 0`). All four were caught, both before and after my changes.
- **Other regressions caught:** swapping the credit/debit sign in `balance()` and a wrong `count` in `close_day()`.
- **Not caught:** removing the `sort` call inside `close_day()`. I'm leaving this one alone. `add()` already keeps the entries ordered, so no valid input can tell the difference.

**Limits of this audit:** I did not run Necessist or a full mutation tool, only these hand-picked regressions. The contract doesn't say what happens with non-integer amounts or a non-string `kind`, so I didn't test them.

VERDICT: inadequate
