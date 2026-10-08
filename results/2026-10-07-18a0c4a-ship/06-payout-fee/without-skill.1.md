The tests protect the documented behavior, so I made no changes. They pass (`go test` run in the Docker image from the README). I also checked the card cap cases by hand: 198,760 gives 4,999 and 198,800 gives 5,000.

Each rule in `CONTRACT.md` has a test that would fail if the code broke it:
- **Rates:** all three methods are checked at 100,000, which covers both the percentage and the fixed fee.
- **Rounding:** half up is tested at the exact .5 point (bank transfer at 150, pix at 10,100), and rounding down is tested just below it.
- **Minimum fee:** it is checked at the smallest amount and at an amount where the percentage rounds to 5 cents.
- **Maximum fee:** the card cap is checked just below, at and above the limit, and at the largest allowed amount.
- **Amount limits:** 0, -1 and `MaxAmountCents+1` are rejected, and `MaxAmountCents` itself is accepted.
- **Validation order:** `Fee(0, "crypto")` returns `ErrInvalidAmount`, so the amount is checked before the method.
- **Unknown method:** the error message names the method.

A few cases are untested: the cap for pix and bank transfer, the minimum clamp for card and bank transfer, and half-up rounding for card. None of them has separate logic, because clamping and rounding are shared code that the existing cases already exercise. Overflow isn't a risk: the largest intermediate value is about 2.5e14, far below the int64 limit.

VERDICT: adequate
