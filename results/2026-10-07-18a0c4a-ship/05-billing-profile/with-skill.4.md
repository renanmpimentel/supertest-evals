The original tests don't give enough confidence, so I added tests to `tests/profile.test.ts`. The original suite passed 15/15, but it let real defects through.

I mutated `src/profile.ts` in a scratch copy and ran the original tests against three of the defects:

- **`DE` removed from the allowed countries:** the original tests still passed.
- **An absent `companyName` reset to `null` instead of keeping the stored value:** the original tests still passed.
- **An absent `country` reset to `"BR"`:** the original tests still passed.

All three pass because the original fixtures store `BR` and `null`, so a reset looks the same as keeping the value. `DE`, `taxId` kept when only other fields are patched, and the other three countries were never tested.

I added 15 tests. They cover:

- an empty patch;
- explicit `undefined`;
- every optional field keeping its stored value when only others are patched;
- all four countries accepted and unsupported ones rejected;
- blank and malformed emails, including blank and invalid country, with the right `field` on the error;
- that a new object is returned and `stored` is left unchanged.

The suite now passes 30/30. All eight mutants I tried are caught by the new suite. They were:

- dropping `DE`;
- skipping email normalization;
- resetting each of `companyName`, `taxId` and `country` when absent;
- loosening the email regex;
- removing `toLowerCase`;
- breaking the blank-to-`null` rule.

I did not run Necessist, and the mutations were hand-picked rather than from a mutation tool. The test changes are uncommitted in the working tree.

VERDICT: inadequate
