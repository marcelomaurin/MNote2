unit mnote_chatgpt_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, chatgpt, setmain;

procedure ConfiguraChatGPTPorSetMain(AChat: TCHATGPT);

implementation

procedure ConfiguraChatGPTPorSetMain(AChat: TCHATGPT);
begin
  if AChat = nil then
    Exit;

  AChat.TOKEN := FSetMain.CHATGPT;
  AChat.LocalIP := FSetMain.IPLocalIA;
  AChat.MaxTokens := 4096;

  case FSetMain.Provider of
    0:
      begin
        AChat.Provider := AIP_OPENAI;
        AChat.CustomModel := FSetMain.ModelOpenAI;
      end;

    1:
      begin
        AChat.Provider := AIP_OPENROUTER;
        AChat.CustomModel := FSetMain.ModelOpenRouter;
      end;

    2:
      begin
        AChat.Provider := AIP_CEREBRAS;
        AChat.CustomModel := FSetMain.ModelCerebras;
      end;

    3:
      begin
        AChat.Provider := AIP_LOCAL;
        AChat.CustomModel := FSetMain.ModelLocal;
      end;

    4:
      begin
        AChat.Provider := AIP_GEMINI;
        { Gemini 1.5 foi encerrado em 29/09/2025. Mantemos a leitura da
          configuração antiga, migrando somente os aliases aposentados. }
        if SameText(FSetMain.ModelGemini, 'gemini-1.5-flash') or
          SameText(FSetMain.ModelGemini, 'gemini-1.5-flash-latest') or
          SameText(FSetMain.ModelGemini, 'gemini-1.5-flash-8b') then
          AChat.CustomModel := 'gemini-2.5-flash'
        else
          AChat.CustomModel := FSetMain.ModelGemini;
      end;
  else
    begin
      AChat.Provider := AIP_OPENAI;
      AChat.CustomModel := FSetMain.ModelOpenAI;
    end;
  end;
end;

end.
