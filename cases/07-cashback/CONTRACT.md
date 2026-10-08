# Cashback rules

`cashback_cents(amount_cents, tier)` returns the cashback earned on a card purchase, in cents.

| Tier | Rate |
| --- | --- |
| `basic` | 1% |
| `plus` | 2% |
| `premium` | 3% |

- Purchases below 500 cents earn no cashback.
- From 500 cents up, the cashback is the tier's rate of the amount, rounded half up to whole cents, then kept between 25 and 3,000 cents, inclusive.
- A negative amount or an unknown tier raises `CashbackError`, whatever the amount; the message for an unknown tier names it.
