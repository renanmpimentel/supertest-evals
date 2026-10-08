The existing tests were mostly good but left gaps, so I added cases. The suite passes with them, and the code matches `CONTRACT.md`.

**What was already covered:**
- the three methods' percentage and fixed fees
- half-up rounding at the half-cent boundary
- the minimum clamp, and the cap clamp for `card`
- amount validation, and amount being checked before method
- a returned fee of 0 on error

**What wasn't covered:**
- The cap boundary for `bank_transfer` and `pix`. Only `card` had it, so a wrong cap threshold for those two methods would have passed.
- `bank_transfer` and `card` at `MaxAmountCents`. Only `pix` was tested there.
- The `bank_transfer` smallest amount and the `pix` minimum-fee boundary.
- A negative amount combined with an unknown method.
- A zero fee when the amount and the method are both invalid.
- Method names that are empty or differently cased (`""`, `PIX`, `Card`).

**What I added to `payouts_test.go`:**
- the boundary cases above, for the cap, the minimum and `MaxAmountCents`
- the invalid-amount and unknown-method checks, now also asserting the fee is 0 and that the error names the method

I ran the new cases only against the current code, not against deliberately broken versions of it. The suite passes under `go test` in the `golang:1.27` container.

VERDICT: inadequate
