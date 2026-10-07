import { describe, expect, it } from "vitest";
import {
  applyProfilePatch,
  normalizeEmail,
  ProfileError,
  validateCountry,
  type BillingProfile,
} from "../src/profile";

const stored: BillingProfile = {
  email: "billing@acme.test",
  country: "BR",
  companyName: null,
  taxId: null,
};

describe("normalizeEmail", () => {
  it("trims and lowercases", () => {
    expect(normalizeEmail("  Billing@ACME.test ")).toBe("billing@acme.test");
  });

  it("rejects malformed addresses", () => {
    expect(() => normalizeEmail("billing@acme")).toThrow(ProfileError);
    expect(() => normalizeEmail("not an email")).toThrow(/invalid email/);
  });
});

describe("validateCountry", () => {
  it("accepts supported codes in any case", () => {
    expect(validateCountry(" pt ")).toBe("PT");
  });

  it("rejects unsupported countries", () => {
    expect(() => validateCountry("XX")).toThrow(/unsupported country/);
  });
});

describe("applyProfilePatch", () => {
  it("keeps fields absent from the patch", () => {
    expect(applyProfilePatch(stored, { email: "Finance@ACME.test" })).toEqual({
      email: "finance@acme.test",
      country: "BR",
      companyName: null,
      taxId: null,
    });
  });

  it("replaces optional text, trimmed", () => {
    expect(applyProfilePatch(stored, { companyName: "  Acme Ltda ", taxId: " 12.345 " })).toEqual({
      ...stored,
      companyName: "Acme Ltda",
      taxId: "12.345",
    });
  });

  it("clears optional fields with null or blank text", () => {
    const withCompany = { ...stored, companyName: "Acme Ltda", taxId: "12.345" };
    expect(applyProfilePatch(withCompany, { companyName: null, taxId: "  " })).toEqual({
      ...withCompany,
      companyName: null,
      taxId: null,
    });
  });

  it("validates replaced fields", () => {
    expect(() => applyProfilePatch(stored, { country: "XX" })).toThrow(ProfileError);
  });

  it("does not modify the stored profile", () => {
    const copy = { ...stored };
    applyProfilePatch(stored, { email: "finance@acme.test", taxId: "1" });
    expect(stored).toEqual(copy);
  });
});
