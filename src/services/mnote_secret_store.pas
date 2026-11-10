unit mnote_secret_store;

{ Proteção dos segredos gravados no mnote.cfg (chave de IA e senhas de banco).

  Windows: DPAPI (CryptProtectData), escopo do usuário atual. O valor gravado
           é 'dpapi:' + Base64 do bloco cifrado.
  Unix:    chaveiro do sistema pelo comando secret-tool (libsecret). O valor
           gravado é 'keyring:' + nome do campo; o segredo fica no chaveiro.

  Compatibilidade: um valor sem prefixo é tratado como texto puro e devolvido
  como está, para que arquivos antigos continuem funcionando. Quando o
  mecanismo de proteção não existe ou falha, ProtectSecret devolve o texto
  puro em vez de perder o segredo; SecretStoreLastError explica o motivo.

  Nenhuma rotina desta unidade registra o segredo em log ou mensagem de erro. }

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils;

const
  MNOTE_SECRET_PREFIX_DPAPI = 'dpapi:';
  MNOTE_SECRET_PREFIX_KEYRING = 'keyring:';

{ Indica se o valor lido do arquivo já está protegido. }
function IsProtectedSecret(const AStored: string): Boolean;

{ Devolve o valor a gravar no arquivo. AName identifica o campo
  (por exemplo 'CHATGPT' ou 'PASSWORDMY'). Texto vazio continua vazio. }
function ProtectSecret(const AName, APlain: string): string;

{ Devolve o segredo em claro a partir do valor lido do arquivo. Se o valor
  estiver protegido e não puder ser aberto (outro usuário, outra máquina,
  chaveiro indisponível), devolve texto vazio. }
function UnprotectSecret(const AName, AStored: string): string;

{ Indica se há mecanismo de proteção disponível nesta máquina. }
function SecretStoreAvailable: Boolean;

{ Motivo da última falha de ProtectSecret/UnprotectSecret; vazio se não houve. }
function SecretStoreLastError: string;

implementation

uses
  {$IFDEF WINDOWS}
  Windows,
  {$ELSE}
  Process,
  {$ENDIF}
  base64;

var
  GLastError: string = '';

function HasPrefix(const AValue, APrefix: string): Boolean;
begin
  Result := (Length(AValue) >= Length(APrefix)) and
    (Copy(AValue, 1, Length(APrefix)) = APrefix);
end;

function IsProtectedSecret(const AStored: string): Boolean;
begin
  Result := HasPrefix(AStored, MNOTE_SECRET_PREFIX_DPAPI) or
    HasPrefix(AStored, MNOTE_SECRET_PREFIX_KEYRING);
end;

function SecretStoreLastError: string;
begin
  Result := GLastError;
end;

{$IFDEF WINDOWS}

type
  TMNoteDataBlob = record
    cbData: DWORD;
    pbData: PByte;
  end;
  PMNoteDataBlob = ^TMNoteDataBlob;

const
  MNOTE_CRYPTPROTECT_UI_FORBIDDEN = $1;

function CryptProtectData(pDataIn: PMNoteDataBlob; szDataDescr: PWideChar;
  pOptionalEntropy: PMNoteDataBlob; pvReserved: Pointer;
  pPromptStruct: Pointer; dwFlags: DWORD;
  pDataOut: PMNoteDataBlob): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptProtectData';

function CryptUnprotectData(pDataIn: PMNoteDataBlob; ppszDataDescr: Pointer;
  pOptionalEntropy: PMNoteDataBlob; pvReserved: Pointer;
  pPromptStruct: Pointer; dwFlags: DWORD;
  pDataOut: PMNoteDataBlob): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptUnprotectData';

{ A entropia amarra o bloco cifrado ao campo: um valor copiado de
  PASSWORDMY para CHATGPT não abre. }
function EntropyFor(const AName: string): string;
begin
  Result := 'MNote2:' + UpperCase(AName);
end;

{ Entrada e saída são tratadas como bytes; nenhuma conversão de página de
  código é feita. }
