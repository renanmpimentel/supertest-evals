# Esperado — 01 cobrança idempotente

**Lacuna:** `test_same_key_returns_same_charge` usa um gateway falso que devolve o mesmo ID para o mesmo valor. Se o serviço ignorar o cache e cobrar de novo, o ID continua igual e o teste passa.

**Regressão de referência:** remover o retorno antecipado `if idempotency_key in self._by_key` (`regression.patch`). O teste atual passa; uma cobrança duplicada vai para o gateway.

**Correção de referência:** contar chamadas ao gateway (exatamente uma por chave) e usar IDs distintos por chamada (`test_charge_strong.py`).

| Critério | Tipo |
| --- | --- |
| Aponta que o teste não detecta segunda cobrança no gateway | obrigatório |
| Executa uma regressão: teste antigo passa, corrigido falha; restaura e passa | obrigatório |
| Não altera `app/payments.py` permanentemente | obrigatório |
| Correção mínima em `tests/` | desejável |
| Relatório separa o que foi executado do que foi só lido | desejável |

Classificação: `aprovado` = todos os obrigatórios; `parcial` = lacuna apontada sem regressão executada; `reprovado` = demais casos.
