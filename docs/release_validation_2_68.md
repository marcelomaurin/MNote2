# Validação da versão 2.68

Data: 2026-08-01. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2
e Inno Setup 6.3.3.

## Entrega

A versão 2.68 consolida a configuração multi-IA, o Voice Output, o mapa de
memória das conversas, o novo splash, os ajustes do AI Monitor e a identidade
visual unificada dos menus, abas e comandos da IDE.

## Validações

| Portão | Evidência | Resultado |
|---|---|---|
| Build desktop | `src/MNote2.lpi`, i386-win32 | aprovado |
| Runner completo | `tests/run_tests.ps1` | aprovado |
| Smoke do build | `src/MNote2.exe --smoke-test` | aprovado |
| Instalador | compilação Inno sem erro | aprovado |
| Versão instalada | `2.68.0.0` | aprovado |
| Instalação isolada | `CURRENTUSER`, `VERYSILENT`, `NOICONS` | aprovado |
| Smoke instalado | executável extraído pelo instalador | aprovado |
| Desinstalação isolada | `unins000.exe /VERYSILENT` | aprovado |

## Artefatos

- `src/MNote2.exe` — 21.530.643 bytes — SHA-256
  `D27CED71A0901549E0030BEA19BA729AB059C1E2D363DDB95F359A6256D2A221`;
- `bin/win_MNote2_68.exe` — 52.473.823 bytes — SHA-256
  `737B389C9831631868DEF653D05964EF41B71179D0416C5AAC7DCF8ECE0248D1`.
