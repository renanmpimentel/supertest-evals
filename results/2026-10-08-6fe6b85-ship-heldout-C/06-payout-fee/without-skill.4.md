The existing tests are enough for this contract, so I changed nothing. They pass (run through the Docker image from the README, since Go isn't installed locally).

I checked each rule in `CONTRACT.md` against the cases in `payouts_test.go`, and worked the arithmetic for the boundary cases by hand against `payouts.go`.

- **Rates and fixed fees:** `pix`, `bank_transfer` and `card` each have a percentage-plus-fixed case, so a wrong rate or fixed fee for any of them would fail.
- **Rounding half up:** there are exact-half and just-below-half cases for `bank_transfer` (150 and 149), `card` (1,020 and 1,019) and `pix` (10,100). A change to the rounding offset would fail.
- **Minimum fee of 50:** this is covered at amount 1, just below and exactly at the floor for `card` (760 and 800), and at 1,000 for `pix`.
- **Maximum fee of 5,000:** `card` is tested just below the cap, exactly at it and just above it. Fees of 4,999 and 5,000 are distinguished, so an off-by-one on the cap would fail.
- **Amount limits:** 0, -1, and 1,000,000,000,001 are rejected with `ErrInvalidAmount` and a fee of 0. The extremes 1 and 1,000,000,000,000 are accepted. The largest amount is checked for overflow in the multiplication, which is fine.
- **Validation order:** an invalid amount combined with the unknown method `crypto` must return `ErrInvalidAmount`, and that is tested.
- **Unknown method:** the error text names the method and the fee is 0.

Two small gaps remain. Neither justifies new tests:
- **Cap on `pix` and `bank_transfer`:** only `card` is tested at the cap boundary, except `pix` at the largest amount. The clamp is shared code, so a method-specific bug there is unlikely.
- **Floor on `bank_transfer`:** this can't be reached, because its fixed fee is already 150.

The contract says nothing about case sensitivity or an empty method name, so there is nothing to test there.

VERDICT: adequate
