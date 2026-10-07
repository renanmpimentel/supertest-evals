# Contrato: criação de pagamento

- `POST /payments` com `{"amount_cents": N}` e `N > 0` grava o pagamento e responde `201` com `{"id", "amount_cents"}`.
- `201` significa que o pagamento está gravado e confirmado (commit): o pagamento passa a existir no banco.
- `amount_cents <= 0` ou corpo inválido responde `400` sem gravar nada.
