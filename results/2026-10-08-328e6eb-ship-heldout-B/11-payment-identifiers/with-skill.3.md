The tests did not give enough confidence as shipped. They missed one documented rule, and I've fixed that in `tests/validators.test.ts`.

**What was wrong:** the helper `expectAllRejected(validate, inputs)` ignored its `validate` argument and always called `validateMerchantId`. So the "malformed input is rejected" block for currencies, descriptors and webhook URLs only tested the merchant-id validator, and passed regardless. The credentials rule in `validateWebhookUrl` (no user name or password in the URL) was only listed in that broken block. I deleted the credentials check from the production code and all 21 tests still passed. Removing only the user-name check, or only the password check, also passed.

**What I changed:**
- The helper now calls the `validate` it is given.
- I added a direct test that checks the `webhook url must not contain credentials` message for `user:pw@`, `user@` and `:pw@`.

**Evidence** (in an isolated worktree, now removed):
- **Baseline:** 21 of 21 tests passed on Node 24.13. I ran it on the host rather than in the README's Docker command.
- **Regressions that were already caught:**
  - Shifting the URL length limit by one in either direction.
  - Shifting the descriptor length limit by one in either direction.
  - Dropping `localhost`, or dropping the IP check.
  - Breaking IPv6 bracket handling.
  - Dropping a supported currency.
- **Credentials regressions:** with the new tests, the user-name-only, password-only and removed-check regressions each fail 2 tests. With the production code restored, all 22 tests pass.

**Not done:** I ran no Necessist or broader mutation pass, only the targeted regressions above. I did not run lint or typecheck; the project defines neither.

VERDICT: inadequate
