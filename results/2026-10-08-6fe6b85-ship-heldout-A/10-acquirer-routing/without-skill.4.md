The existing tests did not protect the documented behavior, so I added one that does. The suite is now green, and `routing.go` is unchanged.

**The gap:** The contract says an 8-digit BIN entry wins over a 6-digit one. In the original suite, every `bin8` entry mapped to the same acquirer as its matching `bin6` entry (`41111190` and `411111` both → `delta`, `55555500` and `555555` both → `echo`).

Because of that, I could break the precedence without any test noticing. If `acquirer()` consulted only `bin6`, or checked `bin6` first, the suite would still pass. No test covered a `bin8` entry that has no `bin6` counterpart either.

**The fix:** I added `TestEightDigitEntryTakesPrecedenceOverSixDigit` in `routing_test.go`. It uses a router where the two tables disagree. It checks four cases:
- **Both match:** the 8-digit entry wins.
- **Only the 6-digit entry matches:** the 6-digit entry is used.
- **Only the 8-digit entry matches:** the 8-digit entry is used.
- **A card whose first 6 digits match but whose first 8 digits don't match any `bin8` key:** it falls back to `bin6`.

**Verification:** The suite passes with the new test. I then made `acquirer()` look up the 8-digit prefix in `bin6` instead of `bin8` as a mutation. The new test failed on the both-match and 8-digit-only cases, and the original suite would have passed. I restored `routing.go` afterwards.

**Rest of the contract:** The other rules are covered at their boundaries:
- Luhn check and separator handling.
- Card lengths per scheme: 12/19 for visa, 16 for mastercard, 15 for amex.
- Scheme leading-digit boundaries.
- Currency matching, including the case-sensitivity rule.
- Positive-amount check.
- Per-scheme limits, tested at the limit and one above it.
- The scheme default acquirers.

VERDICT: inadequate
