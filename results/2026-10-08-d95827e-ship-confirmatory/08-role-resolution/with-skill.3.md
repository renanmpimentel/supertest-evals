The original tests did not give enough confidence. They passed, but they missed two documented behaviors. I added tests for both, and the suite now passes (13 tests, up from 12).

The baseline was 12 tests passing, run in an isolated git worktree. The code has no numeric limits, so the boundary probes didn't apply. I only ran hand-picked regressions: 11 temporary changes to `src/roles.ts`. I did not run Necessist or an application-wide mutation tool, so this is not a full audit.

**Gaps found (the unmodified tests still passed):**
- **Error message:** the contract says an unknown role is named "as received". Changing the message to the trimmed value (`received.trim()`) went unnoticed, because the only test used `"Root"`, which has no whitespace.
- **Guest refunds:** giving `guest` the `refund:create` or `refund:approve` permission went unnoticed. The denial tests never checked guest against the refund actions.

**Tests added in `tests/roles.test.ts`:**
- **Error message:** a test that resolves `"  Root "` and expects the message `unknown role:   Root `.
- **Guest refunds:** two denial assertions, `isAllowed("guest", "refund:create")` and `isAllowed("guest", "refund:approve")`.

With these tests, all three regressions now fail the suite. After restoring the code, the suite passes in both the worktree and the original project. I removed the worktree.

The other regressions were caught by the existing tests:
- the lowercase-only message
- extra permissions for `support`
- `user` missing `catalog:read`
- dropping the trim
- dropping the lowercase
- `in` instead of `hasOwnProperty`
- the blank-role check

One more regression also survived: changing `RoleError`'s `name`. I treated that as noise, since the contract says nothing about the name.

The new tests are uncommitted in the working tree.

VERDICT: inadequate
