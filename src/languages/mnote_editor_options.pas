unit mnote_editor_options;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_language_profile;

type
  TMNoteEditorOptions = class
  public
    class function ToggleLineComments(const AText: string;
      AProfile: TMNoteLanguageProfile): string; static;
  end;

implementation

class function TMNoteEditorOptions.ToggleLineComments(const AText: string;
  AProfile: TMNoteLanguageProfile): string;
var
  Lines: TStringList;
  I, FirstNonSpace: Integer;
  AllCommented: Boolean;
  LineText, Prefix, SourceLineBreak: string;
begin
  Result := AText;
  if (AProfile = nil) or (AProfile.LineComment = '') then Exit;
  Lines := TStringList.Create;
  try
    if Pos(#13#10, AText) > 0 then
      SourceLineBreak := #13#10
    else if Pos(#10, AText) > 0 then
      SourceLineBreak := #10
    else if Pos(#13, AText) > 0 then
      SourceLineBreak := #13
    else
      SourceLineBreak := LineEnding;
    Lines.LineBreak := SourceLineBreak;
    Lines.Text := AText;
    AllCommented := True;
    for I := 0 to Lines.Count - 1 do
    begin
      LineText := Lines[I];
      if Trim(LineText) = '' then Continue;
      FirstNonSpace := 1;
      while (FirstNonSpace <= Length(LineText)) and
        (LineText[FirstNonSpace] in [' ', #9]) do Inc(FirstNonSpace);
      if Copy(LineText, FirstNonSpace,
        Length(AProfile.LineComment)) <> AProfile.LineComment then
        AllCommented := False;
    end;
    for I := 0 to Lines.Count - 1 do
    begin
      LineText := Lines[I];
      if Trim(LineText) = '' then Continue;
      FirstNonSpace := 1;
      while (FirstNonSpace <= Length(LineText)) and
        (LineText[FirstNonSpace] in [' ', #9]) do Inc(FirstNonSpace);
      Prefix := Copy(LineText, 1, FirstNonSpace - 1);
      Delete(LineText, 1, FirstNonSpace - 1);
      if AllCommented then
      begin
        Delete(LineText, 1, Length(AProfile.LineComment));
        if (LineText <> '') and (LineText[1] = ' ') then Delete(LineText, 1, 1);
      end
      else
        LineText := AProfile.LineComment + ' ' + LineText;
      Lines[I] := Prefix + LineText;
    end;
    Result := Lines.Text;
    if (AText <> '') and not (AText[Length(AText)] in [#10, #13]) then
      while (Result <> '') and (Result[Length(Result)] in [#10, #13]) do
        Delete(Result, Length(Result), 1);
  finally
    Lines.Free;
  end;
end;

end.
