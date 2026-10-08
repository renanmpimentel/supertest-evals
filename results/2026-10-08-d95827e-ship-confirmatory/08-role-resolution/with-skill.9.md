The original tests were not enough. They missed two documented behaviors, and I added tests for both.

I ran the suite in an isolated worktree under Docker (`node:24-slim`, vitest). The baseline was 12 of 12 passing. I then made four temporary breaking changes to `src/roles.ts`, each with the original tests:

| Change | Original tests |
|---|---|
| Use `request.role` when the claims have no role | **Still passed** |
| Grant `refund:approve` to `guest` | **Still passed** |
| Put the trimmed or lowercased role in the error message instead of the role as received | Failed, as it should |
| Treat a whitespace-only role as a real role instead of `guest` | Failed, as it should |

The first gap breaks the rule that the request body is not a source of roles. A caller with no role in their token could have sent `{role: "admin"}` and been treated as admin. The tests only checked the case where the token already had a role. The second gap was that the "denies" tests listed a few examples. A role could have been given extra permissions without any test noticing.

I made two additions to `tests/roles.test.ts`:
- **Request-body role:** a new test checks that a missing, null or blank claim role resolves to `guest` even when the request body says `admin`.
- **Permission table:** a new test checks every role against every action and requires exactly the documented table.

With these in place, the clean code passes 14 of 14. Both breaking changes now make one test fail, and I restored the code afterward. The final run in the original project also passes 14 of 14.

The module has no numeric limits, so there were no boundary probes to run. I did not run Necessist or a full mutation tool. I only tried the four hand-picked changes above. I couldn't delete the temporary worktree at `/tmp/tmp.RZovuZNSYj/w` (permission denied), so it's still on disk. Only `tests/roles.test.ts` is modified in the project, and nothing is committed.

VERDICT: inadequate
