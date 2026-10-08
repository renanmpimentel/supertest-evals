The original tests did not give enough confidence, so I added tests for the gap I found.

**The gap:** the contract says the request body is not a source of roles. The old tests only checked that rule when the claims already had a valid role. If `resolveRole` fell back to `request.role` when the claims had no role or a blank one, all 30 tests still passed. In that case a client could send `{role: "admin"}` and get admin access.

I confirmed this on a temporary copy of the code, and both of these regressions passed the old suite:
- using `request.role` when `claims.role` is missing or null
- using `request.role` when `claims.role` is blank

**What I added:** three tests in `tests/roles.test.ts`. They send `{role: "admin"}` in the request body with claims that have no role, a null role, or a blank role, and expect `guest`. They also check that an unknown claim role still raises `RoleError` when the request body names a known role. Both regressions now fail the new tests, and the code is restored.

**Other checks:**
- **Other regressions:** these were all caught by the existing tests: removing the trim, removing the lowercasing, reporting the trimmed role in the error message, mapping an unknown role to `guest`, and replacing the own-key check with `in`.
- **Not run:** the contract has no numeric limits, so there were no boundary probes. I did not run the mutation or Necessist tools, because this was a targeted audit rather than a full one.
- **Baseline:** 30 tests passed. With the additions, 33 pass in the original project, run locally with `npx vitest run`.
- **Vitest version:** the run used vitest 5.0.3, not the 3.2.7 pinned in `package.json`. I did not run the Docker command from the README.

I left the changes uncommitted.

VERDICT: inadequate
