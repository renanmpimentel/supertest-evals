The original tests did not give enough confidence. They passed, but two mutations of the clamp logic went undetected. I added cases to `payouts_test.go` that catch both, and the production code is untouched.

**Gaps found.** I ran the suite in Docker (`golang:1.27`) against hand-made mutations of `payouts.go`.
- **Minimum clamp:** every minimum-fee case was either exactly 50 or far below it. Changing the check to `fee < MinFeeCents-1` was not exercised by a fee of 49, so a 49-cent fee could go out instead of 50. The mutation is `fee < MinFeeCents-1`; the original suite did not catch it, and I did not re-run it on the original suite, so that is inferred from the missing case.
- **Maximum clamp:** nothing tested a fee of 5,001. Changing the check to `fee > MaxFeeCents+1` survived and returned 5,001. I ran that mutation against the original suite and it passed.

**Cases added:**
- Pix 9,800 gives a raw fee of 49 and must be raised to 50.
- Pix 10,000 gives exactly 50.
- Pix 10,300 gives 52.
- Card amount 1 has a fixed fee of 30, which must be raised to 50.
- Bank transfer at 500,000,000 must be capped at 5,000.
- Card 198,840 gives a raw fee of 5,001 and must be capped at 5,000.

**Evidence.** The updated suite passes on the real code. The minimum-clamp mutation now fails. The maximum-clamp mutation survived the first round of new cases, then failed once I added the 5,001 case. Mutating the upper amount bound (`>` to `>=`) and zeroing the fixed fee were already caught by the original tests and still are. The original `payouts.go` is restored.

**Limits.**
- I used a hand-picked set of mutations, not a full mutation or Necessist run.
- The `+5000` rounding offset can't be meaningfully mutated. Every rate's raw product is a multiple of 50 or more, so remainders near 5,000 never occur.
- I did not test that `Fee` returns 0 alongside an error, because `CONTRACT.md` doesn't document it.

VERDICT: inadequate
