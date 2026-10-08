The original tests did not give enough confidence, so I added tests. All 17 now pass (the original suite plus the new ones), but I didn't run them against a deliberately broken implementation to confirm they catch it.

**The main gap:** the contract says the request body is not a source of roles. The old test only covered a caller whose claims had a valid role. A bug like `claims.role ?? request.role` would have passed every old test. It would let a caller with no role in their token send `{role: "admin"}` and get admin access. I confirmed this by reading the old tests, not by running such a bug.

**Tests added in `tests/roles.test.ts`:**
- **No privilege from the request:** claims with a missing, null or blank role resolve to `guest` even when the request says `admin`.
- **Request ignored when claims are valid:** an invalid request role doesn't affect a valid claims role.
- **Error message wording:** the unknown-role error names the role exactly as received. Input like `"  ROOT "` is not trimmed or lowercased in the message.
- **Exact permission table:** each role gets exactly its row from the contract and nothing more.
- **Role case:** `isAllowed("Admin", …)` is denied, since only `resolveRole` normalizes case.
- **Inherited keys as actions:** `toString` and `length` are denied as actions.

The existing tests were otherwise sound.

VERDICT: inadequate
