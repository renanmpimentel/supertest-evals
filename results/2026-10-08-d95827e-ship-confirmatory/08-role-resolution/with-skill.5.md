The original tests were not enough to ship on. The source matches `CONTRACT.md`, but three deliberate bugs I put in a scratch copy of the code still passed all 12 original tests.

**Baseline:** the 12 original tests passed with `vitest run`.

**Bugs the original tests missed:**
- **Error message:** if the `RoleError` message used the trimmed role instead of the role as received, nothing failed. The only test input was `"Root"`, which has no whitespace to expose it.
- **Extra permission:** adding `refund:approve` to `guest` passed. The deny checks covered only some role and action pairs.
- **Prefix matching:** matching actions by prefix instead of exactly passed, so `catalog:read:all` would have been allowed.

**Bugs the original tests did catch:**
- An extra permission added to `user`, `support` or `admin`.
- A blank-role check that skips trimming.

**Added to `tests/roles.test.ts`:**
- **Error message:** a test that `"  Root "` is reported exactly as received.
- **Permissions:** a test of every role against all five actions, so any extra or missing permission fails.
- **Action matching:** a test that actions match exactly, with no prefix, partial or case-insensitive matches and no empty string.

**Verification:** the three bugs that slipped through now each fail one of the new tests. With the real code restored, all 15 tests pass. I only re-ran the vitest suite. There is no lint or typecheck script in the project, and I did not run Necessist.

There are no numeric limits in the code, so I ran no boundary-shift probes. I removed the scratch copy, and the new tests are in the original project, uncommitted.

VERDICT: inadequate
