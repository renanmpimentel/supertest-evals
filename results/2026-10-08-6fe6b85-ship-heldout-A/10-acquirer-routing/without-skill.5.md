The original tests did not protect one documented rule, so I added tests for it.

**The gap:** `CONTRACT.md` says the `bin8` entry beats the `bin6` entry, which beats the scheme default. The shared test router mapped both tables to the same acquirer for every card that matched both. So the tests passed even with the lookup order reversed, or with the `bin8` lookup removed.

**What I added to `routing_test.go`:**
- A test with a router whose two tables disagree. It checks that `bin8` wins when both match, `bin6` is used when only it matches, and the scheme default applies when neither matches.
- A test for a router with only a `bin8` table.

**How I checked:**
- With the change, `go test ./...` passes, run in Docker because Go isn't installed locally.
- I temporarily swapped the lookup order in `routing.go`. The new test failed for the Visa and Mastercard cards, so it catches that bug.
- I then restored `routing.go`. Only `routing_test.go` is modified.

**What the existing tests already cover well:**
- Card number normalization and Luhn.
- Length boundaries for each scheme.
- Leading-digit boundaries.
- Currency checks.
- Amount limits, inclusive at the limit.
- Scheme default acquirers.

**Not covered:** `CONTRACT.md` doesn't say which error wins when several things are wrong at once, and I didn't test that.

VERDICT: inadequate
