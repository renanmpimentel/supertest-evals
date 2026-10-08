The original tests did not give enough confidence. I added tests to `tests/breaker.test.ts`, and the suite now has 7 passing tests, up from 2.

**What the original two tests covered.** They covered a success and the fallback after three failures. I checked this by reading the tests, not by running the old suite against each defect. The weaknesses were:
- The failing gateway in the tests threw the same text as `FALLBACK_MESSAGE`. A closed circuit that returned the fallback instead of the gateway's own error message would have passed.
- Nothing checked that the gateway is not called while the circuit is open. The test passed even if the open check was removed, because the failing gateway kept failing and produced the same message.
- Nothing checked that a success resets the failure count, or that the circuit opens exactly at the threshold.
- Nothing checked that the amount reaches the gateway.

**What I added.** The new tests use a gateway that returns scripted results and records its calls:
- A closed-circuit failure returns the gateway's own message.
- The circuit stays closed one failure short of the threshold and opens at the threshold.
- The gateway receives no calls while the circuit is open.
- A success resets the failure count.
- The charge amount is passed through to the gateway.

**Evidence.** I applied six temporary defects to a copy of `src/breaker.ts` and ran the suite against each one. Each defect failed at least one test.

| Defect | Tests failed |
|---|---|
| `>=` changed to `>` | 3 |
| Reset on success removed | 1 |
| Failure message replaced by the fallback | 1 |
| Open check removed | 1 |
| Failure count never incremented | 3 |
| Amount hardcoded to 0 | 2 |

The unmodified source passes all 7 tests. I made the changes in a throwaway copy, which I deleted. The only change in the repo is the test file.

**Limits.** I did not run Necessist or a full mutation-testing tool. The six defects were hand-picked. I ran the tests on the host, not in the Docker command from the README.

VERDICT: inadequate
