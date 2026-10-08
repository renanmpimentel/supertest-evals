The tests you were given didn't fully protect the documented behavior, so I added tests. All 36 now pass (`npx vitest run`).

**Gaps in the original tests:**
- **Request body with no claim role:** the only test of "the request body is not a source of roles" used a caller who already had a valid claim role. A buggy `resolveRole` that falls back to `request.role` when the claim is missing or blank would have passed every test. That would let a caller promote themselves from guest to admin by putting a role in the request body. The contract says no-role and blank-role claims resolve to `guest`.
- **Error message "as received":** this was only checked with `"Root"`, which has no whitespace. Nothing caught an implementation that put the trimmed or lowercased value in the message.
- **Permission table:** about half of the deny cases weren't covered, for example guest `refund:*` and support `catalog` checks.

**Tests added in `tests/roles.test.ts`:**
- A request-body role is ignored when the claims have no role, a null role, or a blank role.
- A request-body role doesn't change the error for an unknown claim role.
- The error message keeps the exact received value, for example `"  ROOT "`.
- A full role × action matrix (4 roles × 5 actions) checked against the contract table.
- Unknown roles are denied every action, including `toString`, `__proto__` and `Admin`.

I didn't change `src/roles.ts`. It matches the contract.

VERDICT: inadequate
