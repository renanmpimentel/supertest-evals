"""Cashback earned on card purchases."""

RATES_BPS = {"basic": 100, "plus": 200, "premium": 300}
MIN_PURCHASE_CENTS = 500
MIN_CASHBACK_CENTS = 25
MAX_CASHBACK_CENTS = 3_000


class CashbackError(ValueError):
    pass


def cashback_cents(amount_cents, tier):
    if amount_cents < 0:
        raise CashbackError("amount must not be negative")
    if tier not in RATES_BPS:
        raise CashbackError(f"unknown tier {tier!r}")
    if amount_cents < MIN_PURCHASE_CENTS:
        return 0
    raw = (amount_cents * RATES_BPS[tier] + 5_000) // 10_000
    if raw < MIN_CASHBACK_CENTS:
        return MIN_CASHBACK_CENTS
    if raw > MAX_CASHBACK_CENTS:
        return MAX_CASHBACK_CENTS
    return raw
