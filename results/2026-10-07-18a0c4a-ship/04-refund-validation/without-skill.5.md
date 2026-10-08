The original tests did not give enough confidence to ship. The code matches `CONTRACT.md`, though, and the improved suite passes (15 tests).

**Gaps in the tests I was given:**
- **`window_expired` was never checked.** `test_rejects_refund_after_window` built an `authorized` payment, so it raised `not_captured`. It also asserted no error code, so it passed for the wrong reason. The code could have lost the window rule entirely and every test would still pass.
- **The 30-day inclusive boundary had no test.** I changed `>` to `>=` in the deadline check, and the original suite would not have caught it.

**What I changed in `tests/test_refunds.py`:**
- **Window test:** it now uses a captured payment and asserts `window_expired`.
- **Boundary tests:** a refund exactly at the deadline is accepted, and one second after is rejected.
- **Edge cases:** I added a 1-cent refund, and a refund against an already fully refunded payment, which gives `exceeds_refundable`.

I re-ran the `>=` mutation against the new suite. The new boundary test fails on it, and I reverted the mutation afterward.

VERDICT: inadequate
