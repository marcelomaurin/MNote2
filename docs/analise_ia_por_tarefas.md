# Orquestração de análises por tarefas — MNote2

## Visão geral
Menu principal **Análise IA por tarefas...**. A análise é subdividida em tarefas persistidas, dependentes e revisáveis, em vez de enviar uma solicitação única ao modelo.

## Arquitetura inicial
- `src/services/mnote_ai_task_orchestrator.pas` — plano determinístico, dependências, controle de estados e persistência em `.mnote/ai_tasks.json` dentro da raiz do projeto.
- `src/ui/mnote_ai_tasks_form.pas` — janela do plano, seleção de etapas e resultados.
- `src/main.pas` — ponto de entrada pelo menu principal.
- `TMNoteAIService.ExecuteToolRequest` — execução de **uma tarefa por vez**, com ferramentas de leitura do projeto. Não há aplicação de correções nem execução de SQL automática.

## Plano criado
1. Inventário do projeto
2. Análise de código (depende de inventário)
3. Análise SQL opcional (depende de inventário)
4. Revisão técnica por IA (depende de código)
5. Relatório consolidado (depende de IA e SQL, quando incluído)

As tarefas exibem estado pendente, executando, concluída, falhou ou bloqueada, com evidências e erro. Reabertura recupera o plano; tarefa que estava em execução retorna a pendente.

## Limitações e segurança
- A orquestração é sequencial e manual (botão **Executar próxima tarefa**), para evitar concorrência insegura com a instância compartilhada de IA.
- Não há agendamento autônomo, execução em segundo plano nem paralelismo nessa versão.
- A integração dos menus File e SQL antigos ainda deve ser migrada para apontar ao mesmo serviço. O novo menu já permite incluir tarefa SQL.
- A etapa SQL não presume acesso a esquemas remotos: utiliza somente informações e ferramentas existentes no contexto do projeto.
- Há leitura por ferramentas do executor com limitação somente-leitura. Trate respostas de IA como hipóteses e confirme achados com build e testes reais.
- Por enquanto, nenhuma alteração é aplicada automaticamente. Correções devem continuar no fluxo existente de revisão e confirmação.
- A UI aguarda a resposta de cada execução síncrona e pode ficar temporariamente sem responder. Recomenda-se migrar para worker assíncrono com cancelamento em uma próxima fase.
- É necessária compilação e validação E2E no Lazarus antes de release.

## Testes recomendados
1. Abrir projeto e criar plano com ou sem SQL.
2. Executar primeiro inventário e verificar desbloqueio das dependências.
3. Fechar/reabrir janela e verificar persistência.
4. Simular falha na IA e verificar estado e erro preservados.
5. Confirmar que solicitações de escrita/compilação não são executadas pelo planejador.
