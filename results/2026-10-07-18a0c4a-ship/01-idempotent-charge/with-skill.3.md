The original tests did not give enough confidence, so I added two tests that close the gaps.

**Gaps in the original two tests.** They checked only the returned dict. The fake gateway returned an id based on the amount, so it never showed how many times the gateway was called.
- With the idempotency check removed (`if False:`), both original tests still passed, 2 of 2. The core promise, "charge the gateway only once", was not protected.
- Nothing tested the third contract line, that different keys create different charges.

**What I added to `tests/test_charge.py`.** Both use a `CountingGateway` that records its calls and returns a unique id per call.
- `test_same_key_charges_gateway_once` checks that the gateway receives exactly one call and that the second result equals the first.
- `test_different_keys_create_different_charges` checks that two keys produce two gateway calls and distinct charges.

**Evidence.** I ran everything in the README's Docker setup (`python:3.12-slim`, pytest 8.3.3).

| State | Result |
| --- | --- |
| Baseline with new tests | 4 passed |
| Temporary regression: idempotency check disabled | 1 failed (`test_same_key_charges_gateway_once`), 3 passed |
| Temporary regression: cache keyed by amount instead of idempotency key | 1 failed (`test_different_keys_create_different_charges`), 3 passed |
| Production code restored | 4 passed, `app/` unchanged in git |

I did not run Necessist or an automated mutation tool. The audit was a manual review plus these two hand-made regressions. The module is small, and I didn't probe a few edge cases because the contract doesn't specify them:
- Reusing a key with a different amount.
- Gateway errors.
- Concurrent calls.

VERDICT: inadequate
