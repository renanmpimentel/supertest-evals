The original tests did not give enough confidence. I added four tests, and all 6 tests now pass.

- **Idempotency:** `test_same_key_returns_same_charge` only compared ids from a fake gateway that returns the same id for the same amount. A service that charged the gateway twice would still have passed, and "charges the gateway only once" was never checked.
- **Different keys:** nothing tested that different keys create different charges.

The four new tests use a gateway that counts calls and returns a unique id per call:
- A repeated key calls the gateway exactly once.
- A repeated key returns an identical result.
- Different keys make two gateway calls and give different ids.
- Replaying the first key after a second key doesn't recharge.

The contract doesn't cover reusing a key with a different amount, a gateway error, or concurrent calls with the same key. I didn't test those. The implementation isn't thread-safe, so two simultaneous calls with the same key could both charge. Decide whether that matters before shipping.

VERDICT: inadequate
