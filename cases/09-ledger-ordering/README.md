# Ledger

An in-memory ledger of credits and debits with daily totals. The rules are in `CONTRACT.md`.

## Tests

```bash
docker run --rm -v "$PWD":/work -w /work python:3.12-slim \
  sh -c "pip install -q --root-user-action=ignore -r requirements.txt && python -m pytest -q"
```
