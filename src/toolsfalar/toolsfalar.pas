unit toolsfalar;
{$mode objfpc}{$H+}
{$codepage utf8}
interface
uses Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  mnote_voice_output_service;
type
  TfrmToolsfalar = class(TForm)
    btFalar: TButton;
    edFalar: TEdit;
    Shape1: TShape;
    procedure btFalarClick(Sender: TObject);
    procedure edFalarKeyPress(Sender: TObject; var Key: char);
  public
    procedure Falar(); overload;
    procedure Falar(Texto: string); overload;
    procedure Conectar();
    procedure Disconectar();
  end;
var frmToolsfalar: TfrmToolsfalar;
implementation
{$R *.lfm}
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
procedure TfrmToolsfalar.Falar();
var Texto: string;
begin
  Texto := Trim(edFalar.Text);
  if Texto = '' then
  begin
    ShowMessage('Informe o texto que será sintetizado.');
    Exit;
  end;
  if MNoteVoiceOutput.Speak(Texto, True) then
    Shape1.Brush.Color := clGreen
  else
  begin
    Shape1.Brush.Color := clRed;
    ShowMessage('Não foi possível falar a resposta: ' + MNoteVoiceOutput.LastError);
  end;
end;
procedure TfrmToolsfalar.Falar(Texto: string);
begin
  edFalar.Text := Texto;
  Falar();
end;
procedure TfrmToolsfalar.Conectar();
begin
  { Mantido para chamadas antigas: saída de voz usa componente CHATGPT local. }
  MNoteVoiceOutput.ApplyConfiguration;
end;
procedure TfrmToolsfalar.Disconectar();
begin
  { Não existe servidor externo para desconectar. }
end;
end.
