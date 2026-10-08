The tests I was given did not give enough confidence, so I rewrote the weak ones and added boundary tests. The corrected suite passes (16 passed, run in Docker), and every mutation I tried now fails it. I did not run Necessist or a full mutation tool. I only ran hand-picked regressions: the boundary probes plus one that removed the window check.

**Gaps in the original tests:**
- **Window rule never exercised:** `test_rejects_refund_after_window` used an `authorized` payment. It raised `not_captured`, not `window_expired`, and never checked the code. With the window check deleted, that test still passed.
- **Inclusive 30-day boundary untested:** a refund exactly at the deadline was never tried. Changing `>` to `>=` (rejecting at day 30) would have passed.
- **Amount limits only partly covered:** nothing tested a 1-cent refund, a refund of the full captured amount with no prior refunds, or any refund on a fully refunded payment.

**Changes to `tests/test_refunds.py`:**
- **Window rejection:** `test_rejects_refund_after_window` now uses a captured payment, goes one second past the deadline, and asserts `window_expired`.
- **New tests:**
  - A refund exactly at the deadline is accepted.
  - A refund one second before the deadline is accepted.
  - A 1-cent refund is accepted.
  - A refund of the full amount with no prior refunds is accepted.
  - Any refund on a fully refunded payment is rejected with `exceeds_refundable`.

**Regressions I ran in an isolated copy:** each one fails the corrected suite. The window tests were the ones that failed the window changes; all of them were missed before.

| Change | Failures |
| --- | --- |
| Window 29 days | 3 |
| Window 31 days | 1 |
| Deadline check `>=` | 1 |
| Window check removed | 1 |
| `<= 1` for invalid amount | 2 |
| `< 0` for invalid amount | 1 |
| Refundable check `>=` | 2 |
| Refundable limit +1 | 2 |
| Refundable limit −1 | 2 |

None of the boundary shifts survived, so there are no equivalent ones to record.

One limit of this check: the original project's suite was only run once, after my edits. I didn't run the original 9 tests as a separate baseline, and I didn't run the original tests against the mutations.

One thing to watch outside the tests: the check order in `validate_refund` is untested. When several rules are broken at once, such as an expired window and an excessive amount, nothing says which code should win. `CONTRACT.md` doesn't specify an order either.

VERDICT: inadequate
