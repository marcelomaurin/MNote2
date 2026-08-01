# Documentação do Sistema MNote2

> Documento histórico da arquitetura original. Para a arquitetura efetivamente
> entregue na versão 2.65, consulte `arquitetura_ide_ia.md`,
> `capability_matrix.md` e `manual_usuario.md`.

Este documento descreve a estrutura técnica do **MNote2** com base nos fontes do projeto.

O foco é ajudar desenvolvedores a entenderem a organização interna, os principais módulos, responsabilidades, dependências, pontos de atenção e caminhos recomendados para manutenção.

## 1. Visão arquitetural

O MNote2 é uma aplicação desktop Lazarus/Free Pascal baseada em formulários LCL. A arquitetura atual é predominantemente orientada a forms, com parte significativa da lógica de negócio implementada diretamente nas units de tela.

Principais características:

- aplicação desktop LCL;
- editor baseado em SynEdit;
- persistência de configuração em arquivo local;
- integração HTTP com provedores de IA;
- integração Python via Python4Lazarus;
- banco de dados via Zeos;
- análise de arquivos e pastas;
- ferramentas TCP auxiliares;
- distribuição com binários, DLLs, scripts, banco padrão e instalador.

## 2. Estrutura principal

```text
src/
├── MNote2.lpr
├── MNote2.lpi
├── main.pas
├── folders.pas
├── ia.pas
├── config.pas
├── setmain.pas
├── funcoes.pas
├── sqlite_db.pas
├── uProjetoDB.pas
├── uPdfText.pas
├── uDocText.pas
├── classes/
│   ├── item.pas
│   ├── chatgpt.pas
│   └── demais classes auxiliares
├── mquery2/
│   ├── mquery2.pas
│   ├── tabela.pas
│   ├── typedb.pas
│   ├── triggers.pas
│   ├── view.pas
│   └── views.pas
├── imgjson/
├── toolsfalar/
└── toolsouvir/
```

## 3. Ponto de entrada

### `src/MNote2.lpr`

Responsável por iniciar a aplicação Lazarus, criar os formulários principais e executar o loop da aplicação.

### `src/MNote2.lpi`

Arquivo de projeto Lazarus.

Informações relevantes:

- projeto em modo compatibilidade;
- manifesto Windows XP habilitado;
- DPI aware habilitado;
- versão histórica do projeto analisado nesse documento: 2.61;
- 52 units registradas;
- 23 pacotes Lazarus exigidos.

Pacotes relevantes:

- LCL;
- SynEdit;
- TAChart;
- Zeos `zcomponent` e `zcomponentdesign`;
- Indy;
- lNet;
- RX;
- Python4Lazarus;
- GifAnim;
- pacotes próprios/externos como `industrial`, `poweredby`, `multiloglaz`.

## 4. Form principal

### `src/main.pas`

Unit principal da aplicação. Declara `TfrmMNote`.

Responsabilidades principais:

- gerenciar a janela principal;
- controlar abas do editor;
- abrir, salvar e fechar arquivos;
- integrar menus de linguagem;
- acionar execução de scripts;
- acionar execução Python;
- integrar ChatGPT/IA;
- abrir módulos auxiliares, como MQuery2, Folders, ferramentas de fala/escuta e JSON;
- manter histórico e contexto;
- restaurar estado de workspace.

Funções e procedimentos importantes identificados:

- `NovoItem`;
- `CloseTab`;
- `FileLoad`;
- `FileNewSave`;
- `FocusFile`;
- `GetFile`;
- `LoadArquivo`;
- `SalvarTab`;
- `SalvarComo`;
- `SalvarTudo`;
- `Mudou`;
- `PerguntaSalvar`;
- `RodaScript`;
- `RodaSQL`;
- `FazPergunta`;
- `QuestionChat`;
- `SubmeteChatGPT`;
- `CarregarHistorico`;
- `CarregaContexto`;
- `SalvarWorkspaceState`;
- `RestaurarWorkspaceState`.

### Pontos fortes

- Centraliza a experiência do usuário.
- Integra diversos módulos em uma única interface.
- Usa SynEdit como base de edição.
- Suporta múltiplos arquivos por abas.

