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
  end;

var
  dmBase: TdmBase;

implementation

{$R *.lfm}

{ TdmBase }

uses setmain, mquery2;

procedure TdmBase.Connect(Username: string; Password: string; hostname: string;
  Database: string);
begin

  zconlocal.Disconnect;
  zconlocal.User:=  Username;
  zconlocal.Password:= Password;
  zconlocal.HostName:= hostname;
  zconlocal.Database:= Database;
  zconlocal.Connect;

end;

procedure TdmBase.loadlib(path: string);
begin
  //zcon.LibraryLocation :=path;
end;

procedure TdmBase.Close;
begin
  //zcon.Disconnect;
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





end.

