The existing tests are adequate. I changed nothing in the project, and `git status` is clean.

**Baseline:** `go test -v ./...` in `golang:1.27` ran 2 tests (`TestFee`, which has 18 cases, and `TestFeeRejectsInvalidInput`). Both passed, with 0 failed and 0 skipped.

**What I ran:** I made temporary changes to `payouts.go` in an isolated worktree and ran the unmodified tests against each. I discarded the worktree afterward. My first pass used a backup file in `/tmp` that turned out to hold unrelated content, so I threw those results away and redid everything with a private backup directory.

- **Boundary probes:** I shifted each of the four limits one unit down and one unit up, which is eight shifts.
  - **Amount lower bound (`<= 0`):** both shifts were caught.
  - **Amount upper bound (`> MaxAmountCents`):** both shifts were caught.
  - **Minimum fee (`fee < Min`):**
    - Shifting down was caught.
    - Shifting up survived, but it is equivalent. A fee of exactly 50 is clamped to 50 either way.
  - **Maximum fee (`fee > Max`):**
    - Shifting up was caught.
    - Shifting down survived, but it is equivalent. A fee of exactly 5,000 is clamped to 5,000 either way.
- **Contract mutations:** all of these were caught.
  - Rounding offset 5000 → 4999.
  - Dropping the fixed fee.
  - Changing the percentage of each method.
  - Changing the fixed fee of each method.
  - `MinFeeCents` 50 → 51.
  - `MaxFeeCents` 5,000 → 5,001.
  - Swapping the amount and method validation order. My first attempt didn't compile, so I redid it properly and the tests failed as they should.
- **Rounding offset 5000 → 5001:** this survived and is equivalent. The scaled amount is always a multiple of 50, so a remainder of 4,999 can't occur.
- **Errors return a fee of 0:** the tests check this directly. I didn't run a separate regression for it.
- **Unknown method error naming the method:** the tests check this directly. I didn't run a separate regression for it.

I used 28 regressions, under the 30 budget. I did not run Necessist or a full mutation tool; hand-written `sed` mutations stood in for both. This is a progressive audit, not a full one, and it doesn't promise the module is free of bugs.

VERDICT: adequate
