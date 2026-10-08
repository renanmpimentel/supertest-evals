The original tests didn't give enough confidence, so I added three. All 5 tests now pass, run through the Docker command from the README.

**What was missing.** The two original tests never checked how many times the gateway was called. The contract's main promise is that the same key charges the gateway only once. The old fake gateway also derived the charge id from the amount, so it couldn't show whether two different keys made separate charges. A service that called the gateway on every request would have passed. So would one that gave every key the same charge.

**What I added in `tests/test_charge.py`:**
- **Same key, one gateway call:** a counting gateway confirms a repeated key calls the gateway once and returns an identical result.
- **Same key, different amount:** the gateway is still not called again, and the first charge comes back.
- **Different keys:** two keys with the same amount each call the gateway and get different ids.

I didn't change the code. The implementation matches the contract.

One thing the contract doesn't cover: concurrent calls with the same key could both reach the gateway, because there's no locking. I didn't test for it since it isn't documented, but check it if you expect parallel requests.

VERDICT: inadequate
