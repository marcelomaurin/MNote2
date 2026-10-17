## Análise de IA por tarefas

- [Gerenciador de tarefas de análise](analise_ia_por_tarefas.md)

# Documentação do MNote2

> Documentação de referência da IDE MNote2 2.68. Os recursos descritos nos manuais são capacidades declaradas pelo projeto; a situação dos testes e regressões deve ser consultada nos relatórios de validação e na lista de bugs.

## Uso

- [Manual do usuário](manual_usuario.md)
- [Matriz de capacidades](capability_matrix.md)

## Acompanhamento de defeitos

- [Lista de bugs e verificações](bugs.md) — 16 cenários pendentes de validação, sem defeitos confirmados nesta triagem documental.

## Integrações de voz

- [Migração para os componentes de voz CHATGPT](migracao_voz_chatgpt.md)

## Arquitetura e contratos

- [Arquitetura da IDE com IA](arquitetura_ide_ia.md)
- [Integração CHATGPT](chatgpt_integration_audit.md)
- [Dependências do Agent Core](agentcore_dependencias.md)
- [Segurança dos agentes](agent_safety_audit.md)
- [Auditoria do ChangeSource](changesource_audit.md)
- [Extensões do schema](schema_extensoes.md)
- [Ownership dos highlighters](highlighter_ownership.md)
- [Portabilidade do dicionário](porte_dicionario.md)

## Compilação e execução

- [C, Pascal, Python, PHP e JavaScript](compilacao_multilinguagem.md)

## Treinamento de IA

- [Treinamento LLM com LoRA/QLoRA](treinamento_llm.md)

## Planos de implementação

- [Diagrama multibanco do MQuery — plano e acompanhamento](plano_diagrama_mquery.md)
- [Validação do diagrama nos servidores](validacao_diagrama_multibanco.md)

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
- [Validação da versão 2.67](release_validation_2_67.md)
- [Validação da versão 2.68](release_validation_2_68.md)

O arquivo `mnote.cfg` é local e pode conter segredos; ele não deve ser
versionado. Use `mnote.example.cfg`.
