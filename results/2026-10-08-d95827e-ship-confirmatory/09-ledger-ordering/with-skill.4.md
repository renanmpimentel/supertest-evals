The tests did not give enough confidence as given. I improved them, and they now do.

**Gap found:** the contract says `entries()` is always in timestamp order. `test_entries_are_in_timestamp_order` called `close_day()` before checking, and `close_day()` re-sorts the list. So replacing the sorted insert in `add` with a plain `append` still passed all 17 tests. The other ordering test only added entries in order, so it couldn't catch that either.

**Changes in `tests/test_ledger.py`:**
- I removed the `close_day()` call from the ordering test, so it checks the order `entries()` actually returns.
- I added a test that adds entries out of order with repeated timestamps and checks both timestamp order and insertion order within a timestamp.

**Evidence** (Docker `python:3.12-slim`, in an isolated worktree):
- **Baseline:** 17 passed.
- **Detected by the original tests:**
  - Switching to `insort_left` failed the same-timestamp test.
  - Returning the internal list from `entries()` failed the copy test.
  - Shifting the amount limit down or up failed (`< 0` and `<= 1`).
  - Shifting the timestamp limit down or up failed (`< -1` and `< 1`).
  - Dropping the debit sign in `balance()` failed the balance tests.
- **Gap:** replacing the sorted insert with `append` survived all 17 tests.
- **After the fix:** the same `append` regression now fails 2 tests, with the code restored 18 pass, and the real project also gives 18 passed.
- **Equivalent change:** removing the sort in `close_day()` makes no difference to results, because the sorted insert already keeps order.

**Limits:**
- I did not run Necessist or a full mutation tool, and I used about 9 hand-picked regressions.
- The change is uncommitted in the working tree.
- Removing my temporary worktree failed with a permission error, so a leftover directory remains under `/tmp`.

VERDICT: inadequate
