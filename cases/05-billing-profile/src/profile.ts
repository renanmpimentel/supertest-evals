export interface BillingProfile {
  email: string;
  country: string;
  companyName: string | null;
  taxId: string | null;
}

export type ProfilePatch = {
  email?: string;
  country?: string;
  companyName?: string | null;
  taxId?: string | null;
};

export class ProfileError extends Error {
  constructor(
    readonly field: keyof BillingProfile,
    message: string,
  ) {
    super(message);
  }
}

const COUNTRIES = new Set(["BR", "US", "PT", "DE"]);

export function normalizeEmail(email: string): string {
  const normalized = email.trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized)) {
    throw new ProfileError("email", `invalid email: ${email}`);
  }
  return normalized;
}

export function validateCountry(country: string): string {
  const code = country.trim().toUpperCase();
  if (!COUNTRIES.has(code)) {
    throw new ProfileError("country", `unsupported country: ${country}`);
  }
  return code;
}

function optionalText(value: string | null): string | null {
  if (value === null) return null;
  const trimmed = value.trim();
  return trimmed === "" ? null : trimmed;
}

export function applyProfilePatch(stored: BillingProfile, patch: ProfilePatch): BillingProfile {
  return {
    email: patch.email === undefined ? stored.email : normalizeEmail(patch.email),
    country: patch.country === undefined ? stored.country : validateCountry(patch.country),
    companyName: patch.companyName === undefined ? stored.companyName : optionalText(patch.companyName),
    taxId: patch.taxId === undefined ? stored.taxId : optionalText(patch.taxId),
  };
}
