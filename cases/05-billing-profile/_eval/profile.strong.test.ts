import { describe, expect, it } from "vitest";
import { applyProfilePatch, type BillingProfile } from "../src/profile";

describe("applyProfilePatch (absent optional fields)", () => {
  it("keeps stored optional fields that the patch does not mention", () => {
    const stored: BillingProfile = {
      email: "billing@acme.test",
      country: "BR",
      companyName: "Acme Ltda",
      taxId: "12.345",
    };
    const updated = applyProfilePatch(stored, { email: "finance@acme.test" });
    expect(updated.companyName).toBe("Acme Ltda");
    expect(updated.taxId).toBe("12.345");
  });
});
