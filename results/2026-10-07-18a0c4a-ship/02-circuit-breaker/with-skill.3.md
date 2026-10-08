The original tests did not give enough confidence, so I added tests to `tests/breaker.test.ts`.

**What was wrong with the original two tests:**
- The fake gateway threw the same text as `FALLBACK_MESSAGE`. The "open circuit" test therefore couldn't tell a fallback from a real gateway error. It also never checked that the gateway was left uncalled.
- Nothing tested the contract's reset-on-success rule.
- The threshold was only checked after 3 of 3 failures, so an off-by-one (`>` instead of `>=`) would have passed.
- The closed-circuit failure message wasn't tested.
- The default threshold and the amount passed to the gateway weren't tested.

**What I added (6 tests):**
- The gateway's error message is returned while the circuit is closed.
- The circuit opens exactly at the threshold, not before.
- The gateway call count stays unchanged once the circuit is open.
- The amount is passed through to the gateway.
- A success resets the consecutive failure count.
- The default threshold is 3.

**Evidence:** I ran the suite on the unmodified code and all 8 tests passed. I then applied 7 temporary regressions to `src/breaker.ts` and restored the file after each one. Every regression made at least one test fail:

| Regression | Failing tests |
| --- | --- |
| `>` instead of `>=` | 4 |
| Threshold plus one | 4 |
| Success no longer resets the count | 1 |
| Failures never counted | 4 |
| Open check removed | 1 |
| Wrong fallback message | 2 |
| Default threshold changed to 2 | 1 |

I didn't run the original tests against each regression. By inspection, they would have missed most of them, including the off-by-one threshold, the missing reset and the removed open check.

I did not run Necessist or an automated mutation tool. I ran the baseline with local Node and vitest, not the README's Docker command. `src/breaker.ts` is unchanged. The only modified file is `tests/breaker.test.ts`, and the changes are uncommitted.

VERDICT: inadequate
