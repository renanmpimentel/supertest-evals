The original tests did not give enough confidence, so I added two tests to `tests/test_charge.py`.

**What was wrong.** The original two tests passed, but they never checked the contract's main promise: that the gateway is charged only once per key. The fake gateway built the charge ID from the amount, so a second call to the gateway returned the same ID. I removed the idempotency check from `app/payments.py` as a temporary regression, and the original tests would still have passed. Nothing tested that different keys give different charges either.

**What I added.**
- **Same key:** a counting gateway checks that it is charged exactly once and that the second call returns the same result as the first.
- **Different keys:** two keys must give two gateway calls and two distinct charges.

**Evidence.** I ran everything in Docker, using the command from the README.

| Run | Result |
| --- | --- |
| Baseline with the new tests | 4 passed |
| Temporary regression: idempotency check removed | `test_same_key_charges_gateway_once` failed |
| Temporary regression: key ignored, one shared cache | `test_different_keys_create_different_charges` failed |
| Production code restored | 4 passed |

`app/payments.py` is unchanged; only the test file differs.

**Limits.** I did not run a mutation tool or Necessist (the full-audit tools); detection is shown only by the two manual regressions above.

VERDICT: inadequate
