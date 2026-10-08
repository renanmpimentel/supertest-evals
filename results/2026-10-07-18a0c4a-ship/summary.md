# Round summary

    date=2026-10-07T15:43:05-03:00 supertest=18a0c4a model=sonnet repeats=5 prompt=ship
    claude=2.1.285 (Claude Code)
    cases=01-idempotent-charge 02-circuit-breaker 03-payment-persistence 04-refund-validation 05-billing-profile 06-payout-fee

Gap cases expect `VERDICT: inadequate` and a fix that catches the reference regression; the control case expects `VERDICT: adequate`. Rates are runs meeting the criterion / runs.

| Case | Arm | Correct verdict | Fix check | Production intact | Skill loaded | Test lines added (mean) | Cost USD (mean) | Seconds (mean) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 01-idempotent-charge | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 40 | 0.07 | 28 |
| 01-idempotent-charge | with-skill | 5/5 | 5/5 | 5/5 | 5/5 | 32 | 0.10 | 59 |
| 02-circuit-breaker | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 63 | 0.07 | 21 |
| 02-circuit-breaker | with-skill | 5/5 | 5/5 | 5/5 | 5/5 | 69 | 0.10 | 46 |
| 03-payment-persistence | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 108 | 0.08 | 73 |
| 03-payment-persistence | with-skill | 5/5 | 5/5 | 5/5 | 5/5 | 93 | 0.14 | 302 |
| 04-refund-validation | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 21 | 0.08 | 31 |
| 04-refund-validation | with-skill | 5/5 | 5/5 | 5/5 | 5/5 | 24 | 0.12 | 102 |
| 05-billing-profile | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 38 | 0.07 | 25 |
| 05-billing-profile | with-skill | 5/5 | 5/5 | 5/5 | 5/5 | 50 | 0.12 | 61 |
| 06-payout-fee (control) | without-skill | 5/5 | 5/5 | 5/5 | 0/5 | 0 | 0.06 | 31 |
| 06-payout-fee (control) | with-skill | 2/5 | 5/5 | 5/5 | 5/5 | 3 | 0.12 | 141 |

## Totals per arm

| Arm | Kind | Correct verdict | Fix check | Production intact | Cost USD (total) |
| --- | --- | --- | --- | --- | --- |
| without-skill | control | 5/5 | 5/5 | 5/5 | 0.31 |
| without-skill | gap | 25/25 | 25/25 | 25/25 | 1.85 |
| with-skill | control | 2/5 | 5/5 | 5/5 | 0.61 |
| with-skill | gap | 25/25 | 25/25 | 25/25 | 2.91 |