### Pontos de atenção

- A unit é grande e concentra muita responsabilidade.
- Há forte acoplamento entre tela principal, IA, banco, Python, documentos e ferramentas externas.
- Para manutenção futura, recomenda-se mover regras para services/use cases.

## 5. Representação de arquivo/aba

### `src/classes/item.pas`

Declara `TItem`, classe que representa um arquivo ou item editável dentro do editor.

Responsabilidades:

- armazenar nome, diretório, extensão e estado de salvamento;
- associar um `TSynEdit` ao item;
- configurar highlighter por extensão;
- gerenciar autocomplete;
- executar arquivos/scripts;
- manter dados de erro;
- integrar execução Python por `TPythonCtrl`.

### Tipos de arquivo reconhecidos

A enumeração `TTypeItem` prevê:

- indefinido;
- C/C++;
- Pascal;
- batch;
- configuração/texto;
- SQL;
- Python;
- PHP;
- Java;
- JavaScript;
- HTML;
- CSS;
- JSON;
- XML;
- YAML;
- INI;
- Markdown;
- Arduino `.ino`;
- shell script.

### Highlighters usados

A unit utiliza vários highlighters SynEdit:

- `TSynPasSyn`;
- `TSynBatSyn`;
- `TSynCppSyn`;
- `TSynCssSyn`;
- `TSynJavaSyn`;
- `TSynJScriptSyn`;
- `TSynPHPSyn`;
- `TSynPythonSyn`;
- `TSynSQLSyn`;
- `TSynUNIXShellScriptSyn`;
- `TSynAnySyn`.

### Pontos de atenção

- Existe função marcada como placeholder: `getPascfuncs`.
- O autocomplete possui pontos reservados para evolução contextual.
- O módulo mistura controle de item, editor, highlighter e execução.

## 6. Cliente de IA

### `src/classes/chatgpt.pas`

Declara a classe `TCHATGPT`, responsável por comunicação com provedores de IA compatíveis com chat/completions.

Responsabilidades:

- armazenar token, pergunta, resposta, modelo e provider;
- montar endpoint conforme provider;
- montar JSON de requisição;
- adicionar headers HTTP;
- enviar requisição via `TFPHttpClient`;
- interpretar JSON de resposta;
- armazenar último JSON retornado;
- tratar provedores locais sem Authorization;
- redirecionar provider Antigravity/Gemini para classe própria.

### Providers previstos

Enumeração `TAIProvider`:

- `AIP_OPENAI`;
- `AIP_OPENROUTER`;
- `AIP_CEREBRAS`;
- `AIP_LOCAL`.

Além disso, quando `FSetMain.Provider = 4`, a unit redireciona a chamada para `TAntigravity`.

### Modelos previstos

A enumeração `TVersionChat` inclui:

- GPT 3.5;
- GPT-4;
- GPT-4 Turbo;
- GPT-4o;
- o3-mini;
- GPT-4.1;
- GPT-4.1 mini;
- GPT-5;
- llama3.2:3b;
- Qwen;
- DeepSeek;
- customizado.

### Endpoints

- OpenAI: `https://api.openai.com/v1/chat/completions`.
- OpenRouter: `https://openrouter.ai/api/v1/chat/completions`.
- Cerebras: `https://api.cerebras.ai/v1/chat/completions`.
- Local: servidor configurado + `/v1/chat/completions`.

### Pontos de atenção

- O limite `max_tokens` aparece fixado em 150 na montagem do JSON.
- Timeouts são maiores para IA local.
- Erros são encapsulados como JSON simples em `FResponse`.
- A classe é útil e poderia ser separada futuramente como componente reutilizável.

## 7. Tela de IA

### `src/ia.pas`

Declara `TfrmIA`, tela de interação com IA.

Responsabilidades:

- manter histórico de conversa;
- manter mapa de memória;
- manter pensamento/contexto;
- permitir seleção de provider e modelo;
- fazer perguntas à IA;
- analisar continuidade;
- analisar banco e pastas;
- gerar ações a partir de respostas;
- executar ações assistidas.

