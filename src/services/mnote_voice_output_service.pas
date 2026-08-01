unit mnote_voice_output_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, aivoicesynthesizer;

type
  { TMNoteVoiceOutputService }

  TMNoteVoiceOutputService = class
  private
    FSynthesizer: TAIVoiceSynthesizer;
    FLastError: string;
    function EngineFromIndex(AIndex: Integer): TSpeechEngine;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ApplyConfiguration;
    function Speak(const AText: string; AForce: Boolean = False): Boolean;
    function GetAvailableVoices(AEngineIndex: Integer; AList: TStrings): Boolean;
    property LastError: string read FLastError;
    property Synthesizer: TAIVoiceSynthesizer read FSynthesizer;
  end;

function MNoteVoiceOutput: TMNoteVoiceOutputService;
procedure FinalizeMNoteVoiceOutput;

implementation

uses
  setmain;

var
  FVoiceOutputService: TMNoteVoiceOutputService = nil;

constructor TMNoteVoiceOutputService.Create;
begin
  inherited Create;
  FSynthesizer := TAIVoiceSynthesizer.Create(nil);
  FLastError := '';
end;

destructor TMNoteVoiceOutputService.Destroy;
begin
  FSynthesizer.Free;
  inherited Destroy;
end;

function TMNoteVoiceOutputService.EngineFromIndex(
  AIndex: Integer): TSpeechEngine;
begin
  case AIndex of
    1: Result := seSAPI;
    2: Result := seEspeak;
    else Result := seSystemDefault;
  end;
end;

procedure TMNoteVoiceOutputService.ApplyConfiguration;
begin
  if FSetMain = nil then Exit;
  FSynthesizer.Engine := EngineFromIndex(FSetMain.VoiceOutputEngine);
  FSynthesizer.VoiceName := FSetMain.VoiceOutputName;
  FSynthesizer.Volume := FSetMain.VoiceOutputVolume;
  FSynthesizer.Rate := FSetMain.VoiceOutputRate;
  FSynthesizer.Asynchronous := FSetMain.VoiceOutputAsync;
end;

function TMNoteVoiceOutputService.Speak(const AText: string;
  AForce: Boolean): Boolean;
begin
  Result := False;
  FLastError := '';
  if Trim(AText) = '' then
  begin
    FLastError := 'Não há texto para sintetizar.';
    Exit;
  end;
  if FSetMain = nil then
  begin
    FLastError := 'A configuração do MNote2 ainda não foi carregada.';
    Exit;
  end;
  if (not AForce) and (not FSetMain.VoiceOutputEnabled) then Exit(True);
  ApplyConfiguration;
  FSynthesizer.Say(AText);
  FLastError := FSynthesizer.LastError;
  Result := FLastError = '';
end;

function TMNoteVoiceOutputService.GetAvailableVoices(AEngineIndex: Integer;
  AList: TStrings): Boolean;
begin
  Result := False;
  FLastError := '';
  if AList = nil then
  begin
    FLastError := 'A lista de vozes não foi informada.';
    Exit;
  end;
  FSynthesizer.Engine := EngineFromIndex(AEngineIndex);
  FSynthesizer.GetAvailableVoices(AList);
  FLastError := FSynthesizer.LastError;
  Result := FLastError = '';
end;

function MNoteVoiceOutput: TMNoteVoiceOutputService;
begin
  if FVoiceOutputService = nil then
    FVoiceOutputService := TMNoteVoiceOutputService.Create;
  Result := FVoiceOutputService;
end;

procedure FinalizeMNoteVoiceOutput;
begin
  FreeAndNil(FVoiceOutputService);
end;

finalization
  FinalizeMNoteVoiceOutput;

end.
