Status: I ran the 17 existing tests, then ran 18 temporary changes to the code in a disposable Docker copy. Your working tree is untouched and still clean.

**Baseline:** 17 passed, 0 failed, 0 skipped, on Python 3.12 with pytest 8.3.3.

**Mutations:** the tests failed on 14 of 18 changes. Each of these broke a documented rule, and the tests caught it:
- the thresholds for negative amounts and for the 500-cent minimum purchase
- the half-up rounding
- all three tier rates
- the 25 and 3,000 clamp values and their return paths
- the unknown-tier message
- the rule that an unknown tier raises even for small purchases

The other 4 changes passed, and none of them is a gap:
- **`+ 5_001` instead of `+ 5_000`:** it behaves identically. Every product is a multiple of 100, so the extra 1 never changes the floor division.
- **`raw <= 25` and `raw >= 3000`:** they return the same value at those exact points, so no behavior differs.
- **Skipping the tier check for negative amounts:** negative amounts still raise `CashbackError`, so the documented outcome doesn't change. A negative amount with an unknown tier raises either way.

I made no changes to the tests. I didn't run Necessist; the mutation results above come from manual changes, not a tool.

VERDICT: adequate