function DpapiTransform(const AName, AInput: string; AProtect: Boolean;
  out AOutput: string): Boolean;
var
  InBlob, OutBlob, EntropyBlob: TMNoteDataBlob;
  Entropy: string;
begin
  AOutput := '';
  Result := False;
  if Length(AInput) = 0 then Exit;
  Entropy := EntropyFor(AName);
  InBlob.cbData := Length(AInput);
  InBlob.pbData := PByte(@AInput[1]);
  EntropyBlob.cbData := Length(Entropy);
  EntropyBlob.pbData := PByte(@Entropy[1]);
  OutBlob.cbData := 0;
  OutBlob.pbData := nil;
  if AProtect then
    Result := CryptProtectData(@InBlob, nil, @EntropyBlob, nil, nil,
      MNOTE_CRYPTPROTECT_UI_FORBIDDEN, @OutBlob)
  else
    Result := CryptUnprotectData(@InBlob, nil, @EntropyBlob, nil, nil,
      MNOTE_CRYPTPROTECT_UI_FORBIDDEN, @OutBlob);
  if not Result then
  begin
    GLastError := 'DPAPI: ' + SysErrorMessage(GetLastError);
    Exit;
  end;
  try
    SetLength(AOutput, OutBlob.cbData);
    if OutBlob.cbData > 0 then
      Move(OutBlob.pbData^, AOutput[1], OutBlob.cbData);
  finally
    if OutBlob.pbData <> nil then
      LocalFree(HLOCAL(OutBlob.pbData));
  end;
end;

function SecretStoreAvailable: Boolean;
begin
  Result := True;
end;

function ProtectSecret(const AName, APlain: string): string;
var
  Cipher: string;
begin
  GLastError := '';
  if APlain = '' then Exit('');
  if DpapiTransform(AName, APlain, True, Cipher) then
    Result := MNOTE_SECRET_PREFIX_DPAPI + EncodeStringBase64(Cipher)
  else
    Result := APlain;
end;

function UnprotectSecret(const AName, AStored: string): string;
var
  Cipher, Plain: string;
begin
  GLastError := '';
  if not IsProtectedSecret(AStored) then Exit(AStored);
  Result := '';
  if not HasPrefix(AStored, MNOTE_SECRET_PREFIX_DPAPI) then
  begin
    GLastError := 'Segredo gravado por outro sistema operacional.';
    Exit;
  end;
  try
    Cipher := DecodeStringBase64(Copy(AStored,
      Length(MNOTE_SECRET_PREFIX_DPAPI) + 1, MaxInt));
  except
    on E: Exception do
    begin
      GLastError := 'Base64 inválido no segredo ' + AName + '.';
      Exit;
    end;
  end;
  if DpapiTransform(AName, Cipher, False, Plain) then
    Result := Plain;
end;

{$ELSE}

const
  SECRET_TOOL = 'secret-tool';
  SECRET_TOOL_TIMEOUT_MS = 5000;

var
  { Últimos valores já sincronizados com o chaveiro, por campo. Evita chamar o
    secret-tool a cada gravação do mnote.cfg quando nada mudou. }
  GSynced: TStringList = nil;

function SyncedValue(const AField: string; out AValue: string): Boolean;
var
  Index: Integer;
begin
  AValue := '';
  Result := False;
  if GSynced = nil then Exit;
  Index := GSynced.IndexOfName(AField);
  if Index < 0 then Exit;
  AValue := GSynced.ValueFromIndex[Index];
  Result := True;
end;

procedure RememberSynced(const AField, AValue: string);
begin
  if GSynced = nil then
  begin
    GSynced := TStringList.Create;
    GSynced.CaseSensitive := True;
  end;
  GSynced.Values[AField] := AValue;
end;

function SecretToolPath: string;
begin
  Result := ExeSearch(SECRET_TOOL, GetEnvironmentVariable('PATH'));
end;

function SecretStoreAvailable: Boolean;
begin
  Result := SecretToolPath <> '';
end;

{ Executa o secret-tool com limite de tempo, para não travar a tela quando o
  chaveiro está bloqueado ou não há sessão gráfica. }
