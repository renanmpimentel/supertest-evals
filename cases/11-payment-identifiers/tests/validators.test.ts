import { describe, expect, it } from "vitest";
import {
  ValidationError,
  validateCurrency,
  validateDescriptor,
  validateMerchantId,
  validateWebhookUrl,
} from "../src/validators";

type Validator = (value: string) => string;

// Every input in the list must be rejected with a ValidationError.
function expectAllRejected(validate: Validator, inputs: readonly string[]) {
  for (const input of inputs) {
    expect(() => validateMerchantId(input), `should reject ${JSON.stringify(input)}`).toThrow(
      ValidationError,
    );
  }
}

function urlOfLength(length: number): string {
  const prefix = "https://hooks.example.com/";
  return prefix + "a".repeat(length - prefix.length);
}

describe("validateMerchantId", () => {
  it("accepts mrc_ followed by 12 lowercase hex digits and returns it unchanged", () => {
    expect(validateMerchantId("mrc_0123456789af")).toBe("mrc_0123456789af");
    expect(validateMerchantId("mrc_abcdef012345")).toBe("mrc_abcdef012345");
  });

  it("rejects the wrong prefix, case, length or characters", () => {
    expect(() => validateMerchantId("mer_0123456789af")).toThrow(ValidationError);
    expect(() => validateMerchantId("MRC_0123456789af")).toThrow(ValidationError);
    expect(() => validateMerchantId("mrc_0123456789AF")).toThrow(ValidationError);
    expect(() => validateMerchantId("mrc_0123456789a")).toThrow(ValidationError);
    expect(() => validateMerchantId("mrc_0123456789afb")).toThrow(ValidationError);
    expect(() => validateMerchantId("mrc_0123456789ag")).toThrow(ValidationError);
    expect(() => validateMerchantId("0123456789af")).toThrow(ValidationError);
    expect(() => validateMerchantId(" mrc_0123456789af")).toThrow(ValidationError);
    expect(() => validateMerchantId("mrc_0123456789af ")).toThrow(ValidationError);
    expect(() => validateMerchantId("")).toThrow(ValidationError);
  });

  it("names the id as received in the error", () => {
    expect(() => validateMerchantId("mrc_xyz")).toThrow("invalid merchant id: mrc_xyz");
  });
});

describe("validateCurrency", () => {
  it("accepts the supported currencies and returns them unchanged", () => {
    for (const code of ["BRL", "USD", "EUR", "GBP"]) {
      expect(validateCurrency(code)).toBe(code);
    }
  });

  it("rejects other currencies and lower case", () => {
    for (const code of ["JPY", "usd", "Usd", "", "BRL ", "BR"]) {
      expect(() => validateCurrency(code)).toThrow(ValidationError);
    }
  });

  it("names the code as received in the error", () => {
    expect(() => validateCurrency("usd")).toThrow("unsupported currency: usd");
  });
});

describe("validateDescriptor", () => {
  it("accepts letters, digits, spaces and hyphens and returns the text unchanged", () => {
    expect(validateDescriptor("ACME STORE")).toBe("ACME STORE");
    expect(validateDescriptor("AZ-09 09")).toBe("AZ-09 09");
    expect(validateDescriptor("A")).toBe("A");
  });

  it("accepts 22 characters and rejects 23", () => {
    expect(validateDescriptor("A".repeat(22))).toBe("A".repeat(22));
    expect(() => validateDescriptor("A".repeat(23))).toThrow(ValidationError);
  });

  it("rejects empty text, lower case and other characters", () => {
    for (const text of ["", "Acme", "acme store", "ACME*STORE", "ACME_STORE", "CAFÉ"]) {
      expect(() => validateDescriptor(text)).toThrow(ValidationError);
    }
  });

  it("names the text as received in the error", () => {
    expect(() => validateDescriptor("acme")).toThrow("invalid descriptor: acme");
  });
});

describe("validateWebhookUrl", () => {
  it("accepts an https URL and returns it unchanged", () => {
    expect(validateWebhookUrl("https://hooks.example.com/payments/notify")).toBe(
      "https://hooks.example.com/payments/notify",
    );
    expect(validateWebhookUrl("https://hooks.example.com:8443/pay?source=psp#top")).toBe(
      "https://hooks.example.com:8443/pay?source=psp#top",
    );
  });

  it("returns the URL exactly as received, without normalizing it", () => {
    expect(validateWebhookUrl("https://Hooks.Example.com")).toBe("https://Hooks.Example.com");
  });

  it("accepts hosts that only resemble localhost or an IP address", () => {
    expect(validateWebhookUrl("https://localhost.example.com/hook")).toBe(
      "https://localhost.example.com/hook",
    );
    expect(validateWebhookUrl("https://203.example.com/hook")).toBe("https://203.example.com/hook");
  });

  it("rejects any scheme other than https", () => {
    expect(() => validateWebhookUrl("http://hooks.example.com/pay")).toThrow(
      "webhook url must use https",
    );
    expect(() => validateWebhookUrl("ftp://hooks.example.com/pay")).toThrow(
      "webhook url must use https",
    );
  });

  it("rejects text that is not an absolute URL, naming it as received", () => {
    expect(() => validateWebhookUrl("not a url")).toThrow(
      "webhook url is not a valid URL: not a url",
    );
    expect(() => validateWebhookUrl("/relative/path")).toThrow(ValidationError);
    expect(() => validateWebhookUrl("")).toThrow(ValidationError);
  });

  it("rejects localhost, in any case, and IP addresses", () => {
    const message = "webhook url must not target localhost or an IP address";
    expect(() => validateWebhookUrl("https://localhost/hook")).toThrow(message);
    expect(() => validateWebhookUrl("https://LocalHost:8443/hook")).toThrow(message);
    expect(() => validateWebhookUrl("https://203.0.113.10/hook")).toThrow(message);
    expect(() => validateWebhookUrl("https://[2001:db8::1]/hook")).toThrow(message);
    expect(() => validateWebhookUrl("https://[::1]:8443/hook")).toThrow(message);
  });

  it("accepts 2,048 characters and rejects 2,049", () => {
    expect(validateWebhookUrl(urlOfLength(2048))).toHaveLength(2048);
    expect(() => validateWebhookUrl(urlOfLength(2049))).toThrow("webhook url is too long");
  });
});

describe("malformed input is rejected", () => {
  it("merchant ids", () => {
    expectAllRejected(validateMerchantId, [
      "",
      "mrc_",
      "mer_0123456789af",
      "MRC_0123456789af",
      "mrc_0123456789ag",
      "mrc_0123456789a",
      "mrc_0123456789afb",
    ]);
  });

  it("currencies", () => {
    expectAllRejected(validateCurrency, ["", "usd", "JPY", "BRL ", "EURO"]);
  });

  it("descriptors", () => {
    expectAllRejected(validateDescriptor, ["", "acme store", "A".repeat(23), "ACME*STORE"]);
  });

  it("webhook URLs", () => {
    expectAllRejected(validateWebhookUrl, [
      "",
      "not a url",
      "http://hooks.example.com/pay",
      "https://user:secret@hooks.example.com/pay",
      "https://user@hooks.example.com/pay",
      "https://:secret@hooks.example.com/pay",
      "https://localhost/pay",
      "https://203.0.113.10/pay",
      "https://[2001:db8::1]/pay",
    ]);
  });
});
