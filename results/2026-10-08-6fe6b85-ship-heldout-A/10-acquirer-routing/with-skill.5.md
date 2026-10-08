The existing tests did not give enough confidence to ship. I added tests that close the gaps, and the suite now passes.

**What I ran.** The baseline was 11 tests, all passing. Then I applied 38 temporary regressions in an isolated worktree: limit shifts of ±1, the order of the 8-digit and 6-digit lookups, the Luhn check, the digit filter, scheme prefixes, currencies, and default acquirers. Go isn't installed on the host, so everything ran in the `golang:1.27` Docker image. Of the 38, 6 survived the original tests:

- **8-digit entries never tested (documented contract).** I removed the 8-digit lookup, and I swapped it with the 6-digit lookup. Both passed because every fixture had the same acquirer in both tables.
- **Digit filter edges.** Loosening the check to accept `/` or `:` passed, because the only non-digit tested was `?`.
- **Visa leading digit.** Rejecting cards that start with `49` passed, because no Visa card starting with `49` was tested.
- **Luhn `n > 8` instead of `n > 9`.** This is equivalent, since a doubled digit is always even and never 9, so I left it alone.

**What I added to `routing_test.go`.**
- `TestEightDigitEntryWinsOverSixDigitEntry` has different acquirers in the two tables.
- `TestEightDigitEntryWithoutSixDigitEntry` has an 8-digit entry and no 6-digit entry.
- `TestVisaAnyLeadingFour` covers a Visa card starting with `49`.
- Two new invalid-card cases, `:` and `/`, each built so the Luhn check alone would accept the card. The `/` case needed a last digit that makes the Luhn sum valid once the byte wraps to 255.

**Result.** With the new tests, all 38 regressions except the equivalent one are caught, and the original code passes. I ran `gofmt`, `go vet` and `go test ./...` on the real project, and all were clean. I removed the worktree.

**Limits.** I didn't run Necessist or a mutation-testing tool. The 38 regressions were hand-picked, not exhaustive. The contract doesn't say which error wins when several inputs are invalid at once, so I didn't test that.

VERDICT: inadequate
