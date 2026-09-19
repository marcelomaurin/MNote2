# Integração contínua

O workflow `.github/workflows/ci.yml` usa três níveis de validação.

## 1. Integridade obrigatória

O job `project-integrity` é um gate sem dependências externas pesadas. Ele
valida:

- consistência do projeto Lazarus e das units ativas;
- sincronismo de versão;
- fronteira dos pacotes CHATGPT usados pelo MNote2;
- contrato do runner estendido em `tests/test_runner.lpr`.

O script `scripts/check_extended_test_contract.py` garante que fluxos críticos
de projeto/IA continuam presentes e realmente invocados pelo runner, incluindo
`mnote_task_execution_flow`, ações de IA, planejamento, diagnóstico e o teste
end-to-end de tarefa. Essa checagem existe para impedir que testes importantes
fiquem órfãos silenciosamente.

## 2. Núcleo portátil obrigatório

O job `portable-core` compila e executa `tests/ci_core_runner.lpi` em Windows
e Linux x64 com Lazarus 4.4. Ele falha imediatamente se a compilação ou qualquer
validação retornar código diferente de zero.

O runner portátil cobre busca UTF-8, usage real, estimativa de tokens, palavra
de ativação, resolução semântica Pascal e diff parcial.

## 3. Projeto principal ainda diagnóstico

O job `main-project-build` continua com `continue-on-error: true` porque a IDE
completa ainda depende de pacotes externos que não são instalados de forma
reproduzível na imagem limpa do CI.

`tests/test_runner.lpr` possui cobertura maior. O runner Windows em
`tests/run_tests.ps1` foi refatorado para remover caminhos pessoais absolutos e
agora aceita `MNOTE_CHATGPT_ROOT`, `MNOTE_ZEOS_ROOT` e
`MNOTE_EXTRA_UNIT_PATHS`. Mesmo assim, a imagem limpa do CI ainda não instala
todos esses pacotes externos; por isso a compilação completa do runner ainda
não é um gate portátil.

## Meta de endurecimento

A sequência para tornar todo o CI obrigatório é:

1. declarar e instalar as dependências externas de forma reproduzível;
2. compilar e executar o runner estendido no GitHub Actions;
3. retirar `continue-on-error` do build principal.

Até lá, o núcleo portátil e os contratos estruturais são gates obrigatórios e o
build integral permanece um diagnóstico explícito.

## Dependências reproduzíveis

O arquivo `ci/dependencies.json` é a fonte de verdade das dependências externas
do CI. O repositório CHATGPT é fixado por SHA completo e não por branch. O
bootstrap `ci/bootstrap_chatgpt.sh` clona exatamente esse commit, registra os
pacotes Lazarus na ordem declarada e força a compilação de cada pacote.

O build desktop usa o suporte `include-packages` de
`gcarreno/setup-lazarus` para provisionar as famílias do Online Package
Manager usadas pelo projeto. Enquanto essa resolução ainda estiver sendo
validada no runner limpo, os jobs de dependências/build principal permanecem
diagnósticos. Quando ambos passarem de forma estável, `continue-on-error` deve
ser removido e o build integral passa a ser gate obrigatório.

Para atualizar o CHATGPT usado pelo CI, altere conscientemente o SHA em
`ci/dependencies.json` e deixe o gate `check_dependency_manifest.py` validar
o novo manifesto.

O runner estendido também possui agora um projeto Lazarus próprio em
`tests/test_runner.lpi`. Isso evita compilar a suíte com uma longa lista manual
de `-Fu`: o `lazbuild` passa a usar os pacotes registrados pelo bootstrap.
O job `chatgpt-dependencies` compila e executa esse runner depois de preparar
o checkout fixado do CHATGPT.


### Bootstrap gráfico do desktop

O Online Package Manager do Lazarus pode enumerar os arquivos do pacote
BGRABitmap numa ordem em que `BGLControls` é compilado antes de
`BGRABitmapPack`. Para evitar depender dessa ordem interna, o CI usa
`ci/bootstrap_desktop_graphics.sh`.

Esse bootstrap fixa o repositório oficial `bgrabitmap/bgrabitmap` por SHA,
registra e compila primeiro `BGRABitmapPack`, e só depois baixa e compila
`atsynedit_package` e `atsynedit_ex_package`.

O CHATGPT usado pelo CI também está fixado em um commit que inclui a correção
Linux de `pacote/funcoes.pas`, evitando a geração de um bloco `uses ;`
vazio fora de Windows/Darwin.
