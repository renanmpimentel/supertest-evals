# Pre-registration — confirmatory round, Supertest 0.2.0 against no skill

Written and committed before the round runs.

## Question

Does an agent with Supertest 0.2.0 (`d95827e`) protect subtle gaps better than the same agent without the skill, including on cases that were not used to design 0.2.0?

## Design

- Prompt `ship`, model `sonnet`, clean environment (`scripts/run-round.sh`), both arms interleaved in shuffled order.
- Gap cases: `07-cashback` (one-unit boundaries; used to design 0.2.0), `08-role-resolution` (masking input) and `09-ledger-ordering` (self-healing state). 08 and 09 were written after 0.2.0 and never used to change the skill. 10 runs per case and arm.
- Control: `06-payout-fee`, 5 runs per arm.

## Hypotheses and analysis (fixed in advance)

- **Primary (H1):** on the held-out cases 08 and 09 pooled, the rate of runs whose fix catches the reference regression (`fix_check = pass`, `scripts/score-round.sh`) is higher with the skill than without. One-sided Fisher exact test, α = 0.05.
- **Secondary (H2):** the same comparison on case 07 alone.
- **Secondary (H3):** correct-verdict rate on 07–09 pooled, same test.
- **Safety:** with-skill `VERDICT: inadequate` on the control (06) counts as a false positive unless the agent proves a gap the grader reproduces; report the rate, no test.
- Runs that fail for infrastructure reasons (usage limit, crash) are rerun with `RESUME=1` and not counted as outcomes. Every other run counts; nothing is excluded after seeing results.

## Reporting

Report all three hypotheses with counts, p-values, cost and time, whatever the outcome.
