The tests did not give enough confidence as shipped. They missed one documented rule, the order between the two BIN tables, and I added tests that cover it.

**Baseline.** All 11 tests passed with `go test` in the golang:1.27 Docker image.

**The gap.** The fixtures used the same acquirer for the 8-digit and 6-digit entries (`delta` and `echo`). The documented rule is that the `bin8` entry wins over `bin6`. Two regressions in an isolated worktree still passed all 11 tests:
- Ignoring `bin8` entirely, so every card fell back to `bin6`.
- Changing the 8-digit prefix length to 7 or to 9.

A real regression there would have sent cards to the wrong acquirer.

**What I added to `routing_test.go`.**
- `TestEightDigitEntryTakesPrecedenceOverSixDigitEntry` uses a router whose `bin8` and `bin6` entries name different acquirers. It also checks the cases where only `bin6` matches and where neither does.
- `TestEightDigitEntryWithoutSixDigitEntry` checks a `bin8` entry that has no `bin6` entry.

With the new tests, all three of those regressions now fail the suite. The restored code passes, and `go vet` is clean.

**Boundary probes.** I shifted each limit one unit down and one unit up, and every shift was caught by the existing tests:
- card length bounds (12 and 19);
- the Mastercard length (16) and the Amex length (15);
- the Visa and Mastercard amount limit (10,000,000) and the Amex amount limit (5,000,000);
- the Mastercard prefix range (51 to 55);
- the amount-must-be-positive check.

I also ran `>=` in place of `>` on the amount check, and two Luhn changes. All were caught.

**Limits of the audit.**
- I did not run Necessist or a full mutation tool. The probes were hand-picked.
- My first run of the amount probes silently did not execute because of a shell quoting bug. I reran them and they were caught.
- One probe I wrote (`digits[0] == 52`) was equivalent to the original code, since `'4'` is byte 52, so it proves nothing.
- The contract does not say which error wins when several inputs are bad at once, so no test pins that order.
- The changes are in `routing_test.go` in the original project and are not committed. I removed the temporary worktree.

VERDICT: inadequate
