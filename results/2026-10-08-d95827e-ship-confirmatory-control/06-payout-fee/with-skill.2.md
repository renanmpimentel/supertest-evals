The existing tests give enough confidence that `Fee` works as `CONTRACT.md` documents. I didn't change anything.

**Baseline:** `go test` in Docker (`golang:1.27`) passes. I didn't record the test counts.

**Boundary probes:** I ran these in a temporary worktree, which I've since removed. I shifted each limit in `payouts.go` one unit down and one unit up and ran the unmodified tests. Six of the eight shifts were caught. The two that survived are equivalent mutations, so they aren't gaps.

| Limit | Shift | Result |
| --- | --- | --- |
| `fee < MinFeeCents` | −1 | Caught: `Fee(760, card)` returned 49, wanted 50. |
| `fee < MinFeeCents` | +1 | Survived, equivalent: a fee of exactly 50 is returned as 50 either way. |
| `fee > MaxFeeCents` | −1 | Survived, equivalent: a fee of exactly 5000 is returned as 5000 either way. |
| `fee > MaxFeeCents` | +1 | Caught: `Fee(198840, card)` returned 5001, wanted 5000. |
| lower amount bound (`<= 0`) | up | Caught: `Fee(1, pix)` was rejected. |
| lower amount bound (`<= 0`) | down | Caught: `Fee(0, crypto)` got the unknown-method error instead of `ErrInvalidAmount`. |
| `amountCents > MaxAmountCents` | −1 | Caught: `Fee(1e12, pix)` was rejected. |
| `amountCents > MaxAmountCents` | +1 | Caught: `Fee(1e12+1, crypto)` got the unknown-method error instead of `ErrInvalidAmount`. |

**Other contract points:**
- Rounding half up is checked on both sides of the half-cent for `bank_transfer`, `card` and `pix`.
- The fixed fees and the 0.50%, 1.00% and 2.50% rates are exercised.
- Amount-before-method validation is covered.
- The error message naming the unknown method is checked.
- A fee of 0 whenever an error is returned is checked.

**Limitations:**
- I didn't run Necessist or a full mutation tool. I stopped at the boundary probes and a reading of the rounding and rate logic.
- I didn't mutate the individual rate table values. Rate and fixed-fee mistakes are protected only by the example cases.
- `pix` and `bank_transfer` are never tested at the minimum or cap. That is the same clamp code `card` already exercises.

VERDICT: adequate
