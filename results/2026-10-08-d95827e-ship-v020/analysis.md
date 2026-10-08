# Validation — Supertest 0.2.0 (`d95827e`) against 0.1.1 (`18a0c4a`)

Planned comparison (written in the improvements backlog before running): does requiring one-unit boundary probes make the agent catch the planted boundary regression of case 07? With-skill arm only, `ship` prompt, `sonnet`, clean environment, 10 runs per version. The two versions ran one after the other, not interleaved.

| Case 07 (cashback) | 0.1.1 (`18a0c4a-ship-v011`) | 0.2.0 (this folder) |
| --- | --- | --- |
| Agent's fix catches the planted regression | 0/10 | 8/10 |
| Correct verdict (`inadequate`) | 3/10 | 8/10 |
| Production code intact | 10/10 | 10/10 |
| Mean cost / time per run | $0.14 / 54 s | $0.14 / 66 s |

Fisher exact, two-sided, on the planned metric (fix catches the regression): p = 0.0007.

No regression elsewhere (`2026-10-08-d95827e-ship-v020-regression`, 3 runs per case): cases 01–06 all 18/18 on verdict, fix check and production intact; no false positive on the control case 06. Case 03 got slower (545 s mean).