function RunSecretTool(const AArguments: array of string;
  const AInput: string; out AOutput: string): Boolean;
var
  Tool: TProcess;
  Buffer: array[0..1023] of Byte;
  ReadCount, I: Integer;
  Started: QWord;
  Executable: string;
begin
  Result := False;
  AOutput := '';
  Executable := SecretToolPath;
  if Executable = '' then
  begin
    GLastError := 'secret-tool não encontrado; segredo mantido em texto.';
    Exit;
  end;
  Tool := TProcess.Create(nil);
  try
    Tool.Executable := Executable;
    for I := Low(AArguments) to High(AArguments) do
      Tool.Parameters.Add(AArguments[I]);
    Tool.Options := [poUsePipes, poStderrToOutPut];
    try
      Tool.Execute;
      if AInput <> '' then
        Tool.Input.Write(AInput[1], Length(AInput));
      Tool.CloseInput;
      Started := GetTickCount64;
      while Tool.Running do
      begin
        while Tool.Output.NumBytesAvailable > 0 do
        begin
          ReadCount := Tool.Output.Read(Buffer, SizeOf(Buffer));
          if ReadCount <= 0 then Break;
          SetLength(AOutput, Length(AOutput) + ReadCount);
          Move(Buffer[0], AOutput[Length(AOutput) - ReadCount + 1], ReadCount);
        end;
        if GetTickCount64 - Started > SECRET_TOOL_TIMEOUT_MS then
        begin
          Tool.Terminate(1);
          GLastError := 'O chaveiro do sistema não respondeu a tempo.';
          AOutput := '';
          Exit;
        end;
        Sleep(10);
      end;
      while Tool.Output.NumBytesAvailable > 0 do
      begin
        ReadCount := Tool.Output.Read(Buffer, SizeOf(Buffer));
        if ReadCount <= 0 then Break;
        SetLength(AOutput, Length(AOutput) + ReadCount);
        Move(Buffer[0], AOutput[Length(AOutput) - ReadCount + 1], ReadCount);
      end;
      Result := Tool.ExitStatus = 0;
      if not Result then
      begin
        GLastError := 'O chaveiro do sistema recusou a operação.';
        AOutput := '';
      end;
    except
      on E: Exception do
      begin
        GLastError := 'Falha ao executar secret-tool: ' + E.Message;
        AOutput := '';
        Result := False;
      end;
    end;
  finally
    Tool.Free;
  end;
end;

function ProtectSecret(const AName, APlain: string): string;
var
  Ignored, Known, Field: string;
begin
  GLastError := '';
  if APlain = '' then Exit('');
  Field := UpperCase(AName);
  if SyncedValue(Field, Known) and (Known = APlain) then
    Exit(MNOTE_SECRET_PREFIX_KEYRING + Field);
  if RunSecretTool(['store', '--label=MNote2 ' + AName, 'app', 'mnote2',
    'campo', Field], APlain, Ignored) then
  begin
    RememberSynced(Field, APlain);
    Result := MNOTE_SECRET_PREFIX_KEYRING + Field;
  end
  else
    Result := APlain;
end;

function UnprotectSecret(const AName, AStored: string): string;
var
  Field: string;
begin
  GLastError := '';
  if not IsProtectedSecret(AStored) then Exit(AStored);
  Result := '';
  if not HasPrefix(AStored, MNOTE_SECRET_PREFIX_KEYRING) then
  begin
    GLastError := 'Segredo gravado por outro sistema operacional.';
    Exit;
  end;
  Field := Copy(AStored, Length(MNOTE_SECRET_PREFIX_KEYRING) + 1, MaxInt);
  if Field = '' then Field := UpperCase(AName);
  if RunSecretTool(['lookup', 'app', 'mnote2', 'campo', Field], '',
    Result) then
    RememberSynced(Field, Result)
  else
    Result := '';
end;

{$ENDIF}

{$IFNDEF WINDOWS}
finalization
  GSynced.Free;
{$ENDIF}

end.
