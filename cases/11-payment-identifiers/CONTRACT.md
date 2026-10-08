# Payment identifiers

Validators for identifiers received in payment API requests. Each returns its input unchanged when it is valid and throws `ValidationError` otherwise.

## `validateMerchantId(id)`

- A merchant id is `mrc_` followed by exactly 12 lowercase hexadecimal digits.
- Anything else throws `invalid merchant id: <id>`.

## `validateCurrency(code)`

- Supported currencies are `BRL`, `USD`, `EUR` and `GBP`, in upper case.
- Anything else throws `unsupported currency: <code>`.

## `validateDescriptor(text)`

- A statement descriptor has 1 to 22 characters, each an upper-case letter, a digit, a space or a hyphen.
- Anything else throws `invalid descriptor: <text>`.

## `validateWebhookUrl(url)`

- A webhook URL has at most 2,048 characters (`webhook url is too long`) and must be an absolute URL (`webhook url is not a valid URL: <url>`).
- The scheme must be `https` (`webhook url must use https`).
- It must not embed credentials: a user name or a password in the URL is rejected (`webhook url must not contain credentials`).
- The host must not be `localhost` or an IP address, IPv4 or IPv6 (`webhook url must not target localhost or an IP address`).
