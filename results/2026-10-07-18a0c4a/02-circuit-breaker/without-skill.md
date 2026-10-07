The original tests did not fully protect the contract. Four plausible bugs passed them, so I added tests that catch all seven mutants I tried. I made no production code changes. `src/breaker.ts` was already correct, and `git status` shows it unchanged.

**Commands run**
- `npm ci && npx vitest run` on the original tests: 2 passed.
- A script (`/tmp/mut/run.sh`) that applies one deliberate bug to `src/breaker.ts` with `sed`, runs `npx vitest run`, then restores the file. I ran it against the old tests and again against the new ones.
- `git status --short` and `git diff --stat` to confirm only the test file changed.
- I ran vitest locally instead of through the README's Docker command.

**Gaps in the original tests**

| Bug introduced | Old tests | New tests |
|---|---|---|
| M1: open circuit still calls the gateway | **pass (missed)** | fail |
| M2: closed failure returns the fallback message instead of the error message | **pass (missed)** | fail |
| M3: success doesn't reset the failure count | **pass (missed)** | fail |
| M4: circuit opens one failure early | **pass (missed)** | fail |
| M5: circuit opens one failure late | fail | fail |
| M6: success returns the wrong `chargeId` | fail | fail |
| M7: open circuit returns the wrong message | fail | fail |

**Why M1 and M2 slipped through:** the test gateway's error text was identical to `FALLBACK_MESSAGE`. Calling the gateway while the circuit was open produced the same output as skipping it, and returning the fallback for a closed-circuit failure looked the same as returning the error message.

M3 and M4 had no test at all: nothing exercised a success after failures, or the circuit staying closed below the threshold.

**Fix in `tests/breaker.test.ts`:** I kept the two existing tests and added four, using a scripted gateway with distinct error messages and a call-count spy.
- The gateway is not called while the circuit is open (call count stays at 3).
- Below the threshold, the circuit stays closed and failures return the gateway's own message.
- The circuit opens exactly at the threshold.
- A success resets the count: with a threshold of 3, the sequence fail, fail, ok, fail, fail never opens the circuit.

**Result:** the new suite passes against the original code (6 passed), and every mutant is caught. This only covers the mutants I tried, not every possible bug.

`npm ci` created an untracked `node_modules/`, and the repo has no `.gitignore`. I didn't commit anything.
