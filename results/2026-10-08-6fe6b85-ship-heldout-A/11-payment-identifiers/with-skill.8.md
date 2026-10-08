The original tests were not enough to ship on. The credentials rule in `CONTRACT.md` had no effective test, and I've fixed that.

**The gap.** The helper `expectAllRejected` ignored the validator it was given and always called `validateMerchantId`. So the "malformed input is rejected" block for currencies, descriptors and webhook URLs only ever tested merchant ids. The credentials cases in that block passed only because merchant-id validation rejects any URL. Nothing else covered credentials.

**Evidence.** I ran each change on a temporary copy of the module, against the unmodified tests:
- **Credentials check removed**, or reduced to only the user-name check or only the password check: all 21 original tests still passed. A webhook URL like `https://user:secret@…` would have been accepted.
- **The other probes were caught by the original tests.** These were removing the localhost check, removing the IP check, not stripping IPv6 brackets, shifting the 2,048 URL limit up and down, and shifting the 22-character descriptor limit up and down.

**Changes to `tests/validators.test.ts`:**
- `expectAllRejected` now calls the validator passed in.
- A new test rejects a URL with a user name and password, a user name only, and a password only. It also checks the `webhook url must not contain credentials` message.

**After the fix.** With the credentials check removed, or reduced to one half, 2 tests now fail. With the code restored, the suite passes 22/22. Three extra probes, each failing one test, confirmed the other validators are still guarded: dropping the `^` anchor on the merchant-id pattern, dropping the hyphen from the descriptor pattern, and removing `GBP`.

**Limits of this audit.** I did not run Necessist or a full mutation tool. Coverage comes from the hand-picked probes above plus the limit-shift probes on the two limits (2,048 and 22). The run used `npx vitest`, which reported v5.0.3 here; `package.json` pins 3.2.7, so I did not run the Docker command from the README.

VERDICT: inadequate
