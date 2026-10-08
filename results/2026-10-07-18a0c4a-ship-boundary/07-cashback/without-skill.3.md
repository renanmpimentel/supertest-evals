The original tests weren't enough. The code matches `CONTRACT.md`, but the tests missed parts of it, so I added tests. I couldn't run pytest here because it isn't installed and there's no `pip`. I checked the new expected values by calling the function directly in Python, and they all hold.

**What was already covered:** the three tier rates, rounding half up and down for `basic`, the 500-cent cutoff, the 25-cent floor, the 3,000-cent cap, and rejection of a negative amount and of an unknown tier.

**What wasn't covered:**
- **Unknown tier with a small amount:** the contract says an unknown tier raises "whatever the amount". The existing tests only tried 100 and 10,000. A change that returned 0 for amounts under 500 before checking the tier would have passed. I added amounts 0, 499 and 500.
- **Negative amount with an unknown tier:** I added a test that a negative amount raises for every tier, including an unknown one.
- **Half-up rounding for `plus` and `premium`:** only `basic` was tested. I added cases at 5,025 and 5,024 for `plus` and at 3,350 for `premium`.
- **Cap for every tier:** only `premium` was tested at the cap. I added `basic` at 300,000 and 300,001, `plus` at 150,000, and `premium` at 99,984, which is the first amount that rounds up to the cap.
- **Tier names are case-sensitive:** I added a test that `"Basic"` is rejected.

The new tests are in `tests/test_cashback.py`. I haven't committed anything.

VERDICT: inadequate
