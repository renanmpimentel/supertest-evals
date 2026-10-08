The original tests did not give enough confidence, so I fixed them. They now pass on the real code (16 passed).

**Why the original tests fell short:** the 30-day window rule in `CONTRACT.md` was effectively untested. `test_rejects_refund_after_window` built an `"authorized"` payment, so it raised `not_captured` for the wrong reason. It also never checked the error code. Removing the window check entirely left all 11 original tests green. So did changing `>` to `>=` at the deadline, which breaks the "inclusive" rule.

**Changes to `tests/test_refunds.py`:**
- The window test now uses a captured payment and asserts `window_expired`.
- New tests cover the deadline boundary: exactly at the deadline is accepted, one second before is accepted, and one second after is rejected with `window_expired`.
- New tests cover a fully refunded payment, which gives `exceeds_refundable`, and the smallest valid amount, 1 cent.

**Mutation evidence:** I ran each change as a temporary mutant of `app/refunds.py` in an isolated copy. The strengthened suite fails on all six:

| Mutant | Result |
| --- | --- |
| deadline `>` to `>=` | 1 failed |
| window 30 days to 31 days | 2 failed |
| window check removed | 2 failed |
| exceeds check `>` to `>=` | 1 failed |
| amount check `<=` to `<` | 1 failed |
| wrong error code on the window rule | 2 failed |

The original tests passed 11 of 11 against the first two window mutants.

**Limits:**
- My first mutation runs were invalid. `/tmp/run.sh` ignored its directory argument, so every run tested the unmutated code. I redid them with a new script and the results above are from that run.
- I did not run Necessist, only these hand-picked mutants.
- The contract doesn't say which error wins when several rules are broken at once, so I added no test for that.

VERDICT: inadequate
