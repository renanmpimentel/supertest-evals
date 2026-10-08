# Round summary

    date=2026-10-08T07:55:05-03:00 supertest=d95827e model=sonnet repeats=3 prompt=ship arms=with-skill
    claude=2.1.286 (Claude Code)
    cases=01-idempotent-charge 02-circuit-breaker 03-payment-persistence 04-refund-validation 05-billing-profile 06-payout-fee

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 01-idempotent-charge | with-skill | 3/3 | 3/3 | 3/3 | 3/3 | 37 | 0.10 | 63 |
| 02-circuit-breaker | with-skill | 3/3 | 3/3 | 3/3 | 3/3 | 80 | 0.11 | 42 |
| 03-payment-persistence | with-skill | 3/3 | 3/3 | 3/3 | 3/3 | 104 | 0.19 | 545 |
| 04-refund-validation | with-skill | 3/3 | 3/3 | 3/3 | 3/3 | 32 | 0.16 | 156 |
| 05-billing-profile | with-skill | 3/3 | 3/3 | 3/3 | 3/3 | 22 | 0.14 | 78 |
| 06-payout-fee (control) | with-skill | 3/3 | 3/3 | 3/3 | 3/3 | 0 | 0.16 | 246 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| with-skill | control | 3/3 | 3/3 | 3/3 | 0.48 |
| with-skill | gap | 15/15 | 15/15 | 15/15 | 2.08 |
