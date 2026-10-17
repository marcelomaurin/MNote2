unit ToolsOuvir;
{$mode ObjFPC}{$H+}
{$codepage utf8}
interface
uses Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, mnote_voice_command, mnote_voice_input_service;
type
  TConversationalVoiceCommandEvent = procedure(Sender: TObject;
    const ACommand: string) of object;
  TfrmToolsOuvir = class(TForm)
    btConect: TButton;
    btDisconect: TButton;
    Shape1: TShape;
    procedure btConectClick(Sender: TObject);
    procedure btDisconectClick(Sender: TObject);
  private
    lastfrase: string;
    FWakeWord: string;
    FLastTranscript: string;
    FOnCommand: TConversationalVoiceCommandEvent;
    FVoiceService: TMNoteVoiceInputService;
    procedure SetConnectedVisual(AConnected: Boolean);
    procedure ProcessTranscript(const AText: string);
    procedure VoiceText(Sender: TObject; const AText: string);
    procedure VoiceError(Sender: TObject; const AError: string);
  public
    frase: string;
    procedure Conectar();
    procedure Disconectar();
    property WakeWord: string read FWakeWord write FWakeWord;
    property LastTranscript: string read FLastTranscript;
    property OnCommand: TConversationalVoiceCommandEvent read FOnCommand write FOnCommand;
  end;
var frmToolsOuvir: TfrmToolsOuvir;
implementation
{$R *.lfm}
procedure TfrmToolsOuvir.SetConnectedVisual(AConnected: Boolean);
begin
  btConect.Enabled := not AConnected;
  btDisconect.Enabled := AConnected;
  if AConnected then Shape1.Brush.Color := clGreen
  else Shape1.Brush.Color := clRed;
end;
procedure TfrmToolsOuvir.ProcessTranscript(const AText: string);
var Info, CommandText: string;
begin
  Info := Trim(AText);
  if (Info = '') or SameText(lastfrase, Info) then Exit;
  lastfrase := Info;
  frase := Info;
  FLastTranscript := Info;
  if TMNoteVoiceCommand.TryParse(Info, FWakeWord, CommandText) then
    if Assigned(FOnCommand) then FOnCommand(Self, CommandText);
end;
procedure TfrmToolsOuvir.VoiceText(Sender: TObject; const AText: string);
begin
  ProcessTranscript(AText);
end;
procedure TfrmToolsOuvir.VoiceError(Sender: TObject; const AError: string);
begin
  SetConnectedVisual(False);
  if Trim(AError) <> '' then ShowMessage('Reconhecimento de voz: ' + AError);
end;
procedure TfrmToolsOuvir.btConectClick(Sender: TObject);
begin
  Conectar();
end;
procedure TfrmToolsOuvir.btDisconectClick(Sender: TObject);
begin
  Disconectar();
end;
procedure TfrmToolsOuvir.Conectar();
var Reason: string;
begin
  if FWakeWord = '' then FWakeWord := 'OK MNote';
  lastfrase := '';
  FLastTranscript := '';
  if FVoiceService = nil then
  begin
    FVoiceService := TMNoteVoiceInputService.Create(Self);
    FVoiceService.OnText := @VoiceText;
    FVoiceService.OnError := @VoiceError;
  end;
  if not FVoiceService.Available(Reason) then
  begin
    SetConnectedVisual(False);
    ShowMessage('Reconhecimento de voz indisponível: ' + Reason);
    Exit;
  end;
  if FVoiceService.StartListening then SetConnectedVisual(True)
  else
  begin
    SetConnectedVisual(False);
    ShowMessage('Não foi possível iniciar reconhecimento: ' + FVoiceService.LastError);
  end;
end;
procedure TfrmToolsOuvir.Disconectar();
begin
  try
    if (FVoiceService <> nil) and FVoiceService.Recognizer.Busy then
      if not FVoiceService.StopListening then
        ShowMessage('Falha ao concluir reconhecimento: ' + FVoiceService.LastError)
      else
        ProcessTranscript(FVoiceService.LastText);
  finally
    SetConnectedVisual(False);
  end;
end;
end.
