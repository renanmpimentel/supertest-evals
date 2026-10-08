The original tests mostly covered the documented behavior, but one case was missing, so I added tests. All 35 tests now pass against the current code, and I made no changes to `src/roles.ts`.

The missing case was that nothing checked that the request body is ignored when the claims have no role. An implementation could fall back to `request.role` there, which would let a caller grant themselves `admin`. The old tests would not have caught that. The contract says the request body is not a source of roles, and this is the case where that matters most.

I added three things in `tests/roles.test.ts`:
- **Request body ignored:** a request role of `admin` with missing, null, blank or unknown claim roles must still give `guest` or `RoleError`.
- **Error message:** the message must name the role exactly as received, untrimmed.
- **Permission table:** every role is checked against every action in the table, so a wrongly granted or missing permission fails. The old tests left some denials unchecked, such as `guest` with `refund:create`. This also checks that inherited array members like `length` are not treated as actions.

I didn't run mutation checks against the new tests.

VERDICT: inadequate
