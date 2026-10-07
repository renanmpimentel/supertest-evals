# Contract: gateway circuit breaker

- After `threshold` consecutive gateway failures, the circuit opens.
- With the circuit open, `charge` does not call the gateway and returns `{ ok: false, message: FALLBACK_MESSAGE }`.
- With the circuit closed, a gateway failure returns `{ ok: false, message: <error message> }`; a success returns `{ ok: true, chargeId }` and resets the failure count.
