The existing tests already protect every rule in `CONTRACT.md`, so I changed nothing.

I couldn't run pytest here because it isn't installed and there's no Docker. Instead I ran the same assertions by hand against `app/cashback.py`, and they all hold. Run the README's Docker command once to confirm before you ship.

- **Rates:** the 1%, 2% and 3% tiers are each checked at 10,000 cents.
- **Rounding:** 4,050 gives 41 (exact half rounds up) and 4,049 gives 40, so ceiling and half-even rounding would both fail.
- **Purchase threshold:** 0 and 499 earn 0, and 500 earns the 25-cent minimum, so an off-by-one on the threshold would fail.
- **Minimum cashback:** 1,000 cents on `plus` and 2,500 on `basic` both land on 25, covering the floor and its edge.
- **Maximum cashback:** 99,983 gives 2,999, 100,000 gives 3,000, and 1,000,000 stays at 3,000, covering both sides of the cap and the clamp itself.
- **Errors:** a negative amount raises `CashbackError`. An unknown tier raises with its name in the message, at amounts 0, 100 and 10,000, so the check isn't skipped for small purchases.

Two small gaps remain. The cap is only tested on `premium`, and negative amounts are only tested with `-1` on `basic`. A bug in either would be unlikely, because the code has a single clamp and a single check for each, and neither gap leaves a documented rule unprotected.

VERDICT: adequate
