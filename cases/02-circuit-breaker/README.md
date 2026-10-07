# Gateway breaker

Circuit breaker em volta do gateway de pagamento. O contrato está em `CONTRACT.md`.

## Testes

```bash
docker run --rm -v "$PWD":/work -w /work node:24-slim sh -c "npm ci && npx vitest run"
```
