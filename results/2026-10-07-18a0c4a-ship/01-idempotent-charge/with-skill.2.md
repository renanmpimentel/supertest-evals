The original tests did not give enough confidence, so I added three tests to `tests/test_charge.py`. The suite now has 5 tests, all passing, and the three regressions below are now caught.

**What was wrong.** The old tests checked only the returned values. Their fake gateway built the charge ID from the amount (`ch_5000`), so the same ID came back whether or not the service cached anything. They never counted gateway calls, and they never used two different keys. That left two of the three documented behaviors, "charges the gateway only once" and "different keys create different charges", unchecked.

**Evidence.** I made three temporary breaks in an isolated copy, run with the README's Docker command:

| Temporary break | Original 2 tests | New tests |
|---|---|---|
| Idempotency check disabled, so every call charges the gateway | 2 passed | `test_same_key_charges_gateway_once` fails |
| Result never stored under the key | 2 passed | `test_same_key_charges_gateway_once` fails |
| Cache keyed by amount instead of idempotency key | 2 passed | `test_different_keys_create_different_charges` fails |

With the production code restored, all 5 tests pass. I did not change `app/payments.py`.

**What the new tests do.** They use a gateway that records each call and returns a unique ID per call:
- `test_same_key_charges_gateway_once` checks the gateway is called exactly once and the second result equals the first.
- `test_different_keys_create_different_charges` checks two keys produce two gateway calls and two distinct IDs.
- `test_different_keys_with_different_amounts_are_independent` checks a second key with a different amount gets its own charge.

**Limits.**
- I ran three hand-picked breaks, not a full mutation-testing or Necessist run, so this is not a full audit.
- The contract says nothing about gateway errors, concurrent calls, or the same key with a different amount, so none of those are tested.
- `/tmp/run.sh` was overwritten by something outside this session partway through (it began running a Go command). I switched to a private script, and the results above come from that.

VERDICT: inadequate
