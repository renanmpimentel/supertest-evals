The existing tests already protect the documented behavior, so I changed nothing. They pass (run through Docker, since Go isn't installed locally).

I checked each rule in `CONTRACT.md` against `payouts_test.go`:

- **Rates:** `pix`, `bank_transfer` and `card` each have a test that fails if either their percentage or their fixed fee changes.
- **Rounding:** half-up and just-below-half cases cover `bank_transfer` and `card`. A `pix` case checks that rounding happens before the minimum clamp.
- **Minimum fee (50):** covered at the smallest amount (1), just below the minimum, and at the minimum.
- **Maximum fee (5,000):** covered just below the cap, exactly at it, just above it, and far above it.
- **Amount limits:** 1 and `MaxAmountCents` are accepted. 0, -1 and `MaxAmountCents+1` return `ErrInvalidAmount`.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`.
- **Unknown method:** the error names the method.
- **Errors return 0:** the returned fee is 0 in every error case.

Two things aren't tested directly: the max-fee cap for `bank_transfer`, and `MaxAmountCents` with a method other than `pix`. Both use the same code path as the cases that are covered, so I don't count them as gaps.

VERDICT: adequate
