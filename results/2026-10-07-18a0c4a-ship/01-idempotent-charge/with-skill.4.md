The original tests did not give enough confidence, so I added two tests that close the gaps.

**What was wrong:** The original suite had two tests, and both passed even with the idempotency logic removed. The fake gateway returned the same ID for the same amount (`ch_5000`). That meant the "same key returns the same charge" test could not tell a cached result from a second gateway call. Nothing counted gateway calls, so "charges the gateway only once" was never checked. The "different keys create different charges" rule had no test at all.

**What I added** (in `tests/test_charge.py`, using a gateway that records its calls and returns a new ID each time):
- `test_same_key_charges_gateway_once_and_returns_same_charge` checks that the gateway is called once and that both results are equal.
- `test_different_keys_create_different_charges` checks that two keys cause two gateway calls with distinct IDs.

**Evidence** (I ran the suite in the README's Docker command, and the `app/` code is restored and unchanged):
- Baseline: 4 passed.
- With the idempotency lookup disabled, the new once-only test fails. The original tests would have passed.
- With every key sharing one cache entry, the new different-keys test fails. The original tests would have passed.
- After restoring `app/payments.py`: 4 passed.

I did not run mutation or Necessist tools. I used two hand-made regressions aimed at the documented contract.

VERDICT: inadequate
