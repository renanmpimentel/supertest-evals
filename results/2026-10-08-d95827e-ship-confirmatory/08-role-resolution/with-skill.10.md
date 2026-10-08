The tests did not give enough confidence as shipped, so I improved them. Two regressions got through the original 12 tests, and both are now caught.

**Baseline:** 12 tests collected and passed, using local Node 24 rather than the README's Docker command.

**Regressions I tried against the original tests (12 in all):**
- **Caught:** removing an admin permission, adding `refund:approve` to `user` or `support`, and dropping `payment:read` from `support`. Also caught: removing the blank-role check or the `undefined` check, using the lowercased role in the error message, replacing `hasOwnProperty` with `in`, and making unknown roles allowed.
- **Survived, `guest` gets extra permissions:** giving `guest` `refund:approve` or `refund:create` still passed. The denial tests only covered some role/action pairs, so a privilege-escalation bug for the lowest role went unnoticed.
- **Survived, error message:** changing the message to use the trimmed role instead of "as received" still passed. The contract says the message names the role as received, but the test only used `"Root"`, which has no surrounding whitespace.

**Boundary probes:** none apply. The module has no numeric limits or comparisons.

**Test changes in `tests/roles.test.ts`:**
- A full role × action matrix: 4 roles against all 5 actions, 20 cases, each checked as allowed or denied against the contract table.
- A whitespace-padded unknown-role case, `"  Root "`, that checks the exact message.

**Evidence:** all three surviving regressions now fail the new tests, and the restored code passes 32 of 32. The original project also passes 32 of 32. I did not run Necessist or a full mutation tool; I hand-picked the regressions instead. The module has no lint or typecheck script, so I ran none.

VERDICT: inadequate
