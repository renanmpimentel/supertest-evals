The existing tests did not protect the documented behavior. They missed one rule: the 8-digit table must win over the 6-digit table.

In the old tests, every card that matched both tables mapped to the same acquirer. That was `delta` for the Visa card and `echo` for the Mastercard. Swapping the two lookups in `routing.go` therefore left every test passing.

I added two tests in `routing_test.go`:
- **`TestEightDigitEntryTakesPrecedenceOverSixDigit`:** the tables disagree for the same card. It covers both-match (8-digit wins), 6-digit only, and neither (scheme default).
- **`TestEightDigitEntryWithoutSixDigitEntry`:** an 8-digit entry with no 6-digit entry.

With the lookup order swapped, the new precedence test fails. With the original code, all tests pass. I restored `routing.go`, so only the test file changed.

The rest of the contract is covered. That includes Luhn, length limits per scheme, scheme prefixes, currencies, amount bounds and inclusive limits, and separator handling.

VERDICT: inadequate