### Ações previstas

A enumeração `TTipoAcao` contém:

- pesquisar informação;
- criar tabela;
- modificar tabela;
- modificar código;
- criar novo código;
- enviar e-mail.

### Arquivos `.RIA`

A tela trabalha com arquivos como:

- `HISTORICO.RIA`;
- `mapamemoria.RIA`;
- `pensamento.RIA`.

Esses arquivos persistem histórico e contexto da IA.

### Pontos de atenção

- O fluxo de pergunta é síncrono.
- Para modelos locais ou análises longas, a interface pode ficar bloqueada.
- Recomenda-se evolução para thread/fila/cancelamento.
- A execução de ações deve ser protegida por confirmação quando envolver banco, arquivo ou e-mail.

## 8. Análise de pastas e projeto

### `src/folders.pas`

Declara `TfrmFolders`, módulo de gerenciamento e análise de pastas.

Responsabilidades:

- exibir árvore de diretórios;
- exibir lista de arquivos;
- fazer scanner de pasta;
- gerar árvore de projeto;
- analisar arquivos com IA;
- gerar e ler cache `.RIA`;
- gerar e ler cache `.PIA`;
- limpar caches;
- verificar alteração de fonte após cache;
- buscar termos em arquivos;
- montar prompt de análise;
- gerar mapa mental textual;
- resolver caminhos de forma cross-platform;
- abrir arquivos na tela principal.

### Fluxo de análise

Fluxo conceitual:

1. O usuário escolhe uma pasta.
2. O scanner lista os arquivos relevantes.
3. A pergunta do usuário é analisada.
4. A IA pode recomendar arquivos importantes.
5. O sistema gera resumo base `.RIA` por arquivo.
6. O sistema gera análise orientada `.PIA` por pergunta.
7. Uma resposta final é montada com base nos resumos.

### Caches

| Cache | Finalidade |
|---|---|
| `.RIA` | Resumo técnico base ou contexto geral |
| `.PIA` | Pontos importantes para uma pergunta específica |

### Caminhos cross-platform

A unit implementa helpers como:

- `IsAbsolutePathPortable`;
- `NormalizeRelPath`;
- `NormalizeAndExpand`.

Esses helpers reduzem problemas entre Windows e Linux.

### Pontos de atenção

- A unit é extensa.
- A lógica de UI e análise está misturada.
- Recomendado extrair scanner, cache e análise IA para units próprias.

## 9. MQuery2

### `src/mquery2/mquery2.pas`

Declara `Tfrmmquery2`, gerenciador SQL integrado ao MNote2.

Responsabilidades:

- conectar em MySQL;
- conectar em PostgreSQL;
- conectar em SQLite;
- executar SQL;
- exibir resultados em grids;
- listar estruturas de banco;
- importar CSV;
- gerar dicionário de dados;
- gerar dependências;
- analisar SQL com IA;
- embelezar SQL;
- criar estruturas auxiliares;
- trabalhar com triggers, views, sequences e tabelas.

### Componentes importantes

- `TZConnection` para conexões Zeos;
- `TZReadOnlyQuery` e `TZQuery` para consultas;
- `TDataSource` e `TDBGrid` para exibição;
- `TSynEdit` para edição SQL;
- `TSynSQLSyn` para realce;
- `TCSVDataset` para CSV;
- `TAChart` para gráficos.

### Bancos suportados

- MySQL;
- PostgreSQL;
- SQLite.

### Pontos de atenção

- `mquery2.pas` é o maior módulo do sistema.
- A unit concentra UI, conexão, execução SQL, metadados, IA e geração de scripts.
- Recomenda-se separar em serviços específicos por banco e por responsabilidade.

## 10. Configuração

### `src/setmain.pas`

Responsável pela configuração global e persistência do contexto.

O sistema usa `FSetMain` como objeto global de configuração.

Configurações previstas:

- posição da janela;
- fonte;
- últimos arquivos;
- scripts externos;
- token de IA;
- provider;
- modelos;
- endpoint local;
- caminho de Python;
- caminhos de bibliotecas de banco;
- configurações MySQL/PostgreSQL/SQLite;
- ToolsFalar/ToolsOuvir;
- pasta padrão;
- projeto atual.

