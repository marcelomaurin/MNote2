# Compilação e execução multilíngue do MNote2

## Escopo implementado

O módulo `TMNoteBuildService.StartSource` usa `TMNoteBuildThread` e `TMNoteProcessService` existentes para compilar, validar sintaxe e executar **arquivos isolados**. Os comandos `CommandProjectBuild` e `CommandProjectRun` do editor encaminham o arquivo ativo às ferramentas abaixo.

| Extensões | Compilar/Validar | Executar |
|---|---|---|
| `.c` | `gcc arquivo.c -o arquivo -Wall -Wextra` | executável previamente compilado |
| `.pas`, `.pp` | `fpc arquivo.pas` | executável previamente compilado |
| `.py` | Python 3 executa `ast.parse` sem executar o script | `python3 arquivo.py` (Windows: `python`) |
| `.php`, `.phtml` | `php -l arquivo.php` | `php arquivo.php` (CLI) |
| `.js`, `.mjs`, `.cjs` | `node --check arquivo.js` | `node arquivo.js` |

A execução tem controle assíncrono, interrupção, código de saída, limite de 10 minutos e logs da aba Output por reaproveitamento dos serviços existentes. A identificação da linguagem utiliza a extensão do arquivo salvo, não o highlighting.

## Projetos Lazarus e perfis

Projetos completos preservam o fluxo de `.mnote/build.json` e `lazbuild` quando o arquivo ativo não é uma das extensões atendidas diretamente; para projetos Pascal com múltiplas unidades, utilizar o build do projeto com o perfil apropriado, pois compilar um arquivo Pascal isolado não substitui o `lazbuild`. Perfis `.mnote/build.json` podem executar comandos externos personalizados.

## Dependências

Exige as ferramentas instaladas e localizáveis no PATH (`gcc`, `fpc`, `python3`/`python`, `php`, `node`) e permissões adequadas. As ferramentas **não são instaladas automaticamente** pelo MNote2.

## Limites conhecidos

- C com múltiplos arquivos/Make/CMake, GCC vs. Clang e opções de link devem usar perfil personalizado.
- Pascal `.lpi` com pacotes e dependências deve usar `lazbuild`.
- TypeScript precisa de etapa `tsc` ou ferramenta equivalente, não implementada nessa execução direta.
- PHP CLI não disponibiliza servidor web nem simula automaticamente variáveis HTTP.
- JavaScript de navegador precisa de navegador/web server e não roda necessariamente no Node.js.
- Execução de programas criados pelo usuário deve ser iniciada conscientemente: o código executado tem as permissões do usuário do MNote2.
- Análise das mensagens Python/PHP/Node no painel Problems pode não mapear todas as linhas; stdout/stderr permanece em Output.
- Depuração integrada e detecção/configuração visual de toolchains ainda não foram implementadas.
- Não há compilação real nem teste E2E confirmado nesta alteração. É necessário validar Lazarus e toolchains Windows/Linux antes de publicar instaladores.

## Teste manual recomendado

1. Abrir e salvar arquivos mínimos de cada linguagem.
2. Para C/Pascal compilar, verificar executável, depois executar.
3. Para Python/PHP/JavaScript validar sintaxe, depois executar.
4. Confirmar texto de erro, código de retorno, cancelamento e tempo limite.
5. Verificar projeto Lazarus com `.lpi`, e conferir build via `lazbuild` com perfil do projeto.
