unit mnote_ssl_loader;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fphttpclient, opensslsockets;

function InitializeMNoteSSL(out AError: string): Boolean;
function MNoteSSLLoadedDescription: string;
function IsMNoteSSLLoaded: Boolean;
function GetMNoteSSLLastError: string;
function PerformSSLCheckCLI(out AOutput: string): Boolean;

implementation

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ENDIF}
  funcoes;

var
  GSSLLoaded: Boolean = False;
  GSSLLoadAttempted: Boolean = False;
  GSSLDescription: string = '';
  GSSLLastError: string = '';
  GSSLWinErrorCode: DWORD = 0;

{$IFDEF WINDOWS}
function SetDllDirectoryW(lpPathName: PWideChar): BOOL; stdcall; external 'kernel32.dll' name 'SetDllDirectoryW';
{$ENDIF}

function DiagnoseLoadLibraryError(const ADLLPath, ADLLName: string; AErrorCode: DWORD): string;
begin
  case AErrorCode of
    126:
      Result := 'Dependência ausente ou DLL não encontrada: ' + ADLLName +
        ' (Erro 126: ' + SysErrorMessage(126) + ')';
    127:
      Result := 'Função ou versão incompatível na DLL: ' + ADLLName +
        ' (Erro 127: ' + SysErrorMessage(127) + ')';
    193:
      Result := 'A DLL encontrada não é compatível com o MNote2 de 32 bits. Utilize uma versão OpenSSL x86.';
  else
    Result := 'Erro ao carregar ' + ADLLName + ' (Erro ' + IntToStr(AErrorCode) +
      ': ' + SysErrorMessage(AErrorCode) + ')';
  end;
end;

function TryLoadDLLPair(const AAppFolder, ASSLDLL, ACryptoDLL: string; out AError: string): Boolean;
{$IFDEF WINDOWS}
var
  CryptoPath, SSLPath: string;
  HCrypto, HSSL: HMODULE;
  ErrCode: DWORD;
{$ENDIF}
begin
  AError := '';
  GSSLWinErrorCode := 0;
{$IFDEF WINDOWS}
  CryptoPath := AAppFolder + ACryptoDLL;
  SSLPath := AAppFolder + ASSLDLL;

  if not FileExists(CryptoPath) then
  begin
    AError := 'Arquivo não encontrado: ' + CryptoPath;
    Exit(False);
  end;
  if not FileExists(SSLPath) then
  begin
    AError := 'Arquivo não encontrado: ' + SSLPath;
    Exit(False);
  end;

  HCrypto := LoadLibraryW(PWideChar(UnicodeString(CryptoPath)));
  if HCrypto = 0 then
  begin
    ErrCode := GetLastError;
    GSSLWinErrorCode := ErrCode;
    AError := DiagnoseLoadLibraryError(CryptoPath, ACryptoDLL, ErrCode);
    Exit(False);
  end;

  HSSL := LoadLibraryW(PWideChar(UnicodeString(SSLPath)));
  if HSSL = 0 then
  begin
    ErrCode := GetLastError;
    GSSLWinErrorCode := ErrCode;
    AError := DiagnoseLoadLibraryError(SSLPath, ASSLDLL, ErrCode);
    FreeLibrary(HCrypto);
    Exit(False);
  end;

  Result := True;
{$ELSE}
  Result := True;
{$ENDIF}
end;

function InitializeMNoteSSL(out AError: string): Boolean;
var
  AppFolder: string;
  BitnessMsg: string;
begin
  AError := '';
  if GSSLLoadAttempted then
  begin
    AError := GSSLLastError;
    Exit(GSSLLoaded);
  end;

  GSSLLoadAttempted := True;
  AppFolder := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

{$IFDEF CPU32}
  BitnessMsg := '32 bits';
{$ELSE}
  BitnessMsg := '64 bits';
{$ENDIF}

