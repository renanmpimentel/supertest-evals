The original tests did not give enough confidence, so I improved them. Production code is unchanged and restored. Only `payments_test.go` changed.

**What was wrong:** There were two tests. One checked the 201 status, the `pay_` ID prefix and the echoed amount. The other checked that `amount_cents: 0` gives 400. Neither read the database. The contract's central claim is that a 201 means the payment is saved and committed, and nothing checked it. Nothing checked that a 400 saves nothing, and negative amounts, malformed bodies and the `amount_cents: 1` boundary were never tried.

**What I added:**
- `TestCreatePaymentPersistsCommitted` posts a payment, then looks for that row, with the right amount, through a second, independent database connection.
- `TestCreatePaymentBoundaryAndRejections` runs these cases, and each one also checks the saved row count:

  | Case | Expected |
  |---|---|
  | `amount_cents: 1` | 201, one row saved |
  | `0` | 400, nothing saved |
  | `-1` | 400, nothing saved |
  | malformed JSON | 400, nothing saved |
  | empty body | 400, nothing saved |
  | string amount | 400, nothing saved |
  | `{}` | 400, nothing saved |

**Evidence:** I ran `go test ./...` in the `golang:1.27` container. The baseline was 2 passed. After my changes everything passes. I then broke `payments.go` three ways and restored it each time:

| Temporary change to `payments.go` | Original tests | New tests |
|---|---|---|
| Skip `tx.Commit()` (still returns 201) | would pass, since they never read the database | fail: the row is missing |
| `<= 0` changed to `< 0` | the zero-amount test already fails | fails on the zero and missing-field cases |
| `<= 0` changed to `== 0` | would pass | fails on the negative case |

The original tests would pass on the commit and negative-amount changes because they never look at the database or send a negative amount. I reasoned that from the code and did not run them against those two changes.

**Limitations:**
- I did not run Necessist or a full mutation-testing tool.
- The non-POST 405 path and the 500 error paths are not in the contract, so I did not test them.
- The mutation checks were hand-picked, not exhaustive.

VERDICT: inadequate
