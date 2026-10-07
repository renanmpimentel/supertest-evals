# Gateway breaker

Circuit breaker around the payment gateway. The contract is in `CONTRACT.md`.

## Tests

```bash
docker run --rm -v "$PWD":/work -w /work node:24-slim sh -c "npm ci && npx vitest run"
```
