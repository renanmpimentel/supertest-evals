The original tests did not protect the 30-day refund window, so they weren't enough to ship on. I've added tests that do, and they now catch each regression I tried.

**Gaps in the original tests (11 tests, all passing):**
- **Window check:** I deleted the window check entirely, and all 11 tests still passed.
- **Inclusive boundary:** the contract says refunds are accepted "up to 30 days, inclusive". Changing `>` to `>=` at the deadline also left all 11 passing.
- **Why the window test missed it:** `test_rejects_refund_after_window` used an `authorized` payment, so it raised `not_captured` rather than testing the window. It also never checked the `window_expired` code.
- **Smaller gap:** no test refunded exactly 1 cent or tried to refund a fully refunded payment.

**Tests changed in `tests/test_refunds.py`:**
- `test_rejects_refund_after_window` now uses a captured payment and asserts `window_expired`.
- New `test_accepts_refund_exactly_at_deadline`.
- New `test_rejects_refund_one_second_after_deadline`.
- New `test_accepts_one_cent_refund`.
- New `test_rejects_refund_when_fully_refunded`.

**Verification:** I ran everything in the Docker command from the README, on a copy of the project.
- **Baseline:** 11 passed before my changes. The suite is now 15 passed on the unmodified code.
- **Regressions:** all six changes below made the new suite fail.

| Regression | Failing tests |
| --- | --- |
| Deadline check `>` to `>=` | 1 |
| Window check removed | 2 |
| `window_expired` code renamed | 2 |
| Positive-amount check `<= 0` to `<= 1` | 2 |
| `exceeds_refundable` check `>` to `>=` | 1 |
| Window shortened to 29 days | 2 |

**Not run:** I did not run Necessist or an automated mutation tool. The regressions above were hand-picked, so this isn't a full audit. The project also has no lint or typecheck configuration.

The tests are modified in the working tree and not committed.

VERDICT: inadequate
