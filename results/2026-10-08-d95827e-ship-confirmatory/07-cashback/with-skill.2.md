The existing tests already protect the documented behavior. The baseline was 17 passed, 0 failed, 0 skipped, run in `python:3.12-slim` with pytest 8.3.3.

**Boundary probes.** I shifted each of the four limits one unit down and one unit up against the unmodified tests. The limits are the negative-amount check, the 500 minimum purchase, the 25 minimum cashback and the 3,000 maximum cashback. All eight shifts were caught, so none survived.

**Other regressions I ran:**
- **Rounding:** `+5000` changed to `+4999` and to `+0` were caught.
- **Rates:** changing the plus rate to 201 and the premium rate to 299 was caught.
- **Unknown-tier check:** limiting it to amounts of 500 or more was caught.
- **Equivalent change:** `+5001` passed, but no valid input can tell it from `+5000`. Every rate is a multiple of 100 basis points, so the product can never end in 4999.
- **Equivalent change:** a negative amount with an unknown tier raises `CashbackError` either way, so reordering the two checks is also equivalent by the contract.

I did not run Necessist or a full mutation tool. The budget was well under the 30-regression limit.

I added one small test, `test_rejects_negative_amount_for_any_tier`. It pins the contract line "negative amount raises whatever the tier", including a large negative amount with an unknown tier. It passes on the current code, and the suite now has 20 passing tests. The change is in `tests/test_cashback.py` and is uncommitted.

VERDICT: adequate
