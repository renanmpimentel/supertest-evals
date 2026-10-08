The original tests didn't give enough confidence, so I added five and the suite now passes (7 tests).

**What was missing:**
- The only failure test used a gateway error message identical to `FALLBACK_MESSAGE`. A breaker that returned the fallback on every failure would have passed.
- Nothing checked that the gateway isn't called while the circuit is open.
- Nothing checked that a success resets the failure count, or that only consecutive failures count.
- Nothing checked the threshold boundary or a custom threshold.

**What I added:**
- The gateway is not called while the circuit is open.
- A closed-circuit failure returns the gateway's own error message.
- The circuit stays closed below the threshold and opens exactly at it.
- A success resets the failure count.
- A custom threshold is honored.

I didn't change the source, and the new tests found no bugs in it. I ran them in the Docker setup from the README.

VERDICT: inadequate
