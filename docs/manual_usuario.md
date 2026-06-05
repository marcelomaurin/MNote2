# Manual de Uso do MNote2

Este manual apresenta o uso do **MNote2** para usuários que desejam editar arquivos, executar scripts, usar IA, analisar pastas e trabalhar com bancos de dados.

## 1. Visão geral

O MNote2 é uma aplicação desktop que reúne várias ferramentas em uma única interface:

- editor de texto e código;
- gerenciador de arquivos e pastas;
- assistente de IA;
- execução de Python;
- execução de scripts externos;
- gerenciador SQL integrado;
- leitura de documentos PDF, DOC e DOCX;
- ferramentas TCP para fala e escuta.

Ele é indicado para programadores, técnicos, estudantes e usuários avançados que desejam uma ferramenta leve para editar, analisar e automatizar tarefas.

## 2. Abrindo o programa

Ao abrir o MNote2, a tela principal apresenta:

- área de edição em abas;
- menus de arquivo, linguagem, execução e configuração;
- painel de resultado;
- acesso às telas de IA, pastas, banco de dados e ferramentas auxiliares.

## 3. Criando ou abrindo arquivos

### Criar novo arquivo

1. Use a opção **Novo**.
2. Uma nova aba será aberta.
3. Digite o conteúdo desejado.
4. Salve o arquivo com **Salvar** ou **Salvar como**.

### Abrir arquivo existente

1. Use a opção **Carregar/Abrir**.
2. Escolha o arquivo no disco.
3. O arquivo será aberto em uma nova aba.

### Salvar arquivo

- Use **Salvar** para gravar no mesmo arquivo.
- Use **Salvar como** para escolher outro nome ou pasta.

## 4. Trabalhando com abas

Cada arquivo aberto fica em uma aba independente. O MNote2 controla internamente cada aba como um item editável.

Recursos disponíveis:

- alternar entre arquivos abertos;
- fechar abas;
- detectar alterações;
- salvar arquivos individualmente;
- salvar todos os arquivos abertos;
- restaurar estado de trabalho conforme configuração.

## 5. Selecionando linguagem do arquivo

O MNote2 usa realce de sintaxe para facilitar a edição de código.

Linguagens e formatos suportados pelo código:

- Pascal/Lazarus: `.pas`, `.pp`, `.lpr`, `.lfm`;
- C/C++: `.c`, `.cpp`, `.h`;
- Python: `.py`;
- PHP: `.php`;
- Java: `.java`;
- JavaScript: `.js`;
- HTML/CSS: `.html`, `.htm`, `.css`;
- SQL: `.sql`;
- shell script: `.sh`;
- batch: `.bat`;
- JSON: `.json`;
- XML: `.xml`;
- YAML: `.yml`, `.yaml`;
- INI: `.ini`;
- Markdown: `.md`;
- Arduino: `.ino`.

A linguagem pode ser definida automaticamente pela extensão ou manualmente pelo menu.

## 6. Busca e substituição

O editor possui recursos de:

- localizar texto;
- substituir texto;
- localizar novamente;
- seleção de blocos;
- copiar, colar, desfazer e refazer.

Use estes recursos para editar arquivos de código ou texto comum.

## 7. Executando Python

O MNote2 pode executar código Python usando Python4Lazarus/PythonEngine.

### Antes de usar

Configure o caminho da biblioteca Python compatível com a versão e arquitetura do programa.

Exemplos comuns:

- Windows 64 bits: `python3x.dll` compatível com a versão instalada.
- Linux: biblioteca compartilhada Python correspondente.

### Como executar

1. Abra um arquivo `.py` ou escreva código Python em uma aba.
2. Configure o Python nas opções do sistema.
3. Use a opção de execução.
4. Veja a saída no painel de resultado.

### Observações

- Se a DLL/biblioteca Python estiver errada, a execução pode falhar.
- A arquitetura do Python deve combinar com a arquitetura do executável.
- Scripts com dependências externas precisam que os pacotes estejam instalados no ambiente Python usado.

## 8. Scripts externos

O MNote2 permite configurar comandos externos para:

- run;
- debug;
- clean;
- install;
- compile.

Esses comandos podem ser usados para acionar compiladores, scripts `.bat`, scripts `.sh` ou ferramentas externas.

### Exemplo de uso

1. Abra as configurações.
2. Defina o comando de execução ou compilação.
3. Abra um arquivo do projeto.
4. Use o menu correspondente para executar o comando.

## 9. Usando Inteligência Artificial

O MNote2 possui integração com IA para responder perguntas, analisar fontes, gerar ideias, analisar SQL e trabalhar com contexto.

### Providers suportados

- OpenAI;
- OpenRouter;
- Cerebras;
- IA local compatível com `/v1/chat/completions`;
- Antigravity/Gemini, por classe própria.

### Configuração da IA

1. Abra as configurações.
2. Escolha o provider.
3. Informe o token, quando necessário.
4. Escolha o modelo.
5. Para IA local, configure o endereço do servidor.

Exemplo de endpoint local esperado:

```text
http://localhost:8095/v1/chat/completions
```

Dependendo da configuração, o MNote2 monta o endpoint a partir do servidor local informado.

### Usando a tela de IA

1. Abra a tela de IA.
2. Digite a pergunta.
3. Envie para o modelo configurado.
4. Veja a resposta.
5. Consulte histórico, mapa de memória, pensamento e logs.

