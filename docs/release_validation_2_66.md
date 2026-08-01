# Validação da versão 2.66

Data: 2026-08-01. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2,
GDB 8.3.1 e Inno Setup 6.3.3.

## Correção

O comando `Close` destruía a aba e seu `TSynEdit` antes do `TItem`. O destrutor
do item ainda precisava do editor para remover eventos, completion e
highlighter. Além disso, Search e o shell da IDE ainda mantinham referências
ao editor fechado. O acesso posterior à memória liberada resultava em
`Privileged instruction` ou código de saída 217.

A rotina agora desconecta Search e o shell enquanto o editor está válido,
libera o `TItem`, destrói a aba e atualiza o próximo editor ativo. A ordem
respeita a propriedade real dos objetos e não oculta exceções.

## Resultado

| Portão | Evidência | Resultado |
|---|---|---|
| Reprodução anterior | `--close-tab-test`, código 217 | falha confirmada |
| Diagnóstico | GDB: `TSynEditMarkupHighlightAll.SetSearchOptions`, Search destructor | causa confirmada |
| Regressão corrigida | cinco ciclos reais de criar aba + `Close` | 5/5, código 0 |
| Script permanente | `tests/run_close_tab.ps1` | aprovado |
| Fechamento da janela | mensagem `WM_CLOSE`, saída normal | código 0 |
| Build desktop | build forçado de `src/MNote2.lpi`, i386-win32 | aprovado |
| Runner completo | suíte funcional e de integração | aprovado |
| Smoke do fonte | `tests/run_smoke.ps1` | código 0 |
| Versão do executável | `2.66.0.0` | aprovado |
| Instalador | compilação Inno sem erro | aprovado |
| Instalação isolada | `CURRENTUSER`, `NOICONS` | aprovado |
| Close instalado | executável instalado, `--close-tab-test` | código 0 |
| Smoke instalado | executável instalado | código 0 |
| Limpeza | desinstalação e remoção da pasta isolada | aprovado |

## Artefatos

- `src/MNote2.exe` — 21.460.499 bytes — SHA-256
  `94D8EE12A385D0F5CE1D9E0F95C0925D35312D33822C51409AA8674729EAC957`;
- `bin/win_MNote2_66.exe` — 52.463.688 bytes — SHA-256
  `27CFA95DB520F838C265F27BD0375984E3A2A3AAC435C796B68D0F568BF90475`.

Os avisos restantes do build pertencem majoritariamente ao código legado.
Não houve erro de compilação nem alteração de credenciais.
