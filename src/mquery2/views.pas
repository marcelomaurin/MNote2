unit Views;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils, ZConnection, ZDataset, chaves, typeDB;

Type

  { TViews }

  TViews = class(TObject)
  private
    qry: TZReadOnlyQuery;

  public
    items : TStringlist;
    database_name :string;
    constructor create(zqry :TZReadOnlyQuery; Databasename : string; TypeDB : TypeDatabase);
    destructor destroy();
    procedure CarregarMyViews();
    procedure CarregarPostgresViews;

end;



implementation

{ TViews }

constructor TViews.create(zqry: TZReadOnlyQuery; Databasename : string; TypeDB: TypeDatabase);
begin
   items := TStringlist.create();
   qry := zqry;
   database_name:= Databasename;
   if (TypeDB = DBMysql) then
   begin
     CarregarMyViews();
   end;
   if (TypeDB = DBPostgres) then
   begin
     CarregarPostgresViews();

   end;
end;

destructor TViews.destroy();
begin
  items.destroy;
end;

procedure TViews.CarregarMyViews();
begin
    qry.close;
    qry.sql.text := ' SELECT table_name, TABLE_SCHEMA '+
                    ' FROM information_schema.tables  '+
                    ' WHERE TABLE_TYPE  LIKE "VIEW" '+
                    ' and TABLE_SCHEMA LIKE "'+ database_name+'"; ';
    qry.open;
    qry.first;
    while not qry.EOF do
    begin
      items.Add(qry.FieldByName('table_name').asstring);
      qry.next;
    end;
end;

procedure TViews.CarregarPostgresViews;
begin
   qry.close;
   qry.sql.text := 'select schemaname, viewname from pg_catalog.pg_views '+
                   ' where schemaname NOT IN ('+#39+'pg_catalog'+#39+', '+#39+'information_schema'+#39+')'+
                   ' order by schemaname, viewname; ';
   qry.open;
   qry.first;
   while not qry.EOF do
   begin
     items.Add(qry.FieldByName('viewname').asstring);
     qry.next;
   end;
end;



end.

