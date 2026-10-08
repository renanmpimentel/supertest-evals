from app.ledger import Ledger


def test_entries_are_in_timestamp_order_right_after_add():
    ledger = Ledger()
    ledger.add(30, "credit", 100)
    ledger.add(10, "credit", 200)
    ledger.add(20, "debit", 50)
    assert [e.timestamp for e in ledger.entries()] == [10, 20, 30]
