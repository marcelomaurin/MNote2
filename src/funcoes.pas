unit funcoes;

{$mode objfpc}{$H+}


interface

uses
Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
StdCtrls, ExtCtrls, UTF8Process, Process
{$IFDEF MSWINDOWS}
,windows, jwaWinBase
{$else}
//LCLType,
//LCLIntf
{$ENDIF}

;

{$IFDEF WINDOWS}
const
  SECURITY_NT_AUTHORITY: TSidIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID  = $00000020;
  DOMAIN_ALIAS_RID_ADMINS      = $00000220;
  SE_GROUP_USE_FOR_DENY_ONLY  = $00000010;
{$endif}

Function RetiraInfo(Value : string): string;
function BuscaChave( lista : TStringList; Ref: String; var posicao:integer): boolean;
function iif(condicao : boolean; verdade : variant; falso: variant):variant;
function GetTotalCpuUsagePct(): double;
function GetProcessorUsage : integer;
function GetCPUCount : integer;
function ShowConfirm(Mensagem : string) : boolean;

function GetGPUTemperature(device : integer): string;
function GetGPUCount : integer;
function GetGPUName(device : integer): string;
{$IFDEF WINDOWS}
function RegisterFileType(ExtName: string; AppName: string): boolean;
function  VerificaRegExt(extensao : string) : boolean;
function RegisterFileType2(const DocFileName: string; AppName : string): boolean;
function RegistrarExtensao(const Extensao, TipoArquivo, NomeAplicacao, Executavel: string) : boolean;
function IsAdministrator: Boolean;
{$ENDIF}

{$IFDEF Darwin}
function VerifyAdminLogin:boolean;
{$endif}

implementation


uses main
{$IFDEF WINDOWS}
   ,Registry, ShlObj
{$ENDIF}
{$ifdef Darwin}
,MacOSAll
{$endif}
;





var LastTickCount     : cardinal = 0;
    LastProcessorTime : int64    = 0;
    FLastIdleTime: Int64;
    FLastKernelTime: Int64;
    FLastUserTime: Int64;


function ShowConfirm(Mensagem : string) : boolean;
var
      Reply, BoxStyle: Integer;
begin
      BoxStyle := MB_ICONQUESTION + MB_YESNO;
      Reply := Application.MessageBox(pchar(Mensagem),'Confirmation', BoxStyle);
      if Reply = IDYES then
         result := true
        else
          result := false;
end;

{$IFDEF Darwin}
function VerifyAdminLogin:boolean;
var
  status:OSStatus;
  authRef: AuthorizationRef;
  authFlags: AuthorizationFlags;
  authRights: AuthorizationRights;
  authItem: AuthorizationItem;
begin
  authItem.flags := 0;
  authItem.name  := kAuthorizationRightExecute;
  authItem.value := nil;
  authItem.valueLength:= 0;
  authRights.count := 1;
  authRights.items := @authItem;
  authRef := nil;
  authFlags := kAuthorizationFlagInteractionAllowed or kAuthorizationFlagExtendRights or kAuthorizationFlagPreAuthorize;
  status := AuthorizationCreate(@authRights, kAuthorizationEmptyEnvironment, authFlags, authRef);
  Result := status=errAuthorizationSuccess;
end;
{$endif}


{$IFDEF WINDOWS}

function  VerificaRegExt(extensao : string) : boolean;
var
   reg: TRegistry;
begin

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if not reg.KeyExists(extensao + 'file\shell\open\command') then
      result := false
    else
      result := true;
  finally
    reg.Free;
  end;
   (*
 if ParamCount > 0 then
  begin
    s := ParamStr(1);
    if ExtractFileExt(s) = extensao then
      LoadFile(s);
  end;
  *)
end;

function IsAdministrator: Boolean;
var
  psidAdmin: Pointer;
  B: BOOL;

begin
  psidAdmin := nil;
  try
    // Создаём SID группы админов для проверки
    Win32Check(AllocateAndInitializeSid(@SECURITY_NT_AUTHORITY, 2,
      SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0,
      psidAdmin));

    // Проверяем, входим ли мы в группу админов (с учётов всех проверок на disabled SID)
    if CheckTokenMembership(0, psidAdmin, B) then
      Result := B
    else
      Result := False;
  finally
    if psidAdmin <> nil then
      FreeSid(psidAdmin);
  end;
