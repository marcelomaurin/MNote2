# Validação do diagrama em servidores

Estado em 2026-10-08: validador compilado; quatro ambientes ainda não configurados.
Não interpretar SKIP como aprovação. O teste consulta metadados e não cria,
altera nem exclui tabelas no servidor.

## Execução

Na raiz do projeto, executar em PowerShell:

```powershell
./tests/run_db_diagram_tests.ps1 -TestProgram db_diagram_server_test
```

O compilador e os drivers usados são os mesmos da aplicação Win32/i386.
As bibliotecas cliente devem ser compatíveis com essa arquitetura.

Cada ambiente é configurado por variáveis de ambiente da sessão do teste:

| Prefixo | Driver Zeos |
| --- | --- |
| MQUERY_POSTGRES_ | postgresql |
| MQUERY_MYSQL_ | mysql |
| MQUERY_MSSQL_ | mssql |
| MQUERY_ORACLE_ | oracle |

Acrescentar ao prefixo: HOST, PORT, DATABASE, SCHEMA, USER, PASSWORD e LIBRARY.
DATABASE ausente faz o ambiente ser pulado. PORT pode ser omitido para usar o
padrão do driver. LIBRARY identifica o arquivo cliente usado pela conexão.
Não salvar PASSWORD em arquivos versionados nem colocar credenciais em exemplos.
Este runner não importa automaticamente as senhas salvas pelo MQuery.

EXPECT_TABLES e EXPECT_FKS são opcionais e permitem verificar contagens exatas
de um schema de teste conhecido. Sem elas, o runner verifica leitura não vazia,
origens das relações e ordenação das colunas, e informa as contagens encontradas.
Isso não substitui a validação dos casos de borda descritos abaixo.

O runner conecta uma origem de leitura e executa o mesmo serviço assíncrono
do diagrama, que abre sua conexão independente. Erros são registrados sem a
senha fornecida. Não há criação automática de schemas ou fixtures remotas.

## Resultados

- Saída 0: todos os quatro ambientes configurados e aprovados pelo runner.
- Saída 1: ao menos um ambiente configurado falhou.
- Saída 2: nenhum falhou, mas ao menos um ficou sem configuração.
- PASS informa engine, número de tabelas, FKs e avisos; guardar essa evidência
  no plano junto com a versão do servidor e o schema de teste utilizado.
- O limite de espera do teste de metadados é 60 segundos. O timeout do login
  inicial depende do driver. Cancelamento não interrompe à força chamadas nativas.

## Casos para homologação

Validar em cada engine, com estruturas previamente preparadas no ambiente de teste:

1. FK simples, composta, autorreferente e múltiplas FKs entre as mesmas tabelas.
2. Tabelas homônimas em schemas diferentes e nomes com espaços, aspas e underscore.
3. Referência para outro schema, respeitando o escopo selecionado e avisos.
4. Usuário com visibilidade limitada de metadados; erros ou omissões explícitos.
5. Banco sem FKs e banco com centenas de tabelas.
6. Duas conexões simultâneas, abertura pela pasta não ativa e desconexão durante leitura.
7. Cancelamento durante leitura, fechamento da janela e preservação do snapshot.

Não marcar uma engine como integralmente homologada apenas por conseguir
conectar ou por compilar o driver. Registrar limitações por versão/configuração.
