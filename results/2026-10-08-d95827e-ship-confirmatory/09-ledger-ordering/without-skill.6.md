The existing tests already protected the documented behavior, and the module matches `CONTRACT.md`. I only added regression guards for a few gaps. All 24 tests pass (15 existing, 9 new), run in the README's Docker setup.

**What was covered:**
- recording entries
- the validation rules and their error messages
- rejected entries not being recorded
- stable ordering for same-timestamp entries
- the `entries()` copy
- balance
- `close_day` totals, including the empty case

**Gaps I closed:**
- **Ordering test:** `test_entries_are_in_timestamp_order` called `close_day()` before checking order. `close_day()` re-sorts, so a broken sort in `add` would have gone unnoticed there. The new test checks `entries()` order without calling `close_day()`.
- **`close_day` side effects:** nothing checked that `close_day()` leaves same-timestamp order alone, can be called twice with the same result, or ignores rejected entries. New tests cover each of these.
- **Copy semantics:** the only existing check was that `clear()` on the returned list leaves the ledger alone. The new test also appends to the returned list and then adds more entries.
- **Other cases:** I added a debits-only `close_day` and an interleaved add/balance/order check.

`bisect.insort(key=...)` needs Python 3.10 or later. The README's Docker image is 3.12, so that setup is fine.

VERDICT: adequate
