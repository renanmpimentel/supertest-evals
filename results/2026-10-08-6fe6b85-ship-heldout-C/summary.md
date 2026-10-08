# Round summary

    date=2026-10-08T13:31:29-03:00 supertest=6fe6b85 model=sonnet repeats=5 prompt=ship arms=without-skill with-skill
    claude=2.1.286 (Claude Code)
    cases=06-payout-fee

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 06-payout-fee (control) | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 0 | 0.08 | 23 |
| 06-payout-fee (control) | with-skill | 5/5 | 5/5 | 5/5 | 5/5 | 0 | 0.16 | 255 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| without-skill | control | 5/5 | 5/5 | 5/5 | 0.39 |
| with-skill | control | 5/5 | 5/5 | 5/5 | 0.79 |
