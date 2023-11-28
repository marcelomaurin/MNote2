unit funcoes;

{$mode objfpc}{$H+}


interface

uses
Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
StdCtrls, ExtCtrls, UTF8Process, Process, TypInfo , SynEdit, fpjson
{$IFDEF MSWINDOWS}
,windows, jwaWinBase, shellAPI , Registry , JwaTlHelp32
{$ENDIF}
{$IFDEF LINUX}
//LCLType,
//LCLIntf
,BaseUnix
,Unix
{$ENDIF}
{$IFDEF DARWIN}

{$ENDIF}
;

{$IFDEF WINDOWS}
const
  SECURITY_NT_AUTHORITY: TSidIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID  = $00000020;
  DOMAIN_ALIAS_RID_ADMINS      = $00000220;
  SE_GROUP_USE_FOR_DENY_ONLY  = $00000010;
{$endif}

type
  TProcessInfo = record
    ProcessID: THandle;
    Name: string;
  end;

  TProcessList = array of TProcessInfo;

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
procedure StringToFont(const AFontStr: string; var AFont: TFont);
function FontToString(AFont: TFont): string;
function IsRun(const Executavel: string): boolean;
function KillAppByName(const ProcessName: string): boolean;
procedure RemoveCtrlMFromSynEdit(SynEdit: TSynEdit);
function ValidateDirectory(const DirectoryPath: string): Boolean;
function ValidateJson(SynEdit: TSynEdit): Boolean;
function GetProcessList: TProcessList;
{$IFDEF WINDOWS}
function RegisterFileType(ExtName: string; AppName: string): boolean;
function  VerificaRegExt(extensao : string) : boolean;
function RegisterFileType2(const DocFileName: string; AppName : string): boolean;
function RegistrarExtensao(const Extensao, TipoArquivo, NomeAplicacao, Executavel: string) : boolean;
function IsAdministrator: Boolean;
function RunAsAdmin(const Handle: Hwnd; const Path, Params: string): Boolean;
function RunBatch(const Handle: Hwnd; const batch, Params: string): boolean;

function Callprg(filename: string; source: String; var Output: string): boolean;



{$ENDIF}
function VerificaArea(X, Y: longint): Boolean;
{$IFDEF LINUX}
function RunBatch(const batch, Params: string; var Output : string): boolean;
{$ENDIF}
{$IFDEF Darwin}
function VerifyAdminLogin:boolean;
{$endif}

implementation


uses main
{$IFDEF WINDOWS}
   , ShlObj
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


function Callprg(filename: string; source: String; var Output: string): boolean;
var
      resultado: boolean;
      commandLine: string;
      processInfo: TProcessInformation;
      startInfo: TStartupInfo;
begin
      resultado := false;
      FillChar(startInfo, SizeOf(startInfo), 0);
      startInfo.cb := SizeOf(startInfo);
      startInfo.dwFlags := STARTF_USESHOWWINDOW;
      startInfo.wShowWindow := SW_SHOWNORMAL;

      {$IFDEF WINDOWS}
      commandLine := 'cmd.exe /C "' + filename + '" ' + source;
      {$ENDIF}

      {$IFDEF LINUX}
      // Para Linux, você pode precisar ajustar o comando de acordo com suas necessidades
      commandLine := filename + ' ' + source;
      {$ENDIF}

      {$IFDEF DARWIN}
      // Para macOS, ajuste o comando conforme necessário
      commandLine := filename + ' ' + source;
      {$ENDIF}

      if CreateProcess(nil, PChar(commandLine), nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, startInfo, processInfo) then
      begin
        CloseHandle(processInfo.hProcess);
        CloseHandle(processInfo.hThread);
        resultado := True;
      end;

      Result := resultado;
    end;



function VerificaArea(X, Y: longint): Boolean;
var
  ScreenWidth, ScreenHeight: Integer;
