The existing tests already protect the documented behavior, so I made no changes. They pass: I ran `go test` in the Docker image from the README, because Go isn't installed locally.

I checked each rule in `CONTRACT.md` against the tests:
- **Rates:** `pix`, `bank_transfer` and `card` each have a case that checks both the percentage and the fixed fee.
- **Rounding:** exact-half and just-below-half cases cover rounding half up. The `pix` 10,100 case rounds up from exactly 50.5, and the `bank_transfer` 150 and 149 cases cover the other side.
- **Minimum fee:** `pix` at amounts 1 and 1,000 are clamped up to 50. The 10,100 case sits just above the clamp, so a change to the minimum would be caught.
- **Maximum fee:** `card` at 198,760 gives 4,999, at 198,800 gives exactly 5,000, and 2,000,000 is capped. The largest allowed amount is also capped.
- **Amount limits:** 0, -1 and 1,000,000,000,001 are rejected, and both limit values (1 and 1,000,000,000,000) are accepted.
- **Validation order:** an invalid amount with an unknown method returns `ErrInvalidAmount`.
- **Unknown method:** the error message names the method.

I also read `payouts.go` and found no overflow or other bugs. Even the largest amount at the highest rate stays well within `int64`.

Two small gaps remain. The maximum fee is only tested for `card` and `pix`, and half-up rounding isn't tested on `card`. All methods share one code path, so neither is a real risk.

VERDICT: adequate
