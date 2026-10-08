# Confirmatory round — Supertest 0.2.0 against no skill

Pre-registered in `prereg/2026-10-08-confirmatory.md` (commit `3d33208`, before any run). 70 runs, all completed; both arms interleaved in shuffled order. Scores from `summary.md` / `runs.csv`, analysis exactly as registered.

| Hypothesis | With skill | Without skill | One-sided Fisher p | Outcome |
| --- | --- | --- | --- | --- |
| **H1 (primary):** fix catches the reference regression, held-out cases 08+09 | 14/20 | 19/20 | 0.996 | **not supported** |
| H2: fix catches the reference regression, case 07 | 9/10 | 3/10 | 0.0099 | supported |
| H3: correct verdict, cases 07–09 | 29/30 | 21/30 | 0.0061 | supported |
| Safety: control 06 says `inadequate` | 0/5 | 1/5 (not inspected) | — | no skill false positive |

Per case, fix check: 07 9/10 vs 3/10; 08 4/10 vs 9/10; 09 10/10 vs 10/10. Mean cost per run $0.13–0.15 with the skill against $0.07–0.09 without; mean time 83–293 s against 21–33 s. One without-skill run on 07 changed production code (`prod_intact` 9/10).

## What happened on case 08 (found after the round; does not change the outcome)

With the skill, the agent answered `inadequate` in 10/10 runs, but its fix caught the planted masking-input regression (`claims.role ?? request.role`) in only 4/10. In the other runs it proved a different, real gap: the permission table never checks `guest` against `refund:create` or `refund:approve`. The grader reproduced it: giving `guest` the `refund:create` permission passes all 12 original tests. So case 08 has an unplanted second gap, which the case review missed. The skill's agents chased that gap; without the skill, the agent fixed the planted, more visible one (the test named "ignores the role in the request body" sends both roles).

## Reading

- The skill reliably improves what 0.2.0 targeted (one-unit boundaries, case 07) and makes verdicts more accurate.
- On held-out cases it did **not** produce better fixes: equal on 09 (self-healing state), worse on 08, where it found a different real gap instead of the planted one.
- The evidence supports "Supertest 0.2.0 helps on boundary-style gaps and on deciding whether tests are adequate", not "it generally produces better test fixes".

## Follow-ups

- Close the `guest` permission gap in case 08 and re-sweep it with statement-level mutants.
- Make the skill apply the gap-pattern catalogue (masking input) as systematically as the boundary probes; validate with a new held-out case.
