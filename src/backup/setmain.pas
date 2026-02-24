//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, graphics;

const filename = 'mnote.cfg';


type
  { TSetMain }

  TSetMain = class(TObject)

  private
        arquivo :Tstringlist;
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

        FRunScript : string;    //Script de Compilação
        FDebugScript : string;  //Script de Debug
        FCleanScript : string;  //Script de Limpeza
        FInstall : string;      //Script de Instalacao
        FCompile : string;      //Script de Compilação

        FHostnameMy : String;
        FBancoMy : String;
        FUsernameMy : String;
        FPasswordMy : String;

        FHostnamePost : String;
        FBancoPOST : String;
        FUsernamePost: String;
        FPasswordPost : String;
        FSchemaPost: String;
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
        procedure SetDllPath( value : string);
        procedure SetDllMyPath( value : string);
        procedure SetDllPostPath( value : string);
        procedure SetToolsFalar(value : boolean);
        procedure Default();
  public
        constructor create();
        destructor Destroy(); override;
        procedure SalvaContexto(flag : boolean);
        Procedure CarregaContexto();
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

        property HostnameMy: string read FHostnameMy write FHostnameMy;
        property BancoMy : String read FBancoMy write FBancoMy;
        property UsernameMy : String read FUsernameMy write FUsernameMy;
        property PasswordMy : String read FPasswordMy write FPasswordMy;
        property HostnamePost : String read FHostnamePost write FHostnamePost;
        property BancoPOST : String read FBancoPOST write FBancoPOST;
        property UsernamePost: String read FUsernamePost write FUsernamePost;
        property PasswordPost : String read FPasswordPost write FPasswordPost;
        property SchemaPost: String read FSchemaPost write FSchemaPost;
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
    fixar:=false;
    stay:=false;
    FPosX :=100;
    FPosY := 100;
    FFixar :=false;
    FStay := false;

    FDllPath:= ExtractFilePath(ApplicationName);
    FDllMyPath:= ExtractFilePath(ApplicationName);
    FDllPostPath:= ExtractFilePath(ApplicationName);

    FHeight :=400;
    FWidth :=400;
    FRunScript := '';
    FDebugScript :='';
    FCleanScript :='';
    FInstall :='';
    FCompile :='';

    fIPFALAR := '127.0.0.1';
    fIPOUVIR := '127.0.0.1';
    if FFont = nil then
    begin
         FFONT := TFont.create();
    end;
    FFONT.Name := 'Courier New';
    FFont.Size := 12;

    FCHATGPT:='';
    FToolsFalar := false;
    FToolsOuvir := false;
    FDefaultfolder := '';
    FProject:= '';
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
  FLastFiles:= value;
end;

procedure TSetMain.SetFont(value: TFont);
begin
  // copia o conteúdo da fonte em vez de trocar o ponteiro
  if Assigned(value) then
    FFONT.Assign(value);
end;

procedure TSetMain.SetCHATGPT(value: String);
begin
  FCHATGPT:= value;
end;

procedure TSetMain.SetDllPath(value: string);
begin
  FDllPath:= value;
end;

procedure TSetMain.SetDllMyPath(value: string);
begin
  FDllMyPath:= value;
end;

procedure TSetMain.SetDllPostPath(value: string);
begin
  FDllPostPath:= value;
end;

procedure TSetMain.SetToolsFalar(value: boolean);
begin
  FToolsFalar := value;
end;

procedure TSetMain.CarregaContexto();
var
  posicao: integer;
