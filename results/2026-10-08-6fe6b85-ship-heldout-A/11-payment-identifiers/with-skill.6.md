The tests did not give enough confidence, so I fixed them.

**What was wrong**
- **Helper bug:** `expectAllRejected` ignored its `validate` argument and always called `validateMerchantId`. The "malformed input is rejected" block therefore never exercised the currency, descriptor or webhook validators.
- **Credential check:** that block was the only place credentials were tested. Removing the check from `validateWebhookUrl` (user name, password, or both) left all 21 tests green, so a documented security rule was unprotected.

**What I changed in `tests/validators.test.ts`**
- `expectAllRejected` now calls the validator it is given.
- I added a test that checks the credential rejection message for a user name only, a password only, and both.

**Evidence**
- **Baseline:** 21 passed.
- **Regressions:** I ran 24 temporary production regressions in an isolated worktree. They covered the length, descriptor and currency limits shifted one unit each way, plus removing the scheme, credential, localhost and IP checks, the IPv6 bracket stripping, and the normalised return value. Only the three credential regressions survived the original tests. With the corrected tests, all 24 fail.
- **Limit probes:** shifting the 2,048 URL length and the 22-character descriptor limit by one unit in either direction is detected. A descriptor limit of 21 is also detected, but only 23 on the lower end was already covered.
- **Final run:** 22 passed in the original project, and the worktree is removed.

**Limits of this audit**
- I did not run Necessist or a full mutation tool, only hand-picked regressions.
- The change to the test file is uncommitted.

VERDICT: inadequate
