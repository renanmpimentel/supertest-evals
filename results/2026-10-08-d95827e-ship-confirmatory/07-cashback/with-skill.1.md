The original tests were not enough. They missed two boundaries of the 25–3,000 cap, so I added three tests.

I ran the suite in Docker as the README describes: 17 passed. Then I ran the boundary probes in an isolated worktree. For each limit in `app/cashback.py`, I shifted it one unit down and one unit up and re-ran the unmodified tests.

- **Negative-amount and 500-cent limits:** all four shifts were caught.
- **Cap upper end (`raw > 3000`):**
  - Shifting up to `> 3001` survived. The tests only checked 3,000 exactly and values far above it, so a cashback of 3,001 (for example, premium on 100,034 cents) would have shipped uncapped.
  - Shifting down to `> 2999` is equivalent, because it gives the same result for every input.
- **Cap lower end (`raw < 25`):**
  - Shifting down to `< 24` survived. A raw cashback of 24 (for example, basic on 2,400 cents) would have been paid as 24 instead of 25.
  - Shifting up to `< 26` is equivalent.

I added three tests to `tests/test_cashback.py`:
- 2,400 basic returns 25.
- 2,600 basic returns 26.
- 100,034 premium returns 3,000.

With them, the two surviving shifts now fail, one test each. The restored code passes all 20 tests.

I did not run mutation testing or Necessist beyond these boundary probes.

I couldn't remove the temporary worktree: Docker left root-owned files in it (`/tmp/tmp.s3yaalLhcU/wt`), so `git worktree remove` failed with "Permissão negada". It's harmless, but it needs `sudo` to clean up. The original project has only the test change.

VERDICT: inadequate
