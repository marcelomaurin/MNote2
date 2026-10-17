# Validação da versão 2.71

Data: 2026-10-17. Ambiente de referência: Windows, Lazarus 4.4, FPC 3.2.2.

## Entrega

A versão 2.71 consolida a refatoração do sistema de configuração, expansão dos componentes de IA/ChatGPT e modernização da identidade visual dos menus:
1. Desmembramento da tela legada de configuração (`config.pas`/`config.lfm`) em formulários modulares dedicados: `database_config.pas` (Database), `scripts_config.pas` (Scripts) e `voice_recognition_config.pas` (Voice Recognition).
2. Remoção definitiva da aba obsoleta `EAR ToolsOuvir` da tela de configurações e limpeza de units legadas.
3. Modernização completa do `Tools > ToolsOuvir` (`toolsouvir.pas`/`toolsouvir.lfm`), removendo o modelo legado de servidor TCP (IP/porta) e migrando para os componentes nativos de reconhecimento de voz do ChatGPT (`TAISpeechRecognizer` / `TAIWhisperProcessEngine` / `TAIAudioInput` do pacote `openai_voice`), com LED indicador de escuta ativa, histórico de transcrição e execução direta de comandos.
4. Ajuste no serviço de entrada de voz (`mnote_voice_input_service.pas`) para consulta direta das propriedades configuradas no `FSetMain`.
5. Implementação de 13 novos ícones vetoriais em `mnote_visual_identity.pas` e mapeamento abrangente (100% de cobertura) de todos os menus principais, submenus e menus de contexto (popups).
6. Ajuste no posicionamento do menu `About`, garantindo que seja sempre o último item na barra de menu principal.
7. Correção no painel Mapa de Memória (`mnote_memory_map_panel.pas`) com quebra automática de linha (`WordBreak := True`) e correção textual de "map code".
8. Visibilidade aprimorada de código e contexto do projeto no chat de IA (`QuestionChat` em `src/main.pas`), com suporte bidirecional aos envelopes de ferramentas ("name" e "action").
9. Sincronização e bump de versão para 2.71 em todos os manifestos (`MNote2.lpi`), código-fonte (`src/mnote_version.pas`), instalador Inno Setup (`instalador/MNote2.iss`) e documentações multilíngues.

## Validações

| Portão | Evidência | Resultado |
|---|---|---|
| Build desktop | `src/MNote2.lpi`, i386-win32 | aprovado |
| Instalador Windows | `instalador/MNote2.iss`, Inno Setup 6 | aprovado |
| Integridade do projeto | `python scripts/check_lazarus_project.py` | aprovado |
| Sincronia de versão | `python scripts/check_version_sync.py` | aprovado |
| Smoke test | `tests/run_smoke.ps1` (`MNote2.exe --smoke-test`) | aprovado |

## Artefatos

- `src/MNote2.exe` — 16.441.875 bytes — SHA-256 `7B18088E9F206755678DD5F55DFD2A7BEF6F427F7B8EB3B9C71FFDC30141F78A`.
- `bin/win_MNote2_71.exe` — 14.385.559 bytes — SHA-256 `0092225BF6A610BC5D2FF17955CE369E3AF9EDF02F3F9A20566CB7801013D421`.
