# Payments API

Payment creation backed by SQLite. The contract is in `CONTRACT.md`.

## Tests

```bash
docker run --rm -v "$PWD":/work -w /work golang:1.27 go test ./...
```
