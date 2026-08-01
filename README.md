# MNote2

MNote2 é uma IDE desktop leve, escrita em Lazarus/Free Pascal, com editor em
abas, busca de projeto, autocomplete local, gestão de tarefas, banco de dados,
build e assistência multi-IA por texto ou voz.

Versão desta entrega: **2.64**.

![MNote2 IDE com IA](screenshots/MNote2_IDE_IA_2_63.png)

## Destaques

- shell no estilo Visual Studio com painéis persistentes e paleta de comandos;
- Search/Replace UTF-8, regex, filtros, preview, backup e rollback;
- perfis de linguagem, temas, snippets, símbolos, F12 e referências;
- Solution Explorer hierárquico e contexto único para projeto, arquivos, Tasks,
  busca, build, terminal, símbolos e IA;
- projetos, Tasks, Task List, Gantt, Timeline e Risk Matrix;
- seis papéis de IA, router determinístico, limites, cancelamento e AI Monitor;
- entrada digitada responde por texto; voz ativada por “OK MNote” responde por
  fala e também preserva o texto;
- propostas de fonte em JSON, diff por hunk, confirmação, Apply atômico, testes
  e rollback;
- Data Dictionary PostgreSQL/SQLite, autocomplete SQL e geração sem execução;
- Problems, Output por canal, Build/Rebuild e Terminal;
- núcleo portátil validado em CI Windows e Linux x64.

## Documentação

- [Manual do usuário](docs/manual_usuario.md)
- [Arquitetura](docs/arquitetura_ide_ia.md)
- [Matriz de capacidades](docs/capability_matrix.md)
- [Testes e CI](docs/ci.md)
- [Calibração real do estimador](docs/tokenest_calibracao.md)

## Desenvolvimento e validação

O projeto de referência usa Lazarus 4.4 e FPC 3.2.2. No Windows:

```powershell
powershell -ExecutionPolicy Bypass -File tests/run_tests.ps1
powershell -ExecutionPolicy Bypass -File tests/run_smoke.ps1
```

O instalador Windows é gerado por `instalador/MNote2.iss`. Credenciais ficam no
`mnote.cfg` local; use `mnote.example.cfg` como referência segura.

## Segurança

Respostas livres da IA nunca são executadas como comandos. Leitura, build e
alteração de fonte possuem permissões distintas. Escrita exige proposta
validada, diff e confirmação. Não publique `mnote.cfg`.

## Licença

Consulte [LICENSE](LICENSE).
