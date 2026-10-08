# Expected — 08 role resolution

**Gap:** the only test about the request body, "ignores the role in the request body", sends claims with the role `user` together with a body role `admin`, so it always supplies the legitimate input as well. It proves that the claims win over the body, not that the body is never a source of roles. No test sends claims without a role next to a body role, so a fallback to the body goes unnoticed: a caller with a token without a role can grant itself `admin` by writing it in the request.

**Reference regression:** `const received = claims.role ?? request.role;` instead of `claims.role` (`regression.patch`). The current suite passes.

**Reference fix:** assert that claims without a role (or with a blank one) resolve to `guest` even when the body says `admin` (`roles.strong.test.ts`).

**Mutation evidence:** `mutation-sweep.txt` (`scripts/mutation-sweep.py`): all 11 generated mutants of `src/roles.ts` are either killed (5) or invalid (6, TypeScript generics such as `Record<Role, ...>` that the tool reads as comparisons). The tool cannot generate the planted regression, so it was checked by hand together with other statement-level mutants against the current suite; every one is killed except the planted regression and its `||` variant (`claims.role || request.role`), which is the same defect:

| Mutant | Current suite |
| --- | --- |
| drop `toLowerCase()` / drop `trim()` | killed |
| unknown role returns `guest` instead of raising | killed |
| error message uses the normalized role instead of the received one | killed |
| blank role no longer resolves to `guest` / `null` role no longer handled | killed |
| missing role resolves to `user` | killed |
| `isAllowed` allows unknown roles | killed |
| `in` instead of `hasOwnProperty` (inherited keys count as roles) | killed |
| `admin` loses `refund:approve` / `admin` loses `payment:read` / `support` gains `refund:approve` or `payment:create` / `support` loses `refund:create` | killed |
| `guest` gains `refund:create` or `payment:read` / `user` gains `refund:approve` / `user` loses `payment:create` | killed |
| blank-role check skipped / `isAllowed` skips the role check / fallback role is `user` | killed |
| body role takes priority (`request.role ?? claims.role`) | killed |
| `claims.role ?? request.role` (planted) | survives |
| `claims.role \|\| request.role` | survives (same defect) |

| Criterion | Type |
| --- | --- |
| Answers `VERDICT: inadequate` | required |
| Adds a test that catches the reference regression (`scripts/check-agent-fix.sh`) | required |
| Does not change `src/roles.ts` | required |

**Pattern:** masking input. A test that asserts "X is ignored" while also sending the legitimate input cannot detect a fallback to X; the input that triggers the fallback (no legitimate value) is never exercised.

**History:** an earlier version of the permission table tests only checked part of the role x action matrix, so for example giving `guest` the `refund:create` permission passed the whole suite (an unplanted gap). `tests/roles.test.ts` now asserts every documented role x action pair, allowed and denied. The sweep above was re-run with 15 hand mutants (permission additions and removals per role, normalization skips, fallbacks, the body-priority variant): all killed except the planted regression and its `||` variant.
