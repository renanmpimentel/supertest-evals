# Round summary

    date=2026-10-08T08:39:54-03:00 supertest=d95827e model=sonnet repeats=10 prompt=ship arms=without-skill with-skill
    claude=2.1.286 (Claude Code)
    cases=07-cashback 08-role-resolution 09-ledger-ordering

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 07-cashback | without-skill | 4/10 | 3/10 | 9/10 | 0/10 | 26 | 0.08 | 25 |
| 07-cashback | with-skill | 9/10 | 9/10 | 10/10 | 10/10 | 11 | 0.15 | 86 |
| 08-role-resolution | without-skill | 9/10 | 9/10 | 10/10 | 0/10 | 30 | 0.07 | 21 |
| 08-role-resolution | with-skill | 10/10 | 4/10 | 10/10 | 10/10 | 17 | 0.13 | 83 |
| 09-ledger-ordering | without-skill | 8/10 | 10/10 | 10/10 | 0/10 | 39 | 0.09 | 31 |
| 09-ledger-ordering | with-skill | 10/10 | 10/10 | 10/10 | 10/10 | 13 | 0.13 | 92 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| without-skill | gap | 21/30 | 22/30 | 29/30 | 2.37 |
| with-skill | gap | 29/30 | 23/30 | 30/30 | 4.11 |
