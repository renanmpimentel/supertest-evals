The original tests were not enough to ship on. I added the missing tests, and the suite is now 25 tests, all passing.

**What I did.** The baseline was green, with 15 of 15 passing under Node 24 and vitest 3.2.7. I then ran 12 temporary regressions against the unmodified tests in an isolated git worktree. 7 of them survived, which means the code could break and the suite would still pass:

- Removing `BR` from the supported countries.
- Removing `DE` from the supported countries.
- A patch without `companyName` set the stored value to `null` instead of keeping it.
- A patch without `taxId` set the stored value to `null` instead of keeping it.
- Emails with whitespace inside, such as `with space@acme.test`, were accepted.
- Emails with an empty local part, such as `@acme.test`, were accepted.
- Treating an explicit `undefined` like `null` cleared the field instead of keeping the stored value. The contract says `undefined` keeps the stored value, and the old tests never passed it.

**Fix.** I added tests to `tests/profile.test.ts` for each gap. With the new tests, all 7 regressions now fail the suite. After restoring the code, 25 of 25 pass.

**Limits.** The code has no numeric limit comparisons, so the boundary probes didn't apply. I did not run mutation testing or Necessist. The review is the 12 hand-picked regressions plus a read of the code against `CONTRACT.md`. I removed the worktree, and the only change to the project is `tests/profile.test.ts`, which is uncommitted.

VERDICT: inadequate
