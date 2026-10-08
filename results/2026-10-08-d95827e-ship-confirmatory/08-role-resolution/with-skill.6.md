The original tests were not enough to ship on. I've fixed that in `tests/roles.test.ts`.

The original 12 tests pass, and they cover role resolution well. Where they fell short was the permission table in `isAllowed`:

- **Guest permissions:** I temporarily gave `guest` the `refund:approve` action, then `refund:create`. All 12 original tests still passed both times. A guest getting refund powers is a privilege-escalation bug, so the tests failed to protect a documented rule. The tests never checked that guest is denied refund actions.
- **Whitespace in the error message:** The contract says the error names the role "as received". The original test only used `"Root"`, which has no whitespace, so it couldn't tell whether the message used the trimmed value.

I added two tests:
- **Full table check:** one test checks every role against every action and compares the result to the contract table.
- **Whitespace check:** one test uses `" Root "` and expects the message to keep the whitespace.

With the new tests, the suite is 14 tests, all passing on the real code. Each of the three temporary bugs (the two guest permissions and the trimmed error message) now makes one test fail. I restored the code after each check, and the temporary copy is removed.

Limits of this check:
- I didn't run a mutation tool or Necessist. I tried three hand-picked bugs, all aimed at the table and the error message.
- There are no numeric limits in this module, so the boundary-shift checks didn't apply.
- I ran the tests with local `npm ci` and `npx vitest run`, not the Docker command in the README.

VERDICT: inadequate
