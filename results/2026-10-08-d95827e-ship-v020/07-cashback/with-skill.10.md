The tests did not give enough confidence as written, so I added one test.

**Baseline:** 17 tests passed, run through Docker with Python 3.12 and pytest 8.3.3. Pytest isn't installed on the host.

**Boundary probes:** I shifted each limit in `app/cashback.py` one unit down and one unit up, running the unmodified tests against each shift.
- **Caught:** the 500 minimum purchase (both shifts), the 25 minimum cashback (both shifts), the negative-amount check (`< -1` and `< 1`), and removing the half-up rounding term.
- **Equivalent:** lowering the 3,000 cap by one (`raw > MAX - 1`) gives the same result for every valid input, so it needs no test.
- **Survived:** raising the 3,000 cap by one (`raw > MAX + 1`) let all 17 tests pass. A purchase earning 3,001 cents would have been paid in full instead of being capped at 3,000. The existing tests only used inputs that land exactly on 3,000 or far above it, so the contract's cap went unchecked.

One result I didn't dig into: the `raw < MIN + 1` shift made a test fail even though I'd expect it to be equivalent. It's a harmless extra detection, but I didn't explain it.

**Fix:** I added `test_cashback_just_above_maximum_is_capped` to `tests/test_cashback.py`. It checks that 100,034 cents on `premium` returns 3,000, since the uncapped value is 3,001. With the `MAX + 1` shift in place the suite now fails (1 failed, 17 passed). With the original code restored, all 18 pass.

I didn't run Necessist or a full mutation tool. The audit covered the boundary probes and one rounding mutation, about 10 regressions. The temporary worktree at `/tmp/tmp.fMuz3npcoX/w` couldn't be removed because of a permissions error, so it is still there. The original project has only the one test change.

VERDICT: inadequate
