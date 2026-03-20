MNote2 é um editor de texto multiplataforma avançado, desenvolvido principalmente em Pascal com Lazarus/Free Pascal, que oferece diversas funcionalidades integradas para edição, organização e gerenciamento de notas e códigos. A seguir, um resumo detalhado das características, arquitetura e principais tecnologias do MNote2, com foco em aspectos técnicos:

---

### Funcionalidades Principais:

- **Edição de Texto Avançada:**
  - Suporte a múltiplas abas para edição simultânea.
  - Editor com realce sintático para linguagens como Pascal, Python, Java, SQL, PHP e C.
  - Busca e substituição de texto.
  - Salvamento automático para evitar perda de dados.
  - Extração de texto embutida de arquivos PDF e documentos Word (.doc, .docx).

- **Banco de Dados SQLite Embutido e Gerenciamento de Projetos:**
  - Uso da classe `TSQLiteDb` para gerenciamento de conexões, transações e execução de SQL.
  - Projeto gerenciado pela classe `TProjetoDB`, que carrega metadados importantes e verifica integridade.
  - Armazenamento e organização de notas, categorias, tags, e controle de versões direto no banco.
  - Backup e restauração disponíveis via exportação/importação do arquivo do banco SQLite.

- **Integração com Python:**
  - Execução de scripts Python dentro do próprio editor através de `PythonEngine`.
  - Visualização e inspeção das variáveis globais e locais após execução dos scripts.
  - Controle do interpretador Python, incluindo uso do GIL (Global Interpreter Lock).

- **Integração com Inteligência Artificial:**
  - Comunicação com API do ChatGPT via componente `TCHATGPT`.
  - Interface gráfica dedicada para troca de perguntas e respostas com histórico.
  - Geração e modificação assistida de código baseado no conteúdo aberto no editor.
  - Cache local de respostas para otimização do uso da IA.
  - Suporte para executar ações automáticas sugeridas pela IA, como criação de consultas SQL.

- **Ferramentas Auxiliares para Fala e Audição:**
  - `Toolsfalar`: formulário para envio de texto por conexão TCP para síntese de voz.
  - `Toolsouvir`: cliente TCP para escutar e processar comandos recebidos em rede.
  - Configuração de IP e ativação dessas ferramentas via interface.

- **Interface e Usabilidade:**
  - Construída com Lazarus Component Library (LCL) e suporte multiplataforma.
  - Painéis para edição, histórico de ações, inspeção de variáveis, resultados e configurações.
  - Associação de extensões de arquivo no sistema operacional (principalmente Windows).
  - Suporte aos instaladores para Windows (em 32 bits com privilégios admin) e macOS (instalação em `/Applications` com autenticação).

- **Utilitários Multiplataforma:**
  - Biblioteca utilitária para manipulação de arquivos, processos, formatação JSON e CSV, manipulação de fontes e strings.
  - Funções para controle de processos do sistema e coleta de informações de hardware (CPU e GPUs Nvidia).
  - Registro automático de associações de arquivos em Windows.

---

### Estrutura do Projeto:

- **src/main.pas:** 
  - Núcleo da aplicação que gerencia o ciclo das abas, arquivos abertos, interação com IA, execução de scripts Python e SQL.
  - Implementa a interface principal e coordena eventos de interface e lógica.

- **src/sqlite_db.pas:** 
  - Classe `TSQLiteDb` para conexão e manipulação segura do banco SQLite embutido.
  - Aplicação de configurações essenciais via pragmas SQLite para segurança e performance.
  - Suporte a comandos SQL padrão e parametrizados, além de consultas retornando dados estruturados.

- **src/uprojetodb.pas:** 
  - Gerencia projetos e carregamento de metadados via banco SQLite.
  - Verifica existência de tabelas e importa parâmetros de configuração para o ambiente da aplicação.

- **src/config.pas:** 
  - Formulário para configuração dos caminhos dos scripts, bibliotecas DLL, token ChatGPT, IPs e ativação das ferramentas de fala e audição.
  - Sincroniza as configurações com o objeto global `FSetMain`.

- **src/ia.pas:** 
  - Interface e controle do módulo de Inteligência Artificial, intermediando a comunicação e respostas da API ChatGPT.
  - Gera ações a partir das respostas da IA, mantém cache, histórico e mapa de memória para continuidade.
  - Executa ações automáticas, como abrir consultas SQL em abas, baseadas nas respostas da IA.

- **src/udoctext.pas / src/updftext.pas:** 
  - Unidades para extração nativa de texto de arquivos do Word (.doc/.docx) e PDF, ampliando os tipos de documentos suportados.

- **src/toolsfalar/toolsfalar.pas / src/toolsouvir/toolsouvir.pas:** 
  - Formulários para comunicação TCP: envio de textos para voz e recepção de comandos para ações.
  - Integram funcionalidades multimodais para acessibilidade e interação.

- **Instaladores:** 
  - Windows: Script Inno Setup `MNote2.iss` com instalação em modo 32 bits e configuração dos arquivos/banco no caminho `C:\db`.
  - macOS: Projeto `mac.pkgproj` para instalação com privilégios administrativos em `/Applications`.

---

### Requisitos Técnicos para Compilação e Uso:

- Sistema Windows 7+ (32 bits recomendados), macOS 10.12+, e possibilidade para Linux.
- Lazarus IDE e Free Pascal Compiler para compilação.
- Bibliotecas SQLite e Python 3 (via pacote python4lazarus_package) corretamente instaladas.
- Configuração do token para ChatGPT necessária para uso das funcionalidades IA.
- Permissões administrativas para instalação em Windows e macOS.

---

### Uso Básico:

1. Instale o MNote2 pelo instalador adequado.
2. Abra/crie notas, organize projetos no banco SQLite.
3. Utilize múltiplas abas para edição simultânea.
4. Execute scripts Python internos para automatização.
5. Faça consultas SQL usando os módulos integrados.
6. Interaja com o assistente de IA para suporte na programação.
7. Use ferramentas de fala e escuta para acessibilidade.
8. Faça backups e restaurações do banco diretamente via interface.
9. Ajuste configurações via formulário de configuração (`config.pas`).

---

### Documentação Visual para README:

Inclua as imagens da pasta `screenshots`:

- `Gestão de Arquivos.jpg`
- `Editor com IA integrada.jpg`
- `MQUERY.jpg`

---

### Resumo:

MNote2 é um ambiente integrado para edição, organização e gestão de notas e códigos, combinando tecnologia moderna de inteligência artificial, execução Python, banco de dados local SQLite e interface gráfica rica e configurável, tudo dentro de uma aplicação leve escrita em Pascal com Lazarus/Free Pascal. É compatível com Windows, macOS e potencialmente Linux.

### Screen Shot
![Editor](screenshots/Editor%20com%20IA%20integrada.jpg)
