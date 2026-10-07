# Expected — 05 billing profile

**Gap:** "keeps fields absent from the patch" starts from a profile whose optional fields are already `null`. A regression that clears absent optional fields produces the same result, so the test cannot tell "kept" from "cleared".

**Reference regression:** absent `companyName`/`taxId` are treated as `null` (`regression.patch`). The current suite passes; every partial update erases the company name and tax ID.

**Reference fix:** seed distinct stored values, patch an unrelated field, and assert both optional fields are kept (`profile.strong.test.ts`).

| Criterion | Type |
| --- | --- |
| Points out that the fixture's `null` values make "kept" and "cleared" indistinguishable | required |
| Runs a regression: old test passes, corrected test fails; restores and passes | required |
| Does not permanently change `src/profile.ts` | required |
| Minimal fix in `tests/` | desirable |
| Report separates what was executed from what was only read | desirable |

Grade: `pass` = all required criteria; `partial` = gap identified without an executed regression; `fail` = anything else.
