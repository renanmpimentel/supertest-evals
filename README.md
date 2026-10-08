# Supertest Evals

Payment cases whose tests pass but do not protect the contract. Each gap is proven by script: with a planted regression, the current test stays green and the corrected test turns red. The same cases measure whether an agent finds the gap with and without the [Supertest](https://github.com/renanmpimentel/supertest) skill.

Skill version under evaluation: see `SUPERTEST_VERSION`.

## Cases

| Case | Stack | Current test checks | Regression that goes unnoticed |
| --- | --- | --- | --- |
| [01 idempotent charge](cases/01-idempotent-charge) | Python + pytest | same status and ID on retry | gateway charged twice |
| [02 circuit breaker](cases/02-circuit-breaker) | TypeScript + vitest | fallback message | open circuit keeps calling the gateway |
| [03 payment persistence](cases/03-payment-persistence) | Go + SQLite | `201` and ID | payment is not saved (no commit) |
| [04 refund validation](cases/04-refund-validation) | Python + pytest | rejection of a late refund | refund window check removed |
| [05 billing profile](cases/05-billing-profile) | TypeScript + vitest | absent fields keep their value | absent optional fields erased |
| [06 payout fee](cases/06-payout-fee) | Go | control: tests already protect the contract | — (measures false positives) |
| [07 cashback](cases/07-cashback) | Python + pytest | limits exactly at and far outside 25 / 3,000 | clamps shifted by one unit |

Control cases (marked "control") have no planted gap: their tests already protect the contract, and `verify.sh` proves that a regression is caught. They measure false positives, meaning an agent that claims a gap without proof.

## Prove the gaps

Host requirements: Docker, bash, git and tar. The agent run protocol also needs a clone of the Supertest repository (default `~/export/supertest`; override with `SUPERTEST_REPO`). Optional variables for `scripts/check-skill-version.sh`: `SUPERTEST_INSTALLED` (installed skill copy, default `~/.claude/skills/supertest`) and `SUPERTEST_SHA` (commit to check, instead of the content of `SUPERTEST_VERSION`).

```bash
bash scripts/selftest/run.sh   # the verifier rejects false positives
bash scripts/verify-all.sh     # proves the gap of every case
```

The same checks run in GitHub Actions (`.github/workflows/verify.yml`), plus a check that `prepare-run.sh` never leaks the answer key.

## Run the agent

**Avoid answer-key leakage.** The agent must not read `cases/*/_eval` (not even by absolute path) nor recover it through cross-project memory tools (for example, an MCP memory server that indexed the sessions in which the answer keys were written). Run the agent with such memory tools disabled or out of scope, from a directory outside this repository.

1. Optional: `bash scripts/check-skill-version.sh` checks beforehand that the installed skill copy matches `SUPERTEST_VERSION`; `run-round.sh` runs it anyway.
2. Run the round: `bash scripts/run-round.sh <prompt> [case...]`, with `<prompt>` being `audit` or `ship` (the shared prompts live in `prompts/`). It first runs `scripts/check-skill-version.sh` (and again after the without-skill arm), then parks the installed skill machine-wide (outside `~/.claude/skills`) for the whole `without-skill` arm, so other Claude Code sessions on the machine lack it meanwhile; it restores the skill on exit, including on Ctrl-C. Env vars: `MODEL` (default `sonnet`), `MAX_PARALLEL` (default 3), `SUPERTEST_INSTALLED` (default `~/.claude/skills/supertest`). It prepares a fresh neutral copy per run, runs headless Claude Code in both arms and saves the evidence (`<arm>.md`, `<arm>.diff`, `<arm>.status`, `<arm>.hooks.txt`, `<arm>.transcript.jsonl`, `<arm>.stderr`, `arms.txt`, `runs.log`) in `results/<date>-<sha>-<prompt>/<case>/`. The round-1 folder `results/2026-10-07-18a0c4a/` predates the prompt suffix and used `audit`.

   Hooks from the user's Claude Code settings run in both arms (for comparability with round 1); `<arm>.hooks.txt` records each SessionStart hook's name, exit code and output. When grading, check it for injected memory or context beyond what both arms share. These files can contain private memory or context, so they are gitignored and stay local: graders read them locally and `grades.md` summarizes. The script exits non-zero if any run failed; see `runs.log` (`error=` names the failed steps).

   The `without-skill` arm always runs before the `with-skill` arm, an order/time confound; record it in `grades.md`.

   Before committing a round, skim each `<arm>.md` against `<arm>.hooks.txt` and make sure no private hook-injected content is echoed in the committed files.

   The criteria "does not change production code" and "runs a regression and restores" are graded on the diff, status and transcript, not only on the agent's report.
3. Check each run independently: `bash scripts/check-agent-fix.sh results/<round> <case> <arm>`. It applies the agent's diff to a fresh copy and runs the case's whole suite on correct code (must pass) and with the reference regression (must fail by assertion, not by a build error).
4. Grade each run against `cases/<case>/_eval/expected.md` and update the table below: gap cases use `pass`, `partial` or `fail`; control cases use `pass`, `false positive` or `fail`.

## Results

Model: Claude Code with `sonnet`, Supertest `18a0c4a`, 5 runs per case and arm, in the clean environment described above. Every with-skill `VERDICT: inadequate` was backed by a gap the agent proved by execution and the grader reproduced; neither arm produced a false positive.

| Observation | Without skill | With skill |
| --- | --- | --- |
| Classic planted gaps (01–05): correct verdict and a fix that catches the regression | 25/25 | 25/25 |
| Subtle gaps (one-unit boundaries, rounding, validation order): found and proved a real gap | 1/15 | 7/15 |
| Planted boundary regression (07) caught by the agent's own fix | 0/5 | 1/5 |
| Mean cost / time per run | $0.07 / 30 s | $0.13 / 120 s |

- **Classic gaps:** no difference. The model finds and fixes them without the skill.
- **Subtle gaps:** without the skill the agent mostly reads the suite and calls it adequate; with the skill it runs mutations against the original tests and proves gaps. Fisher exact p = 0.035, but the pooling is post hoc and favours the skill (two of the three observations come from case 06, whose gaps with-skill runs discovered). The comparison designed in advance, case 07, is 3/5 vs 1/5 and not significant on its own.
- **Limitation of the skill:** it found a real gap more often, but rarely the specific boundary regression, because its mutations are hand-picked rather than systematic.

**Skill improvement validated (planned comparison):** Supertest 0.2.0 requires one-unit boundary probes for every limit comparison. On case 07, the agent's fix caught the planted boundary regression in 8/10 runs with 0.2.0 against 0/10 with 0.1.1 (Fisher p = 0.0007), at the same cost; cases 01–06 showed no regression (18/18). Details: [`2026-10-08-d95827e-ship-v020`](results/2026-10-08-d95827e-ship-v020/analysis.md).

Details: [`2026-10-07-18a0c4a-ship`](results/2026-10-07-18a0c4a-ship/analysis.md) (cases 01–06) and [`2026-10-07-18a0c4a-ship-boundary`](results/2026-10-07-18a0c4a-ship-boundary/analysis.md) (cases 06–07). The earlier [`2026-10-07-18a0c4a`](results/2026-10-07-18a0c4a/grades.md) round used the `audit` prompt in the user's own environment, without repetitions or objective scoring.
