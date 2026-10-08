The original tests weren't enough, so I added two tests. The original suite passed (30 tests), but it missed a security regression the contract forbids. Production code was not changed.

**The gap.** The contract says the request body is not a source of roles. The old test for that always sent a valid `claims.role` next to the request role, so the claim won either way. I made `resolveRole` fall back to `request.role` in two ways: one when claims have no role (`undefined` or `null`), one when the role is blank. All 30 original tests still passed under both changes. A caller with a token that has no role could have sent `{role: "admin"}` and been treated as admin.

**The fix.** I added two tests to `tests/roles.test.ts`. They send a request role of `admin` or `support` while the claims role is missing, `null`, empty or whitespace. Each expects `guest`.
- With either regression applied, 2 tests fail (30 pass, 2 fail).
- With the code restored, all 32 pass.
- I also reran the 32 tests in the original project and they pass.

**What the original tests already caught.** I ran other regressions and the tests failed on each:
- Putting the normalized role in the error message instead of the role as received.
- Throwing a plain `Error` instead of `RoleError`.
- Returning `guest` for an unknown role.
- Treating inherited keys such as `constructor` as roles.

**What I didn't run.** Neither mutation testing nor Necessist was run, so this is a targeted review, not a full audit. The code has no numeric limits, so there were no boundary probes. The `isAllowed` permission table is checked cell by cell against the contract, so I didn't probe it further.

The temporary worktree is removed. The only change in the project is the added tests, uncommitted.

VERDICT: inadequate
