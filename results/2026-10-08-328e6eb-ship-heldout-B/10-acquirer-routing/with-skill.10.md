The original tests were not enough to ship on. The documented rule that an 8-digit BIN entry beats a 6-digit one had no protection. I added two tests for it.

**The gap.** The `bin8` and `bin6` tables in the original fixture map to the same acquirer for the same cards (`delta` for `visaBin8`, `echo` for `mastercardBin8`). Because of that, none of these changes made a test fail:
- Checking `bin6` before `bin8`.
- Reading the first 7 digits instead of 8.
- Reading the first 6 digits instead of 8.

I ran the first two against the original tests. Both passed.

**What I changed.** I added two tests to `routing_test.go`. They use their own router, where `bin8` and `bin6` give different acquirers for the same card:
- `TestEightDigitEntryTakesPrecedenceOverSixDigitEntry`: the 8-digit entry wins when both match, the 6-digit entry applies when only it matches, and the scheme default applies when neither does.
- `TestEightDigitEntryWithoutSixDigitEntry`: an 8-digit entry works on its own, and a card sharing only the first 7 digits does not match.

All four mutations now fail the new tests: swapped lookup order, 7 digits, 6 digits, and the `bin8` lookup removed. I also made `binShort` 5, which the original tests already caught. With the source restored, the suite passes.

**Boundary probes.** I did not run the one-unit shifts on the other limits. I only reasoned that the existing tests would catch them: card lengths 12 and 19, the mastercard and amex lengths, the positive-amount check, and the per-scheme amount limits. Each is tested at the limit and just past it. I did not execute those shifts, and I did not run Necessist or a full mutation tool.

**Test runs.** I ran the tests in Docker with `golang:1.27`, as the README says. The only change in the working tree is `routing_test.go`, and I haven't committed it.

VERDICT: inadequate
