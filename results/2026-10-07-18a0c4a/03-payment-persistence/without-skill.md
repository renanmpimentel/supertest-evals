The original tests did not protect the contract. I added tests that close the gaps, and the production code is unchanged. All tests pass against the real code. Each deliberately broken copy of the handler now fails them.

## Gaps
`CONTRACT.md` makes three promises. The old tests covered the first one only partly:

| Contract clause | Old tests |
|---|---|
| `201` with `{id, amount_cents}` | Covered (status, `pay_` prefix, amount). |
| `201` means the payment is saved and committed | Not checked. No test ever read the database. |
| `amount_cents <= 0` or an invalid body gives `400` without saving | Only `amount_cents: 0` was tested. Negative amounts, invalid bodies and "nothing saved" were not. |

## Proof
I copied the handler to `/tmp/mut` (outside the repo) and broke it five ways, running the old tests against each:

| Broken copy | Old tests | New tests |
|---|---|---|
| M1: `tx.Commit()` removed, still returns 201 | pass | **fail**: payment not found after 201 |
| M2: the `INSERT` removed, still returns 201 | pass | **fail**: payment not found after 201 |
| M3: check changed to `== 0`, so negatives get 201 | pass | **fail**: status 201, want 400 |
| M4: JSON decode error ignored | pass | **fail**: status 201, want 400 |
| M5: row written on the 400 path | pass | **fail**: rows = 1, want 0 |

M4 survived my first new tests as well. An unparseable body usually leaves the amount at 0, so the `<= 0` check catches it anyway. I added the input `{"amount_cents": 100, "amount_cents": "x"}`, which has a valid amount followed by a type error. That case now catches M4.

## Fix
The only file changed is `payments_test.go`, with 82 lines added:
- `TestCreatePaymentIsPersistedAndCommitted` sends a `201` request. It then opens a second connection to the same database file and checks the row has the returned id and amount. A row that is only visible inside an uncommitted transaction would fail this check.
- `TestCreatePaymentRejectsAndDoesNotSave` covers zero, negative, large negative, a missing amount, malformed JSON, non-JSON, a string amount, an empty body, and the duplicate-key case. For each it expects `400` and zero rows in the database.

## Commands run
Go isn't installed on the host, so everything ran through Docker, as the README describes.
- `docker run --rm -v "$PWD":/work -w /work golang:1.27 go test ./...` gave `ok` for the original tests.
- `bash /tmp/runmut.sh M1 M2 M3 M4 M5` ran the five broken copies. The outputs are in the table above.
- `gofmt`, `go vet ./...` and `go test -v ./...` on the final tests all passed, 12 tests including the subtests.
- `git status` shows only `payments_test.go` modified. I did not commit.
