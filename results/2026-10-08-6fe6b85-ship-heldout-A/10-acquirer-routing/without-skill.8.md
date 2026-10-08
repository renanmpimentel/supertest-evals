The existing tests did not fully protect the documented behavior, so I added tests for the gaps.

**The gap:** the contract says a `bin8` match beats a `bin6` match, but no test checked that. The test router mapped the same cards to the same acquirer in both tables (`delta`/`delta` and `echo`/`echo`). I ran a mutation that made the router ignore `bin8` entirely, and the original suite would have passed. Shipping that would have sent traffic to the wrong acquirer for any card with a differing `bin8` override.

**Added to `routing_test.go`:**
- `bin8` takes precedence over `bin6` when both match and name different acquirers. The same router also checks that a card with no `bin8` entry falls back to `bin6`.
- A `bin8` entry works when there is no `bin6` entry, and a card with no `bin8` match falls to the scheme default.
- The mastercard prefix boundaries 53 and 55 are accepted. Only 51, 52 and 54 were covered, plus 50 and 56 as rejects.

All tests pass on the unmodified code. With the `bin8` mutation applied, the two new precedence tests fail. I restored `routing.go` afterward, and the only changed file is `routing_test.go`.

The rest of the contract was already covered: Luhn, separators, length limits per scheme, currencies, amount bounds, and per-scheme limits inclusive at the boundary.

The contract doesn't say which error wins when several things are wrong at once (for example a bad currency and a bad amount), so no test pins that order.

VERDICT: inadequate
