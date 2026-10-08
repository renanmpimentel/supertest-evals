The original tests did not give enough confidence. I fixed that, and all 14 tests now pass (11 before my changes, which included the vacuous window test).

**What was wrong:** the only `window_expired` test was vacuous. It built its payment with status `authorized`, so it raised `not_captured` before the window check ran. It also never checked the error code. As written, the 30-day window rule had no real coverage. Deleting the window check from `validate_refund` would not have failed any test.

**What I changed in `tests/test_refunds.py`:**
- **Window rule:** the test now uses a captured payment and asserts `window_expired`.
- **Inclusive deadline:** a refund exactly at `refund_deadline` is accepted. The contract says "inclusive", and this pins it.
- **Just past the deadline:** a refund one second after is rejected with `window_expired`.
- **Fully refunded payment:** any positive amount on a fully refunded payment is rejected with `exceeds_refundable`.

The implementation in `app/refunds.py` matches the contract, and I changed nothing there. The other three rules, the exact-remaining-amount boundary and both helpers were already covered. I did not add tests for which error wins when several rules are broken at once, since the contract doesn't specify an order.

VERDICT: inadequate
