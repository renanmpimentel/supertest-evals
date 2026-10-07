# Contract: idempotent charge

- `ChargeService.charge(idempotency_key, amount_cents)` charges the gateway and returns `{"id", "amount_cents", "status"}`.
- Two calls with the same `idempotency_key` charge the gateway only once; the second returns the same charge as the first.
- Different keys create different charges at the gateway.
