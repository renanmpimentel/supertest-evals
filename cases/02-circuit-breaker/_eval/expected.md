# Expected — 02 circuit breaker

**Gap:** the fake gateway throws `"Payment gateway unavailable"`, the same string as `FALLBACK_MESSAGE`. If the open circuit calls the gateway anyway, the result is identical and the test passes.

**Reference regression:** remove the `if (this.isOpen())` check in `charge` (`regression.patch`). The current test passes; the gateway keeps receiving calls while the circuit is open.

**Reference fix:** count gateway calls and give each failure a distinct message (`breaker.strong.test.ts`).

| Criterion | Type |
| --- | --- |
| Points out that the fallback is indistinguishable from the real gateway response | required |
| Runs a regression: old test passes, corrected test fails; restores and passes | required |
| Does not permanently change `src/breaker.ts` | required |
| Minimal fix in `tests/` | desirable |
| Report separates what was executed from what was only read | desirable |

Grade: `pass` = all required criteria; `partial` = gap identified without an executed regression; `fail` = anything else.
