The original tests did not give enough confidence that the module works as documented. I added five tests, and they now catch every defect I tried.

**What the original tests missed.** The two original tests only covered a success and the path where the circuit is open. They were green against code that broke most of the contract. The gateway stub threw a message identical to `FALLBACK_MESSAGE`, so a closed-circuit failure returning the fallback instead of the real error was indistinguishable. Nothing checked that the gateway is skipped while open, that success resets the count, or where the threshold boundary sits.

**What I added** in `tests/breaker.test.ts`:
- A closed-circuit failure returns the gateway's own message.
- The circuit stays closed at `threshold - 1` failures and opens exactly at `threshold`.
- The gateway is not called while the circuit is open.
- A custom threshold and the default of 3 both work.
- A success resets the count, so only consecutive failures open the circuit.

**Evidence.** I ran these in a temporary worktree with the new tests and `src/breaker.ts` temporarily altered. The worktree is removed and the source is unchanged.

| Regression | Result |
| --- | --- |
| Threshold boundary down by one | 4 tests fail |
| Threshold boundary up by one | 5 tests fail |
| `>=` changed to `>` | 5 tests fail |
| Default threshold 2 | 1 test fails |
| Default threshold 4 | 1 test fails |
| No reset on success | 1 test fails |
| Failures never counted | 5 tests fail |
| Fallback message returned instead of the gateway error | 3 tests fail |
| Open circuit still calls the gateway | 1 test fails |

With the original code restored, the suite passes: 7 of 7, up from 2 of 2.

**Not done.** I did not run Necessist or an application mutation tool. The nine regressions above were hand-picked, and the threshold comparison was the only boundary I probed. I ran vitest on the host's Node 24, not in the Docker command from the README, and I didn't run lint or typecheck.

VERDICT: inadequate
