The tests did not give enough confidence. The 8-digit BIN lookup, a documented rule, had no effective test. I fixed that gap in `routing_test.go`, and the suite now passes (11 tests, `go test -count=1`, run in the `golang:1.27` image).

**The gap.** In the old fixtures, the `bin8` and `bin6` entries for the same card returned the same acquirer (`delta` for Visa, `echo` for Mastercard). Any change to the 8-digit lookup therefore left every test green. These three temporary regressions in an isolated worktree all passed the original suite:
- **Lookup removed:** the `bin8` lookup was deleted.
- **Order swapped:** the 6-digit lookup was made to run first.
- **Prefix shortened:** the 8-digit prefix was cut to 7 digits.

**The fix.**
- The `bin8` entries now map to distinct acquirers (`golf` and `hotel`).
- `TestEightDigitEntryIsUsed` expects those acquirers, so it proves the 8-digit entry wins over the 6-digit one.
- The Mastercard 6-digit fixture now uses its own prefix (`555556`), so it no longer overlaps the 8-digit case.

With the corrected tests, those three regressions and an extra one on the Luhn digit-doubling check (`n > 9` changed to `n > 10`) are all caught. The Luhn change had survived nothing before; I re-checked it after the fix because I touched the fixtures.

**What else I checked.** Everything else was caught by the original tests:
- **Limits shifted one unit down and up:** min and max card length, the Mastercard `51`/`55` prefix bounds, the amount limits for Visa, Mastercard and Amex, and the `amount <= 0` check.
- **Exact lengths:** the Amex and Mastercard lengths.
- **Luhn:** the doubling start (the flip of the initial `double` flag).
- **6-digit lookup:** removing it and shortening its prefix.

One regression showed as surviving, but it was a no-op: I replaced `'4'` with byte 52, which is the same value. A second one, the Luhn `n > 9` change, only ran correctly on the second pass because my first command mangled it in the shell.

**Limits of this audit.**
- I did not run Necessist or a full mutation tool.
- The probes were hand-picked, about 27 in all.
- Go isn't installed on the host, so all runs used the Docker image from the README.
- The worktree has been removed. The only change in the original project is `routing_test.go`, which I haven't committed.

VERDICT: inadequate
