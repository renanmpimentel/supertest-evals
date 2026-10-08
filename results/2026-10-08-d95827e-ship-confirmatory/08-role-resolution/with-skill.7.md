The original tests didn't give enough confidence, so I added tests for the gaps. The baseline was 12 passing tests, and the suite is now 14 passing.

**Regressions that passed the original tests**

I ran temporary regressions in an isolated worktree. Four of them passed all 12 original tests:
- **Request-body role fallback:** the code used `claims.role ?? request.role`. A caller with no role in their claims could then self-assign `admin`. This is the most serious gap, because the contract says the request body is never a source of roles. The old test only covered a request role next to a valid claims role.
- **Guest allowed `refund:approve`:** nothing denied it.
- **Guest allowed `refund:create`:** nothing denied it.
- **Error message echoing the trimmed role:** the contract says the error names the role "as received". The old tests only used `"Root"`, which has no whitespace to trim.

**Regressions the original tests did catch**
- Dropping the trim from the role lookup.
- Treating whitespace-only roles as roles instead of `guest`.
- Giving `user` the `refund:create` action.
- Giving `support` the `payment:create` action.

**Changes**

The new tests are in `tests/roles.test.ts`:
- A request-body role is ignored when the claims role is missing, `null` or blank.
- The unknown-role error keeps the received whitespace and case.
- `guest` is denied `refund:create` and `refund:approve`.

With the new tests, all four surviving regressions now fail the suite. With the code restored, 14 of 14 tests pass. I ran this with local Node 24 rather than the Docker command in the README.

**Limits of this check**
- The code has no limit comparisons (`<`, `>`, `<=`, `>=`), so the boundary probes didn't apply.
- I ran a hand-picked set of regressions and did not run a full mutation tool or Necessist. A few of my regressions were also simple tests that were already caught.
- There is no lint or typecheck script in `package.json`.

VERDICT: inadequate
