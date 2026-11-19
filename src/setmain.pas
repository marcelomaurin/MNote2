//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, graphics, mnote_secret_store;

const
  filename = 'mnote.cfg';

type
  { TSetMain }

  TSetMain = class(TObject)
  private
    arquivo : Tstringlist;
    ckdevice : boolean;
    FPosX : integer;
    FPosY : integer;
    FFixar : boolean;
    FStay : boolean;
    FLastFiles : String;
    FPATH : string;
    FHeight : integer;
    FWidth : integer;
    FFONT : TFont;
    FCHATGPT : string;
    FDllPath : string;
    FDllMyPath : string;
    FDllPostPath : string;
    FDllMSSQLPath : string;
    FDllOraclePath : string;

    FRunScript : string;    //Script de Compilação
    FDebugScript : string;  //Script de Debug
    FCleanScript : string;  //Script de Limpeza
    FInstall : string;      //Script de Instalacao
    FCompile : string;      //Script de Compilação

    // ===== Provider IA =====
    // 0 = OpenAI
    // 1 = OpenRouter
    // 2 = Cerebras
    // 3 = Local / llama.cpp
    // 4 = Gemini
    FProvider : Integer;

    // ===== Modelos IA =====
    FModelOpenAI : string;
    FModelLocal : string;
    FModelGemini : string;
    FModelOpenRouter : string;
    FModelCerebras : string;
    FModelClaude : string;

    // ===== IA Local =====
    fIPLocalIA : String;

    // ===== MySQL =====
    FHostnameMy : String;
    FBancoMy : String;
    FUsernameMy : String;
    FPasswordMy : String;

    // ===== Postgres =====
    FHostnamePost : String;
    FPortaPost : Integer;
    FBancoPOST : String;
    FUsernamePost: String;
    FPasswordPost : String;
    FSchemaPost: String;

    // ===== SQLite (NOVO PADRÃO) =====
    FBancoSQLite    : String;  // arquivo .db/.sqlite
    FProtocolSQLite : String;  // default sqlite-3
    FSchemaSQLite   : String;  // opcional (não usado no SQLite, mas mantém padrão)

    // ===== SQL Server (MSSQL) =====
    FHostnameMSSQL : String;
    FBancoMSSQL : String;
    FUsernameMSSQL : String;
    FPasswordMSSQL : String;
    FSchemaMSSQL : String;

    // ===== Oracle =====
    FHostnameOracle : String;
    FBancoOracle : String;
    FUsernameOracle : String;
    FPasswordOracle : String;
    FSchemaOracle : String;

    FToolsFalar : Boolean;
    FToolsOuvir : Boolean;
    fIPFALAR : String;
    fIPOUVIR : String;
    FVoiceWakeWord: string;
    FVoiceOutputEnabled: Boolean;
    FVoiceOutputEngine: Integer;
    FVoiceOutputName: string;
    FVoiceOutputVolume: Integer;
    FVoiceOutputRate: Integer;
    FVoiceOutputAsync: Boolean;
    FWhisperCliPath: string;
    FWhisperModelPath: string;
    FWhisperLanguage: string;
    FWhisperThreads: Integer;
    FWhisperGPU: Boolean;

    FDefaultfolder : string;
    FProject : string;

    FUsePythonConnector: Boolean;
    FPythonExecutionMode: Integer;

    FIDELeftWidth: Integer;
    FIDERightWidth: Integer;
    FIDEBottomHeight: Integer;
    FIDELeftVisible: Boolean;
    FIDERightVisible: Boolean;
    FIDEBottomVisible: Boolean;
    FIDELeftTab: Integer;
    FIDERightTab: Integer;
    FIDEBottomTab: Integer;
    FEditorTheme: string;
    FEditorTabWidth: Integer;
    FEditorShowSpaces: Boolean;
    FEditorShowLineNumbers: Boolean;
    FCompletionAcceptMode: Integer;
    FCompletionAutoTrigger: Boolean;
    FCompletionMinChars: Integer;
    FUseAIDiskScanner: Boolean;

    procedure SetDevice(const Value : Boolean);
    procedure SetPOSX(value : integer);
    procedure SetPOSY(value : integer);
    procedure SetFixar(value : boolean);
    procedure SetStay(value : boolean);
    procedure SetLastFiles(value : string);
    procedure SetFont(value : TFont);
    procedure SetCHATGPT(value : String);
    procedure SetDllPath(value : string);
    procedure SetDllMyPath(value : string);
    procedure SetDllPostPath(value : string);
    procedure SetDllMSSQLPath(value : string);
    procedure SetDllOraclePath(value : string);
    procedure SetToolsFalar(value : boolean);

    procedure Default();

  public
    constructor create();
    destructor Destroy(); override;

    procedure SalvaContexto(flag : boolean);
    procedure CarregaContexto();
    procedure IdentificaArquivo(flag : boolean);

    property device : boolean read ckdevice write SetDevice;
    property posx : integer read FPosX write SetPOSX;
    property posy : integer read FPosY write SetPOSY;
    property fixar : boolean read FFixar write SetFixar;
    property stay : boolean read FStay write SetStay;
    property lastfiles: string read FLastFiles write SetLastFiles;

    property Height: integer read FHeight write FHeight;
    property Width : integer read FWidth write FWidth;

    property RunScript : string read FRunScript write FRunScript;
    property DebugScript : string read FDebugScript write FDebugScript;
    property CleanScript : string read FCleanScript write FCleanScript;
    property Install : string read FInstall write FInstall;
    property Compile : string read FCompile write FCompile;

    property Font : TFont read FFONT write SetFont;
    property CHATGPT: String read FCHATGPT write SetCHATGPT;

    property DLLPath : String read FDllPath write SetDllPath;
    property DLLMyPath : String read FDllMyPath write SetDllMyPath;
    property DLLPostPath : String read FDllPostPath write SetDllPostPath;
    property DLLMSSQLPath : String read FDllMSSQLPath write SetDllMSSQLPath;
    property DLLOraclePath : String read FDllOraclePath write SetDllOraclePath;

    // ===== Provider IA =====
    property Provider : Integer read FProvider write FProvider;

    // ===== IA Local =====
    property IPLocalIA : string read fIPLocalIA write fIPLocalIA;

    // ===== Modelos IA =====
    property ModelOpenAI : string read FModelOpenAI write FModelOpenAI;
    property ModelLocal : string read FModelLocal write FModelLocal;
    property ModelGemini : string read FModelGemini write FModelGemini;
    property ModelOpenRouter : string read FModelOpenRouter write FModelOpenRouter;
    property ModelCerebras : string read FModelCerebras write FModelCerebras;
    property ModelClaude : string read FModelClaude write FModelClaude;

    // ===== MySQL =====
    property HostnameMy: string read FHostnameMy write FHostnameMy;
    property BancoMy : String read FBancoMy write FBancoMy;
    property UsernameMy : String read FUsernameMy write FUsernameMy;
    property PasswordMy : String read FPasswordMy write FPasswordMy;

    // ===== Postgres =====
    property HostnamePost : String read FHostnamePost write FHostnamePost;
    property PortaPost : Integer read FPortaPost write FPortaPost;
    property BancoPOST : String read FBancoPOST write FBancoPOST;
    property UsernamePost: String read FUsernamePost write FUsernamePost;
    property PasswordPost : String read FPasswordPost write FPasswordPost;
    property SchemaPost: String read FSchemaPost write FSchemaPost;

    // ===== SQLite (NOVO PADRÃO) =====
    property BancoSQLite: String read FBancoSQLite write FBancoSQLite;
    property ProtocolSQLite: String read FProtocolSQLite write FProtocolSQLite;
    property SchemaSQLite: String read FSchemaSQLite write FSchemaSQLite;

    // ===== SQL Server =====
    property HostnameMSSQL : String read FHostnameMSSQL write FHostnameMSSQL;
    property BancoMSSQL : String read FBancoMSSQL write FBancoMSSQL;
    property UsernameMSSQL : String read FUsernameMSSQL write FUsernameMSSQL;
    property PasswordMSSQL : String read FPasswordMSSQL write FPasswordMSSQL;
    property SchemaMSSQL : String read FSchemaMSSQL write FSchemaMSSQL;

    // ===== Oracle =====
    property HostnameOracle : String read FHostnameOracle write FHostnameOracle;
    property BancoOracle : String read FBancoOracle write FBancoOracle;
    property UsernameOracle : String read FUsernameOracle write FUsernameOracle;
    property PasswordOracle : String read FPasswordOracle write FPasswordOracle;
    property SchemaOracle : String read FSchemaOracle write FSchemaOracle;

    // ===== Tools =====
    property ToolsFalar : Boolean read FToolsFalar write SetToolsFalar;
    property ToolsOuvir : Boolean read FToolsOuvir write FToolsOuvir;
    property IPFALAR : string read fIPFALAR write fIPFALAR;
    property IPOUVIR : string read fIPOUVIR write fIPOUVIR;
    property VoiceWakeWord: string read FVoiceWakeWord write FVoiceWakeWord;
    property VoiceOutputEnabled: Boolean read FVoiceOutputEnabled
      write FVoiceOutputEnabled;
    property VoiceOutputEngine: Integer read FVoiceOutputEngine
      write FVoiceOutputEngine;
    property VoiceOutputName: string read FVoiceOutputName
      write FVoiceOutputName;
    property VoiceOutputVolume: Integer read FVoiceOutputVolume
      write FVoiceOutputVolume;
    property VoiceOutputRate: Integer read FVoiceOutputRate
      write FVoiceOutputRate;
    property VoiceOutputAsync: Boolean read FVoiceOutputAsync
      write FVoiceOutputAsync;
    property WhisperCliPath: string read FWhisperCliPath write FWhisperCliPath;
    property WhisperModelPath: string read FWhisperModelPath write FWhisperModelPath;
    property WhisperLanguage: string read FWhisperLanguage write FWhisperLanguage;
    property WhisperThreads: Integer read FWhisperThreads write FWhisperThreads;
    property WhisperGPU: Boolean read FWhisperGPU write FWhisperGPU;

    property Defaultfolder : string read FDefaultfolder write FDefaultfolder;
    property Project : string read FProject write FProject;

    property UsePythonConnector: Boolean read FUsePythonConnector write FUsePythonConnector;
    property PythonExecutionMode: Integer read FPythonExecutionMode write FPythonExecutionMode;

    property IDELeftWidth: Integer read FIDELeftWidth write FIDELeftWidth;
    property IDERightWidth: Integer read FIDERightWidth write FIDERightWidth;
    property IDEBottomHeight: Integer read FIDEBottomHeight write FIDEBottomHeight;
    property IDELeftVisible: Boolean read FIDELeftVisible write FIDELeftVisible;
    property IDERightVisible: Boolean read FIDERightVisible write FIDERightVisible;
    property IDEBottomVisible: Boolean read FIDEBottomVisible write FIDEBottomVisible;
    property IDELeftTab: Integer read FIDELeftTab write FIDELeftTab;
    property IDERightTab: Integer read FIDERightTab write FIDERightTab;
    property IDEBottomTab: Integer read FIDEBottomTab write FIDEBottomTab;
    property EditorTheme: string read FEditorTheme write FEditorTheme;
    property EditorTabWidth: Integer read FEditorTabWidth write FEditorTabWidth;
    property EditorShowSpaces: Boolean read FEditorShowSpaces
      write FEditorShowSpaces;
    property EditorShowLineNumbers: Boolean read FEditorShowLineNumbers
      write FEditorShowLineNumbers;
    property CompletionAcceptMode: Integer read FCompletionAcceptMode
      write FCompletionAcceptMode;
    property CompletionAutoTrigger: Boolean read FCompletionAutoTrigger
      write FCompletionAutoTrigger;
    property CompletionMinChars: Integer read FCompletionMinChars
      write FCompletionMinChars;
    property UseAIDiskScanner: Boolean read FUseAIDiskScanner
      write FUseAIDiskScanner;
  end;

