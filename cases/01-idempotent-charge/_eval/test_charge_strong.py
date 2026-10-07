from app.payments import ChargeService


class CountingGateway:
    def __init__(self):
        self.calls = []

    def charge(self, amount_cents):
        self.calls.append(amount_cents)
        return f"ch_{len(self.calls)}"


def test_same_key_charges_gateway_once():
    gateway = CountingGateway()
    service = ChargeService(gateway)
    first = service.charge("key-1", 5000)
    second = service.charge("key-1", 5000)
    assert gateway.calls == [5000]
    assert second == first


def test_different_keys_charge_separately():
    gateway = CountingGateway()
    service = ChargeService(gateway)
    a = service.charge("key-1", 5000)
    b = service.charge("key-2", 5000)
    assert gateway.calls == [5000, 5000]
    assert a["id"] != b["id"]
