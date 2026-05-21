# MNote2

MNote2 e um editor de texto e codigo multiplataforma desenvolvido em Lazarus/Free Pascal. A aplicacao combina editor com abas, execucao de scripts, gerenciador de bancos de dados, integracao com IA, leitura de documentos e ferramentas auxiliares de voz.

Versao atual do fonte: **2.56**.

## Screenshots

### Editor integrado
![Editor](screenshots/Editor%20com%20IA%20integrada.jpg)

### Gerenciamento de arquivos
![Gestao de Arquivos](screenshots/Gest%C3%A3o%20de%20Arquivos.jpg)

### Inteligencia Artificial
![Uso da IA](screenshots/IA.jpg)

### Gerenciador de Banco de Dados
![Banco de dados](screenshots/MQUERY.jpg)

## Funcionalidades Principais

### Editor e arquivos

- Editor multiabas baseado em SynEdit.
- Realce e apoio a edicao para Pascal, Python, Java, SQL, PHP, C e outros tipos configurados por listas auxiliares.
- Busca, substituicao, copiar/colar, desfazer/refazer, selecao de blocos e configuracao de fonte.
- Carregamento e salvamento de arquivos em abas independentes.
- Extracao de texto de PDF, DOC e DOCX:
  - PDF via parser interno em src/uPdfText.pas.
  - DOCX via leitura de word/document.xml.
  - DOC via automacao OLE no Windows com Word instalado.
- Historico de conversa por arquivo usando arquivos .RIA associados.
- Integracao com organizacao de pastas e projetos.

### Projetos, pastas e analise IA

- Varredura de pastas com analise de arquivos fonte e documentos.
- Gera resumos tecnicos por arquivo em cache .RIA.
- Gera analises orientadas a pergunta em cache .PIA.
- Remove cache .RIA quando o arquivo fonte foi alterado depois do resumo.
- Gera mapa mental textual para consolidar pontos relevantes de uma pergunta.
- Ignora automaticamente arquivos de cache .RIA e .PIA durante novas analises.
- Suporte a leitura de extensoes como .pas, .pp, .lfm, .lpr, .ini, .json, .yml, .yaml, .php, .htm, .html, .js, .xml, .c, .cpp, .txt, .doc, .docx, .pdf, .sql, .jsp, .py, .cob e .md.

### Inteligencia Artificial

- Cliente de IA encapsulado em TCHATGPT, versao interna 1.5.
- Providers suportados: OpenAI, OpenRouter, Cerebras e Local/llama.cpp compativel com API /v1/chat/completions.
- Modelos previstos no codigo: gpt-3.5-turbo, gpt-4, gpt-4-turbo-preview, gpt-4o, gpt-o3-mini, gpt-4.1, gpt-4.1-mini e gpt-5.
- Modelos locais/Ollama previstos, incluindo llama3.2:3b, Qwen e DeepSeek.
- Suporte a modelo customizado quando configurado.
- Configuracao de endpoint local por IPLocalIA.
- Historico, mapa de memoria e pensamento persistidos em arquivos .RIA.
- Classificacao de continuidade da conversa.
- Preparacao de contexto a partir de historico, mapa de memoria, projeto, banco de dados e arquivos analisados.
- Acoes assistidas pela IA, incluindo geracao de consultas SQL e criacao de estruturas de tabela.

### Python e automacao

- Execucao de codigo Python aberto no editor usando PythonEngine.
- Uso configuravel do caminho da DLL Python.
- Saida de execucao direcionada para a area de resultados.
- Inspecao de variaveis globais e locais apos a execucao.
- Execucao de scripts externos configuraveis para run, debug, clean, install e compile.
- Amostras em sample/python, sample/gcc e scripts auxiliares em src.

### Banco de dados e MQuery2

O modulo MQuery2 funciona como gerenciador SQL integrado.

- Conexao com MySQL, PostgreSQL e SQLite usando Zeos.
- Configuracao de bibliotecas DLL/SO para MySQL, PostgreSQL e SQLite.
- Navegacao por arvores de banco, tabelas, campos, views, procedures, functions, triggers e sequences conforme o banco conectado.
- Execucao de SQL livre por editor integrado.
- Geracao de SQL a partir de tabelas selecionadas.
- Criacao de tabela a partir de dataset CSV.
- Criacao de usuario no PostgreSQL.
- Geracao de dicionario de dados para PostgreSQL e SQLite.
- Geracao de lista de dependencias/foreign keys para SQLite e PostgreSQL.
- Integracao com IA para analisar SQL, sugerir melhorias, embelezar consultas e responder perguntas com base em DDL/dependencias.
- Classe TSQLiteDb para conexao SQLite, transacoes, pragmas recomendados, execucao parametrizada e consultas utilitarias.
- Classe TProjetoDB para abrir projeto SQLite, verificar tabelas e carregar metadados/configuracoes.

### Ferramentas de voz

- ToolsFalar envia texto por TCP para um servico de sintese de voz, como srvFalar.
- ToolsOuvir conecta por TCP para receber comandos/mensagens externas.
- Ativacao automatica opcional ao iniciar, conforme configuracao.
- Configuracao de IP e porta pela interface.

