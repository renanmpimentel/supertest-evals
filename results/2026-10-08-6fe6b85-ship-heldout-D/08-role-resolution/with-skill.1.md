The original tests did not give enough confidence, so I added three tests to `tests/roles.test.ts`. They now catch every regression I tried. The suite has 33 tests, all passing on the original project.

**What I ran:** I made temporary changes to `src/roles.ts` in an isolated worktree and ran the unmodified tests against each one. The baseline was 30 passing on the host Node, not the Docker image from the README. The other regressions I ran were all caught:
- Removing the trim, the lowercase step, the blank-role check, or the null/undefined check.
- Making unknown roles allowed `catalog:read`.
- Using `in` instead of `hasOwnProperty` for the role check.

**Gaps found (3 regressions survived):**
1. **Request body as a fallback role:** if the claims had no role or a blank one, resolving to the request body's role instead of `guest` still passed. The old test only sent a body role alongside a valid claim role. This is a privilege-escalation risk, and the contract says the body is not a source of roles.
2. **Error message with whitespace:** an error message that named the trimmed role instead of the role as received still passed. The old test used `"Root"`, which has no whitespace.
3. **Unknown claim role:** no test showed that a body role is ignored when the claim role is unknown. I did not run a separate regression against the original tests for this one.

**Fixes:** the new tests cover a body role of `"admin"` with missing, null and blank claim roles, which must resolve to `guest`. They also cover an unknown claim role with a body role, which must throw. The last one checks that `"  Root "` is reported as `unknown role:   Root `. With these tests, each of the three regressions fails the suite, and the restored code passes.

**Limits:**
- I did not run Necessist or a full mutation tool.
- The module has no numeric limits, so the boundary probes did not apply.
- I spent about 13 regressions, well under the 30-regression budget.

VERDICT: inadequate
