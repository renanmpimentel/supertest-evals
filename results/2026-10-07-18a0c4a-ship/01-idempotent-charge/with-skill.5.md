The original tests did not give enough confidence, so I added tests to `tests/test_charge.py`. The original suite missed two contract violations that the new tests catch.

**The gaps in the original two tests:**
- They never checked how many times the gateway was called. The fake gateway returned `ch_<amount>`, so a repeat call produced the same id as the first. Removing the idempotency check entirely would have passed.
- Nothing covered "different keys create different charges".

**Evidence.** I ran everything in Docker (`python:3.12-slim`). I did not run Necessist or a mutation tool; the check was two temporary regressions, each reverted afterwards.

| Regression | Original 2 tests | Updated 5 tests |
| --- | --- | --- |
| Idempotency check disabled (every call charges the gateway) | 2 passed, not detected | 2 failed, detected |
| Cache returns the first stored charge for any key | 2 passed, not detected | 1 failed, detected |

With the code restored, the original suite passes 2 of 2 and the updated suite passes 5 of 5.

**The three new tests:**
- A repeated key calls the gateway once and returns the identical charge. The gateway here counts calls and returns unique ids.
- A repeated key with a different amount still returns the first charge.
- Different keys produce two gateway calls and distinct charges.

The second test goes beyond the three contract bullets. It treats the key as authoritative, which is what the current code does, but the contract doesn't state it. Drop that test if you'd rather not lock the behaviour in.

The contract says nothing about gateway errors or concurrency, so I didn't test either.

VERDICT: inadequate
