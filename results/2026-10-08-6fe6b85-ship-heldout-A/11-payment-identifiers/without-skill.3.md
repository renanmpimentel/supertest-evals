The tests you were given didn't give enough confidence, so I improved them. The implementation matches `CONTRACT.md`, and all 23 tests now pass.

**The problem:** the `expectAllRejected` helper in `tests/validators.test.ts` ignored its `validate` argument and always called `validateMerchantId`. So the "malformed input is rejected" block, which covers currencies, descriptors and webhook URLs, never ran those validators. The credentials rule (user name or password in the URL) was only covered through that block. As a result, deleting the credentials check from `src/validators.ts` would have left the suite green.

**What I changed:**
- **Helper:** `expectAllRejected` now calls the validator it is given.
- **Credentials test:** I added a direct test that checks user-only, password-only and user-plus-password URLs against the exact `webhook url must not contain credentials` message.
- **IP test:** I added a test for IPv4 (`127.0.0.1`) and IPv4-mapped IPv6 (`[::ffff:127.0.0.1]`) hosts.

**Check:** I removed the credentials check from `src/validators.ts` and ran the suite. Two tests failed, and the source is restored.

The other documented behavior was already covered. That includes the formats, the supported currencies, the length boundaries (22/23 characters, 2,048/2,049), the error messages, and returning the input unchanged.

VERDICT: inadequate
