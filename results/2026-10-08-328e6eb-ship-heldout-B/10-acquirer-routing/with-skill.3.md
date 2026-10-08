The original tests were not enough, and I fixed the gap. The 8-digit table taking priority over the 6-digit table was never checked. Everything else in `CONTRACT.md` is protected.

**What I ran:** the baseline was 11 tests, all passing, via `go test` in `golang:1.27`. I then ran 13 boundary probes and 1 precedence regression in a temporary worktree. I only did the boundary probes, not a full mutation or Necessist run. I did not probe the Luhn arithmetic. The "failed luhn" case is the only protection I saw for it.

**Boundary probes:** 12 of the 13 were caught. I shifted each limit one unit down and one unit up: card length 12 and 19, the visa/mastercard and amex amount limits, the amount > 0 check, and the mastercard prefix range 51–55. The 13th changed the 8-digit prefix length from 8 to 7 and survived. It is not equivalent, so it is a real gap, not a harmless variant.

**The gap:**
- **What the contract says:** the `bin8` entry for the first 8 digits wins over the `bin6` entry for the first 6.
- **Why the tests missed it:** every `bin8` entry in the test router maps to the same acquirer as its `bin6` entry. Both swapping the lookup order and truncating the 8-digit prefix to 7 digits passed all 11 tests.

**Fix:** I added `TestEightDigitEntryWinsOverSixDigitEntry` to `routing_test.go`. It uses a router where `bin8` says `golf` and `bin6` says `delta` for the same card. It also checks that a 6-digit-only match still returns `delta` and that a card with no table entry gets the scheme default.

**Evidence the fix works:** with the lookup order swapped, and again with the 8-digit prefix cut to 7, the new test fails. With the code restored, the full suite passes and `gofmt` is clean. The original project's only change is `routing_test.go`, and I removed the temporary worktree and branch.

VERDICT: inadequate
