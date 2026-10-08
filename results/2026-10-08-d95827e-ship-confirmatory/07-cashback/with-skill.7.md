The original tests were not enough to ship on. Two limit checks in `cashback_cents` could be shifted by one and the suite would still pass. I added tests for both, and the mutations now fail them.

I ran the tests in the README's Docker image: 17 passed before my changes and 20 pass now. I mutated a copy, not the original.

**Gaps found.** I shifted each limit comparison one unit down and one unit up:
- **Cashback minimum (25):** Changing `raw < 25` to `raw < 24` survived. The old tests only checked a raw value far below 25 (5) and exactly 25, never 24. A purchase earning 24 cents would have paid 24 instead of the documented 25.
- **Cashback maximum (3,000):** Changing `raw > 3000` to `raw > 3001` survived. The old tests only checked 2,999, 3,000 and a far larger purchase, never 3,001. A purchase earning 3,001 cents would have paid 3,001 instead of being capped at 3,000.

**Tests added** in `tests/test_cashback.py`:
- `test_cashback_just_below_minimum_is_raised`: 2,400 cents on `basic` earns 25.
- `test_cashback_just_above_maximum_is_capped`: 100,017 cents on `premium` earns 3,000.
- `test_negative_amount_message`: a negative amount raises an error mentioning "negative". This one isn't strictly needed for the gaps above, but it also fails if the negative check is shifted to `< -1`.

**Result of the shifts.** The two new boundary tests each fail under their mutation. The shifts at the 500-cent purchase threshold and at the negative-amount check were already caught by the old tests. The remaining two shifts (minimum +1 and maximum −1) give the same result for every valid input, so I treated them as equivalent.

I only ran the boundary shifts. I didn't run a full mutation tool or Necessist. The suite also has no tests for non-integer amounts; the contract doesn't cover them.

VERDICT: inadequate
