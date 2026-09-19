# Backlog funcional do MNote2

Este backlog deriva de `docs/functional_audit.md`.

## P0 — recursos visíveis sem implementação

### F-001 — Select All
- **Arquivo:** `src/main.pas`
- **Handler:** `TfrmMNote.miSelectAllClick`
- **Problema:** menu visível; handler vazio.
- **Aceite:** selecionar todo o conteúdo do editor ativo; não gerar exceção sem aba aberta.
- **Teste:** abrir documento, executar comando, validar `SelText = Text`.

### F-002 — Select Command
- **Arquivo:** `src/main.pas`
- **Handler:** `TfrmMNote.miSelectCmdClick`
- **Problema:** menu visível; handler vazio.
- **Aceite:** selecionar comando/statement em torno do cursor usando regra por linguagem.
- **Primeira versão:** seleção até delimitador/linha lógica; Pascal/SQL como prioridade.

### F-003 — Select Block
- **Arquivo:** `src/main.pas`
- **Handler:** `TfrmMNote.miSelectBlockClick`
- **Problema:** menu visível; handler vazio.
- **Aceite:** selecionar bloco sintático quando reconhecido; fallback seguro para bloco de linhas.

### F-004 — LogView
- **Arquivo:** `src/main.pas`
- **Handler:** `TfrmMNote.MenuItem16Click`
- **Problema:** Tools > LogView não faz nada.
- **Aceite:** abrir/focar o painel moderno Output/Log; remover tela antiga se redundante.

### F-005 — Load SQL no MQuery2
- **Arquivo:** `src/mquery2/mquery2.pas`
- **Handler:** `Tfrmmquery2.MenuItem6Click`
- **Problema:** File > Load SQL não faz nada.
- **Aceite:** abrir diálogo, carregar arquivo SQL no editor da conexão ativa, preservar encoding e reportar erro.

### F-006 — Migration to PostgreSQL
- **Arquivo:** `src/mquery2/mquery2.pas`
- **Handler:** `Tfrmmquery2.Button3Click`
- **Problema:** botão visível sem implementação.
- **Aceite mínimo:** wizard/fluxo explícito com origem, destino, preview, confirmação e log.
- **Segurança:** nunca executar DDL/DML destrutivo sem confirmação.
- **Observação:** se a funcionalidade não fizer mais parte do produto, remover o botão em vez de deixá-lo inerte.

### F-007 — seleção manual de linguagem
- **Arquivos:** `src/main.pas`, `src/main.lfm`, `src/languages/*`
- **Problema:** menus antigos Pascal/Python/C/SQL/PHP/Java não usam de forma uniforme a infraestrutura nova.
- **Aceite:** todos os itens chamam um único caminho de aplicação de linguagem; atualizar highlighter, tipo, autocomplete e UI.

### F-008 — associação de extensão/tipo
- **Arquivo:** `src/main.pas`
- **Handler:** `mnAssociarClick`
- **Problema:** handler vazio apesar da existência de `AssociarExtensao`.
- **Aceite:** associação funcional, persistida e refletida no documento ativo.

### F-009 — idioma da interface
- **Arquivos:** `src/main.pas`, `src/main.lfm`
- **Problema:** Português possui handler vazio; English/Spanish não têm fluxo equivalente.
- **Decisão necessária:** implementar i18n real ou remover menu até existir suporte.
- **Aceite se mantido:** captions principais, dialogs e mensagens localizáveis sem reinicialização obrigatória.

## P1 — fechar fluxos modernos

### F-101 — Agent ponta a ponta
Validar UI -> tarefa -> plano -> ferramentas -> proposta -> diff -> confirmação ->
apply -> build -> testes -> conclusão.

### F-102 — Tasks/Subtasks
Garantir criação, persistência, dependências, critérios de aceite, evidência de
conclusão e navegação para arquivo/commit.

### F-103 — Changes
Garantir proposta, diff, confirmação, aplicação atômica, rollback e atualização
da UI.

### F-104 — Build/Rebuild/Stop
Validar Windows e Linux, saída incremental, diagnóstico, stop real e estado final.

### F-105 — Test execution
Integrar testes confiáveis do projeto ao fluxo Agent sem permitir comando arbitrário.

### F-106 — Terminal
Validar cwd do projeto, histórico, cancelamento, encoding e proteção contra uso
automático sem autorização.

### F-107 — Git
Manter leitura segura já existente e decidir se operações mutáveis serão
implementadas; qualquer escrita deve exigir confirmação.

### F-108 — Python
Consolidar execução no `TMNotePythonService` e retirar caminhos antigos duplicados.

## P2 — dívida de produto

### F-201 — MQuery2 modular
Separar conexão, metadados, execução, migração, importação e IA em serviços.

### F-202 — Folders/RIA/PIA
Reavaliar sobreposição com ProjectContext, índice de símbolos e ações modernas.

### F-203 — ImgJSON
Decidir entre módulo integrado, plugin opcional ou aplicação separada.

### F-204 — Voice
Unificar ToolsFalar/ToolsOuvir legados com os serviços modernos de voz.

### F-205 — internacionalização
Criar catálogo de strings e idioma padrão coerente.

### F-206 — remover eventos mortos
Eliminar handlers vazios sem função real após confirmar que não representam
comando visível.

## Ordem sugerida de execução

```text
F-001 Select All
F-004 LogView
F-005 Load SQL
F-007 Linguagens
F-008 Associação de extensão
F-002 Select Command
F-003 Select Block
F-006 Migration PostgreSQL
F-101 Agent E2E
F-102 Tasks
F-103 Changes
F-104 Build
F-105 Tests
F-106 Terminal
F-108 Python
```

## Definição de pronto

Uma tarefa funcional só é considerada concluída quando:

- código implementado;
- UI ligada;
- erro tratado;
- teste adicionado;
- documentação atualizada;
- não introduz caminho absoluto pessoal;
- CI relevante permanece verde.
