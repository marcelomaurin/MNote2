unit ToolsOuvir;

{$mode ObjFPC}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lNetComponents, lNet, strutils, mnote_voice_command,
  mnote_voice_input_service;

type
  TConversationalVoiceCommandEvent = procedure(Sender: TObject;
    const ACommand: string) of object;

  { TfrmToolsOuvir }

  TfrmToolsOuvir = class(TForm)
    btConect: TButton;
    btDisconect: TButton;
    edIP: TEdit;
    edPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    LTCPComponent1: TLTCPComponent;
    Shape1: TShape;
    procedure btConectClick(Sender: TObject);
    procedure btDisconectClick(Sender: TObject);
    procedure LTCPComponent1Receive(aSocket: TLSocket);
    procedure Shape1ChangeBounds(Sender: TObject);
  private
    lastfrase: string;
    FWakeWord: string;
    FLastTranscript: string;
    FOnCommand: TConversationalVoiceCommandEvent;
    FVoiceService: TMNoteVoiceInputService;
    FUsingNativeVoice: Boolean;
    function ValidateConnection(out AHost: string; out APort: Word;
      out AError: string): Boolean;
    procedure SetConnectedVisual(AConnected: Boolean);
    procedure ProcessTranscript(const AText: string);
    procedure VoiceText(Sender: TObject; const AText: string);
    procedure VoiceError(Sender: TObject; const AError: string);
    function StartNativeVoice(out AReason: string): Boolean;
  public
    frase: string;
    procedure Conectar();
    procedure Disconectar();
    property WakeWord: string read FWakeWord write FWakeWord;
    property LastTranscript: string read FLastTranscript;
    property OnCommand: TConversationalVoiceCommandEvent read FOnCommand
      write FOnCommand;
  end;

var
  frmToolsOuvir: TfrmToolsOuvir;

implementation

{$R *.lfm}

{ TfrmToolsOuvir }

function TfrmToolsOuvir.ValidateConnection(out AHost: string; out APort: Word;
  out AError: string): Boolean;
var
  PortValue: Integer;
begin
  AHost := Trim(edIP.Text);
  APort := 0;
  AError := '';

  if AHost = '' then
  begin
    AError := 'Informe o endereço do servidor de reconhecimento.';
    Exit(False);
  end;

  if (not TryStrToInt(Trim(edPort.Text), PortValue)) or
     (PortValue < 1) or (PortValue > 65535) then
  begin
    AError := 'Informe uma porta válida entre 1 e 65535.';
    Exit(False);
  end;

  APort := Word(PortValue);
  Result := True;
end;

procedure TfrmToolsOuvir.SetConnectedVisual(AConnected: Boolean);
begin
  btConect.Enabled := not AConnected;
  btDisconect.Enabled := AConnected;
  edIP.Enabled := not AConnected;
  edPort.Enabled := not AConnected;
  if AConnected then
    Shape1.Brush.Color := clGreen
  else
    Shape1.Brush.Color := clRed;
end;

procedure TfrmToolsOuvir.ProcessTranscript(const AText: string);
var
  Info, CommandText: string;
begin
  Info := Trim(AText);
  if Info = '' then Exit;
  if SameText(lastfrase, Info) then Exit;

  lastfrase := Info;
  frase := Info;
  FLastTranscript := Info;

  if TMNoteVoiceCommand.TryParse(Info, FWakeWord, CommandText) then
    if Assigned(FOnCommand) then
      FOnCommand(Self, CommandText);
end;

procedure TfrmToolsOuvir.VoiceText(Sender: TObject; const AText: string);
begin
  ProcessTranscript(AText);
end;

procedure TfrmToolsOuvir.VoiceError(Sender: TObject; const AError: string);
begin
  if Trim(AError) <> '' then
    ShowMessage('Reconhecimento de voz: ' + AError);
end;

function TfrmToolsOuvir.StartNativeVoice(out AReason: string): Boolean;
begin
  AReason := '';
  if FVoiceService = nil then
  begin
    FVoiceService := TMNoteVoiceInputService.Create(Self);
    FVoiceService.OnText := @VoiceText;
    FVoiceService.OnError := @VoiceError;
  end;

  if not FVoiceService.Available(AReason) then Exit(False);
  Result := FVoiceService.StartListening;
  if not Result then AReason := FVoiceService.LastError;
end;

procedure TfrmToolsOuvir.Shape1ChangeBounds(Sender: TObject);
begin
  if not btConect.Enabled then
    Shape1.Brush.Color := clGreen
  else
    Shape1.Brush.Color := clRed;
end;

procedure TfrmToolsOuvir.btConectClick(Sender: TObject);
begin
  Conectar();
end;

procedure TfrmToolsOuvir.btDisconectClick(Sender: TObject);
begin
  Disconectar();
end;

procedure TfrmToolsOuvir.LTCPComponent1Receive(aSocket: TLSocket);
var
  Info: string;
begin
  Info := '';
  if aSocket = nil then Exit;
  aSocket.GetMessage(Info);
  ProcessTranscript(Info);
end;

procedure TfrmToolsOuvir.Conectar();
var
  Host, ErrorText, NativeReason: string;
  Port: Word;
begin
  if FWakeWord = '' then FWakeWord := 'OK MNote';
  lastfrase := '';
  FLastTranscript := '';

  { Primeiro tenta o reconhecimento local do pacote CHATGPT. A configuração
    segue o padrão dos samples do pacote: WHISPER_CLI e WHISPER_MODEL. }
  if StartNativeVoice(NativeReason) then
  begin
    FUsingNativeVoice := True;
    SetConnectedVisual(True);
    Exit;
  end;

  { Retrocompatibilidade: se Whisper ainda não estiver configurado, mantém
    o servidor TCP antigo disponível. }
  FUsingNativeVoice := False;
  if not ValidateConnection(Host, Port, ErrorText) then
  begin
    if NativeReason <> '' then
      ErrorText := NativeReason + LineEnding + LineEnding +
        'Fallback TCP: ' + ErrorText;
    ShowMessage(ErrorText);
    SetConnectedVisual(False);
    Exit;
  end;

  try
    LTCPComponent1.Connect(Host, Port);
    SetConnectedVisual(True);
  except
    on E: Exception do
    begin
      SetConnectedVisual(False);
      ShowMessage('Reconhecimento local indisponível: ' + NativeReason +
        LineEnding + 'Fallback TCP falhou: ' + E.Message);
    end;
  end;
end;

procedure TfrmToolsOuvir.Disconectar();
begin
  try
    if FUsingNativeVoice then
    begin
      if (FVoiceService <> nil) and FVoiceService.Recognizer.Busy then
      begin
        if not FVoiceService.StopListening then
          ShowMessage('Não foi possível concluir o reconhecimento: ' +
            FVoiceService.LastError)
        else
          ProcessTranscript(FVoiceService.LastText);
      end;
    end
    else
      LTCPComponent1.Disconnect(True);
  finally
    FUsingNativeVoice := False;
    SetConnectedVisual(False);
  end;
end;

end.
