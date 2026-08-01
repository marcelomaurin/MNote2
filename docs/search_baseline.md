# Linha de base e ownership da pesquisa

## MIDE-G02 — mecanismo legado

A medição usa a fixture versionada `tests/fixtures/search/baseline_utf8.txt` e
reproduz o algoritmo anterior de `main.pas`: `Copy` do restante do texto a cada
ocorrência e `AnsiUpperCase` de cópias completas para a busca sem diferenciar
caixa. Cada cenário foi repetido 200.000 vezes para produzir duração mensurável.

Ambiente: Windows 11 Pro 10.0.22631, Intel Core i3-10100, 15,8 GB de RAM,
Free Pascal 3.2.2, alvo i386-win32.

| Cenário | Ocorrências por execução | Tempo total | Pico aproximado do processo |
| --- | ---: | ---: | ---: |
| Literal, case sensitive (`MNote`) | 4 | 156 ms | 7.675.904 bytes |
| Literal, case insensitive (`mnote`) | 5 | 2.235 ms | 7.675.904 bytes |
| Múltiplas ocorrências (`alpha`) | 6 | 6.281 ms | 7.675.904 bytes |

Comando reproduzível: `tests/run_search_baseline.ps1`. Os tempos são contexto
comparativo da máquina acima, não um limite absoluto de aprovação.

## MIDE-G03 — propriedade e vazamento

`TMNoteSearchResults` é o proprietário exclusivo de cada
`TMNoteSearchResult`. O cenário `tests/run_search_heap.ps1` executa 1.000 ciclos
de criação do serviço, busca, navegação lógica pela coleção, `Clear` e
destruição, compilado com `heaptrc`.

Resultado registrado: 12.169 blocos alocados, 12.169 liberados e zero blocos
não liberados. O `TFinds` legado mantém apenas referências emprestadas e seu
destrutor agora chama `inherited`; nenhum resultado novo deve usar essa classe.

## Convenção de posições

Linha e coluna são baseadas em 1. A coluna é contada em caracteres UTF-8 como o
`CaretXY` do SynEdit, e não em bytes; caracteres combinantes ocupam colunas
separadas. `AbsoluteIndex` continua 1-based e em bytes apenas como dado auxiliar
para aplicar mudanças do fim para o início. CRLF e LF incrementam uma única
linha lógica.

Para regex, substituições usam a sintaxe do `RegExpr`: `$0` para o casamento
completo e `$1` a `$9` (ou `${1}`) para grupos capturados.

## MIDE-043 — desempenho do mecanismo novo

`tests/run_search_performance.ps1` gera fora da árvore de fontes uma fixture
temporária com 500 arquivos pequenos e um arquivo grande de 50.000 linhas. Ela
é removida pelo próprio cenário, inclusive quando ocorre uma exceção.

Medição no mesmo ambiente da linha de base, com FPC 3.2.2:

- 501 arquivos examinados e 50.500 ocorrências encontradas em 250 ms;
- pico aproximado do processo de 16.924.672 bytes;
- sinalização e término do cenário cancelado em 0 ms nesta fixture;
- cancelamento suportado tanto pela API síncrona quanto pela thread de busca.

O valor de memória inclui a coleção intencional de 50.500 resultados. A busca
lê apenas um arquivo e uma linha por vez; portanto, o projeto inteiro não é
carregado na memória. Os números são reprodutíveis e comparativos, não limites
absolutos independentes de hardware.

## Markup e navegação

A versão instalada do SynEdit 4.4 oferece
`TCustomSynEdit.SetHighlightSearch`, apoiado por
`TSynEditMarkupHighlightAll`. A barra usa esse markup nativo e o limpa com uma
string vazia ao fechar, sem modificar o highlighter de linguagem. O resultado
atual continua sendo a seleção normal do editor e, por isso, recebe a aparência
distinta já definida pelo SynEdit.
