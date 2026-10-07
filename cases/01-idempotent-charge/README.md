# Charge service

Serviço de cobrança com chave de idempotência. O contrato está em `CONTRACT.md`.

## Testes

```bash
docker run --rm -v "$PWD":/work -w /work python:3.12-slim \
  sh -c "pip install -q --root-user-action=ignore -r requirements.txt && python -m pytest -q"
```
