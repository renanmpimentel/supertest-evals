The original tests did not fully protect the documented behavior. I found one gap and fixed it.

**Gap:** the contract says an 8-digit BIN entry takes precedence over a 6-digit one. No test showed that.
- In the fixtures, `visaBin8` and `mastercardBin8` map to the same acquirer in both tables.
- With the `bin8` lookup removed, the original suite still passed, so that mutation survived.
- I added `TestEightDigitEntryWinsOverSixDigitEntry`. It uses a router where the two tables disagree (`delta` for the 8-digit entry, `golf` for the 6-digit one). It also checks that the 6-digit entry is used when no 8-digit entry matches.
- With that test, the `bin8`-removed mutation is caught. So are `bin6`-removed and swapped lookup order.

**What I ran** (in a throwaway worktree, using `golang:1.27` in Docker):
- **Baseline:** the original suite was green.
- **Boundary probes:** I shifted every limit by one unit down and up, and each shift was caught. They covered the card length min and max (12 and 19), the Mastercard prefix range (51 and 55), the three scheme amount limits, and the amount check (`<= 0`). The Amex and Mastercard exact-length checks were also caught.
- **Other mutations:** all were caught. They covered the Luhn doubling threshold and start parity, and removing either Amex prefix (34 and 37).
- **Final checks:** `gofmt`, `go vet` and `go test ./...` pass on the original project with the new test. The test change is uncommitted in `routing_test.go`.

**Limitations:**
- I did not run Necessist.
- I hand-picked the other mutations beyond the required boundary probes, so passing them doesn't prove the suite catches every defect.
- A first batch of runs broke partway because of shell quoting. I reran the affected mutations, and the results above come from those reruns.
- `/tmp/wt` is a pre-existing directory that isn't part of this project, and I left it alone.

VERDICT: inadequate
