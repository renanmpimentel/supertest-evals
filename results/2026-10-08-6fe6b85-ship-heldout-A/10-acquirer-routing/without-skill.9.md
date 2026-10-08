The existing tests didn't protect one documented rule, so I added tests for it. The rule is that a `bin8` match takes precedence over a `bin6` match.

**The gap:** in the original fixtures, every card's `bin8` and `bin6` entries pointed to the same acquirer (`delta`/`delta` and `echo`/`echo`). `TestEightDigitEntryIsUsed` therefore passed even if the `bin8` lookup was removed or checked after `bin6`.

**The fix:** I added two tests in `routing_test.go`:
- `TestEightDigitEntryWinsOverSixDigitEntry` uses tables where `bin8` and `bin6` disagree. It covers the cases where both match (`bin8` wins), only `bin6` matches, and neither matches (scheme default).
- `TestEightDigitEntryWithoutSixDigitEntry` covers a `bin8` match with no `bin6` entry.

**Verification:** the suite passes in Docker with golang:1.27. To check the new tests catch the gap, I temporarily swapped the `bin8` and `bin6` lookup order in `routing.go`. The new test failed as expected, and I then restored `routing.go`.

**The rest of the contract:** the existing tests already covered the other documented rules: normalization, Luhn, length boundaries, scheme prefix boundaries, currencies, amount limits at the boundary, and the default acquirers. I didn't mutation-test those.

`gofmt` isn't installed on this machine, so I couldn't format the new test code. Run `gofmt -w routing_test.go` before you commit. The comment alignment in the new table may need it.

VERDICT: inadequate
