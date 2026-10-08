The existing tests protect the documented behavior, so I made no changes. They pass (`ok example.com/payouts`, run via Docker because Go isn't installed locally).

I checked each rule in `CONTRACT.md` against the tests, mentally mutating the code to see whether a test would fail:

- **Rates:** every method has a test with a distinct expected value, so swapping any percentage or fixed fee would fail.
- **Rounding:** half-up and just-below-half are tested for `bank_transfer` and `card`, plus `pix` at 10,100, where the half-cent comes only from the percentage.
- **Minimum clamp:** the `pix` cases at 1 and 1,000, and the `card` cases at 760 and 800, catch a wrong threshold or a wrong comparison.
- **Maximum clamp:** `card` 198,760, 198,770, 198,800, 198,840 and 2,000,000 pin down both sides of the 5,000 cap.
- **Amount bounds:** 0, -1, 1 and 1,000,000,000,000 are tested. So is 1,000,000,000,001, which catches a change from `>` to `>=` on the upper bound.
- **Validation order:** amounts of 0 and 1,000,000,001 with an unknown method must return `ErrInvalidAmount`.
- **Errors:** the unknown-method message must contain the method name, and the fee is 0 on every error path.

Not covered:

- The cap is only tested with `card` and `pix`, not `bank_transfer`.
- Method names are not tested for case or whitespace, such as `PIX`.
- A negative amount with an unknown method is not tested.

All three go through the same code paths as the cases that are tested, so I don't think they raise the risk enough to block shipping.

VERDICT: adequate
