# Auditoria da segurança de agentes

## Decisão

`aiagentsafety.pas` foi adaptada e incluída em `openai_agentcore`. A unit do
pacote pesado permanece como fachada compatível. O executor do MNote2 usa a
camada de segurança real; nenhuma proteção é anunciada apenas por existir no
repositório.

## Camadas ativas

- protocolo JSON estrito e rejeição de campos críticos desconhecidos;
- matriz explícita de permissões por papel;
- bloqueio de caminho fora da raiz, symlink, extensão e tamanho;
- distinção entre leitura, build e alteração de fonte;
- confirmação obrigatória para efeitos privilegiados;
- limite de saída, rodadas, tentativas e orçamento;
- fingerprint de ciclos e bloqueio de A → B → A;
- classificação de erro antes de retry;
- hash, diff, gravação atômica, backup e rollback para mudanças;
- log de decisão sem token, senha ou prompt completo.

## Limites declarados

A LLM não recebe autoridade implícita. Triagem e Árbitro não executam ações. A
IA de banco gera e valida SQL, mas não o executa. Voz pode ser desativada; quando
o reconhecedor ou sintetizador não está disponível, a falha é informada e não
simulada.

Os testes `TestAIActions`, `TestMultiAICore`, `TestSourceChanges` e
`TestEndToEndTaskExecution` exercitam bloqueios, confirmação, ciclo, falha real,
apply e rollback.
