The original tests did not give enough confidence, so I added six tests to `tests/breaker.test.ts`. All 8 tests now pass (2 original, 6 new). I ran them with the local vitest, which is v5.0.3 rather than the 3.2.7 pinned in `package.json`, so I did not run the pinned version or the README's docker command.

**What was missing:** The original suite had two tests: one success, and "opens after 3 failures". Its fake gateway threw an error whose message was exactly `FALLBACK_MESSAGE`. That meant the open-circuit test would still pass if the breaker never short-circuited and just passed the gateway error through. Nothing checked these contract points:
- **Closed circuit:** a gateway failure returns the gateway's own error message.
- **Open circuit:** the gateway is not called at all.
- **Reset:** a success resets the failure count, so only consecutive failures count.
- **Threshold:** the circuit stays closed just below it and opens exactly at it. This covers a custom threshold and the default of 3.

**What I added:** Each of those points now has a test. They use a scripted gateway that counts calls and returns distinct error messages.

I did not mutation-test the new tests against a deliberately broken breaker. I only ran them against the current, correct code.

VERDICT: inadequate
