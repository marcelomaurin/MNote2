unit base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, DB;

type

  { TdmBase }

  TdmBase = class(TDataModule)
    DataSource1: TDataSource;
    qryauxlocal: TZQuery;
    zcon: TZConnection;
    zconlocal: TZConnection;
    zqryaux: TZQuery;
    zqryaux1: TZQuery;
    zqryaux2: TZQuery;
  private

  public
    procedure Connect( Username : string; Password : string; hostname: string; Database: string);
    procedure loadlib(path : string);
    procedure Close();
    function ConectaSQLite(const ArquivoDB: string; biblioteca : string): Boolean;
    function SalvarDadosMaster(projeto : string; Proposito: string; target: string; database: integer): boolean;
    procedure RegistraParam(Chave: string; Valor :string);
    function ValidaConexao(
      const HostName, Schema, Database, UserName, Password: string;
      DatabaseType: Integer
    ): Boolean;
  end;

var
  dmBase: TdmBase;

implementation

{$R *.lfm}

{ TdmBase }

procedure TdmBase.Connect(Username: string; Password: string; hostname: string;
  Database: string);
begin
  zcon.Disconnect;
  zcon.User:=  Username;
  zcon.Password:= Password;
  zcon.HostName:= hostname;
  zcon.Database:= Database;
  zcon.Connect;
end;

procedure TdmBase.loadlib(path: string);
begin
  zcon.LibraryLocation :=path;
end;

procedure TdmBase.Close;
begin
  zcon.Disconnect;
end;

function TdmBase.ConectaSQLite(const ArquivoDB: string; biblioteca : string): Boolean;
begin
  Result := False;
  try
    if zconlocal.Connected then
      zconlocal.Disconnect;

    zconlocal.Protocol := 'sqlite';
    zconlocal.Database := ArquivoDB;
    zconlocal.User := '';  // SQLite não usa usuário normalmente
    zconlocal.Password := '';
    {$IFDEF WINDOWS}
     zconlocal.LibraryLocation:= biblioteca ;
    {$ENDIF}
    {$IFDEF LINUX}
    zconlocal.LibraryLocation:= ExtractFilePath(ApplicationName)+'libs/sqlite/lin32/sqlite3.so' ;
    {$ENDIF}

    zconlocal.Connect;
    Result := zconlocal.Connected;
  except
    Result := False; // Se der erro, retorna False
  end;
end;

function TdmBase.SalvarDadosMaster(projeto : string; Proposito: string; target: string; database: integer): boolean;
begin
  RegistraParam('PROJETO',projeto);
  RegistraParam('PROPOSITO',proposito);
  RegistraParam('TARGET',target);
  RegistraParam('DATABASETYPE',inttostr(database));
end;

procedure TdmBase.RegistraParam(Chave: string; Valor: string);
var
  Existe: Boolean;
begin
  // Verifica se a chave já existe
  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text := 'select 1 from params where chave = :chave limit 1';
  qryauxlocal.ParamByName('chave').AsString := Chave;
  qryauxlocal.Open;
  Existe := not qryauxlocal.IsEmpty;
  qryauxlocal.Close;

  // Atualiza se existir, senão insere
  qryauxlocal.SQL.Clear;
  if Existe then
    qryauxlocal.SQL.Text := 'update params set valor = :valor where chave = :chave'
  else
    qryauxlocal.SQL.Text := 'insert into params (chave, valor) values (:chave, :valor)';

  qryauxlocal.ParamByName('chave').AsString := Chave;
  qryauxlocal.ParamByName('valor').AsString := Valor;
  qryauxlocal.ExecSQL;
end;

function TdmBase.ValidaConexao(
  const HostName, Schema, Database, UserName, Password: string;
  DatabaseType: Integer
): Boolean;
var
  Q: TZQuery;
  Proto: string;
begin
  // 1) grava os parâmetros (os não vazios) + DATABASETYPE sempre
  try
    if Trim(HostName) <> ''  then RegistraParam('HOSTNAME', HostName);
    if Trim(Schema)   <> ''  then RegistraParam('SCHEMA', Schema);
    if Trim(Database) <> ''  then RegistraParam('DATABASE', Database);
    if Trim(UserName) <> ''  then RegistraParam('USER', UserName);
    if Trim(Password) <> ''  then RegistraParam('PASSWORD', Password);
    RegistraParam('DATABASETYPE', IntToStr(DatabaseType));
  except
    Exit(False);
  end;

  // 2) configura e registra a conexão no zcon
  Result := False;
  try
    if zcon.Connected then
      zcon.Disconnect;

    case DatabaseType of
      0: Proto := 'mysql';       // ajuste para 'mysql-8' se você usa client 8.x
      1: Proto := 'postgresql';  // ajuste p/ 'postgresql-12' etc. se preferir
    else
      raise Exception.Create('DATABASETYPE inválido. Use 0=MySQL ou 1=Postgres.');
    end;

    zcon.Protocol := Proto;
    zcon.HostName := HostName;
    zcon.User     := UserName;
    zcon.Password := Password;
    zcon.Database := Database;

    // opcional: zcon.Port se necessário (ex.: 3306/5432)
    // zcon.Port := 5432;

    zcon.Connect;

    // 3) aplica schema se for Postgres e informado
    if (DatabaseType = 1) and (Trim(Schema) <> '') then
    begin
      Q := TZQuery.Create(nil);
      try
        Q.Connection := zcon;
        Q.SQL.Text := 'SET search_path TO ' + Schema;
        Q.ExecSQL;
      finally
        Q.Free;
      end;
    end;

    Result := zcon.Connected;
  except
    on E: Exception do
    begin
      // se quiser, faça log do E.Message
      Result := False;
      // garante estado limpo
      if zcon.Connected then
        zcon.Disconnect;
    end;
  end;
end;



end.

