# Inventário de arquivos `.PIA` e `.RIA`

## Objetivo

Este relatório atende ao portão `MIDE-G01` e classifica os arquivos antes de qualquer regra de exclusão ou limpeza. A inspeção foi feita no repositório, no `MNote2.lpi` e no código ativo em 31/07/2026.

## Resultado

| Grupo | Produtor | Consumidor | Classificação | Decisão |
|---|---|---|---|---|
| `<fonte>.RIA` | `TfrmFolders.IA_ResumoArquivoBase` | análise de pastas em `folders.pas` | cache regenerável de resumo por IA | ignorar novos arquivos no Git |
| `<fonte>.PIA` | `TfrmFolders.IA_PontosImportantes` | análise de pastas em `folders.pas` | cache regenerável de análise orientada à pergunta | ignorar novos arquivos no Git |
| `HISTORICO.RIA`, `mapamemoria.RIA`, `pensamento.RIA` e arquivos de continuidade | `TfrmIA` | histórico e contexto da tela de IA | estado local regenerável e potencialmente sensível | ignorar no Git e manter fora do path de compilação |
| arquivos `.PIA` já versionados junto a fontes, scripts, configuração e instaladores | versões anteriores do analisador de pastas | nenhum consumidor de compilação | saída histórica de IA/cache, não fonte | retirar do versionamento sem apagar a cópia de trabalho |
| `.PIA/.RIA` dentro de exemplos intencionais | nenhum grupo distinto encontrado | não aplicável | não encontrado na data da auditoria | reavaliar se um exemplo documentado for adicionado |

## Evidências

- O projeto ativo não declara arquivo `.PIA` ou `.RIA` em `MNote2.lpi` nem em paths de units.
- `folders.pas` grava e reutiliza `<fonte>.RIA` e `<fonte>.PIA`, invalida o cache quando o fonte muda e possui limpeza explícita desses arquivos.
- `ia.pas` grava histórico, mapa de memória, pensamento, continuidade e respostas intermediárias com extensão `.RIA`.
- `main.pas` lê histórico `.RIA` associado ao documento.
- Os 25 arquivos `.PIA` encontrados no Git começam com metadados `Arquivo`, `FullPath`, `Pergunta` e texto de análise; nenhum contém uma unit, projeto ou script consumido como fonte ativa.
- Nenhum arquivo `.RIA` estava versionado no inventário.
- A compilação de referência resolveu os fontes `.pas`, `.lpr`, `.lfm` e pacotes instalados sem consultar `.PIA/.RIA`.

## Segurança e privacidade

Esses arquivos podem conter perguntas, respostas, caminhos absolutos e trechos de código. Por isso, novos caches não devem ser versionados. A limpeza pela aplicação deve continuar limitada à raiz escolhida e às duas extensões, sem apagar fontes correspondentes.

## Conclusão

Neste repositório, `.PIA` e `.RIA` são saídas regeneráveis/estado local, não entrada de gerador nem fonte ativa. É seguro adicioná-los ao `.gitignore` e retirar apenas os exemplares já rastreados do índice, preservando os arquivos locais. Uma futura exceção deverá ser documentada por caminho antes de ser versionada.
