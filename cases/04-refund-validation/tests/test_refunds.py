from datetime import datetime, timedelta

import pytest

from app.refunds import Payment, RefundError, refund_deadline, refundable_amount, validate_refund

CAPTURED_AT = datetime(2026, 3, 1, 12, 0, 0)


def captured(refunded_cents=0):
    return Payment("pay_1", "captured", 10_000, refunded_cents, CAPTURED_AT)


def test_refundable_amount_subtracts_previous_refunds():
    assert refundable_amount(captured(refunded_cents=2_500)) == 7_500


def test_refund_deadline_is_thirty_days_after_capture():
    assert refund_deadline(captured()) == datetime(2026, 3, 31, 12, 0, 0)


def test_accepts_partial_refund_within_window():
    assert validate_refund(captured(), 4_000, CAPTURED_AT + timedelta(days=1)) == 4_000


def test_accepts_full_remaining_amount():
    assert validate_refund(captured(refunded_cents=2_500), 7_500, CAPTURED_AT) == 7_500


def test_rejects_uncaptured_payment():
    payment = Payment("pay_2", "authorized", 0, 0, None)
    with pytest.raises(RefundError) as error:
        validate_refund(payment, 1_000, CAPTURED_AT)
    assert error.value.code == "not_captured"


@pytest.mark.parametrize("amount", [0, -1])
def test_rejects_non_positive_amount(amount):
    with pytest.raises(RefundError) as error:
        validate_refund(captured(), amount, CAPTURED_AT)
    assert error.value.code == "invalid_amount"


def test_rejects_amount_above_refundable():
    with pytest.raises(RefundError) as error:
        validate_refund(captured(refunded_cents=2_500), 7_501, CAPTURED_AT)
    assert error.value.code == "exceeds_refundable"


def test_rejects_refund_after_window():
    payment = Payment("pay_3", "authorized", 10_000, 0, CAPTURED_AT)
    with pytest.raises(RefundError):
        validate_refund(payment, 1_000, CAPTURED_AT + timedelta(days=31))
