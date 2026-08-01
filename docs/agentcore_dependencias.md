# Dependências do Agent Core

O pacote `openai_agentcore` foi separado do agregador visual `openai_agent` no
repositório CHATGPT. O núcleo contém os contratos e componentes de execução:

- `aiagent_core`;
- `aiagent_classifier` e `aiagent_decision`;
- `aiagent_actionbuilder`, `aiagent_actions` e `aiagent_executor`;
- `aiagent_flowevents`, `aiagent_memorymap` e `aiagent_orchestrator`;
- `aiagentsafety`.

O pacote depende somente do núcleo da IA e de units da RTL/FCL/LCL já exigidas
pelos componentes. Ele não depende de GLScene, ML, Modbus, MQTT, Chromium,
visão, hardware ou formulários de demonstração.

`openai_agent` continua sendo o pacote agregador retrocompatível e requer
`openai_agentcore`. A IDE MNote2 consome o core e implementa seu próprio fluxo de
tarefa, router, barramento e executor de ações. `TAIPipeline` permanece opcional
e não participa do caminho de inicialização da IDE.

O portão foi validado por build limpo de `openai_agentcore`, build do agregador
e execução do sample `agent_memorymap_demo`.
