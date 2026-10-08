The tests did not give enough confidence, so I fixed them. They now cover everything in `CONTRACT.md`. The original 21 tests passed, but they missed the credentials rule completely.

**Gaps found**
- **Credentials rule untested.** `validateWebhookUrl` should reject a user name or password in the URL. I removed that check in an isolated copy and all 21 tests still passed. The only test that touched credentials went through `expectAllRejected`, which has the second problem below.
- **Helper checked the wrong function.** `expectAllRejected(validate, inputs)` ignored its `validate` argument and always called `validateMerchantId`. So the four "malformed input is rejected" tests, for currencies, descriptors and webhook URLs, checked nothing about those validators. They passed only because those inputs are also invalid merchant ids.

**Changes to `tests/validators.test.ts`**
- `expectAllRejected` now calls the validator it is given.
- A new test checks that user-only, password-only and user-plus-password URLs are rejected with the `webhook url must not contain credentials` message.

**Evidence**
- The limit probes (shifting each limit one unit up and one unit down) all failed the existing tests, so those boundaries are protected:
  - the 2,048 URL length
  - the 22-character descriptor length
  - the 12-digit merchant id
- With the new test, removing the credentials check now fails 2 tests. Removing only the password check also fails 2.
- Removing the merchant-id check fails 3 tests, and removing the currency check fails 3.
- After restoring the code, the suite passes with 22 tests, and I removed the temporary copy.

**Not run:** I did not run a full mutation-testing or Necessist pass. I ran only targeted regressions, plus a read-through of the tests against the contract.

VERDICT: inadequate
