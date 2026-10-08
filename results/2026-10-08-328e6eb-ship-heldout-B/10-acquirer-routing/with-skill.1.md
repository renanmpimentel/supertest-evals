The existing tests were not enough to ship on. They missed one documented rule: the 8-digit BIN entry takes precedence over the 6-digit one. I added tests for it, and the whole suite now passes (13 tests) in the original project.

**The gap.** In the old fixture every `bin8` entry mapped to the same acquirer as its `bin6` entry. So I could disable the `bin8` lookup in `routing.go` and the old suite still passed, and I never tried swapping the lookup order. A change like that would have shipped unnoticed and sent some cards to the wrong acquirer.

**The fix.** I added two tests to `routing_test.go`, using a router where the two tables disagree:
- **Precedence:** when both tables match, the `bin8` acquirer wins. When only `bin6` matches, the `bin6` acquirer is used.
- **`bin8` alone:** a `bin8` entry with no `bin6` entry still routes to its acquirer.

Both the disabled-`bin8` regression and the swapped-order regression now fail the new tests, and the code is restored afterwards.

**Boundary probes.** I shifted every limit in `routing.go` one unit down and one unit up against the existing tests. The tests failed on each shift I checked:
- the card length bounds (12 and 19);
- the Mastercard prefix range (51 to 55);
- the amount floor (> 0);
- the scheme limit (inclusive).

The last shift, the Amex length (15 → 16), was still running when I removed the isolated copy. I saw no result for it. The existing Amex length tests (14 and 16 digits rejected) look like they cover it, but I did not confirm that.

**Not done.** I did not run Necessist or a full mutation tool. Coverage beyond the regressions above is by reading the tests. I did not hand-check Luhn mutations such as the `n > 9` threshold or the digit-character check.

**Checks.** `go test ./... -count=1` runs in Docker (`golang:1.27`), as the README says. The suite passes on the original project. The only change is the uncommitted edit to `routing_test.go`; I have not committed it.

VERDICT: inadequate
