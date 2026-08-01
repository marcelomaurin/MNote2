# Validação da versão 2.64

Data: 2026-08-01. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2
e Inno Setup 6.3.3.

## Escopo

A versão 2.64 integra a área de projetos ao restante da IDE segundo o fluxo do
Visual Studio. Um contexto único passa a coordenar Solution Explorer, Files,
Tasks, Task List, Changes, Terminal, busca, símbolos, Build e IA.

O contexto reconhece pastas, `.mnoteproj.json`, Lazarus `.lpi`/`.lpr` e o
projeto legado `.db`. Um descritor inválido é recusado sem substituir o projeto
que já está aberto.

## Resultado

| Portão | Evidência | Resultado |
|---|---|---|
| Build desktop | build forçado de `src/MNote2.lpi`, i386-win32 | aprovado |
| Versão do executável | `2.64.0.0` | aprovado |
| Runner completo | suíte funcional e de integração | aprovado |
| Contexto de projeto | criar, fechar, reabrir por pasta e preservar contexto em erro | aprovado |
| Compatibilidade | descritor MNote2, Lazarus e `.db` legado | aprovado |
| Integração | projeto redireciona painéis, terminal, tarefas, busca, símbolos, Build e IA | aprovado |
| Segurança de caminhos | nomes com separadores/travessia são recusados | aprovado |
| Smoke do fonte | `tests/run_smoke.ps1`, código 0 | aprovado |
| Instalador | compilação Inno sem erro | aprovado |
| Instalação isolada | instalação por usuário e versão `2.64.0.0` | aprovado |
| Smoke instalado | executável instalado, código 0 | aprovado |
| Limpeza do teste | desinstalação código 0 e pasta temporária removida | aprovado |

## Artefatos

- `src/MNote2.exe` — 21.448.211 bytes — SHA-256
  `5B959015030B397E1CF22433DB46E0E8F24F9C22C2271E5EC2FBD1AB8CDDE093`;
- `bin/win_MNote2_64.exe` — 52.461.097 bytes — SHA-256
  `106FAA7A400CC4B9337D304B99A2980F6E899D87E05C17E3574EC3640AC759D3`.

O instalador foi exercitado com `CURRENTUSER`, `NOICONS` e diretório isolado.
O teste não alterou a instalação já existente na máquina.

## Observações

Os avisos restantes do build pertencem majoritariamente ao código legado
(conversões de strings, parâmetros não usados e units agregadas). Não houve
erro de compilação. Nenhuma credencial foi gravada neste relatório.
