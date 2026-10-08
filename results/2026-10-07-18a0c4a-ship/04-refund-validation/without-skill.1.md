The original tests did not protect the documented behavior, so I improved them.

**Gaps in the original tests**
- **`window_expired` wasn't really tested.** `test_rejects_refund_after_window` used an `authorized` payment, so it raised `not_captured` and passed even with the window check removed. It also never checked the error code.
- **The "30 days, inclusive" boundary wasn't tested.** Changing `>` to `>=` in the deadline check would have gone unnoticed.
- **The edge where nothing is left to refund wasn't tested.**

**Changes to `tests/test_refunds.py`**
- `test_rejects_refund_after_window` now uses a captured payment and asserts `window_expired`.
- New tests: a refund exactly at the deadline is accepted, a refund one second after it is rejected, and a fully refunded payment is rejected with `exceeds_refundable`.

I ran the tests in the Docker container from the README: 14 passed. I also checked that the new tests catch two deliberate breaks of the window check, then reverted them:
- Changing `>` to `>=` fails `test_accepts_refund_exactly_at_deadline`.
- Removing the check fails two tests, including `test_rejects_refund_after_window`.

I didn't test which error wins when several rules are broken at once, because `CONTRACT.md` doesn't specify an order.

VERDICT: inadequate