var
  FSetMain : TSetMain;

function ResolvePythonFileInDir(const ADir: string;
  AExecutionMode: Integer): string;
function ResolveBundledPythonPath(AExecutionMode: Integer): string;
function IsBundledPythonPath(const APath: string): Boolean;

implementation

function ResolvePythonFileInDir(const ADir: string;
  AExecutionMode: Integer): string;
const
  {$IFDEF WINDOWS}
  DLLNames: array[0..7] of string = (
    'python312.dll', 'python311.dll', 'python313.dll', 'python310.dll',
    'python39.dll', 'python38.dll', 'python314.dll', 'python3.dll'
  );
  {$ELSE}
  {$IFDEF DARWIN}
  DLLNames: array[0..3] of string = (
    'libpython3.12.dylib', 'libpython3.11.dylib', 'libpython3.13.dylib',
    'libpython3.dylib'
  );
  {$ELSE}
  DLLNames: array[0..3] of string = (
    'libpython3.12.so', 'libpython3.11.so', 'libpython3.13.so',
    'libpython3.so'
  );
  {$ENDIF}
  {$ENDIF}
var
  BaseDir, Candidate: string;
  I: Integer;
begin
  Result := '';
  if Trim(ADir) = '' then
    Exit;
  BaseDir := IncludeTrailingPathDelimiter(ADir);
  if AExecutionMode = 0 then
  begin
    for I := Low(DLLNames) to High(DLLNames) do
    begin
      Candidate := BaseDir + DLLNames[I];
      if FileExists(Candidate) then
        Exit(Candidate);
    end;
  end
  else
  begin
    {$IFDEF WINDOWS}
    Candidate := BaseDir + 'python.exe';
    if FileExists(Candidate) then
      Exit(Candidate);
    {$ELSE}
    Candidate := BaseDir + 'bin' + PathDelim + 'python3';
    if FileExists(Candidate) then
      Exit(Candidate);
    Candidate := BaseDir + 'python3';
    if FileExists(Candidate) then
      Exit(Candidate);
    {$ENDIF}
  end;
