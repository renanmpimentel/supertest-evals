# Supertest Evals

Casos de pagamento com testes que passam mas não protegem o contrato. Cada lacuna é provada por script: com uma regressão plantada, o teste atual continua verde e o teste corrigido fica vermelho. Os mesmos casos medem se o agente encontra a lacuna com e sem o skill [Supertest](https://github.com/renanmpimentel/supertest).

Versão do skill avaliada: ver `SUPERTEST_VERSION`.

## Casos

| Caso | Stack | Teste atual verifica | Regressão que passa despercebida |
| --- | --- | --- | --- |
| [01 cobrança idempotente](cases/01-idempotent-charge) | Python + pytest | status e ID iguais na repetição | gateway cobrado duas vezes |
| [02 circuit breaker](cases/02-circuit-breaker) | TypeScript + vitest | mensagem de fallback | circuito aberto continua chamando o gateway |
| [03 persistência](cases/03-payment-persistence) | Go + SQLite | `201` e ID | pagamento não é gravado (sem commit) |

## Provar as lacunas

Requer apenas Docker.

```bash
bash scripts/selftest/run.sh   # a verificação rejeita falsos positivos
bash scripts/verify-all.sh     # prova a lacuna de cada caso
```

## Rodar o agente (protocolo manual)

1. `bash scripts/check-skill-version.sh` — a cópia instalada do skill precisa bater com `SUPERTEST_VERSION`.
2. **Sem skill:** mover `~/.claude/skills/supertest` para fora da pasta de skills; `bash scripts/prepare-run.sh cases/<caso> /tmp/evals/<caso>-without`; abrir o Claude Code nessa pasta e enviar `cases/<caso>/_eval/prompt.md`. Salvar o relatório final em `results/<data>-<sha>/<caso>/without-skill.md`. Devolver o skill ao lugar.
3. **Com skill:** nova cópia com `prepare-run.sh` em `/tmp/evals/<caso>-with`; enviar `Carregue o skill Supertest.` seguido do mesmo prompt. Salvar em `with-skill.md`.
4. Classificar cada rodada contra `cases/<caso>/_eval/expected.md` (`aprovado`, `parcial`, `reprovado`) e atualizar a tabela abaixo.

## Resultados

Nenhuma rodada registrada ainda.

| Data | Skill | Caso | Sem skill | Com skill |
| --- | --- | --- | --- | --- |
