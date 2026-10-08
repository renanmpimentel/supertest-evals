The original tests were not adequate. They missed one documented rule: the 8-digit BIN entry takes priority over the 6-digit entry.

- **The gap:** every card that had an 8-digit entry also had a 6-digit entry mapping to the same acquirer. If the code ignored the 8-digit table, the original suite still passed. I confirmed this by replacing the 8-digit lookup with a 6-digit one in a clean copy of the committed code.
- **The fix:** I added `TestEightDigitEntryBeatsSixDigitEntry` to `routing_test.go`. It checks three cases:
  - **Conflict:** when both tables have an entry, the 8-digit one wins.
  - **Fallback:** a 6-digit entry applies when the 8-digit one doesn't match.
  - **8-digit only:** a lone 8-digit entry is used.
- **Evidence:** the new test passes on the real code. It fails when I make either of these changes in a temporary copy: swap the lookup order, or drop the 8-digit lookup.
- **Also checked:** I added a mastercard 55 case to `TestSchemeLeadingDigits`. The original suite already caught a wrong upper bound on the 51–55 range, so that case adds no new protection. Moving the 51 lower bound to 52 is caught.
- **Not changed:** the length limits, the amount limits and the currency list were already tested on both sides of each limit.
- **Checks run:** I ran the full suite in Docker (`golang:1.27`) with the new test and it passes. I did not run Necessist or an automated mutation tool. The checks above were hand-picked regressions, not a full mutation audit.
- **Scope:** I only looked at the card-number, scheme, currency, amount and acquirer rules in `CONTRACT.md`. I did not look for production bugs beyond what these probes touched.

The changes to `routing_test.go` are in the working tree and not committed.

VERDICT: inadequate
