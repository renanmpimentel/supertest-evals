The original tests were not enough to ship on. Two clamp boundaries went untested, and I added tests for both. The suite now has 19 tests, and all pass in the README's Docker setup.

**What the original 17 tests covered.** They covered the tier rates, half-up rounding, the 500-cent threshold, negative amounts, unknown tiers (including the message), and the exact 25 and 3,000 clamp values.

**Boundary probes.** I shifted each limit comparison one unit down and one unit up against the original tests, in an isolated worktree:

| Limit | Shift | Original tests | Result |
| --- | --- | --- | --- |
| Purchase threshold (500) | both | caught | covered |
| Negative check (`< 0`) | both | caught | covered |
| Minimum cashback (`raw < 25`) | up (`raw < 26`) | passed | equivalent: a raw value of 25 still returns 25 |
| Minimum cashback (`raw < 25`) | down (`raw < 24`) | passed | **gap**: a raw value of 24 would return 24 instead of 25, and no test hit it |
| Maximum cashback (`raw > 3000`) | up (`raw > 3001`) | passed | **gap**: a raw value of 3,001 would return 3,001 instead of 3,000, and no test hit it |
| Maximum cashback (`raw > 3000`) | down (`raw > 2999`) | passed | equivalent: a raw value of 3,000 still returns 3,000 |

**Fixes.** I added two tests to `tests/test_cashback.py`:
- `cashback_cents(2_400, "basic") == 25` covers a raw value just below the minimum.
- `cashback_cents(100_034, "premium") == 3_000` covers a raw value just above the maximum.

With the new tests, the two surviving shifts now fail. The two equivalent shifts still pass, as expected. The production code is unchanged.

**Limitations.** I ran only the boundary probes, not a full mutation or Necessist audit. The suite is small and pure-function, so I judged that enough.

**Cleanup.** The temporary worktree at `/tmp/tmp.GGr6kLHQ03/w` couldn't be removed because of a permissions error. It is outside the project and safe to delete by hand.

VERDICT: inadequate
