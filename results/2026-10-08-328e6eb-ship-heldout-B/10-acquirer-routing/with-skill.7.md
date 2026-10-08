The original tests were not enough to ship on. I found two gaps and fixed both in `routing_test.go`.

I ran 29 mutations against the original tests in a scratch copy, in Docker with `golang:1.27`. The baseline was green, with 11 tests passing. 26 mutations were caught. These cover the 12–19 digit limits, all three scheme amount limits shifted down and up by one, the amount check, the Mastercard and Amex prefix edges, Luhn, and separator and digit handling. The other 3 survived and came from two gaps.

- **bin8 over bin6 precedence:** every `bin8` entry in the test router pointed at the same acquirer as its matching `bin6` entry. Swapping the lookup order, or dropping the `bin8` lookup, still passed, so the documented "first match" rule was unprotected. I added `TestEightDigitEntryTakesPrecedenceOverSixDigitEntry`, which uses conflicting entries. A second card there confirms a `bin8` miss falls through to `bin6`.
- **Visa lengths 14–18:** only 12, 13, 16 and 19 digits were tested. A mutation that rejected 14-digit Visas passed. I added Luhn-valid Visa numbers of lengths 14, 15, 17 and 18 to `TestCardLengthLimits`.

With the new tests, all three survivors fail as they should. The full suite passes with the original `routing.go` untouched.

I didn't run Necessist, and I stopped at 29 hand-picked mutations rather than a full mutation tool run. The changes are uncommitted in the working tree.

VERDICT: inadequate
