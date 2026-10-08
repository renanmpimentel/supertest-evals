The original tests didn't give enough confidence. The module itself matches `CONTRACT.md`, and all 20 tests pass now (15 original plus 5 I added).

**What was missing**
- **Absent fields:** the only "keeps absent fields" test used a stored profile whose `companyName` and `taxId` were already `null`. A bug that reset absent optional fields to `null` would have passed. The same test only ever kept `country: "BR"`.
- **Explicit `undefined`:** the contract says it keeps the stored value, but no test covered it.
- **Blank email or country:** no test checked that a blank value in the patch is rejected instead of silently keeping the stored one.
- **Failed patches:** no test checked that `stored` is untouched after a patch throws.

**Tests I added in `tests/profile.test.ts`**
- Populated stored values are kept for every absent field. This covers an empty patch and single-field patches.
- Explicit `undefined` on all four fields is treated as absent.
- Stored values that aren't patched are not re-validated or altered.
- Blank email and blank country are rejected with the correct `field`.
- The result is a new object, and `stored` is unchanged after a failed patch.

I didn't change `src/profile.ts`.

VERDICT: inadequate
