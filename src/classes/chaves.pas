unit chaves;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, typeDB;

type

{ TChaves }

TChaves = class(TObject)
   private

   public
   tablename : string;
   coinstraintname : TStringList;
   coinstrainttable : TStringList;
   coinstraintcolumn_name : TStringList;
   coinstraint_Reference_schema : TStringList;
   coinstraint_Reference_column_name : TStringList;
   coinstraint_Reference_Table_name : TStringList;

   primarykeys : TStringList;
   constructor create(zqry :TZReadOnlyQuery; ptablename: string; TypeDB : TypeDatabase);
end;

implementation

{ TChaves }


constructor TChaves.create(zqry: TZReadOnlyQuery; ptablename: string; TypeDB : TypeDatabase);
var
   sql : string;
begin
    tablename := ptablename;
    if TypeDB = DBMysql then
       sql := 'select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE where table_name = "'+
        tablename+'" order by ordinal_position';
    if TypeDB = DBPostgres then
       sql := 'select * from INFORMATION_SCHEMA.KEY_COLUMN_USAGE where table_name = '+#39+
             tablename+#39+' order by ordinal_position';

    zqry.SQL.Text:= sql;
    zqry.Open;
    zqry.first;
    coinstraintname := TStringlist.create();
    coinstrainttable := TStringlist.create();
    coinstraintcolumn_name := TStringlist.create();
    coinstraint_Reference_Table_name :=  TStringlist.create();
    coinstraint_Reference_column_name := TStringlist.create();
    coinstraint_Reference_schema := TStringlist.create();
    primarykeys := TStringList.create();
    while not zqry.EOF do
    begin
      if TypeDB = DBMysql then
      begin
         if zqry.FieldByName('constraint_name').asstring = 'PRIMARY' then
         begin
           primarykeys.Add(zqry.FieldByName('column_name').asstring);
         end
          else
         begin
           coinstraintname.add(zqry.FieldByName('constraint_name').asstring);
           coinstrainttable.add(zqry.FieldByName('table_name').asstring);
           coinstraintcolumn_name.add(zqry.FieldByName('column_name').asstring);
           coinstraint_Reference_column_name.add(zqry.FieldByName('referenced_table_name').asstring);
           coinstraint_Reference_Table_name.add(zqry.FieldByName('referenced_column_name').asstring);
           coinstraint_Reference_schema.add(zqry.FieldByName('referenced_table_schema').asstring);
         end;
      end;
      if TypeDB = DBPostgres then
      begin
        if zqry.FieldByName('constraint_name').asstring = 'PRIMARY' then
        begin
          primarykeys.Add(zqry.FieldByName('column_name').asstring);
        end
         else
        begin
          coinstraintname.add(zqry.FieldByName('constraint_name').asstring);
          coinstrainttable.add(zqry.FieldByName('table_name').asstring);
          coinstraintcolumn_name.add(zqry.FieldByName('column_name').asstring);
          //coinstraint_Reference_column_name.add(zqry.FieldByName('referenced_table_name').asstring);
          coinstraint_Reference_column_name.add('');
          //coinstraint_Reference_Table_name.add(zqry.FieldByName('referenced_column_name').asstring);
          coinstraint_Reference_Table_name.add('');
          //coinstraint_Reference_schema.add(zqry.FieldByName('referenced_table_schema').asstring);
          coinstraint_Reference_schema.add('');
        end;
      end;
      zqry.next;
    end;
end;

end.

