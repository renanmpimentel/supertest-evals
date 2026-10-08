from app.cashback import cashback_cents


def test_cashback_is_clamped_one_unit_outside_the_limits():
    assert cashback_cents(2_400, "basic") == 25
    assert cashback_cents(100_020, "premium") == 3_000
