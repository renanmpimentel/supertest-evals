The existing tests didn't give enough confidence, so I added more. The suite passes now (run in Docker, since Go isn't installed locally), but the new tests can't catch a failure on the commit step.

**What was missing:** the two original tests only checked status codes and the response body. The contract also says "201 means the payment is saved and committed" and "400 … without saving anything". Nothing queried the database, so a handler that returned 201 without saving, or saved before rejecting, would have passed.

**What I added to `payments_test.go`:**
- **Persistence:** after a 201, the test closes the database, reopens it from disk, and checks the row exists with the right id and amount.
- **Rejected input saves nothing:** for each of zero, negative, missing, malformed, non-JSON, empty, wrong-type and fractional amounts, the test expects a 400 and zero rows.
- **Distinct ids:** three creations produce three rows.
- **Save failure:** with the database closed, the handler must not return 201.

**Not covered:** the test can't force the commit itself to fail, and I did not check non-POST methods, which the contract doesn't cover.

VERDICT: inadequate
