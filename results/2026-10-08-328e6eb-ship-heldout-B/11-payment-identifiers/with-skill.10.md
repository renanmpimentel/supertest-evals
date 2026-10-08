The tests were not adequate, and I've fixed them. The original 21 tests all passed even with the credentials check deleted from `validateWebhookUrl`.

- **Cause:** the shared `expectAllRejected` helper in `tests/validators.test.ts` ignored its `validate` argument and always called `validateMerchantId`. The "malformed input is rejected" block therefore never exercised the currency, descriptor or webhook validators.
- **Gap:** the contract's credentials rule had no direct test, because the only credential URLs were in that broken helper block. No test checked the `webhook url must not contain credentials` message either.
- **Fix:** the helper now calls the validator it is given. I added a test covering user name only, password only, and both, with the contract's message.

I checked each change by temporarily breaking `src/validators.ts` in a scratch copy and running the tests:

| Change to `validateWebhookUrl` | Original tests | Fixed tests |
| --- | --- | --- |
| Credentials check removed | 21 pass, bug missed | 2 fail |
| Password check dropped | not run | 2 fail |
| User name check dropped | not run | 2 fail |
| IP check removed | not run | 2 fail |
| Bracket stripping for IPv6 hosts broken | not run | 2 fail |
| `localhost` check removed | not run | 2 fail |
| URL length limit shifted down by one | not run | 1 fail |
| URL length limit shifted up by one | not run | 1 fail |

With the real code restored, the fixed suite passes: 22 of 22. I did not run the same probes on the merchant id, currency or descriptor validators. Their tests already check the 12-digit and 22-character boundaries, but I only read those and didn't break the code to confirm. I didn't rerun lint or typecheck, since the project has neither. The only file changed is `tests/validators.test.ts`, and it is uncommitted.

VERDICT: inadequate
