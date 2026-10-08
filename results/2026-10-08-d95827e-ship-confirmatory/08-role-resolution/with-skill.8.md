The original tests did not give enough confidence, so I added four tests. The module's code is correct as written, and all 16 tests now pass on it.

I checked this by breaking `src/roles.ts` on purpose, in a throwaway copy of the repo. The copy is now removed. The original 12 tests passed on the unmodified code. They then missed 4 of the 17 deliberate breakages I tried.

**Breakages the original tests missed:**
- **Guest permissions:** granting `guest` either `refund:approve` or `refund:create` went unnoticed. The tests never checked guest against the refund actions.
- **Request-body role:** when the claims have no role, falling back to `request.role` went unnoticed. The "ignores the request body" test only covered a caller whose claims already had a role. This is the most serious gap, because it would let a caller set their own role.
- **Error message:** trimming the role in the `RoleError` message went unnoticed. The contract says the message names the role as received, so `"  Root "` should appear untrimmed.
- **Partial action names:** matching actions by prefix, so that `catalog` or `refund:app` would pass, went unnoticed.

**Tests I added in `tests/roles.test.ts`:**
- No role in the claims (missing, `null` or blank) still resolves to `guest` when the request body says `admin`.
- The unknown-role error keeps the received text exactly (`"  Root "`).
- `guest` is denied every action except `catalog:read`.
- Partial or empty action names are denied, even for `admin`.

With the new tests, each of those four breakages now fails a test. The 16 tests pass again once the original code is restored.

The other 13 breakages were caught by the original tests, for example a missing `trim`, a missing `lowercase`, and `user` losing `payment:read`.

I did not add tests for two things the contract doesn't specify: whether `isAllowed` normalizes the case of `action`, and whether it trims or lowercases `role`. The mutations on those passed, but there is no documented behavior to check them against.

The code has no numeric limits, so the boundary probes didn't apply. I ran the tests locally on Node 24.13.0, not in the Docker image the README uses. The changes are uncommitted in `tests/roles.test.ts`.

VERDICT: inadequate
