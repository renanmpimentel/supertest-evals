The original tests did not give enough confidence. Three of the documented rules could break without any test failing, so I added two tests that close those gaps.

**Baseline:** 30 tests passed, run with the README's Docker command.

**Regressions I tried:** I made 10 temporary changes to `src/roles.ts` in an isolated worktree and ran the original tests against each. Seven were caught. Three survived:
- **Request-body role used as a fallback:** `claims.role ?? request.role`. The "ignores the request body" test always gave the claims a role, so it could never see this. That is the privilege-escalation case: a caller with no role in their token could send `role: "admin"` in the body.
- **Request-body role rescuing a blank claim role:** same cause.
- **Error message trimmed:** the contract says the unknown role is named "as received". Only `"Root"` was tested, which has no surrounding spaces.

**Changes:** I added two tests to `tests/roles.test.ts`:
- **No request-body fallback:** with a missing, null or blank claim role and `role: "admin"` in the body, the result must be `guest`.
- **Message as received:** the error for `"  Root "` must keep the spaces.

**After the fix:** 32 tests pass. All three survivors now fail the tests, and the other seven regressions are still caught. The permission table and its inherited-key handling were already well covered.

**Limits of this audit:**
- The code has no numeric limits, so there were no boundary probes.
- I ran only these hand-picked regressions. I did not run a mutation tool or Necessist.
- I didn't rerun the final suite on the original project, only in the worktree.
- The temporary worktree at `/tmp/tmp.Xo5W2SyXjE/wt` could not be removed (permission denied, probably because Docker created root-owned files in it). It is outside the project and safe to delete by hand.

The test changes are uncommitted in the original project.

VERDICT: inadequate
