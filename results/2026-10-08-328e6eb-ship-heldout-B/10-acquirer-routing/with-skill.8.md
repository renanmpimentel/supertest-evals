The original tests were not enough. They missed one documented rule: a `bin8` entry beats a `bin6` entry.

**Cause:** every `bin8` fixture mapped to the same acquirer as its `bin6` entry. A router that ignored `bin8`, or checked `bin6` first, still passed.

**What I ran:** the baseline was 11 tests, all passing, using the README's Docker command. In an isolated worktree I ran 25 regressions against the unmodified tests:
- limits shifted one down and one up: card length bounds, per-scheme length, per-scheme amount limits, and the Mastercard 51–55 range
- the amount `<= 0` check and the `> limit` check
- three Luhn variants
- `bin8` ignored

Every regression was caught except the `bin8` one, which survived. I did not run Necessist or a full mutation tool.

**The fix:** I added two tests to `routing_test.go`:
- `TestEightDigitEntryTakesPrecedenceOverSixDigitEntry` uses a router where the two tables disagree for the same card. It checks that `bin8` wins when both match and `bin6` is used when only it matches.
- `TestEightDigitEntryOnlyWithoutSixDigitEntry` checks that a `bin8` entry works on its own.

With the code correct, both tests pass. They fail when `bin8` is ignored and when the lookup order is swapped (I ran both as separate regressions). After restoring the code, the full suite passes, and the worktree is removed.

`routing_test.go` has these two tests as uncommitted changes. I did not touch `routing.go` and made no commit.

VERDICT: inadequate
