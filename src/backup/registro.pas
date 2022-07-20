unit registro;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  PopupNotifier, lNetComponents, lNet;

type

  { TfrmRegistrar }

  TfrmRegistrar = class(TForm)
    Button1: TButton;
    edNome: TEdit;
    edEmail: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LTCPComponent1: TLTCPComponent;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LTCPComponent1Accept(aSocket: TLSocket);
    procedure LTCPComponent1Connect(aSocket: TLSocket);
    procedure LTCPComponent1Receive(aSocket: TLSocket);
    procedure Memo1Change(Sender: TObject);
  private
    procedure registrar();
  public
    registrou : boolean;
    INFO : String;
    procedure Identifica();
  end;

var
  frmRegistrar: TfrmRegistrar;

implementation

{$R *.lfm}

{ TfrmRegistrar }

procedure TfrmRegistrar.Button1Click(Sender: TObject);
begin
  if (edNome.text <> '') and (edEmail.text <> '') then
  begin
       if (pos('@', edEmail.text)<> 0)  then
       begin
         Registrar();
         close;
       end
       else
       begin
         ShowMessage('Email não é valido!');
       end;
  end
  else
  begin
    Showmessage('Preencha os dados do registro!');
  end;
end;

procedure TfrmRegistrar.FormCreate(Sender: TObject);
begin
  INFO := '';
end;

procedure TfrmRegistrar.FormShow(Sender: TObject);
begin

end;

procedure TfrmRegistrar.LTCPComponent1Accept(aSocket: TLSocket);
begin

end;

procedure TfrmRegistrar.LTCPComponent1Connect(aSocket: TLSocket);
var
  resultado : string;
begin
  if (INFO <> '') then
  begin
    aSocket.SendMessage(INFO);
  end;
end;

procedure TfrmRegistrar.LTCPComponent1Receive(aSocket: TLSocket);
var
  retorno : string;
begin
  aSocket.GetMessage(retorno);

  //ShowMessage(retorno);
  //frmlog.Log('Recebeu retorno do socket:'+copy(retorno,1,10));
end;

procedure TfrmRegistrar.Memo1Change(Sender: TObject);
begin

end;

procedure TfrmRegistrar.registrar();
begin

end;

procedure TfrmRegistrar.Identifica();
begin
  if(LTCPComponent1.Connected) then
  begin
       LTCPComponent1.Disconnect(true);
       sleep(1000);
  end;

  INFO :=  'GET /ws/register/iconfila.php?tipo=4 HTTP/1.0'+#13+#10+
           'Connection: close'+#13+#10+
            #13+#10;


  LTCPComponent1.Connect('maurinsoft.com.br',80);
end;

end.

