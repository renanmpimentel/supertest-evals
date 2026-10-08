The original tests didn't give enough confidence, so I added tests. All 16 pass.

The implementation matches `CONTRACT.md`. The gaps were in the tests.

- **Escalation case:** The tests only checked that the request-body role is ignored when the claims also had a role. A change like `claims.role ?? request.role` would have passed every original test. That change would let a caller with no role claim send `{role: "admin"}` and become admin. I added tests that claims with no role, a null role or a blank role resolve to `guest` even when the body says `admin`. I also added one showing that an unknown claim role still throws when the body says `admin`.
- **Permission table:** The denial checks were hand-picked, so an extra grant could slip through. For example, `refund:approve` added to `guest` would not have been caught. One new test now checks every role against every action and compares the result with the documented table. I also added tests that inherited names such as `constructor` and `length` are denied as actions, and that role names in `isAllowed` are case-sensitive.

I didn't change `src/roles.ts` and haven't committed anything.

VERDICT: inadequate
