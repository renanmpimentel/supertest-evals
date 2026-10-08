The tests were not adequate to ship, and I've fixed them. I found two gaps, both in `tests/validators.test.ts`.

**Gaps found**
- **The credentials rule was untested.**
  - I deleted the check, and also made it reject only a user name or only a password. All 21 tests still passed in each case.
  - The only "credentials" cases were in the `expectAllRejected` helper. That helper took a `validate` argument but always called `validateMerchantId`, so every input was rejected for being a malformed merchant id.
  - Because of that, the "malformed input is rejected" group never exercised the currency, descriptor or webhook validators. Making the currency and descriptor validators accept everything also went unnoticed.
- **The credentials error message (`webhook url must not contain credentials`) was never asserted.**

**What I changed**
- The helper now calls the `validate` it receives.
- I added a webhook test that checks the credentials message for user and password, user only, and password only.

**Checks**
- Baseline was 21 of 21 passing.
- Of 19 regressions run against the original tests, 15 were caught. I mutated the length limit, descriptor length, `isIP`, bracket stripping, `localhost`, `https`, each currency, and the merchant-id rules. The 4 survivors were the credentials ones.
- With the fixes, all 4 now fail, and the full suite passes at 22 of 22.
- The helper fix is caught too: making the currency and descriptor validators accept everything now fails 7 tests.
- The numeric limits were already covered on both sides (2048 and 2049 characters, 22 and 23 for descriptors), so those shifts were caught.
- I ran the tests locally with `npx vitest run`, not in the Docker image from the README. I ran no lint or typecheck, and Necessist wasn't run. The regressions were hand-picked, not a full mutation run.

The work is uncommitted in the original project. I removed the temporary worktree.

VERDICT: inadequate
