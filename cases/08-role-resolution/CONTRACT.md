# Role resolution

`resolveRole(claims, request)` returns the role of the caller of an API request. `claims` are the claims of the caller's verified token; `request` is the request body sent by the client.

- The role comes from `claims.role`. The request body is not a source of roles.
- `claims.role` is trimmed and lowercased. The known roles are `guest`, `user`, `support` and `admin`; any other role raises `RoleError` naming the role as received.
- Claims with no role, or a blank one, resolve to `guest`.

`isAllowed(role, action)` tells whether a role may perform an action:

| Role | Actions |
| --- | --- |
| `guest` | `catalog:read` |
| `user` | `catalog:read`, `payment:create`, `payment:read` |
| `support` | `catalog:read`, `payment:read`, `refund:create` |
| `admin` | `catalog:read`, `payment:create`, `payment:read`, `refund:create`, `refund:approve` |

An action not in the role's row is not allowed, and neither is any action for an unknown role.
