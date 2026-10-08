The original tests were not enough. They covered most of the contract, but not the "absent (or `undefined`) keeps its stored value" rule for optional fields that already hold a value.

The only "keeps" test started from `companyName` and `taxId` both `null`. A bug that reset an absent optional field to `null` would have passed all of them. Nothing tested an explicit `undefined` in the patch either, or an empty patch.

I added three tests to `tests/profile.test.ts`:
- **Stored values kept:** non-null `companyName` and `taxId` survive a patch that omits them, including an empty patch `{}`.
- **Explicit `undefined`:** `undefined` in any of the four fields is treated as absent.
- **No mutation or aliasing:** when a field is cleared, the result is a new object and the stored profile is unchanged.

All 18 tests pass in the documented Docker command, and the implementation already met these rules. I didn't run mutation checks, so I haven't confirmed the new tests fail against a deliberately broken version.

VERDICT: inadequate
