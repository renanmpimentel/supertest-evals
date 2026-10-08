import { isIP } from "node:net";

export class ValidationError extends Error {}

const MAX_URL_LENGTH = 2048;
const SUPPORTED_CURRENCIES = new Set(["BRL", "USD", "EUR", "GBP"]);

export function validateMerchantId(id: string): string {
  if (!/^mrc_[0-9a-f]{12}$/.test(id)) {
    throw new ValidationError(`invalid merchant id: ${id}`);
  }
  return id;
}

export function validateCurrency(code: string): string {
  if (!SUPPORTED_CURRENCIES.has(code)) {
    throw new ValidationError(`unsupported currency: ${code}`);
  }
  return code;
}

export function validateDescriptor(text: string): string {
  if (!/^[A-Z0-9 -]{1,22}$/.test(text)) {
    throw new ValidationError(`invalid descriptor: ${text}`);
  }
  return text;
}

export function validateWebhookUrl(raw: string): string {
  if (raw.length > MAX_URL_LENGTH) {
    throw new ValidationError("webhook url is too long");
  }
  let url: URL;
  try {
    url = new URL(raw);
  } catch {
    throw new ValidationError(`webhook url is not a valid URL: ${raw}`);
  }
  if (url.protocol !== "https:") {
    throw new ValidationError("webhook url must use https");
  }
  if (url.username !== "" || url.password !== "") {
    throw new ValidationError("webhook url must not contain credentials");
  }
  const host = url.hostname.replace(/^\[|\]$/g, "");
  if (host === "localhost" || isIP(host) !== 0) {
    throw new ValidationError("webhook url must not target localhost or an IP address");
  }
  return raw;
}
