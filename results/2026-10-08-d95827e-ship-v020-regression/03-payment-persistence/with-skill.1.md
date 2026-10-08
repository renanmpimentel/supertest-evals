The original tests were not enough to ship on. They never checked the documented "201 means saved and committed" rule, or that a 400 saves nothing. I added tests for both, and the suite now passes: gofmt, go vet and all 5 tests.

**Gaps in the original two tests**

I ran temporary changes to `payments.go` in an isolated worktree against the original tests:

| Change to `payments.go` | Original tests |
|---|---|
| Skip the INSERT (still returns 201) | passed, so the gap is real |
| Skip the commit | passed, so the gap is real |
| Boundary shifted up (`<= 1`) | passed, so the gap is real |
| Boundary shifted down (`<= -1`) | caught |

**Tests I added** (in `payments_test.go`)
- **Persistence:** a 201 response is followed by a read through a separate database connection, checking the row exists with the right amount.
- **Amount boundary:** -1 and 0 return 400 and save no row. 1 and 2 return 201 and save one row.
- **Invalid body:** an empty body, malformed JSON, a string amount, `{}` and a fractional amount all return 400 and save no row.

**Result with the new tests:** all four changes above now fail, and so does dropping the amount check entirely. I removed the worktrees afterwards. The only change to your repo is the edit to `payments_test.go`, which is not committed.

**Not covered:** I didn't run mutation testing or Necessist, so this is targeted evidence for the documented contract, not a full audit. Non-POST requests and 500 error paths aren't in `CONTRACT.md`, so I left them untested.

VERDICT: inadequate
