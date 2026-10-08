import pytest

from app.ledger import Ledger, LedgerError


def stamps(ledger):
    return [e.timestamp for e in ledger.entries()]


def test_records_entries():
    ledger = Ledger()
    ledger.add(10, "credit", 500)
    ledger.add(20, "debit", 200)
    entries = ledger.entries()
    assert [(e.timestamp, e.kind, e.amount_cents) for e in entries] == [
        (10, "credit", 500),
        (20, "debit", 200),
    ]


def test_new_ledger_is_empty():
    ledger = Ledger()
    assert ledger.entries() == []
    assert ledger.balance() == 0


def test_entries_are_in_timestamp_order():
    ledger = Ledger()
    ledger.add(30, "credit", 100)
    ledger.add(10, "credit", 200)
    ledger.add(20, "debit", 50)
    ledger.close_day()
    assert stamps(ledger) == [10, 20, 30]


def test_same_timestamp_keeps_insertion_order():
    ledger = Ledger()
    ledger.add(5, "credit", 300)
    ledger.add(10, "credit", 100)
    ledger.add(10, "debit", 200)
    ledger.add(10, "credit", 400)
    assert [e.amount_cents for e in ledger.entries()] == [300, 100, 200, 400]


def test_entries_returns_a_copy():
    ledger = Ledger()
    ledger.add(10, "credit", 100)
    ledger.entries().clear()
    assert len(ledger.entries()) == 1


def test_balance_is_credits_minus_debits():
    ledger = Ledger()
    ledger.add(1, "credit", 1_000)
    ledger.add(2, "debit", 300)
    ledger.add(3, "credit", 50)
    assert ledger.balance() == 750


def test_balance_can_be_negative():
    ledger = Ledger()
    ledger.add(1, "debit", 300)
    assert ledger.balance() == -300


def test_close_day_totals():
    ledger = Ledger()
    ledger.add(1, "credit", 1_000)
    ledger.add(2, "debit", 300)
    ledger.add(3, "credit", 50)
    assert ledger.close_day() == {"count": 3, "credits": 1_050, "debits": 300, "balance": 750}


def test_close_day_on_empty_ledger():
    assert Ledger().close_day() == {"count": 0, "credits": 0, "debits": 0, "balance": 0}


@pytest.mark.parametrize("amount", [0, -1, -500])
def test_rejects_non_positive_amount(amount):
    with pytest.raises(LedgerError, match="amount must be positive"):
        Ledger().add(1, "credit", amount)


def test_accepts_the_smallest_amount():
    ledger = Ledger()
    ledger.add(1, "credit", 1)
    assert ledger.balance() == 1


def test_rejects_unknown_kind_naming_it():
    with pytest.raises(LedgerError, match="unknown kind 'refund'"):
        Ledger().add(1, "refund", 100)


def test_rejects_negative_timestamp():
    with pytest.raises(LedgerError, match="timestamp must not be negative"):
        Ledger().add(-1, "credit", 100)


def test_accepts_timestamp_zero():
    ledger = Ledger()
    ledger.add(0, "credit", 100)
    assert stamps(ledger) == [0]


def test_rejected_entries_are_not_recorded():
    ledger = Ledger()
    for args in [(1, "refund", 100), (1, "credit", 0), (-1, "credit", 100)]:
        with pytest.raises(LedgerError):
            ledger.add(*args)
    assert ledger.entries() == []
    assert ledger.balance() == 0