end;

function ResolveBundledPythonPath(AExecutionMode: Integer): string;
var
  AppDir, PlatformFolder, ArchFolder, Found: string;
  Candidates: array[0..5] of string;
  Count, I: Integer;

  procedure AddArchCandidates(const AArch: string);
  var
    RelSubPath, AltSubPath: string;
  begin
    RelSubPath := 'runtime' + PathDelim + 'python' + PathDelim + 'libs' +
      PathDelim + PlatformFolder + PathDelim + AArch;
    AltSubPath := 'libs' + PathDelim + PlatformFolder + PathDelim + AArch;
    if Count <= High(Candidates) then
    begin
      Candidates[Count] := AppDir + RelSubPath;
      Inc(Count);
    end;
    if Count <= High(Candidates) then
    begin
      Candidates[Count] := ExpandFileName(AppDir + '..' + PathDelim + RelSubPath);
      Inc(Count);
    end;
    if Count <= High(Candidates) then
    begin
      Candidates[Count] := AppDir + AltSubPath;
      Inc(Count);
    end;
  end;

begin
  Result := '';
  AppDir := ExtractFilePath(ParamStr(0));
  if AppDir = '' then
    Exit;
  AppDir := IncludeTrailingPathDelimiter(AppDir);

  {$IFDEF WINDOWS}
  PlatformFolder := 'windows';
  {$IFDEF CPU64}
  ArchFolder := 'x86_64';
  {$ELSE}
  ArchFolder := 'x86';
  {$ENDIF}
  {$ELSE}
  {$IFDEF DARWIN}
  PlatformFolder := 'mac';
  {$IFDEF CPUAARCH64}
  ArchFolder := 'arm';
  {$ELSE}
  ArchFolder := 'x86_64';
  {$ENDIF}
  {$ELSE}
  PlatformFolder := 'linux';
  {$IFDEF CPUAARCH64}
  ArchFolder := 'arm64';
  {$ELSE}
  {$IFDEF CPUARM}
  ArchFolder := 'arm';
  {$ELSE}
  {$IFDEF CPU64}
  ArchFolder := 'x86_64';
  {$ELSE}
  ArchFolder := 'x86';
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}

  Count := 0;
  AddArchCandidates(ArchFolder);
  {$IFDEF WINDOWS}
  {$IFDEF CPU64}
  // Em modo processo, o runtime x86 tambem executa em Windows 64 bits.
  if AExecutionMode <> 0 then
    AddArchCandidates('x86');
  {$ENDIF}
  {$ENDIF}

  for I := 0 to Count - 1 do
  begin
    if DirectoryExists(Candidates[I]) then
    begin
      Found := ResolvePythonFileInDir(Candidates[I], AExecutionMode);
      if Found <> '' then
        Exit(Found);
    end;
  end;
end;

function IsBundledPythonPath(const APath: string): Boolean;
var
  NormInput, NormProc, NormDLL: string;
begin
  Result := False;
  if Trim(APath) = '' then
    Exit;
  NormInput := ExpandFileName(Trim(APath));
  NormProc := ResolveBundledPythonPath(1);
  if (NormProc <> '') and SameFileName(NormInput, ExpandFileName(NormProc)) then
    Exit(True);
  NormDLL := ResolveBundledPythonPath(0);
  if (NormDLL <> '') and SameFileName(NormInput, ExpandFileName(NormDLL)) then
    Exit(True);
