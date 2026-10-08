The existing tests already protect the documented behavior, so I changed nothing. The project is still clean.

**Baseline:** In the `golang:1.27` Docker image, both tests (`TestFee`, `TestFeeRejectsInvalidInput`) passed.

**Audit scope:** I ran 15 regressions against the unmodified tests in an isolated worktree, which I removed afterwards. They covered every limit comparison in `Fee` plus the rounding constant, rates and fixed fees.

**Boundary probes:** I shifted each limit one unit down and one unit up.

| Limit | Down | Up |
| --- | --- | --- |
| `amountCents <= 0` | caught | caught |
| `amountCents > MaxAmountCents` | caught | caught |
| `fee < MinFeeCents` | caught | survived, equivalent |
| `fee > MaxFeeCents` | survived, equivalent | caught |

- **`fee < MinFeeCents+1`:** this only changes the result when the fee is exactly 50, and it returns 50 either way.
- **`fee > MaxFeeCents-1`:** this only changes the result when the fee is exactly 5,000, and it returns 5,000 either way.

**Other regressions:**
- **Caught:**
  - the rounding constant shifted down (`+4_999`);
  - every rate's percentage shifted up by one basis point;
  - the `bank_transfer` and `card` fixed fees shifted up by one cent.
- **Survived, equivalent:** the rounding constant shifted up (`+5_001`). Every rate is a multiple of 50 basis points, so `amount*bp` never ends in 4999 and the result can't differ.

I did not run Necessist or a full mutation tool. The unknown-method error and fee 0, and the amount-before-method validation order, are covered by the tests, but I did not probe them with regressions.

VERDICT: adequate
