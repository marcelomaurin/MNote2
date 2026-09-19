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

Da mesma forma, `tests/test_runner.lpr` possui cobertura maior, mas o runner
Windows legado em `tests/run_tests.ps1` ainda contém caminhos absolutos para
instalações locais de CHATGPT, Zeos e componentes Lazarus. Enquanto esses
caminhos não forem substituídos por descoberta/configuração reproduzível, a
compilação completa do runner não deve ser apresentada como um gate portátil.

## Meta de endurecimento

A sequência para tornar todo o CI obrigatório é:

1. remover caminhos absolutos de `tests/run_tests.ps1`;
2. declarar e instalar as dependências externas de forma reproduzível;
3. compilar e executar o runner estendido no GitHub Actions;
4. retirar `continue-on-error` do build principal.

Até lá, o núcleo portátil e os contratos estruturais são gates obrigatórios e o
build integral permanece um diagnóstico explícito.
