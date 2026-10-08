I checked the tests against `CONTRACT.md` and the implementation, and they cover the documented behavior. I changed nothing.

I couldn't run pytest here because it isn't installed in this environment. Instead I ran the same assertions in plain Python and they all passed.

The tests cover each part of the contract:
- **Tier rates:** 1%, 2% and 3% are each checked.
- **Rounding:** half up (4,050 gives 41) and just below half (4,049 gives 40).
- **Minimum purchase:** 499 earns 0, and 500 is the first eligible amount.
- **Floor and cap:** the 25-cent floor is checked from below and exactly at the floor. The 3,000-cent cap is checked just under, at, and well over.
- **Errors:** a negative amount raises, and an unknown tier raises with the tier named in the message, including for amounts that would otherwise earn 0.

The tests would catch the mistakes I tried by hand: a wrong comparison at 500, a different rounding rule, a wrong floor or cap, or checking the tier too late.

The one gap is a negative amount combined with an unknown tier. The contract doesn't say which error message wins there, so there is nothing to pin down.

VERDICT: adequate
