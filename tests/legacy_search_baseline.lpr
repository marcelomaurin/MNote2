program legacy_search_baseline;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  Classes, SysUtils;

function LegacyCount(const AText, AQuery: string;
  AMatchCase: Boolean): Integer;
var
  SearchPart: string;
  RelativePosition, CurrentPosition, TextLength: Integer;
begin
  Result := 0;
  CurrentPosition := 0;
  TextLength := Length(AText);
  repeat
    SearchPart := Copy(AText, CurrentPosition + 1,
      TextLength - CurrentPosition);
    if AMatchCase then
      RelativePosition := Pos(AQuery, SearchPart)
    else
      RelativePosition := Pos(AnsiUpperCase(AQuery),
        AnsiUpperCase(SearchPart));
    if RelativePosition > 0 then
    begin
      CurrentPosition := CurrentPosition + RelativePosition;
      Inc(Result);
    end
    else
      Break;
  until False;
end;

procedure Measure(const AName, AText, AQuery: string; AMatchCase: Boolean;
  AIterations: Integer);
var
  StartedAt: QWord;
  I, Count: Integer;
begin
  StartedAt := GetTickCount64;
  Count := 0;
  for I := 1 to AIterations do
    Count := LegacyCount(AText, AQuery, AMatchCase);
  Writeln(AName, ': matches=', Count, '; iterations=', AIterations,
    '; elapsed_ms=', GetTickCount64 - StartedAt);
end;

var
  Fixture: TStringList;
begin
  if ParamCount <> 1 then
    raise Exception.Create('Informe o caminho da fixture.');
  Fixture := TStringList.Create;
  try
    Fixture.LoadFromFile(ParamStr(1));
    Measure('literal_case_sensitive', Fixture.Text, 'MNote', True, 200000);
    Measure('literal_case_insensitive', Fixture.Text, 'mnote', False, 200000);
    Measure('multiple_occurrences', Fixture.Text, 'alpha', False, 200000);
  finally
    Fixture.Free;
  end;
end.
