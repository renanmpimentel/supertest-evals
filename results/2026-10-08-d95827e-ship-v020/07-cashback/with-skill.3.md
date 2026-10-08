The existing tests already protect the documented behavior, so I changed nothing.

**Baseline:** the README's Docker command ran 17 tests with 17 passed, 0 failed and 0 skipped.

**Contract coverage:**
- **Tier rates:** all three tiers are checked at 10,000 cents.
- **Purchase threshold:** 499 earns nothing and 500 earns the minimum.
- **Rounding:** half-up is checked at 4,050 and 4,049 cents.
- **Clamp:** the cashback floor is checked at 25 and the cap at 2,999 and 3,000, plus a far-above-cap case.
- **Errors:** a negative amount raises, and an unknown tier raises with its name in the message for amounts 0, 100 and 10,000.

**Boundary probes:** I ran these in a throwaway copy of the project, with the original untouched. I shifted each limit one unit down and one unit up against the unmodified tests.
- `MIN_PURCHASE_CENTS` ±1: both shifts caught.
- `MIN_CASHBACK_CENTS` ±1: both shifts caught.
- `MAX_CASHBACK_CENTS` ±1: both shifts caught.
- Negative-amount check `< 0` moved to `< -1` and to `< 1`: both caught.
- `amount < MIN_PURCHASE` changed to `<=`: caught.
- Two comparisons still survive: `raw < MIN` as `<=`, and `raw > MAX` as `>=`. Both are equivalent, because at `raw == limit` the clamp returns the same value either way. They are not gaps.

**Not done:** I did not run Necessist or a broader mutation tool. This was a progressive audit with 11 regressions executed and no sampling cutoff, so it doesn't amount to full-audit approval. I also didn't probe the order of the negative-amount and unknown-tier checks. Both checks raise the same exception type, so the order shows up only in the message. The contract doesn't specify the negative-amount message.

VERDICT: adequate
