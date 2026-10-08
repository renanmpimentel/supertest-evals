The existing tests already protect the documented behavior, so I'm calling them adequate. I checked every existing expected value by hand against `CONTRACT.md` and `payouts.go`, and they're all correct.

They cover:
- **Rates:** each method's percentage and fixed fee.
- **Rounding:** half-up rounding, with an exact-half case and a just-below-half case.
- **Clamps:** both ends, tested at the boundary and one step either side.
- **Amount limits:** amounts of 0, -1, and `MaxAmountCents`+1 are rejected, and 1 and `MaxAmountCents` are accepted.
- **Error handling:** the amount is validated before the method, the unknown-method error names the method, and the fee is 0 whenever an error is returned.

The existing suite passes, and so does the suite with my additions.

The gaps were small, so I added two tests in `payouts_test.go`:
- **Boundaries:** the bank_transfer cap boundary (484,900 gives 4,999 and 485,000 gives 5,000), the smallest amount (1) for bank_transfer and card, the max amount for bank_transfer and card, and the pix cap boundary.
- **Method names:** an empty or wrongly cased method name (`""`, `"PIX"`, `"Card"`, `" pix"`) is an unknown-method error rather than `ErrInvalidAmount`, with a fee of 0.

My first draft had two wrong expected values, from my own arithmetic. The code was right, and I corrected the tests.

VERDICT: adequate
