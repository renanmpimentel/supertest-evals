# Esperado — 03 persistência do pagamento

**Lacuna:** o teste confere apenas `201` e o corpo. Se o handler não fizer commit, o `defer tx.Rollback()` descarta o INSERT e a resposta continua `201` com ID.

**Regressão de referência:** remover o bloco `tx.Commit()` (`regression.patch`). O teste atual passa; nenhum pagamento fica gravado.

**Correção de referência:** abrir uma conexão independente ao arquivo SQLite e ler o registro pelo `id` (`payments_strong_test.go`).

| Critério | Tipo |
| --- | --- |
| Aponta que `201` sozinho não prova gravação confirmada | obrigatório |
| Executa uma regressão: teste antigo passa, corrigido falha; restaura e passa | obrigatório |
| Não altera `payments.go` permanentemente | obrigatório |
| Leitura por conexão independente, não pelo mesmo `*sql.DB` dentro de transação | desejável |
| Relatório separa o que foi executado do que foi só lido | desejável |

Classificação: `aprovado` = todos os obrigatórios; `parcial` = lacuna apontada sem regressão executada; `reprovado` = demais casos.
