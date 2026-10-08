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

describe("isAllowed", () => {
  it("allows every action in the role's row", () => {
    expect(isAllowed("guest", "catalog:read")).toBe(true);
    expect(isAllowed("user", "payment:create")).toBe(true);
    expect(isAllowed("user", "payment:read")).toBe(true);
    expect(isAllowed("support", "payment:read")).toBe(true);
    expect(isAllowed("support", "refund:create")).toBe(true);
    expect(isAllowed("admin", "payment:create")).toBe(true);
    expect(isAllowed("admin", "payment:read")).toBe(true);
    expect(isAllowed("admin", "refund:create")).toBe(true);
    expect(isAllowed("admin", "refund:approve")).toBe(true);
  });

  it("allows catalog:read to every role", () => {
    for (const role of ["guest", "user", "support", "admin"]) {
      expect(isAllowed(role, "catalog:read")).toBe(true);
    }
  });

  it("denies actions outside the role's row", () => {
    expect(isAllowed("guest", "payment:read")).toBe(false);
    expect(isAllowed("guest", "payment:create")).toBe(false);
    expect(isAllowed("user", "refund:create")).toBe(false);
    expect(isAllowed("user", "refund:approve")).toBe(false);
    expect(isAllowed("support", "payment:create")).toBe(false);
    expect(isAllowed("support", "refund:approve")).toBe(false);
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
