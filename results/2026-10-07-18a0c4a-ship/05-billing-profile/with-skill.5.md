The original tests were not enough, so I added tests to `tests/profile.test.ts`. The source is unchanged.

**The gap:** the original 15 tests pass, but they never checked that fields left out of a patch keep non-null stored values. Every stored profile in them had `null` for `companyName` and `taxId` and `"BR"` for country. I broke `src/profile.ts` so those three fields fell back to `null`, `null` and `"BR"` when absent from the patch. All 15 original tests still passed, so a real bug in the "absent field keeps its stored value" rule would have shipped.

**What I added (21 new tests):**
- **Absent and `undefined` fields:** an empty patch and an all-`undefined` patch both return the stored values. I also check that single-field patches leave the other fields alone, that the result is a new object, and that untouched stored values aren't revalidated.
- **Countries and emails:** all four countries are accepted and several near-misses are rejected. Several malformed emails are rejected and a minimal valid one is accepted.

**Evidence:** I ran everything in Docker with `node:24-slim` and vitest 3.2.7, on a copy of the project. The baseline was 36/36 passing. I then applied seven temporary breaks to the source, and the new suite failed on each one:
- absent `companyName` falling back to `null`
- absent `taxId` falling back to `null`
- absent `country` falling back to `"BR"`
- absent `email` falling back to `""`
- `DE` dropped from the allowed countries
- the email regex loosened to accept an empty local part
- the blank-text check changed so only a single space counts as blank

The first three also pass the original suite (I checked them together), which is the gap above. I didn't run the other four against the original tests. I didn't run Necessist or a full mutation tool, so this is a targeted audit, not a full one.

VERDICT: inadequate
