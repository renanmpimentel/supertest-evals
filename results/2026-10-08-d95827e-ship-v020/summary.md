# Round summary

    date=2026-10-08T07:46:09-03:00 supertest=d95827e model=sonnet repeats=10 prompt=ship arms=with-skill
    claude=2.1.286 (Claude Code)
    cases=07-cashback

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 07-cashback | with-skill | 8/10 | 8/10 | 10/10 | 10/10 | 8 | 0.14 | 66 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| with-skill | gap | 8/10 | 8/10 | 10/10 | 1.42 |
