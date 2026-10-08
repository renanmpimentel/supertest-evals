The original tests were not enough to ship on. I added tests, and the module now has real coverage.

**What was missing.** The original 2 tests passed on a lot of broken code. Their failing gateway threw the same text as `FALLBACK_MESSAGE`, so they couldn't tell a passed-through error from the fallback. They never checked that the gateway goes uncalled while the circuit is open. They never checked that success resets the count, that 2 failures leave the circuit closed, or that the amount reaches the gateway.

**What I added.** Six tests in `tests/breaker.test.ts`, using a scripted gateway that records its calls. They cover:
- the amount passed to the gateway;
- the gateway's own error message returned while closed;
- the circuit staying closed one failure below the threshold;
- the circuit opening exactly at the threshold, with the gateway not called afterwards;
- a custom threshold;
- a success resetting the failure count.

**Evidence.** The suite passes: 8 of 8 on Node 24.13 with vitest, run locally, not in the Docker command from the README. I then made seven temporary changes to `src/breaker.ts`, one at a time, and restored the file after each. The new suite caught all seven:

| Change to `src/breaker.ts` | Result |
|---|---|
| `>=` changed to `>` | 3 tests failed |
| Threshold shifted up by one | 3 tests failed |
| Threshold shifted down by one | 3 tests failed |
| Failure count no longer reset on success | 1 test failed |
| Error message replaced with the fallback | 1 test failed |
| Open check removed | 1 test failed |
| Wrong amount sent to the gateway | 1 test failed |

I did not run the original 2 tests against these changes, and I did not run Necessist or a mutation tool. `src/breaker.ts` is unchanged.

VERDICT: inadequate
