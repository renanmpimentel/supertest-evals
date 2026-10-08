The existing tests already protect the documented behavior, so I changed nothing.

**Baseline:** `go test` in the `golang:1.27` Docker image passes. Go isn't installed on the host.

**What I tried:** I applied 16 single-line regressions to an isolated copy of `payouts.go` and ran the unmodified tests against each. Fourteen were caught:
- **Amount validation:** the lower bound (`<= 0`) and the upper bound (`>`), checked both tighter and looser.
- **Rounding:** the half-up constant, changed in both directions.
- **Rates and fixed fees:** each method's percentage and fixed fee.
- **Clamp constants:** `MinFeeCents` and `MaxFeeCents`.
- **Zero fee on error:** the invalid-amount and unknown-method paths each returning a nonzero fee.
- **Minimum clamp:** the clamped branch returning 0 instead of `MinFeeCents`.

**Survivors:** the two that passed (`fee < Min` to `<=`, and `fee > Max` to `>=`) are equivalent mutants. When the fee equals a bound, clamping returns the same value either way, so no test could tell them apart.

**Not run:** Necessist wasn't available, so I didn't run it. This was a targeted manual mutation audit, not a full audit.

The copy is deleted and the working tree is clean.

VERDICT: adequate
