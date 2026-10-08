The original tests did not protect the 8-digit BIN rule, so I strengthened them. The code itself was correct.

**Baseline:** the original suite had 10 tests, all passing (run in `golang:1.27`).

**Gap:** the 8-digit BIN lookup could be broken without any test failing. The fixtures had every `bin8` entry returning the same acquirer as its matching `bin6` entry (`delta` and `echo`). Two of the regressions I ran against the unmodified tests passed:
- Removing the `bin8` lookup entirely passed.
- Making the `bin8` lookup use the first 6 digits passed.

This matches the contract's "first match" order (`bin8`, then `bin6`, then scheme default). It is also a documented rule where a wrong acquirer means a misrouted payment.

**Fix (`routing_test.go` only):**
- The `bin8` entries now return distinct acquirers (`golf` and `hotel`).
- `mastercardBin6` is now a card (`5555560000000001`) that matches only the `bin6` entry `555556`, so the 6-digit-only path is still checked.
- The `bin8` tests now expect `golf` and `hotel`.

**Evidence:** I ran 36 temporary regressions in an isolated worktree. After the fix, these were all caught: `bin8` removed, `bin8` keyed on 6 digits, `bin6` checked before `bin8`, and `bin6` removed.

The other 32 regressions were already caught by the original tests. They covered:
- Limit shifts, one unit down and one unit up, for every limit: the three scheme amount limits, card length 12/19, the `mastercard` and `amex` lengths, the `mastercard` prefix bounds 51/55, and the amount `<= 0` check.
- Luhn and digit-validation changes, and the `amex` prefixes.
- Visa prefix changes.
- Case-insensitive currency matching.

The worktree is removed, and the final run on the real project passes `gofmt`, `go vet` and `go test`.

**Limits:** I used hand-picked regressions only and did not run Necessist or an automated mutation tool. The `go` runner is only available through Docker here.

VERDICT: inadequate
