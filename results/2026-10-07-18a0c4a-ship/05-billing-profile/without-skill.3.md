The original tests did not give enough confidence, so I added tests. The new suite has 21 tests and all pass.

**What was missing:** every "keeps stored value" test used a stored profile whose `companyName` and `taxId` were already `null`. A bug that reset absent optional fields to `null` would have passed. An explicit `undefined` in the patch, which CONTRACT.md says keeps the stored value, was never tested either. Nothing checked an empty patch, all four supported countries, or blank email or country.

**What I added** (in `tests/profile.test.ts`):
- A stored profile with non-null optional fields stays unchanged under an empty patch and under a partial patch.
- Explicit `undefined` in every patch field keeps the stored values.
- All of `BR`, `US`, `PT` and `DE` are accepted when lowercased.
- Blank email and blank country are rejected.
- When email and country are both in the patch and the email is invalid, the error reports `field: "email"`.
- The returned profile is a new object, not `stored`.

The code already behaved as documented, so I didn't change `src/profile.ts`.

VERDICT: inadequate
