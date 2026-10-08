The original tests were not enough, so I changed them. The suite passes now. Swapping the lookup order in `routing.go` makes it fail, and I restored `routing.go` afterwards.

**The gap:** the contract says the `bin8` entry beats the `bin6` entry, which beats the scheme default. The test router mapped both tables to the same acquirers (`delta` for Visa, `echo` for Mastercard). A router that checked `bin6` before `bin8` would have passed every test. The Mastercard "bin6" card also matched the `bin8` prefix, so it didn't isolate a 6-digit match.

**Changes (all in `routing_test.go`):**
- The `bin8` entries now map to different acquirers (`golf` and `hotel`), so precedence is observable.
- `mastercardBin6` is now `5555551000000000`. It matches only the 6-digit entry, not the 8-digit one.
- `TestEightDigitEntryIsUsed` now expects `golf` and `hotel`.

I checked the rest of the contract against the existing tests and found nothing else missing. Those tests cover:
- scheme prefixes and their boundaries
- length limits
- Luhn failures and separator handling
- currency case sensitivity
- amount boundaries
- the per-scheme limits

One thing the tests still don't pin down is which error wins when several inputs are bad at once. The contract doesn't specify that, so I left it alone.

VERDICT: inadequate
