The existing tests already protect the documented behavior, so I changed nothing. The original project is untouched and the worktree is removed.

**Baseline:** `go test ./...` in `golang:1.27` passed (`ok example.com/payouts`). I didn't capture a per-test count because the output was only the package summary.

**Boundary probes:** I ran 10 temporary regressions against the unmodified tests. Each shifted a limit or the rounding constant, and the original code was restored and passing afterward.
- **Detected (7):**
  - `amount <= 0` shifted to `<= -1` and to `<= 1`.
  - `amount > Max` shifted to `Max-1` and to `Max+1`.
  - `fee < Min` shifted to `Min-1`.
  - `fee > Max` shifted to `Max+1`.
  - Rounding constant `+5000` shifted to `+4999`.
- **Survived, but equivalent (3):**
  - `fee < MinFeeCents+1`: a fee of exactly 50 is returned as 50 either way, so no valid input changes.
  - `fee > MaxFeeCents-1`: a fee of exactly 5000 is returned as 5000 either way.
  - `+5001` rounding: the percentage product is always a multiple of 50, so the remainder can never be 4999 and the result never changes.

**Contract coverage:**
- Rounding half up and down is covered.
- The amount is validated before the method, and the unknown-method error names the method.
- Every error returns a fee of 0.
- The tests pin the exact minimum and maximum fee transitions and the amount limits, with neighbours on both sides.

**Not run:** I didn't run Necessist or a full mutation tool. The audit was a progressive one with the boundary probes, within the 30-regression budget.

VERDICT: adequate
