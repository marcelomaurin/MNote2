unit toolsfalar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, lNetComponents, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, AdvLed, lNet, setmain;

type

  { TfrmToolsfalar }

  TfrmToolsfalar = class(TForm)
    AdvLed1: TAdvLed;
    btFalar: TButton;
    btConect: TButton;
    btDisconect: TButton;
    edIP: TEdit;
    edFalar: TEdit;
    edPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LTCPComponent1: TLTCPComponent;
    Shape1: TShape;
    procedure btConectClick(Sender: TObject);
    procedure btDisconectClick(Sender: TObject);
    procedure btFalarClick(Sender: TObject);
    procedure edFalarKeyPress(Sender: TObject; var Key: char);
    procedure edPortChange(Sender: TObject);
    procedure LTCPComponent1Accept(aSocket: TLSocket);
    procedure LTCPComponent1Connect(aSocket: TLSocket);
    procedure LTCPComponent1Disconnect(aSocket: TLSocket);
    procedure LTCPComponent1Error(const msg: string; aSocket: TLSocket);
    procedure LTCPComponent1Receive(aSocket: TLSocket);
  private
    procedure SetReady(AReady: Boolean);
    function ValidateSocket(out AHost: string; out APort: Word;
      out AError: string): Boolean;
  public
    procedure Falar();
    procedure Falar(Texto: string);
    procedure Conectar();
    procedure Disconectar();
  end;

var
  frmToolsfalar: TfrmToolsfalar;

implementation

{$R *.lfm}

uses
  mnote_voice_output_service;

procedure TfrmToolsfalar.SetReady(AReady: Boolean);
begin
  AdvLed1.Blink := False;
  if AReady then
  begin
    AdvLed1.State := lsOn;
    Shape1.Brush.Color := clGreen;
  end
  else
  begin
    AdvLed1.State := lsOff;
    Shape1.Brush.Color := clRed;
  end;
end;

function TfrmToolsfalar.ValidateSocket(out AHost: string; out APort: Word;
  out AError: string): Boolean;
var
  PortValue: Integer;
begin
  AHost := Trim(edIP.Text);
  APort := 0;
  AError := '';
  if AHost = '' then
  begin
    AError := 'Informe o endereço do servidor.';
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

procedure TfrmToolsfalar.btConectClick(Sender: TObject);
begin
  Conectar();
end;

procedure TfrmToolsfalar.btDisconectClick(Sender: TObject);
begin
  Disconectar();
end;

procedure TfrmToolsfalar.btFalarClick(Sender: TObject);
begin
  Falar();
end;

procedure TfrmToolsfalar.edFalarKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Falar();
  end;
end;

procedure TfrmToolsfalar.edPortChange(Sender: TObject);
begin
  { Evento mantido para compatibilidade com o formulário antigo. }
end;

procedure TfrmToolsfalar.LTCPComponent1Accept(aSocket: TLSocket);
begin
  SetReady(True);
end;

procedure TfrmToolsfalar.LTCPComponent1Connect(aSocket: TLSocket);
begin
  SetReady(True);
end;

procedure TfrmToolsfalar.LTCPComponent1Disconnect(aSocket: TLSocket);
begin
  SetReady(False);
end;

procedure TfrmToolsfalar.LTCPComponent1Error(const msg: string; aSocket: TLSocket);
begin
  SetReady(False);
  if Trim(msg) <> '' then
    ShowMessage('Erro de conexão: ' + msg);
end;

procedure TfrmToolsfalar.LTCPComponent1Receive(aSocket: TLSocket);
var
  info: String;
begin
  info := '';
  if aSocket <> nil then
    aSocket.GetMessage(info);
end;

procedure TfrmToolsfalar.Falar();
var
  Texto: string;
begin
  Texto := Trim(edFalar.Text);
  if Texto = '' then
  begin
    ShowMessage('Informe o texto que será sintetizado.');
    Exit;
  end;

  { Caminho principal: componente TAIVoiceSynthesizer do projeto CHATGPT,
    encapsulado pelo serviço do MNote2. O socket legado não é necessário
    para sintetizar voz. }
  if MNoteVoiceOutput.Speak(Texto, True) then
    SetReady(True)
  else
  begin
    SetReady(False);
    ShowMessage('Não foi possível falar a resposta: ' +
      MNoteVoiceOutput.LastError);
  end;
end;

procedure TfrmToolsfalar.Falar(Texto: string);
begin
  edFalar.Text := Texto;
  Falar();
end;

procedure TfrmToolsfalar.Conectar();
var
  Host, ErrorText: string;
  Port: Word;
begin
  { Conexão mantida apenas por retrocompatibilidade com instalações que ainda
    usam o serviço TCP antigo. A síntese local usa CHATGPT/TAIVoiceSynthesizer. }
  if not ValidateSocket(Host, Port, ErrorText) then
  begin
    ShowMessage(ErrorText);
    SetReady(False);
    Exit;
  end;
  try
    LTCPComponent1.Connect(Host, Port);
  except
    on E: Exception do
    begin
      SetReady(False);
      ShowMessage('Não foi possível conectar: ' + E.Message);
    end;
  end;
end;

procedure TfrmToolsfalar.Disconectar();
begin
  try
    LTCPComponent1.Disconnect(True);
  finally
    SetReady(False);
  end;
end;

end.
