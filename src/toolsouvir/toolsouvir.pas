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
    lastfrase : string;
    FWakeWord: string;
    FLastTranscript: string;
    FOnCommand: TConversationalVoiceCommandEvent;
  public
    frase : string;
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


procedure TfrmToolsOuvir.Shape1ChangeBounds(Sender: TObject);
begin

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
  aSocket.GetMessage(info);
  info := Trim(info);
  if info = '' then Exit;
  if SameText(lastfrase, info) then Exit;
  lastfrase := info;
  FLastTranscript := info;
  if TMNoteVoiceCommand.TryParse(info, FWakeWord, CommandText) then
  begin
    if Assigned(FOnCommand) then FOnCommand(Self, CommandText);
  end;
end;

procedure TfrmToolsOuvir.Conectar();
begin
  if FWakeWord = '' then FWakeWord := 'OK MNote';
  LTCPComponent1.Connect(edIP.text,strtoint(edPort.text));
end;

procedure TfrmToolsOuvir.Disconectar();
begin
  LTCPComponent1.Disconnect(true);
end;

end.

