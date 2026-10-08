The tests did not give enough confidence, so I added two tests that close the gap.

**Gap:** No test showed that an 8-digit BIN entry takes precedence over a 6-digit one. Wherever a card matched both tables, the fixtures returned the same acquirer from each (`delta` for Visa, `echo` for Mastercard). I ran three regressions against the original tests, and all three still passed:
- checking the 6-digit table first
- dropping the 8-digit lookup entirely
- keying the 8-digit lookup on 7 digits

**Fix:** I added two tests to `routing_test.go`:
- `TestEightDigitEntryTakesPrecedenceOverSixDigitEntry` uses a router where the two tables disagree for the same card.
- `TestEightDigitEntryMatchesFullPrefixOnly` checks that an 8-digit key only matches the full 8-digit prefix.

All three regressions now fail with the new tests, and the restored code passes `go test`, `go vet` and `gofmt`.

**Already protected:** The following all failed when I shifted the limit one unit each way, so the tests cover them:
- card length 12 and 19
- the Visa and Mastercard amount limit of 10,000,000
- the Amex amount limit of 5,000,000

**Not checked:** I didn't run Necessist or a full mutation-testing sweep. I only ran the boundary shifts and the BIN-table regressions above, and I didn't probe the other parts of the contract with regressions.

VERDICT: inadequate
