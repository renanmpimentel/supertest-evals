The tests you were given did not protect the documented behavior. With my changes, all 24 tests pass against the unchanged source. `src/validators.ts` is untouched, and `node_modules` was installed inside the Docker container, so nothing leaked into the repo.

**What was wrong**
- **Broken helper:** `expectAllRejected` took a `validate` argument but always called `validateMerchantId`. The whole "malformed input is rejected" block therefore tested only merchant ids, and it passed for every list because those inputs are all invalid merchant ids. The currency, descriptor and URL lists were never checked.
- **Credentials rule untested:** The rule "must not embed credentials" appeared only in that broken block. I removed the credentials check from the source as a test, and the original suite still passed.

**What I changed in `tests/validators.test.ts`**
- Fixed the helper to call `validate`.
- Added a test for the credentials rule that checks the error message for `user:pass@`, `user@` and `:pass@`.
- Added tests that reject IPv4 hosts written as `2130706433` or `0x7f.0.0.1`, and that reject a trailing newline on merchant ids and descriptors.

With the credentials check removed again, the new credentials test and the repaired URL block both fail, so the credentials rule is now covered. I restored the source afterwards.

The rest of the contract was already covered: formats, length boundaries, error messages, and that valid input is returned unchanged.

VERDICT: inadequate
