The tests already protect the documented behavior, so I made no changes.

I checked this by running the suite and then deliberately breaking `payouts.go` in a temporary copy. I left the real project untouched. The suite passed on the unmodified code, running in `golang:1.27` via Docker.

**Boundary probes.** For each limit, I shifted it one unit down and one unit up. Seven of the ten shifts made the suite fail, as they should. The three that survived change no valid result:
- **`fee < MinFeeCents+1`:** a fee of exactly 50 still comes out as 50, so the result is the same.
- **`fee > MaxFeeCents-1`:** a fee of exactly 5,000 still comes out as 5,000, so the result is the same.
- **Rounding offset `+5_001`:** this only differs when the percentage part has a remainder of 4,999 (out of 10,000). The basis points are all multiples of 50, so that remainder can't occur.

The seven caught shifts cover:
- the amount lower limit (both shifts);
- the amount upper limit (both shifts);
- the minimum fee (one shift);
- the fee cap (one shift);
- the rounding offset (one shift, `+4_999`).

The tests pin each edge at, just below and just above the limit. They also cover the documented rules for rounding half up, the fixed fees, the cap, and checking the amount before the method. On any error the fee must be 0, and an unknown method must name that method in the error.

I did not run Necessist or a broader mutation tool. The probes were enough to settle the question for a module this small.

VERDICT: adequate
