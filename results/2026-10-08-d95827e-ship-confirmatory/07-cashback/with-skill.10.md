The original tests were not enough. Two clamp-boundary bugs got past them, and I added tests that catch both.

**Baseline:** 17 tests passed, run with the README's Docker command. I audited the single module, `cashback_cents`, against `CONTRACT.md`. I did not run Necessist or a full mutation tool, so only the boundary probes are covered.

**Boundary probes:** I shifted each limit down one and up one in an isolated copy, with the original tests unchanged.

| Limit | Shift | Result |
| --- | --- | --- |
| Negative amount (`< 0`) | `< -1` | caught |
| Negative amount (`< 0`) | `< 1` | caught |
| Minimum purchase, 500 | down 1 | caught |
| Minimum purchase, 500 | up 1 | caught |
| Minimum cashback, 25 | down 1 | **survived** |
| Minimum cashback, 25 | up 1 | survived, but equivalent (same result for every valid input) |
| Maximum cashback, 3,000 | down 1 | survived, but equivalent (same result for every valid input) |
| Maximum cashback, 3,000 | up 1 | **survived** |

**The two real gaps:**
- **Minimum clamp:** a computed cashback of 24 was never tested. The shifted code would return 24 where the contract says 25.
- **Maximum clamp:** a computed cashback of 3,001 was never tested. The shifted code would return 3,001 where the contract says 3,000.

**Added to `tests/test_cashback.py`:**
- `cashback_cents(2_400, "basic") == 25`
- `cashback_cents(2_600, "basic") == 26`
- `cashback_cents(100_033, "premium") == 3_000`
- A negative amount with an unknown tier raises `CashbackError`. This guards the "whatever the amount" wording and is not tied to either gap.

**Verification:** the two surviving shifts now fail the suite, and the restored code passes. The final run on the real project gave 21 passed.

**Limits:** I did not probe the rounding half-point or the clamps for other tiers by hand. The existing tests looked adequate there, but I did not run regressions on them. The change to `tests/test_cashback.py` is uncommitted.

VERDICT: inadequate
