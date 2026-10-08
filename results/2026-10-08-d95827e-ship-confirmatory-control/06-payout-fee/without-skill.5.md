The existing tests give enough confidence to ship. I didn't change them. I ran them in the documented Docker command and they pass.

I checked each rule in `CONTRACT.md` against the tests:

- **Rates and fixed fees:** each of the three methods has a case, so a swapped or wrong rate would fail.
- **Rounding:** there are half-up and just-below-half cases for `bank_transfer` and `card`. For `pix`, one case (10,100 → 51) covers half-up.
- **Minimum clamp:** the smallest amount, a `pix` case and a `card` case just under the 50 floor all land on 50.
- **Maximum clamp:** `card` has cases just below, at and just above the 5,000 cap, and the largest allowed amount is covered.
- **Amount validation:** 0, -1 and `MaxAmountCents+1` are rejected with `ErrInvalidAmount`.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`, so the amount is checked first.
- **Unknown method:** the error names the method (`unknown payout method "crypto"`).
- **Fee on error:** the fee is 0 on every error path.

There are a few small gaps. Nothing tests the cap for `bank_transfer`, and `pix` is only checked at the largest amount. The clamp code is shared by all methods, so a bug in it would show up in the `card` cases. I judged those gaps too small to justify more tests.

VERDICT: adequate
