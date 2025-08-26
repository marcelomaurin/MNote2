unit base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, DB;

type

  { TdmBase }

  TdmBase = class(TDataModule)
    DataSource1: TDataSource;
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
    function ConectaSQLite(const ArquivoDB: string): Boolean;
    function SalvarDadosMaster(projeto : string; Proposito: string; target: string; database: integer): boolean;

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

function TdmBase.ConectaSQLite(const ArquivoDB: string): Boolean;
begin
  Result := False;
  try
    if zconlocal.Connected then
      zconlocal.Disconnect;

    zconlocal.Protocol := 'sqlite-3';
    zconlocal.Database := ArquivoDB;
    zconlocal.User := '';  // SQLite não usa usuário normalmente
    zconlocal.Password := '';

    zconlocal.Connect;
    Result := zconlocal.Connected;
  except
    Result := False; // Se der erro, retorna False
  end;
end;

function TdmBase.SalvarDadosMaster(projeto : string; Proposito: string; target: string; database: integer): boolean;
begin
end;


end.

