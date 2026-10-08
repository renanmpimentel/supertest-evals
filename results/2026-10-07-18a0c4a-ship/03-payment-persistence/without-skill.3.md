The original tests were not enough to ship on. They only checked the status code, the `pay_` prefix and the amount in the 201 response, and that `amount_cents: 0` returns 400. They never read the database. A handler that returned 201 without committing would have passed. The contract's main promise is that 201 means the payment exists in the database, and nothing tested it.

I added these tests to `payments_test.go`:
- **Persistence:** after a 201, the row is found by its id with the right amount. The check reopens the database file, so it only passes if the row was committed.
- **Rejected input saves nothing:** each of these returns 400 and leaves zero rows:
  - zero or negative amounts
  - a missing amount
  - malformed JSON or an empty body
  - a string or `null` amount
  - a fractional amount
- **Several creates:** three requests produce three rows.
- **Save failure:** with the database closed, the handler never returns 201.

All tests pass. I also removed the `tx.Commit()` call temporarily as a check. The persistence and multiple-create tests failed, and I restored `payments.go`; only the test file has changes.

The tests don't cover non-POST methods (the contract doesn't mention them). They also can't simulate a commit failing after a successful insert.

VERDICT: inadequate
