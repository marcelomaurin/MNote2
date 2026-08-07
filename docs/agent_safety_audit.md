# Auditoria da segurança de agentes

## Decisão verificada no MNote2

O executor cria `TAIAgentSafety` habilitado, fora de simulação e com
`SafeBasePath` igual à raiz absoluta do projeto. Em cada ação, ele envia os
parâmetros reais ao componente; parâmetros `path` e `file` são normalizados
para caminho absoluto. A prova está em `TMNoteAIActionExecutor.Create` e
`ExecuteRequest`, em `src/ai/mnote_ai_actions.pas`.

A organização física da unit no repositório CHATGPT não é afirmada como
concluída nesta auditoria. No checkout validado, a pasta `pacote/AI Agent Core`
e o pacote `openai_agentcore` possuem remoções locais preexistentes, enquanto o
fonte real permanece em `pacote/AI Agent/aiagentsafety.pas`. Inverter essa
fachada sobrescreveria uma refatoração em andamento; a mudança exige decisão do
responsável pelo repositório CHATGPT.

## Camadas ativas

- protocolo JSON estrito, com rejeição de campos e parâmetros desconhecidos;
- matriz explícita de permissões por papel;
- validação local de raiz, arquivo existente, symlink e nomes sensíveis;
- lista explícita de extensões de fonte e texto em `IsAllowedExtension`;
- limite de 2 MB para leitura e paginação de no máximo 20.000 caracteres;
- validação adicional de ação e caminho por `TAIAgentSafety`;
- distinção entre leitura, build e alteração de fonte;
- confirmação obrigatória para `Compile`;
- modo somente leitura para Explain, Find Bugs e Improve;
- limite de saída, rodadas, chamadas, tentativas e orçamento;
- fingerprint de ciclos e bloqueio de repetição;
- hash, diff, gravação atômica, backup e rollback para mudanças;
- log de decisão sem token, senha ou prompt completo.

As guardas de arquivo ficam em `ResolveProjectFile`, e a autorização e o envio
dos parâmetros ao Agent Safety ficam em `ExecuteRequest`, ambos em
`src/ai/mnote_ai_actions.pas`.

## Limites declarados

A LLM não recebe autoridade implícita. Triagem e Árbitro não executam ações. A
IA de banco gera e valida SQL, mas não o executa. Resposta livre não é
interpretada como ação. Nas ações contextuais, uma solicitação de `Compile` é
recusada antes de criar processo.

`TestAIActions`, em `tests/test_runner.lpr`, cobre caminho fora da raiz,
sensíveis, extensão não permitida, binário, paginação, parâmetros desconhecidos,
papel sem permissão e confirmação. `TestAIToolLoop` cobre contrato, limite de
rodadas, orçamento, catálogo, dossiê e somente leitura. `TestSourceChanges` e
`TestEndToEndTaskExecution` cobrem aplicação e rollback.
