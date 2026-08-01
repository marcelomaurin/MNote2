# Documentação do MNote2

## Uso

- [Manual do usuário](manual_usuario.md)
- [Matriz de capacidades](capability_matrix.md)

## Arquitetura e contratos

- [Arquitetura da IDE com IA](arquitetura_ide_ia.md)
- [Integração CHATGPT](chatgpt_integration_audit.md)
- [Dependências do Agent Core](agentcore_dependencias.md)
- [Segurança dos agentes](agent_safety_audit.md)
- [Auditoria do ChangeSource](changesource_audit.md)
- [Extensões do schema](schema_extensoes.md)
- [Ownership dos highlighters](highlighter_ownership.md)
- [Portabilidade do dicionário](porte_dicionario.md)

## Evidências

- [Build de referência](build_baseline.md)
- [Busca de referência](search_baseline.md)
- [Inventário PIA/RIA](pia_ria_inventory.md)
- [Regressão dos pacotes](package_regression.md)
- [Calibração real de tokens](tokenest_calibracao.md)
- [CI Windows/Linux](ci.md)
- [Validação da versão 2.63](release_validation_2_63.md)
- [Validação da versão 2.64](release_validation_2_64.md)
- [Validação da versão 2.65](release_validation_2_65.md)
- [Validação da versão 2.66](release_validation_2_66.md)

O arquivo `mnote.cfg` é local e pode conter segredos; ele não deve ser
versionado. Use `mnote.example.cfg`.
