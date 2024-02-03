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
    zqryaux: TZQuery;
    zqryaux1: TZQuery;
    zqryaux2: TZQuery;
  private

  public
    procedure Connect( Username : string; Password : string; hostname: string; Database: string);
    procedure loadlib(path : string);
    procedure Close();


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


end.

