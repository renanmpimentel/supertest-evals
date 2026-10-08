The original tests did not give enough confidence, so I added tests to `payments_test.go`. I ran everything in `golang:1.27` via Docker.

**Why the original two tests fell short.** They passed (2 of 2), but they only checked the HTTP status and response body. Two of the three documented rules were unprotected:
- **`201` means saved and committed.** Nothing read the database. Removing the insert or the commit would have left both tests green.
- **`400` means nothing is saved.** Only `amount_cents: 0` was tested, and only the status code was checked. Negative amounts, malformed JSON, a missing or wrongly typed amount, and the row count were all untested.

**What I added.** The suite now has 5 test functions and 12 runs including subtests, all passing, and `go vet` is clean.
- **Persistence:** reads the database through a separate connection after the request, so only committed rows are visible. It checks the exact id and amount.
- **Smallest valid amount:** `amount_cents: 1` returns `201` and is saved.
- **Rejections:** zero, negative, missing amount, malformed JSON, empty body, a string amount and a fractional amount all return `400` and leave the table empty.
- **Repeated requests:** three requests produce three distinct stored rows.

**Checking the new tests catch real breakage.** I broke the code temporarily in a copy, and the project itself is unchanged. The new tests failed each time:

| Temporary break | Result |
| --- | --- |
| Commit replaced with a rollback | 3 tests fail (no rows persisted) |
| Insert removed | 3 tests fail |
| `<= 0` changed to `< 0` | The rejection tests fail |
| Stored amount off by one | The persistence test fails |

The original tests would have missed the first, second and fourth of these.

**Limits.**
- I did not run Necessist or an automated mutation tool. The checks above were four manual breaks.
- The documented 400 rule covers `amount_cents <= 0` and invalid bodies. Cases like a string or fractional amount rely on Go's JSON decoding rejecting them, which the tests now pin down.
- Behavior the contract doesn't cover is untested: non-POST methods, database errors, and the response `Content-Type` header.

VERDICT: inadequate