end;

procedure TSetMain.SetDevice(const Value: Boolean);
begin
  ckdevice := Value;
end;

//Valores default do codigo
procedure TSetMain.Default();
begin
  ckdevice := false;
  fixar := false;
  stay := false;
  FPosX := 100;
  FPosY := 100;
  FFixar := false;
  FStay := false;

  FDllPath := '';
  FDllMyPath := ExtractFilePath(ApplicationName);
  FDllPostPath := ExtractFilePath(ApplicationName);
  FDllMSSQLPath := ExtractFilePath(ApplicationName);
  FDllOraclePath := ExtractFilePath(ApplicationName);

  FHeight := 400;
  FWidth := 400;
  FRunScript := '';
  FDebugScript := '';
  FCleanScript := '';
  FInstall := '';
  FCompile := '';

  // ===== Provider default =====
  FProvider := 0; // OpenAI

  // ===== Modelos IA defaults =====
  FModelOpenAI := 'gpt-4o-mini';
  FModelLocal := 'llama3.2:3b';
  FModelGemini := 'gemini-2.5-flash';
  FModelOpenRouter := 'google/gemma-2-9b-it:free';
  FModelCerebras := 'llama3.1-8b';
  FModelClaude := 'claude-3-5-sonnet-20241022';

  // ===== IA Local =====
  fIPLocalIA := 'http://127.0.0.1:8095';

  fIPFALAR := '127.0.0.1';
  fIPOUVIR := '127.0.0.1';
  FVoiceWakeWord := 'OK MNote';
  FVoiceOutputEnabled := True;
  {$IFDEF WINDOWS}
  FVoiceOutputEngine := 1;
  {$ELSE}
  FVoiceOutputEngine := 2;
  {$ENDIF}
  FVoiceOutputName := '';
  FVoiceOutputVolume := 100;
  FVoiceOutputRate := 0;
  FVoiceOutputAsync := True;
  FWhisperCliPath := '';
  FWhisperModelPath := '';
  FWhisperLanguage := 'pt';
  FWhisperThreads := 0;
  FWhisperGPU := False;

  if FFONT = nil then
    FFONT := TFont.Create;

  FFONT.Name := 'Courier New';
  FFONT.Size := 12;

  FCHATGPT := '';
  FToolsFalar := false;
  FToolsOuvir := false;

  // ===== Default de conexões =====
  FHostnameMy := '';
  FBancoMy := '';
  FUsernameMy := '';
  FPasswordMy := '';

  FHostnamePost := '';
  FPortaPost := 5432;
  FBancoPOST := '';
  FUsernamePost := '';
  FPasswordPost := '';
  FSchemaPost := '';

  // ===== SQLite defaults (NOVO) =====
  FBancoSQLite := '';
  FProtocolSQLite := 'sqlite-3';
  FSchemaSQLite := '';

  // ===== SQL Server defaults =====
  FHostnameMSSQL := '';
  FBancoMSSQL := '';
  FUsernameMSSQL := '';
  FPasswordMSSQL := '';
  FSchemaMSSQL := '';

  // ===== Oracle defaults =====
  FHostnameOracle := '';
  FBancoOracle := '';
  FUsernameOracle := '';
  FPasswordOracle := '';
  FSchemaOracle := '';

  FDefaultfolder := '';
  FProject := '';

  FPythonExecutionMode := 1;
  FDllPath := ResolveBundledPythonPath(FPythonExecutionMode);
  FUsePythonConnector := (FDllPath <> '');

  FIDELeftWidth := 240;
  FIDERightWidth := 340;
  FIDEBottomHeight := 180;
  FEditorTheme := 'Light';
  FEditorTabWidth := 0;
  FEditorShowSpaces := False;
  FEditorShowLineNumbers := True;
  FCompletionAcceptMode := 0;
  FCompletionAutoTrigger := True;
  FCompletionMinChars := 3;
  FUseAIDiskScanner := True;
  FIDELeftVisible := True;
  FIDERightVisible := True;
  FIDEBottomVisible := True;
  FIDELeftTab := 0;
  FIDERightTab := 0;
  FIDEBottomTab := 0;
end;

procedure TSetMain.SetPOSX(value: integer);
begin
  Fposx := value;
end;

procedure TSetMain.SetPOSY(value: integer);
begin
  FposY := value;
end;

procedure TSetMain.SetFixar(value: boolean);
begin
  FFixar := value;
end;

procedure TSetMain.SetStay(value: boolean);
begin
  FStay := value;
end;

procedure TSetMain.SetLastFiles(value: string);
begin
  FLastFiles := value;
end;

procedure TSetMain.SetFont(value: TFont);
begin
  if Assigned(value) then
    FFONT.Assign(value);
end;

procedure TSetMain.SetCHATGPT(value: String);
begin
  FCHATGPT := value;
end;

procedure TSetMain.SetDllPath(value: string);
begin
  FDllPath := value;
end;

procedure TSetMain.SetDllMyPath(value: string);
begin
  FDllMyPath := value;
end;

procedure TSetMain.SetDllPostPath(value: string);
begin
  FDllPostPath := value;
end;

procedure TSetMain.SetDllMSSQLPath(value: string);
begin
  FDllMSSQLPath := value;
end;

procedure TSetMain.SetDllOraclePath(value: string);
begin
  FDllOraclePath := value;
end;

procedure TSetMain.SetToolsFalar(value: boolean);
begin
  FToolsFalar := value;
end;

procedure TSetMain.CarregaContexto();
var
  posicao: integer;
