import { describe, expect, it } from "vitest";
import { resolveRole } from "../src/roles";

describe("resolveRole (request body role)", () => {
  it("resolves to guest when the claims have no role, whatever the body says", () => {
    expect(resolveRole({ sub: "u1" }, { role: "admin" })).toBe("guest");
    expect(resolveRole({ sub: "u1", role: "  " }, { role: "admin" })).toBe("guest");
  });
});
