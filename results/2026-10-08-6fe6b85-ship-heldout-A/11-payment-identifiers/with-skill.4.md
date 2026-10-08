The original tests didn't give enough confidence, so I fixed them. The documented rule that webhook URLs must not embed credentials had no effective test.

**Cause:** the `expectAllRejected` helper in `tests/validators.test.ts` ignored its `validate` argument and always called `validateMerchantId`. Every case in the "malformed input is rejected" block therefore tested the merchant-id validator, which rejects them all. The credentials cases lived only in that block.

**Evidence** (21-test baseline passed; probes run in a temporary worktree, with the code restored after each):
- **Credentials check removed:** 21 of 21 tests passed, so the removal went undetected.
- **Check on user name only:** 21 of 21 passed.
- **Check on password only:** 21 of 21 passed.
- **Other regressions:** I ran 13 more, none of which survived. They covered the URL length limit shifted by one in each direction, descriptor length 21 and 23, dropping each descriptor character class, dropping GBP, accepting any scheme, the localhost check, the IP check, bracket stripping for IPv6, and uppercase hex in merchant ids.
- **Boundary probes:** the URL-length (2048) and descriptor-length (22) comparisons were each shifted one down and one up, and all four shifts were caught.

**Fix:**
- The helper now calls `validate`.
- I added a test that rejects a user name only, a password only, and both, and checks the documented error message.
- With the fix, all three credential regressions fail 2 tests each. After restoring the code, 22 of 22 pass.

**Limitations:** I ran only the Vitest suite, locally on Node 24, not in the README's Docker command. I didn't run Necessist or a full mutation tool; the probes were hand-picked. The change is in your working tree, uncommitted.

VERDICT: inadequate