end;



function RegistrarExtensao(const Extensao, TipoArquivo, NomeAplicacao, Executavel: string) : boolean;
var
  ChaveArquivo: string;
  Registro: TRegistry;

  procedure EditarChave(const Chave, Valor: string);
  begin
    Registro.OpenKey(Chave, True);
    Registro.WriteString('', Valor);
    Registro.CloseKey;
  end;

begin
  Registro := TRegistry.Create;
  result := false;
  try
    Registro.RootKey := HKEY_CLASSES_ROOT;
    Registro.LazyWrite := False;
    ChaveArquivo := 'Arquivo' + Extensao;

    //Registra a extensão
    EditarChave('.' + Extensao, ChaveArquivo);

    //Define a descrição para o tipo de arquivo
    EditarChave(Format('%s', [ChaveArquivo]), TipoArquivo);

    //Adiciona uma entrada no menu de contexto
    EditarChave(Format('%s\shell\open', [ChaveArquivo]), Format('&Abrir com %s', [NomeAplicacao]));

    //Associa a extensão à aplicação
    EditarChave(Format('%s\shell\open\command', [ChaveArquivo]), Format('”%s” “%s”', [Executavel, '%1']));

    //Define o ícone associado ao tipo de arquivo
    EditarChave(Format('%s\DefaultIcon', [ChaveArquivo]), Format('%s, 0', [Executavel]));
  finally
    Registro.Free;
  end;
  //Notifica o SO da alteração na associação do tipo de arquivo
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
  result := true;
end;



function RegisterFileType2(const DocFileName: string; AppName : string): boolean;
var
  FileClass: string;
  Reg: TRegistry;
begin
  Result := false;
  Reg := TRegistry.Create(KEY_EXECUTE);
  Reg.RootKey := HKEY_CLASSES_ROOT;
  reg.LazyWrite:= false;
  FileClass := '';
  if Reg.OpenKeyReadOnly(ExtractFileExt(DocFileName)) then
  begin
    FileClass := Reg.ReadString('');
    Reg.CloseKey;
  end;
  if FileClass <> '' then begin
    if Reg.OpenKey(FileClass + '\Shell\Open\Command',True) then
    begin
      reg.WriteString('', AppName + ',0');
      Reg.CloseKey;
      Reg.OpenKey( ExtractFileExt(DocFileName) + 'fileshellopencommand', True);
      Reg.WriteString('',AppName+' "%1"');
      Reg.CloseKey;
      Result := true;
    end;
  end;
  Reg.Free;
end;

function RegisterFileType(ExtName: string; AppName: string): boolean;
    var
      reg: TRegistry;
begin
      reg := TRegistry.Create;
      try
        reg.RootKey := HKEY_CLASSES_ROOT;
        reg.Access:= KEY_ALL_ACCESS;
        if not reg.OpenKey('.' + ExtName, True) then
        begin
          reg.CreateKey('.' + ExtName);
        end;
        reg.WriteString('', ExtName + 'file');
        reg.CloseKey;
        reg.CreateKey(ExtName + 'file');
        reg.OpenKey(ExtName + 'file\DefaultIcon', True);
        reg.WriteString('', AppName + ',0');
        reg.CloseKey;
        reg.OpenKey(ExtName + 'file\shell\open\command', True);
        reg.WriteString('', AppName + ' "%1"');
        reg.CloseKey;
        result := true;

      finally
        reg.Free;
      end;
      SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
    end;
{$ENDIF}

//    nvidia-smi    --query-gpu=gpu_name, vbios_version --format=csv,noheader
function GetGPUCount : integer;
var
   cmd : TProcess;
   AStringList: TStringList;
   info : string;
begin
   cmd := TProcess.Create(nil);
   // Cria o objeto TStringList.
   AStringList := TStringList.Create;
   cmd.CommandLine := 'nvidia-smi --format=csv,noheader --query-gpu=gpu_name';

   cmd.Options := cmd.Options + [poWaitOnExit,poUsePipes,poNoConsole];

   cmd.Execute;
   AStringList.LoadFromStream(cmd.Output);

   //AStringList.SaveToFile('output.txt');
   info := trim(AStringList.Text);
   result := AStringList.Count;

   // Agora que o arquivo foi salvo nós podemos liberar a
   // TStringList e o TProcess.
   AStringList.Free;
   cmd.Free;
