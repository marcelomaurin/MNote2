# Auditoria funcional do MNote2

Data da auditoria: 2026-09-19

## Objetivo

Este documento registra o estado funcional observado no MNote2 a partir das
units ativas do projeto, com foco em recursos visíveis ao usuário e em fluxos
que atravessam UI, serviço e execução real.

Estados usados:

- **OK**: fluxo implementado e ligado à interface.
- **PARCIAL**: há implementação relevante, mas o fluxo está incompleto,
  duplicado ou parcialmente integrado.
- **NÃO IMPLEMENTADO**: recurso visível ou declarado sem comportamento útil.
- **LEGADO**: implementação antiga ainda presente e sobreposta pela arquitetura nova.
- **REVISAR**: evento vazio pode ser apenas artefato do Lazarus; não deve ser
  tratado automaticamente como defeito.

## Resumo executivo

A auditoria confirma que o MNote2 possui uma base funcional ampla, mas ainda
mantém recursos visíveis sem implementação e duas gerações de arquitetura
convivendo. O problema principal não é ausência de código: é fechamento de
fluxos e consolidação da interface sobre os serviços novos.

Prioridade imediata:

1. eliminar comandos visíveis que não fazem nada;
2. consolidar seleção de linguagem/highlighter;
3. completar comandos básicos do MQuery2;
4. validar ponta a ponta Agent/Tasks/Changes/Build/Test;
5. retirar caminhos antigos quando o serviço novo já cobre o caso.

## Editor e menus principais

| Funcionalidade | Estado | Evidência | Ação |
| --- | --- | --- | --- |
| Novo/Abrir/Salvar/Salvar todos/Fechar | OK | comandos e handlers ativos em `main.pas` | manter testes |
| Undo/Redo | OK | SynEdit ligado aos handlers | manter |
| Select All | OK | `miSelectAllClick` seleciona o editor ativo e trata ausência de documento | manter teste/regressão |
| Select Command | NÃO IMPLEMENTADO | `miSelectCmdClick` vazio | definir semântica e implementar |
| Select Block | NÃO IMPLEMENTADO | `miSelectBlockClick` vazio | implementar bloco lógico/seleção |
| Find | OK | diálogo e serviço de busca existentes | manter |
| Replace | PARCIAL | fluxo existe, mas há handlers auxiliares vazios | validar seleção e replace em projeto |
| LogView | OK | `MenuItem16Click` delega para `CommandShowOutput` | manter |
| Hide Chat | PARCIAL | `btHideChange` não altera visibilidade | ligar ao painel ou remover controle |
| Associação de extensão/tipo | PARCIAL | `mnAssociarClick` vazio; existe `AssociarExtensao` | ligar UI ao serviço existente |
| Troca manual de linguagem | PARCIAL | itens de Type existem; handlers antigos incompletos | usar registro de linguagens moderno |
| Português/English/Spanish | NÃO IMPLEMENTADO | Português chama handler vazio; demais sem fluxo equivalente | implementar i18n ou remover menu |

## Linguagens e highlighters

O projeto já possui infraestrutura moderna em `src/languages/`, incluindo
registro, perfis, toolbar, temas e opções. Porém a UI antiga ainda expõe itens
Pascal/Python/C/SQL/PHP/Java que não estão todos ligados de forma consistente.

Estado: **PARCIAL**.

Tarefa de consolidação:

- usar uma única função para alterar a linguagem do documento ativo;
- atualizar highlighter, tipo do item, autocomplete e toolbar no mesmo ponto;
- remover comentários antigos do tipo “configurar highlighter se desejar”;
- garantir que todos os itens de menu tenham o mesmo caminho de execução.

## Projeto / Workspace / IDE shell

| Funcionalidade | Estado | Observação |
| --- | --- | --- |
| Abrir pasta/projeto | OK | comandos novos integrados |
| Fechar/salvar/atualizar projeto | OK | fluxo moderno presente |
| Solution Explorer | OK/PARCIAL | painel e testes existem; validar UX completa |
| Files panel | OK/PARCIAL | infraestrutura presente |
| Properties/Outline | OK/PARCIAL | comandos existem; validar estados sem projeto |
| Workspace state | OK | salvar/restaurar implementados |
| Project context | OK | serviço dedicado presente |
| Symbol index | OK/PARCIAL | infraestrutura avançada, depende da linguagem |
| Goto Definition | PARCIAL | resolver Pascal mais maduro que outras linguagens |
| Find References | PARCIAL | depende do índice e do parser |

## IA e Agent

A arquitetura nova é significativamente mais completa que a documentação
histórica. Existem serviço assíncrono, perfis, router, sessão, memória, catálogo
de ferramentas, confirmação de ações, planejamento e fluxo revisável de
mudanças.

| Funcionalidade | Estado | Observação |
| --- | --- | --- |
| Chat IA | OK | fluxo principal existe |
| Perfis de IA | OK | configuração e teste de perfil presentes |
| Cancelar IA | OK/PARCIAL | comando existe; validar todos os providers |
| Explain | OK | integrado |
| Find Bugs | OK | integrado |
| Suggest Improvement | OK | integrado |
| Completion | OK/PARCIAL | integrado, qualidade depende do contexto |
| Propose Change | OK/PARCIAL | contrato de mudança presente |
| Tool loop | OK | coberto por testes |
| ReadFile/SearchProject/ListSymbols | OK | capability matrix e testes |
| FindDefinition/DependencyGraph | OK/PARCIAL | melhor em Pascal |
| GitLog/GitDiff | OK | leitura apenas |
| Compile via IA | OK | exige confirmação |
| Agent developer actions | PARCIAL | read/replace/build/test existem; validar UI completa |
| Planejamento em tarefas | PARCIAL | contratos e painéis existem; validar ciclo completo |
| Recuperação de erro | OK/PARCIAL | existe no serviço; validar provider real |
| Modos de autonomia/permissão | PARCIAL | segurança existe, política ainda pode ser consolidada |

