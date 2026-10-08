# Plano de implementação — diagramas de banco no MQuery

Última atualização: 2026-10-08.
Estado: segunda etapa implementada: leitura assíncrona, cancelamento, foco por tabela e persistência de filtros; validação dos quatro servidores aguarda conexões de teste.
Responsável pela execução: Codex, com acompanhamento do usuário.

## Objetivo e requisitos do usuário

Implementar no MQuery uma ferramenta visual de tabelas e relacionamentos,
inspirada nas imagens de referência de diagramas de banco e modelagem.
O recurso deve estar disponível em cada pasta/nó de banco, mantendo o contexto
da conexão, catálogo e schema daquela pasta.

O MQuery atende Oracle, PostgreSQL, SQL Server, MySQL e outros bancos.
A implementação não pode ser considerada concluída atendendo apenas
PostgreSQL e SQLite. A existência de um adaptador de dicionário mais pronto
para esses dois bancos é uma facilidade técnica, não uma redução de escopo.

Neste plano, “pasta de banco” significa o nó de banco na árvore do MQuery
e sua representação no Solution Explorer. Não se presume uma pasta física
do Windows. Se houver também vínculo com diretórios de projeto, preservar
esse vínculo sem usar o caminho como única identidade do banco.

## Base examinada

- src/mquery2/mquery2.pas: formulário com conexões, exploração e geração de SQL;
  miRelacionamentosClick atualmente gera dependências em texto.
- GetActiveDatabaseTree, na mesma unit: exporta tabelas de SQLite, PostgreSQL
  e MySQL; o fluxo examinado não contempla Oracle e SQL Server e contém
  fallback para outra conexão conectada.
- src/services/mnote_db_dictionary_service.pas: serviço de dicionário;
  AttachConnection instancia atualmente apenas PostgreSQL e SQLite.
  O estado experimental dos demais engines nesse serviço não significa
  ausência de suporte desses bancos no restante do MQuery.
- src/ui/mnote_db_dictionary_panel.pas: árvore e detalhes textuais.
- src/ui/mnote_solution_explorer_panel.pas: mantém um nome de banco e uma lista
  de tabelas; precisa evoluir para contextos independentes por nó de banco.
- src/main.pas: GenerateDataDictionary prioriza PostgreSQL conectado;
  SyncSolutionDatabaseFromMQuery e RefreshSolutionDatabase integram a árvore.
- Dependência CHATGPT/pacote/AI DBase: aidb_types e leitores de metadados.
  O modelo de FK precisa preservar schemas e ordem das colunas compostas.
- TAIGraphVisualizer examinado na dependência AI Graph exporta grafos;
  não constitui, por si só, um editor visual de tabelas.

O levantamento inicial foi estático. A primeira implementação foi compilada e
validada com SQLite em memória; evidências detalhadas ao final deste documento. Há alterações locais preexistentes no repositório,
que devem ser preservadas.

## Comportamento planejado em cada pasta de banco

1. Oferecer “Abrir diagrama” no menu contextual do nó de banco.
2. Oferecer abertura filtrada no nó de schema e, para tabelas,
   “Mostrar no diagrama” e inclusão de tabelas relacionadas.
3. Resolver a conexão pelo contexto do nó clicado; nunca escolher outro banco
   porque está conectado ou porque sua aba está ativa.
4. Exibir conexão, engine, catálogo e schema no título/contexto do diagrama.
5. Manter diagramas independentes por banco, permitindo alternar entre eles
   sem misturar tabelas, relacionamentos, filtros e posições.
6. Salvar posições, seleção de tabelas, zoom e filtros por identidade estável
   da conexão/banco. Bancos homônimos em servidores diferentes são distintos.
7. Ao desconectar, indicar que o conteúdo é um snapshot; atualizar somente
   após reconectar o contexto correto, sem fallback para outra conexão.
8. Preservar o vínculo com a pasta de banco ao atualizar a árvore.

A identidade deve considerar perfil de conexão, engine, servidor/instância,
porta quando aplicável, catálogo/database e schema/owner. Para SQLite,
considerar o arquivo resolvido. Senhas não integram o arquivo do diagrama.

## Escopo funcional

### Primeira entrega funcional: engenharia reversa e navegação

