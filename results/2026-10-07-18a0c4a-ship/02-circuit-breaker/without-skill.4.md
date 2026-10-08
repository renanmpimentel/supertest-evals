The original tests did not give enough confidence, so I added six tests to `tests/breaker.test.ts`. All 8 tests now pass against the current code. I didn't run mutation checks, so I haven't confirmed the new tests fail when the breaker is broken.

**What was missing**
- **Fallback vs. error:** the failing gateway in the old tests throws a message identical to `FALLBACK_MESSAGE`. The "open" test would therefore pass even if the breaker passed gateway errors straight through.
- **Gateway not called while open:** nothing checked this, and the contract requires it.
- **Closed-circuit failure:** nothing checked that a failure returns the gateway's own error message.
- **Reset on success:** nothing checked that a success resets the failure count.
- **Consecutive failures:** nothing checked that only consecutive failures open the circuit.
- **Threshold boundary:** nothing checked that the circuit stays closed just below the threshold, or that a custom threshold is honoured.

**What the new tests cover**
- A closed-circuit failure returns the gateway's message.
- The circuit stays closed below the threshold and opens exactly at it.
- The gateway call count stays flat while the circuit is open.
- The open circuit returns `FALLBACK_MESSAGE` even when the gateway's own message is different.
- A success in the middle resets the count, so non-consecutive failures never open the circuit.
- A custom threshold of 1 opens after one failure.

**Not covered:** there is no half-open or recovery behaviour, because `CONTRACT.md` doesn't describe any. Once open, the circuit never closes again. That matches the contract as written, but check it's what you intend before shipping.

VERDICT: inadequate
