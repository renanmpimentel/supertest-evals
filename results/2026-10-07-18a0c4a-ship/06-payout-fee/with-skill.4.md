The original tests did not give enough confidence, so I added four cases to `payouts_test.go`.

**What I ran:** Go isn't installed on the host, so I used the README's Docker command. The baseline had 2 tests passing and 0 failing. I then applied 16 hand-made mutations to the code in a scratch copy. I did not run Necessist.

**What the original tests missed:** 4 of the 16 mutations passed undetected. Two were harmless: `<=` for `<` on the minimum fee, and `>=` for `>` on the maximum fee. Both return the same value at the boundary, so no test can tell them apart. The other two were real gaps in the clamp from `CONTRACT.md`:
- **Minimum fee:** `fee < MinFeeCents-1` let a fee of 49 come back as 49 instead of 50.
- **Maximum fee:** `fee > MaxFeeCents+1` let a fee of 5001 come back as 5001 instead of 5000.

The existing tests only used values far from the 50 and 5,000 boundaries or exactly on them. Nothing sat one cent either side.

**What I added** (all four are card cases):
- Amount 760 gives a raw fee of 49, which must be raised to 50.
- Amount 800 gives exactly 50, which must stay 50.
- Amount 840 gives 51, which must stay 51.
- Amount 198,840 gives 5001, which must be clamped to 5,000.

**Result:** The suite still passes with the new cases. In the re-run, the two real boundary mutations are now caught, and only the two equivalent ones survive. The other 12 mutations were caught before and after.

The verdict is `inadequate` because it describes the tests as I received them, before my additions.

VERDICT: inadequate
