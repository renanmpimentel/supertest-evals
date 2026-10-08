The tests you were given were not enough to ship on, so I added more. The implementation itself already matches `CONTRACT.md`, and all 34 tests now pass.

**What was missing**
- **Request body as a fallback:** nothing tested the case where the claims have no role and the body says `admin`. An implementation that fell back to the body would have passed every existing test. That is a privilege-escalation hole, and the contract explicitly rules it out.
- **Permission table:** only some of the allowed and denied combinations were checked. For example, nothing checked that `guest` can't do `refund:create` or `refund:approve`, so someone could have granted `guest` those actions without a test failing.

**What I added** (in `tests/roles.test.ts`)
- A test that the body role is never used when the claims role is missing, `null` or blank. It also checks that an unknown claims role still raises `RoleError` even when the body says `admin`.
- A test for every role and action pair in the contract, 20 in all, checked against the documented table.
- A test that inherited property names such as `constructor` and `length` are not treated as allowed actions.

I didn't run mutations against the implementation to confirm the new tests catch these cases. I only confirmed they pass on the current code.

VERDICT: inadequate
