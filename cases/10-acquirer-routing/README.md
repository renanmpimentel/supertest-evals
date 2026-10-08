# Acquirer routing

Acquirer selection for card payments. The rules are in `CONTRACT.md`.

## Tests

```bash
docker run --rm -v "$PWD":/work -w /work golang:1.27 go test ./...
```
