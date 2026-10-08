The original tests were not enough, so I added tests. The module passes the new ones, and the source is unchanged.

**Gap:** the contract says the acquirer is the first match of `bin8`, then `bin6`, then the scheme default. The existing fixtures couldn't check that order. Every card with a `bin8` match also had a `bin6` entry returning the same acquirer, so swapping the two lookups in `routing.go` still passed the whole suite. That is the core routing rule, so the suite could not catch a regression there.

**Added to `routing_test.go`:**
- **`bin8` over `bin6`:** a router whose `bin8` and `bin6` entries disagree. The `bin8` entry must win, and a card matching only the `bin6` entry must fall back to it.
- **`bin8` alone:** a `bin8` entry with no `bin6` entry, and a card with no match falling back to the scheme default.
- **12-digit card:** it still goes through the table lookups.
- **Other whitespace:** a newline, a tab and full-width Unicode digits are rejected as invalid.
- **Mastercard prefixes:** the 53 and 55 prefixes are accepted.

**Check:** I ran the suite through docker, since `go` isn't installed on the host. With the lookup order swapped, the new precedence test fails. With the original code restored, everything passes.

The rest of the contract is already well covered: Luhn, length limits per scheme, scheme prefixes and their boundaries, currencies, amount bounds, per-scheme limits inclusive, and `nil` tables.

VERDICT: inadequate
