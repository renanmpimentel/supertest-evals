The tests did not give enough confidence, so I added the missing case. Production code is unchanged, and the suite now passes (`go test`, run in the `golang:1.27` container).

**The gap:** the contract says the amount is validated before the method. The tests only checked that ordering for a too-small amount (`Fee(0, "crypto")`). They never tried an amount above `MaxAmountCents` with an unknown method.

**Proof:** I temporarily moved the upper-bound check to after the method lookup. The original tests still passed with that change. With my new case, the suite fails with `unknown payout method "crypto", want ErrInvalidAmount`. I then restored `payouts.go`, which `git diff` confirms is unchanged.

**What I added** to `TestFeeRejectsInvalidInput` in `payouts_test.go`:
- `Fee(1_000_000_000_001, "crypto")` must return `ErrInvalidAmount`.
- `Fee(-1, "crypto")` must return `ErrInvalidAmount`.

**What I checked and found adequate:** I reviewed the rest by reading the code against `CONTRACT.md`, not by mutating it.
- **Rates:** all three methods are covered.
- **Rounding:** half-up and round-down both have cases.
- **Fee clamps:** the fee is checked just below the cap, at the cap and above it, and the minimum fee is covered.
- **Amount limits:** amounts at 1, 0, the maximum and one above it are covered.
- **Error text:** the unknown-method message is checked.

I did not run Necessist or a broader mutation sweep.

VERDICT: inadequate
