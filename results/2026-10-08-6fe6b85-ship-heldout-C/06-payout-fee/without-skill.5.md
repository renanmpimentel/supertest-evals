The existing tests already protect the documented behavior, so I changed nothing. They pass (run through Docker, since Go isn't installed locally).

I checked each case's arithmetic against `CONTRACT.md` by hand. They all match the contract and exercise the boundaries it describes:

- **Percentage and fixed fee:** each of the three methods is tested, including that the fixed fee is added after rounding.
- **Rounding:** half-up and just-below-half cases exist for `pix`, `bank_transfer` and `card`.
- **Minimum clamp (50):** `card` is tested at 49 (clamped up) and at exactly 50. `pix` is tested at 1 and at 1,000.
- **Maximum clamp (5,000):** `card` is tested at 4,999, at exactly 5,000, above the cap and well above it. `pix` is tested at the largest amount.
- **Amount limits:** 0, -1 and `MaxAmountCents`+1 are rejected, while 1 and `MaxAmountCents` are accepted.
- **Error handling:** the amount is validated before the method, an unknown method gives an error naming it, and the fee is 0 whenever an error is returned.

The cap and minimum boundaries are only tested on `card` (plus the `pix` extremes). That's acceptable: the clamp logic is shared by all methods, and `bank_transfer` can never fall below the minimum because its fixed fee is 150. A mutation that changed `<` to `<=` in a clamp wouldn't change any result, so it doesn't matter that no test catches it.

VERDICT: adequate
