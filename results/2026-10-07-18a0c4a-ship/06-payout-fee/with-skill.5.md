The existing tests give enough confidence that `Fee` works as `CONTRACT.md` documents. I changed nothing.

**Baseline.** I ran `go test -v ./...` in the `golang:1.27` Docker image, since Go isn't installed on the host. Both tests (`TestFee`, `TestFeeRejectsInvalidInput`) passed.

**Regressions.** I applied 17 temporary regressions to the production code in an isolated copy and ran the suite against each. The tests failed on 14 and passed on 3. The 14 caught:
- **Amount bounds:** `<= 0` changed to `< 0`, `> Max` changed to `>= Max`, `> Max` changed to `> Max+1`.
- **Rounding:** the `+5000` half-up offset changed to `+4999`, and removed.
- **Rates:** each method's percentage and fixed fee, all five values bumped by one.
- **Clamp constants:** `MinFeeCents` and `MaxFeeCents` each changed by one.
- **Clamps:** each clamp's `return` replaced with returning the unclamped fee.

I checked the 3 survivors and none is a gap:
- **`fee <= MinFeeCents` and `fee >= MaxFeeCents`:** these return the same value as the original at the boundary (50 and 5,000), so the behavior is identical.
- **Rounding offset `+5001`:** it only differs when the remainder of `amount × basisPoints` is 4999. Every rate is a multiple of 50 basis points, so that remainder is never 4999 for any valid amount.

**Limits.**
- I ran this as a hand-built set of regressions, not a full mutation or Necessist audit.
- The suite doesn't test the clamp separately for `card` and `bank_transfer`. They share one code path, so I judged that low risk.

I restored everything and the working tree is clean.

VERDICT: adequate