### Fluxo que deve ser validado como critério de produto

```text
Pergunta
  -> tarefa
  -> plano
  -> subtarefas
  -> coleta de contexto
  -> proposta
  -> diff
  -> confirmação
  -> aplicação
  -> build
  -> testes
  -> correção
  -> conclusão com evidências
```

O projeto possui peças desse fluxo, mas a auditoria ainda não considera todo o
ciclo como “produto fechado” até haver teste ponta a ponta pela UI.

## Build, Output, Problems e Terminal

| Funcionalidade | Estado | Observação |
| --- | --- | --- |
| Build/Rebuild | OK/PARCIAL | serviço existe; CI de projeto integral ainda em estabilização |
| Stop Build | OK/PARCIAL | comando existe; validar término de processo em todas as plataformas |
| Output | OK | modelo/painel dedicado |
| Problems | OK | integração com diagnóstico |
| Terminal | PARCIAL | painel existe; validar execução, cwd, cancelamento e persistência |
| Run Project | PARCIAL | depende do tipo de projeto/configuração |

## Python

| Funcionalidade | Estado | Observação |
| --- | --- | --- |
| Executar Python | OK | serviço novo presente |
| Stop Python | OK/PARCIAL | validar interrupção real |
| Environment/diagnóstico | OK | comandos específicos presentes |
| Integração antiga via item | LEGADO/PARCIAL | convive com serviço novo |

Ação recomendada: centralizar toda execução Python no serviço moderno e reduzir
a execução direta antiga.

## Voz

| Funcionalidade | Estado | Observação |
| --- | --- | --- |
| Saída de voz | OK/PARCIAL | serviço e configuração presentes |
| Entrada/comando de voz | PARCIAL | legado ToolsOuvir + infraestrutura nova |
| Wake word “OK MNote” | OPCIONAL | capability matrix considera opcional |
| TCP ToolsFalar/ToolsOuvir | LEGADO/PARCIAL | ainda ativo como ferramenta auxiliar |

## Banco de dados e MQuery2

MQuery2 é funcional em várias áreas, mas contém alguns dos exemplos mais claros
de recursos visíveis não concluídos.

| Funcionalidade | Estado | Evidência |
| --- | --- | --- |
| MySQL | OK | conexão, navegação e execução |
| PostgreSQL | OK | conexão, navegação e execução |
| SQLite | OK | conexão e execução |
| Executar SQL | OK | fluxos por banco |
| Save SQL | OK | `MenuItem5Click` salva arquivo |
| Load SQL | OK | `MenuItem6Click` carrega no editor SQL da conexão ativa |
| Migration to PostgreSQL | NÃO IMPLEMENTADO | botão visível `Button3` com handler vazio |
| Import CSV | OK/PARCIAL | implementação presente; validar casos de erro |
| Dicionário de dados | OK | integração nova disponível |
| Dependências/relacionamentos | OK/PARCIAL | geração existente |
| SQL com IA | OK/PARCIAL | integração existe |
| Charts | OK/PARCIAL | há handlers ativos |
| Ocultar PostgreSQL | REVISAR/NÃO IMPLEMENTADO | `miOcultarPostClick` vazio |
| Alguns eventos de editor/grid | REVISAR | eventos vazios podem ser desnecessários |

## Folders / análise de projeto

Estado geral: **PARCIAL/LEGADO**.

O módulo possui scanner, cache RIA/PIA, análise por IA e navegação, mas concentra
muita lógica de UI, cache e análise em uma única form. Foram encontrados eventos
vazios e referências a estados “pendente da pergunta”.

Ação recomendada:

- preservar o que ainda tem uso real;
- migrar análise de projeto para `ProjectContext`, índice de símbolos e ações
  modernas de IA;
- manter RIA/PIA apenas se houver valor que não esteja coberto pelo novo fluxo.

## ImgJSON

Estado: **REVISAR/PARCIAL**.

O módulo continua registrado no projeto e funciona quase como uma aplicação
embutida. Deve ser auditado como produto separado para decidir entre:

- manter como ferramenta integrada;
- transformar em plugin/módulo opcional;
- retirar da aplicação principal.

## Documentos PDF/DOC/DOCX

Estado: **PARCIAL**.

Extração existe, porém:

- PDF escaneado sem camada de texto não é resolvido por OCR;
- DOC clássico pode depender do ambiente;
- DOCX tende a ser mais portátil.

## Código legado e handlers vazios

Nem todo método vazio é funcionalidade quebrada. Eventos como `Change`,
`Enter`, `ClickLink`, `GutterClick` e outros podem ter sido criados pelo
designer e nunca terem sido necessários.

Regra para esta auditoria:

- se existe controle/menu visível com legenda funcional e o handler está vazio:
  **NÃO IMPLEMENTADO**;
- se o evento é técnico e não há comportamento prometido ao usuário:
  **REVISAR**;
- se o recurso novo substituiu o antigo:
  **LEGADO**.

## Critério de conclusão da auditoria

Uma funcionalidade só muda para **OK** quando atende aos seguintes pontos
aplicáveis:

1. está acessível pela UI ou comando;
2. executa uma ação real;
3. apresenta resultado ou erro;
4. trata ausência de projeto/documento/conexão;
5. permite cancelamento quando longa;
6. não depende de caminho pessoal;
7. possui teste automatizado ou teste de integração reproduzível;
8. não possui implementação antiga concorrente sem justificativa.

## Próxima etapa

Usar `docs/functional_backlog.md` como fila de execução e atualizar este
documento a cada funcionalidade concluída.
