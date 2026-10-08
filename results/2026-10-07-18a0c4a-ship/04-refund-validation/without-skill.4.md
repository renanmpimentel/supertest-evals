The original tests didn't give enough confidence. The `window_expired` rule was effectively untested, and the module itself looks correct.

**What was wrong**
- `test_rejects_refund_after_window` used an `authorized` payment and never checked the error code. It passed because the payment wasn't captured, so it raised `not_captured`. The window check was never reached. If the window rule were deleted or broken, that test would still pass.
- Nothing tested the "30 days, inclusive" boundary. Changing `now > deadline` to `>=` would have gone unnoticed.
- Nothing tested a payment with nothing left to refund.

**What I changed in `tests/test_refunds.py`**
- The expiry test now uses a captured payment and asserts `window_expired`.
- I added a test that a refund at exactly the deadline is accepted.
- I added a test that a refund one second past the deadline is rejected with `window_expired`.
- I added a test that a fully refunded payment gives `exceeds_refundable`.

All 14 tests pass in the Docker run from the README. I didn't mutation-test the new tests against a broken implementation, so the claim that they would catch `>=` or a removed window check comes from reading them, not from running them.

VERDICT: inadequate
