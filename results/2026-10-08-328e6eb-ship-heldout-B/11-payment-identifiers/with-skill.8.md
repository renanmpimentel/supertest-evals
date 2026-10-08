The tests did not give enough confidence as shipped, so I fixed them. The fixed suite passes (22 tests).

**What was wrong**
- **Helper bug:** the `expectAllRejected` helper took a `validate` argument but always called `validateMerchantId`. The "malformed input is rejected" block therefore never exercised the currency, descriptor or webhook validators. Each of those inputs was rejected only because it isn't a merchant id.
- **Credentials rule untested:** the rule "must not embed credentials" appeared only in that broken block. I removed the credentials check from the validator in an isolated worktree, and all 21 original tests still passed.

**What I changed** (`tests/validators.test.ts`)
- The helper now calls the validator it is given.
- I added a test that rejects a user name only, a password only, and both. It also asserts the documented message, `webhook url must not contain credentials`.

**Evidence**
- **Baseline:** 21 passed.
- **Credentials check removed:** the new tests fail (2 failed, 20 passed). That includes the case that drops only the user-name condition and the case that drops only the password condition.
- **Helper fix:** I changed the merchant id regex in the worktree, and the repaired helper now fails on it (1 failed, 21 passed).
- **Restored code:** all 22 pass. The worktree is removed, and only the test file is modified.

**Boundary probes:** the 22/23-character descriptor limit and the 2,048/2,049-character URL limit are each tested on both sides. I judged this by reading the tests; I did not run the one-unit-shift regressions on the limits.

**Not done:** I did not run a full mutation or Necessist pass. Other rules (scheme, localhost, IP, merchant id format, currencies) are covered by explicit tests, but I did not mutate each of them.

VERDICT: inadequate
