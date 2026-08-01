# Auditoria do ChangeSource

## Decisão

O fluxo ativo usa `TAISourceChangeManager` e o contrato
`TMNoteAIChangeContract`. O formulário legado não atua como um segundo motor de
escrita: ele é somente uma entrada de compatibilidade para o painel Changes.

## Garantias do caminho ativo

1. A IA envia JSON puro e validado; texto livre nunca vira ação.
2. Caminho, extensão, tamanho, conteúdo esperado e hash são verificados.
3. O diff unificado é reconstruível, possui fallback explícito e seleção real
   por arquivo ou hunk.
4. Nada é escrito antes da aprovação explícita.
5. A gravação usa arquivo temporário e substituição atômica.
6. Backup e histórico são ligados ao identificador do change set.
7. Rollback recusa sobrescrever alteração manual posterior.
8. A validação de build após Apply pode oferecer rollback sem marcar a tarefa
   como concluída.

O runner cobre inserção, remoção, substituição, arquivo novo, múltiplos hunks,
seleção parcial, falha após temporário, divergência de hash e rollback.
