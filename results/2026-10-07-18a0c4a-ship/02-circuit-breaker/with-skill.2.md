The original tests did not give enough confidence to ship, so I added more and the module now has real coverage of the contract.

**What was missing.** There were only two tests, and both passed even when the code was wrong. I didn't run the original two against mutants. The gaps come from reading them:
- The gateway stub threw the same text as `FALLBACK_MESSAGE`. A breaker that never returned the fallback would still pass.
- Nothing checked that the gateway isn't called while the circuit is open.
- Nothing checked the exact threshold boundary, the default threshold of 3, or a custom threshold.
- Nothing checked that a closed-circuit failure returns the gateway's own error message.
- Nothing checked that a success resets the failure count, so the "consecutive" part of the contract was untested.

**What I changed.** I added six tests to `tests/breaker.test.ts`. They use a scripted gateway that records the amounts it receives. The suite passes 8 of 8 in the Docker command from the README.

**Evidence.** I applied six temporary mutations to `src/breaker.ts`. Each one made at least one test fail. I then restored the file, and `git status` shows only the test file modified.

| Mutation | Tests failed (of 8) |
| --- | --- |
| `>=` changed to `>` | 3 |
| Reset on success removed | 1 |
| Failure count set to 1 instead of incremented | 3 |
| Fallback message changed | 1 |
| Open-circuit check disabled | 1 |
| Amount not passed to the gateway | 1 |

**Limits.** I ran no Necessist or automated mutation tool, only the six hand-picked mutations. There is no lint or typecheck script in the project. Nothing in the contract covers concurrent calls, and a closed circuit never recovers on its own. Neither is tested, because the contract doesn't specify them.

VERDICT: inadequate
