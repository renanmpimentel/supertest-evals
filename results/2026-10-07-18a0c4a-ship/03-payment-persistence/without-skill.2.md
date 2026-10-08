The original tests didn't give enough confidence, so I added tests for the documented behavior. The module passes all of them, so I found no bug.

**What was missing:** the original two tests only checked status codes and the response body. Nothing looked at the database. They would still pass if the handler returned 201 without saving, or saved a payment and then returned 400. Those are the two guarantees `CONTRACT.md` makes. They also covered only `amount_cents: 0`, not negative amounts or malformed bodies.

**What I added to `payments_test.go`:**
- **Persistence:** after a 201, the test closes the database and reopens it. It then checks that the row with the returned ID exists with the right amount.
- **Distinct IDs:** five requests produce five different IDs and five rows.
- **Invalid requests:** each of these returns 400 and leaves zero rows in the table:
  - zero and negative amounts
  - a missing field
  - malformed JSON
  - an empty body
  - a string amount
  - a fractional amount
  - a non-object body

I did not test the 405 for non-POST requests, because the contract doesn't mention it. I also did not test database failures such as a failed insert or commit, which would need fault injection.

All tests pass with `go test` in the golang:1.27 container, and the test file is gofmt-clean.

VERDICT: inadequate
