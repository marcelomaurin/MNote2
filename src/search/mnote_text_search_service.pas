unit mnote_text_search_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_service_base, mnote_search_types;

type
  { TMNoteTextSearchService }

  TMNoteTextSearchService = class(TMNoteServiceBase)
  private
    function IsWholeWord(const ALine: string; AColumn,
      AMatchLength: Integer; const AOptions: TMNoteSearchOptions): Boolean;
    procedure SearchLineLiteral(const ALine, AQuery, AFileName: string;
      ALineNumber: Integer; ALineAbsoluteIndex: Int64;
      const AOptions: TMNoteSearchOptions; AResults: TMNoteSearchResults);
    function SearchLineRegex(const ALine, AQuery, AFileName: string;
      ALineNumber: Integer; ALineAbsoluteIndex: Int64;
      const AOptions: TMNoteSearchOptions; AResults: TMNoteSearchResults): Boolean;
  public
    function SearchText(const AText, AQuery, AFileName: string;
      const AOptions: TMNoteSearchOptions;
      AResults: TMNoteSearchResults): Boolean;
    function ReplaceText(const AText, AQuery, AReplacement: string;
      const AOptions: TMNoteSearchOptions; out ANewText: string;
      out AReplaceCount: Integer): Boolean;
    function ResolveReplacement(const AMatchedText, AQuery,
      AReplacement: string; const AOptions: TMNoteSearchOptions;
      out AResolved: string): Boolean;
  end;

implementation

uses
  StrUtils, RegExpr, LazUTF8;

type
  TReplacementRange = record
    ByteStart: Integer;
    ByteLength: Integer;
    Replacement: string;
  end;

  TReplacementRanges = array of TReplacementRange;

function LogicalColumnFromByteIndex(const AText: string;
  AByteIndex: Integer): Integer;
begin
  if AByteIndex <= 1 then
    Exit(1);
  Result := UTF8Length(Copy(AText, 1, AByteIndex - 1)) + 1;
end;

function ByteIndexFromLogicalColumn(const AText: string;
  AColumn: Integer): Integer;
begin
  if AColumn <= 1 then
    Exit(1);
  Result := Length(UTF8Copy(AText, 1, AColumn - 1)) + 1;
end;

function IsConfiguredWordChar(const ACharacter: string;
  const AOptions: TMNoteSearchOptions): Boolean;
var
  B: Byte;
begin
  if ACharacter = '' then Exit(False);
  B := Byte(ACharacter[1]);
  Result := (ACharacter[1] in ['a'..'z', 'A'..'Z', '0'..'9']) or
    (Pos(ACharacter, AOptions.WordCharacters) > 0) or (B >= $80);
end;

function IsWholeWordAtByteRange(const AText: string; AByteStart,
  AByteLength: Integer; const AOptions: TMNoteSearchOptions): Boolean;
var
  CharacterStart: Integer;
  PreviousCharacter, NextCharacter: string;
begin
  PreviousCharacter := '';
  NextCharacter := '';
  if AByteStart > 1 then
  begin
    CharacterStart := AByteStart - 1;
    while (CharacterStart > 1) and
      ((Byte(AText[CharacterStart]) and $C0) = $80) do
      Dec(CharacterStart);
    PreviousCharacter := Copy(AText, CharacterStart,
      AByteStart - CharacterStart);
  end;
  if AByteStart + AByteLength <= Length(AText) then
    NextCharacter := UTF8Copy(Copy(AText, AByteStart + AByteLength,
      MaxInt), 1, 1);
  Result := (not IsConfiguredWordChar(PreviousCharacter, AOptions)) and
    (not IsConfiguredWordChar(NextCharacter, AOptions));
end;

function TMNoteTextSearchService.IsWholeWord(const ALine: string;
  AColumn, AMatchLength: Integer;
  const AOptions: TMNoteSearchOptions): Boolean;
var
  PreviousCharacter, NextCharacter: string;
