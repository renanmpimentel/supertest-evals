from app.payments import ChargeService


class FakeGateway:
    def charge(self, amount_cents):
        return f"ch_{amount_cents}"


def test_charge_succeeds():
    service = ChargeService(FakeGateway())
    result = service.charge("key-1", 5000)
    assert result == {"id": "ch_5000", "amount_cents": 5000, "status": "succeeded"}


def test_same_key_returns_same_charge():
    service = ChargeService(FakeGateway())
    first = service.charge("key-1", 5000)
    second = service.charge("key-1", 5000)
    assert second["status"] == "succeeded"
    assert second["id"] == first["id"]