- Caixas de tabelas com nome qualificado, colunas, tipos, nulabilidade e PK/FK.
- Ligações entre as colunas de origem e destino das FKs.
- Chaves compostas agrupadas por restrição e com pares de colunas ordenados.
- Autorrelacionamentos, múltiplas FKs entre tabelas e relações entre schemas.
- Arrastar tabelas, selecionar, zoom, deslocamento e ajustar à área visível.
- Filtro por schema/tabela, busca e organização automática inicial.
- Atualização dos metadados preservando posições dos objetos existentes.
- Persistência versionada do layout e exportação de imagem.
- Estado de carregamento, cancelamento e mensagens de erro por contexto.
- Leitura de metadados sem executar alterações de estrutura.
- Cardinalidades somente quando sustentadas pelas restrições conhecidas;
  não deduzir relações apenas por semelhança de nomes.
- Funcionar sem IA ou serviços externos de geração de conteúdo.

### Evolução posterior, separada da primeira entrega

Edição visual de tabelas e relacionamentos, comparação modelo/banco,
geração de DDL por dialeto e aplicação revisada de alterações.
Views, índices, triggers, procedures, notas e minimapa podem ampliar a
visualização após o núcleo. Dependências de views/procedures não devem
ser apresentadas como FKs.

A primeira entrega não será descrita como modelador completo nem como
sincronização bidirecional. O escopo dessa evolução será detalhado antes
da implementação correspondente.

## Cobertura de bancos

| Engine | Trabalho previsto | Validação da feature |
| --- | --- | --- |
| Oracle | Menu por pasta e leitor Zeos implementados | Compila; servidor real pendente |
| PostgreSQL | Menu por pasta e leitor Zeos implementados | Compila; servidor real pendente |
| SQL Server | Menu por pasta e leitor Zeos implementados | Compila; servidor real pendente |
| MySQL | Menu por pasta e leitor Zeos implementados | Compila; servidor real pendente |
| SQLite | Leitor dedicado de sqlite_master e PRAGMAs | Testado com banco SQLite em memória; schema main |
| MariaDB, Firebird e demais protocolos | Nenhuma árvore própria encontrada no MQuery atual; dependem de exposição de conexão e validação | Não declarados como suportados pela feature |

A ordem interna de desenvolvimento pode começar por um adaptador existente
para validar a interface. Isso não exclui Oracle, SQL Server e MySQL.
Cada engine terá evidência própria; ausência de ambiente de teste será
registrada como não validado, nunca como suporte confirmado.

## Arquitetura proposta

Fluxo: contexto da pasta → provedor de metadados → modelo normalizado →
painel visual → persistência/exportação.

Separar o novo código do formulário extenso mquery2.pas:

- Contexto de banco: identidade e resolução da conexão do nó selecionado.
- Provedores por engine: coleta de metadados com capacidades declaradas.
- Modelo: tabelas, colunas, restrições, pares ordenados e nomes qualificados.
- Serviço: carregamento, snapshot, atualização e tratamento de falhas.
- Painel Lazarus/LCL: desenho, seleção, movimentação e navegação.
- Persistência: formato versionado, layout por banco e restauração.

Os nomes finais de units serão definidos durante a implementação.
Reutilizar o dicionário quando adequado; qualquer extensão da dependência
CHATGPT deverá manter compatibilidade com seus consumidores.
Consultas do diagrama não devem sobrescrever SQL ou resultados do usuário.
Coleta demorada deve preservar a responsividade; se houver execução em
segundo plano, usar conexão apropriada ao worker, sem compartilhar componentes
visuais ou consultas ativas entre threads.

## Etapas e checklist de acompanhamento

Estados: [ ] pendente; [x] concluído. Trabalho em andamento deve ser
descrito na tabela de situação abaixo, sem marcar conclusão antecipadamente.

### E0 — levantamento e contrato
- [x] Avaliar código do MQuery, dicionário e integração com a árvore.
- [x] Registrar abrangência multibanco e uso por pasta de banco.
- [x] Criar este plano e adicioná-lo ao índice de docs.
- [x] Inventariar todos os protocolos e pastas de banco efetivamente disponíveis.
- [x] Definir contrato de contexto e identidade estável por nó.
- [ ] Definir fixtures e ambientes de validação por engine.

### E1 — contexto e metadados
- [x] Remover ambiguidade de conexão no fluxo específico do diagrama.
- [x] Evoluir integração da árvore para preservar contextos independentes.
- [x] Implementar modelo normalizado, com schemas e chaves compostas.
- [ ] Integrar e validar provedor PostgreSQL.
- [x] Integrar e validar provedor SQLite.
- [ ] Integrar e validar provedor Oracle.
- [ ] Integrar e validar provedor SQL Server.
- [ ] Integrar e validar provedor MySQL.
- [x] Registrar cobertura e limitações dos demais engines inventariados.

