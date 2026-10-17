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

## Configuração na interface

Em Configurações > Reconhecimento de voz, o usuário define o executável `whisper-cli`, arquivo do modelo Whisper, idioma, número de threads (0 = automático), uso de GPU e palavra de ativação. A tela permite **verificar o executável e o modelo**, mas ainda não executa uma gravação de microfone de teste. Ao salvar, os valores são persistidos em `mnote.cfg`, usando `WHISPERCLI`, `WHISPERMODEL`, `WHISPERLANGUAGE`, `WHISPERTHREADS`, `WHISPERGPU` e `VOICEWAKEWORD`. O serviço de entrada aplica esses valores diretamente aos componentes CHATGPT. Variáveis de ambiente são utilizadas apenas quando a configuração `FSetMain` não estiver disponível.

## Dependências e configuração
O reconhecimento exige um executável Whisper e um arquivo de modelo válidos, selecionados na própria configuração do MNote2. Os parâmetros são aplicados ao componente Whisper da biblioteca CHATGPT. A síntese usa a configuração de engine, voz, volume, taxa e modo assíncrono do MNote2.

## Validação pendente
Mudanças publicadas no código-fonte, **sem compilação ou teste de microfone/alto-falante executado nesta sessão**. Para concluir a migração:
1. Executar `python scripts/check_lazarus_project.py`.
2. Compilar com Lazarus 4.4 e FPC 3.2.2.
3. Testar iniciar/parar reconhecimento, comando com palavra de ativação, saída de fala e fechamento de formulários.
4. Compilar instalador e confirmar ausência dos servidores legados.
5. Pesquisar referências obsoletas em documentação histórica e artefatos pré-compilados antes de nova release.

Este documento registra alteração de código, não uma aprovação de release.