### `src/config.pas`

Formulário de configuração. Permite editar parâmetros persistidos em `FSetMain`.

### Cuidados

- `mnote.cfg` pode conter dados sensíveis.
- Não versionar configuração pessoal com tokens e senhas.
- Recomenda-se criar `mnote.example.cfg` sem dados reais.

## 11. SQLite e projeto de banco

### `src/sqlite_db.pas`

Wrapper para operações SQLite.

Responsabilidades esperadas:

- abrir conexão;
- controlar transações;
- executar comandos;
- aplicar pragmas;
- auxiliar consultas.

### `src/uProjetoDB.pas`

Responsável por abrir projeto SQLite, verificar tabelas e carregar metadados/configurações do projeto.

## 12. Extração de documentos

### `src/uPdfText.pas`

Extração simples de texto de PDF.

### `src/uDocText.pas`

Extração de texto de DOC/DOCX.

Cuidados:

- PDFs escaneados podem não ter texto extraível.
- DOC clássico pode depender do ambiente Windows/Word.
- DOCX costuma ser mais adequado para extração direta.

## 13. Ferramentas TCP

### `src/toolsfalar/toolsfalar.pas`

Ferramenta para enviar texto a um serviço TCP de fala.

Uso previsto:

- integração com `srvFalar` ou serviço semelhante;
- envio de texto para síntese de voz;
- configuração de IP e porta.

### `src/toolsouvir/toolsouvir.pas`

Ferramenta para receber comandos/mensagens via TCP.

Uso previsto:

- integração com assistentes externos;
- recebimento de comandos;
- automação por rede local.

## 14. Fluxos principais

### 14.1 Abrir arquivo

```text
Usuário seleciona arquivo
        ↓
main.pas chama FileLoad/LoadArquivo
        ↓
cria ou localiza TItem
        ↓
TItem identifica extensão
        ↓
configura highlighter
        ↓
conteúdo é exibido em TSynEdit
```

### 14.2 Executar Python

```text
Usuário abre/escreve script Python
        ↓
TItem identifica tipo Python
        ↓
PythonEngine é usado para execução
        ↓
saída vai para painel de resultado
        ↓
variáveis globais/locais podem ser inspecionadas
```

### 14.3 Perguntar à IA

```text
Usuário escreve pergunta
        ↓
TfrmIA ou TfrmMNote prepara contexto
        ↓
TCHATGPT/TAntigravity monta requisição
        ↓
TFPHttpClient envia JSON
        ↓
resposta é extraída de choices[0].message.content
        ↓
resposta é exibida e registrada
```

### 14.4 Analisar pasta com IA

```text
Usuário escolhe pasta
        ↓
TfrmFolders faz scanner
        ↓
arquivos relevantes são listados
        ↓
IA recomenda arquivos ou gera resumos
        ↓
.RIA guarda resumo base
        ↓
.PIA guarda análise por pergunta
        ↓
resposta final é montada
```

### 14.5 Executar SQL no MQuery2

```text
Usuário configura conexão
        ↓
Zeos conecta ao banco
        ↓
usuário escreve SQL em SynEdit
        ↓
query é executada
        ↓
resultado aparece no grid
        ↓
erros aparecem no painel de mensagens
```

## 15. Dependências externas

Principais dependências:

- Lazarus/FPC;
- SynEdit;
- ZeosLib;
- Python4Lazarus;
- Indy;
- lNet;
- RX;
- TAChart;
- OpenSSL;
- bibliotecas clientes de banco;
- Python instalado ou biblioteca Python distribuída;
- Inno Setup para instalador Windows.

## 16. Segurança

Pontos sensíveis:

- token de IA;
- senhas de banco;
- execução de SQL;
- execução de Python;
- scripts externos;
- serviços TCP;
- caches com conteúdo de arquivos analisados.

Recomendações:

