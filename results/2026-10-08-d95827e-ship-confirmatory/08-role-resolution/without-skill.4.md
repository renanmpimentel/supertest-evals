The tests you were given weren't enough. They missed a real hole: if the code fell back to `request.role` when the claims had no role, every test would still have passed. A caller could then send `{role: "admin"}` with a role-less token and be treated as admin. The contract says the request body is not a source of roles. The old "ignores the role in the request body" test only covered a token that already had a role.

I added three tests to `tests/roles.test.ts`:
- **No role in the claims:** a request-body role of `admin` is ignored, and the caller resolves to `guest`. This covers a missing role, a null role and a blank role.
- **Unknown claim role:** a request-body role of `admin` doesn't rescue it, and it still raises `RoleError`.
- **Whitespace in the error:** an unknown role is named exactly as received, including surrounding whitespace.

All 15 tests pass. I temporarily changed the code to `claims.role ?? request.role`, and the new test failed as it should. I then restored `src/roles.ts`.

The rest of the contract was already covered. That includes the full permissions table, the unknown-role and unknown-action denials, and the inherited-key cases like `constructor`.

VERDICT: inadequate
