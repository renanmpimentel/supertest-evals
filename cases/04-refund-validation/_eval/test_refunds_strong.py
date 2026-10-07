from datetime import datetime, timedelta

import pytest

from app.refunds import Payment, RefundError, validate_refund

CAPTURED_AT = datetime(2026, 3, 1, 12, 0, 0)
DEADLINE = CAPTURED_AT + timedelta(days=30)


def captured():
    return Payment("pay_1", "captured", 10_000, 0, CAPTURED_AT)


def test_rejects_captured_payment_after_window():
    with pytest.raises(RefundError) as error:
        validate_refund(captured(), 1_000, DEADLINE + timedelta(seconds=1))
    assert error.value.code == "window_expired"


def test_accepts_refund_at_deadline():
    assert validate_refund(captured(), 1_000, DEADLINE) == 1_000
