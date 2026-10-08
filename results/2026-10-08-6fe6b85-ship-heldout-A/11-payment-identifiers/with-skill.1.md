The tests did not give enough confidence, so I fixed them. The credentials rule in `validateWebhookUrl` had no effective test.

**What was wrong**
- `expectAllRejected` in `tests/validators.test.ts` ignored its `validate` argument and always called `validateMerchantId`. The "malformed input is rejected" block for currencies, descriptors and webhook URLs therefore tested nothing.
- The credentials cases (`user:secret@`, `user@`, `:secret@`) appeared only in that block. I deleted the credentials check from `src/validators.ts` and also tried checking only the user name or only the password. All 21 tests still passed each time. It is a documented security rule, and nothing protected it. Its error message was not checked either.

**What I changed**
- The helper now calls the validator it is given.
- I added a test that checks all three credential forms against the documented error message `webhook url must not contain credentials`.

**Evidence**
- I ran the checks in a temporary worktree with Node 24 and vitest, not Docker. The baseline was 21 of 21 passing.
- After the fix, all 22 tests pass. Deleting the credentials check, checking only the user name, checking only the password, or changing the message each makes tests fail.
- I also shifted the length limits one unit down and up:
  - URL length: 2047, 2049, and `>=` instead of `>`.
  - Descriptor length: 21, 23, and a minimum of 0.
  - All of these were caught.
- Other temporary regressions were also caught: removing the localhost check or the IP check, dropping the IPv6 bracket stripping, accepting uppercase hex, accepting an 11-digit merchant id, and changing the https message.
- I removed the worktree and its branch afterward. The only change left in the project is `tests/validators.test.ts`.

**Not done**
- I did not run Necessist or a full mutation-testing tool. The result comes from about 20 hand-picked regressions.
- I did not run the README's Docker command.

VERDICT: inadequate
