The original tests were not enough. The probes below were run in a container (python:3.12-slim, pytest 8.3.3).

**The gap.** I shifted each limit in `app/cashback.py` one unit down and one unit up. Two shifts passed all 17 original tests and change valid results:
- **Minimum cashback (25).** With `raw < 24`, a purchase whose rate gives 24 cents pays 24 instead of the documented 25. The tests only checked values that were far from the floor or exactly on it.
- **Maximum cashback (3,000).** With `raw > 3001`, a purchase whose rate gives 3,001 cents pays 3,001 instead of the documented 3,000. The tests checked 2,999, 3,000 and a far-above value.

Two other shifts also survived, but they are equivalent. `raw < 26` and `raw > 2999` give identical results for every valid input. The purchase-threshold (500) and negative-amount shifts were already caught by the original tests.

**What I changed.** I added three tests to `tests/test_cashback.py`:
- `2_400, "basic"` expects 25. The raw cashback is 24, below the floor.
- `100_049, "premium"` expects 3,000. The raw cashback is 3,001, above the cap.
- A negative amount with an unknown tier raises `CashbackError`. The original tests did not cover this documented "whatever the amount" case, and the probes did not need it.

With the new tests, both real shifts now fail one test each. Restored, the suite passes: 20 passed, 0 failed. Only the test file differs from the baseline commit.

**Limits.**
- I only ran the boundary probes. I did not run Necessist or a full mutation tool.
- An early run showed 2 spurious failures. A stale root-owned `__pycache__` from my mutation loop was the cause, not the code. I deleted it and reran with bytecode writing off.

VERDICT: inadequate