begin
   // Obter as dimensões da área de trabalho
   ScreenWidth := Screen.Width;
   ScreenHeight := Screen.Height;

   // Verificar se a área de trabalho é maior que as posições X e Y passadas nos parâmetros
   Result := (ScreenWidth > X) and (ScreenHeight > Y) and (x > 0) and (y > 0);
end;

function KillAppByName(const ProcessName: string): boolean;
var
      ProcessList: TProcessList;
      I: Integer;
      CurrentProcessID: THandle;
      ProcessToKill: string;
      ProcessHandle: THandle;
begin
      Result := False;
      ProcessList := GetProcessList;
      {$IFDEF WINDOWS}
      CurrentProcessID := GetCurrentProcessId;
      {$ENDIF}
      {$IFDEF UNIX}
      CurrentProcessID := fpGetPID;
      {$ENDIF}

      //ProcessToKill := ExtractFileNameOnly(ProcessName);
      ProcessToKill := ExtractFileName(ProcessName);
      try
        for I := 0 to High(ProcessList) do
        begin
          //if (CompareText(ExtractFileNameOnly(ProcessList[I].Name), ProcessToKill) = 0) and
          if (CompareText(ExtractFileName(ProcessList[I].Name), ProcessToKill) = 0) and
             (ProcessList[I].ProcessID <> CurrentProcessID) then
          begin
            {$IFDEF UNIX}
            if fpKill(ProcessList[I].ProcessID, SIGTERM) = 0 then
            begin
              Result := True;
            end;
            {$ENDIF}

            {$IFDEF WINDOWS}
            ProcessHandle := OpenProcess(PROCESS_TERMINATE, False, ProcessList[I].ProcessID);
            if ProcessHandle <> 0 then
            begin
              if TerminateProcess(ProcessHandle, 0) then
              begin
                Result := True;
              end;
              CloseHandle(ProcessHandle);
            end;
            {$ENDIF}
          end;
        end;

      finally
        //FreeProcessList(ProcessList);
      end;
end;

(*
function GetProcessList: TProcessList;
    {$IFDEF WINDOWS}
var
      Snapshot: THandle;
      ProcessEntry: TProcessEntry32;
    {$ENDIF}
    {$IFDEF UNIX}
    var
      F: TextFile;
      PID: LongInt;
      ProcPath, ProcName: string;
    {$ENDIF}
begin
      {$IFDEF WINDOWS}
      Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
      if Snapshot = INVALID_HANDLE_VALUE then
        Exit;

      ProcessEntry.dwSize := SizeOf(ProcessEntry);
      if Process32First(Snapshot, ProcessEntry) then
      begin
        repeat
          SetLength(Result, Length(Result) + 1);
          Result[High(Result)].ProcessID := ProcessEntry.th32ProcessID;
          Result[High(Result)].Name := ProcessEntry.szExeFile;
        until not Process32Next(Snapshot, ProcessEntry);
      end;

      CloseHandle(Snapshot);
      {$ENDIF}

      {$IFDEF UNIX}
      AssignFile(F, '/proc');
      Reset(F);
      try
        while not Eof(F) do
        begin
          Readln(F, ProcPath);
          if TryStrToInt(ProcPath, PID) then
          begin
            ProcName := '';
            ProcPath := Format('/proc/%d/exe', [PID]);

            if fpReadLink(PCHAR(ProcPath), PCHAR(ProcName),Length(ProcName)) > 0 then
            begin
              SetLength(Result, Length(Result) + 1);
              Result[High(Result)].ProcessID := PID;
              Result[High(Result)].Name := ExtractFileName(ProcName);
            end;
          end;
        end;
      finally
        CloseFile(F);
      end;
      {$ENDIF}
end;
*)

function GetProcessList: TProcessList;
  {$IFDEF WINDOWS}
  var
    Snapshot: THandle;
    ProcessEntry: TProcessEntry32;
  {$ENDIF}
  {$IFDEF UNIX}
  var
    SearchRec: TSearchRec;
    PID: LongInt;
    ProcPath, ProcName: string;
    Buffer: array[0..1023] of char;
    LinkSize: LongInt;
  {$ENDIF}
