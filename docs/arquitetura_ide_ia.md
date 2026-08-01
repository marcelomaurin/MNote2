# Arquitetura da IDE com IA

## Princípios

O MNote2 permanece uma aplicação desktop Lazarus/Free Pascal. Forms coordenam a
interface; regras ficam em units sem UI, dentro de `src/services`, `src/search`,
`src/completion`, `src/project`, `src/sourcechange`, `src/ai` e `src/commands`.
Componentes reutilizáveis pertencem aos pacotes `openai_*` do CHATGPT.

Tokens e senhas são configuração local. Resposta livre nunca é executada.
Mudanças propostas pela IA usam JSON estrito, diff revisável, confirmação,
gravação atômica, histórico e rollback.

## Áreas e responsáveis

| Área | Interface | Núcleo responsável |
|---|---|---|
| Shell e layout | `main.pas`, `mnote_ide_shell` | `mnote_tool_windows`, `mnote_commands` |
| Editor e linguagem | editor em abas | `src/languages`, temas e opções editoriais |
| Search/Replace | barra e Search Results | `src/search/*` |
| Completion | popup e comandos de navegação | `src/completion/*` |
| Projeto e tarefas | Tasks e Task List | `TMNoteProjectService`, `openai_project_core` |
| IA | painel AI e AI Monitor | `TMNoteAIService`, router, bus, perfis e sessão |
| Voz | ToolsOuvir/ToolsFalar | comando de ativação e adaptadores de fala/escuta |
| Mudanças | painel Changes | `TAISourceChangeManager`, contrato e diff |
| Banco | MQuery2 e Data Dictionary | `TMNoteDBDictionaryService`, `openai_aidbase` |
| Build | Problems, Output e Terminal | processo, build service e diagnósticos |
| Capacidades | Files e Components Lab | inventário, documentos, grafo e catálogo |

Services não conhecem forms. A UI fornece buffer, seleção, raiz e autorização;
recebe dados tipados, estado e mensagens de erro reais.

## Fluxo por modalidade

1. Texto digitado cria uma requisição de texto; fala reconhecida cria uma
   requisição de voz.
2. Comando de voz só é encaminhado depois da frase de ativação configurável,
   cujo padrão é “OK MNote”.
3. A camada Gestão entende objetivo e escopo. Dúvida material gera pergunta de
   confirmação antes de qualquer ação.
4. Router e Triagem selecionam deterministicamente perfil, orçamento e limites.
5. Ações exigidas são contratos JSON, passam pela matriz de permissões e
   retornam evidência real.
6. Entrada digitada recebe texto. Entrada por voz recebe texto de auditoria e
   síntese de voz. Pedido digitado nunca dispara fala automática.

## Segurança em camadas

- caminho, extensão, tamanho, symlink e raiz validados;
- leitura, build e escrita são efeitos distintos;
- Triagem e Árbitro não possuem executor;
- ações privilegiadas exigem confirmação;
- erros de autenticação/configuração não entram em retry;
- retry transitório, correção de contrato, rodadas e reorientação têm limites;
- ciclos usam fingerprints coerentes;
- Apply exige hash original e validação posterior;
- logs e arquivos persistidos removem segredos.

## Dependências e portabilidade

O núcleo consome `openai_core`, `openai_project_core`, `openai_agentcore`,
`openai_graphcore`, `openai_aidbase` e os componentes Python já existentes.
CEF, visão, ML, industrial, rede e hardware são opcionais e aparecem apenas no
AI Components Lab. `TAIPipeline` fica fora do núcleo.

As units portáteis compilam com FPC 3.2.2 em Windows e Linux x64 no CI. A
entrega desktop de referência permanece i386-win32 por compatibilidade com os
componentes instalados no projeto original.