begin
  PreviousCharacter := '';
  NextCharacter := '';
  if AColumn > 1 then
    PreviousCharacter := UTF8Copy(ALine, AColumn - 1, 1);
  if AColumn + AMatchLength <= UTF8Length(ALine) then
    NextCharacter := UTF8Copy(ALine, AColumn + AMatchLength, 1);
  Result := (not IsConfiguredWordChar(PreviousCharacter, AOptions)) and
    (not IsConfiguredWordChar(NextCharacter, AOptions));
end;

procedure TMNoteTextSearchService.SearchLineLiteral(const ALine, AQuery,
  AFileName: string; ALineNumber: Integer; ALineAbsoluteIndex: Int64;
  const AOptions: TMNoteSearchOptions; AResults: TMNoteSearchResults);
var
  SearchLine, SearchQuery, MatchedText: string;
  SearchFrom, MatchByte, OriginalByte, Column, MatchLength: Integer;
begin
  if AOptions.MatchCase then
  begin
    SearchLine := ALine;
    SearchQuery := AQuery;
  end
  else
  begin
    SearchLine := UTF8LowerCase(ALine);
    SearchQuery := UTF8LowerCase(AQuery);
  end;
  SearchFrom := 1;
  while SearchFrom <= Length(SearchLine) do
  begin
    MatchByte := PosEx(SearchQuery, SearchLine, SearchFrom);
    if MatchByte = 0 then Break;
    Column := LogicalColumnFromByteIndex(SearchLine, MatchByte);
    MatchLength := UTF8Length(SearchQuery);
    OriginalByte := ByteIndexFromLogicalColumn(ALine, Column);
    MatchedText := UTF8Copy(ALine, Column, MatchLength);
    if (not AOptions.WholeWord) or
      IsWholeWord(ALine, Column, MatchLength, AOptions) then
      AResults.Add(TMNoteSearchResult.Create(AFileName, ALineNumber,
        Column, MatchLength, Trim(ALine), MatchedText,
        ALineAbsoluteIndex + OriginalByte - 1));
    SearchFrom := MatchByte + Length(SearchQuery);
    if Length(SearchQuery) = 0 then Inc(SearchFrom);
  end;
end;

function TMNoteTextSearchService.SearchLineRegex(const ALine, AQuery,
  AFileName: string; ALineNumber: Integer; ALineAbsoluteIndex: Int64;
  const AOptions: TMNoteSearchOptions; AResults: TMNoteSearchResults): Boolean;
var
  Expression: TRegExpr;
  Column, MatchLength: Integer;
begin
  Result := False;
  Expression := nil;
  try
    Expression := TRegExpr.Create(AQuery);
    Expression.ModifierI := not AOptions.MatchCase;
    if Expression.Exec(ALine) then
      repeat
        Column := LogicalColumnFromByteIndex(ALine, Expression.MatchPos[0]);
        MatchLength := UTF8Length(Expression.Match[0]);
        if (not AOptions.WholeWord) or
          IsWholeWord(ALine, Column, MatchLength, AOptions) then
          AResults.Add(TMNoteSearchResult.Create(AFileName, ALineNumber,
            Column, MatchLength, Trim(ALine), Expression.Match[0],
            ALineAbsoluteIndex + Expression.MatchPos[0] - 1));
      until not Expression.ExecNext;
    Result := True;
  except
    on E: Exception do
      SetError('Expressão regular inválida: ' + E.Message);
  end;
  Expression.Free;
end;

function TMNoteTextSearchService.SearchText(const AText, AQuery,
  AFileName: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults): Boolean;
var
  LineText: string;
  TextIndex, LineStart, LineNumber: Integer;
