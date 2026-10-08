The original tests weren't enough, so I added cases to `tests/test_cashback.py`. The two remaining mutants that still pass are equivalent: the `<=`/`>=` clamp mutations return the same value at the boundary.

I ran the suite in Docker with `python:3.12-slim` and pytest 8.3.3, as the README does. The baseline was 16 passed. I then applied 13 temporary mutations to `app/cashback.py` in isolated copies and left the original file untouched.

- **Gap found:** the mutation that skips the unknown-tier check when the amount is 0 passed all 16 tests. The contract says an unknown tier raises "whatever the amount", but the tests only tried amounts 100 and 10,000.
- **Negative amounts:** they were only tested with `basic` and a single value, -1.
- **Equivalent mutants:** changing `raw < MIN` to `raw <= MIN` and `raw > MAX` to `raw >= MAX` returns the same value at the boundary, so no test can tell them apart.

**Test changes:**
- The unknown-tier test now uses amounts 0, 100, 499, 500, 10,000 and 1,000,000.
- The negative-amount test now covers all three tiers with -1, -499, -500 and -1,000,000.

With these changes the suite is 31 passed. The mutant that skips the tier check for amounts of 0 or less is now caught, as are the other 10 mutants that can change behavior. I did not run Necessist, and I did not commit the changes.

VERDICT: inadequate
