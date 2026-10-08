The tests you were given did not protect the documented behavior, so I improved them. They now pass (25 tests), and the source is unchanged.

**The problem:** the `expectAllRejected` helper took a `validate` argument but always called `validateMerchantId`. That had two effects:
- The "malformed input is rejected" block checked nothing for currencies, descriptors or webhook URLs. Merchant-id validation rejects every one of those inputs, so they all passed.
- The credentials rule (user name or password in a webhook URL) was tested only inside that block. With the credential check removed from the source, the old suite would have stayed green.

**What I changed in `tests/validators.test.ts`:**
- The helper now calls the validator it is given.
- Added a direct test for credentials: user and password, user only, and password only.
- Added more IP cases: other IPv4 addresses and an IPv4-mapped IPv6 address.
- Added trailing-newline rejection for merchant ids and descriptors.

I checked this by temporarily removing the credentials check from the source. Two tests failed, and I then restored the source.

The remaining tests already covered the documented rules, including the length boundaries, the error messages and the return-unchanged behavior.

VERDICT: inadequate
