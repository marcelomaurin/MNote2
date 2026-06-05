# MNote2

**MNote2** é uma mini IDE multiplataforma desenvolvida em **Lazarus/Free Pascal**. O projeto reúne editor de código com abas, análise de pastas com IA, cliente para modelos de linguagem, execução Python, leitura de documentos, gerenciador SQL integrado e ferramentas auxiliares de voz.

O objetivo do MNote2 é oferecer uma ferramenta leve para programadores, estudantes e técnicos que precisam editar fontes, consultar bancos de dados, analisar projetos e usar IA local ou remota dentro de uma aplicação desktop.

## Versão do projeto

- Versão declarada em `src/main.pas`: **2.60**.
- Versão de projeto em `src/MNote2.lpi`: **2.61**.
- Biblioteca interna `TCHATGPT`: **1.5**.

## Documentação

A documentação foi separada em três níveis:

- [Visão geral da documentação](docs/README.md)
- [Manual de uso](docs/manual_usuario.md)
- [Documentação do sistema](docs/documentacao_sistema.md)

## Screenshots

### Editor integrado

![Editor](screenshots/Editor%20com%20IA%20integrada.jpg)

### Gerenciamento de arquivos

![Gestão de Arquivos](screenshots/Gest%C3%A3o%20de%20Arquivos.jpg)

### Inteligência Artificial

![Uso da IA](screenshots/IA.jpg)

### Gerenciador de Banco de Dados

![Banco de dados](screenshots/MQUERY.jpg)

## Principais recursos

### Editor de código

- Editor multiabas baseado em SynEdit.
- Realce de sintaxe para Pascal, C/C++, SQL, Python, PHP, Java, JavaScript, HTML, CSS, shell script e outros formatos.
- Suporte a JSON, XML, YAML, INI, Markdown e Arduino `.ino`.
- Busca, substituição, seleção de bloco, copiar, colar, desfazer e refazer.
- Carregamento e salvamento de arquivos em abas independentes.
- Histórico e contexto por arquivo.

### Inteligência Artificial

- Cliente de IA encapsulado em `TCHATGPT`.
- Suporte a OpenAI, OpenRouter, Cerebras e servidor local compatível com `/v1/chat/completions`.
- Suporte adicional ao provider Antigravity/Gemini por classe própria.
- Configuração de modelo, token, provider e endpoint local.
- Histórico de conversa, mapa de memória e pensamento persistidos em arquivos `.RIA`.
- Geração de respostas com contexto de projeto, banco de dados e arquivos analisados.

### Análise de projeto e pastas

- Varredura de diretórios.
- Geração de resumo técnico por arquivo em cache `.RIA`.
- Geração de análise orientada à pergunta em cache `.PIA`.
- Leitura de arquivos de código e documentos.
- Extração de texto de PDF, DOC e DOCX.
- Busca global por termos dentro dos arquivos analisados.
- Geração de mapa mental textual para consolidar respostas.

### Python e automação

- Execução de código Python via Python4Lazarus/PythonEngine.
- Configuração de DLL/biblioteca Python.
- Exibição da saída na área de resultados.
- Inspeção de variáveis globais e locais.
- Execução de scripts externos configuráveis para run, debug, clean, install e compile.

### Banco de dados e MQuery2

O módulo **MQuery2** é um gerenciador SQL integrado ao MNote2.

- Conexão com MySQL, PostgreSQL e SQLite usando Zeos.
- Navegação por bancos, tabelas, campos, views, triggers, procedures, functions e sequences.
- Execução de SQL livre em editor com realce.
- Importação de CSV.
- Geração de SQL, dicionário de dados, dependências e análises de consultas.
- Integração com IA para análise, melhoria e formatação de SQL.

### Ferramentas de voz

- `ToolsFalar`: envia texto por TCP para serviço de síntese de voz.
- `ToolsOuvir`: recebe mensagens/comandos por TCP.
- Configuração de IP, porta e ativação automática.

## Estrutura resumida

```text
MNote2/
├── README.md
├── docs/
│   ├── README.md
│   ├── manual_usuario.md
│   └── documentacao_sistema.md
├── src/
│   ├── MNote2.lpr
│   ├── MNote2.lpi
│   ├── main.pas
│   ├── folders.pas
│   ├── ia.pas
│   ├── config.pas
│   ├── setmain.pas
│   ├── classes/
│   │   ├── item.pas
│   │   └── chatgpt.pas
│   ├── mquery2/
│   │   └── mquery2.pas
│   ├── toolsfalar/
│   └── toolsouvir/
├── screenshots/
├── sample/
├── db/
├── instalador/
├── libs/
└── tools/
```

## Requisitos gerais

### Para uso

- Windows ou Linux.
- Bibliotecas necessárias para os recursos utilizados: SQLite, MySQL, PostgreSQL/libpq, Python e OpenSSL conforme configuração.
- Token de IA para provedores remotos ou servidor local compatível com API OpenAI.
- Serviço TCP externo quando usar ToolsFalar/ToolsOuvir.

### Para desenvolvimento

- Lazarus IDE.
- Free Pascal Compiler.
- Pacotes Lazarus usados no projeto, incluindo LCL, SynEdit, TAChart, Indy, Zeos, RX, Python4Lazarus, lNet e demais pacotes declarados no `src/MNote2.lpi`.
- Inno Setup para gerar instalador Windows.

## Configuração principal

A configuração é persistida em `mnote.cfg` pela unit `setmain.pas`. O arquivo pode conter:

- posição e tamanho da janela;
- fonte do editor;
- últimos arquivos;
- scripts externos;
- token de IA;
- provider e modelo;
- endpoint de IA local;
- caminhos de DLLs/bibliotecas;
- dados de conexão com bancos;
- ativação de ferramentas TCP;
- pasta padrão e projeto atual.

> Atenção: `mnote.cfg` pode conter tokens e senhas. Não publique esse arquivo com dados reais.

## Status técnico

O MNote2 é funcional e possui vários módulos maduros, mas parte da lógica ainda está concentrada em formulários grandes, especialmente `main.pas`, `folders.pas`, `ia.pas` e `mquery2.pas`. A documentação técnica em `docs/documentacao_sistema.md` descreve esses módulos e aponta melhorias recomendadas.

## Licença

Consulte o arquivo [LICENSE](LICENSE).