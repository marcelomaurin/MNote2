# Documentação do MNote2

Esta pasta reúne a documentação principal do **MNote2**, organizada para dois públicos:

1. **Usuários finais**, que precisam instalar, configurar e usar a aplicação.
2. **Desenvolvedores**, que precisam entender a estrutura interna, os módulos e os pontos de manutenção do sistema.

## Documentos disponíveis

- [Manual de uso](manual_usuario.md)
- [Documentação do sistema](documentacao_sistema.md)

## O que é o MNote2

O MNote2 é uma aplicação desktop escrita em **Lazarus/Free Pascal**. Ele começou como editor de texto/código e evoluiu para uma ferramenta técnica com:

- editor multiabas;
- execução Python;
- integração com IA;
- análise de pastas e fontes;
- leitura de PDF, DOC e DOCX;
- gerenciador SQL integrado;
- ferramentas TCP de fala e escuta;
- suporte a bancos MySQL, PostgreSQL e SQLite.

## Módulos principais

| Módulo | Fonte principal | Finalidade |
|---|---|---|
| Aplicação principal | `src/main.pas` | Janela principal, abas, editor, arquivos, integração geral |
| Item/aba editável | `src/classes/item.pas` | Representa cada arquivo aberto e controla linguagem, highlighter e execução |
| Cliente de IA | `src/classes/chatgpt.pas` | Comunicação HTTP com OpenAI, OpenRouter, Cerebras e IA local |
| Análise de pastas | `src/folders.pas` | Scanner, análise IA, cache `.RIA`/`.PIA`, busca global |
| Tela de IA | `src/ia.pas` | Histórico, mapa de memória, pensamento e ações assistidas |
| Banco de dados | `src/mquery2/mquery2.pas` | MQuery2: gerenciador SQL para MySQL, PostgreSQL e SQLite |
| Configuração | `src/setmain.pas` e `src/config.pas` | Persistência e tela de configuração |
| Voz TCP | `src/toolsfalar/` e `src/toolsouvir/` | Integração com serviços externos de fala e escuta |

## Fluxo básico de uso

1. Abrir o MNote2.
2. Configurar caminhos, IA, Python e bancos.
3. Abrir ou criar arquivos.
4. Usar o editor ou executar scripts.
5. Abrir pastas para análise de projeto.
6. Usar a IA com contexto de arquivos, banco e histórico.
7. Usar o MQuery2 para consultas e análise SQL.

## Arquivos gerados pela aplicação

| Arquivo | Uso |
|---|---|
| `mnote.cfg` | Configurações locais da aplicação |
| `.RIA` | Cache/resumo/análise gerado por IA |
| `.PIA` | Análise orientada a pergunta gerada por IA |
| bancos `.db` | Bancos SQLite usados pelo projeto ou pelo MQuery2 |

## Cuidados

- Não publique `mnote.cfg` com token de IA ou senhas reais.
- Arquivos `.RIA` e `.PIA` são caches e podem ser regenerados.
- A execução Python depende da biblioteca Python configurada corretamente.
- O MQuery2 executa SQL real; use com cuidado em bancos de produção.
- Algumas funcionalidades exigem bibliotecas externas ou serviços TCP ativos.

## Recomendação de evolução

Para evolução futura, recomenda-se separar a lógica hoje concentrada nos formulários em units de serviço. Isso facilitaria testes, manutenção e reutilização dos módulos em outros projetos Lazarus.