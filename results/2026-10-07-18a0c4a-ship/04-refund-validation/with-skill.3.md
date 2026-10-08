The original tests did not protect the 30-day refund window, so I strengthened them. The suite now passes (13 tests), production code is unchanged, and I did not run Necessist or a full mutation tool.

**What was wrong**
- `test_rejects_refund_after_window` used an `authorized` payment. It raised `RefundError` because of `not_captured`, not because of the window. It also never checked the error code.
- Nothing tested the exact 30-day boundary, which the contract says is inclusive.

**Proof of the gap.** I made temporary changes to `app/refunds.py` and ran the original tests against them:

| Change | Original tests |
|---|---|
| `now >= deadline` (breaks the inclusive boundary) | pass |
| window check removed entirely | pass |

**Fix.** In `tests/test_refunds.py`:
- The window test now uses a captured payment at 31 days and asserts `window_expired`.
- A new test accepts a refund exactly at the deadline.
- A new test rejects one second after the deadline and asserts `window_expired`.

**Verification.** All three window changes now fail the strengthened tests:
- `>=`: 1 failure.
- Check removed: 2 failures.
- Window set to 31 days: 3 failures.

I restored the code after each change and the suite passes again.

**Already adequate:** `not_captured`, `invalid_amount` (0 and -1), the `exceeds_refundable` boundary (7500 accepted, 7501 rejected), and both helpers.

**Limitation.** The contract doesn't say which error wins when several rules are broken at once, so I didn't test rule ordering.

VERDICT: inadequate
