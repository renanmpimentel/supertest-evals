The tests are adequate. I checked every case by hand against `CONTRACT.md`, and `go test` passes.

- **Rates:** Each method's percentage and fixed fee is checked at 100,000 cents. A swapped or wrong rate would fail.
- **Rounding:** The cases at 149 and 150 (bank transfer) and 10,100 (pix) separate half-up from floor, ceiling and half-even.
- **Minimum clamp:** Amounts 1, 760, 800 and 1,000 cover fees below and at the 50-cent floor.
- **Maximum clamp:** The card cases at 198,760, 198,770, 198,800 and 198,840 sit on both sides of the 5,000-cent cap, and the largest allowed amount is also checked.
- **Amount limits:** 0, -1, 1,000,000,000,001 and the exact bounds 1 and 1,000,000,000,000 are covered. Overflow isn't a risk, since the largest intermediate value is about 2.5e14.
- **Errors:**
  - The fee is 0 on every error.
  - The amount is validated before the method.
  - The unknown-method message includes the method name.

I found nothing the contract promises that a plausible bug could break without a test failing, so I changed no files.

VERDICT: adequate
