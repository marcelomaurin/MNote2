# Validação da versão 2.67

Data: 2026-08-01. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2
e Inno Setup 6.3.3.

## Correção

O Solution Explorer voltou a usar uma hierarquia explícita no estilo Visual
Studio: `Solution > Projeto > pastas e arquivos`. A pasta raiz é carregada e
expandida ao abrir ou atualizar o projeto, enquanto as subpastas continuam com
carregamento sob demanda.

A conexão ativa do MQuery2 também passou a ser sincronizada no Solution
Explorer. MySQL, PostgreSQL e SQLite exibem `Banco de dados > Tabelas` logo
após conectar ou atualizar. O Data Dictionary mantém a mesma árvore atualizada
quando seus metadados são gerados.

## Validações

| Portão | Evidência | Resultado |
|---|---|---|
| Árvore do projeto | fixture com arquivo e subpasta | aprovado |
| Árvore do banco | banco e duas tabelas simuladas no painel real | aprovado |
| Integração MQuery2 | sincronização após Refresh MySQL/PostgreSQL/SQLite | aprovado |
| Segurança das ações | nós virtuais não aceitam renomear/excluir no disco | aprovado |
| Build desktop | `src/MNote2.lpi`, i386-win32 | aprovado |
| Teste dedicado | `tests/run_solution_tree.ps1` | aprovado |
| Regressão Close | `tests/run_close_tab.ps1` | aprovado |
| Smoke | `tests/run_smoke.ps1` | aprovado |
| Runner completo | `tests/run_tests.ps1` | aprovado |
| Versão do executável instalado | `2.67.0.0` | aprovado |
| Instalador | compilação Inno sem erro | aprovado |
| Instalação isolada | árvore, Close e smoke no executável instalado | aprovado |
| Limpeza | desinstalação e remoção da pasta temporária | aprovado |

## Artefatos

- `src/MNote2.exe` — 21.464.595 bytes — SHA-256
  `3E7E6FB03B56CD878F66C5809A4B41F082D13A1C61FD3B44C661F2B2A130A34E`;
- `bin/win_MNote2_67.exe` — 52.458.371 bytes — SHA-256
  `A39906D116B24ABF25AB4822432BC54C98670D6CBB4D458075389AC4A002DA69`.