begin
  if BuscaChave(arquivo,'DEVICE:',posicao) then
    ckdevice := (RetiraInfo(arquivo.Strings[posicao])='1');

  if BuscaChave(arquivo,'POSX:',posicao) then
    FPOSX := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), FPosX);

  if BuscaChave(arquivo,'POSY:',posicao) then
    FPOSY := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), FPosY);

  if BuscaChave(arquivo,'FIXAR:',posicao) then
    FFixar := StrToBoolDef(RetiraInfo(arquivo.Strings[posicao]), FFixar);

  if BuscaChave(arquivo,'STAY:',posicao) then
    FStay := StrToBoolDef(RetiraInfo(arquivo.Strings[posicao]), FStay);

  if BuscaChave(arquivo,'LASTFILES:',posicao) then
    FLastFiles := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'HEIGHT:',posicao) then
    FHEIGHT := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), FHeight);

  if BuscaChave(arquivo,'WIDTH:',posicao) then
    FWidth := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), FWidth);

  if BuscaChave(arquivo,'RUNSCRIPT:',posicao) then
    FRunScript := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'DEBUGSCRIPT:',posicao) then
    FDebugScript := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'CLEANSCRIPT:',posicao) then
    FCleanScript := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'INSTALLSCRIPT:',posicao) then
    FInstall := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'COMPILESCRIPT:',posicao) then
    FCompile := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'FONT:',posicao) then
    StringToFont(RetiraInfo(arquivo.Strings[posicao]),FFONT);

  if BuscaChave(arquivo,'CHATGPT:',posicao) then
    FCHATGPT := UnprotectSecret('CHATGPT', RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo,'DLLPATH:',posicao) then
    FDLLPATH := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'DLLMYPATH:',posicao) then
    FDLLMyPATH := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'DLLPOSTPATH:',posicao) then
    FDLLPOSTPATH := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'DLLMSSQLPATH:',posicao) then
    FDLLMSSQLPATH := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'DLLORACLEPATH:',posicao) then
    FDLLORACLEPATH := RetiraInfo(arquivo.Strings[posicao]);

  // ===== Provider =====
  if BuscaChave(arquivo,'PROVIDER:',posicao) then
    FProvider := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 0)
  else
    FProvider := 0;

  // ===== IA Local =====
  if BuscaChave(arquivo,'IPLOCALIA:',posicao) then
    fIPLocalIA := RetiraInfo(arquivo.Strings[posicao]);

  // ===== Modelos IA =====
  if BuscaChave(arquivo,'MODELOPENAI:',posicao) then
    FModelOpenAI := RetiraInfo(arquivo.Strings[posicao])
  else
    FModelOpenAI := 'gpt-4o-mini';

  if BuscaChave(arquivo,'MODELLOCAL:',posicao) then
    FModelLocal := RetiraInfo(arquivo.Strings[posicao])
  else
    FModelLocal := 'llama3.2:3b';

  if BuscaChave(arquivo,'MODELGEMINI:',posicao) then
    FModelGemini := RetiraInfo(arquivo.Strings[posicao])
  else
    FModelGemini := 'gemini-2.5-flash';
  if BuscaChave(arquivo,'BANCOMY:',posicao) then
    FBancoMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'USERNAMEMY:',posicao) then
    FUsernameMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PASSWORDMY:',posicao) then
    FPasswordMy := UnprotectSecret('PASSWORDMY', RetiraInfo(arquivo.Strings[posicao]));

  // ===== Postgres =====
  if BuscaChave(arquivo,'HOSTNAMEPOST:',posicao) then
    FHostnamePost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'BANCOPOST:',posicao) then
    FBancoPost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'USERNAMEPOST:',posicao) then
    FUsernamePost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PASSWORDPOST:',posicao) then
    FPasswordPost := UnprotectSecret('PASSWORDPOST', RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo,'SCHEMAPOST:',posicao) then
    FSchemaPost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PORTAPOST:',posicao) then
    FPortaPost := StrToIntDef(Trim(RetiraInfo(arquivo.Strings[posicao])), 5432);
  if FPortaPost <= 0 then FPortaPost := 5432;

  // ===== SQLite (NOVO) =====
  if BuscaChave(arquivo,'BANCOSQLITE:',posicao) then
    FBancoSQLite := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PROTOCOLSQLITE:',posicao) then
    FProtocolSQLite := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'SCHEMASQLITE:',posicao) then
    FSchemaSQLite := RetiraInfo(arquivo.Strings[posicao]);

  // ===== SQL Server (MSSQL) =====
  if BuscaChave(arquivo,'HOSTNAMEMSSQL:',posicao) then
    FHostnameMSSQL := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'BANCOMSSQL:',posicao) then
    FBancoMSSQL := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'USERNAMEMSSQL:',posicao) then
    FUsernameMSSQL := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PASSWORDMSSQL:',posicao) then
    FPasswordMSSQL := UnprotectSecret('PASSWORDMSSQL', RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo,'SCHEMAMSSQL:',posicao) then
    FSchemaMSSQL := RetiraInfo(arquivo.Strings[posicao]);

  // ===== Oracle =====
  if BuscaChave(arquivo,'HOSTNAMEORACLE:',posicao) then
    FHostnameOracle := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'BANCOORACLE:',posicao) then
    FBancoOracle := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'USERNAMEORACLE:',posicao) then
    FUsernameOracle := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PASSWORDORACLE:',posicao) then
    FPasswordOracle := UnprotectSecret('PASSWORDORACLE', RetiraInfo(arquivo.Strings[posicao]));

  if BuscaChave(arquivo,'SCHEMAORACLE:',posicao) then
    FSchemaOracle := RetiraInfo(arquivo.Strings[posicao]);

  // ===== tools =====
  FVoiceOutputEnabled := True;
  {$IFDEF WINDOWS}
  FVoiceOutputEngine := 1;
  {$ELSE}
  FVoiceOutputEngine := 2;
  {$ENDIF}
  FVoiceOutputName := '';
  FVoiceOutputVolume := 100;
  FVoiceOutputRate := 0;
  FVoiceOutputAsync := True;
  if BuscaChave(arquivo,'TOOLSFALAR:',posicao) then
    FTOOLSFALAR := iif(RetiraInfo(arquivo.Strings[posicao])='0',false,true);

  if BuscaChave(arquivo,'TOOLSOUVIR:',posicao) then
    FTOOLSOUVIR := iif(RetiraInfo(arquivo.Strings[posicao])='0',false,true);

  if BuscaChave(arquivo,'IPFALAR:',posicao) then
    fIPFALAR := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'IPOUVIR:',posicao) then
    fIPOUVIR := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo,'VOICEWAKEWORD:',posicao) then
    FVoiceWakeWord := RetiraInfo(arquivo.Strings[posicao]);
  if Trim(FVoiceWakeWord) = '' then FVoiceWakeWord := 'OK MNote';
  if BuscaChave(arquivo,'VOICEOUTPUTENABLED:',posicao) then
    FVoiceOutputEnabled := RetiraInfo(arquivo.Strings[posicao]) <> '0';
  if BuscaChave(arquivo,'VOICEOUTPUTENGINE:',posicao) then
    FVoiceOutputEngine := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]),
      FVoiceOutputEngine);
  if BuscaChave(arquivo,'VOICEOUTPUTNAME:',posicao) then
    FVoiceOutputName := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo,'VOICEOUTPUTVOLUME:',posicao) then
    FVoiceOutputVolume := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 100);
  if BuscaChave(arquivo,'VOICEOUTPUTRATE:',posicao) then
    FVoiceOutputRate := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 0);
  if BuscaChave(arquivo,'VOICEOUTPUTASYNC:',posicao) then
    FVoiceOutputAsync := RetiraInfo(arquivo.Strings[posicao]) <> '0';
  if (FVoiceOutputEngine < 0) or (FVoiceOutputEngine > 2) then
    FVoiceOutputEngine := 0;
  if FVoiceOutputVolume < 0 then FVoiceOutputVolume := 0;
  if FVoiceOutputVolume > 100 then FVoiceOutputVolume := 100;
  if FVoiceOutputRate < -10 then FVoiceOutputRate := -10;
  if FVoiceOutputRate > 10 then FVoiceOutputRate := 10;
  if BuscaChave(arquivo,'WHISPERCLIPATH:',posicao) then
    FWhisperCliPath := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo,'WHISPERMODELPATH:',posicao) then
    FWhisperModelPath := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo,'WHISPERLANGUAGE:',posicao) then
    FWhisperLanguage := RetiraInfo(arquivo.Strings[posicao]);
  if Trim(FWhisperLanguage) = '' then FWhisperLanguage := 'pt';
  if BuscaChave(arquivo,'WHISPERTHREADS:',posicao) then
    FWhisperThreads := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 0);
  if BuscaChave(arquivo,'WHISPERGPU:',posicao) then
    FWhisperGPU := RetiraInfo(arquivo.Strings[posicao]) <> '0';

  if BuscaChave(arquivo,'DEFAULTFOLDER:',posicao) then
    FDefaultfolder := RetiraInfo(arquivo.Strings[posicao]);
 
  if BuscaChave(arquivo,'PROJECT:',posicao) then
    FProject := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'USEPYTHONCONNECTOR:',posicao) then
    FUsePythonConnector := (RetiraInfo(arquivo.Strings[posicao])='1')
  else
    FUsePythonConnector := False;

  if BuscaChave(arquivo,'PYTHONEXECUTIONMODE:',posicao) then
    FPythonExecutionMode := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 1)
  else
    FPythonExecutionMode := 1;

  if (Trim(FDLLPATH) = '') or
     (DirectoryExists(FDLLPATH) and
       (ResolvePythonFileInDir(FDLLPATH, FPythonExecutionMode) = '')) or
     ((Pos(PathDelim, FDLLPATH) > 0) and (not FileExists(FDLLPATH)) and
       (not DirectoryExists(FDLLPATH))) then
  begin
    FDLLPATH := ResolveBundledPythonPath(FPythonExecutionMode);
    if FDLLPATH <> '' then
      FUsePythonConnector := True;
  end;

  if BuscaChave(arquivo,'IDELEFTWIDTH:',posicao) then
    FIDELeftWidth := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 240);
  if BuscaChave(arquivo,'IDERIGHTWIDTH:',posicao) then
    FIDERightWidth := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 340);
  if BuscaChave(arquivo,'IDEBOTTOMHEIGHT:',posicao) then
    FIDEBottomHeight := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 180);
  if BuscaChave(arquivo,'IDELEFTVISIBLE:',posicao) then
    FIDELeftVisible := StrToBoolDef(RetiraInfo(arquivo.Strings[posicao]), True);
  if BuscaChave(arquivo,'IDERIGHTVISIBLE:',posicao) then
    FIDERightVisible := StrToBoolDef(RetiraInfo(arquivo.Strings[posicao]), True);
  if BuscaChave(arquivo,'IDEBOTTOMVISIBLE:',posicao) then
    FIDEBottomVisible := StrToBoolDef(RetiraInfo(arquivo.Strings[posicao]), True);
  if BuscaChave(arquivo,'IDELEFTTAB:',posicao) then
    FIDELeftTab := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 0);
  if BuscaChave(arquivo,'IDERIGHTTAB:',posicao) then
    FIDERightTab := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 0);
  if BuscaChave(arquivo,'IDEBOTTOMTAB:',posicao) then
    FIDEBottomTab := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 0);
  if BuscaChave(arquivo,'EDITORTHEME:',posicao) then
    FEditorTheme := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo,'EDITORTABWIDTH:',posicao) then
    FEditorTabWidth := StrToIntDef(RetiraInfo(arquivo.Strings[posicao]), 0);
  if BuscaChave(arquivo,'EDITORSHOWSPACES:',posicao) then
    FEditorShowSpaces := StrToBoolDef(RetiraInfo(arquivo.Strings[posicao]), False);
  if BuscaChave(arquivo,'EDITORSHOWLINENUMBERS:',posicao) then
    FEditorShowLineNumbers := StrToBoolDef(
      RetiraInfo(arquivo.Strings[posicao]), True);
  if BuscaChave(arquivo,'COMPLETIONACCEPTMODE:',posicao) then
    FCompletionAcceptMode := StrToIntDef(
      RetiraInfo(arquivo.Strings[posicao]), 0);
  if BuscaChave(arquivo,'COMPLETIONAUTOTRIGGER:',posicao) then
    FCompletionAutoTrigger := StrToBoolDef(
      RetiraInfo(arquivo.Strings[posicao]), True);
  if BuscaChave(arquivo,'COMPLETIONMINCHARS:',posicao) then
    FCompletionMinChars := StrToIntDef(
      RetiraInfo(arquivo.Strings[posicao]), 3);
  if BuscaChave(arquivo,'USEAIDISKSCANNER:',posicao) then
    FUseAIDiskScanner := StrToBoolDef(
      RetiraInfo(arquivo.Strings[posicao]), True);

  if (FCompletionAcceptMode < 0) or (FCompletionAcceptMode > 2) then
    FCompletionAcceptMode := 0;
  if FCompletionMinChars < 1 then FCompletionMinChars := 1;

  if Trim(FProtocolSQLite) = '' then
    FProtocolSQLite := 'sqlite-3';

  if Trim(fIPLocalIA) = '' then
    fIPLocalIA := 'http://127.0.0.1:8095';

  if FProvider < 0 then
    FProvider := 0;
