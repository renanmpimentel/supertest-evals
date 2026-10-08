The original tests were not enough to ship on. I added tests, and they now cover the documented behavior.

**What was wrong:** the original suite had 2 tests, both passing. The mock gateway threw the same text as `FALLBACK_MESSAGE`, so a breaker that never opened would have passed. They also never checked that the gateway is skipped while the circuit is open, that the success reset works, or the closed-circuit error message. The exact open-at-threshold boundary was untested too.

**What I added to `tests/breaker.test.ts`:**
- A closed-circuit failure returns the gateway's own error message.
- The circuit opens exactly at the threshold and not before, and a custom threshold is honored.
- While open, the gateway is not called (checked with a call counter) and the fallback is returned.
- A success resets the count, so only consecutive failures open the circuit.

**Evidence:** the suite went from 2 passed to 7 passed. I then ran temporary changes to `src/breaker.ts` and restored the file after each one:

| Temporary change | Result |
| --- | --- |
| `>=` changed to `>` | 4 failed |
| failure count never reset | 1 failed |
| closed-circuit message replaced by the fallback | 1 failed |
| open-circuit check removed | 1 failed |
| failure count incremented by 2 | 4 failed |

The source is restored and the suite is back to 7 passed.

**Not done:** I did not run Necessist or an application mutation tool. This was a manual set of five regressions, not a full audit. I ran the tests with the host's npm and vitest, not the Docker command in the README.

VERDICT: inadequate
