unit view;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, chaves, typeDB;

Type

  { TViews }

  TView = class(TObject)
  private
    ldefinicao : Tstringlist;
    lviewname : string;
    ldatabase : string;
    lTypeDB : TypeDatabase;
    lqry : TZReadOnlyQuery;
  public
    constructor create(zqry :TZReadOnlyQuery; pviewname : string; pDatabasename : string; pTypeDB : TypeDatabase);
    destructor destroy;
    procedure VisualizaViewMy(viewname: string);
    procedure VisualizaViewPost(viewname: string);
    property definicao : TStringlist read ldefinicao;
    property viewname : string read lviewname;

  end;

implementation

{ TView }

constructor TView.create(zqry: TZReadOnlyQuery; pviewname: string;
  pDatabasename: string; pTypeDB: TypeDatabase);
begin
  lviewname := pviewname;
  ldatabase := pDatabasename;
  lTypeDB := pTypeDB;
  ldefinicao := TStringlist.create();
  lqry := zqry;
  if (lTypeDB = DBMysql) then
  begin
    VisualizaViewMy(viewname);
  end;
  if (lTypeDB = DBPostgres) then
  begin
    VisualizaViewPost(viewname);
  end;

end;

destructor TView.destroy();
begin

end;

procedure TView.VisualizaViewMy(viewname: string);
begin
    lqry.close;
    lqry.sql.text := ' SELECT VIEW_DEFINITION FROM INFORMATION_SCHEMA.VIEWS '+
                    ' WHERE TABLE_SCHEMA = "'+ ldatabase +'" '+
                    ' and TABLE_NAME  LIKE "'+ viewname+'"; ';
    lqry.open;
    lqry.first;
    ldefinicao.clear;
    ldefinicao.add(' create or replace view '+viewname + ' AS '+#13);
    ldefinicao.add(lqry.FieldByName('VIEW_DEFINITION').asstring);
end;

procedure TView.VisualizaViewPost(viewname: string);
begin

end;

end.

