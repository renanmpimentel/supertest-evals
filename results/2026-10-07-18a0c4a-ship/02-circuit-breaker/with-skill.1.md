The original tests were not enough to ship on. I strengthened them, and the new suite catches every defect I tried.

**Original tests.** They passed (2 tests). But they missed 5 of the 7 defects I injected into `src/breaker.ts` one at a time:
- The failure count never resets after a success.
- The gateway is still called while the circuit is open.
- A closed-circuit failure returns the wrong message.
- Each failure counts twice.
- The default threshold is wrong.

The open-circuit test wasn't strong enough because the fake gateway throws a message identical to `FALLBACK_MESSAGE`. It couldn't tell whether the gateway was skipped or called. Two documented behaviors had no test at all: the success-resets-count rule and the closed-circuit error message.

**Changes.** I rewrote `tests/breaker.test.ts` with a scripted gateway that records its calls. It now has 7 tests covering:
- success, including the amount passed to the gateway
- the gateway's own error message while the circuit is closed
- the open boundary (closed one failure short, open at the threshold)
- no gateway call once open, with the fallback returned
- a threshold of 1
- the default threshold of 3
- reset on success, so only consecutive failures open the circuit

**Evidence.** I ran the tests in the `node:24-slim` container from the README. The new suite passes 7 of 7 against the real code. I then injected each of the 7 defects separately. The new suite failed on all 7, and the original tests failed on only 2 (`>=` changed to `>`, and the fallback message changed). I restored `src/breaker.ts` afterward, and `git status` shows only the test file modified.

**Not done.** I didn't run Necessist or an automated mutation tool. The 7 defects were hand-picked.

I haven't committed anything.

VERDICT: inadequate
