The original tests did not fully protect the documented behavior, so I added tests for the gap. The suite now passes: 30 tests, up from 16, run with the README's Docker command.

**What I checked.** I ran 14 temporary changes to `cashback.py` against the original tests in an isolated copy:
- The original tests caught 11 of them. These covered tier rates, half-up rounding, the 500 threshold, the 25 and 3,000 clamps, and the negative-amount check.
- The other 3 survived. Two (`<=` against `<`, and `>=` against `>` on the clamps) change nothing observable. The third only swapped which message a negative amount with an unknown tier produces, and the contract doesn't specify that.

**The gap.** The contract says an unknown tier raises "whatever the amount", but the tests only tried 100 and 10,000. A change that skipped the tier check for amounts of 0 or 499 would have passed all 16 tests. Production code was not modified.

**What I changed in `tests/test_cashback.py`:**
- **Unknown tier:** it is now tested at 0, 100, 499, 500, 10,000 and 1,000,000, with the message checked.
- **Negative amounts:** they are now tested for every tier at -1 and -10,000. Negative amount with an unknown tier is tested, but only that it raises.
- **Unrecognised tiers:** `""`, `"Basic"` and `None` are tested too.

**Verification.** With the new tests, two versions of that tier-check bug (skipped for amounts of 0 or below, or below 500) both failed the suite. The unmodified code then passed all 30. My first draft wrongly expected the unknown-tier message for a negative amount. I removed that expectation because the contract doesn't specify it.

I did not run Necessist, and no linter or typechecker is configured in the project.

VERDICT: inadequate