end;

procedure TSetMain.IdentificaArquivo(flag: boolean);
begin
  {$IFDEF DARWIN}
  FPath := IncludeTrailingPathDelimiter(GetAppConfigDir(False));
  {$ENDIF}
  {$IFDEF LINUX}
  FPath := IncludeTrailingPathDelimiter(GetAppConfigDir(False));
  {$ENDIF}
  {$IFDEF WINDOWS}
  FPath := IncludeTrailingPathDelimiter(GetAppConfigDir(False));
  {$ENDIF}

  if not DirectoryExists(FPath) then
    CreateDir(FPath);

  if FileExists(FPath + filename) then
  begin
    arquivo.LoadFromFile(FPath + filename);
    CarregaContexto();
  end
  else
    Default();
end;

constructor TSetMain.create();
begin
  inherited Create;
  arquivo := TStringList.Create;
  FFONT := TFont.Create;
  IdentificaArquivo(true);
end;

procedure TSetMain.SalvaContexto(flag: boolean);
begin
  if flag then
    IdentificaArquivo(False);

  if not DirectoryExists(FPath) then
    CreateDir(FPath);

  arquivo.Clear;
  arquivo.Append('DEVICE:'+iif(ckdevice,'1','0'));
  arquivo.Append('POSX:'+IntToStr(FPOSX));
  arquivo.Append('POSY:'+IntToStr(FPOSY));
  arquivo.Append('FIXAR:'+BoolToStr(FFixar));
  arquivo.Append('STAY:'+BoolToStr(FStay));
  arquivo.Append('LASTFILES:'+FLastFiles);
  arquivo.Append('HEIGHT:'+IntToStr(FHEIGHT));
  arquivo.Append('WIDTH:'+IntToStr(FWIDTH));
  arquivo.Append('RUNSCRIPT:'+FRunScript);
  arquivo.Append('DEBUGSCRIPT:'+FDebugScript);
  arquivo.Append('CLEANSCRIPT:'+FCleanScript);
  arquivo.Append('INSTALLSCRIPT:'+FInstall);
  arquivo.Append('COMPILESCRIPT:'+FCompile);
  arquivo.Append('FONT:'+FontToString(FFONT));
  arquivo.Append('CHATGPT:'+ProtectSecret('CHATGPT', FCHATGPT));
  arquivo.Append('DLLPATH:'+FDLLPATH);
  arquivo.Append('DLLMYPATH:'+FDLLMYPATH);
  arquivo.Append('DLLPOSTPATH:'+FDLLPOSTPATH);
  arquivo.Append('DLLMSSQLPATH:'+FDLLMSSQLPATH);
  arquivo.Append('DLLORACLEPATH:'+FDLLORACLEPATH);

  // ===== Provider =====
  arquivo.Append('PROVIDER:'+IntToStr(FProvider));

  // ===== IA Local =====
  arquivo.Append('IPLOCALIA:'+fIPLocalIA);

  // ===== Modelos IA =====
  arquivo.Append('MODELOPENAI:'+FModelOpenAI);
  arquivo.Append('MODELLOCAL:'+FModelLocal);
  arquivo.Append('MODELGEMINI:'+FModelGemini);
  arquivo.Append('MODELOPENROUTER:'+FModelOpenRouter);
  arquivo.Append('MODELCEREBRAS:'+FModelCerebras);
  arquivo.Append('MODELCLAUDE:'+FModelClaude);

  // ===== MySQL =====
  arquivo.Append('HOSTNAMEMY:'+FHostnameMy);
  arquivo.Append('BANCOMY:'+FBancoMy);
  arquivo.Append('USERNAMEMY:'+FUsernameMy);
  arquivo.Append('PASSWORDMY:'+ProtectSecret('PASSWORDMY', FPasswordMy));

  // ===== Postgres =====
  arquivo.Append('HOSTNAMEPOST:'+FHostnamePOST);
  arquivo.Append('BANCOPOST:'+FBancoPOST);
  arquivo.Append('USERNAMEPOST:'+FUsernamePOST);
  arquivo.Append('PASSWORDPOST:'+ProtectSecret('PASSWORDPOST', FPasswordPOST));
  arquivo.Append('SCHEMAPOST:'+FSchemaPost);
  arquivo.Append('PORTAPOST:'+IntToStr(FPortaPost));

  // ===== SQLite (NOVO) =====
  arquivo.Append('BANCOSQLITE:'+FBancoSQLite);
  arquivo.Append('PROTOCOLSQLITE:'+FProtocolSQLite);
  arquivo.Append('SCHEMASQLITE:'+FSchemaSQLite);

  // ===== SQL Server (MSSQL) =====
  arquivo.Append('HOSTNAMEMSSQL:'+FHostnameMSSQL);
  arquivo.Append('BANCOMSSQL:'+FBancoMSSQL);
  arquivo.Append('USERNAMEMSSQL:'+FUsernameMSSQL);
  arquivo.Append('PASSWORDMSSQL:'+ProtectSecret('PASSWORDMSSQL', FPasswordMSSQL));
  arquivo.Append('SCHEMAMSSQL:'+FSchemaMSSQL);

  // ===== Oracle =====
  arquivo.Append('HOSTNAMEORACLE:'+FHostnameOracle);
  arquivo.Append('BANCOORACLE:'+FBancoOracle);
  arquivo.Append('USERNAMEORACLE:'+FUsernameOracle);
  arquivo.Append('PASSWORDORACLE:'+ProtectSecret('PASSWORDORACLE', FPasswordOracle));
  arquivo.Append('SCHEMAORACLE:'+FSchemaOracle);

  // ===== tools =====
  arquivo.Append('TOOLSFALAR:'+iif(FToolsFalar,'1','0'));
  arquivo.Append('TOOLSOUVIR:'+iif(FToolsOuvir,'1','0'));
  arquivo.Append('IPFALAR:'+fIPFALAR);
  arquivo.Append('IPOUVIR:'+fIPOUVIR);
  arquivo.Append('VOICEWAKEWORD:'+FVoiceWakeWord);
  arquivo.Append('VOICEOUTPUTENABLED:'+iif(FVoiceOutputEnabled,'1','0'));
  arquivo.Append('VOICEOUTPUTENGINE:'+IntToStr(FVoiceOutputEngine));
  arquivo.Append('VOICEOUTPUTNAME:'+FVoiceOutputName);
  arquivo.Append('VOICEOUTPUTVOLUME:'+IntToStr(FVoiceOutputVolume));
  arquivo.Append('VOICEOUTPUTRATE:'+IntToStr(FVoiceOutputRate));
  arquivo.Append('VOICEOUTPUTASYNC:'+iif(FVoiceOutputAsync,'1','0'));
  arquivo.Append('WHISPERCLIPATH:'+FWhisperCliPath);
  arquivo.Append('WHISPERMODELPATH:'+FWhisperModelPath);
  arquivo.Append('WHISPERLANGUAGE:'+FWhisperLanguage);
  arquivo.Append('WHISPERTHREADS:'+IntToStr(FWhisperThreads));
  arquivo.Append('WHISPERGPU:'+iif(FWhisperGPU,'1','0'));

  arquivo.Append('DEFAULTFOLDER:'+FDefaultfolder);
  arquivo.Append('PROJECT:'+FPROJECT);
 
  arquivo.Append('USEPYTHONCONNECTOR:'+iif(FUsePythonConnector,'1','0'));
  arquivo.Append('PYTHONEXECUTIONMODE:'+IntToStr(FPythonExecutionMode));

  arquivo.Append('IDELEFTWIDTH:'+IntToStr(FIDELeftWidth));
  arquivo.Append('IDERIGHTWIDTH:'+IntToStr(FIDERightWidth));
  arquivo.Append('IDEBOTTOMHEIGHT:'+IntToStr(FIDEBottomHeight));
  arquivo.Append('IDELEFTVISIBLE:'+BoolToStr(FIDELeftVisible, True));
  arquivo.Append('IDERIGHTVISIBLE:'+BoolToStr(FIDERightVisible, True));
  arquivo.Append('IDEBOTTOMVISIBLE:'+BoolToStr(FIDEBottomVisible, True));
  arquivo.Append('IDELEFTTAB:'+IntToStr(FIDELeftTab));
  arquivo.Append('IDERIGHTTAB:'+IntToStr(FIDERightTab));
  arquivo.Append('IDEBOTTOMTAB:'+IntToStr(FIDEBottomTab));
  arquivo.Append('EDITORTHEME:'+FEditorTheme);
  arquivo.Append('EDITORTABWIDTH:'+IntToStr(FEditorTabWidth));
  arquivo.Append('EDITORSHOWSPACES:'+BoolToStr(FEditorShowSpaces, True));
  arquivo.Append('EDITORSHOWLINENUMBERS:'+
    BoolToStr(FEditorShowLineNumbers, True));
  arquivo.Append('COMPLETIONACCEPTMODE:'+IntToStr(FCompletionAcceptMode));
  arquivo.Append('COMPLETIONAUTOTRIGGER:'+
    BoolToStr(FCompletionAutoTrigger, True));
  arquivo.Append('COMPLETIONMINCHARS:'+IntToStr(FCompletionMinChars));
  arquivo.Append('USEAIDISKSCANNER:'+BoolToStr(FUseAIDiskScanner, True));

  arquivo.SaveToFile(FPath + filename);
end;

destructor TSetMain.Destroy;
begin
  arquivo.Free;
  arquivo := nil;

  FFONT.Free;
  FFONT := nil;

  inherited Destroy;
end;

end.
