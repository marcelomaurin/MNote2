# Services do MNote2

Esta pasta é o local oficial da lógica de aplicação extraída dos formulários.

## Convenções

- Services não referenciam forms, controles visuais ou variáveis globais de tela.
- Dados atravessam a fronteira por tipos, interfaces, métodos e eventos explícitos.
- Operações podem expor progresso e cancelamento sem acessar a thread visual diretamente.
- Erros previsíveis atualizam `LastError` e disparam `OnError`; exceções inesperadas mantêm contexto e não viram sucesso.
- Escritas em arquivo validam raiz e usam operação atômica quando aplicável.
- Tokens, senhas, prompts completos e dados sensíveis não são persistidos por services.
- Units reutilizáveis possuem testes isolados em `tests/`.
- Integrações de plataforma ficam atrás de adaptadores; o contrato comum permanece compatível com Windows e Linux.

## Nomes

Units usam o prefixo `mnote_` e classes públicas usam `TMNote`. Interfaces começam com `IMNote`. O form pode coordenar um service, mas não deve duplicar sua regra de negócio.
