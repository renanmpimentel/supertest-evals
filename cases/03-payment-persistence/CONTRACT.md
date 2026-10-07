# Contract: payment creation

- `POST /payments` with `{"amount_cents": N}` and `N > 0` saves the payment and responds `201` with `{"id", "amount_cents"}`.
- `201` means the payment is saved and committed: the payment now exists in the database.
- `amount_cents <= 0` or an invalid body responds `400` without saving anything.
