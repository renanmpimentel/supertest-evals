# Round summary

    date=2026-10-08T13:02:56-03:00 supertest=328e6eb model=sonnet repeats=10 prompt=ship arms=with-skill
    claude=2.1.286 (Claude Code)
    cases=10-acquirer-routing 11-payment-identifiers

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 10-acquirer-routing | with-skill | 10/10 | 10/10 | 10/10 | 10/10 | 25 | 0.21 | 376 |
| 11-payment-identifiers | with-skill | 10/10 | 10/10 | 10/10 | 10/10 | 8 | 0.12 | 84 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| with-skill | gap | 20/20 | 20/20 | 20/20 | 3.31 |
