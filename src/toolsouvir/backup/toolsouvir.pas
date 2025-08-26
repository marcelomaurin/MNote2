unit ToolsOuvir;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lNetComponents, lNet, strutils;

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
    lastfrase : string;
  public
    frase : string;
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
   posicao : integer;
begin
  //ShowMessage('Recebeu a mensagem:');
  info := '';
  aSocket.GetMessage(info);
  posicao := pos(frase,info);
  if(posicao<>0) then
  begin
       if(lastfrase <> info) then
       begin
         lastfrase := info;
         info := replacestr(info,frase, '');
         frmmain.NewContext();
         frmmain.pergunta := info;

         frmmain.FazPergunta();
       end;


  end;

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

