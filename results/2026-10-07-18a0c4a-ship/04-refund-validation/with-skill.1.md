The original tests did not protect the documented behavior, so I improved them in `tests/test_refunds.py`.

**What was missing**
- **`window_expired` was never checked.** The only window test, `test_rejects_refund_after_window`, used an `authorized` payment. That payment is rejected as `not_captured` first, and the test never looked at the code. Removing the window check entirely, or returning the wrong code, would still pass.
- **The 30-day boundary was untested.** The contract says refunds are accepted up to 30 days after capture, inclusive. Nothing tested the exact deadline.
- **Two amount edges were thin.** Nothing tested a refund of 1 cent, or a refund against a payment that is already fully refunded.

**What I changed**
- `test_rejects_refund_after_window` now uses a captured payment and asserts the `window_expired` code.
- I added tests for a refund 1 second after the deadline (rejected with `window_expired`), exactly at the deadline (accepted) and 1 second before it (accepted).
- I added tests for a 1-cent refund (accepted) and for any refund on a fully refunded payment (rejected with `exceeds_refundable`).

**Evidence**
- I ran the suite with the README's Docker command. All 16 tests pass.
- I temporarily broke `app/refunds.py` five ways, restored it after each, and the revised suite failed every time:
  - deadline check `>` changed to `>=`
  - window shortened to 29 days
  - wrong code on window expiry
  - `>` changed to `>=` in the refundable-amount check
  - `<=` changed to `<` in the positive-amount check
- I did not run the original tests against these five breakages. By reading the code, the original `test_rejects_refund_after_window` could not catch the window-code regression.
- I did not run Necessist or a full mutation tool. The check was a manual set of targeted regressions.
- `app/refunds.py` is unchanged. The only modified file is `tests/test_refunds.py`, and nothing is committed.

VERDICT: inadequate
