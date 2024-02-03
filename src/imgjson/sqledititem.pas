unit SqlEditItem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TSQLEditItem = class(TObject)
  private
    FNome: string;
    FSQL: string;
    function GetNome: string;
    procedure SetNome(AValue: string);
    function GetSQL: string;
    procedure SetSQL(AValue: string);
  public
    property Nome: string read GetNome write SetNome;
    property SQL: string read GetSQL write SetSQL;
  end;

implementation

function TSQLEditItem.GetNome: string;
begin
  Result := FNome;
end;

procedure TSQLEditItem.SetNome(AValue: string);
begin
  FNome := AValue;
end;

function TSQLEditItem.GetSQL: string;
begin
  Result := FSQL;
end;

procedure TSQLEditItem.SetSQL(AValue: string);
begin
  FSQL := AValue;
end;

end.


