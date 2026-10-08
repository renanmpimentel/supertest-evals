"""In-memory ledger of credits and debits."""

import bisect
from dataclasses import dataclass

KINDS = ("credit", "debit")


class LedgerError(ValueError):
    pass


@dataclass(frozen=True)
class Entry:
    timestamp: int
    kind: str
    amount_cents: int


class Ledger:
    def __init__(self):
        self._entries = []

    def add(self, timestamp, kind, amount_cents):
        if kind not in KINDS:
            raise LedgerError(f"unknown kind {kind!r}")
        if amount_cents <= 0:
            raise LedgerError("amount must be positive")
        if timestamp < 0:
            raise LedgerError("timestamp must not be negative")
        bisect.insort(self._entries, Entry(timestamp, kind, amount_cents), key=lambda e: e.timestamp)

    def entries(self):
        return list(self._entries)

    def balance(self):
        total = 0
        for entry in self._entries:
            total += entry.amount_cents if entry.kind == "credit" else -entry.amount_cents
        return total

    def close_day(self):
        self._entries.sort(key=lambda e: e.timestamp)
        credits = sum(e.amount_cents for e in self._entries if e.kind == "credit")
        debits = sum(e.amount_cents for e in self._entries if e.kind == "debit")
        return {
            "count": len(self._entries),
            "credits": credits,
            "debits": debits,
            "balance": credits - debits,
        }
