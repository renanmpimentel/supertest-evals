The tests you were given did not protect the documented behavior, so I fixed them. The suite now has 22 tests and all pass.

**What was wrong**
- **Broken helper:** `expectAllRejected(validate, inputs)` ignored its `validate` argument and always called `validateMerchantId`. The "malformed input is rejected" block therefore never ran the currency, descriptor or webhook validators. It passed only because every input is also an invalid merchant id.
- **Credentials rule untested:** The only credential cases were inside that broken helper. Deleting the credentials check from `validateWebhookUrl` would have left the suite green.

**What I changed in `tests/validators.test.ts`**
- The helper now calls the validator it is given.
- I added a test for the credentials rule. It covers user and password, user only, and password only, and checks the exact `webhook url must not contain credentials` message.

I did not run a mutation check, such as removing the credentials check, to confirm the new test fails.

The other documented rules were already covered:
- the accepted and rejected inputs for each validator
- the error messages
- the 22-character and 2,048-character boundaries
- inputs returned unchanged
- localhost and IP hosts, including IPv6

I did not add tests for edge cases the contract doesn't spell out, such as `localhost.` with a trailing dot.

VERDICT: inadequate
