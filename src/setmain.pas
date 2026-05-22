//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, graphics;

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
    // 4 = Antigravity / Gemini
    FProvider : Integer;

    // ===== Modelos IA =====
    FModelOpenAI : string;
    FModelLocal : string;
    FModelGemini : string;

    // ===== IA Local =====
    fIPLocalIA : String;

    // ===== MySQL =====
    FHostnameMy : String;
    FBancoMy : String;
    FUsernameMy : String;
    FPasswordMy : String;

    // ===== Postgres =====
    FHostnamePost : String;
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

    FDefaultfolder : string;
    FProject : string;

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

    // ===== MySQL =====
    property HostnameMy: string read FHostnameMy write FHostnameMy;
    property BancoMy : String read FBancoMy write FBancoMy;
    property UsernameMy : String read FUsernameMy write FUsernameMy;
    property PasswordMy : String read FPasswordMy write FPasswordMy;

    // ===== Postgres =====
    property HostnamePost : String read FHostnamePost write FHostnamePost;
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

    property Defaultfolder : string read FDefaultfolder write FDefaultfolder;
    property Project : string read FProject write FProject;
  end;

var
  FSetMain : TSetMain;

implementation

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

  FDllPath := ExtractFilePath(ApplicationName);
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
  FModelGemini := 'gemini-1.5-flash';

  // ===== IA Local =====
  fIPLocalIA := 'http://172.17.241.200:8095';

  fIPFALAR := '127.0.0.1';
  fIPOUVIR := '127.0.0.1';

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
    FCHATGPT := RetiraInfo(arquivo.Strings[posicao]);

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
    FModelGemini := 'gemini-1.5-flash';

  // ===== MySQL =====
  if BuscaChave(arquivo,'HOSTNAMEMY:',posicao) then
    FHostnameMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'BANCOMY:',posicao) then
    FBancoMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'USERNAMEMY:',posicao) then
    FUsernameMy := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PASSWORDMY:',posicao) then
    FPasswordMy := RetiraInfo(arquivo.Strings[posicao]);

  // ===== Postgres =====
  if BuscaChave(arquivo,'HOSTNAMEPOST:',posicao) then
    FHostnamePost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'BANCOPOST:',posicao) then
    FBancoPost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'USERNAMEPOST:',posicao) then
    FUsernamePost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PASSWORDPOST:',posicao) then
    FPasswordPost := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'SCHEMAPOST:',posicao) then
    FSchemaPost := RetiraInfo(arquivo.Strings[posicao]);

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
    FPasswordMSSQL := RetiraInfo(arquivo.Strings[posicao]);

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
    FPasswordOracle := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'SCHEMAORACLE:',posicao) then
    FSchemaOracle := RetiraInfo(arquivo.Strings[posicao]);

  // ===== tools =====
  if BuscaChave(arquivo,'TOOLSFALAR:',posicao) then
    FTOOLSFALAR := iif(RetiraInfo(arquivo.Strings[posicao])='0',false,true);

  if BuscaChave(arquivo,'TOOLSOUVIR:',posicao) then
    FTOOLSOUVIR := iif(RetiraInfo(arquivo.Strings[posicao])='0',false,true);

  if BuscaChave(arquivo,'IPFALAR:',posicao) then
    fIPFALAR := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'IPOUVIR:',posicao) then
    fIPOUVIR := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'DEFAULTFOLDER:',posicao) then
    FDefaultfolder := RetiraInfo(arquivo.Strings[posicao]);

  if BuscaChave(arquivo,'PROJECT:',posicao) then
    FProject := RetiraInfo(arquivo.Strings[posicao]);

  if Trim(FProtocolSQLite) = '' then
    FProtocolSQLite := 'sqlite-3';

  if Trim(fIPLocalIA) = '' then
    fIPLocalIA := 'http://172.17.241.200:8095';

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
  arquivo.Append('CHATGPT:'+FCHATGPT);
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

  // ===== MySQL =====
  arquivo.Append('HOSTNAMEMY:'+FHostnameMy);
  arquivo.Append('BANCOMY:'+FBancoMy);
  arquivo.Append('USERNAMEMY:'+FUsernameMy);
  arquivo.Append('PASSWORDMY:'+FPasswordMy);

  // ===== Postgres =====
  arquivo.Append('HOSTNAMEPOST:'+FHostnamePOST);
  arquivo.Append('BANCOPOST:'+FBancoPOST);
  arquivo.Append('USERNAMEPOST:'+FUsernamePOST);
  arquivo.Append('PASSWORDPOST:'+FPasswordPOST);
  arquivo.Append('SCHEMAPOST:'+FSchemaPost);

  // ===== SQLite (NOVO) =====
  arquivo.Append('BANCOSQLITE:'+FBancoSQLite);
  arquivo.Append('PROTOCOLSQLITE:'+FProtocolSQLite);
  arquivo.Append('SCHEMASQLITE:'+FSchemaSQLite);

  // ===== SQL Server (MSSQL) =====
  arquivo.Append('HOSTNAMEMSSQL:'+FHostnameMSSQL);
  arquivo.Append('BANCOMSSQL:'+FBancoMSSQL);
  arquivo.Append('USERNAMEMSSQL:'+FUsernameMSSQL);
  arquivo.Append('PASSWORDMSSQL:'+FPasswordMSSQL);
  arquivo.Append('SCHEMAMSSQL:'+FSchemaMSSQL);

  // ===== Oracle =====
  arquivo.Append('HOSTNAMEORACLE:'+FHostnameOracle);
  arquivo.Append('BANCOORACLE:'+FBancoOracle);
  arquivo.Append('USERNAMEORACLE:'+FUsernameOracle);
  arquivo.Append('PASSWORDORACLE:'+FPasswordOracle);
  arquivo.Append('SCHEMAORACLE:'+FSchemaOracle);

  // ===== tools =====
  arquivo.Append('TOOLSFALAR:'+iif(FToolsFalar,'1','0'));
  arquivo.Append('TOOLSOUVIR:'+iif(FToolsOuvir,'1','0'));
  arquivo.Append('IPFALAR:'+fIPFALAR);
  arquivo.Append('IPOUVIR:'+fIPOUVIR);

  arquivo.Append('DEFAULTFOLDER:'+FDefaultfolder);
  arquivo.Append('PROJECT:'+FPROJECT);

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
