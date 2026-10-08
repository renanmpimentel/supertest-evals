The tests did not cover the contract. The credentials rule was completely untested, and I've fixed that in `tests/validators.test.ts`.

**Gap.** The `expectAllRejected` helper ignored its `validate` argument and always called `validateMerchantId`. That made the "malformed input is rejected" block a no-op for currencies, descriptors and webhook URLs. The credentials cases lived only in that block, and no other test covered the credentials rule.

I removed or weakened the credentials check in a temporary worktree and ran the unmodified 21-test suite each time. It stayed green for:
- dropping the check entirely;
- checking only the user name;
- checking only the password;
- changing the error message.

That means a webhook URL like `https://user:pw@host` would have shipped accepted.

**Fix.**
- The helper now calls `validate`.
- I added a dedicated test for user-only, password-only and user-plus-password URLs, which also checks the error message.
- With the new test, all four credentials mutations fail the suite.
- I restored the code afterwards and the suite passes. I ran the whole suite in the original project, 22/22, and removed the worktree.

**Other mutations.** I ran 24 mutations in total. Besides the credentials ones, these covered the URL length limit shifted ±1, descriptor length ±1, the currency list, merchant id anchors, length and case, IPv4-only and IPv6-only checks, bracket stripping, and the localhost, https and error-message checks. The original tests caught all of them. The length limits are tested exactly at the boundary, so those shifts failed as they should.

I only changed the tests; the source needed no change.

VERDICT: inadequate
