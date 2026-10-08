The original tests were not enough to ship on. I've added tests that close the gaps, and the suite now passes: 15 tests in Docker on python:3.12, up from 9.

**Gaps in the original tests** (the original suite passed 9/9 at baseline):
- **Window rule never tested.** `test_rejects_refund_after_window` used an `authorized` payment, so it raised `not_captured` instead of `window_expired`. It also didn't check the code. I temporarily removed the window check entirely, and the suite should have failed. I haven't run that against the original suite, but by reading the test, it would still have passed.
- **No 30-day boundary test.** The contract says refunds are accepted up to 30 days after capture, inclusive. Nothing tested that, so changing `>` to `>=` on the deadline check would have gone unnoticed.
- **Missing amount cases.** There was no test for a fully refunded payment. There was also none for the smallest positive amount.

**Changes to `tests/test_refunds.py`:**
- Fixed the window test to use a captured payment and assert `window_expired`.
- Added tests for a refund exactly at the deadline (accepted) and one second after (rejected).
- Added a test for a fully refunded payment (`exceeds_refundable`) and one for a 1-cent refund (accepted).

**Checks against temporary changes to the code:** each change below was caught by the new or fixed tests, then reverted.
- Deadline `>` to `>=`: caught by the exact-deadline test.
- Amount `>` refundable to `>=`: caught by the full-remaining-amount test.
- Amount `<= 0` to `< 0`: caught by the zero-amount case.
- Window check removed: caught by two tests.

I also tried a deadline change that referenced an undefined name. It failed with a `TypeError`, so it doesn't count as detection, and I discarded it.

**Not done:** I didn't run a full mutation-testing or Necessist pass. The check order among the four rules isn't specified in `CONTRACT.md`, so I didn't pin it.

VERDICT: inadequate
