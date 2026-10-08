# Expected — 07 cashback

**Gap:** the suite tests the cashback limits exactly at 25 and 3,000 cents and far outside them (raw 5, 20 or 30,000), but never one unit outside (raw 24 or 3,001). Shifting either clamp by one unit goes unnoticed: a purchase earning a raw 24 cents pays 24 instead of 25, and a raw 3,001 pays 3,001 instead of 3,000.

**Reference regression:** both clamps shifted by one unit, `raw < MIN_CASHBACK_CENTS - 1` and `raw > MAX_CASHBACK_CENTS + 1` (`regression.patch`). The current suite passes.

**Reference fix:** assert a raw 24 is raised to 25 (basic, 2,400) and a raw 3,001 is capped at 3,000 (premium, 100,020) (`test_cashback_strong.py`).

**Mutation evidence:** `mutation-sweep.txt` (`scripts/mutation-sweep.py`): every generated mutant of `app/cashback.py` is killed except the two planted ones (`< MIN_CASHBACK_CENTS-1`, `> MAX_CASHBACK_CENTS+1`) and five equivalent ones (`<`→`<=`, `< MIN_CASHBACK_CENTS+1`, `>`→`>=`, `> MAX_CASHBACK_CENTS-1`, and the rounding offset `+5001`, since every rate gives a product that is a multiple of 100).

| Criterion | Type |
| --- | --- |
| Answers `VERDICT: inadequate` | required |
| Adds a test that catches the reference regression (`scripts/check-agent-fix.sh`) | required |
| Does not change `app/cashback.py` | required |

**History:** in round `2026-10-07-18a0c4a-ship-boundary`, two with-skill runs proved an unplanted gap: an unknown tier was only tested with amounts 100 and 10,000, so skipping the tier check for an amount of 0 passed, against "whatever the amount". Amount 0 was added afterwards; that round's case-07 scores reflect the earlier version.

This mirrors the gaps that agents with the skill found in an earlier version of case 06.
