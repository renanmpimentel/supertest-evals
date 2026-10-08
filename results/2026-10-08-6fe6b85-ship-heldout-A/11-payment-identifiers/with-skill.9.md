The tests did not protect the documented behavior. The webhook rule "must not embed credentials" had no working test, so I fixed that.

**What was wrong**
- `expectAllRejected(validate, inputs)` in `tests/validators.test.ts` ignored its `validate` argument and always called `validateMerchantId`.
- Every "malformed input is rejected" block therefore tested merchant ids only. That includes the webhook block, which held the only credentials cases.
- I ran 22 temporary regressions on an isolated copy against the original 21 tests, which passed. Five survived, and all five were credentials regressions:
  - removing the credentials check
  - checking only the user name
  - checking only the password
  - requiring both user name and password
  - changing the error message
- The other 17 regressions were caught. They covered the 22-character and 2,048-character limits shifted one unit each way, the 12-digit hex count shifted one each way, a dropped currency, the localhost and IP checks, bracket stripping for IPv6, the https check, returning a normalized URL, and the other messages.

**What I changed** (`tests/validators.test.ts`, applied to the project)
- The helper now calls the `validate` it receives.
- I added a test that rejects user-only, password-only and user-plus-password URLs, and checks the exact `webhook url must not contain credentials` message.

**Evidence**
- With the fix, all five credentials regressions are now caught.
- A temporary regression that dropped `GBP` also fails through the repaired helper.
- With the code restored, 22 of 22 tests pass in the project. `src/` is untouched.

**Not run:** Necessist and a full mutation tool. I used hand-picked regressions (including one-unit shifts on both limits), not a tool-driven mutation run. I ran Vitest directly on Node 24 instead of the README's Docker command, and I didn't run lint or typecheck because the project has neither script.

VERDICT: inadequate
