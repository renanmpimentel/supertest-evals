# Round summary

    date=2026-10-08T12:19:47-03:00 supertest=6fe6b85 model=sonnet repeats=10 prompt=ship arms=without-skill with-skill
    claude=2.1.286 (Claude Code)
    cases=10-acquirer-routing 11-payment-identifiers

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 10-acquirer-routing | without-skill | 10/10 | 10/10 | 10/10 | 0/10 | 29 | 0.10 | 48 |
| 10-acquirer-routing | with-skill | 10/10 | 10/10 | 10/10 | 10/10 | 24 | 0.24 | 415 |
| 11-payment-identifiers | without-skill | 10/10 | 10/10 | 10/10 | 0/10 | 15 | 0.08 | 29 |
| 11-payment-identifiers | with-skill | 10/10 | 10/10 | 10/10 | 10/10 | 8 | 0.14 | 109 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| without-skill | gap | 20/20 | 20/20 | 20/20 | 1.75 |
| with-skill | gap | 20/20 | 20/20 | 20/20 | 3.78 |