begin
  {$IFDEF WINDOWS}
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snapshot = INVALID_HANDLE_VALUE then
    Exit;

  ProcessEntry.dwSize := SizeOf(ProcessEntry);
  if Process32First(Snapshot, ProcessEntry) then
  begin
    repeat
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)].ProcessID := ProcessEntry.th32ProcessID;
      Result[High(Result)].Name := ProcessEntry.szExeFile;
    until not Process32Next(Snapshot, ProcessEntry);
  end;

  CloseHandle(Snapshot);
  {$ENDIF}

  {$IFDEF UNIX}
  if FindFirst('/proc/*', faDirectory, SearchRec) = 0 then
  begin
    try
      repeat
        if TryStrToInt(SearchRec.Name, PID) then
        begin
          ProcPath := Format('/proc/%d/exe', [PID]);

          LinkSize := fpReadLink(PAnsiChar(ProcPath), @Buffer[0], SizeOf(Buffer) - 1);
          if LinkSize > 0 then
          begin
            Buffer[LinkSize] := #0;
            ProcName := ExtractFileName(AnsiString(Buffer));

            SetLength(Result, Length(Result) + 1);
            Result[High(Result)].ProcessID := PID;
            Result[High(Result)].Name := ProcName;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
  {$ENDIF}
end;

function IsRun(const Executavel: string): boolean;
    var
      ProcessList: TProcessList;
      I: Integer;
      ProcessName: string;
begin
      Result := False;
      ProcessList := GetProcessList;

      try
        for I := 0 to High(ProcessList) do
        begin
          //ProcessName := ExtractFileNameOnly(ProcessList[I].Name);
          ProcessName := ExtractFileName(ProcessList[I].Name);
          //if CompareText(ProcessName, ExtractFileNameOnly(Executavel)) = 0 then
          if CompareText(ProcessName, ExtractFileName(Executavel)) = 0 then
          begin
            Result := True;
            Break;
          end;
        end;
      finally
        //FreeProcessList(ProcessList);
      end;
end;

function ValidateDirectory(const DirectoryPath: string): Boolean;
begin
  Result := DirectoryExists(DirectoryPath);
end;

function ValidateJson(SynEdit: TSynEdit): Boolean;
var
      JsonData: TJSONData;
begin
      Result := False;
      try
        JsonData := GetJSON(SynEdit.Text);
        try
          Result := True;
        finally
          JsonData.Free;
        end;
      except
        //on E: EJSONParser do
          // Erro ao analisar a string JSON, considera inválido

      end;
end;

procedure RemoveCtrlMFromSynEdit(SynEdit: TSynEdit);
var
  i: Integer;
  Line: string;
begin
  for i := 0 to SynEdit.Lines.Count - 1 do
  begin
    Line := SynEdit.Lines[i];

    // Remove o CTRL-M (ASCII 13) do final da linha
    if (Length(Line) > 0) and (Ord(Line[Length(Line)]) = 13) then
    begin
      Line := Copy(Line, 1, Length(Line) - 1);
      SynEdit.Lines[i] := Line;
    end;
  end;
end;


function ShowConfirm(Mensagem : string) : boolean;
var
      Reply, BoxStyle: Integer;
begin
 {$IFDEF MSWINDOWS}
      BoxStyle := MB_ICONQUESTION + MB_YESNO;
      Reply := Application.MessageBox(pchar(Mensagem),'Confirmation', BoxStyle);
      if Reply = IDYES then
         result := true
        else
          result := false;
 {$ENDIF}
 {$IFDEF LINUX}
   result := true;
 {$ENDIF}
 {$IFDEF DARWIN}
   result := true;
 {$ENDIF}

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

{$IFDEF LINUX}

function RunBatch(const batch, Params: string; var Output : string): boolean;
var
  resultado : boolean;
  //Output : string;
  comando : string;
