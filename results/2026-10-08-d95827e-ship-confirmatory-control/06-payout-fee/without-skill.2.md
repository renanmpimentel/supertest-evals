I read `CONTRACT.md` against `payouts.go` and the tests, and ran `go test ./...` in the Docker image from the README. It passes. I didn't change anything, because I found no gap worth closing.

Each documented rule has a test that would fail if the code broke it:

- **Rates:** all three methods are checked for both percentage and fixed fee. Swapping or mis-keying a rate fails.
- **Rounding:** half-up and just-below-half are each checked for `pix`, `bank_transfer` and `card`. `pix` at 10,100 is an exact 50.5 that must round to 51.
- **Minimum clamp:** a fee just below 50 (49, on `card` at 760) and one exactly at 50 (`card` at 800) both return 50. Amount 1 also returns 50.
- **Maximum clamp:** `card` fees of 4,999, exactly 5,000 and 5,001 sit on either side of the cap. A fee far above the cap and the largest allowed amount are also checked.
- **Amount validation:** 0, -1 and 1,000,000,000,001 are rejected with `ErrInvalidAmount`. The valid edges, 1 and 1,000,000,000,000, are accepted.
- **Validation order:** an invalid amount with an unknown method still returns `ErrInvalidAmount`.
- **Unknown method:** the error text names the method.
- **Errors return a fee of 0:** this is checked for both the amount error and the method error.

I also checked by hand that the expected values in the table follow the contract's formula. The `>` versus `>=` choice in the clamps can't change any result, so there is no mutation to catch there.

Two small things I left alone. No test applies the cap to `bank_transfer`, but it shares the same clamp code as `card`. The contract also doesn't say whether method names are case-sensitive, so there is nothing to test.

VERDICT: adequate
