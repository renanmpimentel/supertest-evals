Yes, the tests protect the documented behavior, so I changed nothing. They pass (run via Docker, since Go isn't installed locally). I also checked the expected values by hand against `CONTRACT.md`.

What the tests already pin down:
- **Rates:** each of the three methods is checked with its percentage and fixed fee. Pix has no fixed fee, so the fixed-fee part is covered too.
- **Rounding:** an exact half rounds up (150 on bank transfer gives 152), and just below half rounds down (149 gives 151). A half-up case above the minimum fee (pix at 10,100) also fails if the code floors instead of rounding.
- **Clamping:** the smallest amount hits the 50 minimum. Card at 198,760 gives 4,999 (just below the cap), and at 198,800 it gives exactly 5,000. Card at 2,000,000 and pix at the largest amount both clamp to the 5,000 cap.
- **Amount limits:** 0, -1 and 1,000,000,000,001 are rejected, and the largest valid amount is accepted.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`. A valid amount with an unknown method returns an error that names the method.

Not tested, but harmless:
- The cap is only tested on card, and the minimum only on pix. The clamp is shared code, so this doesn't leave a gap.
- Changing `<` to `<=` (or `>` to `>=`) in the clamps would give the same results, so no test could catch it and none needs to.
- Overflow isn't a risk. The largest intermediate value is about 2.5e14, well within `int64`.

VERDICT: adequate
