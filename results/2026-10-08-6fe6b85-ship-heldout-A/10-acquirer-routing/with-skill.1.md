The tests did not give enough confidence as shipped. They missed one documented rule, and I added a test for it.

**The gap:** `CONTRACT.md` says an 8-digit BIN entry wins over a 6-digit one. In every existing fixture the two tables gave the same acquirer, so that rule was never actually checked. I ran two regressions against the original tests, and both passed:
- swapping the lookup order so the 6-digit table is checked first;
- deleting the 8-digit lookup entirely.

**The fix:** I added `TestEightDigitEntryTakesPrecedenceOverSixDigit` in `routing_test.go`. Its two tables return different acquirers, so a wrong level gives a visibly wrong answer. It covers four cases: both tables match, only the 6-digit one matches, neither matches, and the default fallback. With the new test:
- swapping the order fails;
- deleting the 8-digit lookup fails;
- changing `binLong` from 8 to 7 fails;
- the restored code passes.

**What was already protected:** I shifted each limit one unit down and one unit up, and every shift was caught:
- card length minimum and maximum (12 and 19);
- the 10,000,000 limit for Visa and Mastercard, and the 5,000,000 limit for Amex;
- the positive-amount check (`<= 0` changed to `< 0`).

**Not run:** I didn't run Necessist or a full application-mutation pass. This was a progressive audit with hand-picked regressions, not a full audit. I also didn't write out a pattern-by-pattern record of which gap patterns apply to this code.

**Final checks:** `gofmt`, `go vet` and `go test ./...` pass in `golang:1.27`. The only change in the working tree is `routing_test.go`, and the temporary worktree is removed.

VERDICT: inadequate
