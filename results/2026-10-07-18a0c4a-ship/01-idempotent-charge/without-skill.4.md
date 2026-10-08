The original tests weren't enough, so I added new ones. I couldn't run pytest here because it isn't installed. I ran the tests with a small script that calls each test function, and all 5 passed.

**What was wrong:** the original two tests passed even with idempotency removed. The fake gateway returns `ch_<amount>`, so a second gateway charge for the same key and amount still produced the same id. Nothing counted gateway calls, so "charges the gateway only once" was untested. "Different keys create different charges" had no test at all.

**What I added** to `tests/test_charge.py`, using a gateway that returns a unique id per call and records its calls:
- `test_same_key_charges_gateway_only_once`
- `test_different_keys_create_different_charges`
- `test_interleaved_keys_each_charged_once`

**Mutation check:** I disabled the idempotency check in `app/payments.py`. The old tests still passed. The two new "only once" tests failed, as they should. I then restored the file.

**Not covered:** the contract doesn't say what happens when the same key is reused with a different amount. The code silently returns the first charge. It also doesn't say what happens when the gateway raises. In that case nothing is cached, so a retry charges again. I left both untested because the contract doesn't define them. You may want to decide on that behavior before shipping.

VERDICT: inadequate
