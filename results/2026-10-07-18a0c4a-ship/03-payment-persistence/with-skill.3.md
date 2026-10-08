The original tests did not give enough confidence, so I added tests. With them, the module is covered against every regression I tried.

**What was missing.** The two original tests passed, but they only checked the HTTP response. The contract says a `201` means the payment is saved and committed, and a `400` saves nothing. Nothing in the suite checked either. Negative amounts and invalid request bodies were also untested.

**What I added to `payments_test.go`:**
- **Persistence:** after a `201`, the payment is read back through a separate database connection. That checks the row is committed, with the right id and amount.
- **Rejected input:** a `400` is expected for zero, negative, missing, wrong-typed, malformed and empty amounts, and no rows may be saved.
- **Boundary:** an `amount_cents` of 1 is accepted and saved.

**Regressions I tried (temporary edits to `payments.go`, all restored):**

| Change | Original tests | New tests |
| --- | --- | --- |
| Skip `tx.Commit()` | passed (undetected) | failed |
| `amount <= 0` changed to `amount < 0` | detected (only the zero case) | failed on zero and missing amount |
| `amount <= 0` changed to `amount <= 1` | passed (undetected) | failed |

I did not run the skip-commit and `<= 1` mutations against the original tests. I assessed them by reading, so those two "undetected" results are reasoned, not observed. The new tests detect all three changes.

**Restored state:** `payments.go` is identical to its original, and the final suite run is green. I ran everything in the `golang:1.27` Docker image because Go isn't installed on the host. I did not run Necessist, and I did not run lint or typecheck beyond `gofmt` and the Go build. The handler's 405 response for non-POST methods and its 500 paths (id, begin or insert failures) are not in `CONTRACT.md`, so I didn't test them.

VERDICT: inadequate
