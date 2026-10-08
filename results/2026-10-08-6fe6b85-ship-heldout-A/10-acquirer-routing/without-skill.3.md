The original tests were not enough. I added two tests, and the module passes them. I haven't committed anything.

**Gap:** the contract says the 8-digit table entry wins over the 6-digit one. The old tests never checked that. Every 8-digit entry in their fixtures mapped to the same acquirer as its 6-digit entry (`delta`/`delta`, `echo`/`echo`). Swapping the lookup order in `routing.go` made no test fail, so that rule could have broken unnoticed.

**Added to `routing_test.go`:**
- `TestEightDigitEntryTakesPrecedenceOverSixDigit` uses a router whose 8-digit and 6-digit entries disagree. It checks that the 8-digit entry wins when both match, and that the 6-digit entry is used when only it matches.
- `TestEightDigitEntryWithoutSixDigitEntry` checks that an 8-digit entry works with no 6-digit entry, and that a card with no match falls back to the scheme default.

**Verification:** with the lookup reading the 6-digit table first, both new tests failed. I then restored `routing.go`, and the full suite passes.

The rest of the contract was already covered by the original tests:
- **Card number:** normalization, Luhn, the 12–19 length bounds, and the per-scheme lengths.
- **Scheme:** the leading-digit boundaries (50/51/55/56, 33–38).
- **Currency and amount:** supported currencies, positive amounts, and each scheme's limit at and above the boundary.
- **Acquirer:** the scheme defaults.

I had no local `gofmt`. The `gofmt -w` inside the container ran with no errors, but I didn't re-check the formatting afterward.

VERDICT: inadequate
