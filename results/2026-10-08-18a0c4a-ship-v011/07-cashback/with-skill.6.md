The original tests were not enough to ship on. I added tests, and they now cover the contract.

**Baseline:** 17 tests passed in `python:3.12-slim` with pytest 8.3.3, the setup from the README.

**What I checked:** I made 15 temporary changes to `app/cashback.py` in an isolated copy, such as changed comparisons, rates, clamps and error handling. The original suite missed 5 of them:
- **Negative amounts:** the check only applied to the `basic` tier, and the tests only used `basic`.
- **Rounding:** half-up rounding only applied to `basic`, and the tests only checked rounding for `basic`.
- **Small purchases:** the "below 500 earns nothing" rule was skipped for `plus`, and the tests only used `premium`.
- **Min and max clamp comparisons:** `raw <= MIN` and `raw >= MAX` passed. They return the same value as the original code in every case, so no test can tell them apart.

**What I changed:** I added 15 tests to `tests/test_cashback.py` (32 now pass). They cover:
- small purchases for every tier;
- negative amounts for every tier;
- negative amounts with an unknown tier;
- half-up rounding for `plus` and `premium`.

Rerunning the same 15 changes, every one is now caught except the two equivalent clamp changes. I did not run Necessist or any other mutation tool, only these hand-made changes. The edits are in the working tree and are not committed.

VERDICT: inadequate
