The original tests weren't enough, and I've fixed that. One part of the documented permission table was unprotected.

**Baseline:** 12 of 12 tests passed in the original project.

**What I checked:** I made temporary changes to `src/roles.ts` in an isolated worktree and ran the unmodified tests against each one. The module has no numeric limits, so the boundary-shift probes don't apply. I didn't run Necessist or a mutation-testing tool. This was a hand-picked set of 10 regressions.
- **Caught (8):**
  - extra permissions for `user` (`refund:create`), `support` (`refund:approve`, `payment:create`) and `guest` (`payment:read`)
  - dropping the trim
  - dropping the lowercase
  - the error message naming the trimmed role instead of the role as received
- **Not caught (2):**
  - giving `guest` the `refund:create` permission
  - giving `guest` the `refund:approve` permission

  The denial test never checked those two actions for `guest`, so a guest could have been allowed to create or approve refunds without any test failing.
- **Inconclusive (1):** my tenth probe, an `isAllowed` that lowercases its input, was a no-op, so it proves nothing. The contract doesn't specify that behavior anyway.

**Fix:** I added one test to `tests/roles.test.ts`. It checks every role against every action and compares each result with the table in `CONTRACT.md`. With it, both guest regressions fail, and with the code restored, all 13 tests pass. The worktree is removed, and the only change in the original project is that test file.

**Limits:** the two `guest` regressions are the only ones I re-ran against the new test. I didn't re-run the other eight, but the new test is stricter than the one it replaces.

VERDICT: inadequate
