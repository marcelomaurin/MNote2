unit ToolsOuvir;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lNetComponents, lNet, strutils, mnote_voice_command;

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
    function ValidateConnection(out AHost: string; out APort: Word;
      out AError: string): Boolean;
    procedure SetConnectedVisual(AConnected: Boolean);
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

procedure TfrmToolsOuvir.Shape1ChangeBounds(Sender: TObject);
begin
  { Mantém o indicador visual coerente quando o formulário é recriado pelo LCL. }
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
  info, CommandText: String;
begin
  info := '';
  if aSocket = nil then Exit;
  aSocket.GetMessage(info);
  info := Trim(info);
  if info = '' then Exit;
  if SameText(lastfrase, info) then Exit;

  lastfrase := info;
  frase := info;
  FLastTranscript := info;

  if TMNoteVoiceCommand.TryParse(info, FWakeWord, CommandText) then
  begin
    if Assigned(FOnCommand) then
      FOnCommand(Self, CommandText);
  end;
end;

procedure TfrmToolsOuvir.Conectar();
var
  Host, ErrorText: string;
  Port: Word;
begin
  if FWakeWord = '' then FWakeWord := 'OK MNote';
  if not ValidateConnection(Host, Port, ErrorText) then
  begin
    ShowMessage(ErrorText);
    SetConnectedVisual(False);
    Exit;
  end;

  try
    LTCPComponent1.Connect(Host, Port);
    lastfrase := '';
    FLastTranscript := '';
    SetConnectedVisual(True);
  except
    on E: Exception do
    begin
      SetConnectedVisual(False);
      ShowMessage('Não foi possível conectar ao reconhecimento de voz: ' +
        E.Message);
    end;
  end;
end;

procedure TfrmToolsOuvir.Disconectar();
begin
  try
    LTCPComponent1.Disconnect(True);
  finally
    SetConnectedVisual(False);
  end;
end;

end.