{$IFDEF WINDOWS}
  SetDllDirectoryW(PWideChar(UnicodeString(AppFolder)));
{$ENDIF}

  // Tentar par primário: libssl-1_1.dll e libcrypto-1_1.dll
  if TryLoadDLLPair(AppFolder, 'libssl-1_1.dll', 'libcrypto-1_1.dll', AError) then
  begin
    GSSLLoaded := True;
    GSSLDescription := 'libssl-1_1.dll + libcrypto-1_1.dll';
    GSSLLastError := '';
    RegistraEventosLog('SSL [OK]: ' + GSSLDescription + ' (Pasta: ' + AppFolder + ', Arq: ' + BitnessMsg + ')');
    Exit(True);
  end;

  // Tentar par fallback: ssleay32.dll e libeay32.dll
  if TryLoadDLLPair(AppFolder, 'ssleay32.dll', 'libeay32.dll', AError) then
  begin
    GSSLLoaded := True;
    GSSLDescription := 'ssleay32.dll + libeay32.dll';
    GSSLLastError := '';
    RegistraEventosLog('SSL [OK]: ' + GSSLDescription + ' (Pasta: ' + AppFolder + ', Arq: ' + BitnessMsg + ')');
    Exit(True);
  end;

  GSSLLoaded := False;
  GSSLDescription := '';
  GSSLLastError := AError;
  RegistraEventosLog('SSL [ERRO]: ' + AError + ' (Pasta: ' + AppFolder + ', Arq: ' + BitnessMsg + ')');
  Exit(False);
end;

function MNoteSSLLoadedDescription: string;
begin
  Result := GSSLDescription;
end;

function IsMNoteSSLLoaded: Boolean;
begin
  Result := GSSLLoaded;
end;

function GetMNoteSSLLastError: string;
begin
  Result := GSSLLastError;
end;

function PerformSSLCheckCLI(out AOutput: string): Boolean;
var
  SSLErr, AppFolder, BitnessMsg, TestURL, Resp: string;
  Client: TFPHTTPClient;
  SSLOK, HTTPSOK: Boolean;
  StatusCode: Integer;
begin
  AppFolder := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
{$IFDEF CPU32}
  BitnessMsg := '32 bits';
{$ELSE}
  BitnessMsg := '64 bits';
{$ENDIF}

  SSLOK := InitializeMNoteSSL(SSLErr);

  AOutput := 'Aplicação: ' + BitnessMsg + sLineBreak;
  AOutput := AOutput + 'Pasta: ' + AppFolder + sLineBreak;

  if SSLOK then
  begin
    AOutput := AOutput + 'SSL: ' + GSSLDescription + sLineBreak;
    AOutput := AOutput + 'Resultado: OK' + sLineBreak;

    // Teste real de conexão HTTPS (Tarefa 12)
    TestURL := 'https://api.github.com/';
    Client := TFPHTTPClient.Create(nil);
    try
      Client.AllowRedirect := True;
      Client.IOTimeout := 5000;
      Client.ConnectTimeout := 5000;
      Client.AddHeader('User-Agent', 'MNote2-SSLCheck/1.0');
      try
        Resp := Client.Get(TestURL);
        StatusCode := Client.ResponseStatusCode;
        if (StatusCode >= 200) and (StatusCode < 400) then
        begin
          HTTPSOK := True;
          AOutput := AOutput + 'Conexão HTTPS (' + TestURL + '): OK (HTTP Status ' +
            IntToStr(StatusCode) + ')' + sLineBreak;
        end
        else
        begin
          HTTPSOK := False;
          AOutput := AOutput + 'Conexão HTTPS (' + TestURL + '): ERRO (HTTP Status ' +
            IntToStr(StatusCode) + ')' + sLineBreak;
        end;
      except
        on E: Exception do
        begin
          HTTPSOK := False;
          AOutput := AOutput + 'Conexão HTTPS (' + TestURL + '): ERRO (Exceção: ' +
            E.Message + ')' + sLineBreak;
        end;
      end;
    finally
      Client.Free;
    end;

    Result := HTTPSOK;
  end
  else
  begin
    AOutput := AOutput + 'Resultado: ERRO' + sLineBreak;
    if GSSLWinErrorCode <> 0 then
      AOutput := AOutput + 'Código Windows: ' + IntToStr(GSSLWinErrorCode) + sLineBreak;
    AOutput := AOutput + 'Descrição: ' + SSLErr + sLineBreak;
    Result := False;
  end;
end;

end.
