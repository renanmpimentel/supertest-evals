The tests did not give enough confidence, so I rewrote `tests/test_charge.py`.

**What was wrong.** The old fake gateway returned a deterministic id (`ch_<amount>`). A service that never cached anything and charged the gateway twice per key therefore still passed. The contract's core guarantee, "charges the gateway only once", was never checked. "Different keys create different charges" had no test at all.

I checked this with a temporary regression in an isolated worktree, using the project's documented Docker command. The baseline was 2 passed. With the idempotency check disabled, it was still 2 passed, so the regression went undetected.

**What I changed.**
- The fake gateway now records its calls and returns a unique id per call.
- The same-key test asserts the gateway is called exactly once and that the second result equals the first.
- A new test covers different keys: separate gateway calls, distinct ids, and a repeat of the first key still hitting the cache.

**Evidence with the new tests** (3 pass on the correct code):
- **Idempotency check disabled:** 2 of the 3 tests fail.
- **All keys sharing one cache entry:** the different-keys test fails. This was a second regression I ran.

**Not done.**
- The code has no limit comparisons, so there were no boundary probes to run. Necessist and a full mutation tool were not run, which is reasonable for a module this small.
- I couldn't remove the worktree `/tmp/wt_st`. Docker left root-owned files in it, so `git worktree remove` was denied. It is harmless and can be removed with sudo.
- The new tests are written to the original project but not committed.
- I did not rerun the final suite on the original project itself. It passed only in the worktree copy.

VERDICT: inadequate
