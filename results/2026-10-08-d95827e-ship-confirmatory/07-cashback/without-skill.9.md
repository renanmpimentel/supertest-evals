I read `CONTRACT.md`, `app/cashback.py` and `tests/test_cashback.py`. I couldn't run the suite, because this machine has no `pytest` and no `python`. Instead I checked the expected values in the tests by hand against the implementation, and they all match.

Every documented rule has a test, including the edges:

- **Rates:** all three tiers are checked at 10,000 cents.
- **Rounding:** 4,050 gives 41 and 4,049 gives 40, so half-up rounding is pinned on both sides.
- **Purchase threshold:** 0 and 499 give 0, and 500 gives 25. That covers both sides of the 500 boundary.
- **Minimum clamp:** 500 basic and 1,000 plus both raise a raw amount below 25 up to 25. 2,500 basic gives exactly 25.
- **Maximum clamp:** 99,983 premium gives 2,999, 100,000 gives 3,000, and 1,000,000 stays at 3,000.
- **Errors:** a negative amount raises `CashbackError`. An unknown tier raises it with the tier named in the message, at amounts of 0, 100 and 10,000.

I looked for ways the code could break without a test failing and found none that matter. The ones I considered were a wrong rate, a different rounding constant, an off-by-one on either threshold, and either clamp being shifted or removed.

One gap is minor. No test combines a negative amount with an unknown tier, but the contract only requires that an error is raised, and either check raises one. I made no changes.

VERDICT: adequate
