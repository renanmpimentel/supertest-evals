I ran 15 temporary regressions against a copy of the module. The existing suite passes at baseline with 17 tests. It caught 14 of the 15 regressions. I changed nothing in the repo.

The one survivor changes `raw < 25` to `<=` and `raw > 3000` to `>=`. That mutation is equivalent. At the boundary, the clamp returns the same value the raw result already had, so no input can show a difference. It is not a gap in the tests.

The caught regressions cover:
- **Eligibility threshold and negative check:** the 500-cent cutoff and the negative-amount check, each shifted by one.
- **Rate table:** each tier's rate.
- **Rounding:** the half-up offset, and the divisor.
- **Clamp limits:** the minimum and maximum values.
- **Tier check:** inverting it, and the "unknown tier" message wording.

Limits of this check:
- I ran no Necessist pass and no mutation tool, only these hand-written mutations.
- Rounding is tested only for the `basic` tier. All tiers go through the same formula, so I didn't count that as a gap.
- The contract doesn't fix the message for a negative amount, so the tests don't check it.

The suite protects the documented behavior.

VERDICT: adequate
