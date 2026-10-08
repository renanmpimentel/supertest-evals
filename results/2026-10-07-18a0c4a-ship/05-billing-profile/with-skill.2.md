The original tests were not enough, so I strengthened them. The suite now has 37 tests, all passing against the unmodified source, and `src/profile.ts` is restored and unchanged.

**What was weak.** The original 15 tests passed, but they checked only the stored-value-is-kept rule with `null` optional fields, and they checked no boundaries.

- Mutating `companyName` or `taxId` to always fall back to `null` when the patch omits them still passed. A patch could have silently wiped a customer's company name or tax ID.
- Hardcoding the kept country to `"BR"` still passed, and so did removing `DE` from the allowed countries.
- The email rules were barely checked, so loosening the pattern could slip through.

**What I added** (in `tests/profile.test.ts`):
- Absent and explicit-`undefined` patch fields keep non-null stored values, including a country other than `BR`.
- A patch changes only the field it names, and `applyProfilePatch` returns a new object.
- All four countries are accepted, and `""`, whitespace, `BRA`, `B` and `FR` are rejected with `field: "country"`.
- Malformed emails (empty, no dot, empty local part, empty domain label, empty TLD, spaces, double `@`) are rejected with `field: "email"`, and `a@b.c` is accepted.

**Evidence.** I temporarily broke the source in these ways:
- always `null` for `companyName`
- always `null` for `taxId`
- hardcoded `"BR"` as the kept country
- `DE` removed from the allowed countries
- empty local part allowed in an email
- lowercasing dropped
- blank-text clearing broken
- empty TLD allowed in an email

The new tests caught every one. The empty-TLD case initially survived, so I added `"a@b."` and it now fails as expected. I restored the source after each change and confirmed all 37 pass. I did not run Necessist, only these hand-picked mutations. Tests ran in `node:24-slim` with vitest 3.2.7, as in the README.

VERDICT: inadequate