end;

function GetCPUCount : integer;
begin
  result := GetSystemThreadCount;
end;

function GetGPUName(device : integer): string;
var
   cmd : TProcess;
   AStringList: TStringList;
begin
   cmd := TProcess.Create(nil);
   // Cria o objeto TStringList.
   AStringList := TStringList.Create;
   cmd.CommandLine := 'nvidia-smi -i '+inttostr(device)+' --format=csv,noheader --query-gpu=gpu_name';

   cmd.Options := cmd.Options + [poWaitOnExit,poUsePipes,poNoConsole];

   cmd.Execute;
   AStringList.LoadFromStream(cmd.Output);

   //AStringList.SaveToFile('output.txt');
   result := trim(AStringList.Text);

   // Agora que o arquivo foi salvo nós podemos liberar a
   // TStringList e o TProcess.
   AStringList.Free;
   cmd.Free;
end;


function GetGPUTemperature(device : integer): string;
var
   cmd : TProcess;
   AStringList: TStringList;
begin
   cmd := TProcess.Create(nil);
   // Cria o objeto TStringList.
   AStringList := TStringList.Create;
   cmd.CommandLine := 'nvidia-smi -i '+inttostr(device)+' --format=csv,noheader --query-gpu=temperature.gpu';

   cmd.Options := cmd.Options + [poWaitOnExit,poUsePipes,poNoConsole];

   cmd.Execute;
   AStringList.LoadFromStream(cmd.Output);

   //AStringList.SaveToFile('output.txt');
   result := trim(AStringList.Text);

   // Agora que o arquivo foi salvo nós podemos liberar a
   // TStringList e o TProcess.
   AStringList.Free;
   cmd.Free;
end;


function iif(condicao : boolean; verdade : variant; falso: variant):variant;
begin
     if condicao then
     begin
          result := verdade;
     end
     else
     begin
       result := falso
     end;
end;


//Retira o bloco de informação
Function RetiraInfo(Value : string): string;
var
  posicao : integer;
  resultado : string;
begin
     resultado := '';
     posicao := pos(':',value);
     if(posicao >-1) then
     begin
          resultado := copy(value,posicao+1,length(value));
     end;
     result := resultado;
end;

function BuscaChave( lista : TStringList; Ref: String; var posicao:integer): boolean;
var
  contador : integer;
  maximo : integer;
  item : string;
  indo : integer;
  resultado : boolean;
begin
     maximo := lista.Count-1;
     resultado := false;
     for contador := 0 to maximo do
     begin
       item := lista.Strings[contador];
       indo := pos(Ref,item);
       if (indo > 0) then
       begin
            posicao := contador;
            resultado := true;
            break;
       end;
     end;
     result := resultado;
end;

{$IFDEF MSWINDOWS}
function GetCPU(): double;
{$PUSH}
{$CODEALIGN LOCALMIN=8}

var
  IdleTimeRec: TFileTime;
  KernelTimeRec: TFileTime;
  UserTimeRec: TFileTime;
  IdleTime: Int64 absolute IdleTimeRec;
  KernelTime: Int64 absolute KernelTimeRec;
  UserTime: Int64 absolute UserTimeRec;
  IdleDiff: Int64;
  KernelDiff: Int64;
  UserDiff: Int64;
  SysTime: Int64;
{$POP}
begin
     if GetSystemTimes(@IdleTimeRec, @KernelTimeRec, @UserTimeRec) then
     begin
        IdleDiff := IdleTime - FLastIdleTime;
        KernelDiff := KernelTime - FLastKernelTime;
        UserDiff := UserTime - FLastUserTime;
        FLastIdleTime := IdleTime;
        FLastKernelTime := KernelTime;
        FLastUserTime := UserTime;
        SysTime := KernelDiff + UserDiff;
        result :=  (SysTime - IdleDiff)/SysTime * 100;

     end;
end;
{$ENDIF}

//https://forum.lazarus.freepascal.org/index.php?topic=38839.0
function GetTotalCpuUsagePct(): double;
begin
  {$IFDEF MSWINDOWS}
  Result :=  GetCPU();
  {$else}
  Result := 0;
  {$ENDIF}
