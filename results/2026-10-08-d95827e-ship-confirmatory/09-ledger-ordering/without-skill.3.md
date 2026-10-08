The existing tests were already adequate. I ran the module against `CONTRACT.md` and found no behavior that was wrong or unprotected.

Each rule in the contract already had a test:
- **Validation:** unknown kinds, non-positive amounts and negative timestamps are rejected. The boundary values 1 and 0 are accepted, and rejected entries are not recorded.
- **Ordering:** entries come back in timestamp order, and same-timestamp entries keep the order they were added in.
- **Copies:** the list returned by `entries()` is a copy.
- **Totals:** `balance()` and `close_day()` have tests, including the empty-ledger case.

I still added five tests for gaps in how ordering and `close_day()` are exercised:
- Out-of-order inserts with several ties, checked without calling `close_day()`.
- `close_day()` keeps the order of tied entries and gives the same result when called twice.
- A day with only debits.
- Adding entries after `close_day()`.
- A list returned earlier by `entries()` does not change when more entries are added.

All 22 tests pass (the 17 existing plus these 5), run in the Docker setup from the README. The new tests pass against the unchanged code, so they add protection against future regressions rather than catching a current bug.

VERDICT: adequate
