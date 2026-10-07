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

Requer no host: Docker, bash, git e tar. Para o protocolo de execução do agente, também é preciso um clone do repositório do Supertest (padrão `~/export/supertest`; sobrescreva com `SUPERTEST_REPO`). Variáveis opcionais de `scripts/check-skill-version.sh`: `SUPERTEST_INSTALLED` (cópia instalada do skill, padrão `~/.claude/skills/supertest`) e `SUPERTEST_SHA` (commit a verificar, no lugar do conteúdo de `SUPERTEST_VERSION`).

```bash
bash scripts/selftest/run.sh   # a verificação rejeita falsos positivos
bash scripts/verify-all.sh     # prova a lacuna de cada caso
```

## Rodar o agente (protocolo manual)

**Evite vazamento do gabarito.** O agente não pode ler `cases/*/_eval` (nem por caminho absoluto) nem recuperá-lo por ferramentas de memória entre projetos (por exemplo, um servidor MCP de memória que indexou as sessões em que os gabaritos foram escritos). Rode o agente com essas ferramentas de memória desativadas ou fora do escopo, e a partir de um diretório fora deste repositório.

1. `bash scripts/check-skill-version.sh` — a cópia instalada do skill precisa bater com `SUPERTEST_VERSION`.
2. Crie a pasta de resultados `results/<data>-<sha>/<caso>/`. Para cada rodada, prepare uma cópia com nome neutro: `bash scripts/prepare-run.sh cases/<caso> "$(mktemp -d)/project"`. Registre na pasta de resultados qual cópia corresponde a qual braço (`without-skill` ou `with-skill`); o nome da pasta não deve indicá-lo.
3. **Sem skill:** mover `~/.claude/skills/supertest` para fora da pasta de skills; abrir o Claude Code na cópia e enviar `cases/<caso>/_eval/prompt.md`. Devolver o skill ao lugar depois.
4. **Com skill:** outra cópia nova; enviar `Carregue o skill Supertest.` seguido do mesmo prompt.
5. Ao fim de cada rodada, salve na pasta de resultados, com `<braço>` igual a `without-skill` ou `with-skill`:
   - o relatório final do agente: `<braço>.md`;
   - `git -C <cópia> diff baseline > <braço>.diff`;
   - `git -C <cópia> status --porcelain > <braço>.status`;
   - a transcrição ou exportação da sessão, se disponível: `<braço>.transcript`.

   Os critérios "não altera código de produção" e "executa regressão e restaura" são avaliados nesses arquivos (diff, status e transcrição), não só no relatório do agente.
6. Opcional: confirme que o teste corrigido pelo agente pega a regressão. Numa cópia descartável com o diff do agente aplicado, aplique `cases/<caso>/_eval/regression.patch` (`git apply`) e rode o comando de teste do caso (ver `STRONG_CMD` em `_eval/verify.sh`) no arquivo de teste do agente; ele deve falhar por asserção.
7. Classificar cada rodada contra `cases/<caso>/_eval/expected.md` (`aprovado`, `parcial`, `reprovado`) e atualizar a tabela abaixo.

## Resultados

Nenhuma rodada registrada ainda.

| Data | Skill | Caso | Sem skill | Com skill |
| --- | --- | --- | --- | --- |
