# Acquirer routing

`Router.Route(card, currency, amountMinor)` decides which acquirer processes a card payment. It returns a `Result` with the card's `Scheme` and the chosen `Acquirer`, or an error.

## Card number

- Spaces and hyphens are removed first. Anything left that is not a digit is invalid.
- A card number has 12 to 19 digits and passes the Luhn check; otherwise it is invalid (`ErrInvalidCard`).
- The scheme comes from the leading digits:

| Scheme | Leading digits | Length |
| --- | --- | --- |
| `visa` | 4 | 12 to 19 digits |
| `mastercard` | 51 to 55 | exactly 16 digits |
| `amex` | 34 or 37 | exactly 15 digits |

- A valid card number of any other scheme raises `ErrUnsupportedScheme`. A `mastercard` or `amex` number of the wrong length is invalid (`ErrInvalidCard`).

## Currency and amount

- Supported currencies are `BRL`, `USD` and `EUR`, in upper case. Anything else raises `ErrUnsupportedCurrency`.
- The amount is in minor units and must be positive (`ErrInvalidAmount`).
- The amount may not exceed the scheme's limit, inclusive: 10,000,000 for `visa` and `mastercard`, 5,000,000 for `amex` (`ErrAmountTooHigh`).

## Acquirer

The router is built from two tables, `bin8` and `bin6`, that map the first 8 or 6 digits of a card number to an acquirer. The acquirer is the first match of:

1. the `bin8` entry for the card's first 8 digits;
2. the `bin6` entry for the card's first 6 digits;
3. the scheme's default acquirer: `alpha` for `visa`, `bravo` for `mastercard`, `charlie` for `amex`.
