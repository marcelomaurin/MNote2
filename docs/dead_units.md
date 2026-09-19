# Units sem referencia

Levantamento original verificado no clone de 2026-08-19. O estado abaixo foi
revalidado em 2026-09-19. Criterio: a unit nao aparece em nenhuma clausula
`uses` de arquivo `.pas` ou `.lpr` ativo (fora de `backup/`).

| Unit | Situacao verificada | Decisao |
|---|---|---|
| `src/ui/mnote_ai_profiles_form.pas` | Zero referencias. `TfrmIAConfig` ja possui `TestClick` com validacao de aba e persistencia da configuracao. | removida em 2026-09-19 |
| `src/classes/setmquery.pas` | Sem referencias ativas. | removida em 2026-09-19 |
| `src/cfgdb.pas` + `src/cfgdb.lfm` | Nao havia `uses`; apenas registro explicito no `MNote2.lpi`. | removidos em 2026-09-19 e projeto Lazarus atualizado |
| `src/imgjson/funcoes2.pas` | Zero referencias ativas. | removida em 2026-09-19 |
| `src/project/mnote_task_execution_flow.pas` | Referenciada por `tests/test_runner.lpr`; portanto possui cobertura funcional fora do CI principal. | manter; integrar `test_runner` ao CI antes de nova decisao |

## Regra para novas remocoes

1. Confirmar ausencia de `uses`, registro no `.lpi`, inicializacao dinamica ou
   referencia de recurso.
2. Quando existir funcionalidade exclusiva em uma unit duplicada, portar a
   funcionalidade antes de apagar a unit antiga.
3. Atualizar esta tabela na mesma alteracao.
4. Executar o validador de projeto e a suite de testes antes do merge.

## Proximos candidatos

- Tela duplicada de perfis IA removida; manter apenas `TfrmIAConfig` como interface de configuracao.
- Colocar `tests/test_runner.lpr` no CI para que o fluxo de execucao de tarefas
  deixe de depender de teste manual.
