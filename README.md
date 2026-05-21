# MNote2

MNote2 é um editor de texto e código multiplataforma desenvolvido em Lazarus/Free Pascal. A aplicação combina editor com abas, execução de scripts, gerenciador de bancos de dados, integração com IA, leitura de documentos e ferramentas auxiliares de voz.

Versão atual do fonte: **2.56**.

## Versões

- [Português](README.pt.md)
- [English](README.en.md)
- [Français](README.fr.md)
- [Español](README.es.md)
- [中文](README.zh.md)
- [العربية](README.ar.md)

## Screenshots

### Editor integrado
![Editor](screenshots/Editor%20com%20IA%20integrada.jpg)

### Gerenciamento de arquivos
![Gestão de Arquivos](screenshots/Gest%C3%A3o%20de%20Arquivos.jpg)

### Inteligência Artificial
![Uso da IA](screenshots/IA.jpg)

### Gerenciador de Banco de Dados
![Banco de dados](screenshots/MQUERY.jpg)

## Funcionalidades Principais

### Editor e arquivos

- Editor multiabas baseado em SynEdit.
- Realce e apoio de edição para Pascal, Python, Java, SQL, PHP, C e outros tipos configurados por listas auxiliares.
- Busca, substituição, copiar/colar, desfazer/refazer, seleção de blocos e configuração de fonte.
- Carregamento e salvamento de arquivos em abas independentes.
- Extração de texto de PDF, DOC e DOCX.
- Histórico de conversa por arquivo usando arquivos .RIA associados.
- Integração com organização de pastas e projetos.

### Projetos, pastas e análise IA

- Varredura de pastas com análise de arquivos fonte e documentos.
- Gera resumos técnicos por arquivo em cache .RIA.
- Gera análises orientadas à pergunta em cache .PIA.
- Remove cache .RIA quando o arquivo fonte é alterado depois do resumo.
- Gera mapa mental textual para consolidar pontos relevantes de uma pergunta.
- Ignora automaticamente arquivos de cache .RIA e .PIA durante novas análises.
- Suporte a leitura de extensões como .pas, .pp, .lfm, .lpr, .ini, .json, .yml, .yaml, .php, .htm, .html, .js, .xml, .c, .cpp, .txt, .doc, .docx, .pdf, .sql, .jsp, .py, .cob e .md.

### Inteligência Artificial

- Cliente de IA encapsulado em TCHATGPT, versão interna 1.5.
- Providers suportados: OpenAI, OpenRouter, Cerebras e Local/llama.cpp compatível com API /v1/chat/completions.
- Modelos previstos no código: gpt-3.5-turbo, gpt-4, gpt-4-turbo-preview, gpt-4o, gpt-o3-mini, gpt-4.1, gpt-4.1-mini e gpt-5.
- Modelos locais/Ollama previstos, incluindo llama3.2:3b, Qwen e DeepSeek.
- Suporte a modelo customizado quando configurado.
- Configuração de endpoint local por IPLocalIA.
- Histórico, mapa de memória e pensamento persistidos em arquivos .RIA.
- Classificação de continuidade da conversa.
- Preparação de contexto a partir de histórico, mapa de memória, projeto, banco de dados e arquivos analisados.
- Ações assistidas pela IA, incluindo geração de consultas SQL e criação de estruturas de tabela.

### Python e automação

- Execução de código Python aberto no editor usando PythonEngine.
- Uso configurável do caminho da DLL Python.
- Saída de execução direcionada para a área de resultados.
- Inspeção de variáveis globais e locais após a execução.
- Execução de scripts externos configuráveis para run, debug, clean, install e compile.
- Amostras em sample/python, sample/gcc e scripts auxiliares em src.

### Banco de dados e MQuery2

O módulo MQuery2 funciona como gerenciador SQL integrado.

- Conexão com MySQL, PostgreSQL e SQLite usando Zeos.
- Configuração de bibliotecas DLL/SO para MySQL, PostgreSQL e SQLite.
- Navegação por árvores de banco, tabelas, campos, views, procedures, functions, triggers e sequences conforme o banco conectado.
- Execução de SQL livre por editor integrado.
- Geração de SQL a partir de tabelas selecionadas.
- Criação de tabela a partir de dataset CSV.
- Criação de usuário no PostgreSQL.
- Geração de dicionário de dados para PostgreSQL e SQLite.
- Geração de lista de dependências/foreign keys para SQLite e PostgreSQL.
- Integração com IA para analisar SQL, sugerir melhorias, embelezar consultas e responder perguntas com base em DDL/dependências.
- Classe TSQLiteDb para conexão SQLite, transações, pragmas recomendados, execução parametrizada e consultas utilitárias.
- Classe TProjetoDB para abrir projeto SQLite, verificar tabelas e carregar metadados/configurações.

### Ferramentas de voz

- ToolsFalar envia texto por TCP para um serviço de síntese de voz, como srvFalar.
- ToolsOuvir conecta por TCP para receber comandos/mensagens externas.
- Ativação automática opcional ao iniciar, conforme configuração.
- Configuração de IP e porta pela interface.

