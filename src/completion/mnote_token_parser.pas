unit mnote_token_parser;

{$mode objfpc}{$H+}

interface

type
  TMNoteTokenParser = class
  public
    class function CurrentToken(const ATextBeforeCursor,
      ATokenCharacters: string): string; static;
  end;

implementation

function IsTokenCharacter(AChar: Char; const AExtraCharacters: string): Boolean;
begin
  Result := (AChar in ['A'..'Z', 'a'..'z', '0'..'9', '_']) or
    (Pos(AChar, AExtraCharacters) > 0) or (AChar in ['''', '"']);
end;

class function TMNoteTokenParser.CurrentToken(const ATextBeforeCursor,
  ATokenCharacters: string): string;
var
  StartIndex: Integer;
begin
  StartIndex := Length(ATextBeforeCursor);
  while StartIndex > 0 do
  begin
    if IsTokenCharacter(ATextBeforeCursor[StartIndex], ATokenCharacters) then
      Dec(StartIndex)
    else if (ATextBeforeCursor[StartIndex] = '>') and (StartIndex > 1) and
      (ATextBeforeCursor[StartIndex - 1] = '-') then
      Dec(StartIndex, 2)
    else
      Break;
  end;
  Result := Copy(ATextBeforeCursor, StartIndex + 1, MaxInt);
  while (Length(Result) > 0) and
    (Result[1] in ['''', '"']) do Delete(Result, 1, 1);
end;

end.
