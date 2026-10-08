I ran the existing tests against 14 deliberate bugs in `payouts.go`, and 12 were caught. The other 2 are changes that can't alter the output. The tests as given protect the documented behavior, so I made no changes.

The baseline passes: `go test` in the `golang:1.27` image reported `ok`. I ran each bug in a temporary copy, so the original files are untouched.

**Caught by the tests (each made `go test` fail):**
- Off-by-one on either amount bound (`<= 0` → `< 0`, `> Max` → `>= Max`).
- Wrong rounding constant (5000 → 4999).
- A wrong percentage for any of the three methods.
- A wrong fixed fee for `bank_transfer` or `card`.
- A wrong fee returned alongside an error, for both the amount error and the unknown-method error.
- A wrong clamp value, at the minimum or at the cap.

**Not caught, but equivalent:** the `fee < MinFeeCents` → `<=` and `fee > MaxFeeCents` → `>=` changes. When the fee equals a limit exactly, the clamp returns that same value, so no test could tell them apart. The card cases at 800 and 198,800 sit exactly on those limits.

Every rule in `CONTRACT.md` has a test: percentages and fixed fees, half-up rounding, the 50 and 5,000 clamps, both amount boundaries, the amount-before-method check, the error text naming the method, and a zero fee on every error.

**Not done:**
- I did not run Necessist. The tests have no setup statements for it to remove, so I judged it low value.
- I did not run the other `go test` checks, such as `go vet`.
- I only tried the 14 changes above, not every possible bug.

VERDICT: adequate
