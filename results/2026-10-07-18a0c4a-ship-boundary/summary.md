# Round summary

    date=2026-10-07T21:35:37-03:00 supertest=18a0c4a model=sonnet repeats=5 prompt=ship
    claude=2.1.285 (Claude Code)
    cases=06-payout-fee 07-cashback

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 06-payout-fee (control) | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 6 | 0.07 | 36 |
| 06-payout-fee (control) | with-skill | 4/5 | 5/5 | 5/5 | 5/5 | 2 | 0.13 | 138 |
| 07-cashback | without-skill | 1/5 | 0/5 | 5/5 | 0/5 | 11 | 0.07 | 22 |
| 07-cashback | with-skill | 3/5 | 1/5 | 5/5 | 5/5 | 6 | 0.16 | 110 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| without-skill | control | 5/5 | 5/5 | 5/5 | 0.36 |
| without-skill | gap | 1/5 | 0/5 | 5/5 | 0.36 |
| with-skill | control | 4/5 | 5/5 | 5/5 | 0.66 |
| with-skill | gap | 3/5 | 1/5 | 5/5 | 0.78 |
