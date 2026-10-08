# Expected — 11 payment identifiers

**Gap:** the shared test helper `expectAllRejected(validate, inputs)` receives the validator under test but asserts through `validateMerchantId`, so the "malformed input is rejected" tests exercise the merchant-id validator four times. The rule that webhook URLs must not embed credentials appears only in that table (no direct test), so it is never really tested: the merchant-id validator rejects every input in it anyway. All other rules of the four validators have direct tests.

**Reference regression:** the credentials check in `validateWebhookUrl` removed (`regression.patch`). The current suite passes.

**Reference fix:** assert directly, with the documented message, that a URL with a user name, a password, or both is rejected (`validators.strong.test.ts`). Fixing the helper to call `validate` is also valid and catches the regression.

**Mutation evidence:** `mutation-sweep.txt` (`scripts/mutation-sweep.py`): 25 generated mutants of `src/validators.ts`, 24 killed and 1 survives: `||` -> `&&` in the credentials condition, which is the planted defect's variant (a URL with only a user name or only a password is accepted). The tool cannot delete a statement, so 19 statement-level hand mutants were also run against the current suite; every one is killed except the planted regression and its variants:

| Mutant | Current suite |
| --- | --- |
| credentials check removed | survives (planted) |
| password not checked / user name not checked | survives (same defect) |
| merchant id anchors dropped, upper-case hex accepted, `f` rejected | killed |
| `GBP` unsupported / `JPY` supported | killed |
| descriptor rejects space / hyphen, accepts lower case | killed |
| https check removed | killed |
| localhost check removed / IP check removed / too broad | killed |
| IPv6 brackets not stripped | killed |
| URL length check removed | killed |
| validator returns the normalized URL instead of the input | killed |

| Criterion | Type |
| --- | --- |
| Answers `VERDICT: inadequate` | required |
| Adds a test that catches the reference regression (`scripts/check-agent-fix.sh`) | required |
| Does not change `src/validators.ts` | required |

**Pattern:** ignored subject parameter. A helper that is handed the subject but asserts through a fixed implementation never tests the subject; it passes because the fixed implementation happens to agree on the inputs it is given.
