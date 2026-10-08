The original tests did not protect the documented behavior, so I improved them. The corrected suite now passes (22 tests, 1 added) on both the isolated copy and the original project.

**What was wrong**
- **Credentials check unprotected:** the helper `expectAllRejected` in `tests/validators.test.ts` ignored its `validate` argument and always called `validateMerchantId`. The "malformed input is rejected" block, which includes the credentials cases, never ran the currency, descriptor or webhook validators. Every input there is a bad merchant id, so it threw regardless.
- **Evidence:** I removed the credentials check from `validateWebhookUrl` in an isolated copy. The original suite stayed green at 21/21, so a webhook URL like `https://user:pw@host` would have passed review. The only test for that rule was the broken one.

**What I changed**
- Fixed the helper to call `validate(input)`.
- Added a test that asserts the `webhook url must not contain credentials` message for a user and password, a user only, and a password only.

**Proof the fix works**
- Removing the credentials check, only the username check, or only the password check now fails the suite (2 failures each).
- Restoring the code returns the suite to green.

**Other regressions I ran (original tests)**
These were all caught by the original tests:
- removing the IP-address check
- descriptor length limit shifted down and up (`{1,22}` to `{1,21}` and `{1,23}`)
- URL length limit shifted down and up (2048 to 2047 and 2049)
- removing `GBP` from the supported currencies
- merchant id length 12 shifted to 11

**Limitations:** I did not run a Necessist or full mutation pass; this was a targeted audit of the documented contract. I also didn't try adding an unsupported currency or a longer or shorter merchant id.

VERDICT: inadequate
