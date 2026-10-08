The original tests did not give enough confidence, so I fixed them. One documented rule, that `entries()` is always in timestamp order, had no real protection.

**The gap:** I replaced `bisect.insort` with a plain `append`, which breaks that ordering rule. All 17 original tests still passed. The ordering test called `close_day()` before checking, and `close_day()` re-sorts the list. The other ordering test only added entries that were already in order.

**What I changed in `tests/test_ledger.py`:**
- `test_entries_are_in_timestamp_order` no longer calls `close_day()`, so it checks `entries()` as the contract describes.
- I added a test that adds entries out of order with a repeated timestamp and checks that same-timestamp entries keep their insertion order.

**Evidence:**
- **Baseline:** 17 passed, run through the README's docker command.
- **After the fix:** with the `append` regression applied, 2 tests fail. With the code restored, 18 pass, including a final run in the original project.
- **Limit checks:** I shifted each limit (amount and timestamp) one unit down and one unit up. All four shifts fail at least one test.
- **Not a gap:** removing the sort in `close_day()` leaves every test passing. That is equivalent behavior, because `insort` already keeps the list sorted.

**Not done:** I did not run Necessist or a full mutation tool; I ran hand-picked regressions only. The temporary worktree at `/tmp/tmp.ywgBpdNWUZ/wt` could not be deleted (permission denied), so it is still there and you can remove it with `git worktree remove`.

VERDICT: inadequate
