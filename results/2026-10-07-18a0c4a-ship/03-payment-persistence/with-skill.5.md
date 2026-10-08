The original tests did not give enough confidence, so I added tests. The original suite had two tests, and both passed at baseline. They only checked the response code and body, never the database.

**What was missing**
- **Commit:** `201` means the payment is committed and exists in the database, but nothing read the database. A handler that returned `201` without committing would have passed.
- **No save on `400`:** nothing checked that rejected requests save nothing.
- **Inputs:** only `amount_cents: 0` was tested. Negative amounts, a missing amount, malformed JSON, a wrong type, an empty body and the 1-cent boundary were not.

**Tests added to `payments_test.go`**
- `TestCreatePaymentPersistsCommitted` reads the saved row back through a separate DB connection and checks the ID and amount.
- `TestCreatePaymentBoundaryAndInvalid` is a table of cases. For each it checks the status code and the row count from a separate connection.

**Evidence** (Go ran in Docker, `golang:1.27`; each regression was a temporary change in a copy of the project)
- **Normal run:** the original code passes the new suite.
- **`<= 0` changed to `< 0`:** the existing reject test failed. So did the new `zero` and `missing amount` cases.
- **Commit removed:** `TestCreatePaymentPersistsCommitted` failed with "payment not found via independent connection". The `one cent` case failed with `saved rows = 0, want 1`. The original suite would have passed this.
- **Broken INSERT:** this mutant made the handler return `500`, so it shows the suite catches a failing save. It is not a clean test of "insert skipped, still `201`".

I did not run Necessist or a broader mutation tool, so this is a targeted check of the three contract rules only. I also did not run the full suite after restoring the copies. The changes are in the working tree, uncommitted.

VERDICT: inadequate
