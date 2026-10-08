The original tests did not give enough confidence, so I added one test to `routing_test.go`.

**Gap:** the bin8-over-bin6 rule in `CONTRACT.md` was never actually checked. Every bin8 fixture mapped to the same acquirer as its bin6 entry (`visaBin8` and `mastercardBin8` used the same values on both tables). So the `bin8` lookup could be broken without any test failing. I confirmed this by running three temporary regressions against the original tests. All three passed:
- dropping the `bin8` lookup;
- checking `bin6` before `bin8`;
- shortening the `bin8` key to 7 digits.

**Fix:** `TestEightDigitEntryTakesPrecedenceOverSixDigit` uses a router where the 8-digit and 6-digit entries give different acquirers. It covers visa, mastercard and amex, plus a card that matches only the 6-digit entry. With the new test, each of the three regressions fails, and the suite passes again once the code is restored. Final run on the original project: `go test ./...` is ok.

**What held up:** the other probes were caught by the original tests:
- Boundary shifts on the amount limit and the 12/19 card lengths.
- Mastercard prefix range (51–55) and amex prefixes (34/37).
- The Luhn doubling and its subtract-9 step.

I ran one limit shift, the visa amount limit down by one, plus the length shifts and the prefix and Luhn mutations. I did not run the up-shift of the amount limits or the full set of limit shifts. I also did not run Necessist or a full mutation tool. The Go tests ran in Docker (`golang:1.27`), as the README describes. The test run reported only pass or fail, not per-test counts.

VERDICT: inadequate
