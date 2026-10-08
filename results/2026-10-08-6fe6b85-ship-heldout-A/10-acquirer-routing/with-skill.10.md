The existing tests did not give enough confidence, so I improved them. The module is correct against `CONTRACT.md`, but the old suite missed a rule the contract states.

**Baseline:** `go test` (golang:1.27 in Docker) passed, and I found no production defect.

**What I tried:** I ran 24 temporary regressions against the unmodified tests, each in an isolated worktree that I removed afterward. They covered:
- The shifted limits (one unit down and one up) on each of the 12/19-digit card length bounds and the 10,000,000 / 5,000,000 amount limits.
- The amount floor, the Mastercard prefix range 51–55, the Mastercard and Amex lengths, and the currency list.
- The Luhn check, separator handling, and the digit check.
- The bin lookups.

Twenty-one were caught. Three survived:

1. **The `bin8` lookup could be deleted and every test still passed.** Setting `binLong` to 7 did the same. Every `bin8` fixture mapped to the same acquirer as its `bin6` entry, so the rule "the `bin8` entry beats the `bin6` entry" was never observed.
2. **The digit check could accept `:`.** The existing invalid-card inputs used `?`, letters or spaces, so the character just above `'9'` was never tried.

**Corrections to `routing_test.go`:**
- **`TestEightDigitEntryWinsOverSixDigitEntry` (new):** gives `bin8` and `bin6` different acquirers, checks that a card with the same 6 digits but a different 8 falls back to `bin6`, and covers a `bin8`-only entry.
- **Invalid-card cases:** added `40000000000:10`.

All three regressions now fail the new tests and pass again once the code is restored. The full suite and `go vet` are green on the restored code.

**Not done:** I didn't run Necessist or a full mutation tool, only the targeted regressions above. The change is applied to the working tree but not committed.

VERDICT: inadequate