### E2 — interface e integração por pasta
- [x] Implementar painel de tabelas e ligações por coluna.
- [x] Implementar seleção, arraste, zoom e deslocamento.
- [x] Implementar busca, filtros e organização inicial.
- [x] Adicionar ações contextuais nas árvores do MQuery e Solution Explorer.
- [x] Manter diagramas separados e título identificando o banco.
- [x] Tratar progresso, cancelamento, desconexão e erro de permissão.

### E3 — persistência e exportação
- [x] Salvar e restaurar layout por banco sem credenciais.
- [x] Versionar o formato e tratar arquivo inválido.
- [x] Preservar layout na atualização, tratando objetos removidos/renomeados.
- [x] Implementar e verificar exportação de imagem.

### E4 — validação e entrega
- [ ] Testar FKs simples, compostas, autorreferentes e múltiplas.
- [ ] Testar tabelas homônimas em schemas e servidores diferentes.
- [ ] Testar duas conexões simultâneas e abertura pela pasta não ativa.
- [ ] Testar desconectar/reconectar sem mudar de contexto.
- [ ] Testar banco sem FK, metadados incompletos e permissões limitadas.
- [x] Testar salvar/reabrir e atualizar sem perder o layout.
- [x] Avaliar desempenho com dezenas e centenas de tabelas.
- [x] Executar build e testes pertinentes sem sobrescrever trabalho preexistente.
- [ ] Registrar resultados reais por engine e plataforma testada.
- [x] Atualizar manual do usuário e matriz de capacidades.

## Critérios de aceite

- Abrir o diagrama pela pasta de um banco sempre usa aquele banco,
  inclusive quando outro banco estiver conectado ou selecionado.
- Oracle, PostgreSQL, SQL Server, MySQL e SQLite possuem caminho funcional
  verificado, ou uma pendência explícita que impede declarar o escopo concluído.
- Cada banco mantém seu próprio diagrama; nomes iguais não causam colisão.
- Ligações refletem restrições reais e preservam pares de chaves compostas.
- Atualização e restauração de layout não misturam contextos.
- A primeira entrega não modifica a estrutura dos bancos.
- Limitações dos demais engines ficam visíveis e documentadas.

## Situação atual e continuidade

| Etapa | Situação | Evidência / próximo passo |
| --- | --- | --- |
| E0 | Em andamento | Cinco árvores inventariadas e identidade definida; faltam ambientes dos quatro servidores |
| E1 | Em andamento | Modelo e contexto implementados; SQLite testado, demais leitores Zeos aguardam servidor real |
| E2 | Implementado; validação externa pendente | Leitura assíncrona, progresso, cancelamento cooperativo, foco por tabela e relações diretas |
| E3 | Implementado | Layout v2 preserva filtros/foco/zoom; atualização e renomeação testadas, objetos novos recebem novas posições |
| E4 | Em andamento | Build, 66 verificações específicas e suíte geral passaram; 4 servidores sem configuração de teste |

Próxima ação: obter os perfis de teste e executar o validador em Oracle, PostgreSQL,
SQL Server e MySQL. A pergunta sobre esses ambientes foi enviada ao usuário.
Não declarar suporte validado com base apenas no build ou em resultados SKIP.

Ao retomar o trabalho, ler este documento e consultar o estado real do Git.
Ao concluir cada etapa, atualizar checklist, situação, arquivos alterados,
testes executados, limitações e próxima ação. Não marcar testes planejados
como executados. Não depender apenas do histórico da conversa.

## Histórico

| Data | Alteração | Verificação |
| --- | --- | --- |
| 2026-10-08 | Segunda etapa: leitura assíncrona, cancelamento, foco, layout v2 e organização por relações | Build e suíte geral passaram; 66 verificações; 4 servidores SKIP |
| 2026-10-08 | Primeira implementação: diagrama por pasta, múltiplos bancos na árvore, layout e PNG | Build passou; 38 testes específicos; servidores e suíte geral pendentes |
| 2026-10-08 | Avaliação inicial; plano registrado com requisito multibanco e acesso por pasta | Leitura estática; sem build, conexão real ou implementação da feature |


## Primeira implementação — 2026-10-08 (histórico; limitações superadas abaixo)

### Arquivos e decisões

- src/services/mnote_db_diagram_model.pas: contexto sem senha, identidade com
  campos delimitados por comprimento, nomes qualificados, pares ordenados de FK.
