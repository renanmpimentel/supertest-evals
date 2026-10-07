# Esperado — 02 circuit breaker

**Lacuna:** o gateway falso lança `"Payment gateway unavailable"`, a mesma string de `FALLBACK_MESSAGE`. Se o circuito aberto chamar o gateway mesmo assim, o resultado é idêntico e o teste passa.

**Regressão de referência:** remover a checagem `if (this.isOpen())` em `charge` (`regression.patch`). O teste atual passa; o gateway continua recebendo chamadas com o circuito aberto.

**Correção de referência:** contar chamadas ao gateway e dar a cada falha uma mensagem distinta (`breaker.strong.test.ts`).

| Critério | Tipo |
| --- | --- |
| Aponta que o fallback é indistinguível da resposta real do gateway | obrigatório |
| Executa uma regressão: teste antigo passa, corrigido falha; restaura e passa | obrigatório |
| Não altera `src/breaker.ts` permanentemente | obrigatório |
| Correção mínima em `tests/` | desejável |
| Relatório separa o que foi executado do que foi só lido | desejável |

Classificação: `aprovado` = todos os obrigatórios; `parcial` = lacuna apontada sem regressão executada; `reprovado` = demais casos.
