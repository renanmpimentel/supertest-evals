The original tests didn't give enough confidence, so I added tests. All 6 now pass, and I ran them in the README's docker setup.

**Gaps in the original two tests:**
- **Gateway called once:** this is the core of the contract, and nothing checked it. The fake gateway didn't count calls, so an implementation that charged the gateway on every call would still have passed.
- **Different keys:** nothing tested this. The fake gateway's id came from the amount (`ch_5000`), so two charges of the same amount got the same id and couldn't be told apart.

**Tests I added in `tests/test_charge.py`:**
- A gateway that records calls and returns unique ids.
- Repeated calls with the same key hit the gateway exactly once.
- The repeated call returns an identical charge.
- Different keys make separate gateway calls and get different ids.
- `amount_cents` in the result matches the amount for each key.

The contract doesn't say what happens when the same key is reused with a different amount. The current code silently returns the first charge. I left that untested because the contract is silent on it, but you may want to define the behavior before shipping.

VERDICT: inadequate
