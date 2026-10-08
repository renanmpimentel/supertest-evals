The original tests were not enough to ship on. I've fixed that in `tests/test_refunds.py`.

**What was wrong**
- **Window test checked the wrong rule.** `test_rejects_refund_after_window` used an `authorized` payment. It passed because of `not_captured`, and it never checked the `code`. Nothing in the old suite checked `window_expired`.
- **The "inclusive" 30-day boundary was untested.** The documented rule "up to 30 days after capture, inclusive" had no test at the deadline. Changing `now > deadline` to `>=` passed all 11 old tests.
- **The amount floor had a gap.** Changing `amount_cents <= 0` to `<= 1` also passed all 11 old tests, so rejecting a 1-cent refund went unnoticed.

**What I added**
- **Window:** `window_expired` is asserted on a captured payment. The deadline is checked one second before, exactly at, and one second after.
- **Amount:** the smallest valid amount (1 cent) is accepted. The full refundable amount is accepted and one cent more is rejected. A fully refunded payment rejects any refund.

**How I checked it**
I ran the tests in Docker with the README command: 11 passed before, 15 pass now. For each limit I applied a temporary change to the code, ran the old and new tests against it, then restored the code. The limits are the 30-day window, the `<= 0` floor and the `> refundable` ceiling.

| Change to the code | Old tests | New tests |
| --- | --- | --- |
| window 29 days | fail | fail |
| window 31 days | fail | fail |
| deadline `>` → `>=` | **pass** | fail |
| floor `<= 0` → `<= 1` | **pass** | fail |
| floor `<= 0` → `< 0` | fail | fail |
| ceiling `>` → `>=` | fail | fail |
| ceiling +1 | fail | fail |

My first batch of probes ran against the wrong directory, because an older `/tmp/run.sh` ignored its argument. I discarded those results and redid every row above with my own runner.

**Not done:** I did not run Necessist or a full mutation tool. I did not test which error wins when several rules break at once, because `CONTRACT.md` doesn't say. The application code is unchanged, and the test changes are uncommitted in the working tree.

VERDICT: inadequate
