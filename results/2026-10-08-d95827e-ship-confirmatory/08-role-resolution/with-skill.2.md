The tests did not give enough confidence. I found four gaps and closed them. The suite now has 13 tests, all passing in the project's documented Docker command.

I made temporary changes to `src/roles.ts` in an isolated git worktree and ran the original 12 tests against each one. Four of these changes passed, so the tests could not catch them:

| Temporary change | Why it matters |
| --- | --- |
| `guest` gets `refund:create` | The contract says guests may only do `catalog:read`, and no test checked guest refunds. |
| `guest` gets `refund:approve` | Same gap, and it is the most security-sensitive one. |
| `isAllowed` lowercases the role, so `"Admin"` is allowed | Any role that isn't one of the four known ones must be denied, and only `"root"`, `""` and `"constructor"` were checked. |
| The `RoleError` message is trimmed | The message must name the role as received, and the only test used `"Root"`, which has no whitespace. |

Three other changes were caught by the original tests. Those were dropping the `trim()` in the blank-role check, adding `refund:approve` to `support`, and lowercasing the role in the error message.

I added assertions to `tests/roles.test.ts` for the four gaps:
- **Guest denials:** `guest` is denied `refund:create` and `refund:approve`.
- **Role casing and spaces:** `isAllowed` denies `"Admin"` and `" admin "`.
- **Error message:** a new test checks that `"  Root "` produces the message `unknown role:   Root ` with the spaces intact.

With the new tests, each of the four changes now fails one test. With the code restored, all 13 pass.

The code has no comparisons against a numeric limit (`<`, `<=`, `>`, `>=`), so the boundary shifts had nothing to apply to. I did not run the full mutation tool or Necessist, because this was a small module and I tested the contract rules by hand instead.

The changes to `tests/roles.test.ts` are in the working tree and not committed. The temporary worktree could not be fully deleted (permission denied on its temp directory). It is outside the project and does not affect the repo.

VERDICT: inadequate
