The tests you were given didn't protect the documented behavior, so I improved them. All 25 tests now pass against the unchanged `src/validators.ts`. I didn't run mutation checks, so I haven't seen the new credential and IP tests fail when the code is broken.

**The problem:** `expectAllRejected` in `tests/validators.test.ts` took a `validate` argument but always called `validateMerchantId`. That made the "malformed input is rejected" block pass vacuously for currencies, descriptors and webhook URLs. Every malformed non-merchant input threw simply because it isn't a merchant id.

The cost was that credential rejection had no real coverage. The only credential cases (`user:pass@`, `user@`, `:pass@`) were in that vacuous block. Deleting the credentials check from `validateWebhookUrl` would have left the suite green.

**What I changed:**
- **Helper:** `expectAllRejected` now calls the validator it's given.
- **Credentials:** a new test covers `user:pass@`, `user@` and `:pass@`, asserting the documented `webhook url must not contain credentials` message.
- **IP addresses:** new cases for `127.0.0.1`, `127.0.0.1:8443` and an IPv4-mapped IPv6 address, all asserting the localhost/IP message.
- **Trailing newline:** new cases for merchant ids and descriptors.

The rest of the suite is sound. It covers the boundaries (22/23 characters, 2,048/2,049 URL characters), unchanged return values, the error messages that include the input, and hosts that only resemble localhost or an IP.

VERDICT: inadequate
