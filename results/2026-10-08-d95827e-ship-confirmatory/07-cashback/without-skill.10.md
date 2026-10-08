I read the contract, the implementation and the tests. pytest isn't installed here, so I ran the tests' key cases directly in Python. Their results match the expected values.

The tests cover every rule in `CONTRACT.md`:
- **Rates:** each tier's rate is checked.
- **Rounding:** half-up rounding is checked (4,050 gives 41, 4,049 gives 40), so banker's rounding would fail.
- **Purchase threshold:** 499 earns 0 and 500 earns the 25-cent minimum, so the threshold is pinned on both sides.
- **Minimum and maximum clamps:** both are checked at the boundary and beyond it, for example 2,999 just below the cap and 3,000 at it.
- **Errors:** a negative amount raises `CashbackError`. An unknown tier raises it for several amounts, and the message names the tier.

The remaining gaps are small, and I don't think they change the call. Caps are only tested with `premium`, and one rate test per tier is enough because the logic is shared. A negative amount with an unknown tier raises either way, and the contract doesn't say which message should win.

I made no changes.

VERDICT: adequate