- não publicar `mnote.cfg` real;
- confirmar ações geradas por IA;
- evitar SQL destrutivo sem confirmação;
- não executar scripts desconhecidos;
- proteger arquivos `.RIA` e `.PIA` quando contiverem informações privadas;
- separar ambiente de teste e produção.

## 17. Pontos técnicos fortes

- Projeto real, grande e funcional.
- Integra editor, IA e banco de dados.
- Usa Lazarus/FPC de forma ampla.
- Suporta IA local e remota.
- Possui análise de projetos por pasta.
- Possui MQuery2 integrado, que poderia ser produto próprio.
- Possui base para automação por Python e TCP.

## 18. Pontos de atenção e dívida técnica

### 18.1 Forms grandes demais

Principais units concentradas:

- `main.pas`;
- `folders.pas`;
- `ia.pas`;
- `mquery2.pas`.

Problema:

- manutenção mais difícil;
- maior risco de regressão;
- menor reutilização;
- testes automatizados quase inexistentes.

### 18.2 Acoplamento alto

A tela principal conhece muitos módulos. Isso dificulta trocar componentes internos sem afetar a interface.

### 18.3 IA síncrona

Chamadas longas podem travar a interface.

Recomendação:

- thread de execução;
- fila de tarefas;
- botão cancelar/stop;
- log incremental;
- estado de progresso.

### 18.4 Configuração sensível

O arquivo `mnote.cfg` centraliza muitos dados e pode conter segredos.

Recomendação:

- criar configuração exemplo;
- separar segredos;
- documentar permissões;
- evitar versionar dados reais.

### 18.5 Dependências de compilação

O `.lpi` exige muitos pacotes. Isso dificulta compilação por terceiros.

Recomendação:

- criar guia de build;
- listar versões testadas;
- separar dependências opcionais;
- criar build modes por plataforma.

## 19. Refatoração recomendada

Sugestão de reorganização futura:

```text
src/services/
├── uAIService.pas
├── uAIProviderOpenAI.pas
├── uAIProviderLocal.pas
├── uProjectScannerService.pas
├── uDocumentTextExtractor.pas
├── uCacheRIAService.pas
├── uPythonRunnerService.pas
├── uScriptRunnerService.pas
├── uMQueryConnectionService.pas
├── uMQueryMetadataService.pas
├── uMQueryExecutionService.pas
└── uVoiceTcpService.pas
```

### Objetivo

- Forms ficam responsáveis pela interface.
- Services ficam responsáveis pela lógica.
- Código fica mais testável.
- Módulos podem ser reutilizados em outros projetos.

## 20. Roadmap técnico sugerido

### Fase 1 — estabilização

- Atualizar documentação.
- Criar guia de build.
- Criar releases oficiais.
- Revisar versão única do projeto.
- Criar `mnote.example.cfg`.
- Padronizar nomenclatura de arquivos e menus.

### Fase 2 — manutenção

- Extrair `TCHATGPT` para módulo reutilizável.
- Separar scanner de pastas.
- Separar cache `.RIA`/`.PIA`.
- Separar execução Python.
- Separar conexão SQL por banco.

### Fase 3 — robustez

- Criar execução assíncrona para IA.
- Criar botão Stop.
- Criar logs estruturados.
- Criar tratamento de erro centralizado.
- Criar testes unitários para helpers.

### Fase 4 — produto

- Criar instalador versionado.
- Criar pacote Linux versionado.
- Criar página de releases.
- Criar screenshots atualizados.
- Criar vídeo curto demonstrando uso.
- Separar MQuery2 como módulo/produto opcional.

## 21. Conclusão técnica

O MNote2 é um projeto ambicioso e funcional. Ele ultrapassa o conceito de editor de texto e se comporta como uma mini IDE técnica com IA, banco de dados e automação.

A maior força do projeto é a integração prática de recursos em um único ambiente Lazarus.

A maior fragilidade é a concentração de lógica em forms grandes. O próximo passo técnico mais importante é transformar partes da aplicação em serviços reutilizáveis, mantendo a interface como camada visual.

Com essa refatoração, o MNote2 pode evoluir de ferramenta pessoal poderosa para produto open source mais profissional e fácil de manter.
