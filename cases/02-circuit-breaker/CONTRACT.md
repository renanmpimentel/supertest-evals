# Contrato: circuit breaker do gateway

- Após `threshold` falhas consecutivas do gateway, o circuito abre.
- Com o circuito aberto, `charge` não chama o gateway e retorna `{ ok: false, message: FALLBACK_MESSAGE }`.
- Com o circuito fechado, uma falha do gateway retorna `{ ok: false, message: <mensagem do erro> }`; um sucesso retorna `{ ok: true, chargeId }` e zera as falhas.
