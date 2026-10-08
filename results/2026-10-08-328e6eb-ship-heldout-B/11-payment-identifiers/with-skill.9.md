The original tests did not protect the documented behavior, so I fixed them. One documented rule, rejecting credentials in webhook URLs, had no working test.

**The gap**
- In `tests/validators.test.ts`, the `expectAllRejected(validate, inputs)` helper ignored its `validate` argument and always called `validateMerchantId`. The "malformed input is rejected" cases for currencies, descriptors and webhook URLs therefore only re-tested merchant ids.
- Removing the credentials check from `validateWebhookUrl` left all 21 tests green. I tried dropping the username half, the password half, and the whole check. The "rejects any scheme other than https" test is the only other test that names a webhook error, and it doesn't cover credentials.

**What I changed**
- The helper now calls the validator it is given.
- I added a test that `https://user:secret@…`, `https://user@…` and `https://:secret@…` are each rejected with `webhook url must not contain credentials`.

**Evidence** (temporary edits in a separate git worktree, since removed)
- **Baseline:** 21 tests passed before my changes and 22 after.
- **Credentials:** each of the three removals above now fails the suite.
- **Credentials before the fix:** all three removals survived.
- **Webhook length limit (2,048):** shifting the limit one down and one up each fail a test, so the boundary is covered.
- **Other regressions:** these each fail a test:
  - IPv6 hosts are no longer rejected.
  - Brackets are no longer stripped from IPv6 hosts.
  - `GBP` is removed from the supported currencies.
  - The descriptor hyphen is removed.
  - The descriptor space is removed.
  - The merchant-id `^` anchor is dropped.
  - The `localhost` check is removed.
  - The https check is removed.
- **Not run:** the full Necessist and application-mutation passes. The fixed suite was only re-run against the credentials, `localhost` and https regressions, not all eleven.
- **Not run in Docker:** I ran vitest on the host with Node 24.13, not through the README's Docker command.
- **Working tree:** the only change in the original project is the uncommitted edit to `tests/validators.test.ts`.

VERDICT: inadequate
