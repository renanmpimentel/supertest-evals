The original tests were not enough to ship on. They passed (11 tests), and every limit I shifted by one was caught. But five regressions to `routing.go` still got through. I added tests for those gaps, and each regression now fails them.

**Boundary probes.** I shifted each limit one unit down and one unit up: the length limits 12 and 19, the visa, mastercard and amex amount limits, the amount > 0 check, and the mastercard prefixes 51 and 55. The original tests caught all of them.

**Regressions the original tests missed:**

| Regression | Contract rule it breaks |
| --- | --- |
| Ignore the `bin8` table | Rule 1 of "Acquirer": the 8-digit entry is looked up first. |
| Check `bin6` before `bin8` | The 8-digit entry must win over the 6-digit one. |
| Treat `/` as a digit (accepted by Luhn through byte wraparound) | Anything that isn't a digit is invalid. |
| Treat `:` as a digit | Same rule. |
| Accept a Luhn sum ending in 5 as well as 0 | Cards must pass the Luhn check. |

The `bin8` gap came from the fixtures. The bin8 and bin6 cards in the test router map to the same acquirer, so the tests could not tell which table answered.

**Tests added to `routing_test.go`:**
- `TestEightDigitEntryTakesPrecedenceOverSixDigit` uses a router where the two tables disagree, and a case with only a `bin8` entry.
- `TestCharactersAdjacentToDigitsAreInvalid` uses Luhn-valid cards containing `/` or `:`.
- `TestOnlyTheLuhnCheckDigitIsAccepted` tries all ten check digits and expects only the correct one to pass.

**Verification.** I ran the regressions in a temporary worktree, which I removed afterwards. After the fixes, the suite, `go vet` and `gofmt` pass on the original project (Docker, golang:1.27). I did not run Necessist or a full mutation tool. I probed by hand, and the Luhn arithmetic was only probed with two regressions.

I made no changes to `routing.go`; none of the tests fail against it.

VERDICT: inadequate
