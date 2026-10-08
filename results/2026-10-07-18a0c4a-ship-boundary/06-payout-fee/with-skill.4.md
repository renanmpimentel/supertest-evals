The tests give enough confidence. I found no gaps against `CONTRACT.md`, so I changed nothing.

I ran the baseline in the `golang:1.27` Docker image, because Go isn't installed on the host. `go test ./...` passed. I then applied 16 temporary mutations to a copy of `payouts.go` outside the repo and reran the tests for each. The repo is unchanged.

- **Caught (12 of 16):**
  - Each method's percentage and fixed fee.
  - The half-up rounding offset, when lowered to 4,999.
  - The amount validation at 0 and at `MaxAmountCents`.
  - The `MinFeeCents` and `MaxFeeCents` values.
  - A non-zero fee returned alongside an error, for both an invalid amount and an unknown method.
- **Survived, but equivalent (3 of 16):**
  - `fee < Min` changed to `<=`, and `fee > Max` changed to `>=`. At exactly 50 or 5,000 the clamp returns the same value, so no input can tell them apart.
  - The rounding offset raised to 5,001. Every percentage is a multiple of 0.5%, so the remainder before rounding is always a multiple of 50 and never falls between 4,999 and 5,000. No valid input behaves differently.
- **No change (1 of 16):** my `errfee` mutation replaced a line with identical text, so it tested nothing and I discarded it.

I did not run Necessist. The module has one function and no integration surface, and the mutation set covered it.

The tests do not pin down method names that differ only in case or whitespace, such as `"PIX"`. The contract doesn't specify that behavior, so it isn't a gap.

VERDICT: adequate
