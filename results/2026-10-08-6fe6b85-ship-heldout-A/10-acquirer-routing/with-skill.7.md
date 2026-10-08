The original tests did not give enough confidence, so I added tests for the gap I found. Everything else in the contract was already protected.

**The gap:** the contract says an 8-digit BIN entry (`bin8`) is checked before a 6-digit one (`bin6`). No test could tell the two lookups apart, because every card that matched a `bin8` entry also matched a `bin6` entry for the same acquirer. Four temporary changes to `routing.go` all passed the original 11 tests:
- removing the `bin8` lookup;
- swapping the `bin8` and `bin6` order;
- shortening the `bin8` key to 7 digits;
- lengthening the `bin8` key to 9 digits.

Each of these would route a card to the wrong acquirer in production.

**The fix:** I added `TestEightDigitEntryTakesPrecedenceOverSixDigitEntry` and `TestEightDigitEntryWithoutSixDigitEntry` to `routing_test.go`. They use tables where the two entries name different acquirers, a card with only a `bin8` entry, and a card that shares only the first 6 digits with a `bin8` key. I reran the four changes above against the corrected tests, and all four now fail. The `go test` suite passes in Docker on the real code (golang:1.27), and `routing_test.go` is the only file I changed.

**Other regressions I tried, all caught by the original tests:**
- shifting each limit one unit up and one unit down (the 10,000,000 and 5,000,000 amount limits, the card length limits 12/19/15/16, the `bin6` key length, and the Mastercard 51 to 55 range);
- the amount check, the Luhn check, the digit check, the space and hyphen handling, and the scheme default acquirers;
- the currency and card-length rules.

I did not run Necessist, and I did not run a full mutation tool; the regressions were hand-written. I also did not test which error wins when a card, currency and amount are all invalid, because the contract doesn't say.

VERDICT: inadequate
