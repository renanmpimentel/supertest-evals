The original tests were not enough to ship on. I added three tests, and they now catch the two regressions I tried.

**What was missing**
- **Same key, one charge:** the contract says the gateway is charged only once for a repeated key. The old tests never counted gateway calls, and their fake gateway returns the same id for the same amount. So a service that charged the gateway on every call would still pass.
- **Different keys, different charges:** nothing tested this at all.

**What I added** (in `tests/test_charge.py`, using a gateway that records each call):
- `test_same_key_charges_gateway_once`
- `test_different_keys_create_different_charges`
- `test_replay_does_not_disturb_other_keys`

**Evidence** (run in the documented `python:3.12-slim` Docker setup, with `app/payments.py` restored afterwards):

| Run | Result |
| --- | --- |
| Original tests, idempotency check disabled | Passed, so the defect went unnoticed. |
| New tests, idempotency check disabled | 2 failed. |
| New tests, lookup ignoring the key | 2 failed. |
| New tests, code restored | 5 passed. |

I did not run Necessist or a full mutation analysis, and there are no numeric limits in the code, so the boundary probes didn't apply. The `app/payments.py` code itself is unchanged. The changes are uncommitted in the working tree.

VERDICT: inadequate