### Instalacao e distribuicao

- Instalador Windows por Inno Setup em instalador/MNote2.iss.
- Versao do instalador Windows: 2.56.
- Copia MNote2.exe, DLLs, arquivos .dci, listas .txt, scripts .bat, amostras e banco padrao.
- Copia o banco padrao para C:\db.
- Inclui opcao pos-instalacao para iniciar srvFalar_1.4.exe.
- Pacotes e binarios historicos ficam em bin.
- Script buildlinux.sh mantem fluxo de empacotamento Linux/deb.

## Estrutura do Projeto

- src/MNote2.lpr: ponto de entrada da aplicacao Lazarus.
- src/main.pas: formulario principal, abas, editor, carga/salvamento, chat, historico, ferramentas e integracao geral.
- src/classes/item.pas: encapsula cada aba/item editavel, execucao Python e execucao de scripts configurados.
- src/classes/chatgpt.pas: cliente HTTP para providers de IA.
- src/setmain.pas: configuracao global e persistencia em mnote.cfg.
- src/config.pas: formulario de configuracao de scripts, DLLs, IA, bancos e ferramentas TCP.
- src/folders.pas: gerenciamento de pastas, analise de arquivos, caches .RIA/.PIA e analise de projeto por IA.
- src/ia.pas: interface de IA com historico, mapa de memoria, pensamento, continuidade e acoes.
- src/mquery2/mquery2.pas: gerenciador de bancos e SQL.
- src/sqlite_db.pas: wrapper SQLite.
- src/uprojetodb.pas: carregamento de projeto SQLite e metadados.
- src/uPdfText.pas: extracao nativa simples de texto de PDF.
- src/uDocText.pas: extracao de texto de DOC/DOCX.
- src/toolsfalar e src/toolsouvir: ferramentas TCP de fala e escuta.
- db/projeto_padrao.db: banco padrao do projeto.
- screenshots: imagens usadas no README.
- instalador: scripts de empacotamento Windows.
- sample: exemplos de Python, C e processamento de imagem.
- libs, sqlite e tools: bibliotecas e utilitarios externos distribuidos com o projeto.

## Requisitos

### Desenvolvimento

- Lazarus IDE e Free Pascal Compiler.
- Pacotes Lazarus usados pelo projeto, incluindo LCL, SynEdit, TAChart, Indy, Zeos, RX, Python4Lazarus, lNet e componentes adicionais listados em src/MNote2.lpi.
- Bibliotecas de banco conforme o uso: SQLite, MySQL client e PostgreSQL/libpq/ODBC conforme configuracao.
- Python 3 compativel com a DLL configurada quando a execucao Python estiver habilitada.
- Inno Setup para gerar o instalador Windows.

### Uso

- Windows e Linux sao os alvos principais presentes no projeto.
- DOC classico (.doc) exige Windows com Microsoft Word instalado.
- Funcionalidades de IA exigem token/provider configurado ou servidor local compativel.
- Ferramentas de fala/escuta exigem servico TCP correspondente ativo.

## Configuracao

A configuracao principal fica em mnote.cfg, gerenciada por TSetMain. Ela inclui:

- Posicao/tamanho da janela e fonte.
- Ultimos arquivos.
- Scripts de run/debug/clean/install/compile.
- Token de IA e provider.
- Endpoint de IA local.
- Caminhos de DLLs de Python, MySQL e PostgreSQL.
- Dados de conexao MySQL, PostgreSQL e SQLite.
- Ativacao e IPs das ferramentas ToolsFalar e ToolsOuvir.
- Pasta padrao e projeto atual.

Observacao: mnote.cfg pode conter token de IA e senhas de banco. Proteja esse arquivo no ambiente local.

## Uso Basico

1. Abra o MNote2.
2. Configure caminhos de DLLs, scripts, bancos e IA em Configuracoes.
3. Abra ou crie arquivos nas abas do editor.
4. Use o menu de linguagem para selecionar o tipo de arquivo/codigo.
5. Execute Python diretamente ou scripts externos configurados.
6. Abra o MQuery2 para conectar em MySQL, PostgreSQL ou SQLite.
7. Use a tela de IA para perguntas com historico, mapa de memoria e analise de projeto.
8. Use o gerenciador de pastas para gerar resumos .RIA e analises .PIA.
9. Ative ToolsFalar/ToolsOuvir quando precisar de integracao TCP de voz.

## Observacoes de Manutencao

- O codigo atual concentra bastante logica em main.pas, folders.pas, ia.pas e mquery2.pas.
- O repositorio contem binarios, pacotes e bibliotecas externas versionadas porque o projeto distribui artefatos junto com o fonte.
- Arquivos .RIA e .PIA sao usados como cache/resultado de IA e podem ser regenerados pela aplicacao.
- src/lib contem artefatos de compilacao Lazarus/Free Pascal para plataformas usadas no projeto.

## Licenca

Consulte o arquivo LICENSE.
