# Validação da versão 2.65

Data: 2026-08-01. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2
e Inno Setup 6.3.3.

## Escopo

A versão 2.65 adiciona a preparação automática do componente neural-api. Na
inicialização, o MNote2 verifica a pasta `neural-api` ao lado do executável. Se
ela estiver ausente, consulta a pasta `bin` do repositório
`marcelomaurin/neural-api` em segundo plano, seleciona o instalador `.exe` ou
`.msi` de maior versão, baixa para a área local do usuário e pede confirmação
antes de executá-lo.

O download aceita somente o endereço `raw.githubusercontent.com` pertencente
ao repositório esperado. O arquivo parcial só é promovido a instalador após a
validação do tamanho e do Git blob SHA-1 fornecidos pela API do GitHub.

## Resultado

| Portão | Evidência | Resultado |
|---|---|---|
| Build desktop | build forçado de `src/MNote2.lpi`, i386-win32 | aprovado |
| Versão do executável | `2.65.0.0` | aprovado |
| Runner completo | suíte funcional e de integração | aprovado |
| Descoberta | versões 2.9 e 2.10 selecionam 2.10 | aprovado |
| Segurança da origem | URL fora do repositório é recusada | aprovado |
| Detecção local | pasta ausente/presente ao lado do executável | aprovado |
| Integridade | tamanho e Git blob SHA-1, incluindo caso divergente | aprovado |
| Consulta real | `--neural-api-check`, pasta local ausente e API `bin` em 404 | aprovado, indisponibilidade controlada |
| Smoke do fonte | `tests/run_smoke.ps1`, código 0 | aprovado |
| Instalador | compilação Inno sem erro | aprovado |
| Instalação isolada | instalação por usuário e versão `2.65.0.0` | aprovado |
| Diagnóstico instalado | `--neural-api-check`, código 0 | aprovado |
| Smoke instalado | executável instalado, código 0 | aprovado |
| Limpeza do teste | desinstalação código 0 e pasta temporária removida | aprovado |

Na data da validação, o repositório remoto ainda não publica a pasta `bin` nem
releases. Esse estado foi verificado de forma real: a API respondeu HTTP 404 e
o MNote2 continuou normalmente, apresentando a indisponibilidade sem bloquear a
IDE. Assim que a pasta for publicada, não será necessária alteração no MNote2.

## Artefatos

- `src/MNote2.exe` — 21.462.547 bytes — SHA-256
  `FFF28F2E22B95B5CF53B18FD323FC5D1BF2D8CB1D7D042E6555957A6E39F3F74`;
- `bin/win_MNote2_65.exe` — 52.467.719 bytes — SHA-256
  `C57AE0A4D0A97D131ED0849B06A3BB2111EF4366D003C26F2E27763F0A016E7C`.

O instalador foi exercitado com `CURRENTUSER`, `NOICONS` e diretório isolado.
O teste não alterou a instalação já existente na máquina.

## Observações

Os avisos restantes do build pertencem majoritariamente ao código legado
(conversões de strings, parâmetros não usados e units agregadas). Não houve
erro de compilação. Nenhuma credencial foi gravada neste relatório.