begin
  resultado := false;
  //comando := 'bash -c ' + extractfilepath(application.exename)+'run_python.sh '+Params ;
  comando := extractfilepath(application.exename)+'run_python.sh '+Params ;
  if RunCommand(comando,Output) then
  begin
    resultado := true;
  end;
  result := resultado;
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

function IsAdministrator
: Boolean;
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

function RunAsAdmin(const Handle: Hwnd; const Path, Params: string): Boolean;
var
  sei: TShellExecuteInfoA;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.Wnd := Handle;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PAnsiChar(Path);
  sei.lpParameters := PAnsiChar(Params);
  sei.nShow := SW_SHOWNORMAL;
  Result := ShellExecuteExA(@sei);
end;


function RunBatch(const Handle: Hwnd; const batch, Params: string): boolean;
var
  resultado : boolean;

begin
  resultado := false;
   //  ( Handle, nil/'open'/'edit'/'find'/'explore'/'print',   // 'open' isn't always needed
  //      path+prog, params, working folder,
  //        0=hide / 1=SW_SHOWNORMAL / 3=max / 7=min)   // for SW_ constants : uses ... Windows ...
//  Function ShellExecute(HWND: hwnd;lpOperation : LPCSTR ; lpFile : LPCSTR ; lpParameters : LPCSTR; lpDirectory:  LPCSTR; nShowCmd:LONGINT):HInst; external shell32 name 'ShellExecuteA';
//Function ShellExecute(hwnd: HWND;lpOperation : LPCWSTR ; lpFile : LPCWSTR ; lpParameters : LPCWSTR; lpDirectory:  LPCWSTR; nShowCmd:LONGINT):HInst; external shell32 name 'ShellExecuteW';
  if ShellExecute(0,'open', PChar('cmd'),PChar('/c '+batch+' '+Params),nil,1) >32  then
  begin
    resultado := true;
  end;
  result := resultado;
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
  Result := False;
  Registro := TRegistry.Create;
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
    EditarChave(Format('%s\shell\open\command', [ChaveArquivo]), Format('"%s" "%s"', [Executavel, '%1']));

    //Define o ícone associado ao tipo de arquivo
    EditarChave(Format('%s\DefaultIcon', [ChaveArquivo]), Format('%s, 0', [Executavel]));

    //Notifica o SO da alteração na associação do tipo de arquivo
    SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
    Result := True;
  except
    on E: Exception do
    begin
      // Se ocorrer algum erro, retorne false.
      Result := False;
    end;
  end;
  Registro.Free;
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



function FontToString(AFont: TFont): string;
begin
  Result := Format('%s,%d,%d,%d,%d,%d',
    [AFont.Name, AFont.Size, GetOrdProp(AFont, 'Style'), AFont.Orientation, AFont.Color, AFont.Quality]);
end;

procedure StringToFont(const AFontStr: string; var AFont: TFont);
var
  FontProps: TStringList;
begin
  if AFont = nil then
  begin
    AFont := TFont.create();
  end;
  FontProps := TStringList.Create;
  FontProps.Delimiter := ','; // Define o delimitador como vírgula
  FontProps.StrictDelimiter := True; // Ignora espaços ao redor do delimitador

  try
    //FontProps.CommaText := AFontStr;
    FontProps.DelimitedText := AFontStr; // Atribui a lista de itens separados por vírgula ao DelimitedText
    if (FontProps.Count = 6) then
    begin
         AFont.Name := FontProps[0];
         AFont.Size := StrToInt(FontProps[1]);
         SetOrdProp(AFont, 'Style', StrToInt(FontProps[2]));
         AFont.Orientation := StrToInt(FontProps[3]);
         AFont.Color := TColor(StrToInt(FontProps[4]));
         AFont.Quality := TFontQuality(StrToInt(FontProps[5]));
    end;
  finally
    FontProps.Free;
  end;
end;




end.

