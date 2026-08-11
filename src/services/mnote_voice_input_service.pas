unit mnote_voice_input_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, aiaudio, aispeechrecognizer, aiwhisperengine;

type
  TMNoteVoiceTextEvent = procedure(Sender: TObject; const AText: string) of object;
  TMNoteVoiceErrorEvent = procedure(Sender: TObject; const AError: string) of object;

  { TMNoteVoiceInputService }

  TMNoteVoiceInputService = class(TComponent)
  private
    FAudio: TAIAudioInput;
    FRecognizer: TAISpeechRecognizer;
    FEngine: TAIWhisperProcessEngine;
    FLastError: string;
    FLastText: string;
    FOnText: TMNoteVoiceTextEvent;
    FOnError: TMNoteVoiceErrorEvent;
    procedure RecognizerText(Sender: TObject; const AText: string);
    procedure RecognizerError(Sender: TObject; const AText: string);
    procedure ApplyEnvironmentConfiguration;
    function DefaultCaptureFile: string;
  public
    constructor Create(AOwner: TComponent); override;
    function Available(out AReason: string): Boolean;
    function StartListening: Boolean;
    function StopListening: Boolean;
    procedure Cancel;
    property LastError: string read FLastError;
    property LastText: string read FLastText;
    property Recognizer: TAISpeechRecognizer read FRecognizer;
    property Engine: TAIWhisperProcessEngine read FEngine;
    property Audio: TAIAudioInput read FAudio;
    property OnText: TMNoteVoiceTextEvent read FOnText write FOnText;
    property OnError: TMNoteVoiceErrorEvent read FOnError write FOnError;
  end;

implementation

constructor TMNoteVoiceInputService.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAudio := TAIAudioInput.Create(Self);
  FAudio.InputSource := asMic;
  FAudio.SampleRate := 16000;
  FAudio.Channels := 1;

  FEngine := TAIWhisperProcessEngine.Create(Self);
  FRecognizer := TAISpeechRecognizer.Create(Self);
  FRecognizer.Engine := FEngine;
  FRecognizer.AudioInput := FAudio;
  FRecognizer.Language := 'pt';
  FRecognizer.Continuous := False;
  FRecognizer.OnText := @RecognizerText;
  FRecognizer.OnError := @RecognizerError;
  ApplyEnvironmentConfiguration;
end;

procedure TMNoteVoiceInputService.ApplyEnvironmentConfiguration;
var
  Value: string;
begin
  FEngine.ExecutablePath := Trim(GetEnvironmentVariable('WHISPER_CLI'));
  FEngine.ModelPath := Trim(GetEnvironmentVariable('WHISPER_MODEL'));
  FRecognizer.ModelPath := FEngine.ModelPath;

  Value := Trim(GetEnvironmentVariable('WHISPER_LANGUAGE'));
  if Value <> '' then FRecognizer.Language := Value;

  Value := Trim(GetEnvironmentVariable('WHISPER_THREADS'));
  if Value <> '' then FRecognizer.Threads := StrToIntDef(Value, 0);

  Value := LowerCase(Trim(GetEnvironmentVariable('WHISPER_GPU')));
  FRecognizer.UseGPU := (Value = '1') or (Value = 'true') or (Value = 'yes');
end;

function TMNoteVoiceInputService.DefaultCaptureFile: string;
var
  Folder: string;
begin
  Folder := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'mnote2';
  ForceDirectories(Folder);
  Result := IncludeTrailingPathDelimiter(Folder) + 'voice_input.wav';
end;

function TMNoteVoiceInputService.Available(out AReason: string): Boolean;
begin
  ApplyEnvironmentConfiguration;
  AReason := '';
  Result := FEngine.ValidateExecutable(AReason);
  if Result then Result := FEngine.ValidateModel(AReason);
  if not Result then FLastError := AReason;
end;

function TMNoteVoiceInputService.StartListening: Boolean;
var
  Reason: string;
begin
  FLastError := '';
  FLastText := '';
  if not Available(Reason) then
  begin
    FLastError := Reason;
    Exit(False);
  end;
  Result := FRecognizer.StartListening(DefaultCaptureFile);
  if not Result then FLastError := FRecognizer.LastError;
end;

function TMNoteVoiceInputService.StopListening: Boolean;
begin
  FLastError := '';
  Result := FRecognizer.StopListening;
  FLastText := FRecognizer.LastText;
  if not Result then FLastError := FRecognizer.LastError;
end;

procedure TMNoteVoiceInputService.Cancel;
begin
  FRecognizer.Cancel;
end;

procedure TMNoteVoiceInputService.RecognizerText(Sender: TObject;
  const AText: string);
begin
  FLastText := Trim(AText);
  if Assigned(FOnText) then FOnText(Self, FLastText);
end;

procedure TMNoteVoiceInputService.RecognizerError(Sender: TObject;
  const AText: string);
begin
  FLastError := AText;
  if Assigned(FOnError) then FOnError(Self, AText);
end;

end.
