# Migração dos serviços de voz para CHATGPT

Atualização: 2026-10-17. Branch: `main`.

## Objetivo
Eliminar a dependência de servidores externos de escuta e fala do MNote2, usando os componentes da biblioteca CHATGPT já incorporados ao projeto.

## Implementação
- Entrada: `src/toolsouvir/toolsouvir.pas` usa `TMNoteVoiceInputService`, que encapsula `TAIAudioInput`, `TAISpeechRecognizer` e `TAIWhisperProcessEngine`.
- Saída: `src/toolsfalar/toolsfalar.pas` usa `MNoteVoiceOutput`, que encapsula `TAIVoiceSynthesizer`.
- Formulários de voz: removidos controles de IP, porta e transporte TCP legado.
- Instalador: removida a instalação/execução do servidor de fala externo.
- Removidos `tools/windows/srvouve.py`, `src/srvfalar.py`, `src/fala.c` e os pacotes `bin/srvfalar*.deb`.
- `scripts/check_lazarus_project.py` verifica a ausência dos serviços antigos e a integração das telas com a camada de voz.

## Dependências e configuração
O reconhecimento pela implementação atual depende de `WHISPER_CLI` e `WHISPER_MODEL`, com ajustes opcionais `WHISPER_LANGUAGE`, `WHISPER_THREADS` e `WHISPER_GPU`. Esses caminhos são usados pelo componente Whisper do projeto CHATGPT. A síntese usa a configuração de engine, voz, volume, taxa e modo assíncrono do MNote2.

## Validação pendente
Mudanças publicadas no código-fonte, **sem compilação ou teste de microfone/alto-falante executado nesta sessão**. Para concluir a migração:
1. Executar `python scripts/check_lazarus_project.py`.
2. Compilar com Lazarus 4.4 e FPC 3.2.2.
3. Testar iniciar/parar reconhecimento, comando com palavra de ativação, saída de fala e fechamento de formulários.
4. Compilar instalador e confirmar ausência dos servidores legados.
5. Pesquisar referências obsoletas em documentação histórica e artefatos pré-compilados antes de nova release.

Este documento registra alteração de código, não uma aprovação de release.
