unit registro;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  lNetComponents, lNet, IdHTTP, IdSSLOpenSSL, IdSSLOpenSSLHeaders, IdSSL,
  IdCompressionIntercept, fphttpclient, opensslsockets, funcoes;

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
    function ExecutaRequisicaoHTTPS(const AURL: string; out AResposta: string): boolean;
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

function TfrmRegistrar.ExecutaRequisicaoHTTPS(const AURL: string; out AResposta: string): boolean;
var
  HTTPClient: TFPHttpClient;
  appPath: string;
begin
  Result := False;
  AResposta := '';
  RegistraEventosLog('HTTPS Req: Iniciando conexao -> ' + AURL);

  // 1ª Tentativa: TFPHttpClient nativo do FPC
  try
    HTTPClient := TFPHttpClient.Create(nil);
    try
      HTTPClient.AllowRedirect := True;
      HTTPClient.IOTimeout := 5000;
      AResposta := HTTPClient.Get(AURL);
      Result := True;
      RegistraEventosLog('HTTPS Req [OK]: Sucesso via TFPHttpClient (FPC)');
      Exit;
    finally
      HTTPClient.Free;
    end;
  except
    on E: Exception do
      RegistraEventosLog('HTTPS Req [AVISO]: TFPHttpClient falhou: ' + E.Message + '. Tentando via Indy...');
  end;

  // 2ª Tentativa: Indy TIdHTTP com OpenSSL
  try
    appPath := ExtractFilePath(ParamStr(0));
    {$IFDEF MSWINDOWS}
    IdOpenSSLSetLibPath(appPath);
    {$ENDIF}
    {$IFDEF LINUX}
    if DirectoryExists('/usr/lib/x86_64-linux-gnu') then
      IdOpenSSLSetLibPath('/usr/lib/x86_64-linux-gnu');
    {$ENDIF}

    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Method := sslvTLSv1_2;
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.SSLVersions := [sslvTLSv1_2];
    IdSSLIOHandlerSocketOpenSSL1.SSLOptions.Mode := sslmUnassigned;
    IdHTTP1.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
    IdHTTP1.ConnectTimeout := 5000;
    IdHTTP1.ReadTimeout := 5000;

    AResposta := IdHTTP1.Get(AURL);
    Result := True;
    RegistraEventosLog('HTTPS Req [OK]: Sucesso via TIdHTTP (Indy)');
  except
    on E: Exception do
    begin
      Result := False;
      RegistraEventosLog('HTTPS Req [ERRO]: Ambos clientes falharam. Erro Indy: ' + E.Message);
    end;
  end;
end;

procedure TfrmRegistrar.Button1Click(Sender: TObject);
begin
  if (edNome.text <> '') and (edEmail.text <> '') then
  begin
       if (pos('@', edEmail.text)<> 0) then
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
  registrou := False;
end;

procedure TfrmRegistrar.FormShow(Sender: TObject);
begin

end;

procedure TfrmRegistrar.LTCPComponent1Accept(aSocket: TLSocket);
begin

end;

procedure TfrmRegistrar.LTCPComponent1Connect(aSocket: TLSocket);
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
end;

procedure TfrmRegistrar.Memo1Change(Sender: TObject);
begin

end;

procedure TfrmRegistrar.registrar();
var
  url: string;
  resposta: string;
begin
  RegistraEventosLog('Registro: Iniciando processo de registro para Nome=' + edNome.Text + ', Email=' + edEmail.Text);
  url := 'https://maurinsoft.com.br/ws/register/register.php?nome=' +
         edNome.Text + '&email=' + edEmail.Text;
  if ExecutaRequisicaoHTTPS(url, resposta) then
  begin
    registrou := True;
    RegistraEventosLog('Registro [OK]: Dados registrados com sucesso.');
  end
  else
    RegistraEventosLog('Registro [ERRO]: Falha ao enviar dados de registro.');
end;

procedure TfrmRegistrar.Identifica();
var
  resposta: string;
begin
  RegistraEventosLog('Identifica: Solicitando confirmacao de conexao (iconnected.php)');
  if ExecutaRequisicaoHTTPS('https://maurinsoft.com.br/ws/register/iconnected.php', resposta) then
    RegistraEventosLog('Identifica [OK]: Resposta recebida da maurinsoft.')
  else
    RegistraEventosLog('Identifica [AVISO]: Nao foi possivel conectar ao servidor de registro.');
end;

end.
