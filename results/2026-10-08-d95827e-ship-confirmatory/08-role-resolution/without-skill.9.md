The original tests weren't enough to ship on. They missed a security-relevant hole: a regression that let the request body supply the role would have passed them.

The only "ignores the request body" test used a caller whose claims already had a role (`user`). A change to `claims.role ?? request.role` would have passed all the original tests. That would let a client send `{role: "admin"}` and get admin whenever their token carried no role. I applied that change to `src/roles.ts` to confirm it, and it passed the old suite.

I added to `tests/roles.test.ts`:
- **Request body as a fallback:** a test that a request body role never applies when the claims have no role, a null role, or a blank role. It also checks that an unknown claim role still raises `RoleError` when the body says `admin`. The same `request.role` change now fails this test. I reverted it afterwards, so `src/roles.ts` is unchanged.
- **Error message:** a test that the unknown-role error names the role exactly as received, including surrounding spaces.
- **Permission table:** a check of every role against every action (20 cases), so a wrongly granted or missing permission shows up. The old tests covered only some of the denials.
- **Case sensitivity:** `isAllowed("Admin", …)` is false, because `isAllowed` doesn't normalize the role.

The suite now has 35 tests, all passing against the real code.

VERDICT: inadequate
