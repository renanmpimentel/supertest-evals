The tests did not give enough confidence, so I fixed them. All 22 tests now pass in the project.

**Gap:** the "no credentials in webhook URL" rule had no real test. The shared `expectAllRejected` helper in `tests/validators.test.ts` ignored the validator it was given and always called `validateMerchantId`. That made the "malformed input is rejected" block pass for every validator, including the webhook URL cases.

**How I checked:** I ran temporary code changes in an isolated git worktree, against the original 21 tests. Removing the user-name check, the password check, or the whole credentials check left the suite green. That confirms those rules were unprotected. The other changes I tried were all caught. These were shifting the 2,048-character URL limit up and down by one, shifting the 22-character descriptor limit up and down by one, shifting the 12-digit merchant id length up and down by one, and removing the IP or localhost checks. I also broke the IPv6 bracket stripping, which was caught too.

**Fix:**
- The helper now calls the validator it receives.
- I added a test that checks `user:secret@`, `user@` and `:secret@` URLs are rejected with `webhook url must not contain credentials`.

With the fix, removing the user-name check, the password check, or the whole credentials check each fails 2 tests. Shifting the descriptor limit to 21 characters still fails 1. I then restored the code and removed the worktree.

**Limits:**
- I tried only some of the regressions (12, plus 4 after the fix). I did not try shifts on the descriptor's 1-character minimum or other outcomes of the IP check.
- I did not run Necessist or a full mutation tool.

VERDICT: inadequate
