# Validação da versão 2.63

Data: 2026-08-01. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2,
Inno Setup 6.3.3.

## Resultado

| Portão | Evidência | Resultado |
|---|---|---|
| Build desktop | build forçado de `src/MNote2.lpi`, i386-win32 | aprovado |
| Runner completo | projeto, plano, ações, multi-IA, diff, rollback, busca, completion, voz e integrações | aprovado |
| Ciclo de tarefa | projeto → tarefa → proposta → aprovação → Apply → teste → conclusão | aprovado |
| Rollback | modificação, hunks, arquivo novo, remoção lógica, falha atômica e hash divergente | aprovado |
| Smoke do fonte | `tests/run_smoke.ps1`, código 0 | aprovado |
| Busca/heap | 0 blocos não liberados atribuíveis à busca | aprovado |
| Busca/desempenho | 501 arquivos, 50.500 resultados, 390 ms; cancelamento ativo | aprovado |
| Highlighter | instâncias por aba, sem estado cruzado; 0 blocos não liberados | aprovado |
| Núcleo portátil | build e execução x86_64-win64 | aprovado |
| CI | workflow Windows/Linux x64 com execução do runner | configurado |
| Pacotes CHATGPT | nove pacotes com build forçado e quatro samples | aprovado |
| Tokens | 10 warmups + 20 validações Gemini reais; erro médio 2,02% | aprovado |
| Instalador | compilação Inno sem erro | aprovado |
| Instalação isolada | instalação por usuário, arquivos essenciais e versão 2.63.0.0 | aprovado |
| Smoke instalado | executável instalado, código 0 | aprovado |
| Limpeza do teste | desinstalação código 0, sem pasta ou registro residual | aprovado |

## Artefatos

- `src/MNote2.exe` — SHA-256
  `328A19FAD621725666E5BB894F7B071C6B00C820D8D6FDA377F755C5681AB130`;
- `bin/win_MNote2_63.exe` — 52.458.498 bytes — SHA-256
  `9330B6F5BE1945D84927D1F0026EECBE6B88E569EE5215744FDD4EEAF44511BD`.

O instalador foi exercitado com `CURRENTUSER`, `NOICONS` e diretório temporário
para não alterar a instalação 2.60 existente na máquina. A entrada de máquina
anterior permaneceu na versão 2.60 após o teste.

## Observações

Os avisos do build completo pertencem majoritariamente ao código legado
(conversões de string, hints de parâmetros e units agregadas). Não houve erro de
compilação. Nenhum token, senha ou prompt completo foi gravado neste relatório.
