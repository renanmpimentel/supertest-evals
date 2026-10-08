The tests already protect the documented behavior, so I changed nothing.

**Baseline:** `go test` in Docker (`golang:1.27`) passes. There are 2 tests, `TestFee` with 18 cases and `TestFeeRejectsInvalidInput`. None fail or are skipped.

**Regressions:** I ran 20 temporary changes to `payouts.go` in an isolated worktree, against the unmodified tests. The 17 that matter were all caught.
- **Amount limits:** I shifted the lower and upper amount limits one unit each way, and all four shifts were caught.
- **Fee limits:** the minimum shifted down and the cap shifted up were both caught.
- **Rounding:** changing the half-up offset from 5000 to 4999 was caught.
- **Rates:** changing any method's percentage or fixed fee was caught.
- **Errors:** returning a nonzero fee on either error path was caught.
- **Order and constant:** validating the method before the amount was caught, and so was changing `MinFeeCents`.

**Survivors:** three changes still passed, and each is equivalent for every valid input.
- Minimum-fee comparison shifted up (`< 51`): a fee of exactly 50 comes out as 50 either way.
- Cap comparison shifted down (`> 4999`): a fee of exactly 5000 comes out as 5000 either way.
- Rounding offset 5001 instead of 5000: the amount times the rate in basis points is always a multiple of 50, so the remainder can never be 4999 and the result never changes.

**Not run:** I did not run Necessist or a full mutation tool, only the targeted probes above. The worktree is removed and the project is clean.

VERDICT: adequate
