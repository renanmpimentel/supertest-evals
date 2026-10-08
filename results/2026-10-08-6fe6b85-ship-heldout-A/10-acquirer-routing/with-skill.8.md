The tests were not enough. They missed the rule that the 8-digit `bin8` table wins over the 6-digit `bin6` table. I added a test for it.

**What I ran:** I started from a passing baseline in an isolated worktree, using the Docker `golang:1.27` image. Then I applied 32 temporary regressions to `routing.go`, one at a time, against the unmodified tests. They covered:
- every limit shifted one unit down and one up: card length 12 and 19, the Mastercard and Amex length rules, the three scheme amount limits, and the amount check at 0 and 1;
- the Mastercard prefix edges (51 and 55);
- the Luhn check, separator stripping, digit validation, and currency case.

30 regressions were caught. Two survived, both from the same gap: the "bin8" lookup removed, and the "bin8" lookup disabled.

**The gap:** every fixture maps the 8-digit and 6-digit entries to the same acquirer (`delta` and `delta`, `echo` and `echo`). So the tests passed with the 8-digit table removed. A swapped precedence would also have been invisible.

**The fix:** I added `TestEightDigitEntryTakesPrecedenceOverSixDigit` to `routing_test.go`, using a router whose two tables return different acquirers. It covers four cases: both tables match, only `bin6` matches, only `bin8` matches, and neither matches.

I confirmed it fails when `bin8` is removed and when the lookup order is swapped, and passes once `routing.go` is restored. The final `go vet` and `go test` on the original project pass. The only change there is to `routing_test.go`, and I removed the worktree.

**Not covered:** I did not run Necessist or a mutation tool, so this is targeted regression probing, not a full audit. The contract does not say which error wins when several things are wrong at once, such as a bad currency together with a bad amount, so I did not test that.

VERDICT: inadequate
