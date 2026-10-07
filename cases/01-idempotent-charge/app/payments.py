"""Charge service with idempotency keys."""


class ChargeService:
    def __init__(self, gateway):
        self._gateway = gateway
        self._by_key = {}

    def charge(self, idempotency_key, amount_cents):
        if idempotency_key in self._by_key:
            return self._by_key[idempotency_key]
        charge_id = self._gateway.charge(amount_cents)
        result = {"id": charge_id, "amount_cents": amount_cents, "status": "succeeded"}
        self._by_key[idempotency_key] = result
        return result
