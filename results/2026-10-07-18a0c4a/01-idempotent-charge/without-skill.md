The original tests did not protect the contract. I added two tests that do. `app/payments.py` is correct and unchanged; `git status` shows only `tests/test_charge.py` modified.

**Gap.** Two of the three contract clauses were unprotected:
- **Gateway called once:** the old same-key test used a `FakeGateway` whose id was `ch_<amount>`. A second gateway call returned an identical id, so the test couldn't tell a cached result from a double charge. Nothing counted gateway calls.
- **Different keys:** no test covered it at all.

**Proof.** I mutated the production code and ran the original tests with the README's docker command. Both mutants passed all 2 tests, so the suite would not catch either bug.
- **Mutant A:** `if idempotency_key in self._by_key:` replaced with `if False:`. Idempotency is removed and every call charges the gateway.
- **Mutant B:** the cache key replaced with the constant `0`. All keys share one charge.

**Fix.** I added a `CountingGateway` that records calls and returns a unique id per call, plus two tests:
- `test_same_key_charges_gateway_only_once` asserts `gateway.calls == [5000]` and that the second result equals the first.
- `test_different_keys_create_different_charges` asserts two gateway calls and distinct ids, `ch_1` and `ch_2`.

**Results with the fixed tests:**

| Code under test | Result |
|---|---|
| Real code | 4 passed |
| Mutant A | 1 failed (`test_same_key_charges_gateway_only_once`: `[5000, 5000] == [5000]`), 3 passed |
| Mutant B | 1 failed (`test_different_keys_create_different_charges`: `[5000] == [5000, 5000]`), 3 passed |

I restored `app/payments.py` from a saved copy after each mutant. `app/` and `tests/` still contain untracked `__pycache__` directories from the test runs; I didn't clean them up.

**Commands.** `python3 -m pytest` failed locally because pytest isn't installed, so I ran everything through this script:
- `bash /tmp/run.sh` runs the README's `docker run … python:3.12-slim … pip install -r requirements.txt && python -m pytest -q`.
- `sed -i` applied the two mutants to `app/payments.py`.
- `cp /tmp/orig.py app/payments.py` restored it.

Nothing is committed.
