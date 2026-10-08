I ran the suite (`go test` in the Docker image from the README) and it passes. I also checked the tests against `CONTRACT.md` rule by rule, and they protect the documented behavior. I changed nothing.

- **Fee table:** each method's percentage and fixed fee is checked at 100,000 cents. A wrong rate or a dropped fixed fee would fail.
- **Rounding half up:** the pix case at 10,100 (50.5 → 51) tells half-up apart from half-even and from truncation. The bank transfer 149 and 150 cases cover the rounding-down side and the exact half.
- **Min and max fee:** the card cases at 760, 800, 198,760, 198,770, 198,800 and 198,840 sit right on both clamp edges. They would catch an off-by-one in either clamp. They would also catch clamping before the fixed fee is added, or rounding after the fixed fee.
- **Amount bounds:** 0, -1, 1 and 1,000,000,000,000 are tested, plus 1,000,000,000,001, which is one over the limit. Pix at the maximum amount is accepted.
- **Error behavior:** `ErrInvalidAmount` and the unknown-method message naming the method are both checked. The fee is 0 on every error. An invalid amount with an unknown method returns `ErrInvalidAmount`, so the amount is validated first.

I tried mentally mutating the code, such as changing `<=` to `<`, changing the `+5000`, and swapping rates. Each one would make at least one existing test fail.

The remaining gaps are minor and don't threaten the documented behavior. Cap and maximum-amount checks only run for pix and card. An empty or differently-cased method name isn't tested, though it follows from the same map lookup as `crypto`.

VERDICT: adequate
