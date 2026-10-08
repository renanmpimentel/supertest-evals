The original tests mostly protect the documented behavior, but they left some gaps. I added tests for them and all 34 pass.

- **Already covered:**
  - each tier's rate
  - half-up rounding for `basic`
  - the 499/500 purchase threshold
  - the 25-cent floor and 3,000-cent cap, both at the boundary and past it
  - unknown-tier errors, including the message
  - a negative amount with the `basic` tier
- **Gaps I filled:**
  - negative amounts are now checked for every tier, not just `basic`
  - a negative amount with an unknown tier is now checked
  - the minimum purchase (500) is now checked for every tier
  - half-up rounding is now checked on `plus` and `premium`
  - the floor now has cases on both sides of the boundary
  - the cap now has cases just over the limit

I found no bugs in `app/cashback.py`. One ambiguity: for a negative amount with an unknown tier, the code raises the "amount must not be negative" error, not one naming the tier. The contract could be read either way, so my test only requires `CashbackError`.

The original tests were a bit thin on those gaps, but nothing they missed was a real defect in the code. So the tests you were given already protected the documented behavior.

VERDICT: adequate
