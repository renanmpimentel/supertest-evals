The original tests don't give enough confidence. They missed two boundary regressions. I added two tests that catch both.

Baseline: 17 tests collected and passed, run in the README's Docker command. I ran the boundary probes in a separate copy of the project, so the production code is untouched.

**Boundary probes** (limit shifted one unit down and one unit up, run against the original tests):
- **Negative-amount check (`< 0`):** both shifts were caught.
- **Minimum purchase (500):** both shifts were caught.
- **Cashback floor of 25, shifted down:** this survived. A raw cashback of 24 was returned as 24 instead of being raised to 25.
- **Cashback floor of 25, shifted up:** equivalent. A raw value of 25 gives 25 either way, so no test can tell them apart.
- **Cashback cap of 3,000, shifted up:** this survived. A raw cashback of 3,001 was returned as 3,001 instead of being capped at 3,000.
- **Cashback cap of 3,000, shifted down:** equivalent. A raw value of 3,000 gives 3,000 either way.

**Fix:** I added two tests to `tests/test_cashback.py`.
- `test_cashback_just_below_minimum_is_raised` checks that 2,400 cents on `basic` gives 25.
- `test_cashback_just_above_maximum_is_capped` checks that 100,033 cents on `premium` gives 3,000.

With each regression applied, the new tests fail. With the original code restored, all 19 tests pass.

**Not done:** I ran no other mutation tool and no Necessist. The probes were the only regressions I executed, so I'm not claiming the suite is free of other gaps. I did not run the final checks again on the original project directory itself. The 19-pass result is from the copy, with the original code and the new test file.

VERDICT: inadequate
