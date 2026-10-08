Quick status: I ran the baseline and the boundary and mutation probes in a temp copy of the project. The project itself is unchanged.

**Contract:** `CONTRACT.md` sets the rates, half-up rounding, the 50 and 5,000 clamps, amount validation before method, an error naming an unknown method, and a zero fee on every error.

**Baseline:** `go test ./...` in `golang:1.27` passes. The suite is one package with two test functions.

**Boundary probes:** I shifted every limit comparison in `Fee` one unit down and one unit up. Only two shifts survived, and both are equivalent.

| Comparison | Shift | Result |
| --- | --- | --- |
| `fee < MinFeeCents` | −1 | Caught: `card` at 760 gave 49. |
| `fee < MinFeeCents` | +1 | Survived. It only changes fee 50, which clamps to 50 either way, so it is equivalent. |
| `fee > MaxFeeCents` | −1 | Survived. It only changes fee 5000, which clamps to 5000 either way, so it is equivalent. |
| `fee > MaxFeeCents` | +1 | Caught: `card` at 198,840 gave 5,001. |
| `amountCents <= 0` | −1 | Caught: amount 0 was no longer rejected. |
| `amountCents <= 0` | +1 | Caught: amount 1 was rejected. |
| `amountCents > MaxAmountCents` | −1 | Caught: the maximum amount was rejected. |
| `amountCents > MaxAmountCents` | +1 | Caught: amount max+1 was accepted. |

**Other regressions:**
- Caught: the rounding offset set to 4,999, and every rate and fixed fee bumped by one (`pix`, bank percentage and fixed, card percentage and fixed).
- Survived, equivalent: the rounding offset set to 5,001. It only differs when the percentage product ends in 4999 mod 10,000. Every product here is a multiple of 50, so no valid input reaches that.

The error cases are already covered. The tests check amount-before-method order with an invalid amount and an unknown method together. They also check that an unknown method's error text names the method, and that the fee is 0 on every error.

I found no test gap and made no changes. I did not run Necessist or a full mutation tool. The probes above were hand-written, about 15 in all.

VERDICT: adequate
