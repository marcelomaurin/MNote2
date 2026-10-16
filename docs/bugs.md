# Lista de bugs e verificações — MNote2

Atualizado em: 2026-10-16 | Branch: `main` | Referência: versão 2.68.

## Escopo e evidências

O backlog foi compilado a partir dos recursos descritos na documentação, não de uma execução de testes. A validação 2.68 registra build desktop, testes, smoke e instalador aprovados no ambiente de referência em 2026-08-01; isso não comprova individualmente os cenários deste backlog. Atualizar a situação de cada item somente com reprodução e evidência identificável.

## Critérios
Este documento é o ponto central de triagem de problemas. **Não confundir hipótese de falha com bug reproduzido.** Os itens abaixo são **verificações pendentes**, derivadas das funcionalidades declaradas no README e documentação. Não há falha de execução confirmada nesta revisão documental.

Status permitidos: `A validar`, `Confirmado`, `Em correção`, `Corrigido`, `Verificado`, `Não reproduzido`.
Prioridade: P0 bloqueante/segurança, P1 alta, P2 média, P3 baixa.

## Backlog inicial — cenários de regressão

| ID | Prioridade | Módulo | Cenário / possível defeito a verificar | Estado |
|---|---|---|---|---|
| MNOTE-001 | P1 | Editor | Abrir/salvar UTF-8 com acentos, emojis e arquivos grandes sem corromper conteúdo | A validar |
| MNOTE-002 | P1 | Editor | Fechar aba com alterações pendentes e testar Salvar/Descartar/Cancelar sem perda de dados | A validar |
| MNOTE-003 | P1 | Busca | Search/Replace regex em múltiplos arquivos: preview, backup e rollback coerentes | A validar |
| MNOTE-004 | P1 | IA / ChangeSource | Rejeitar proposta JSON inválida, hunk divergente e escrita fora do projeto; rollback após falha parcial | A validar |
| MNOTE-005 | P0 | Segurança IA | Garantir que texto livre gerado pela IA nunca vira comando de terminal ou gravação sem confirmação | A validar |
| MNOTE-006 | P1 | Multi-IA | Router, troca de provedor, timeout, cancelamento e limites não deixam interface travada | A validar |
| MNOTE-007 | P2 | Voz | “OK MNote” não dispara múltiplas requisições; saída falada só quando ativada por voz | A validar |
| MNOTE-008 | P1 | Configuração | Ausência/corrupção de `mnote.cfg`; nunca registrar credenciais em log ou versionar segredos | A validar |
| MNOTE-009 | P2 | UI | Persistência e restauração de painéis, abas, foco, dimensões e paleta de comandos | A validar |
| MNOTE-010 | P2 | Navegação | F12, referências e autocomplete após renomear/mover/excluir arquivos no projeto | A validar |
| MNOTE-011 | P1 | Banco de dados | Perda de conexão PostgreSQL/SQLite, SQL autocomplete e geração sem execução acidental | A validar |
| MNOTE-012 | P1 | Build/terminal | Processos longos, códigos de saída, erros e cancelamento adequados em Problems/Output | A validar |
| MNOTE-013 | P1 | Atualização neural-api | Validar integridade, origem, consentimento e comportamento sem rede/instalador | A validar |
| MNOTE-014 | P1 | Portabilidade | Compilar e executar smoke nas plataformas Windows/Linux suportadas; dependências Lazarus/FPC | A validar |
| MNOTE-015 | P1 | Instalador | Instalação, atualização e desinstalação sem apagar arquivos pessoais ou configurações | A validar |
| MNOTE-016 | P2 | Tarefas | Persistência e coerência entre Task List, Gantt, Timeline e Risk Matrix após reiniciar | A validar |

## Bugs confirmados

Nenhum nesta rodada: ainda não foram fornecidos passos de reprodução nem executados testes específicos para comprovar os itens acima. Ao confirmar uma falha, mover o item para esta seção, mantendo seu ID e registrando evidências.

| ID | Prioridade | Descrição | Reprodução | Evidência | Responsável | Estado |
|---|---|---|---|---|---|---|
| — | — | Sem confirmação até o momento | — | — | — | — |

## Ficha para registrar uma ocorrência

- **ID / título:**
- **Versão, commit, sistema operacional e arquitetura:**
- **Módulo afetado:**
- **Passos para reproduzir:** 1. … 2. … 3. …
- **Resultado observado:**
- **Resultado esperado:**
- **Frequência / impacto / prioridade:**
- **Log, captura, teste ou stack trace (sem credenciais):**
- **Arquivos/funções relacionados:**
- **Responsável / estado:**
- **Commit da correção:**
- **Validação da regressão:**

## Fluxo

1. Reproduzir em ambiente controlado e registrar evidência.
2. Separar defeito funcional, melhoria e documentação.
3. Corrigir com teste de regressão e revisão de impactos.
4. Executar os testes automatizados aplicáveis (`tests/run_tests.ps1`, `tests/run_smoke.ps1`, `tests/run_close_tab.ps1`) e, quando pertinente, smoke instalado.
5. Marcar `Verificado` apenas depois de conferir o comportamento corrigido.

Referências: [README principal](../README.md), [Matriz de capacidades](capability_matrix.md), [Testes e CI](ci.md), [Validação 2.68](release_validation_2_68.md).
