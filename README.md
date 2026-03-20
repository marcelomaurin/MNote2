# MNote2

MNote2 é um editor de texto multiplataforma avançado, focado em simplicidade, eficiência e produtividade. Desenvolvido principalmente em Pascal com Lazarus/Free Pascal, oferece uma ampla gama de funcionalidades para edição, organização e gerenciamento de notas e códigos, integrando recursos modernos como inteligência artificial, manipulação de banco de dados SQLite embutido, e integração com Python.

---

## Funcionalidades Principais

- Editor de texto com suporte a arquivos Plain Text (.txt) e extração de texto de arquivos PDF e DOC;
- Suporte a múltiplas abas e sessões para edição simultânea;
- Busca e substituição de texto facilitadas;
- Salvamento automático para evitar perda de dados;
- Gerenciamento interno completo por banco SQLite:
  - Armazenamento e organização de notas, categorias e tags;
  - Controle simples de versões baseado no banco;
  - Importação e exportação de notas;
  - Consulta rápida por data, título e conteúdo;
  - Backup e restauração via exportação do arquivo banco;
- Integração com scripts Python para automação e extensão direta no editor;
- Assistência de inteligência artificial via ChatGPT, baseada no contexto do código fonte;
- Ferramentas configuráveis para fala (ToolsFalar) e audição (ToolsOuvir);
- Interface gráfica rica e responsiva, construída com Lazarus Component Library (LCL), com painéis para edição, histórico, inspeção e resultados;
- Utilitários multiplataforma para manipulação de strings, JSON, processos do sistema, registro de tipos de arquivo no Windows, e monitoramento de hardware (CPU e GPUs Nvidia);
- Associação de extensões de arquivo a programas via registro no Windows;
- Compatibilidade com sistemas Windows e macOS, com possibilidade de compilação para Linux.

---

## Estrutura do Projeto

- **/src**: Código-fonte Pascal/Lazarus, organizado por módulos:
  - `main.pas`: Núcleo da aplicação, gestão de edição, integrações com AI e Python;
  - `config.pas`: Formulário para configuração personalizada de scripts e ferramentas;
  - `sqlite_db.pas`: Componente para manipulação do banco de dados SQLite (conexão, comandos, transações);
  - `uprojetodb.pas`: Gerenciador de projetos baseado no banco SQLite, com leitura de metadados;
  - `funcoes.pas`: Biblioteca utilitária multidisciplinar para operações diversas e suporte multiplataforma;
  - `sobre.pas`: Janela "Sobre" para exibição de informações da aplicação e créditos;
  - Múltiplas unidades adicionais para funcionalidades como IA, rede neural, visualização, SQL, e outras;
- **/instalador**:
  - `MNote2.iss`: Script de instalador para Windows via Inno Setup, com privilégios administrativos, suporte 32 bits, cópia de DLLs, exemplos e banco de dados local;
  - `mac.pkgproj`: Projeto de pacote instalador para macOS, instalação na pasta `/Applications`, com permissões administrativas e estruturação adequada;
- **/bin**: Pacotes e executáveis pré-compilados para Linux (.deb) e Windows (.exe);
- **/db**: Banco de dados padrão SQLite do projeto;
- **/imgs** e **/screenshots**: Imagens do projeto para a interface e documentação visual;
- **/scripts**: Script auxiliar Python para contagem de linhas de código (`contafonte.py`);

---

## Tecnologias Utilizadas

- Linguagem: Pascal/Delphi com Lazarus/Free Pascal IDE e compilador;
- Interface gráfica: Lazarus Component Library (LCL) associada a Qt Widgets (nas versões com Qt);
- Banco de dados: SQLite embutido, gerenciado pelo componente `TSQLiteDb`;
- Integração com Python via pacote `python4lazarus_package`;
- Inteligência Artificial: API ChatGPT para assistente de programação e análises de código;
- Sistema multiplataforma: suporte principal para Windows e macOS; possibilidade de uso em Linux;
- Ferramentas de build e controle: arquivo de projeto Lazarus (`.lpi`), arquivo principal Lazarus (`.lpr`), scripts auxiliares;

---

## Requisitos para Instalação e Compilação

- **Windows**:
  - Windows 7 ou superior (32 bits);
  - Executar instalador `.exe` com privilégios administrativos;
  - O instalador copia todas as bibliotecas, exemplo de códigos e banco em `C:\db`;
  - Criação automática de atalhos no menu iniciar e opcionalmente na área de trabalho.
- **macOS**:
  - macOS 10.12 ou superior;
  - Instalador `.pkg` que coloca o aplicativo em `/Applications`;
  - Requer autenticação administrativa durante instalação.
- **Linux** (compilação manual ou uso de pacotes `.deb`):
  - Free Pascal e Lazarus instalados;
  - Qt 5.x ou superior (caso se use a versão Qt);
  - Biblioteca SQLite instalada;

---

## Como Usar

1. Execute o MNote2 após a instalação;
2. Crie, abra ou importe notas, armazenadas internamente no banco SQLite;
3. Trabalhe com múltiplas abas para gerenciar vários documentos simultaneamente;
4. Use funcionalidades de busca, substituição e salvamento automático;
5. Execute scripts Python dentro das abas para automatização e testes;
6. Consulte bancos de dados SQL e manipule dados com suporte a consultas integradas;
7. Use a integração com ChatGPT para obter suporte inteligente baseado no código;
8. Faça backup e restaure notas via exportação/importação do banco SQLite;
9. Configure caminhos, scripts, e opções relacionadas à fala, audição e IA no menu de configurações;

---

## Contribuindo

Contribuições são bem-vindas! Para colaborar:

- Faça um fork no repositório oficial;
- Crie branches separadas para alterações específicas;
- Faça commits claros e frequentes documentando suas alterações;
- Envie pull requests para revisão e integração no projeto principal.

---

## Licença

MNote2 é licenciado sob a **GNU General Public License versão 3 (GPLv3)**, que garante aos usuários:

- Direitos de uso, modificação e redistribuição livre do software;
- Obrigatoriedade da disponibilização do código fonte nas distribuições;
- Proibição de impor restrições adicionais às liberdades do software;
- Ausência de garantias, software fornecido "no estado em que se encontra".

Consulte o arquivo `LICENSE` para detalhes completos.

---

## Contato e Informações Adicionais

- Autor e mantenedor: **Marcelo Maurin**  
- GitHub: [https://github.com/marcelomaurin](https://github.com/marcelomaurin)  
- Use a janela "Sobre" no aplicativo para obter informações sobre a versão e autores;  
- Agradecimentos às ferramentas Qt, SQLite e Lazarus pelo suporte técnico e desenvolvimento.

---

Obrigado por usar e contribuir para o MNote2, uma solução moderna para gestão e edição integrada de notas e códigos em diversas plataformas.
