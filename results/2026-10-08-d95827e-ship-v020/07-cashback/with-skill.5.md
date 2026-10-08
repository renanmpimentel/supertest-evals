The tests are adequate. Nothing needed changing, and I made no edits to the project.

**Baseline:** the suite passes with 17 tests collected and 17 passed, run with pytest 8.3.3 on Python 3.12 in a `uv` venv. I didn't use the README's docker command.

**Boundary probes:** I ran each regression against the unmodified tests in an isolated git worktree, restoring the code between runs. All the shifts below were caught except the two equivalents:

| Limit | Shift down | Shift up |
| --- | --- | --- |
| `MIN_PURCHASE_CENTS` (500) | caught | caught |
| `MIN_CASHBACK_CENTS` (25) | caught | caught |
| `MAX_CASHBACK_CENTS` (3000) | caught | caught |
| `amount < 0` | caught | caught |
| Rounding offset (`+ 5_000`) | caught | caught |

The two regressions that survived are equivalent mutants:
- **`raw <= MIN_CASHBACK_CENTS`:** when `raw` is exactly 25, both branches return 25.
- **`raw >= MAX_CASHBACK_CENTS`:** when `raw` is exactly 3,000, both branches return 3,000.

**Other contracts:**
- **Rates:** changing the plus rate from 200 to 201 is caught.
- **Error message:** dropping `!r` from the unknown-tier message is caught.
- **Validation order:** the negative-amount and unknown-tier checks are tested at amounts below 500, and the 500-cent floor is tested at its edges.

**Limits of this audit:**
- I ran the boundary probes and a few hand-picked regressions, not a full mutation-testing or Necessist run.
- Rounding is tested only on the `basic` tier. That's acceptable because all tiers share one formula.
- Negative amounts are tested only at -1. A guard that rejected only some negatives would not be caught, and I judged that unlikely.

VERDICT: adequate
