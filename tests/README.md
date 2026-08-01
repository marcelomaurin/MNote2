# Testes

Execute `powershell -ExecutionPolicy Bypass -File tests/run_tests.ps1` a partir da raiz. O runner compila as units reais, grava artefatos em `tests/bin` e retorna código diferente de zero em qualquer falha.

Mocks de respostas de IA não são aceitos como prova funcional. Fixtures determinísticas podem validar parsing, segurança, roteamento e falhas; chamadas declaradas como reais exigem provider e credencial reais e registram indisponibilidade quando não puderem ser executadas.