- src/services/mnote_db_diagram_reader.pas: leitura pela conexão explícita;
  Zeos GetTables/GetColumns/GetPrimaryKeys/GetImportedKeys para servidores;
  SQLite usa leitura própria porque o driver instalado não fornece imported keys.
  A adoção desse leitor evita depender do dicionário limitado a duas engines.
- src/services/mnote_db_diagram_layout.pas: JSON versão 1, validação de contexto,
  posições e zoom antes de aplicar o layout.
- src/ui/mnote_db_diagram_form.pas: janela por contexto, tabelas/colunas/PK/FK,
  arraste pelo cabeçalho, barras de navegação, zoom, ajustar à janela, filtro textual,
  organização em grade, salvar posições e exportar PNG.
- src/mquery2/mquery2.pas: menus vinculados às cinco conexões, sem fallback
  pela aba ativa; atualização da árvore informa o Solution Explorer.
- src/ui/mnote_solution_explorer_panel.pas e src/main.pas: múltiplos bancos
  na árvore, cada nó com seu identificador; comandos recusam contexto desconectado
  ou alterado. A API legada SetDatabase continua disponível.
- tests/db_diagram_test.lpr e tests/run_db_diagram_tests.ps1: testes reproduzíveis.

O menu atual abre o banco inteiro, inclusive quando acionado em uma tabela.
O filtro textual já permite restringir o desenho a nomes de schema/tabela.
O carregamento ainda é síncrono; cancelamento/worker não foram concluídos.
Referências para tabelas fora do escopo geram aviso e não são desenhadas.
FKs sem identificador no leitor genérico são omitidas com aviso para evitar
fundir restrições distintas. SQLite identifica a restrição pelo id do PRAGMA.
O desenho inicial não representa cardinalidades nem edita o schema do banco.
SQLite anexados/temporários ainda não entram no diagrama; a leitura cobre main.
O layout salva posições e zoom por banco; filtros ainda não são persistidos.

### Verificações executadas

- Build Lazarus/Win32/i386: código de saída 0, executável gerado em diretório
  isolado para não sobrescrever o executável anterior durante a validação.
  Última compilação: 21.466 linhas, 223 warnings, 516 hints e 35 notes;
  os avisos do projeto não foram tratados como aprovação de comportamento.
- tests/run_db_diagram_tests.ps1: PASS, 38 verificações. Banco SQLite real
  em memória: tabelas, PK, FKs compostas, referência implícita à PK,
  autorrelacionamento e múltiplas FKs entre tabelas; consulta do usuário preservada.
- Contextos: diferenciação de servidor/schema, conexão alterada/desconectada
  recusada; dois nós independentes e acionamento dos menus de banco/tabelas
  verificados por eventos na árvore. Não equivale a dois servidores reais testados.
- Layout: ida e volta de posições/zoom; contexto incorreto e coordenada inválida
  recusados sem alterar posições existentes; arquivo sem campo de senha.
- PNG: exportado pelo mesmo desenhador do painel e inspecionado visualmente.
- Suíte geral tests/run_tests.ps1: não completou. O compilador tentou recompilar
  aispeechrecognizer por alteração de checksum de aiaudio e não localizou seu
  fonte no caminho do script. Não registrar a regressão geral como aprovada.
- Oracle, PostgreSQL, SQL Server e MySQL: sem conexões reais nesta sessão.

### Como retomar

1. Ler este plano e verificar git status; preservar alterações alheias.
2. Executar tests/run_db_diagram_tests.ps1 para a base específica.
3. Trabalhar nas pendências E1–E4 e atualizar esta seção com resultados reais.
4. Resolver a configuração de dependências da suíte geral antes de declarar
   validação integral. Não instalar componentes ou alterar a biblioteca de voz
   como efeito colateral da feature.

### Executável disponibilizado

Após o build isolado, src/MNote2.exe foi atualizado com a versão compilada.
SHA-256: 1119EA047998A1C9898EF966BB6A99E88740BDE9859B4C13DED2091C83EBE161.
Backup do executável anterior: C:\Users\mmaurin\Documents\Codex\2026-10-08\d-projetos-maurinsoft-mnote2\work\backups\MNote2-antes-diagrama.exe.
Nenhum instalador foi gerado nesta etapa.

## Segunda etapa — 2026-10-08

### Entregue

