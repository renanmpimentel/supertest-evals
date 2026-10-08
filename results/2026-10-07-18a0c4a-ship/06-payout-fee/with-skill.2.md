The existing tests protect the documented behavior, so I made no changes to the repo.

I ran the suite in the `golang:1.27` image, as the README says, and it passes. I also ran 15 temporary mutants of `payouts.go` in an isolated copy at `/tmp/supermut`. The repo is still clean.

- **Caught by the tests:**
  - **Rounding:** changing the half-up constant.
  - **Amount validation:** `<=` to `<` at 0 and `>` to `>=` at the maximum.
  - **Rates:** changing any method's percentage or fixed fee.
  - **Clamps:** removing either the minimum or the maximum clamp.
  - **Validation order:** checking the method before the amount.
  - **Error message:** a wrong method name in the unknown-method message.
- **Survived, but equivalent:** changing the minimum clamp from `<` to `<=` and the cap from `>` to `>=`. At the boundary the clamp value equals the fee, so the output is identical and no test could tell them apart.
- **Didn't compile:** two mutants were rejected by the compiler or vet, so they prove nothing. I replaced the message-text one with a mutant that compiles, and it was caught.

I did not run Necessist. The audit was limited to manual contract review plus these hand-picked mutants.

VERDICT: adequate
