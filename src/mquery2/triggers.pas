unit triggers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, chaves, typeDB;

type


  { TTriggers }

  TTriggers = class(TObject)
    private
      Ltablename : string;



    public
      Triggername : TStringList;
      Source : TStringlist;
      Event : TStringlist;
      Time : TStringlist;
      constructor create(zqry :TZReadOnlyQuery; ptablename: string;
        TypeDB : TypeDatabase);
      property tablename : string read Ltablename;

  end;

implementation

constructor TTriggers.create(zqry: TZReadOnlyQuery; ptablename: string;
  TypeDB: TypeDatabase);
begin
    Triggername := TStringList.create();
    Source := TStringList.create();
    Event := TStringList.create();
    Time :=  TStringList.create();
    Ltablename := ptablename;
    if TypeDB = DBMysql then
       zqry.sql.text := 'select * '+
           ' from information_schema.triggers '+
           ' where event_object_table = "'+Ltablename+'" ';

    if TypeDB = DBPostgres then
          zqry.sql.text := 'select  '+
                 ' trigger_catalog ,'+
                 ' trigger_schema, '+
                 ' trigger_name, '+
                 ' event_manipulation, '+
                 ' event_object_table, '+
                 ' action_statement, '+
                 ' action_timing '+
                 ' from information_schema.triggers '+
                 ' where event_object_table = '+#39+Ltablename+#39+
                 //' group by 1,2,3,4,6 '+
                 ' order by trigger_schema, '+
                 ' trigger_name;' ;


    zqry.Open;
    zqry.first;
    while not zqry.EOF do
        begin
         if TypeDB = DBMysql then
         begin
           Triggername.Add(zqry.FieldByName('trigger_name').asstring);
           Source.Add(zqry.FieldByName('action_statement').asstring);
           Event.Add(zqry.FieldByName('EVENT_MANIPULATION').asstring);
           Time.Add(zqry.FieldByName('action_timing').asstring);
         end;
         if TypeDB = DBPostgres then
         begin
           Triggername.Add(zqry.FieldByName('trigger_name').asstring);
           Source.Add(zqry.FieldByName('action_statement').asstring);
           Event.Add(zqry.FieldByName('EVENT_MANIPULATION').asstring);
           Time.Add(zqry.FieldByName('action_timing').asstring);
         end;
         zqry.Next;
    end;
    zqry.close;
end;


end.

