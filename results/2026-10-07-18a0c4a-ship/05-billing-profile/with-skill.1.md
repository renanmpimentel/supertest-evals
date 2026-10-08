The existing tests did not give enough confidence, so I added tests to `tests/profile.test.ts`.

**Baseline:** the original 15 tests passed. I ran them with the global vitest 5.0.3, not the README's Docker command, because `node_modules` isn't installed. With my additions the suite is 24 tests, all passing.

**Gaps in the original tests:**
- **Stored optional values:** every "keeps stored value" case used `companyName: null` and `taxId: null`. A change that wiped a stored, non-null `companyName` or `taxId` when the patch omitted it would still pass.
- **Explicit `undefined` and empty patch:** the contract says these keep the stored value, and nothing tested it.
- **Validation:** only one bad value was tried per rule. The tests didn't cover all four countries, whether `country` is trimmed before validation, or the shapes of email the regex must reject.
- **Atomicity:** nothing checked that a failed patch leaves `stored` unchanged.

**What I added:** tests for each gap above, plus whitespace-only clearing (tabs, newlines) and inner-whitespace preservation.

**Temporary regressions:** I applied each of these to `src/profile.ts` and ran the suite. All were caught, and `src/profile.ts` is restored (`git diff src` is empty):
- Absent `companyName` becomes `null`: 3 failures.
- Absent `taxId` becomes `null`: 3 failures.
- Email regex loosened to accept an empty local part or domain: 1 failure.
- Country not trimmed before validation: 2 failures.
- `DE` dropped from the supported countries: 1 failure.

**Limits:**
- This was a targeted check, not a full mutation or Necessist run.
- I didn't run the original 15 tests against the regressions. That the two "keep stored value" regressions slipped past them is my reading of the old fixtures, not something I observed.

VERDICT: inadequate
