The existing tests were not enough to ship on. I added tests for the gaps, and all 13 tests pass on the original project.

I only ran the suite and hand-picked regressions. I didn't run a mutation tool or Necessist. There are no numeric limits in the code, so there were no boundary probes to run.

**Baseline:** 12 of 12 tests passed in the README's docker command.

**Regressions that slipped through** (I changed `src/roles.ts` in a temporary copy, and the 12 tests still passed):
- **Request-role fallback:** `claims.role ?? request.role`. A caller with no role in their claims could claim `admin` in the request body. The existing test only covered a caller who already had a claim role.
- **Error message:** naming the role trimmed instead of as received. The only unknown-role test used `"Root"`, which has no surrounding whitespace.
- **Guest permissions:** `guest` granted `refund:create` and `refund:approve`. Nothing checked that guest is denied them.

Two other regressions were caught: `support` gaining `refund:approve`, and dropping `toLowerCase()`.

**Tests added** (`tests/roles.test.ts`, one new test case plus new assertions in two existing ones):
- Claims with no role, a null role, or a blank role resolve to `guest`, even when the request body says `admin`.
- An unknown role with surrounding whitespace (`"  Root "`) is reported exactly as received.
- `guest` is denied `refund:create` and `refund:approve`.

With these tests, each of the three regressions makes a test fail, and the restored code passes 13 of 13.

**Still open:**
- The temporary copy at `/tmp/tmp.gGynciXeCS/wt` couldn't be removed because of a permissions error. It's harmless, but you may want to remove it and run `git worktree prune`.
- My final check was the same docker run, 13 of 13. I didn't run lint or a typecheck because the project doesn't define either.
- The test changes are in your working tree and not committed.

VERDICT: inadequate
