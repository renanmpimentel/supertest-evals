The original tests did not protect the documented behavior, so I added four tests to `tests/test_charge.py`. The file now has six tests, and all six pass on the original code (checked in Docker, `python:3.12-slim`).

**Why the old tests fell short.** The old fake gateway returned an ID based only on the amount (`ch_5000`). So "second call returns the same charge" passed even if the gateway was called twice. The contract's main promise, that the gateway is charged only once, was never checked. "Different keys create different charges" had no test at all.

**What I added.** The new tests use a gateway that records every call and returns a fresh ID each time:
- A repeated key charges the gateway only once and returns an identical result.
- A repeated key with a different amount does not recharge and returns the original charge.
- Different keys each create their own charge.
- Repeating an earlier key after other keys does not recharge.

**Temporary breakages in an isolated worktree (code restored afterward).**

| Break | Old tests | New tests |
| --- | --- | --- |
| Result never cached, so every call charges | pass (the break would have shipped) | 3 fail |
| Gateway charged on every call but the cached result returned | pass (would have shipped) | 3 fail |
| Key ignored, one shared cached result | pass (would have shipped) | 2 fail |

I didn't run Necessist or a full mutation tool. `app/payments.py` has no limit comparisons, so there were no boundary probes to run.

**Limits and untested behavior.**
- The contract says nothing about gateway errors, invalid amounts, or thread safety, and I didn't test them. One thing to know: a gateway exception leaves nothing cached, so a retry charges again.
- The temporary worktree, `/tmp/wt_3427328`, couldn't be removed because Docker left root-owned files in it. It still needs a manual cleanup. The `tmpaudit` branch is deleted. The original project's only change is the modified test file, which is uncommitted.

VERDICT: inadequate
