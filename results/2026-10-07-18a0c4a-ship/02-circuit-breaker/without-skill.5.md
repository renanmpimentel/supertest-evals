The original tests did not give enough confidence, so I added five tests. All 7 tests now pass.

**What the original two tests missed:**
- The failing gateway threw the same text as `FALLBACK_MESSAGE`. Returning the raw error instead of the fallback would still have passed.
- Nothing checked that the gateway isn't called while the circuit is open.
- Nothing tested that a success resets the failure count. If it didn't, the breaker would open on any three failures, not three in a row.
- Nothing tested that the circuit stays closed below the threshold, or opens exactly at it.
- Nothing tested that a closed-circuit failure returns the gateway's own error message.
- Nothing tested a custom threshold or the default of 3.

**What I added, in `tests/breaker.test.ts`:**
- A closed-circuit failure returns the gateway's own error message.
- The circuit stays closed below the threshold and the gateway keeps being called.
- The circuit opens exactly at the threshold, returns the fallback, and makes no further gateway calls.
- A success resets the count, so only consecutive failures open the circuit.
- A custom threshold and the default of 3 both behave correctly.

I didn't change `src/breaker.ts`. The module matches the contract, and the new tests pass against it as written.

One thing the contract doesn't cover is how the circuit closes again once it is open. The code never closes it, so it stays open for the life of the instance. I left that untested because the contract doesn't specify it, but it's worth confirming that's intended before you ship.

VERDICT: inadequate
