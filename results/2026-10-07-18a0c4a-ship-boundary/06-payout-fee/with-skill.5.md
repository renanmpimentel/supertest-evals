The tests give enough confidence that `Fee` works as `CONTRACT.md` documents it, so I changed nothing.

I ran the suite in `golang:1.27` via docker (there's no Go on the host). Both tests passed: `TestFee` and `TestFeeRejectsInvalidInput`.

Then I applied 21 temporary changes to `payouts.go` in a scratch copy and re-ran the tests after each one. The changes covered:
- the amount bounds
- the rounding offset
- each method's percentage and fixed fee
- the min and max clamps and their constants
- the "fee is 0 on error" rule

The tests failed on 19 of them. The two that passed (`fee <= MinFeeCents` and `fee >= MaxFeeCents`) can't change any result: at exactly 50 or 5,000 the code returns that same value either way. A change that only nudges the rounding offset up to `+5_001` has the same problem, because every fee amount is a multiple of 50 cents, so no input could tell the two apart.

I didn't run Necessist, so this is a targeted mutation check, not a full audit. The scratch copy was outside the repo, so the working tree is unchanged.

VERDICT: adequate
