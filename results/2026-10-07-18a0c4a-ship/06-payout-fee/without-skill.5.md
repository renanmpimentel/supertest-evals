The tests protect the documented behavior, so I made no changes. I couldn't run them, because `go` isn't installed here and I didn't try the Docker command from the README. Instead I worked through each case by hand against `payouts.go`, and the expected values all come out right (for example, card at 198,760 gives 4,999 and at 198,800 gives 5,000).

Each rule in `CONTRACT.md` has a test that would fail if the rule were broken:

- **Rates:** each method's percentage and fixed fee is checked at 100,000 cents, so a wrong entry in the rates table would fail.
- **Rounding:** the exact-half case (pix at 10,100 gives 51), the case just below half (bank transfer at 149), and the half case with a fixed fee (bank transfer at 150) are all covered.
- **Clamping:** the minimum is covered by pix at 1 and at 1,000. The maximum is covered just below the cap, at the cap, and above it.
- **Amount limits:** 0, -1, 1 and 1,000,000,000,000 are covered, along with 1,000,000,000,001, which must be rejected.
- **Errors:** an invalid amount is rejected before an unknown method is checked, and the unknown-method message names the method.

There are small gaps, but none that would let a realistic mistake through. Card and bank transfer aren't tested at the minimum fee, and bank transfer and pix aren't tested at the cap. The clamp code is the same for every method, and bank transfer can never fall below the minimum because of its 150 fixed fee.

Before shipping, run the README's Docker command once to confirm the suite passes.

VERDICT: adequate
