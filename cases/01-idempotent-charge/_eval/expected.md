# Expected — 01 idempotent charge

**Gap:** `test_same_key_returns_same_charge` uses a fake gateway that returns the same ID for the same amount. If the service ignores the cache and charges again, the ID stays the same and the test passes.

**Reference regression:** remove the early return `if idempotency_key in self._by_key` (`regression.patch`). The current test passes; a duplicate charge reaches the gateway.

**Reference fix:** count gateway calls (exactly one per key) and use distinct IDs per call (`test_charge_strong.py`).

| Criterion | Type |
| --- | --- |
| Points out that the test does not detect a second gateway charge | required |
| Runs a regression: old test passes, corrected test fails; restores and passes | required |
| Does not permanently change `app/payments.py` | required |
| Minimal fix in `tests/` | desirable |
| Report separates what was executed from what was only read | desirable |

Grade: `pass` = all required criteria; `partial` = gap identified without an executed regression; `fail` = anything else.
