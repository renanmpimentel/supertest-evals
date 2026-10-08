The tests you were given did not give enough confidence, so I fixed them. With the changes, all 23 tests pass and `src/validators.ts` is untouched.

**What was wrong**
- **Helper ignored its argument:** `expectAllRejected(validate, inputs)` always called `validateMerchantId`. The "malformed input is rejected" block therefore checked nothing for currencies, descriptors and webhook URLs.
- **Credentials rule untested:** The only credential cases (user name, password, both) sat in that broken block. Deleting the credentials check from the source left every test passing.

**What I changed**
- The helper now calls `validate`.
- I added a direct test that credentials are rejected with the documented message. It covers `user:pass@`, `user@` and `:pass@`.
- I added a test that an `@` in the query string is still accepted.

**Check:** I broke the source five ways, one at a time, and the suite now fails each time (2 tests fail per break):
- dropping the credentials check
- dropping the IP check
- dropping the localhost check
- widening the descriptor length limit
- adding a currency

The other documented rules were already covered directly: the formats, the error messages, the exact 22- and 2,048-character limits, and the https, IPv6 and localhost rules.

The change is in `tests/validators.test.ts` and is not committed.

VERDICT: inadequate
