# Regressão dos pacotes CHATGPT afetados

## Ambiente

- Lazarus 4.4;
- Free Pascal 3.2.2;
- alvo local i386-win32.

## Pacotes recompilados do fonte

Todos passaram com build forçado: `openai_project_core`, `openai_project`,
`openai_agentcore`, `openai_agent`, `openai_graphcore`, `openai_graph`,
`openai_files`, `openai_output` e `openai_aidbase`.

## Samples executados

- `agent_memorymap_demo`: aprovado;
- `docfilesmanager_demo`: aprovado;
- `output_docs_demo`: aprovado;
- `project_tasklist_ai_demo`: aprovado.

O último sample revelou uma dependência indevida de GLScene em
`aiindustrial.pas`. A unit de bridge registrava também o componente visual do
braço robótico, embora não o usasse. O registro redundante foi removido da
bridge; o pacote agregador continua registrando o componente e o sample voltou
a compilar sem GLScene.

Não permaneceram regressões novas nos pacotes ou samples testados.
