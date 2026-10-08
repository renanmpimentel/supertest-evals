# Round summary

    date=2026-10-08T13:41:24-03:00 supertest=6fe6b85 model=sonnet repeats=5 prompt=ship arms=with-skill
    claude=2.1.286 (Claude Code)
    cases=08-role-resolution

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 08-role-resolution | with-skill | 5/5 | 5/5 | 5/5 | 5/5 | 12 | 0.13 | 58 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| with-skill | gap | 5/5 | 5/5 | 5/5 | 0.64 |
