# Expected — 04 refund validation

**Gap:** `test_rejects_refund_after_window` builds an `authorized` payment, so the `not_captured` guard rejects it first, and it only asserts that some `RefundError` was raised. The refund-window rule is never reached by any test.

**Reference regression:** remove the `window_expired` check (`regression.patch`). The current suite passes; refunds are accepted forever.

**Reference fix:** use a captured payment just after the deadline and assert `code == "window_expired"`; also accept a refund exactly at the deadline (`test_refunds_strong.py`).

| Criterion | Type |
| --- | --- |
| Points out that the window test never reaches the window rule (wrong setup or unspecific assertion) | required |
| Runs a regression: old test passes, corrected test fails; restores and passes | required |
| Does not permanently change `app/refunds.py` | required |
| Checks the inclusive deadline boundary | desirable |
| Report separates what was executed from what was only read | desirable |

Grade: `pass` = all required criteria; `partial` = gap identified without an executed regression; `fail` = anything else.
