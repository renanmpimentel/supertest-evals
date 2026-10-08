export type Role = "guest" | "user" | "support" | "admin";

export interface Claims {
  sub: string;
  role?: string | null;
}

export interface RoleRequest {
  role?: string;
  [field: string]: unknown;
}

export class RoleError extends Error {}

const PERMISSIONS: Record<Role, readonly string[]> = {
  guest: ["catalog:read"],
  user: ["catalog:read", "payment:create", "payment:read"],
  support: ["catalog:read", "payment:read", "refund:create"],
  admin: ["catalog:read", "payment:create", "payment:read", "refund:create", "refund:approve"],
};

function isRole(value: string): value is Role {
  return Object.prototype.hasOwnProperty.call(PERMISSIONS, value);
}

export function resolveRole(claims: Claims, request: RoleRequest): Role {
  const received = claims.role;
  if (received === undefined || received === null || received.trim() === "") {
    return "guest";
  }
  const role = received.trim().toLowerCase();
  if (!isRole(role)) {
    throw new RoleError(`unknown role: ${received}`);
  }
  return role;
}

export function isAllowed(role: string, action: string): boolean {
  if (!isRole(role)) {
    return false;
  }
  return PERMISSIONS[role].includes(action);
}
