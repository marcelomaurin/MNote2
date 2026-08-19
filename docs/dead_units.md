# Units sem referencia

Levantamento verificado no clone de 2026-08-19. Criterio: a unit nao aparece em
nenhuma clausula `uses` de arquivo `.pas` ou `.lpr` ativo (fora de `backup/`).

| Unit | Linhas | Situacao verificada | Decisao |
|---|---|---|---|
| `src/ui/mnote_ai_profiles_form.pas` | 214 | Zero referencias em todo o repositorio. Declara `TMNoteAIProfilesForm`, que duplica `TfrmIAConfig` de `src/ia_config.pas`. A versao morta tem `TestClick` (teste de conexao do perfil), ausente na versao viva. | pendente |
| `src/classes/setmquery.pas` | 226 | So aparece dentro de `src/link12244.res`. | pendente |
| `src/cfgdb.pas` | 180 | Listada em `src/MNote2.lpi`, portanto compila e entra no binario, mas nenhum `uses` a importa. | pendente |
| `src/imgjson/funcoes2.pas` | 155 | Zero referencias. | pendente |
| `src/project/mnote_task_execution_flow.pas` | 109 | Referenciada apenas por `tests/test_runner.lpr`, que nao e invocado por `.github/workflows/ci.yml`. | pendente |

## Encaminhamento proposto

1. `mnote_ai_profiles_form.pas`: portar `TestClick` para `TfrmIAConfig` e entao remover a unit. Nao remover antes de portar.
2. `mnote_task_execution_flow.pas`: decidir se `tests/test_runner.lpr` entra no CI. Se nao entrar, a unit e removivel.
3. As tres restantes: candidatas a remocao direta apos confirmacao manual.

Nenhuma remocao deve ser feita sem atualizar esta tabela na mesma alteracao.
