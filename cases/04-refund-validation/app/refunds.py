"""Refund validation for captured card payments."""

from dataclasses import dataclass
from datetime import datetime, timedelta

REFUND_WINDOW = timedelta(days=30)


class RefundError(Exception):
    def __init__(self, code):
        super().__init__(code)
        self.code = code


@dataclass(frozen=True)
class Payment:
    id: str
    status: str
    captured_cents: int
    refunded_cents: int
    captured_at: datetime | None


def refundable_amount(payment):
    return payment.captured_cents - payment.refunded_cents


def refund_deadline(payment):
    return payment.captured_at + REFUND_WINDOW


def validate_refund(payment, amount_cents, now):
    if payment.status != "captured":
        raise RefundError("not_captured")
    if amount_cents <= 0:
        raise RefundError("invalid_amount")
    if amount_cents > refundable_amount(payment):
        raise RefundError("exceeds_refundable")
    if now > refund_deadline(payment):
        raise RefundError("window_expired")
    return amount_cents
