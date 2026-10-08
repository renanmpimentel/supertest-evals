# Ledger rules

`Ledger` records money movements. Amounts are integer cents.

- `add(timestamp, kind, amount_cents)` records an entry. `kind` is `"credit"` or `"debit"`; anything else raises `LedgerError`.
- `amount_cents` must be positive, and `timestamp` must not be negative; otherwise `LedgerError`. A rejected entry is not recorded.
- `entries()` returns the recorded entries as a new list, always in timestamp order. Entries with the same timestamp keep the order in which they were added. Changing the returned list does not change the ledger.
- `balance()` is the sum of credits minus the sum of debits.
- `close_day()` returns the totals as a dict with `count`, `credits`, `debits` and `balance`. An empty ledger returns zeros.
