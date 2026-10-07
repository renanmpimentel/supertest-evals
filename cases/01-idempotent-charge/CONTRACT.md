# Contrato: cobrança idempotente

- `ChargeService.charge(idempotency_key, amount_cents)` cobra o gateway e retorna `{"id", "amount_cents", "status"}`.
- Duas chamadas com a mesma `idempotency_key` cobram o gateway **uma única vez**; a segunda retorna a mesma cobrança da primeira.
- Chaves diferentes geram cobranças diferentes no gateway.
