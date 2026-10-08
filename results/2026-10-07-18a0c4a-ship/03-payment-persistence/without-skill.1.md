The original tests did not give enough confidence, so I added tests. All tests now pass, including the new ones.

**What was missing.** The two original tests only checked response codes and the body. The contract has two stronger claims that nothing exercised:
- "`201` means the payment is saved and committed." Nothing queried the database. If the handler had skipped the insert or the commit, the tests would still have passed.
- "`400` without saving anything." Only `amount_cents: 0` was tested, and no test checked that the table stayed empty.

**What I added to `payments_test.go`:**
- **Persistence:** after a `201`, a separate connection finds the row with the same id and amount, which shows it was committed.
- **Unique ids:** 20 requests produce 20 distinct ids and 20 stored rows.
- **Invalid requests:** these return `400` and leave the table empty. The cases are zero, negative, a missing field, malformed JSON, non-JSON, an empty body, a string amount, a fractional amount, `null`, and a JSON array.
- **Boundary:** `amount_cents: 1` is accepted and saved.

**Not covered.** I didn't test the `500` paths, such as a failed insert or commit, and I didn't test non-POST methods (`405`). The contract doesn't specify either.

VERDICT: inadequate
