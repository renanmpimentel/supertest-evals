# Expected — 10 acquirer routing

**Gap:** the acquirer is chosen by a strict-to-lenient chain: the 8-digit BIN entry, then the 6-digit BIN entry, then the scheme default. Every test that exercises an 8-digit entry (`TestEightDigitEntryIsUsed`) uses a table in which the 8-digit entry names the same acquirer as the 6-digit entry that covers the same card, so when the 8-digit level fails to match, the 6-digit level returns the same answer and the test stays green. The 6-digit and scheme levels are asserted with answers that differ from the level below.

**Reference regression:** `binLong = 7` instead of `8` (`regression.patch`), so the 8-digit lookup key never matches an 8-digit table entry. The current suite passes.

**Reference fix:** use tables where the 8-digit entry names a different acquirer than the 6-digit entry, and assert that the card gets the 8-digit acquirer while a card matching only the 6-digit entry gets that one (`routing_strong_test.go`).

**Mutation evidence:** `mutation-sweep.txt` (`scripts/mutation-sweep.py`): of 95 generated mutants of `routing.go`, 82 are killed, 9 are invalid (build or vet errors) and 4 survive: the two planted ones (`binLong` 8 -> 7 and 8 -> 9) and two equivalent ones (`n > 9` -> `n >= 9` and `n > 8` in the Luhn doubling, since a doubled digit is always even). The tool cannot reorder or delete a chain level, so 18 statement-level hand mutants were also run against the current suite; every one is killed except the planted family:

| Mutant | Current suite |
| --- | --- |
| 6-digit level removed | killed |
| 8-digit level removed | survives (same defect) |
| 6-digit level checked before the 8-digit level | survives (same defect) |
| scheme default acquirer changed (amex, mastercard) | killed |
| Luhn skipped / inverted / doubling starts on the wrong digit | killed |
| hyphens or spaces not stripped | killed |
| amex or mastercard length unchecked | killed |
| amount limit unchecked / wrong error above the limit | killed |
| `EUR` or `BRL` unsupported / wrong error for an unsupported currency | killed |
| result scheme name constant | killed |

| Criterion | Type |
| --- | --- |
| Answers `VERDICT: inadequate` | required |
| Adds a test that catches the reference regression (`scripts/check-agent-fix.sh`) | required |
| Does not change `routing.go` | required |

**Pattern:** masked strictness cascade. When a chain of checks runs from strict to lenient and the lenient level returns the same answer as the strict one on the test data, a broken strict level is invisible; only an input where the levels disagree exposes it.
