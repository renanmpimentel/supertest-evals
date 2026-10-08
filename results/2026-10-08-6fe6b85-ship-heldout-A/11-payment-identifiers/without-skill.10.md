The tests you were given didn't give enough confidence, so I fixed them. The module itself matches `CONTRACT.md`.

**The problem:** the shared helper `expectAllRejected(validate, inputs)` ignored its `validate` argument and always called `validateMerchantId`. That made the "malformed input is rejected" block pass vacuously for currencies, descriptors and webhook URLs. It also meant the credentials rule (user name, password, or both) was only covered by that block. I confirmed this by temporarily deleting the credentials check from the source. At that point the suite would have stayed green.

**Changes in `tests/validators.test.ts`:**
- The helper now calls the validator it is given.
- Added a test that checks the credentials error message for user only, password only, and both.
- Added a test for more IP forms: `127.0.0.1` and IPv4-mapped IPv6.

**Result:** all 23 tests pass. With the credentials check removed again as a mutation test, two tests fail, as they should. I restored the source file afterwards, so only the test file is modified.

VERDICT: inadequate
