unit registro;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lNetComponents, lNet, IdHTTP, IdSSLOpenSSL, IdSSLOpenSSLHeaders, IdSSL,
  IdCompressionIntercept;

type

  { TfrmRegistrar }

  TfrmRegistrar = class(TForm)
    Button1: TButton;
    edNome: TEdit;
    edEmail: TEdit;
    IdCompressionIntercept1: TIdCompressionIntercept;
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
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
  //frmlog.RegistraLog('Recebeu retorno do socket:'+copy(retorno,1,10));
end;

procedure TfrmRegistrar.Memo1Change(Sender: TObject);
begin

end;

procedure TfrmRegistrar.registrar();
begin

end;

procedure TfrmRegistrar.Identifica();
var
  resposta : string;
begin
  {$IFDEF MSWINDOWS}
  //IdOpenSSLSetLibSSL(ExtractFilePath(ParamStr(0)) + 'libssl-1_0-x64.dll');
  //IdOpenSSLSetLibCrypto(ExtractFilePath(ParamStr(0)) + 'libcrypto-1_0-x64.dll');
  {$ENDIF}
  {$IFDEF LINUX}
  IdOpenSSLSetLibSSL('/usr/lib/x86_64-linux-gnu/libssl.so.1.0.0');
  IdOpenSSLSetLibCrypto('/usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0');
  {$ENDIF}

  try
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvTLSv1_2;
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode   := sslmUnassigned;

    IdHTTP1.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
    resposta := IdHTTP1.Get('https://maurinsoft.com.br/ws/register/iconnected.php');
    //ShowMessage(resposta);
  except
    on E: Exception do
      ShowMessage('Erro ao conectar: ' + E.Message);
  end;
end;

end.

