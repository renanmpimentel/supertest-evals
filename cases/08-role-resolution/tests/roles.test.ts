import { describe, expect, it } from "vitest";
import { isAllowed, resolveRole, RoleError } from "../src/roles";

describe("resolveRole", () => {
  it("returns the role from the claims", () => {
    expect(resolveRole({ sub: "u1", role: "support" }, {})).toBe("support");
    expect(resolveRole({ sub: "u1", role: "admin" }, {})).toBe("admin");
  });

  it("ignores the role in the request body", () => {
    expect(resolveRole({ sub: "u1", role: "user" }, { role: "admin" })).toBe("user");
  });

  it("trims and lowercases the claim role", () => {
    expect(resolveRole({ sub: "u1", role: "  Admin " }, {})).toBe("admin");
    expect(resolveRole({ sub: "u1", role: "SUPPORT" }, {})).toBe("support");
  });

  it("falls back to guest when the claims have no role", () => {
    expect(resolveRole({ sub: "u1" }, {})).toBe("guest");
    expect(resolveRole({ sub: "u1", role: null }, {})).toBe("guest");
  });

  it("falls back to guest when the claim role is blank", () => {
    expect(resolveRole({ sub: "u1", role: "" }, {})).toBe("guest");
    expect(resolveRole({ sub: "u1", role: "   " }, {})).toBe("guest");
  });

  it("rejects an unknown role, naming it as received", () => {
    expect(() => resolveRole({ sub: "u1", role: "Root" }, {})).toThrow(RoleError);
    expect(() => resolveRole({ sub: "u1", role: "Root" }, {})).toThrow("unknown role: Root");
  });

  it("does not treat inherited object keys as roles", () => {
    expect(() => resolveRole({ sub: "u1", role: "constructor" }, {})).toThrow(RoleError);
  });
});

const ACTIONS = [
  "catalog:read",
  "payment:create",
  "payment:read",
  "refund:create",
  "refund:approve",
] as const;

const TABLE: Record<string, readonly string[]> = {
  guest: ["catalog:read"],
  user: ["catalog:read", "payment:create", "payment:read"],
  support: ["catalog:read", "payment:read", "refund:create"],
  admin: ["catalog:read", "payment:create", "payment:read", "refund:create", "refund:approve"],
};

describe("isAllowed", () => {
  for (const [role, allowed] of Object.entries(TABLE)) {
    for (const action of ACTIONS) {
      const expected = allowed.includes(action);
      it(`${expected ? "allows" : "denies"} ${action} to ${role}`, () => {
        expect(isAllowed(role, action)).toBe(expected);
      });
    }
  }

  it("allows catalog:read to every role", () => {
    for (const role of ["guest", "user", "support", "admin"]) {
      expect(isAllowed(role, "catalog:read")).toBe(true);
    }
  });

  it("denies unknown actions, even to admin", () => {
    expect(isAllowed("admin", "user:delete")).toBe(false);
  });

  it("denies everything to an unknown role", () => {
    expect(isAllowed("root", "catalog:read")).toBe(false);
    expect(isAllowed("", "catalog:read")).toBe(false);
    expect(isAllowed("constructor", "catalog:read")).toBe(false);
  });
});
