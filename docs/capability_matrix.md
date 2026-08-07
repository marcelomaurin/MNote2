# Matriz de capacidades

Esta matriz registra apenas capacidades com uma implementação e uma prova
localizáveis. O catálogo entregue ao modelo é gerado por
`TMNoteAIActionExecutor.DescribeActions`, em `src/ai/mnote_ai_actions.pas`.

| Capacidade | Estado | Implementação | Prova |
|---|---|---|---|
| Ações contextuais Explain, Find Bugs e Improve | Integrado, somente leitura | `src/main.pas` (`StartCodeAction`) e `src/services/mnote_ai_service.pas` (`ExecuteContextualCodeAction`) | `tests/test_runner.lpr` (`TestAIToolLoop`) |
| `ReadFile` | Integrado; paginação por linha ou caractere, máximo de 20.000 caracteres por página e 2 MB por arquivo | `src/ai/mnote_ai_actions.pas` (`ExecuteReadFile`) | `TestAIActions`: remontagem exata, faixas inválidas, binário e arquivo sensível |
| `FileOutline` | Integrado para fontes Pascal | `src/ai/mnote_ai_actions.pas` (`ExecuteFileOutline`) | `TestAIActions`: seções e símbolos do arquivo |
| `SearchProject` | Integrado | `src/ai/mnote_ai_actions.pas` (`ExecuteSearchProject`) | `TestAIActions`: busca real na fixture |
| `ListSymbols` | Integrado; filtros aplicados antes do limite e falhas parciais declaradas | `src/ai/mnote_ai_actions.pas` e `src/completion/mnote_project_symbol_index.pas` | `TestAIActions`: filtros e arquivo indisponível |
| `FindDefinition` | Integrado; devolve homônimos | `src/ai/mnote_ai_actions.pas` (`ExecuteFindDefinition`) | `TestAIActions`: definição existente e inexistente |
| `DependencyGraph` | Integrado; arestas factuais e inferidas são identificadas | `src/ai/mnote_ai_actions.pas` (`ExecuteDependencyGraph`) | `TestAIActions`: direções `uses`, `used_by` e `both` |
| `BuildDiagnostics` | Integrado; consulta o último build sem iniciar processo | `src/services/mnote_diagnostics.pas`, `src/ui/mnote_problems_panel.pas` e `src/ai/mnote_ai_actions.pas` | `TestAIActions`: ausência de build, snapshot e contador de processos |
| `ListProjectFiles` | Integrado | `src/ai/mnote_ai_actions.pas` (`ExecuteListProjectFiles`) | `TestAIActions`: listagem limitada à fixture |
| `GitLog` e `GitDiff` | Integrado em modo leitura | `src/ai/mnote_ai_actions.pas` | `TestAIActions`: rejeição de argumento Git injetável |
| `DBDictionary` | Integrado quando o dicionário é fornecido pela aplicação | `src/ai/mnote_ai_actions.pas` (`ExecuteDictionary`) e `src/services/mnote_ai_service.pas` (`SetProjectRoot`) | `TestAIActions` e `TestAIProjectRootRefresh` |
| `Compile` | Integrado com confirmação; falha retorna diagnóstico e `ok:false` | `src/ai/mnote_ai_actions.pas` (`ExecuteCompile`) | `TestAIActions`: recusa sem confirmação e erro real |
| Ciclo de ferramentas | Integrado; dossiê acumulado, catálogo reinjetado, correção única de contrato e limites de rodada/chamadas/orçamento | `src/services/mnote_ai_service.pas` (`ExecuteWithTools`) e `src/ai/mnote_ai_profile.pas` | `TestAIToolLoop` sem acesso à rede |
| Mudanças de fonte | Integrado por fluxo separado, revisável | `src/sourcechange/*` | `TestSourceChanges` e `TestEndToEndTaskExecution` |
| Voz com “OK MNote” | Opcional | `src/services/mnote_voice_command.pas` | `tests/ci_core_runner.lpr` |
| CEF, visão, ML, industrial, rede e hardware | Opcional | inventário de componentes da IDE | ausência não é tratada como resultado simulado |

“Integrado” significa que o caminho pode ser chamado e possui teste local ou de
CI. “Opcional” nunca significa simulado.
