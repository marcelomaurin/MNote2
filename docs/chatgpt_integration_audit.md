# Auditoria da integração `TCHATGPT`

## Resolução ativa

O projeto resolve `TCHATGPT` pelos pacotes instalados do repositório CHATGPT.
Não há cópia local ativa de `chatgpt.pas`. As cópias em backup e arquivos de
inventário não pertencem ao path de compilação.

## Ownership centralizado

`TMNoteAIService` é o único owner funcional dos clientes, registry, perfis,
router, barramento, sessões e executor. Forms solicitam operações ao service e
não instanciam clientes ocultos. Cada perfil possui papel, estado, orçamento e
limites próprios.

As criações diretas antigas em `main.pas`, `folders.pas`, `ia.pas`,
`config.pas` e `mquery2.pas` foram migradas. `TAntigravity` foi retirado do
projeto ativo; sua fonte histórica foi preservada em
`docs/historico/antigravity.pas.txt` para auditoria.

## Pacotes core

O MNote2 requer `openai_project_core`, `openai_agentcore`, `openai_graphcore` e
`openai_aidbase` para contratos leves. Os agregadores continuam
retrocompatíveis no CHATGPT, mas não entram no núcleo da IDE por conveniência.
O build limpo dos nove pacotes afetados e quatro samples está registrado em
`docs/package_regression.md`.

## Configuração e segredos

Tokens permanecem exclusivamente na configuração local `mnote.cfg`. Arquivos de
projeto, perfis multi-IA, mapas de sessão, logs, relatórios e contratos não
persistem token, senha ou prompt completo.
