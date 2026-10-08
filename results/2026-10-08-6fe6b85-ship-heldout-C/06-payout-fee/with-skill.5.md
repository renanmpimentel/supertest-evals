The existing tests give enough confidence that `Fee` works as `CONTRACT.md` documents it, so I changed nothing.

**Baseline:** `go test ./...` in `golang:1.27` passed. I ran everything in a temporary git worktree, which I've since removed. The project is untouched.

**Regressions run (16):** I applied each one to `payouts.go` against the unmodified tests. 13 failed as they should, and 3 passed.
- **Amount limits:** shifting the `<= 0` check and the `MaxAmountCents` check, up and down, was caught every time.
- **Fee floor and cap:** shifting `MinFeeCents` down and `MaxFeeCents` up was caught.
- **Rounding:** shifting the half-up offset down (`+4_999`) was caught.
- **Rates:** changing the bank-transfer fixed fee, the pix percentage, the card percentage and the card fixed fee was caught.
- **Zero fee on error:** returning a non-zero fee on an invalid amount was caught.

**The 3 that passed are equivalent, not gaps:**
- **`fee < MinFeeCents+1`:** a raw fee of exactly 50 returns 50 either way.
- **`fee > MaxFeeCents-1`:** a raw fee of exactly 5,000 returns 5,000 either way.
- **Rounding offset `+5_001`:** the percentage product is always a multiple of 50 and never ends in 4999, so it can't change a result.

**Gap patterns:** The tests also cover the cases where a guard hides a bug: amounts at the limits and one unit either side, a raw fee of 49 (card 760) against the floor, and 4,999 and 5,001 (card 198,760 and 198,840) against the cap. They also check that the amount is validated before the method (`0` and `1_000_000_000_001` with `"crypto"`), and that the error message names the method.

**Not run:**
- **Last regression:** the output file doesn't show the result of the final one (`return 1` on the unknown-method error). The worktree was clean afterwards, and I didn't see it reported as passing.
- **Other checks:** I did not run Necessist or a full mutation tool. I did not run lint or typecheck, since the project defines none.

VERDICT: adequate
