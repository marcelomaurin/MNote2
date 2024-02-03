unit SQLItem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  // TSQLItem descende de TObject
  TSQLItem = class(TObject)
  private
    FNome: string;
    FSQL: TStringList;
    procedure SetNome(const Value: string);
    procedure SetSQL(const Value: TStringList);
  public
    constructor Create;
    destructor Destroy; override;

    property Nome: string read FNome write SetNome;
    property SQL: TStringList read FSQL write SetSQL;
  end;

implementation

constructor TSQLItem.Create;
begin
  inherited Create;
  FSQL := TStringList.Create;
end;

destructor TSQLItem.Destroy;
begin
  FSQL.Free;
  inherited Destroy;
end;

procedure TSQLItem.SetNome(const Value: string);
begin
  FNome := Value;
end;

procedure TSQLItem.SetSQL(const Value: TStringList);
begin
  FSQL.Assign(Value);
end;

end.

