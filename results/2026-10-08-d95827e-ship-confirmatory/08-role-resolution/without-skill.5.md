The original tests were mostly adequate, but one gap mattered, so I improved them. The module already matches the documented behavior, and all 15 tests pass with my additions.

**What was already covered:** claims-over-body precedence, trim and lowercase, the guest fallback, unknown roles raising `RoleError` with the role as received, one inherited-key case, and the permission table.

**What was missing:**
- **Security gap:** nothing tested a request-body role when the claims have no role. A bug like `claims.role ?? request.role` would have let a client claim `admin` and still passed every test. I added this for missing, null and blank claim roles.
- **Smaller gaps I also filled:**
  - Each known role resolving from the claims.
  - The body role not being validated.
  - Guest denied `refund:create` and `refund:approve`.
  - More inherited keys (`toString`, `__proto__`, `hasOwnProperty`) for both `resolveRole` and `isAllowed`.

I haven't committed the changes.

VERDICT: inadequate
