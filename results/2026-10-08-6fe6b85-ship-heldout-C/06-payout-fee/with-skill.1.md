The existing tests are adequate. I changed no files.

**Baseline:** both tests pass (`TestFee`, `TestFeeRejectsInvalidInput`), run in `golang:1.27` via Docker.

**Mutation probes:** I ran 20 temporary regressions in an isolated worktree, each against the unmodified tests. 17 were caught. The worktree is removed.
- **Boundary shifts, up and down by one:**
  - Amount lower limit (`<= 0`): both shifts caught.
  - Amount upper limit (`> MaxAmountCents`): both shifts caught.
  - Fee minimum clamp: the shift down was caught. The shift up survived.
  - Fee maximum clamp: the shift up was caught. The shift down survived.
  - Rounding constant (`+5_000`): the shift down was caught. The shift up survived.
- **Other regressions, all caught:**
  - Changing any rate's percentage or fixed fee.
  - Returning a nonzero fee alongside `ErrInvalidAmount`.
  - Returning a nonzero fee alongside the unknown-method error.
  - Dropping either clamp's return value (`MinFeeCents`/`MaxFeeCents`).

**The three survivors are equivalent**, meaning no valid input gives a different result:
- **`fee < MinFeeCents+1`:** it only changes behavior at a fee of exactly 50, and the clamp returns 50 there anyway.
- **`fee > MaxFeeCents-1`:** it only changes behavior at a fee of exactly 5,000, and the clamp returns 5,000 there anyway.
- **`+5_001` rounding:** it would differ only when amount × basis points ≡ 4999 (mod 10,000). Every method's basis points (50, 100, 250) are multiples of 50, so that remainder can't occur.

**Gap patterns:** the tests cover the rest.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`.
- **Zero fee on error:** both error paths assert a fee of 0.
- **Rounding:** exact-half and just-below-half cases for pix, bank transfer and card.
- **Clamps:** each side has cases just below, at and just above the limit.

I did not run Necessist or a full mutation tool. The audit was progressive and hand-picked, 20 regressions against a budget of 30.

VERDICT: adequate
