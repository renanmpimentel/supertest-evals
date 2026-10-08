The tests did not give enough confidence as written, so I improved them. The suite now passes (22 tests), and `src/validators.ts` is unchanged.

**Problems found**
- **Broken helper:** `expectAllRejected` ignored its `validate` argument and always called `validateMerchantId`. The "malformed input is rejected" block therefore never exercised the currency, descriptor or webhook validators. It looked like extra coverage but wasn't.
- **Credentials rule untested:** the rule that a webhook URL must not embed credentials appeared only in that broken block. Removing the password check from the source would not have failed any test.

**Changes to `tests/validators.test.ts`**
- The helper now calls the validator it is given.
- I added a test for the credentials rule. It covers user name only, password only, and both, and it checks the documented error message.

**Check:** I removed the password half of the credentials check in the source. Two tests then failed, the new one and the previously vacuous webhook block. I reverted that change.

The rest of the contract was already covered: accepted values, boundaries, error messages, unchanged return values, and hosts that only resemble localhost or an IP address. The original suite was inadequate because of the two gaps above.

VERDICT: inadequate
