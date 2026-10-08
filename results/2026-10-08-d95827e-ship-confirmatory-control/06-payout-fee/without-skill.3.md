The tests give enough confidence that `Fee` works as documented, so I made no changes. They pass (`go test` in the golang:1.27 container, as the README describes). I also worked out the expected fee for every table case by hand against `CONTRACT.md`, and each one matches.

Each documented rule has a test that would fail if the rule broke:
- **Rates:** all three methods are checked at 100,000 cents, so a wrong percentage or fixed fee for any method fails.
- **Rounding:** half up and just-below-half are both checked, for bank transfer, card and pix.
- **Floor and cap:** the 50-cent minimum and the 5,000-cent maximum are each tested on both sides of the boundary (card at 760 and 800 cents, and at 198,760, 198,800 and 198,840).
- **Amount limits:** 1 and 1,000,000,000,000 are accepted. 0, -1 and 1,000,000,000,001 return `ErrInvalidAmount`.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`.
- **Unknown method:** the error names the method.
- **Errors:** the fee is 0 whenever an error is returned.

The one thing not tested is the bank-transfer cap, but it uses the same clamp code that the card and pix cap tests already cover.

VERDICT: adequate
