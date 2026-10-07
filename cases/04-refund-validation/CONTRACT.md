# Refund rules

`validate_refund(payment, amount_cents, now)` runs before a refund is sent to the card network. It returns the amount to refund, or raises `RefundError` whose `code` names the broken rule:

| Rule | `code` |
| --- | --- |
| Only captured payments can be refunded | `not_captured` |
| The amount must be positive | `invalid_amount` |
| Refunds cannot exceed the captured amount minus previous refunds | `exceeds_refundable` |
| Refunds are accepted up to 30 days after capture, inclusive | `window_expired` |

Helpers: `refundable_amount(payment)` and `refund_deadline(payment)`.
