//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setbanco;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, TypeDB;

type
  { TSetBanco }

  TSetBanco = class(TObject)
  private
    arquivo: TStringList;
    FHostName: String;
    FTipoBanco: TypeDatabase;
    FUser: String;
    FPassword: String;
    filename: string;
    FDatabasename: String;
    FNroCfg: integer;
    FScheme: String;
    FPATH: string;
    FPORT: String;
    procedure SetTipoBanco(value: TypeDatabase);
    procedure SetHostName(value: string);
    procedure SetUser(value: string);
    procedure SetPassword(value: string);
    procedure SetDatabasename(value: string);
    procedure SetScheme(value: string);
    procedure SetPort(value: string);
    procedure Default();
  public
    constructor Create(Lfilename: string);
    destructor Destroy(); override;
    procedure SalvaContexto(flag: boolean);
    procedure CarregaContexto();
    procedure IdentificaArquivo(flag: boolean);
    property HostName: string read FHostName write SetHostName;
    property User: string read FUser write SetUser;
    property Password: string read FPassword write SetPassword;
    property TipoBanco: TypeDatabase read FTipoBanco write SetTipoBanco;
    property Databasename: String read FDatabasename write SetDatabaseName;
    property nrocfg: integer read FNrocfg write FNrocfg;
    property Scheme: String read FScheme write SetScheme;
    property Port: string read FPort write SetPort;
  end;

implementation

procedure TSetBanco.SetScheme(value: string);
begin
  FScheme := value;
end;

procedure TSetBanco.SetPort(value: string);
begin
  FPort := value;
end;

procedure TSetBanco.SetDatabasename(value: string);
begin
  FDatabasename := value;
end;

procedure TSetBanco.SetPassword(value: string);
begin
  FPassword := value;
end;

procedure TSetBanco.SetUser(value: string);
begin
  FUser := value;
end;

procedure TSetBanco.SetHostName(value: string);
begin
  FHostName := value;
end;

procedure TSetBanco.SetTipoBanco(value: TypeDatabase);
begin
  FTipoBanco := value;
end;

procedure TSetBanco.Default();
begin
  FTipoBanco := DBMysql;
  FDatabasename := '';
  FPassword := '';
  FUser := '';
  FHostName := '127.0.0.1';
  FScheme := '';
  FPORT := '3306';
  FNroCfg := 0;
end;

procedure TSetBanco.CarregaContexto();
var
  posicao, IntegerValue: integer;
begin
  if BuscaChave(arquivo, 'TIPOBANCO:', posicao) and
     TryStrToInt(RetiraInfo(arquivo.Strings[posicao]), IntegerValue) and
     (IntegerValue >= Ord(Low(TypeDatabase))) and
     (IntegerValue <= Ord(High(TypeDatabase))) then
    FTipoBanco := TypeDatabase(IntegerValue);

  if BuscaChave(arquivo, 'DATABASENAME:', posicao) then
    FDatabasename := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo, 'USER:', posicao) then
    FUser := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo, 'HOSTNAME:', posicao) then
    FHostName := RetiraInfo(arquivo.Strings[posicao]);

  { Corrige a chave antiga NFORCFG e mantém leitura retrocompatível. }
  if BuscaChave(arquivo, 'NROCFG:', posicao) or
     BuscaChave(arquivo, 'NFORCFG:', posicao) then
  begin
    if TryStrToInt(RetiraInfo(arquivo.Strings[posicao]), IntegerValue) then
      FNroCfg := IntegerValue;
  end;

  if BuscaChave(arquivo, 'SCHEME:', posicao) then
    FScheme := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo, 'PASSWORD:', posicao) then
    FPassword := RetiraInfo(arquivo.Strings[posicao]);
  if BuscaChave(arquivo, 'PORT:', posicao) then
    FPORT := RetiraInfo(arquivo.Strings[posicao]);
end;

procedure TSetBanco.IdentificaArquivo(flag: boolean);
begin
  FPATH := IncludeTrailingPathDelimiter(GetAppConfigDir(False));
  if not DirectoryExists(FPATH) then
    ForceDirectories(FPATH);

  if DirectoryExists(FPATH) and FileExists(FPATH + filename) then
  begin
    arquivo.LoadFromFile(FPATH + filename);
    Default;
    CarregaContexto();
  end
  else
    Default;
end;

constructor TSetBanco.Create(Lfilename: string);
begin
  inherited Create;
  filename := Lfilename + '.cfg';
  arquivo := TStringList.Create;
  IdentificaArquivo(True);
end;

procedure TSetBanco.SalvaContexto(flag: boolean);
begin
  if FPATH = '' then
    FPATH := IncludeTrailingPathDelimiter(GetAppConfigDir(False));
  if not DirectoryExists(FPATH) then
    ForceDirectories(FPATH);

  arquivo.Clear;
  arquivo.Append('TIPOBANCO:' + IntToStr(Ord(FTipoBanco)));
  arquivo.Append('HOSTNAME:' + FHostName);
  arquivo.Append('DATABASENAME:' + FDatabasename);
  arquivo.Append('NROCFG:' + IntToStr(FNroCfg));
  arquivo.Append('SCHEME:' + FScheme);
  arquivo.Append('USER:' + FUser);
  arquivo.Append('PASSWORD:' + FPassword);
  arquivo.Append('PORT:' + FPORT);

  if DirectoryExists(FPATH) then
    arquivo.SaveToFile(FPATH + filename);
end;

destructor TSetBanco.Destroy();
begin
  SalvaContexto(False);
  FreeAndNil(arquivo);
  inherited Destroy;
end;

end.
