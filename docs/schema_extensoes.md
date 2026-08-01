# Extensões compatíveis do schema de projeto

O MNote2 usa o schema serializável de `openai_project_core`. A versão de arquivo
gravada nesta entrega é `1.1`. As extensões são aditivas: leitores antigos
continuam encontrando os campos históricos e preservam campos desconhecidos no
round-trip.

## Estruturas da raiz

- `project`: identificação, descrição, objetivo e raiz relativa do projeto;
- `tasks`: tarefas com os 21 campos históricos e as extensões descritas abaixo;
- `agile_documents`: `risk_map` e documentos ágeis opcionais;
- `planning`: `gantt` e `timeline` opcionais;
- `agents`: configuração funcional sem tokens ou senhas;
- `task_actions`: histórico imutável de transições;
- `agent_task_analysis`: resultados de análise ligados à tarefa;
- `revisions`: revisões preservadas dos planos gerados.

## Extensões de tarefa

`long_description`, `files_affected`, `must_not_do`, `commits`,
`exclusive_files` e `origin` complementam os campos históricos. As listas são
sempre arrays JSON, mesmo quando vazias. `exclusive_files` é usado pela política
de concorrência para impedir tarefas paralelas sobre o mesmo arquivo.

## Regras de compatibilidade

1. Campos existentes não mudam de tipo nem de significado.
2. Campos desconhecidos são preservados ao abrir e salvar.
3. Ausência de uma extensão é normalizada para objeto, array ou valor vazio.
4. Caminhos persistidos são relativos à raiz sempre que possível.
5. Credenciais e prompts completos nunca pertencem ao arquivo do projeto.

Os testes `TestProjectCore` e `TestAIPlanContract` provam abertura, alteração,
validação e gravação sem perda, incluindo um campo legado desconhecido.
