I checked the tests against the contract. They're adequate, so I changed nothing.

pytest isn't installed on this host, so I couldn't run the suite. Instead I ran `cashback_cents` against an independent reference of the contract, using exact fractions and round-half-up. I covered every amount from 0 to 199,999 for all three tiers, and the results matched everywhere. That means the implementation is correct. It doesn't prove the tests would catch a regression, so I compared the tests with each rule:

- **Tier rates:** the 1%, 2% and 3% rates are each checked.
- **Rounding:** 4,050 gives 41 and 4,049 gives 40. That separates round-half-up from round-half-down and from banker's rounding.
- **Purchase threshold:** 0 and 499 earn nothing, and 500 earns 25. Both sides of the 500 boundary are covered.
- **Minimum cashback (25):** both the clamp (500 and 1,000 with `plus`) and the exact boundary (2,500) are checked.
- **Maximum cashback (3,000):** 99,983 gives 2,999, 100,000 gives 3,000, and 1,000,000 gives 3,000.
- **Errors:** a negative amount raises `CashbackError`. An unknown tier raises it with the tier named, at amounts below and above 500. A mutant that checks the tier only for eligible purchases would be caught.

Small gaps remain, but they wouldn't let a plausible bug through. Half-up rounding is tested only for `basic`, though the rates are all one table and the rate test covers each tier. A negative amount combined with an unknown tier isn't tested, though both orderings raise the same error.

VERDICT: adequate
