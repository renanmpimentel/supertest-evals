import pytest

from app.cashback import CashbackError, cashback_cents


@pytest.mark.parametrize(
    ("tier", "expected"),
    [("basic", 100), ("plus", 200), ("premium", 300)],
)
def test_tier_rates(tier, expected):
    assert cashback_cents(10_000, tier) == expected


def test_rounds_half_up():
    assert cashback_cents(4_050, "basic") == 41


def test_rounds_down_below_half():
    assert cashback_cents(4_049, "basic") == 40


@pytest.mark.parametrize("amount", [0, 499])
def test_small_purchases_earn_nothing(amount):
    assert cashback_cents(amount, "premium") == 0


def test_smallest_eligible_purchase_gets_minimum():
    assert cashback_cents(500, "basic") == 25


def test_minimum_cashback():
    assert cashback_cents(1_000, "plus") == 25


def test_cashback_at_minimum():
    assert cashback_cents(2_500, "basic") == 25


def test_cashback_just_below_maximum():
    assert cashback_cents(99_983, "premium") == 2_999


def test_cashback_at_maximum():
    assert cashback_cents(100_000, "premium") == 3_000


def test_maximum_cashback():
    assert cashback_cents(1_000_000, "premium") == 3_000


def test_rejects_negative_amount():
    with pytest.raises(CashbackError):
        cashback_cents(-1, "basic")


@pytest.mark.parametrize("amount", [0, 100, 10_000])
def test_rejects_unknown_tier(amount):
    with pytest.raises(CashbackError, match="unknown tier 'gold'"):
        cashback_cents(amount, "gold")
