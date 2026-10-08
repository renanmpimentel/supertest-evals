The original tests didn't fully protect the documented behavior, so I strengthened them. All 20 tests now pass against the real code.

**The gap.** The contract says `entries()` is "always in timestamp order". The original ordering test called `close_day()` before checking the order. `close_day()` sorts the entries as a side effect, so that call hid any bug where `add` doesn't keep them sorted. I confirmed this with a mutant: `add` just appends, and only `close_day()` sorts. The original suite passes that mutant, even though it breaks the contract.

**What I changed in `tests/test_ledger.py`:**
- **Ordering test:** I removed the `close_day()` call, so it checks order straight after `add`.
- **New test, ties out of order:** entries added out of order with repeated timestamps must stay in insertion order within each timestamp.
- **New test, `close_day()` side effects:** it must not change the entries or their order, and calling it twice must give the same totals.
- **New test, debits only:** `close_day()` totals on a ledger holding only debits.

With the mutant in place, three tests now fail: the fixed ordering test and the two new ordering tests. I then restored `app/ledger.py` with `git checkout`, so the source is unchanged.

The remaining behavior was already covered: validation, rejected entries not being recorded, the copy returned by `entries()`, balance and the empty ledger.

VERDICT: inadequate
