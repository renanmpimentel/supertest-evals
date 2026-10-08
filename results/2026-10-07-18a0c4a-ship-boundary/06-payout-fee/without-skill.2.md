The existing tests protect the documented behavior. I changed nothing, and the suite passes (run in Docker, since Go isn't installed locally).

I checked each case by hand against `CONTRACT.md` and `payouts.go`:

- **Rates:** all three methods are checked on a clean amount, so a wrong percentage or fixed fee would fail.
- **Rounding:** the half-up ties (150 on `bank_transfer`, 10,100 on `pix`) and a case just below the tie are covered.
- **Minimum clamp:** the cases step from a raw fee of 49 up to exactly 50, and `pix` at 1 and 1,000 are covered too.
- **Maximum clamp:** the card cases step from 4,999 to exactly 5,000 and then to a raw fee of 5,001, which clamps down. A very large amount is covered too.
- **Amount limits:** 1 and 1,000,000,000,000 are accepted. 0, -1 and 1,000,000,000,001 return `ErrInvalidAmount`.
- **Error behavior:** the fee is 0 on every error, the unknown-method error names the method, and an invalid amount wins over an unknown method.

The tests don't exercise the cap for `bank_transfer` or the minimum clamp for any method except `pix` and `card`. Both use the same clamp code, so I don't see that as a real risk.

VERDICT: adequate
