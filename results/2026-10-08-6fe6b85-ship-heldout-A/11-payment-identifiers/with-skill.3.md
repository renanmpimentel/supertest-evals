The tests were not adequate, and I've fixed them. The suite now passes 22 of 22, up from 21 of 21. I ran it on the host's Node rather than the Docker image the README uses.

**Gaps found**
- **Credentials rule was untested.** The documented rejection of a user name or password in a webhook URL (`webhook url must not contain credentials`) could be deleted, weakened to user-only or password-only, or have its message changed, and every test still passed. The only credential cases were in `expectAllRejected`, and that helper was broken (next point).
- **`expectAllRejected` ignored its validator argument.** It always called `validateMerchantId`, so the "malformed input is rejected" cases for currencies, descriptors and webhook URLs were checking the merchant-id validator instead. Those cases are what made the credentials rule look covered.

**Fixes (in `tests/validators.test.ts`)**
- The helper now calls the validator it is given.
- A new test covers credentials: user name only, password only, both, plus the error message.

**Evidence**

Each regression was applied to the production code in an isolated worktree, then restored.
- **Boundary shifts:** I shifted the 2048 URL limit, the 22 descriptor limit and the 12 merchant-id length one unit down and one up. Every shift was caught. I also tried a descriptor minimum of 0, and that was caught too.
- **Other probes:** I also dropped the localhost check, dropped the IP check, narrowed the IP check to one version, removed the https check, removed a currency, added a currency, and removed a regex anchor. All were caught.
- **Credentials:** the three credential regressions that survived before now fail, and so does the message change.
- **Helper:** making the currency validator or the descriptor validator accept everything now fails the suite.

I removed the worktree. The only change in the original project is the test file, and I didn't commit it. I ran the probes by hand, so I did not run Necessist or an automated mutation tool.

VERDICT: inadequate
