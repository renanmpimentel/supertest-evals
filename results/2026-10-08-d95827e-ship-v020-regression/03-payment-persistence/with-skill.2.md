The existing tests were not adequate. I added tests to `payments_test.go` and they now catch the defects the originals missed.

**What was wrong**
- The two original tests checked only the status codes and the response body. They never looked in the database, so nothing tested the contract's rule that `201` means the payment is saved and committed.
- The `<= 0` limit was checked only at `0`. Neither `-1` nor `1` was tried.
- Invalid bodies were never tested, and no test checked that a `400` saves nothing.

**What I added** (`payments_test.go`)
- **Persistence:** a test that reads the row through a separate connection, so it only sees committed data.
- **Amount boundaries:** `0` and `-1` must return `400` and save no rows. `1` and `2` must return `201` and save one row.
- **Invalid bodies:** malformed JSON, an empty body, `{}` and a string amount must each return `400` with zero rows saved.

**Evidence** (Go suite run in Docker):
- **Baseline:** the original 2 tests passed.
- **Regressions run:** I ran each regression against the new tests in a temporary worktree.

| Regression | Result |
| --- | --- |
| `<= 0` changed to `< 0` (limit shifted down) | Caught. The original `0` test also failed. |
| `<= 0` changed to `<= 1` (limit shifted up) | Caught, only by the new tests. |
| Commit removed | Caught, only by the new tests. |
| Insert replaced with a no-op | Caught, only by the new tests. |
| Amount validation removed | Caught. |

- **Final check:** on the real code, the suite passes with `go vet` and `gofmt` clean (3 tests added, 5 in total).

**Limitations**
- I did not run Necessist or a full mutation tool. This was a targeted audit of the contract's risk points, so it is not full-audit approval.
- The last restored-code run in the worktree was cut short when I removed the worktree. The final run on the original project covers that case.
- `500` paths (a failed insert or commit) are not tested. The contract doesn't specify them.

VERDICT: inadequate
