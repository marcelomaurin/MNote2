# Matriz de capacidades

| Capacidade | Estado nesta entrega | Caminho verificável |
|---|---|---|
| Chat e assistência de código | Integrado | painel AI e comandos Explain/Find Bugs/Improve |
| Multi-IA com seis papéis | Integrado | perfis, router, bus e AI Monitor |
| Voz com “OK MNote” | Integrado/opcional | entrada por voz responde por fala; pode ser desativada |
| Search/Replace UTF-8 | Integrado | editor, arquivos, filtros, preview e rollback |
| Autocomplete local | Integrado | popup, snippets, símbolos, SQL, F12 e Shift+F12 |
| Projeto e tarefas | Integrado | Tasks, Task List, Gantt, Timeline e Risk Matrix |
| Mudanças de fonte | Integrado | Changes, diff por hunk, aprovação, apply e rollback |
| Banco PostgreSQL/SQLite | Integrado | Data Dictionary, exportação, completion e contexto IA |
| MySQL e outros bancos | Experimental | status e placeholders são validados por protocolo |
| Build/Problems/Output | Integrado | processo real, parser FPC e canais independentes |
| Files e documentos | Integrado | scanner, exportação TXT/PDF e confirmação de escrita |
| Grafo de dependências | Integrado | arestas factuais e inferidas identificadas |
| Chromium/CEF | Opcional, não carregado | AI Components Lab informa disponibilidade |
| Visão, ML e hardware | Opcional, não carregado | ausência não impede a IDE de iniciar |
| Rede/industrial | Laboratório | dependências e estado reais, sem simulação |
| `TAIPipeline` | Opcional, fora do núcleo | fluxo próprio `TMNoteTaskExecutionFlow` |

“Integrado” significa que existe tela ou fluxo chamável e prova automatizada ou
de compilação. “Opcional” nunca significa simulado.
