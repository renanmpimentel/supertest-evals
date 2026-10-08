The existing tests didn't give enough confidence, so I added three. All five tests pass when called directly. I couldn't install pytest here, so I haven't run them under `pytest` itself.

**What was missing:** the contract says two calls with the same key charge the gateway only once, and different keys create different charges. The existing tests only compared the `id` of two same-key results, and the fake gateway derives that id from the amount alone. A service that called the gateway twice for the same key would still have passed. Nothing tested different keys at all.

**What I added to `tests/test_charge.py`:**
- **Gateway called once:** a counting gateway checks it receives exactly one call for a repeated key, and that the second result equals the first.
- **Different keys:** two keys with the same amount produce two gateway calls and different charge ids.
- **Replay after another key:** replaying the first key after a second key still returns the original charge without a new gateway call.

The contract says nothing about reusing a key with a different amount or about gateway errors, so I didn't test those.

VERDICT: inadequate
