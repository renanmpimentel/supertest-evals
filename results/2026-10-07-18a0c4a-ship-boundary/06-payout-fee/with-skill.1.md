The tests didn't fully protect the documented behavior, so I added cases to `payouts_test.go`. They pass on the unmodified code, and `payouts.go` is unchanged.

**Baseline:** the suite passed (`go test`, run in `golang:1.27` via Docker). I didn't capture the runner's pass/fail/skip counts, and I didn't run Necessist. My evidence is hand-made mutants, not a full mutation tool.

**Mutants the original tests caught (13 of 15):** the rounding offset, both amount bounds, `MinFeeCents` and `MaxFeeCents`, every percentage and fixed fee, and non-zero fees returned alongside errors.

**Survivors (2):** `fee < Min` to `<=`, and `fee > Max` to `>=`. These are equivalent mutants. At the boundary both branches return the same value, so no test can tell them apart.

**Gaps I found in the original tests:**
- Half-up rounding was only tested for `bank_transfer` and `pix`, not `card`.
- The 5,000 cap and its edge were only tested for `card`, plus `pix` at the maximum amount. Nothing covered the cap for `bank_transfer` or `pix` at ordinary amounts.
- `bank_transfer` with the smallest amount, where the fixed fee dominates, wasn't tested.

**Added cases:**
- `card` half-up and just below half (1,020 → 56, 1,019 → 55).
- `bank_transfer` just below, at and above the cap.
- `pix` just below and at the cap.
- `bank_transfer` at amount 1, which gives 150.

**Evidence for the new cases:**
- A mutant that truncates rounding only for `card` now fails; the original tests would have passed it.
- A mutant that raises the cap threshold (`fee > Max+1`) fails.
- A mutant that lowers the minimum threshold (`fee < Min-1`) fails.
- After restoring, the suite passes again.
- A third, larger rounding mutant didn't compile, so it proves nothing. I replaced it with the simpler `card` truncation mutant above.

I made two mistakes along the way. An early script edited the real `payouts.go` by accident, and I restored it with `git checkout`. One of my new expected values was also wrong (999,900 at 0.50% rounds half up to 5,000, not 4,999), so I changed the case to 999,800.

I did not run lint or typecheck, since the project only documents `go test`.

VERDICT: inadequate
