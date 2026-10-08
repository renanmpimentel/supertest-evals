The tests give enough confidence. I didn't change any files, and the working tree is still clean.

**Baseline:** I ran the README's Docker command and got 17 passed, 0 failed, 0 skipped. All 17 tests were collected.

**Contract coverage:** the existing tests check every rule in `CONTRACT.md`:
- **Tier rates:** all three tiers.
- **Eligibility edge:** 499 earns nothing and 500 earns something.
- **Rounding:** half up (4,050 gives 41) and just below half (4,049 gives 40).
- **Clamps:** both the 25 minimum and 3,000 maximum, at the exact edge and one step inside it.
- **Errors:** a negative amount, and an unknown tier at amounts below and above 500, including the message that names the tier.

**Mutation check:** I applied 13 temporary one-line changes to a throwaway copy in Docker and ran the suite against each. I did not run Necessist.
- **Caught (10):**
  - the negative-amount boundary, both ways (`< -1` and `<= 0`);
  - the 500 boundary (`<=`);
  - rounding offset 4,999 and 0;
  - the plus and premium rates;
  - the max and min constants.
- **Survived (3):**
  - **Rounding offset 5,001:** it can't change a result, because every amount × rate is a multiple of 100.
  - **`<=` instead of `<` in the two clamp comparisons:** they return the same value at the boundary.
  - **`tier.lower()`:** the contract says nothing about tier-name case.

None of the survivors violates the contract.

**Limitations:** half-up rounding is only tested on the basic tier. The negative-amount error is only tested with `basic`.

VERDICT: adequate
