The tests are adequate, so I changed nothing. I compared them with each rule in `CONTRACT.md`. I couldn't run pytest here because `python` isn't on the path and pytest isn't installed. Instead I ran the expected values from eight of the tests directly against the code, and they all matched.

The tests cover each rule in the contract:
- **Tier rates:** all three rates are checked at 10,000 cents.
- **Rounding:** there is a half-up case (4,050 gives 41) and a just-below-half case (4,049 gives 40).
- **500-cent threshold:** 0 and 499 give 0, and 500 gives the 25-cent minimum.
- **Minimum clamp:** raw values below 25 are lifted to 25, and a raw value of exactly 25 passes through.
- **Maximum clamp:** 99,983 gives 2,999, 100,000 gives exactly 3,000, and 1,000,000 stays at 3,000.
- **Errors:** a negative amount raises `CashbackError`, and an unknown tier raises it with a message naming the tier. The unknown-tier test uses both an amount below the threshold and one above it, so reordering the checks would fail it.

I looked for ways the code could break these rules without a test failing, such as changing `<` to `<=` or `>` to `>=`, shifting a boundary, or changing the rounding offset. The tests would catch every one I tried.

Two gaps remain, and neither is worth a test. Rounding is only checked for the `basic` tier, but all tiers use the same formula. The negative-amount check uses only -1 with a valid tier, which is enough to pin the `< 0` boundary together with the amount-0 test.

VERDICT: adequate