### Histórico e memória

A tela de IA usa arquivos `.RIA` para guardar:

- histórico;
- mapa de memória;
- pensamento;
- contexto auxiliar.

Esses arquivos ajudam a manter continuidade entre perguntas.

## 10. Analisando pastas e projetos

O módulo de pastas permite analisar arquivos de um diretório com apoio de IA.

### Como usar

1. Abra a tela de pastas/projetos.
2. Escolha a pasta raiz do projeto.
3. Execute a varredura.
4. Faça uma pergunta sobre o projeto.
5. O MNote2 pode gerar resumos e análises dos arquivos relevantes.

### Caches gerados

| Extensão | Finalidade |
|---|---|
| `.RIA` | Resumo técnico base do arquivo ou histórico/contexto |
| `.PIA` | Análise orientada a uma pergunta específica |

### Quando limpar cache

Limpe os caches quando:

- a análise parecer desatualizada;
- muitos arquivos mudaram;
- você quer forçar nova interpretação da IA;
- a pergunta mudou muito de objetivo.

O sistema também possui lógica para remover cache `.RIA` quando o fonte muda depois do resumo.

## 11. Lendo PDF, DOC e DOCX

O MNote2 possui units para extração de texto de documentos.

Formatos previstos:

- PDF;
- DOC;
- DOCX.

Observações:

- PDF pode ter extração limitada dependendo de como o arquivo foi gerado.
- DOC clássico pode depender de recursos do Windows/Microsoft Word.
- DOCX tende a ser mais simples de extrair quando o texto está estruturado.

## 12. Usando o MQuery2

O MQuery2 é o gerenciador SQL integrado ao MNote2.

Ele permite:

- conectar em MySQL;
- conectar em PostgreSQL;
- conectar em SQLite;
- executar SQL;
- navegar por tabelas e estruturas;
- importar CSV;
- gerar dicionário de dados;
- analisar SQL com IA;
- embelezar SQL;
- gerar dependências e relacionamentos.

### Conectando a um banco

1. Abra o MQuery2.
2. Escolha o tipo de banco.
3. Informe host, usuário, senha, banco e bibliotecas necessárias.
4. Clique em conectar.
5. Navegue pelas tabelas e objetos disponíveis.

### Executando SQL

1. Escreva a consulta no editor SQL.
2. Execute a consulta.
3. Veja o resultado no grid.
4. Confira erros no painel de mensagens.

### Atenção com bancos de produção

O MQuery2 executa SQL real. Antes de usar comandos `UPDATE`, `DELETE`, `DROP`, `ALTER` ou `CREATE`, confirme se está no banco correto.

## 13. Usando ToolsFalar

`ToolsFalar` envia texto por TCP para um serviço externo de fala, como `srvFalar`.

### Configuração

1. Informe IP e porta do serviço de fala.
2. Ative a ferramenta.
3. Envie o texto.

### Requisitos

- Serviço de fala ativo.
- Porta liberada no firewall.
- IP correto.

## 14. Usando ToolsOuvir

`ToolsOuvir` conecta a um serviço TCP para receber comandos ou mensagens externas.

### Configuração

1. Informe IP e porta.
2. Ative a ferramenta.
3. Aguarde mensagens recebidas.

## 15. Arquivo de configuração

O MNote2 usa `mnote.cfg` para guardar configurações.

Esse arquivo pode conter:

- token de IA;
- senhas de banco;
- caminhos de DLL;
- últimas pastas;
- últimos arquivos;
- configuração de janela;
- configuração de fonte;
- scripts externos.

> Não publique `mnote.cfg` com dados reais.

## 16. Problemas comuns

### A IA não responde

Verifique:

- token configurado;
- provider correto;
- modelo válido;
- conexão com internet;
- endpoint local ativo, se usar IA local;
- firewall ou proxy.

### Python não executa

Verifique:

- caminho da DLL/biblioteca Python;
- versão e arquitetura do Python;
- dependências instaladas;
- permissões do sistema.

### Banco não conecta

Verifique:

- host;
- porta;
- usuário e senha;
- nome do banco;
- biblioteca cliente configurada;
- firewall;
- serviço do banco ativo.

### PDF ou DOC não abre corretamente

Verifique:

- se o documento possui texto real ou imagem escaneada;
- se o formato é suportado;
- se as bibliotecas necessárias estão disponíveis;
- se o arquivo não está corrompido.

### A análise de pasta ficou errada ou antiga

Tente:

- limpar `.RIA` e `.PIA`;
- refazer a varredura;
- fazer uma pergunta mais específica;
- reduzir o escopo da pasta;
- verificar se os arquivos importantes estão em formato texto.

## 17. Boas práticas

- Use uma pasta de trabalho separada para testes.
- Não rode SQL destrutivo em banco de produção.
- Mantenha backup dos arquivos importantes.
- Configure IA local para testes longos ou privados.
- Proteja arquivos com tokens e senhas.
- Limpe caches quando mudar muito o projeto.

## 18. Resumo rápido

Para começar rapidamente:

1. Abra o MNote2.
2. Configure IA, Python e bancos apenas se precisar.
3. Abra um arquivo ou pasta.
4. Edite o código.
5. Use IA para dúvidas ou análise.
6. Use MQuery2 para consultas SQL.
7. Salve seus arquivos e proteja suas configurações.