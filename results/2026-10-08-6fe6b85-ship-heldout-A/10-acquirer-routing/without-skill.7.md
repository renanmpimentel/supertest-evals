The existing tests were not enough. They missed one documented rule: a `bin8` entry beats a `bin6` entry.

In the test router, every `bin8` entry mapped to the same acquirer as its matching `bin6` entry (`delta` and `echo`). If `acquirer()` checked `bin6` before `bin8`, every existing test would still pass. That is the rule the module's per-BIN routing depends on.

I added two tests to `routing_test.go`:
- **`TestEightDigitEntryTakesPrecedenceOverSixDigit`:** uses a router where the two tables disagree. It covers four cases: both tables match, so `bin8` wins; only `bin6` matches; both match for a Mastercard; and neither matches, so the scheme default applies.
- **`TestEightDigitEntryWithoutSixDigitEntry`:** checks that a `bin8` entry works when `bin6` has no entry.

`go test ./...` passes in Docker with the new tests. I did not mutate the code to confirm the new tests fail when the lookup order is swapped, but by construction they would: `visaBin8` would return `delta` instead of `golf`.

The other documented rules were already covered:
- Card normalization, and the Luhn check.
- Length limits per scheme.
- Boundaries on the leading digits.
- Supported currencies.
- Positive amounts.
- Per-scheme limits, tested inclusive.

The contract doesn't say which error wins when several things are wrong at once, so I didn't test that.

VERDICT: inadequate
