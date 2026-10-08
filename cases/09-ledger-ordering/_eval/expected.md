# Expected — 09 ledger ordering

**Gap:** `test_entries_are_in_timestamp_order` adds entries out of order, then calls `close_day()` before checking `entries()`. `close_day()` sorts the entries itself, so it repairs any disorder left by `add()` and the assertion cannot fail. No test reads `entries()` right after `add()` with out-of-order timestamps, although the contract says `entries()` is always in timestamp order. The tie-order test only adds equal timestamps in already ascending order, so it does not observe the ordering either.

**Reference regression:** `add()` appends instead of inserting in order, `self._entries.append(...)` instead of `bisect.insort(...)` (`regression.patch`). The current suite passes.

**Reference fix:** add out-of-order entries and check `entries()` immediately, without `close_day()` (`test_ledger_strong.py`).

**Mutation evidence:** `mutation-sweep.txt` (`scripts/mutation-sweep.py`): all 14 generated mutants of `app/ledger.py` are killed. The planted regression is a statement-level change the tool cannot generate, so it was checked by hand together with other mutants against the current suite:

| Mutant | Current suite |
| --- | --- |
| `append` instead of `insort` (planted) | survives |
| `insort_left` (ties reversed) | killed |
| `insert(0, ...)` | killed |
| `entries()` returns the internal list | killed |
| unknown kind check removed | killed |
| negative timestamp check removed | killed |
| `close_day()` no longer sorts | survives, equivalent: `add()` already keeps the order |
| amount and timestamp checks swapped | survives, equivalent: the contract does not say which error wins when both are invalid |
| `close_day()` sums debits with `kind != "credit"` | survives, equivalent: the kind is validated, so it is `credit` or `debit` |
| `balance` computed as `credits + debits` | killed |

| Criterion | Type |
| --- | --- |
| Answers `VERDICT: inadequate` | required |
| Adds a test that catches the reference regression (`scripts/check-agent-fix.sh`) | required |
| Does not change `app/ledger.py` | required |

**Pattern:** self-healing state. A later operation (`close_day()`) repairs the violated invariant before the assertion runs, so the check passes whether or not `add()` maintains it.
