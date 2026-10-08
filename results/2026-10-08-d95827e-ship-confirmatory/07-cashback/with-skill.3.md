The existing tests were not enough to ship on. Two of the contract's limits were checked only exactly at the limit or far from it, so a small change to either limit would still have passed. I added tests that close both gaps.

I ran the original suite (17 tests, all passing) in a temporary worktree using the README's Docker command. I then shifted each comparison against a limit one unit down and one unit up and re-ran the suite.

| Limit | Shift | Result |
| --- | --- | --- |
| 500 minimum purchase | down | caught |
| 500 minimum purchase | up | caught |
| 0 negative-amount check | down | caught |
| 0 negative-amount check | up | caught |
| 25 minimum cashback | down (`raw < 24`) | **survived** |
| 25 minimum cashback | up (`raw < 26`) | equivalent: 25 returns 25 either way |
| 3,000 maximum cashback | down (`raw > 2999`) | equivalent: 3,000 returns 3,000 either way |
| 3,000 maximum cashback | up (`raw > 3001`) | **survived** |

- **Minimum cashback:** when the computed cashback is 24 cents, the floor of 25 would stop applying and 24 would be paid. No test used an amount that computes to 24.
- **Maximum cashback:** when the computed cashback is 3,001 cents, the cap of 3,000 would stop applying and 3,001 would be paid. No test used an amount that computes to 3,001.

I added three tests to `tests/test_cashback.py`:
- `test_cashback_just_below_minimum_is_raised`: `cashback_cents(2_400, "basic") == 25`.
- `test_cashback_just_above_minimum_is_not_raised`: `cashback_cents(2_600, "basic") == 26`.
- `test_cashback_just_above_maximum_is_capped`: `cashback_cents(100_034, "premium") == 3_000`.

With the new tests, the suite passes (20 tests). Both surviving shifts now make it fail. I did not run Necessist or a full mutation tool, and the checks above are manual limit shifts only. I ran the new tests only in the temporary worktree, not in the original project. The `git worktree remove` for it failed with a permission error, so a temporary worktree is still at `/tmp/tmp.ppqgueEghI/w`. The change to `tests/test_cashback.py` is uncommitted in your project.

VERDICT: inadequate