- mnote_db_diagram_job.pas: conexão independente criada/destruída na thread;
  parâmetros capturados na interface sem compartilhar TZQuery/TZConnection.
  Senha fica apenas na memória da operação e é removida de mensagens de erro.
- Progresso consultado por timer. O worker não tem referências ao formulário,
  não usa Synchronize e não publica callbacks em objetos já destruídos.
- Cancelar preserva o snapshot e descarta o resultado parcial. Fechar a janela
  cancela sem esperar o driver. O cancelamento é cooperativo: uma chamada nativa
  já em andamento precisa retornar; ele não promete interromper login/SQL remoto.
- Mudança ou desconexão do contexto original faz a interface descartar a leitura.
- Menu por tabela transmite nome e contexto, mostrando a tabela e relações
  diretas; “Todas” remove o foco. Oracle e SQL Server também têm o menu na tabela.
- Layout JSON v2 guarda filtro, foco, zoom e posições, e lê arquivos v1.
  Atualização preserva objetos existentes; removidos desaparecem e renomeados
  são tratados como objetos novos, sem inferência perigosa por semelhança de nomes.
- Organização agrupa tabelas relacionadas; acima de 30 tabelas usa seis colunas.
  Linhas usam cores e setas em direção à coluna referenciada, com rotas ajustadas
  para tabelas à esquerda ou à direita. Não representa cardinalidade inferida.
- tests/run_tests.ps1 inclui o diretório AI Voice existente para resolver
  aispeechrecognizer. Nenhum pacote ou componente externo foi instalado/modificado.

### Evidências atuais

- tests/run_db_diagram_tests.ps1: 66 verificações aprovadas.
- Testes usam arquivo SQLite temporário criado pela suíte (a versão anterior
  usava apenas banco em memória). Leitura assíncrona preserva consulta original;
  conexão de trabalho continua independente da conexão de origem.
- Cancelamento entre tabelas, descarte de resultado e fechamento durante leitura
  foram verificados. A janela não aguarda o término do worker ao fechar.
- Teste com 303 tabelas e 303 relacionamentos: última execução em 656 ms,
  com variação observada de aproximadamente 0,65 a 1,05 segundo nesta máquina.
  Esse número cobre leitura/modelo/organização, não comprova tempo de renderização
  de bancos remotos nem garante desempenho em qualquer ambiente.
- Foco por tabela, relações diretas, persistência de filtro/foco e atualização
  após renomeação testados. PNG gerado e inspecionado visualmente.
- tests/run_tests.ps1: código de saída 0, incluindo test_runner e ssl_loader_test.
- Build final Lazarus/Win32/i386: saída 0. Compilação incremental final:
  688 linhas, 7 warnings e 52 hints; executável testado antes da substituição.
- db_diagram_server_test: compilou; POSTGRES, MYSQL, MSSQL e ORACLE retornaram
  SKIP por ausência de configuração. Resultado: 0 aprovados, 0 falhas, 4 pulados;
  código de saída 2. Isso não é aprovação multibanco.
- Inventário local encontrou serviços Oracle XE parados, nenhum serviço em execução
  dos outros três bancos, cliente sqlcmd disponível e nenhuma variável de teste
  MQUERY configurada. Serviços não foram iniciados nem bancos criados para inferir
  um ambiente de testes. Aguardam-se os perfis indicados pelo usuário.

### Limitações remanescentes

- Validar os quatro servidores, inclusive PK/FK compostas, schemas homônimos,
  nomes especiais, permissões limitadas e relações entre schemas.
- A conexão isolada vê metadados persistidos/confirmados. SQLite :memory: é
  recusado explicitamente na interface assíncrona para não abrir outro banco vazio;
  o leitor síncrono continua disponível para testes e consumidores apropriados.
- SQLite anexados e objetos temporários de sessão ainda não são transportados para
  a conexão isolada; a leitura visual atual cobre main de um arquivo persistido.
- MariaDB/Firebird ainda precisam de exposição de conexões e validação na interface.
- Edição de schema, DDL e sincronização seguem como evolução posterior.

O procedimento reproduzível de validação externa está em
[validacao_diagrama_multibanco.md](validacao_diagrama_multibanco.md).

### Executável da segunda etapa

src/MNote2.exe atualizado após a compilação final. SHA-256: 216B58199C6F96AA881C81B17FB6D7C66B8BC5E464101BE9DDE6014DA9938196.
Backup anterior: C:\Users\mmaurin\Documents\Codex\2026-10-08\d-projetos-maurinsoft-mnote2\work\backups\MNote2-antes-assincrono.exe.
