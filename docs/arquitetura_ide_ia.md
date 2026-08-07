# Arquitetura da IDE com IA

## Princípios

O MNote2 permanece uma aplicação desktop Lazarus/Free Pascal. A interface
coordena buffers, seleção e raiz do projeto; as regras ficam em units sem UI em
`src/services`, `src/search`, `src/completion`, `src/project`,
`src/sourcechange`, `src/ai` e `src/commands`.

Respostas livres nunca são executadas. Uma ferramenta só é acionada por um
objeto JSON estrito — puro ou dentro de uma única cerca `json` — validado pelo
catálogo e pela matriz de permissões. Mudanças de fonte continuam no fluxo
separado de Changes, com diff, confirmação, gravação atômica e rollback.

## Caminho das ações contextuais

1. `StartCodeAction`, em `src/main.pas`, captura a seleção ou o buffer inteiro e
   envia metadados de arquivo, linguagem, linhas e origem.
2. `ExecuteContextualCodeAction`, em `src/services/mnote_ai_service.pas`, abre
   uma sessão, consulta `BuildDiagnostics` e `DependencyGraph` e monta o dossiê
   inicial. Explain, Find Bugs e Improve recebem somente o catálogo de leitura.
3. O perfil Trabalho Leve pode responder em texto ou pedir uma ação. Um pedido
   malformado recebe exatamente uma tentativa de correção de contrato.
4. Cada resultado real é registrado na sessão e acrescentado ao dossiê. A
   rodada seguinte sempre recebe a pergunta original, as evidências preservadas
   e o catálogo completo gerado por `DescribeActions`.
5. Se o contexto não couber, evidências antigas são omitidas primeiro e o fato
   é registrado; o catálogo não é truncado.
6. O ciclo termina com resposta final, erro não recuperável, orçamento global,
   limite de chamadas ou `max_tool_rounds`. O padrão é 8 rodadas e a opção é
   persistida em `mnote_ai.json` por `src/ai/mnote_ai_profile.pas`.

Esse fluxo é exercitado sem rede por `TestAIToolLoop`, em
`tests/test_runner.lpr`, incluindo cerca Markdown, correção de contrato,
retenção do dossiê, reinjeção do catálogo, limites e modo somente leitura.

## Ações e dados reais

O executor `src/ai/mnote_ai_actions.pas` expõe `ReadFile`, `FileOutline`,
`SearchProject`, `ListSymbols`, `FindDefinition`, `DependencyGraph`,
`BuildDiagnostics`, `ListProjectFiles`, `GitLog`, `GitDiff`, `DBDictionary` e
`Compile`. A descrição entregue ao modelo é produzida do mesmo registro usado
para executar, evitando divergência entre prompt e implementação.

`BuildDiagnostics` lê o snapshot thread-safe mantido por
`src/services/mnote_diagnostics.pas`; ele não dispara compilação. `Compile` é
uma ação distinta, exige confirmação e atualiza esse snapshot. O índice de
símbolos registra arquivos que falharam, permitindo resultado parcial explícito
em vez de ocultar a falha.

## Segurança em camadas

- o contrato rejeita texto adicional, campos e parâmetros desconhecidos;
- a raiz absoluta, caminho, symlink, arquivo sensível, extensão e tamanho são
  validados antes da leitura;
- os parâmetros reais da solicitação são entregues a `TAIAgentSafety`, com
  caminhos normalizados para absolutos;
- Triagem e Árbitro não executam ações;
- ações contextuais aceitam apenas ferramentas de leitura;
- build e demais efeitos privilegiados exigem confirmação;
- orçamento, chamadas, rodadas e correção de contrato têm limites independentes;
- logs não persistem tokens, senhas ou o prompt completo.

As guardas e os resultados são cobertos por `TestAIActions` e
`TestAIToolLoop`, em `tests/test_runner.lpr`.

## Dependências e portabilidade

O núcleo consome os pacotes `openai_core`, `openai_project_core`,
`openai_agentcore`, `openai_graphcore` e `openai_aidbase`. CEF, visão, ML,
industrial, rede e hardware permanecem opcionais. O núcleo portátil é validado
por `tests/ci_core_runner.lpr`; a integração desktop completa é validada por
`tests/run_tests.ps1` em i386-win32.
