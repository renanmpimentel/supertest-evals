The original tests were not enough, so I added tests to `tests/test_cashback.py`. I couldn't run real pytest here because the sandbox has no pip or venv, so I ran the file through a small stand-in runner. All 51 cases pass against the current code.

**What the original tests covered:** each tier's rate at 10,000 cents, half-up rounding for `basic` only, the 499/500 purchase threshold, both clamps (mostly with `premium` or `basic`), and an unknown tier's message. Negative amounts were checked only as `-1` with `basic`.

**What they missed:**
- **Rounding for `plus` and `premium`:** the contract says rounding is half up for every tier, but only `basic` was checked.
- **The minimum clamp at its edges:** the cashback of 25 was never tested around the rounding boundary (24.5 up to 25, 26.5 up to 27) or for `plus` and `premium`.
- **The maximum clamp for `plus` and `basic`:** it was checked only for `premium`. A wrong cap or comparison for the other tiers would have passed.
- **Negative amounts:** "whatever the amount" was tested with one value and one tier. A negative amount with an unknown tier wasn't tested at all.
- **Exact tier names:** nothing showed that `"Basic"`, `""` or `None` are rejected.

**What I added:**
- Rounding cases for each tier.
- Minimum-clamp cases for each tier.
- Maximum-clamp cases for each tier, including 3,000 versus 2,999.
- Negative amounts across all tiers.
- A negative amount with an unknown tier.
- Tier names that must match exactly.

**Open question for you:** the contract is ambiguous when the amount is negative and the tier is unknown. The code reports the negative amount, but the contract says the unknown-tier message names the tier. I only assert that an error is raised in that case. If you want the message to name the tier, that is a code change.

VERDICT: inadequate
