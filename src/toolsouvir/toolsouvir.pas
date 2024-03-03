unit ToolsOuvir;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lNetComponents, lNet;

type

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

  public
    procedure Conectar();
    procedure Disconectar();
  end;

var
  frmToolsOuvir: TfrmToolsOuvir;

implementation

{$R *.lfm}

uses main;

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
   info : String;
begin
  //ShowMessage('Recebeu a mensagem:');

  aSocket.GetMessage(info);
  frmMNote.edChat.text := info;
  frmMNote.FazPergunta();

  //ShowMessage(info);
end;

procedure TfrmToolsOuvir.Conectar();
begin
  LTCPComponent1.Connect(edIP.text,strtoint(edPort.text));
end;

procedure TfrmToolsOuvir.Disconectar();
begin
  LTCPComponent1.Disconnect(true);
end;

end.

