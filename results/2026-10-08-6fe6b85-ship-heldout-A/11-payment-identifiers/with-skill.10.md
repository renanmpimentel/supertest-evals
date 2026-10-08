The tests did not give enough confidence as shipped. They missed one documented rule: a webhook URL must not contain credentials.

**The gap**
- The `expectAllRejected` helper took a `validate` argument but always called `validateMerchantId`. That made the "malformed input is rejected" block check only merchant ids. The currency, descriptor and webhook cases in it tested nothing.
- The credentials rule appeared only in that block, so no test covered it. I deleted the credentials check from `validateWebhookUrl`, and all 21 tests still passed. The same happened when I checked only the user name or only the password.

**The fix**
- In `tests/validators.test.ts` the helper now calls `validate(input)`.
- I added a test for the credentials rule. It covers user and password, user only, and password only, and it checks the error message `webhook url must not contain credentials`.
- With the fix, all three credential regressions fail 2 tests. After restoring the code, the suite passes 22 of 22, both in the isolated copy and in the original project.

**Other regressions I tried**
All of these were caught by the original tests:
- Shifting the URL length limit by one in each direction.
- Shifting the descriptor length limit by one in each direction.
- Dropping the IP-address check.
- Dropping IPv6 bracket handling.
- Dropping the `localhost` check.
- Dropping the `https` check.
- Adding an extra currency.

I did not run Necessist or a full mutation tool. I ran only these hand-picked regressions, in a temporary worktree that I removed afterward. Only `tests/validators.test.ts` changed in your project.

The corrected tests protect the documented behavior, but the tests you were given did not.

VERDICT: inadequate