end;

function GetProcessorTime : int64;
type
  TPerfDataBlock = packed record
    signature              : array [0..3] of wchar;
    littleEndian           : cardinal;
    version                : cardinal;
    revision               : cardinal;
    totalByteLength        : cardinal;
    headerLength           : cardinal;
    numObjectTypes         : integer;
    defaultObject          : cardinal;
    systemTime             : TSystemTime;
    perfTime               : comp;
    perfFreq               : comp;
    perfTime100nSec        : comp;
    systemNameLength       : cardinal;
    systemnameOffset       : cardinal;
  end;
  TPerfObjectType = packed record
    totalByteLength        : cardinal;
    definitionLength       : cardinal;
    headerLength           : cardinal;
    objectNameTitleIndex   : cardinal;
    objectNameTitle        : PWideChar;
    objectHelpTitleIndex   : cardinal;
    objectHelpTitle        : PWideChar;
    detailLevel            : cardinal;
    numCounters            : integer;
    defaultCounter         : integer;
    numInstances           : integer;
    codePage               : cardinal;
    perfTime               : comp;
    perfFreq               : comp;
  end;
  TPerfCounterDefinition = packed record
    byteLength             : cardinal;
    counterNameTitleIndex  : cardinal;
    counterNameTitle       : PWideChar;
    counterHelpTitleIndex  : cardinal;
    counterHelpTitle       : PWideChar;
    defaultScale           : integer;
    defaultLevel           : cardinal;
    counterType            : cardinal;
    counterSize            : cardinal;
    counterOffset          : cardinal;
  end;
  TPerfInstanceDefinition = packed record
    byteLength             : cardinal;
    parentObjectTitleIndex : cardinal;
    parentObjectInstance   : cardinal;
    uniqueID               : integer;
    nameOffset             : cardinal;
    nameLength             : cardinal;
  end;
var  c1, c2, c3      : cardinal;
     i1, i2          : integer;
     perfDataBlock   : ^TPerfDataBlock;
     perfObjectType  : ^TPerfObjectType;
     perfCounterDef  : ^TPerfCounterDefinition;
     perfInstanceDef : ^TPerfInstanceDefinition;
begin
  result := 0;
  perfDataBlock := nil;
  try
    c1 := $10000;
    while true do begin
      ReallocMem(perfDataBlock, c1);
      c2 := c1;
      {$IFDEF MSWINDOWS}
      case RegQueryValueEx(HKEY_PERFORMANCE_DATA, '238', nil, @c3, pointer(perfDataBlock), @c2) of
        ERROR_MORE_DATA : c1 := c1 * 2;
        ERROR_SUCCESS   : break;
        else              exit;
      end;
      {$else}

      {$endif}
    end;
    perfObjectType := pointer(cardinal(perfDataBlock) + perfDataBlock^.headerLength);
    for i1 := 0 to perfDataBlock^.numObjectTypes - 1 do begin
      if perfObjectType^.objectNameTitleIndex = 238 then begin   // 238 -> "Processor"
        perfCounterDef := pointer(cardinal(perfObjectType) + perfObjectType^.headerLength);
        for i2 := 0 to perfObjectType^.numCounters - 1 do begin
          if perfCounterDef^.counterNameTitleIndex = 6 then begin    // 6 -> "% Processor Time"
            perfInstanceDef := pointer(cardinal(perfObjectType) + perfObjectType^.definitionLength);
            result := PInt64(cardinal(perfInstanceDef) + perfInstanceDef^.byteLength + perfCounterDef^.counterOffset)^;
            break;
          end;
          inc(perfCounterDef);
        end;
        break;
      end;
      perfObjectType := pointer(cardinal(perfObjectType) + perfObjectType^.totalByteLength);
    end;
  finally FreeMem(perfDataBlock)end;
end;

function GetProcessorUsage : integer;
var tickCount     : cardinal;
    processorTime : int64;
begin
  result := 0;
  tickCount     := GetTickCount;
  processorTime := GetProcessorTime;
  if (LastTickCount <> 0) and (tickCount <> LastTickCount) then
    result := 100 - Round(((processorTime - LastProcessorTime) div 100) / (tickCount - LastTickCount));
  LastTickCount     := tickCount;
  LastProcessorTime := processorTime;
end;





end.

