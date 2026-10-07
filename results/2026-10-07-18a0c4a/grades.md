# Round 2026-10-07 — Supertest 18a0c4a

Agent: Claude Code 2.1.285, headless (`claude -p`), model `sonnet`, `--strict-mcp-config` (no MCP servers), `bypassPermissions`, one run per arm. Without-skill arm: `~/.claude/skills/supertest` moved out of the skills folder; other installed skills and plugins were present in both arms.

Evidence per run: `<arm>.md` (final report), `<arm>.diff`, `<arm>.status`. Transcripts were kept locally. The 01/02 diffs were regenerated excluding build artifacts (`node_modules`, `__pycache__`) that the copies lacked a `.gitignore` for; cases now ship one.

Independent check (not the agents' claims): each agent's diff was applied to a fresh copy; its test suite passes on correct code and fails with `_eval/regression.patch`. No transcript references `supertest-evals` or `_eval`.

## Grades

| Case | Arm | Gap identified | Regression executed (old passes, new fails) | Production code unchanged | Grade | Time |
| --- | --- | --- | --- | --- | --- | --- |
| 01 idempotent charge | without skill | yes | yes (2 mutants, in the project, restored) | yes | pass | 72 s |
| 01 idempotent charge | with skill | yes | yes (isolated copy) | yes | pass | 79 s |
| 02 circuit breaker | without skill | yes | yes (7 mutants, in the project, restored) | yes | pass | 63 s |
| 02 circuit breaker | with skill | yes | yes (6 regressions, isolated copy) | yes | pass | 98 s |
| 03 payment persistence | without skill | yes | yes (5 mutants, copy in /tmp) | yes | pass | 427 s |
| 03 payment persistence | with skill | yes | yes (`no commit old=PASS new=FAIL`, isolated copy) | yes | pass, no final report | 588 s |

## Observations

- **The cases do not discriminate.** Sonnet without the skill found and proved every planted gap. The spec listed this risk; the contracts and READMEs are probably too explicit for this model, and the gaps are classic ones.
- **Process differences favour the skill:** with the skill, all three runs mutated an isolated copy and reported limitations (progressive audit, no mutation tool or Necessist). Without it, two runs mutated production files in the project and restored them with `cp`/`sed`.
- **Breadth was similar:** both arms also covered contract clauses beyond the planted gap (01: different keys; 02: closed-circuit message, success reset, threshold; 03: invalid inputs saving nothing).
- **03 with skill, first attempt:** stopped by an account usage limit after 358 s; archived in `03-payment-persistence/failed-attempt/` and rerun.
- **03 with skill, rerun:** the agent left mutation runs in the background and ended the headless session before writing its report ("The last two mutations are running in the background"). Its test changes and executed regressions are in the diff and transcript.
- **02 with skill:** reported that Docker and `rm -rf node_modules` were denied, despite `bypassPermissions`; it ran vitest on the host instead.
- One run per arm is anecdotal; repeated runs are phase 2.
