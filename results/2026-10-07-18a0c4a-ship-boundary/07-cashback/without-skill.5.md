Status: I checked each rule in `CONTRACT.md` against the tests. pytest isn't installed here, so I re-ran the test assertions by hand against the implementation, and they all passed.

The tests cover the documented behavior:
- **Tier rates:** basic, plus and premium are each checked at 10,000 cents.
- **Rounding:** 4,050 gives 41 (the half rounds up) and 4,049 gives 40.
- **500-cent threshold:** 0 and 499 earn nothing, and 500 earns the 25-cent minimum.
- **Minimum and maximum:** 25 is checked from both sides, and so is 3,000 (99,983 gives 2,999, 100,000 gives 3,000, and 1,000,000 gives 3,000).
- **Errors:** a negative amount raises `CashbackError`, and an unknown tier raises it with a message naming the tier. The unknown-tier check runs at both a below-threshold and an above-threshold amount, which is what "whatever the amount" requires.

The boundary tests would catch the usual off-by-one and wrong-rounding mistakes. I didn't find a gap worth adding tests for, so I changed nothing.

The only things not tested directly are cases that follow from the same code paths, such as the maximum cap for basic and plus, or a negative amount combined with an unknown tier. The contract doesn't say which error message wins in that combined case.

VERDICT: adequate
