# Validação da versão 2.70

Data: 2026-10-16. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2.

## Entrega

A versão 2.70 corrige estabilizações críticas do projeto e consolida o ambiente:
1. Resolução do pacote `openai_voice` em `src/MNote2.lpi` e limpeza de artefatos residuais em `src/lib/`.
2. Correção de Access Violation em `TMNoteAIProfile.ApplyConfig` quando `FSetMain` não está instanciado e proteção de token para `AIP_LOCAL`.
3. Tratamento seguro de saída do console no `src/MNote2.lpr` durante `--smoke-test`, eliminando Runtime Error 217.
4. Remoção de unit órfã duplicada `src/ui/mnote_ai_profiles_form.pas` (funcionalidade portada para `src/ia_config.pas`).
5. Remoção das units mortas `src/classes/setmquery.pas` e `src/imgjson/funcoes2.pas`, com atualização de `docs/dead_units.md`.
6. Limpeza e desindexação de arquivos de cache de IA (`.PIA`) e backups (`.bak`) rastreados indevidamente no repositório.
7. Atualização do `.gitignore` para ignorar `.bak`, `.log`, `.LOG`, `src/lib/` e diretórios de saída de testes.
8. Filtragem de arquivos de cache de IA (`.ria` e `.pia`) na árvore do Solution Explorer (`mnote_solution_explorer_panel.pas`).
9. Limpeza adequada de `FProjectRoot` e `FActionExecutor` em `TMNoteAIService.SetProjectRoot` ao fechar projetos.
10. Sincronização e bump de versão para 2.70 em todos os manifestos, código-fonte e documentação multilíngue.
11. Remoção completa do `srvFalar` (exclusão de `src/srvfalar.py`, `bin/srvfalar*.deb`, referências do instalador Inno Setup e documentação) e modernização do `ToolsFalar` utilizando diretamente o componente nativo de síntese de voz (`TAIVoiceSynthesizer`) da biblioteca CHATGPT.

## Validações

| Portão | Evidência | Resultado |
|---|---|---|
| Build desktop | `src/MNote2.lpi`, i386-win32 | aprovado |
| Instalador Windows | `instalador/MNote2.iss`, Inno Setup 6 | aprovado |
| Integridade do projeto | `python scripts/check_lazarus_project.py` | aprovado |
| Sincronia de versão | `python scripts/check_version_sync.py` | aprovado |
| Smoke test | `tests/run_smoke.ps1` (`MNote2.exe --smoke-test`) | aprovado |
| Testes de diagrama | `tests/run_db_diagram_tests.ps1` (66 checks) | aprovado |
| Testes de abas e árvore | `tests/run_close_tab.ps1`, `tests/run_solution_tree.ps1` | aprovado |
| Testes de busca e heap | `tests/run_search_baseline.ps1`, `tests/run_search_heap.ps1` | aprovado |
| Teste de ownership de syntax | `tests/bin/highlighter_ownership_test.exe` | aprovado |
| Runner de CI portátil | `tests/ci-bin/i386-win32/ci_core_runner.exe` | aprovado |
| Runner completo | `tests/run_tests.ps1` | aprovado |

## Artefatos

- `src/MNote2.exe` — 16.428.051 bytes — SHA-256 `3FEB3851372D1F63CFB95BEB8906DBE94D11437E9E1E788101E16EAACAA20C7E`.
- `bin/win_MNote2_70.exe` — 14.388.037 bytes — SHA-256 `97529D27B2C449F53CEA462C1688E00D0CAE0EE93E1E2D0E6D71165767CF45D6`.
