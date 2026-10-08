The tests didn't give enough confidence as they were, so I fixed them. They now pass (22 tests).

**The problem:** the `expectAllRejected` helper always called `validateMerchantId`, whatever validator it was given. The "malformed input is rejected" block therefore never tested currencies, descriptors or webhook URLs. It only looked like it did.

**Why that mattered:** the credentials rule (`user:pass@`, `user@`, `:pass@`) was tested only in that block. If someone deleted the credentials check, every test would still have passed.

**What I changed in `tests/validators.test.ts`:**
- The helper now calls the validator it receives.
- I added a direct test for the credentials rule that checks the documented error message for all three forms.

The rest of the suite matches `CONTRACT.md`. It covers boundary lengths (22/23 and 2048/2049), exact error messages, unchanged return values, case rules, and hosts that only look like localhost or an IP.

I did not check that the new credentials test fails when the check is removed. I also did not test `https://localhost./`, which the implementation accepts. `CONTRACT.md` doesn't say whether a trailing dot counts as localhost, so decide that before shipping.

VERDICT: inadequate
