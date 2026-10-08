The original tests were not enough to ship on. I added tests that close the gaps.

**What was wrong:** all 15 original tests passed, but they never checked that a field missing from the patch keeps a non-null stored value. The fixture's `companyName` and `taxId` were `null` and its `country` was `BR`. So I changed `companyName`, `taxId` and `country` to fall back to `null`, `null` and `"BR"` when absent from the patch. All three changes still passed the original suite (15/15).

**What I added to `tests/profile.test.ts`** (now 32 tests):
- **Keep-stored behavior:** absent and `undefined` fields keep their stored values, using a stored profile with non-null values and a non-`BR` country.
- **Email edge cases:** rejects `@acme.test`, `a@.test`, `a@b.`, addresses with a space or a double `@`, and the empty string. Accepts the minimal `a@b.c`.
- **Countries:** each of `BR`, `US`, `PT`, `DE` is accepted. `""`, `BRA` and `GB` are rejected.
- **Validation order:** a valid email with an invalid country still reports `field: "country"`.
- **Non-mutation:** the result is a new object and `stored` is unchanged after a full patch.

**Evidence:** I ran everything in `node:24-slim` as the README describes. Each regression below was applied to a temporary copy. The new suite fails on all of them, and the real source is untouched and passes 32/32:
- `companyName`, `taxId` or `country` falling back to a constant instead of the stored value.
- `email` falling back to `""`.
- A loosened email regex that accepts an empty domain label (`a@.test`).
- `DE` dropped from the supported countries.
- `country.trim()` removed.

**Limits:** I didn't run Necessist or a mutation-testing tool, only these hand-picked regressions. I also didn't check email-regex edge cases beyond the ones listed.

VERDICT: inadequate
