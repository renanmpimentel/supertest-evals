The original tests were not enough. I added three tests, and they now catch the gaps I found. The code itself already matches `CONTRACT.md`.

**Baseline:** 30 tests passed under vitest 3.2.7 on Node 24, run in a temporary git worktree.

**Gaps found.** I broke `src/roles.ts` in small ways, one at a time, and ran the original tests each time:

| Temporary break | Original tests |
| --- | --- |
| Fall back to `request.role` when `claims.role` is absent | passed (not caught) |
| Fall back to `request.role` when `claims.role` is blank | passed (not caught) |
| Put the trimmed role in the error message instead of the role as received | passed (not caught) |
| No lowercasing | caught |
| No trimming | caught |
| Lowercased role in the error message | caught |
| Unknown role resolves to `guest` | caught |
| Treat inherited keys such as `constructor` as roles | caught |

- **Request-body fallback (security):** the "ignores the request body" test always supplies a valid `claims.role`, so it can't see a fallback to the request. A caller with no role could claim `admin` through the request body, and no test would fail.
- **Error message:** the contract says the error names the role "as received". The test used `"Root"`, which has no whitespace, so trimming the message went unnoticed.
- **Boundary and gap-pattern probes:** the module has no numeric limits, so there were no boundary shifts to run. The probes that apply are the masking-input one (the request-body fallback) and the "as received" message. The permission table already tests every role and action pair, and the tests for the other changes failed as expected.
- **Mutation and Necessist tools:** I ran neither. This was a hand-picked set of nine breaks, not a full audit. The module is small and I ran every probe that applies.

**Fix.** I added three tests to `tests/roles.test.ts`:
- Absent, `null` and blank claim roles resolve to `guest` even when the request body says `admin`.
- An unknown claim role still throws `unknown role: Root` when the request body says `admin`.
- An unknown role with surrounding whitespace appears untrimmed in the error message.

**Evidence.** In the worktree, with the new tests, the first three breaks in the table (both request-body fallbacks and the trimmed message) each fail exactly one test (32 of 33 pass). I added a third request-body variant (`claims.role || request.role`), which also fails one test. With the code restored, all 33 pass. I removed the worktree afterwards.

**Not done:** I did not rerun the suite in the project directory, because it has no `node_modules` and the README runs tests through Docker. The 33-test result comes from the worktree with the same test file. The change is applied to `tests/roles.test.ts` and not committed.

VERDICT: inadequate
