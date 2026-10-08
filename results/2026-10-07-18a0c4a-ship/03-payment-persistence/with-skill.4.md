The original tests did not give enough confidence, so I added tests and the new suite now covers the documented behavior.

**Gaps in the original two tests.** They checked only the 201 response, the `pay_` ID prefix and the echoed amount, plus a single 400 for `amount_cents: 0`. Nothing read the database. The contract says 201 means the payment is saved and committed, and that a 400 saves nothing. Neither claim was checked.

**Tests added in `payments_test.go`.** They read the database through a separate connection to the same SQLite file:
- A 201 means the row exists with the right ID and amount.
- `amount_cents: 1` is accepted and saved, which covers the boundary.
- A 400 saves zero rows for these bodies: zero, negative, missing field, malformed JSON, non-JSON, wrong type and an empty body.

**Evidence.** I ran each regression in a temporary copy; `payments.go` itself was not changed.

| Check | Result |
| --- | --- |
| Original suite | passes (baseline) |
| Extended suite on the unchanged code | passes |
| Commit removed | original tests still pass; new persistence and boundary tests fail |
| INSERT neutralised | original tests still pass; new persistence and boundary tests fail |
| Check loosened from `<= 0` to `< 0` | zero-amount test and the new no-save test fail |

The first two regressions pass the original tests, which shows the original suite could not detect a payment that was never saved.

I did not run Necessist or a full mutation-testing tool. I used targeted manual regressions only. The 405 method-not-allowed path and the 500 error paths (ID generation, begin and insert failures) are not covered. The contract doesn't specify them.

VERDICT: inadequate
