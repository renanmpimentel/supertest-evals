The existing tests already protect the documented behavior, so I changed nothing.

**Baseline:** `go test` in `golang:1.27` (Docker, since Go isn't installed on the host) ran 2 tests (`TestFee` and `TestFeeRejectsInvalidInput`), and both passed.

**Regressions:** I ran 20 temporary regressions in an isolated worktree. The original project is untouched, and the worktree and branch are removed.

- **Limits:** I shifted each of the four limits down one and up one: amount ≤ 0, amount > `MaxAmountCents`, fee < `MinFeeCents` and fee > `MaxFeeCents`.
- **Rounding, rates and fixed fees:**
  - Moving the +5,000 rounding constant down by one.
  - Bumping each of the three percentages by one basis point.
  - Bumping each of the three fixed fees by one cent.
- **Clamp and error returns:**
  - The minimum clamp returning 0.
  - The cap clamp returning the unclamped fee.
  - The error paths returning a non-zero fee.

The tests caught 17 of them, and the other 3 are equivalent mutations:
- **`fee < 51`:** a fee of exactly 50 comes out as 50 either way.
- **`fee > 4999`:** a fee of exactly 5000 comes out as 5000 either way.
- **Rounding constant +5,001:** it only differs when the remainder is exactly 4999, and the remainders are always multiples of 50 (50, 100 and 250 basis points). That can't happen.

Gap patterns checked:
- **Validation order:** amount is checked before method; the test covers invalid amount with unknown method.
- **Zero fee on error:** both error paths are asserted to return 0.
- **Fallback/default:** nothing falls back to a default method or rate.
- **Fixture equal to the regression output:** not applicable.

I did not run Necessist or a full mutation-testing tool. Coverage comes from the manual regression set above, which is within the 30-regression budget.

VERDICT: adequate
