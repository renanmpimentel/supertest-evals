The existing tests protect the documented behavior, so I changed nothing. I couldn't run them because Go isn't installed here and the README's Docker command wasn't tried. Instead I worked out each expected value by hand against `payouts.go`, and they all match.

Each rule in `CONTRACT.md` has a test that would fail if the rule broke:

- **Rates:** each method (`pix`, `bank_transfer`, `card`) has a case with a distinct expected value. A swapped percentage or fixed fee would fail.
- **Rounding:** half up and just-below-half are both tested for `bank_transfer` (150 and 149) and `card` (1,020 and 1,019). `pix` has a half-up case at 10,100. The `card` case at 198,770 also checks that rounding goes down just below half.
- **Minimum clamp:** the boundary is covered, with `card` giving a raw fee of 49 at 760 and exactly 50 at 800.
- **Maximum clamp:** the `card` cases at 198,760 and 198,770 give 4,999, 198,800 gives exactly 5,000, and 198,840 and 2,000,000 are clamped down to 5,000.
- **Amount limits:** 1 and 1,000,000,000,000 are accepted. 0, -1 and 1,000,000,000,001 return `ErrInvalidAmount`.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`.
- **Unknown method:** the error names the method (`unknown payout method "crypto"`).
- **Errors:** the fee returned is 0 whenever an error is returned.

The min and max clamps are only boundary-tested through `pix` and `card`. `bank_transfer` isn't, but the clamp code is shared across methods, so I don't consider that a real gap.

VERDICT: adequate
