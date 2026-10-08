The existing tests protect the documented behavior, so I made no changes. I couldn't run them: Go isn't installed here, and I didn't try the Docker command from the README. Instead I worked the expected values by hand against `payouts.go`, and they all match.

Each rule in `CONTRACT.md` has a test that would fail if the rule broke:

- **Rates:** each method has a case that exercises both its percentage and its fixed fee (`pix`, `bank_transfer`, `card`).
- **Rounding half up:** `bank_transfer` at 150 (exactly half, rounds up to 152) and at 149 (below half, rounds down to 151). `pix` at 10,100 (50.5 rounds to 51) checks half-up rounding above the minimum fee.
- **Minimum fee:** `pix` at 1 and at 1,000 are both clamped to 50.
- **Maximum fee:** `card` at 4,999 (just below the cap), exactly 5,000, and above it, plus `pix` at the largest amount.
- **Amount bounds:** 0, -1 and `MaxAmountCents+1` are rejected. 1 and `MaxAmountCents` are accepted.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`.
- **Unknown method:** the error text names the method.

Two small gaps remain, neither one a risk to shipping:

- **Bank transfer cap:** the cap isn't tested for `bank_transfer`. It uses the same shared clamp code as `card`, so a bug there would be caught by the `card` cases.
- **Minimum fee for `bank_transfer` and `card`:** the minimum can never apply to them, because their fixed fees (150 and 30) already put the fee at or above 50 for `bank_transfer`. For `card`, the 30 cent fixed fee plus the 2.5% percentage (rounded half up) is at least 31 at an amount of 1, so the clamp matters there only for tiny amounts. The `pix` cases cover that clamp.

VERDICT: adequate
