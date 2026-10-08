The tests did not give enough confidence, so I fixed them.

**The gap:** `expectAllRejected` took a `validate` argument but always called `validateMerchantId`. The "malformed input is rejected" block therefore only ever tested merchant ids. The credentials rule (user name or password in a webhook URL) appeared only in that block, so nothing tested it. I removed the whole credentials check from `src/validators.ts` in an isolated copy, and all 21 tests still passed. Removing only the user-name check or only the password check also left all 21 passing.

**Fix, in `tests/validators.test.ts`:**
- The helper now calls the validator it is given.
- I added a test for user name only, password only, and both. It checks the message `webhook url must not contain credentials`.
- With the original code, 22 tests pass. Each of the three credential regressions now fails 2 tests. The 2 are the new credentials test and the repaired webhook-URL list in the malformed-input block, because the helper now runs the right validator.

**Other regressions (all caught):**
- **Limits, shifted one up and one down:** URL length 2048, descriptor length 22, descriptor minimum 1, and the merchant id's 12 hex digits. Each shift fails at least one test.
- **Checks removed:** the localhost check, the IP-address check, the `https` check, the IPv6 bracket handling, and the `GBP` entry.

**Not done:** I ran no Necessist or full mutation tool, only these hand-picked regressions. I did not run lint or typecheck, and the project has neither configured.

**Cleanup:** `git worktree remove` failed with a permission error, because Docker created root-owned files in `/tmp/wt-audit`. That temporary worktree and its `audit-tmp` branch still exist. They are outside your project files and safe to delete. The only change in your project is `tests/validators.test.ts`, uncommitted.

VERDICT: inadequate
