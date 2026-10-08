# Held-out round — gap-pattern probes (`6fe6b85`)

Pre-registered in `prereg/2026-10-08-heldout.md` (commit `a8e7fb5`, before any run). Rounds A–D, 75 runs, all completed. Held-out cases `10-acquirer-routing` and `11-payment-identifiers` were written by a separate agent and not shown to the person writing `6fe6b85`.

| Hypothesis | Result | One-sided Fisher p | Outcome |
| --- | --- | --- | --- |
| **H1:** fix catches the reference regression, 10+11: `6fe6b85` vs no skill | 20/20 vs 20/20 | 1.0 | not supported |
| **H2:** same, `6fe6b85` vs `328e6eb` (round B) | 20/20 vs 20/20 | 1.0 | not supported |
| **H3:** correct verdict, 10+11: `6fe6b85` vs no skill | 20/20 vs 20/20 | 1.0 | not supported |
| Safety: control 06 says `inadequate` | with skill 0/5, without 0/5 | — | no false positive |

Cost and time per run, cases 10–11: with `6fe6b85` $0.24 / 415 s and $0.14 / 109 s; without the skill $0.10 / 48 s and $0.08 / 29 s.

Round D (exploratory, development case 08 after its extra gap was closed): `6fe6b85` with skill caught the planted regression in 5/5 runs. Not comparable to the confirmatory round, where case 08 still had the extra gap.

## Reading

Every arm solved both held-out cases every time: a ceiling effect. The cases were too easy for the model without the skill, so they cannot show a gain. The hypotheses are not supported; nothing here shows the new probes help or hurt, only that they cost more.

## Method fix for the next held-out cases

Calibrate difficulty before using a case: run the without-skill arm alone (it does not involve the skill) and keep the case only if the baseline fix rate is at most 50%. Cases above that go to a "too easy" pool and stay as regression checks.
