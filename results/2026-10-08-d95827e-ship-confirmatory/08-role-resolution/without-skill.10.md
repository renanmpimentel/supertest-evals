The existing tests were mostly adequate. They covered every rule in `CONTRACT.md`, including that the request body is ignored, trimming and lowercasing, the guest fallback, and inherited keys like `constructor`.

They had two gaps:
- **Permission table:** only some of the denied cells were checked. For example, nothing tested that `guest` is denied `refund:create` or `refund:approve`. A change that granted a refund action to `guest` would still have passed.
- **Unknown-role message:** the contract says the error names the role "as received". The test only used `"Root"`, which has no padding, so it couldn't tell whether the message used the raw or the trimmed value.

I added two tests to `tests/roles.test.ts`:
- One checks every role against every action and compares the result to the contract table.
- The other checks that `"  Root "` produces the message `unknown role:   Root ` with the padding intact.

All 14 tests pass. I didn't run mutation checks to confirm the new tests fail on a broken implementation.

I haven't committed anything.

VERDICT: inadequate
