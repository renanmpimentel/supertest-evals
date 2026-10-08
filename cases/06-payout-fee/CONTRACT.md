# Payout fees

`Fee(amountCents, method)` returns the fee charged on a payout, in cents.

| Method | Percentage | Fixed fee |
| --- | --- | --- |
| `pix` | 0.50% | 0 |
| `bank_transfer` | 1.00% | 150 |
| `card` | 2.50% | 30 |

- The percentage part is rounded half up to whole cents, then the fixed fee is added.
- The result is clamped to at least `MinFeeCents` (50) and at most `MaxFeeCents` (5,000).
- `amountCents` must be between 1 and `MaxAmountCents` (1,000,000,000,000); otherwise `ErrInvalidAmount`.
- The amount is validated before the method.
- An unknown method returns an error naming the method.
- Whenever an error is returned, the fee returned is 0.
