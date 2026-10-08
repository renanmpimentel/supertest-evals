The original tests already protect the documented behavior, so I'd call them adequate to ship. They cover:
- each tier's rate;
- rounding half up, and rounding down just below a half;
- the 500-cent threshold (499 earns 0, 500 earns the 25-cent minimum);
- both clamp edges, including 2,999 → 3,000 and the cap at 1,000,000;
- an unknown tier raising with the tier named in the message, at amounts below and above the threshold;
- a negative amount raising.

The gaps were small, so I added cases in `tests/test_cashback.py`:
- negative amounts of several sizes across all tiers;
- a negative amount with an unknown tier;
- half-up rounding for `plus` and `premium`;
- the 499/500 boundary for every tier.

The full suite now has 36 tests and they all pass. I didn't change `app/cashback.py`, since it matches `CONTRACT.md`.

VERDICT: adequate
