The original tests didn't give enough confidence, so I added more. The module's behavior looks correct. The new tests pass, but I didn't run a mutation check, such as removing `Commit` to see them fail.

**What was missing:** the two original tests checked only status codes and the response body. They never looked at the database. The contract's two main guarantees were untested:
- A `201` means the payment is saved and committed.
- A `400` means nothing is saved.

A handler that returned `201` without writing anything would have passed. So would one that wrote a row and then returned `400`. Only `amount_cents: 0` was tried as invalid input.

**What I added to `payments_test.go`:**
- **Persistence:** after a `201`, the row exists with the right id and amount.
- **Commit durability:** the row is still there after closing and reopening the database file.
- **No save on rejection:** the table stays empty for zero, negative, missing, null, string and fractional amounts, malformed JSON, non-JSON text and an empty body.
- **Multiple payments:** three successful posts give three rows, which checks that ids don't collide.

I didn't add a test for the non-POST `405`, since the contract doesn't mention it.

VERDICT: inadequate
