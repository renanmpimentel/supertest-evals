No, the original tests did not give enough confidence. The module code looks correct, though.

**The gap:** `window_expired` was effectively untested. `test_rejects_refund_after_window` used an `authorized` payment, so it raised `not_captured` and passed for the wrong reason. It never checked the error code. Nothing covered the documented "30 days, inclusive" boundary either. Changing `>` to `>=` in the deadline check, which would reject refunds on day 30, left the whole suite green.

**What I changed in `tests/test_refunds.py`:**
- The window test now uses a captured payment and asserts the `window_expired` code.
- A new test accepts a refund exactly at the deadline.
- A new test rejects a refund one second after the deadline.
- A new test covers a fully refunded payment, which must raise `exceeds_refundable`.

**Verification:** I ran the suite in Docker as the README describes, and all 14 tests pass. I then reintroduced the `>=` bug temporarily, and the new boundary test caught it. I restored `app/refunds.py` afterwards, so only the test file is modified.

I didn't add tests for the order in which the rules are checked when several are broken at once. The contract doesn't specify an order.

VERDICT: inadequate
