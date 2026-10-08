# Analysis — round 2026-10-07, `ship` prompt, cases 06 and 07, N=5

Same clean environment as `results/2026-10-07-18a0c4a-ship` (no user settings, plugins, hooks or MCP; the skill is the only difference). 20 runs, all completed. `summary.md` is the automatic score; this file adds what the grader reproduced.

## What the "inadequate" verdicts were based on

Every with-skill run that answered `inadequate` proved a gap by running a mutant against the original suite, and the grader reproduced each one:

| Run | Gap proved | Reproduced against the original suite |
| --- | --- | --- |
| 07 with-skill.5 | the planted one: clamps shifted by one unit | yes (`verify.sh`) |
| 07 with-skill.2, .4 | unknown tier not rejected for an amount of 0, against "whatever the amount" (unplanted) | yes: `16 passed` with the tier check skipped at 0 |
| 06 with-skill.1 | half-up rounding never exercised for `card` (unplanted) | yes: `go test` passes with truncation for `card` only |

The one without-skill `inadequate` (07 run 3) named the amount-0 gap by reading, but could not run the tests, so it executed no regression.

Neither unplanted gap is a single-token mutation, so `scripts/mutation-sweep.py` did not generate them. Both were closed after this round (see each case's `_eval/expected.md`).

## Reading

- **Case 06 (control at the time):** without skill 5/5 `adequate`; with skill 4/5 `adequate` and 1/5 a proven real gap. No false positive in either arm.
- **Case 07:** without skill 1/5 found a gap (not executed); with skill 3/5 found and proved one. The planted boundary regression was caught by the agent's own fix in 0/5 runs without the skill and 1/5 with it.
- **Cost and time:** with the skill, about 1.9× the cost ($0.14 vs $0.07 per run) and about 4× the time (124 s vs 29 s).

## Pooled subtle-gap detection (post hoc)

| Observation | Without skill | With skill |
| --- | --- | --- |
| 06, earlier suite (round `-ship`) | 0/5 | 3/5 |
| 07 cashback (this round) | 1/5 | 3/5 |
| 06, card rounding gap (this round) | 0/5 | 1/5 |
| Total | 1/15 | 7/15 |

Fisher exact, two-sided: p = 0.035. This pooling is post hoc and biased in the skill's favour: the 06 gaps were discovered by with-skill runs. The only comparison designed in advance, case 07, is 3/5 vs 1/5, which is not significant on its own.
