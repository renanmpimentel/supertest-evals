The tests were not adequate, so I strengthened them. Production code was correct throughout; `routing.go` is unchanged, and only `routing_test.go` changed.

**Baseline:** the suite passed (11 tests, `go test` in `golang:1.27`). I then applied 21 temporary regressions to the code, running the unmodified tests against each. They covered length limits, the digit check, Luhn, Mastercard prefix 50–56, the amount floor, per-scheme limits, and the 8-digit and 6-digit prefix lengths. 17 were caught. Four got through, and they come from three weaknesses:

1. **8-digit table entry vs 6-digit entry:** the contract says the 8-digit entry wins. The fixtures gave both entries the same acquirer (`delta`, `echo`), so swapping the lookup order passed. Cutting the 8-digit lookup to 7 digits also passed.
2. **Characters just outside `0`–`9`:** the digit check could accept `/` (the character before `0`) or `:` (the character after `9`) and no test noticed. The existing invalid-card cases used `?` and letters, which are nowhere near the boundaries.

**Added to `routing_test.go`:**
- `TestEightDigitEntryWinsOverSixDigitEntry` uses distinct acquirers per table and checks that the 8-digit entry wins and that a card matching only the 6-digit entry falls back to it.
- `TestEightDigitEntryWithoutSixDigitEntry` checks an 8-digit-only router, plus a card sharing only the first 7 digits, which must get the scheme default.
- Two invalid-card cases containing `/` and `:` that pass Luhn under the faulty digit check.

**Verification:** with the new tests, the 7-digit prefix change, the swapped lookup order and the `/` and `:` regressions are each caught. The restored code passes. The final run on the original project is green (13 tests).

**Not done:**
- I ran no Necessist pass.
- I did not probe the order in which errors are reported, because the contract doesn't specify it.
- I did not cover tab or other whitespace in card numbers.

VERDICT: inadequate
The monitor expiring changes nothing. It only watched the mutation run, which had already finished, and I'd already used all of its results.

The verdict in my last message stands:

- The original tests let four regressions through.
- I added tests that catch them.
- The final run on the original project passes.

I have no further work pending.
