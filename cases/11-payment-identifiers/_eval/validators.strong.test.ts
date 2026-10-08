import { describe, expect, it } from "vitest";
import { validateWebhookUrl } from "../src/validators";

describe("validateWebhookUrl (embedded credentials)", () => {
  it("rejects a URL with a user name or a password embedded", () => {
    const message = "webhook url must not contain credentials";
    expect(() => validateWebhookUrl("https://user:secret@hooks.example.com/pay")).toThrow(message);
    expect(() => validateWebhookUrl("https://user@hooks.example.com/pay")).toThrow(message);
    expect(() => validateWebhookUrl("https://:secret@hooks.example.com/pay")).toThrow(message);
  });
});