### Instalação e distribuição

- Instalador Windows por Inno Setup em instalador/MNote2.iss.
- Versão do instalador Windows: 2.56.
- Copia MNote2.exe, DLLs, arquivos .dci, listas .txt, scripts .bat, amostras e banco padrão.
- Copia o banco padrão para C:\db.
- Inclui opção pós-instalação para iniciar srvFalar_1.4.exe.
- Pacotes e binários históricos ficam em bin.
- Script buildlinux.sh mantém fluxo de empacotamento Linux/deb.

## Estrutura do Projeto

- src/MNote2.lpr: ponto de entrada da aplicação Lazarus.
- src/main.pas: formulário principal, abas, editor, carga/salvamento, chat, histórico, ferramentas e integração geral.
- src/classes/item.pas: encapsula cada aba/item editável, execução Python e execução de scripts configurados.
- src/classes/chatgpt.pas: cliente HTTP para providers de IA.
- src/setmain.pas: configuração global e persistência em mnote.cfg.
- src/config.pas: formulário de configuração de scripts, DLLs, IA, bancos e ferramentas TCP.
- src/folders.pas: gerenciamento de pastas, análise de arquivos, caches .RIA/.PIA e análise de projeto por IA.
- src/ia.pas: interface de IA com histórico, mapa de memória, pensamento, continuidade e ações.
- src/mquery2/mquery2.pas: gerenciador de bancos e SQL.
- src/sqlite_db.pas: wrapper SQLite.
- src/uprojetodb.pas: carregamento de projeto SQLite e metadados.
- src/uPdfText.pas: extração nativa simples de texto de PDF.
- src/uDocText.pas: extração de texto de DOC/DOCX.
- src/toolsfalar e src/toolsouvir: ferramentas TCP de fala e escuta.
- db/projeto_padrao.db: banco padrão do projeto.
- screenshots: imagens usadas no README.
- instalador: scripts de empacotamento Windows.
- sample: exemplos de Python, C e processamento de imagem.
- libs, sqlite e tools: bibliotecas e utilitários externos distribuídos com o projeto.

## Requisitos

### Desenvolvimento

- Lazarus IDE e Free Pascal Compiler.
- Pacotes Lazarus usados pelo projeto, incluindo LCL, SynEdit, TAChart, Indy, Zeos, RX, Python4Lazarus, lNet e componentes adicionais listados em src/MNote2.lpi.
- Bibliotecas de banco conforme o uso: SQLite, MySQL client e PostgreSQL/libpq/ODBC conforme configuração.
- Python 3 compatível com a DLL configurada quando a execução Python estiver habilitada.
- Inno Setup para gerar o instalador Windows.

### Uso

- Windows e Linux são os alvos principais presentes no projeto.
- DOC clássico (.doc) exige Windows com Microsoft Word instalado.
- Funcionalidades de IA exigem token/provider configurado ou servidor local compatível.
- Ferramentas de fala/escuta exigem serviço TCP correspondente ativo.

## Configuração

A configuração principal fica em mnote.cfg, gerenciada por TSetMain. Ela inclui:

- Posição/tamanho da janela e fonte.
- Últimos arquivos.
- Scripts de run/debug/clean/install/compile.
- Token de IA e provider.
- Endpoint de IA local.
- Caminhos de DLLs de Python, MySQL e PostgreSQL.
- Dados de conexão MySQL, PostgreSQL e SQLite.
- Ativação e IPs das ferramentas ToolsFalar e ToolsOuvir.
- Pasta padrão e projeto atual.

Observação: mnote.cfg pode conter token de IA e senhas de banco. Proteja esse arquivo no ambiente local.

## Uso Básico

1. Abra o MNote2.
2. Configure caminhos de DLLs, scripts, bancos e IA em Configurações.
3. Abra ou crie arquivos nas abas do editor.
4. Use o menu de linguagem para selecionar o tipo de arquivo/código.
5. Execute Python diretamente ou scripts externos configurados.
6. Abra o MQuery2 para conectar em MySQL, PostgreSQL ou SQLite.
7. Use a tela de IA para perguntas com histórico, mapa de memória e análise de projeto.
8. Use o gerenciador de pastas para gerar resumos .RIA e análises .PIA.
9. Ative ToolsFalar/ToolsOuvir quando precisar de integração TCP de voz.

## Observações de Manutenção

- O código atual concentra bastante lógica em main.pas, folders.pas, ia.pas e mquery2.pas.
- O repositório contém binários, pacotes e bibliotecas externas versionadas porque o projeto distribui artefatos junto com o fonte.
- Arquivos .RIA e .PIA são usados como cache/resultado de IA e podem ser regenerados pela aplicação.
- src/lib contém artefatos de compilação Lazarus/Free Pascal para plataformas usadas no projeto.

## Licença

Consulte o arquivo LICENSE.
