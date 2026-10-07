# Expected — 03 payment persistence

**Gap:** the test only checks `201` and the body. If the handler does not commit, `defer tx.Rollback()` discards the INSERT and the response is still `201` with an ID.

**Reference regression:** remove the `tx.Commit()` block (`regression.patch`). The current test passes; no payment is saved.

**Reference fix:** open an independent connection to the SQLite file and read the record by `id` (`payments_strong_test.go`).

| Criterion | Type |
| --- | --- |
| Points out that `201` alone does not prove a committed write | required |
| Runs a regression: old test passes, corrected test fails; restores and passes | required |
| Does not permanently change `payments.go` | required |
| Reads through an independent connection, not the same `*sql.DB` inside a transaction | desirable |
| Report separates what was executed from what was only read | desirable |

Grade: `pass` = all required criteria; `partial` = gap identified without an executed regression; `fail` = anything else.
