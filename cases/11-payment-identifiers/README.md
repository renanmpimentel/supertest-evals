# Payment identifiers

Validation of identifiers received in payment API requests. The rules are in `CONTRACT.md`.

## Tests

```bash
docker run --rm -v "$PWD":/work -w /work node:24-slim sh -c "npm ci && npx vitest run"
```
