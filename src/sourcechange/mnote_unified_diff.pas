unit mnote_unified_diff;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils;

type
  TMNoteUnifiedDiff = class
  private
    class function Normalize(const AText: string): string; static;
    class function EndsWithLineBreak(const AText: string): Boolean; static;
  public
    class function Generate(const AOldText, ANewText, AFileName: string;
      out AFallbackUsed: Boolean; ACellLimit: Int64 = 1000000): string; static;
    class function HunkCount(const ADiff: string): Integer; static;
    class function SelectHunks(const ADiff: string;
      const ASelected: array of Boolean): string; static;
    class function Apply(const AOldText, ADiff: string;
      out ANewText, AError: string): Boolean; static;
  end;

implementation

class function TMNoteUnifiedDiff.Normalize(const AText: string): string;
begin
  Result := StringReplace(AText, #13#10, #10, [rfReplaceAll]);
  Result := StringReplace(Result, #13, #10, [rfReplaceAll]);
end;

class function TMNoteUnifiedDiff.EndsWithLineBreak(const AText: string): Boolean;
begin
  Result := (AText <> '') and (AText[Length(AText)] in [#10, #13]);
end;

procedure TextToLines(const AText: string; ALines: TStrings);
var
  Normalized: string;
begin
  Normalized := StringReplace(AText, #13#10, #10, [rfReplaceAll]);
  Normalized := StringReplace(Normalized, #13, #10, [rfReplaceAll]);
  if (Normalized <> '') and (Normalized[Length(Normalized)] = #10) then
    Delete(Normalized, Length(Normalized), 1);
  ALines.Text := StringReplace(Normalized, #10, LineEnding, [rfReplaceAll]);
end;

class function TMNoteUnifiedDiff.Generate(const AOldText, ANewText,
  AFileName: string; out AFallbackUsed: Boolean; ACellLimit: Int64): string;
var
  OldLines, NewLines, Operations, Output: TStringList;
  Matrix: array of array of Integer;
  I, J, OldCount, NewCount, HunkStart, HunkEnd, LastChange,
  NextChange, OldBefore, NewBefore, OldInHunk, NewInHunk,
  OldStart, NewStart: Integer;
  EOLName: string;
  NewFinal: Boolean;
begin
  OldLines := TStringList.Create;
  NewLines := TStringList.Create;
  Operations := TStringList.Create;
  Output := TStringList.Create;
  try
    TextToLines(AOldText, OldLines);
    TextToLines(ANewText, NewLines);
    OldCount := OldLines.Count;
    NewCount := NewLines.Count;
    AFallbackUsed := (Int64(OldCount + 1) * Int64(NewCount + 1)) > ACellLimit;
    if not AFallbackUsed then
    begin
      SetLength(Matrix, OldCount + 1, NewCount + 1);
      for I := OldCount - 1 downto 0 do
        for J := NewCount - 1 downto 0 do
          if OldLines[I] = NewLines[J] then Matrix[I, J] := Matrix[I + 1, J + 1] + 1
          else if Matrix[I + 1, J] >= Matrix[I, J + 1] then Matrix[I, J] := Matrix[I + 1, J]
          else Matrix[I, J] := Matrix[I, J + 1];
      I := 0;
      J := 0;
      while (I < OldCount) or (J < NewCount) do
      begin
        if (I < OldCount) and (J < NewCount) and (OldLines[I] = NewLines[J]) then
        begin
          Operations.Add(' ' + OldLines[I]); Inc(I); Inc(J);
        end
        else if (I < OldCount) and ((J >= NewCount) or
          (Matrix[I + 1, J] >= Matrix[I, J + 1])) then
        begin
          Operations.Add('-' + OldLines[I]); Inc(I);
        end
        else
        begin
          Operations.Add('+' + NewLines[J]); Inc(J);
        end;
      end;
    end
    else
    begin
      for I := 0 to OldCount - 1 do Operations.Add('-' + OldLines[I]);
      for I := 0 to NewCount - 1 do Operations.Add('+' + NewLines[I]);
    end;
    if Pos(#13#10, ANewText) > 0 then EOLName := 'CRLF' else EOLName := 'LF';
    NewFinal := EndsWithLineBreak(ANewText);
    Output.Add('--- a/' + AFileName);
    Output.Add('+++ b/' + AFileName);
    Output.Add(Format('# mnote-eol=%s;final=%d;fallback=%d',
      [EOLName, Ord(NewFinal), Ord(AFallbackUsed)]));
    I := 0;
    while I < Operations.Count do
    begin
      while (I < Operations.Count) and (Operations[I][1] = ' ') do Inc(I);
      if I >= Operations.Count then Break;
      HunkStart := I - 3;
      if HunkStart < 0 then HunkStart := 0;
      LastChange := I;
      J := I + 1;
      while J < Operations.Count do
      begin
        NextChange := J;
        while (NextChange < Operations.Count) and
          (Operations[NextChange][1] = ' ') do Inc(NextChange);
        if NextChange >= Operations.Count then Break;
        if NextChange - LastChange - 1 > 6 then Break;
        LastChange := NextChange;
        J := NextChange + 1;
      end;
      HunkEnd := LastChange + 3;
      if HunkEnd >= Operations.Count then HunkEnd := Operations.Count - 1;
      OldBefore := 0;
      NewBefore := 0;
      for J := 0 to HunkStart - 1 do
      begin
        if Operations[J][1] <> '+' then Inc(OldBefore);
        if Operations[J][1] <> '-' then Inc(NewBefore);
      end;
      OldInHunk := 0;
      NewInHunk := 0;
      for J := HunkStart to HunkEnd do
      begin
        if Operations[J][1] <> '+' then Inc(OldInHunk);
        if Operations[J][1] <> '-' then Inc(NewInHunk);
      end;
      if OldInHunk = 0 then OldStart := OldBefore
      else OldStart := OldBefore + 1;
      if NewInHunk = 0 then NewStart := NewBefore
      else NewStart := NewBefore + 1;
      Output.Add(Format('@@ -%d,%d +%d,%d @@',
        [OldStart, OldInHunk, NewStart, NewInHunk]));
      for J := HunkStart to HunkEnd do Output.Add(Operations[J]);
      I := HunkEnd + 1;
    end;
    Result := Output.Text;
  finally
    Output.Free;
    Operations.Free;
    NewLines.Free;
    OldLines.Free;
  end;
end;

class function TMNoteUnifiedDiff.HunkCount(const ADiff: string): Integer;
var
  Lines: TStringList;
  I: Integer;
begin
  Result := 0;
  Lines := TStringList.Create;
  try
    Lines.Text := ADiff;
    for I := 0 to Lines.Count - 1 do
      if Pos('@@ ', Lines[I]) = 1 then Inc(Result);
  finally
    Lines.Free;
  end;
end;

class function TMNoteUnifiedDiff.SelectHunks(const ADiff: string;
  const ASelected: array of Boolean): string;
var
  Lines, SelectedLines: TStringList;
  I, HunkIndex: Integer;
  IncludeLine: Boolean;
begin
  Lines := TStringList.Create;
  SelectedLines := TStringList.Create;
  try
    Lines.Text := ADiff;
    HunkIndex := -1;
    IncludeLine := True;
    for I := 0 to Lines.Count - 1 do
    begin
      if Pos('@@ ', Lines[I]) = 1 then
      begin
        Inc(HunkIndex);
        IncludeLine := (HunkIndex <= High(ASelected)) and
          ASelected[HunkIndex];
      end;
      if IncludeLine then SelectedLines.Add(Lines[I]);
    end;
    Result := SelectedLines.Text;
  finally
    SelectedLines.Free;
    Lines.Free;
  end;
end;

function HeaderStart(const AHeader: string; AOld: Boolean): Integer;
var
  Marker: Char;
  P, Q: Integer;
begin
  if AOld then Marker := '-' else Marker := '+';
  P := Pos(Marker, AHeader);
  if P = 0 then Exit(1);
  Inc(P);
  Q := P;
  while (Q <= Length(AHeader)) and (AHeader[Q] in ['0'..'9']) do Inc(Q);
  Result := StrToIntDef(Copy(AHeader, P, Q - P), 1);
  if Result = 0 then Result := 1;
end;

class function TMNoteUnifiedDiff.Apply(const AOldText, ADiff: string;
  out ANewText, AError: string): Boolean;
var
  OldLines, DiffLines, NewLines: TStringList;
  I, SourceIndex, StartIndex: Integer;
  Line, EOL: string;
  FinalBreak: Boolean;
begin
  Result := False;
  AError := '';
  ANewText := '';
  OldLines := TStringList.Create;
  DiffLines := TStringList.Create;
  NewLines := TStringList.Create;
  try
    TextToLines(AOldText, OldLines);
    DiffLines.Text := ADiff;
    EOL := #10;
    FinalBreak := False;
    SourceIndex := 0;
    I := 0;
    while I < DiffLines.Count do
    begin
      Line := DiffLines[I];
      if Pos('# mnote-eol=', Line) = 1 then
      begin
        if Pos('mnote-eol=CRLF', Line) > 0 then EOL := #13#10;
        FinalBreak := Pos('final=1', Line) > 0;
      end
      else if Pos('@@ ', Line) = 1 then
      begin
        StartIndex := HeaderStart(Line, True) - 1;
        while SourceIndex < StartIndex do
        begin
          NewLines.Add(OldLines[SourceIndex]); Inc(SourceIndex);
        end;
        Inc(I);
        while (I < DiffLines.Count) and (Pos('@@ ', DiffLines[I]) <> 1) do
        begin
          Line := DiffLines[I];
          if Line = '' then Break;
          case Line[1] of
            ' ':
              begin
                if (SourceIndex >= OldLines.Count) or
                  (OldLines[SourceIndex] <> Copy(Line, 2, MaxInt)) then
                begin AError := 'Contexto do patch não coincide.'; Exit; end;
                NewLines.Add(Copy(Line, 2, MaxInt)); Inc(SourceIndex);
              end;
            '-':
              begin
                if (SourceIndex >= OldLines.Count) or
                  (OldLines[SourceIndex] <> Copy(Line, 2, MaxInt)) then
                begin AError := 'Linha removida não coincide.'; Exit; end;
                Inc(SourceIndex);
              end;
            '+': NewLines.Add(Copy(Line, 2, MaxInt));
          else
            Break;
          end;
          Inc(I);
        end;
        Continue;
      end;
      Inc(I);
    end;
    while SourceIndex < OldLines.Count do
    begin
      NewLines.Add(OldLines[SourceIndex]); Inc(SourceIndex);
    end;
    for I := 0 to NewLines.Count - 1 do
    begin
      if I > 0 then ANewText := ANewText + EOL;
      ANewText := ANewText + NewLines[I];
    end;
    if FinalBreak then ANewText := ANewText + EOL;
    Result := True;
  finally
    NewLines.Free;
    DiffLines.Free;
    OldLines.Free;
  end;
end;

end.
