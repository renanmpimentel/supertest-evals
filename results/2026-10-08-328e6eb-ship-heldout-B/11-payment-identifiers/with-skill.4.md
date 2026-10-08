The existing tests did not protect the documented behavior, so I fixed them. The credentials rule in `CONTRACT.md` was untested.

**The gap.** The helper `expectAllRejected` in `tests/validators.test.ts` ignored its `validate` argument and always called `validateMerchantId`. Every URL in the "webhook URLs" malformed-input test was rejected because it isn't a merchant id, so that test proved nothing about the webhook rules. The currency and descriptor tests were vacuous in the same way. The credentials check was covered only by that test, so it had no real coverage.

**Evidence from temporary changes in an isolated worktree.** The original suite was green, with 21 of 21 passing:
- **Credentials check removed:** 21 of 21 still passed.
- **Only the user name checked:** 21 of 21 still passed.
- **Only the password checked:** 21 of 21 still passed.
- **URL length limit shifted by one, down and up:** both shifts were caught by the existing 2,048/2,049 test.
- **Localhost check, IP check and IPv6 bracket handling removed:** each was caught.

**What I changed.**
- The helper now calls the validator it is given.
- I added a test that expects the exact credentials error for three URLs: user and password, user only, and password only.

**Verification.** With the fixes, the suite passes, 22 of 22. Each of the three credentials regressions now fails 2 tests, and a merchant-id regression fails 3. I restored the code and the suite passed again. I removed the worktree, and the only change left in the project is `tests/validators.test.ts`.

**Limits.** I did not run Necessist or a full mutation tool. I tried hand-picked regressions plus the boundary probes only. The descriptor 22-character limit lives in a regex, not a comparison, so I did not shift it.

VERDICT: inadequate
