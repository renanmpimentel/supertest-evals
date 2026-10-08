The original tests did not give enough confidence. They missed one documented rule, and I added tests for it.

**The gap:** the contract says an 8-digit table entry wins over a 6-digit entry, and nothing tested that.
- In the test router, every card with an 8-digit entry (`visaBin8`, `mastercardBin8`) also had a 6-digit entry that returned the same acquirer (`delta` and `echo`).
- If someone swapped the lookup order, or deleted the 8-digit lookup, every test would still pass.

**What I added to `routing_test.go`:**
- `TestEightDigitEntryTakesPrecedenceOverSixDigit` uses a router where the two tables disagree. It checks that the 8-digit entry wins and that a card with no 8-digit match falls back to the 6-digit entry.
- `TestEightDigitEntryWithoutSixDigitEntry` checks an 8-digit entry on its own, with no 6-digit entry.
- `TestAllMastercardPrefixes` covers prefixes 53 and 55. Before, the Mastercard tests only covered 51, 52, 54 and the 5555 card.

The suite passes with the new tests (`go test ./...` in the Go 1.27 docker image). I did not run a mutation check, so I haven't confirmed that the new precedence test fails when the lookup order is swapped.

The rest of the contract was already covered: Luhn, card length limits, scheme prefixes, currencies, amount limits at the boundary, and separator handling.

VERDICT: inadequate