begin
    if  BuscaChave(arquivo,'DEVICE:',posicao) then
      ckdevice := (RetiraInfo(arquivo.Strings[posicao])='1');

    if  BuscaChave(arquivo,'POSX:',posicao) then
      FPOSX := strtoint(RetiraInfo(arquivo.Strings[posicao]));

    if  BuscaChave(arquivo,'POSY:',posicao) then
      FPOSY := strtoint(RetiraInfo(arquivo.Strings[posicao]));

    if  BuscaChave(arquivo,'FIXAR:',posicao) then
      FFixar := StrToBool(RetiraInfo(arquivo.Strings[posicao]));

    if  BuscaChave(arquivo,'STAY:',posicao) then
      FStay := strtoBool(RetiraInfo(arquivo.Strings[posicao]));

    if  BuscaChave(arquivo,'LASTFILES:',posicao) then
      FLastFiles := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'HEIGHT:',posicao) then
      FHEIGHT := strtoint(RetiraInfo(arquivo.Strings[posicao]));

    if  BuscaChave(arquivo,'WIDTH:',posicao) then
      FWidth := strtoint(RetiraInfo(arquivo.Strings[posicao]));

    if  BuscaChave(arquivo,'RUNSCRIPT:',posicao) then
      FRunScript := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'DEBUGSCRIPT:',posicao) then
      FDebugScript := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'CLEANSCRIPT:',posicao) then
      FCleanScript := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'INSTALLSCRIPT:',posicao) then
      FInstall := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'COMPILESCRIPT:',posicao) then
      FCompile := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'FONT:',posicao) then
      StringToFont(RetiraInfo(arquivo.Strings[posicao]),FFONT);

    if  BuscaChave(arquivo,'CHATGPT:',posicao) then
      FCHATGPT := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'DLLPATH:',posicao) then
      FDLLPATH := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'DLLMYPATH:',posicao) then
      FDLLMyPATH := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'DLLPOSTPATH:',posicao) then
      FDLLPOSTPATH := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'HOSTNAMEMY:',posicao) then
      FHostnameMy := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'BANCOMY:',posicao) then
      FBancoMy := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'USERNAMEMY:',posicao) then
      FUsernameMy := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'PASSWORDMY:',posicao) then
      FPasswordMy := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'HOSTNAMEPOST:',posicao) then
      FHostnamePost := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'BANCOPOST:',posicao) then
      FBancoPost := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'USERNAMEPOST:',posicao) then
      FUsernamePost := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'PASSWORDPOST:',posicao) then
      FPasswordPost := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'SCHEMAPOST:',posicao) then
      FSchemaPost := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'TOOLSFALAR:',posicao) then
      FTOOLSFALAR := iif(RetiraInfo(arquivo.Strings[posicao])='0',false,true);

    if  BuscaChave(arquivo,'TOOLSOUVIR:',posicao) then
      FTOOLSOUVIR := iif(RetiraInfo(arquivo.Strings[posicao])='0',false,true);

    if  BuscaChave(arquivo,'IPFALAR:',posicao) then
      fIPFALAR := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'IPOUVIR:',posicao) then
      fIPOUVIR := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'DEFAULTFOLDER:',posicao) then
      FDefaultfolder := RetiraInfo(arquivo.Strings[posicao]);

    if  BuscaChave(arquivo,'PROJECT:',posicao) then
      FProject := RetiraInfo(arquivo.Strings[posicao]);
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
    arquivo := TStringList.create();
    FFONT := TFont.create();
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
  arquivo.Append('POSX:'+inttostr(FPOSX));
  arquivo.Append('POSY:'+inttostr(FPOSY));
  arquivo.Append('FIXAR:'+booltostr(FFixar));
  arquivo.Append('STAY:'+booltostr(FStay));
  arquivo.Append('LASTFILES:'+FLastFiles);
  arquivo.Append('HEIGHT:'+inttostr(FHEIGHT));
  arquivo.Append('WIDTH:'+inttostr(FWIDTH));
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

  arquivo.Append('HOSTNAMEMY:'+FHostnameMy);
  arquivo.Append('BANCOMY:'+FBancoMy);
  arquivo.Append('USERNAMEMY:'+FUsernameMy);
  arquivo.Append('PASSWORDMY:'+FPasswordMy);

  arquivo.Append('IPFALAR:'+fIPFALAR);
  arquivo.Append('IPOUVIR:'+fIPOUVIR);

  arquivo.Append('HOSTNAMEPOST:'+FHostnamePOST);
  arquivo.Append('BANCOPOST:'+FBancoPOST);
  arquivo.Append('USERNAMEPOST:'+FUsernamePOST);
  arquivo.Append('PASSWORDPOST:'+FPasswordPOST);
  arquivo.Append('SCHEMAPOST:'+FSchemaPost);
  arquivo.Append('TOOLSFALAR:'+iif(FToolsFalar,'1','0'));
  arquivo.Append('TOOLSOUVIR:'+iif(FToolsOuvir,'1','0'));
  arquivo.Append('DEFAULTFOLDER:'+FDefaultfolder);
  arquivo.Append('PROJECT:'+FPROJECT);

  arquivo.SaveToFile(fpath+filename);
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