begin
  ClearError;
  Result := False;
  if AResults = nil then
  begin
    SetError('A coleção de resultados não foi informada.');
    Exit;
  end;
  AResults.Clear;
  if AQuery = '' then
  begin
    SetError('O texto de pesquisa não pode ser vazio.');
    Exit;
  end;

  TextIndex := 1;
  LineNumber := 1;
  while TextIndex <= Length(AText) + 1 do
  begin
    LineStart := TextIndex;
    while (TextIndex <= Length(AText)) and
      not (AText[TextIndex] in [#10, #13]) do
      Inc(TextIndex);
    LineText := Copy(AText, LineStart, TextIndex - LineStart);
    if AOptions.RegularExpression then
    begin
      if not SearchLineRegex(LineText, AQuery, AFileName, LineNumber,
        LineStart, AOptions, AResults) then Exit;
    end
    else
      SearchLineLiteral(LineText, AQuery, AFileName, LineNumber,
        LineStart, AOptions, AResults);

    if TextIndex > Length(AText) then Break;
    if (AText[TextIndex] = #13) and (TextIndex < Length(AText)) and
      (AText[TextIndex + 1] = #10) then
      Inc(TextIndex, 2)
    else
      Inc(TextIndex);
    Inc(LineNumber);
  end;
  Result := True;
end;

function TMNoteTextSearchService.ReplaceText(const AText, AQuery,
  AReplacement: string; const AOptions: TMNoteSearchOptions;
  out ANewText: string; out AReplaceCount: Integer): Boolean;
var
  Results: TMNoteSearchResults;
  Expression: TRegExpr;
  I, ByteStart, ByteLength: Integer;
  Ranges: TReplacementRanges;
begin
  ClearError;
  ANewText := AText;
  AReplaceCount := 0;
  SetLength(Ranges, 0);
  Results := TMNoteSearchResults.Create;
  try
    if AOptions.RegularExpression then
    begin
      Expression := nil;
      try
        Expression := TRegExpr.Create(AQuery);
        Expression.ModifierI := not AOptions.MatchCase;
        if Expression.Exec(AText) then
          repeat
            if (not AOptions.WholeWord) or
              IsWholeWordAtByteRange(AText, Expression.MatchPos[0],
                Expression.MatchLen[0], AOptions) then
            begin
              SetLength(Ranges, Length(Ranges) + 1);
              Ranges[High(Ranges)].ByteStart := Expression.MatchPos[0];
              Ranges[High(Ranges)].ByteLength := Expression.MatchLen[0];
              Ranges[High(Ranges)].Replacement :=
                Expression.Substitute(AReplacement);
            end;
          until not Expression.ExecNext;
      except
        on E: Exception do
        begin
          SetError('Falha ao substituir expressão regular: ' + E.Message);
          Exit(False);
        end;
      end;
      Expression.Free;
      AReplaceCount := Length(Ranges);
      for I := High(Ranges) downto 0 do
      begin
        Delete(ANewText, Ranges[I].ByteStart, Ranges[I].ByteLength);
        Insert(Ranges[I].Replacement, ANewText, Ranges[I].ByteStart);
      end;
    end
    else
    begin
      if not SearchText(AText, AQuery, '', AOptions, Results) then Exit(False);
      AReplaceCount := Results.Count;
      for I := Results.Count - 1 downto 0 do
      begin
        ByteStart := Results[I].AbsoluteIndex;
        ByteLength := Length(Results[I].MatchedText);
        Delete(ANewText, ByteStart, ByteLength);
        Insert(AReplacement, ANewText, ByteStart);
      end;
    end;
    Result := True;
  finally
    Results.Free;
  end;
end;

function TMNoteTextSearchService.ResolveReplacement(const AMatchedText,
  AQuery, AReplacement: string; const AOptions: TMNoteSearchOptions;
  out AResolved: string): Boolean;
var
  Expression: TRegExpr;
begin
  ClearError;
  AResolved := AReplacement;
  if not AOptions.RegularExpression then Exit(True);
  Expression := nil;
  try
    try
      Expression := TRegExpr.Create(AQuery);
      Expression.ModifierI := not AOptions.MatchCase;
      if not Expression.Exec(AMatchedText) then
      begin
        SetError('A ocorrência atual não corresponde mais à expressão.');
        Exit(False);
      end;
      AResolved := Expression.Substitute(AReplacement);
      Result := True;
    except
      on E: Exception do
      begin
        SetError('Falha ao resolver grupos de captura: ' + E.Message);
        Result := False;
      end;
    end;
  finally
    Expression.Free;
  end;
end;

end.
