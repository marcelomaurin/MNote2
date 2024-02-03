unit Tabela;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, chaves, typeDB;


type

  { TForm1 }


  TTabela = class(TObject)
    private

    public
      tablename : string;
      fieldname : TStringList;
      fieldtype : TStringList;
      fieldstrtam : TStringList;
      fieldbintam : TStringList;
      fieldnro_precision : TStringList;


      fieldcomment : TStringList;
      fieldnullable : TStringList;
      fieldcolumnkey : TStringList;
      chaves : TChaves;
      count : integer;
      constructor create(zqry :TZReadOnlyQuery; ptablename: string; TypeDB : TypeDatabase);
  end;

implementation


constructor TTabela.create(zqry :TZReadOnlyQuery; ptablename: string; TypeDB : TypeDatabase);
var
  sql : string;
begin
    tablename := ptablename;
    fieldname := TStringList.create();
    fieldtype := TStringList.create();
    fieldstrtam := TStringList.create();
    fieldbintam := TStringList.create();
    fieldnullable := TStringList.create();
    fieldcolumnkey := TStringList.create();
    fieldnro_precision := TStringList.create();


    fieldcomment := TstringList.create();
    if TypeDB = DBMysql then
       sql := 'select * from information_schema.COLUMNS where table_name = "'+tablename+'" order by ordinal_position';
    if TypeDB = DBPostgres then
       sql := 'select * from information_schema.COLUMNS where table_name = '+#39+tablename+#39+' order by ordinal_position';

    zqry.SQL.Text:= sql;
    zqry.Open;
    zqry.first;
    while not zqry.EOF do
    begin
     if TypeDB = DBMysql then
     begin
       fieldname.Add(zqry.FieldByName('COLUMN_NAME').asstring);
       fieldnullable.Add(zqry.FieldByName('IS_NULLABLE').asstring);
       fieldtype.Add(zqry.FieldByName('data_type').asstring);
       fieldstrtam.add(zqry.FieldByName('CHARACTER_MAXIMUM_LENGTH').asstring);
       fieldbintam.add(zqry.FieldByName('NUMERIC_SCALE').asstring);
       fieldnro_precision.add(zqry.FieldByName('NUMERIC_PRECISION').asstring);

       fieldcolumnkey.add(zqry.FieldByName('Column_key').asstring);
       fieldcomment.add(zqry.FieldByName('column_comment').asstring);
     end;
     if TypeDB = DBPostgres then
     begin
       fieldname.Add(zqry.FieldByName('COLUMN_NAME').asstring);
       fieldnullable.Add(zqry.FieldByName('IS_NULLABLE').asstring);
       fieldtype.Add(zqry.FieldByName('data_type').asstring);
       fieldstrtam.add(zqry.FieldByName('CHARACTER_MAXIMUM_LENGTH').asstring);
       fieldbintam.add(zqry.FieldByName('NUMERIC_SCALE').asstring);
       fieldnro_precision.add(zqry.FieldByName('NUMERIC_PRECISION').asstring);

       //fieldcolumnkey.add(zqry.FieldByName('Column_key').asstring);
       //fieldcomment.add(zqry.FieldByName('column_comment').asstring);

     end;
     zqry.next;
    end;
    count := fieldname.Count;
    zqry.close;
    if TypeDB = DBMysql then
    begin
       chaves := TChaves.Create(zqry, ptablename,TypeDB);
    end;
    if TypeDB = DBPostgres then
    begin
       chaves := TChaves.Create(zqry, ptablename,TypeDB);
    end;



end;

end.

