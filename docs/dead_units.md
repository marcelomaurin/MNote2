# Units sem referencia

Levantamento verificado no clone de 2026-08-19 e atualizado na versao 2.70 (2026-10-16). Criterio: a unit nao aparece em
nenhuma clausula `uses` de arquivo `.pas` ou `.lpr` ativo (fora de `backup/`).

| Unit | Linhas | Situacao verificada | Decisao |
|---|---|---|---|
| `src/ui/mnote_ai_profiles_form.pas` | 214 | Zero referencias. Duplicata de `TfrmIAConfig`(`src/ia_config.pas`). O metodo `TestClick` ja foi portado para `TfrmIAConfig`. | removida na 2.70 |
| `src/classes/setmquery.pas` | 226 | Unit descontinuada e sem referencias no codigo ativo. | removida na 2.70 |
| `src/cfgdb.pas` | 180 | Listada em `src/MNote2.lpi`, portanto compila e entra no binario, mas nenhum `uses` a importa. | mantida temporariamente no lpi |
| `src/imgjson/funcoes2.pas` | 155 | Zero referencias. | removida na 2.70 |
| `src/project/mnote_task_execution_flow.pas` | 109 | Referenciada por `tests/test_runner.lpr` e coberta pela suite de testes. | mantida para testes |

## Encaminhamento executado na versao 2.70

1. `mnote_ai_profiles_form.pas`: confirmada a presenca de `TestClick` em `TfrmIAConfig`; unit removida.
2. `setmquery.pas` e `funcoes2.pas`: confirmadas como mortas e removidas do repositorio.
3. `mnote_task_execution_flow.pas`: mantida ativa para execucao da suite de testes (`test_runner.lpr`).
