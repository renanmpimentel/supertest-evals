The tests did not give enough confidence, so I fixed them in `tests/validators.test.ts`. The baseline was green (21 tests passed in a throwaway worktree), but two defects hid behind it.

**What was wrong**
1. **The shared helper tested the wrong validator.** `expectAllRejected` always called `validateMerchantId` instead of the validator it was passed. The "malformed input is rejected" block therefore only ever tested merchant ids. Any garbage string is an invalid merchant id, so those checks passed whatever the other validators did.
2. **Nothing tested the credentials rule.** The only credentials inputs were in that broken block. I confirmed this by removing the credentials check entirely, and then dropping just the username or just the password check. All three kept the 21 tests green. A webhook URL like `https://user:secret@host/` would have been accepted, which is a documented-security hole.

**What I changed**
- The helper now calls the validator it receives.
- I added a test for credentials with the username only, the password only, and both, asserting the documented message `webhook url must not contain credentials`.

**Evidence**
Each of these production-code mutations was run against the original tests:

| Area | Mutations tried | Original tests |
| --- | --- | --- |
| Length limits | URL length 2048 shifted ±1; descriptor max 22 shifted ±1; descriptor min 1→0; merchant id length 12 shifted ±1 | All caught |
| Currencies | Each of the four supported currencies removed | All caught |
| Charset / format | Descriptor space, hyphen or digit removed; merchant id start anchor removed; uppercase hex allowed | All caught |
| Webhook URL | localhost check removed; IP check removed; IPv6 bracket stripping removed; URL returned normalized; invalid-URL message without the URL | All caught |
| Webhook credentials | Whole check removed; username-only; password-only | **Survived** |

- **Credentials after the fix:** all three credentials mutations now fail 2 tests.
- **Helper after the fix:** removing `EUR` from the supported currencies is now caught by the previously vacuous currency block.
- **Final run:** 22/22 pass on the restored code.
- **Cleanup:** I removed the temporary worktrees. The only change to your project is the test file.

I did not run Necessist or the Docker command from the README. I ran the suite directly with Node 24.13.0. I did not check the bracket-stripping regex's anchors or whether credentials are checked before the host.

VERDICT: inadequate
