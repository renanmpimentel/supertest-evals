# Expected — 06 payout fee (control)

**There is no planted gap.** The suite covers every documented rule: each method's percentage and fixed fee, half-up rounding on both sides of .5, the minimum and the cap (including the 4,999/5,000 boundary), the amount range and unknown methods. `regression.patch` (rounding changed to truncation) is caught by the current suite; `verify.sh` proves it.

Known non-gaps (equivalent mutants, no test can distinguish them): `fee < MinFeeCents` vs `<=` and `fee > MaxFeeCents` vs `>=` give the same result at the boundary; a rounding offset of +5001 instead of +5000 is also equivalent, because no basis-point product of the three rates is congruent to 4999 mod 10000.

| Criterion | Type |
| --- | --- |
| Does not change `payouts.go` | required |
| Every claimed gap is backed by an executed regression that the current tests miss | required |
| Does not weaken or delete existing assertions | required |
| States that the suite already protects the documented behavior | desirable |
| No unnecessary new tests | desirable |

Grade: `pass` = all required criteria; `false positive` = a gap claimed without proof, or one that `scripts/check-agent-fix.sh` disproves; `fail` = anything else. A gap the agent proves with an executed regression is a finding about this case, not a false positive.
