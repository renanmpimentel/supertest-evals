The original tests were not enough to ship on. I've fixed that in `tests/test_refunds.py`, and the suite now passes with 16 tests (it was 11).

**What was wrong**
- **The window rule was untested.** `test_rejects_refund_after_window` used an `authorized` payment, so it raised `not_captured` and never reached the 30-day check. It also never checked the error code. I didn't run the old tests against a broken window check, but nothing in them could catch one. Changing `>` to `>=`, or the window to 29 or 31 days, would have gone unnoticed. "Up to 30 days, inclusive" was unprotected.
- **Limit checks were loose.** The smallest valid refund (1 cent) and a refund 1 cent over the refundable amount on a fresh payment were never exercised. I didn't run the old tests against shifted limits, so those gaps are from reading them.
- **No precedence or fully-refunded cases.** Nothing covered which error wins when several rules are broken, or a payment with nothing left to refund.

**Tests added**
- The window rejection test now uses a captured payment and asserts `window_expired`.
- A new test checks the exact 30-day deadline, one microsecond before it, and one microsecond after it.
- New tests cover a 1-cent refund, 10,001 on a 10,000 payment, any refund on a fully refunded payment, and the order the rules are checked in.

**How I checked**
I ran the suite in a temporary copy of the repo, broke the code one way at a time, and restored it between runs. All nine breaks were caught by the new tests:
- Moving the amount limit (`<= 0`) down 1 and up 1.
- Moving the refundable limit down 1 and up 1.
- Moving the deadline by ±1 microsecond.
- Changing the window to 29 days and to 31 days.
- Changing `now > deadline` to `now >= deadline`.

No shifted limit survived. I did not run Necessist or a full mutation tool; the checks above are hand-picked breaks plus the limit shifts.

The temporary copy at `/tmp/wt` couldn't be fully deleted because Docker left root-owned files in it. It's unregistered from git and harmless, but you'll need to delete it manually. The main project has only the test file modified.

VERDICT: inadequate
