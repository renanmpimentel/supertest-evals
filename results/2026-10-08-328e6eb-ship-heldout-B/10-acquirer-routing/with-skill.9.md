The tests were not enough to ship on. They missed one documented rule: the `bin8` entry beats the `bin6` entry.

**The gap.** Every `bin8` entry in the test fixtures maps to the same acquirer as its `bin6` entry (`delta`/`delta`, `echo`/`echo`). I swapped the lookup order in `routing.go` so `bin6` was checked first. All 11 original tests still passed, so a router that broke the "first match" rule would have shipped unnoticed.

**The fix.** I added `TestEightDigitEntryTakesPrecedenceOverSixDigitEntry` to `routing_test.go`. It uses a router whose `bin8` and `bin6` entries disagree. It covers a Visa and an Amex card matching both tables, plus a card matching only `bin6`.
- With the swapped lookup order, the new test fails on both cards that match both tables.
- With `routing.go` restored, all tests pass and `gofmt` and `go vet` are clean.
- `routing.go` is unchanged. The only modified file is `routing_test.go`, and nothing is committed.

**What I checked and found covered.** I ran the boundary checks by reading the existing cases, not by running shifted-limit regressions, so they are not execution-verified. The rest is rule by rule:
- **Card length:** the tests include 11, 12, 19 and 20 digits, plus wrong lengths for Mastercard and Amex.
- **Mastercard prefix range:** 50, 51, 52, 54, 55 and 56 are all tested.
- **Amex prefixes:** 33 through 38 are all tested.
- **Amount limits:** each scheme is tested at its limit and one above it.
- **Amount positivity:** 0, -1 and 1 are tested.
- **Currency:** the supported and rejected currency codes are tested.
- **Card normalisation:** spaces, hyphens and non-digit characters are tested.

**Limits of this check.** I did not run Necessist or a full mutation sweep. The mutation testing was just the lookup-order swap. `CONTRACT.md` doesn't say which error wins when several inputs are invalid at once, so the tests don't pin that down.

VERDICT: inadequate
