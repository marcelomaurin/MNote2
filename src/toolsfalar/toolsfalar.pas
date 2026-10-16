unit toolsfalar;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  AdvLed, aivoicesynthesizer, mnote_voice_output_service;

type

  { TfrmToolsfalar }

  TfrmToolsfalar = class(TForm)
    AdvLed1: TAdvLed;
    btConfig: TButton;
    btFalar: TButton;
    btParar: TButton;
    edFalar: TEdit;
    Label3: TLabel;
    lbStatus: TLabel;
    Shape1: TShape;
    procedure btConfigClick(Sender: TObject);
    procedure btFalarClick(Sender: TObject);
    procedure btPararClick(Sender: TObject);
    procedure edFalarKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
  private
    procedure SetReady(AReady: Boolean);
    procedure UpdateStatus(const AMsg: string);
  public
    procedure Falar();
    procedure Falar(Texto: string);
    procedure Parar();
    procedure Conectar();
    procedure Disconectar();
  end;

var
  frmToolsfalar: TfrmToolsfalar;

implementation

{$R *.lfm}

uses
  voice_output_config;

procedure TfrmToolsfalar.FormCreate(Sender: TObject);
begin
  SetReady(True);
  UpdateStatus('Pronto para sintetizar voz (TAIVoiceSynthesizer)');
end;

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

procedure TfrmToolsfalar.UpdateStatus(const AMsg: string);
begin
  if lbStatus <> nil then
    lbStatus.Caption := AMsg;
end;

procedure TfrmToolsfalar.btConfigClick(Sender: TObject);
var
  Frm: TfrmVoiceOutputConfig;
begin
  Frm := TfrmVoiceOutputConfig.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TfrmToolsfalar.btFalarClick(Sender: TObject);
begin
  Falar();
end;

procedure TfrmToolsfalar.btPararClick(Sender: TObject);
begin
  Parar();
end;

procedure TfrmToolsfalar.edFalarKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Falar();
  end;
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

  UpdateStatus('Sintetizando áudio...');
  SetReady(True);

  if MNoteVoiceOutput.Speak(Texto, True) then
  begin
    UpdateStatus('Áudio reproduzido com sucesso.');
  end
  else
  begin
    SetReady(False);
    UpdateStatus('Erro na síntese: ' + MNoteVoiceOutput.LastError);
    ShowMessage('Não foi possível falar: ' + MNoteVoiceOutput.LastError);
  end;
end;

procedure TfrmToolsfalar.Falar(Texto: string);
begin
  edFalar.Text := Texto;
  Falar();
end;

procedure TfrmToolsfalar.Parar();
begin
  try
    if MNoteVoiceOutput.Synthesizer <> nil then
      MNoteVoiceOutput.Synthesizer.Stop;
  finally
    SetReady(True);
    UpdateStatus('Reprodução interrompida.');
  end;
end;

procedure TfrmToolsfalar.Conectar();
begin
  SetReady(True);
  UpdateStatus('Serviço de voz nativo pronto.');
end;

procedure TfrmToolsfalar.Disconectar();
begin
  Parar();
  SetReady(False);
  UpdateStatus('Serviço de voz inativo.');
end;

end.
