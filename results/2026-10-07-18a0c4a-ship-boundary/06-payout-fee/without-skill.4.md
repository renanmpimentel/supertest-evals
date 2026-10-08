The existing tests already protect the documented behavior, so I made no changes. I checked each case in `payouts_test.go` by hand against `CONTRACT.md` and the code, and `go test` passes in the Docker image from the README.

- **Rates and fixed fees:** `pix`, `bank_transfer` and `card` each have a case whose expected value matches the contract table.
- **Rounding:** exact half rounds up (`bank_transfer` at 150 gives 152, `pix` at 10,100 gives 51). Just under half rounds down (`bank_transfer` at 149). A round-half-down or truncating change would fail these.
- **Minimum fee (50):** it applies at 1, at 1,000 and at 760 (card, raw fee 49). Card at 800 lands exactly on 50.
- **Maximum fee (5,000):** card at 198,760 gives 4,999, at 198,800 gives exactly 5,000, and at 198,840 and above is clamped to 5,000. The largest amount (1,000,000,000,000) is also covered.
- **Amount limits:** 0, -1 and 1,000,000,000,001 are rejected, and the amount maximum itself is accepted.
- **Error behavior:** amount is validated before method, an unknown method returns an error naming it, and the fee is 0 on every error.

The remaining gaps are small and share code with cases that are tested. There is no `card`-specific half-up case. There is no cap case for `pix` or `bank_transfer` other than the largest-amount one. Both go through the same rounding and clamping code, and a regression in either would fail the existing cases. I also didn't see an overflow risk: the largest intermediate value is about 2.5e14, well inside `int64`.

VERDICT: adequate
