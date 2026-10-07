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

## Prove the gaps

Host requirements: Docker, bash, git and tar. The agent run protocol also needs a clone of the Supertest repository (default `~/export/supertest`; override with `SUPERTEST_REPO`). Optional variables for `scripts/check-skill-version.sh`: `SUPERTEST_INSTALLED` (installed skill copy, default `~/.claude/skills/supertest`) and `SUPERTEST_SHA` (commit to check, instead of the content of `SUPERTEST_VERSION`).

```bash
bash scripts/selftest/run.sh   # the verifier rejects false positives
bash scripts/verify-all.sh     # proves the gap of every case
```

The same checks run in GitHub Actions (`.github/workflows/verify.yml`), plus a check that `prepare-run.sh` never leaks the answer key.

## Run the agent (manual protocol)

**Avoid answer-key leakage.** The agent must not read `cases/*/_eval` (not even by absolute path) nor recover it through cross-project memory tools (for example, an MCP memory server that indexed the sessions in which the answer keys were written). Run the agent with such memory tools disabled or out of scope, from a directory outside this repository.

1. `bash scripts/check-skill-version.sh` — the installed skill copy must match `SUPERTEST_VERSION`.
2. Run the round: `bash scripts/run-round.sh <prompt> [case...]`, with `<prompt>` being `audit` or `ship` (the shared prompts live in `prompts/`). It first runs `scripts/check-skill-version.sh` (and again after the without-skill arm), then parks the installed skill machine-wide (outside `~/.claude/skills`) for the whole `without-skill` arm, so other Claude Code sessions on the machine lack it meanwhile; it restores the skill on exit, including on Ctrl-C. Env vars: `MODEL` (default `sonnet`), `MAX_PARALLEL` (default 3), `SUPERTEST_INSTALLED` (default `~/.claude/skills/supertest`). It prepares a fresh neutral copy per run, runs headless Claude Code in both arms and saves the evidence (`<arm>.md`, `<arm>.diff`, `<arm>.status`, `<arm>.hooks.txt`, `<arm>.transcript.jsonl`, `arms.txt`, `runs.log`) in `results/<date>-<sha>-<prompt>/<case>/`. The round-1 folder `results/2026-10-07-18a0c4a/` predates the prompt suffix and used `audit`.

   Hooks from the user's Claude Code settings run in both arms (for comparability with round 1); `<arm>.hooks.txt` records each SessionStart hook's name, exit code and output. When grading, check it for injected memory or context beyond what both arms share. These files can contain private memory or context, so they are gitignored and stay local: graders read them locally and `grades.md` summarizes. The script exits non-zero if any run failed; see `runs.log` (`error=` names the failed steps).

   The criteria "does not change production code" and "runs a regression and restores" are graded on the diff, status and transcript, not only on the agent's report.
3. Check each run independently: `bash scripts/check-agent-fix.sh results/<round> <case> <arm>`. It applies the agent's diff to a fresh copy and runs the case's whole suite on correct code (must pass) and with the reference regression (must fail by assertion, not by a build error).
4. Grade each run against `cases/<case>/_eval/expected.md` (`pass`, `partial`, `fail`) and update the table below.

## Results

| Date | Skill | Agent | Case | Without skill | With skill |
| --- | --- | --- | --- | --- | --- |
| 2026-10-07 | `18a0c4a` | Claude Code, sonnet | 01 idempotent charge | pass | pass |
| 2026-10-07 | `18a0c4a` | Claude Code, sonnet | 02 circuit breaker | pass | pass |
| 2026-10-07 | `18a0c4a` | Claude Code, sonnet | 03 payment persistence | pass | pass (no final report) |

First round: the planted gaps did not separate the arms — the model found and proved them without the skill. With the skill, every run mutated an isolated copy instead of the project's production files. Details: [results/2026-10-07-18a0c4a/grades.md](results/2026-10-07-18a0c4a/grades.md).
