unit mnote_pascal_symbol_parser;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_completion_types;

type
  { TMNotePascalSymbolParser }

  TMNotePascalSymbolParser = class
  private
    FMaxLines: Integer;
    function StripCommentsAndStrings(const ALine: string;
      var AInBraceComment, AInParenComment: Boolean): string;
    function ExtractNameAfter(const ALine, AKeyword: string): string;
  public
    constructor Create;
    procedure Parse(const AText, AFileName, AOrigin: string;
      AItems: TMNoteCompletionItems);
    property MaxLines: Integer read FMaxLines write FMaxLines;
  end;

implementation

function IsIdentifierCharacter(AChar: Char): Boolean;
begin
  Result := AChar in ['A'..'Z', 'a'..'z', '0'..'9', '_', '.'];
end;

constructor TMNotePascalSymbolParser.Create;
begin
  inherited Create;
  FMaxLines := 200000;
end;

function TMNotePascalSymbolParser.StripCommentsAndStrings(
  const ALine: string; var AInBraceComment, AInParenComment: Boolean): string;
var
  I: Integer;
  InString: Boolean;
begin
  Result := '';
  I := 1;
  InString := False;
  while I <= Length(ALine) do
  begin
    if AInBraceComment then
    begin
      if ALine[I] = '}' then AInBraceComment := False;
      Result := Result + ' ';
      Inc(I);
      Continue;
    end;
    if AInParenComment then
    begin
      if (ALine[I] = '*') and (I < Length(ALine)) and
        (ALine[I + 1] = ')') then
      begin
        Result := Result + '  ';
        Inc(I, 2);
        AInParenComment := False;
      end
      else
      begin
        Result := Result + ' ';
        Inc(I);
      end;
      Continue;
    end;
    if not InString and (ALine[I] = '/') and (I < Length(ALine)) and
      (ALine[I + 1] = '/') then
    begin
      Result := Result + StringOfChar(' ', Length(ALine) - I + 1);
      Break;
    end;
    if not InString and (ALine[I] = '{') then
    begin
      AInBraceComment := True;
      Result := Result + ' ';
      Inc(I);
      Continue;
    end;
    if not InString and (ALine[I] = '(') and (I < Length(ALine)) and
      (ALine[I + 1] = '*') then
    begin
      AInParenComment := True;
      Result := Result + '  ';
      Inc(I, 2);
      Continue;
    end;
    if ALine[I] = '''' then
    begin
      Result := Result + ' ';
      if InString and (I < Length(ALine)) and (ALine[I + 1] = '''') then
      begin
        Result := Result + ' ';
        Inc(I, 2);
        Continue;
      end;
      InString := not InString;
      Inc(I);
      Continue;
    end;
    if InString then Result := Result + ' ' else Result := Result + ALine[I];
    Inc(I);
  end;
end;

function TMNotePascalSymbolParser.ExtractNameAfter(const ALine,
  AKeyword: string): string;
var
  I, StartIndex: Integer;
begin
  Result := '';
  I := Length(AKeyword) + 1;
  while (I <= Length(ALine)) and (ALine[I] in [' ', #9]) do Inc(I);
  StartIndex := I;
  while (I <= Length(ALine)) and IsIdentifierCharacter(ALine[I]) do Inc(I);
  Result := Copy(ALine, StartIndex, I - StartIndex);
  if Pos('.', Result) > 0 then
    Result := Copy(Result, LastDelimiter('.', Result) + 1, MaxInt);
end;

procedure TMNotePascalSymbolParser.Parse(const AText, AFileName,
  AOrigin: string; AItems: TMNoteCompletionItems);
var
  Lines: TStringList;
  I, SeparatorPosition: Integer;
  CleanLine, TrimmedLine, LowerLine, Name, SectionName: string;
  InBraceComment, InParenComment: Boolean;
  Kind: TMNoteCompletionKind;
  Item: TMNoteCompletionItem;

  procedure AddSymbol(const ASymbolName: string; ASymbolKind: TMNoteCompletionKind);
  begin
    if (ASymbolName = '') or (AItems.FindByInsertText(ASymbolName) <> nil) then
      Exit;
    Item := TMNoteCompletionItem.Create(ASymbolName, ASymbolKind, AOrigin, 20);
    Item.Signature := TrimmedLine;
    Item.FileName := AFileName;
    Item.Line := I + 1;
    AItems.Add(Item);
  end;

begin
  Lines := TStringList.Create;
  try
    Lines.Text := AText;
    InBraceComment := False;
    InParenComment := False;
    SectionName := '';
    for I := 0 to Lines.Count - 1 do
    begin
      if I >= FMaxLines then Break;
      CleanLine := StripCommentsAndStrings(Lines[I], InBraceComment,
        InParenComment);
      TrimmedLine := Trim(CleanLine);
      LowerLine := LowerCase(TrimmedLine);
      if LowerLine = '' then Continue;

      if (LowerLine = 'const') or (Pos('const ', LowerLine) = 1) then
        SectionName := 'const'
      else if (LowerLine = 'var') or (Pos('var ', LowerLine) = 1) then
        SectionName := 'var'
      else if (LowerLine = 'type') or (Pos('type ', LowerLine) = 1) then
        SectionName := 'type'
      else if (LowerLine = 'begin') or (Pos('begin ', LowerLine) = 1) or
        (LowerLine = 'implementation') or (LowerLine = 'interface') or
        (LowerLine = 'uses') then
        SectionName := '';

      Kind := ckText;
      Name := '';
      if Pos('unit ', LowerLine) = 1 then
      begin
        Kind := ckUnit;
        Name := ExtractNameAfter(TrimmedLine, 'unit');
      end
      else if Pos('procedure ', LowerLine) = 1 then
      begin
        Kind := ckProcedure;
        Name := ExtractNameAfter(TrimmedLine, 'procedure');
      end
      else if Pos('class procedure ', LowerLine) = 1 then
      begin
        Kind := ckProcedure;
        Name := ExtractNameAfter(TrimmedLine, 'class procedure');
      end
      else if Pos('function ', LowerLine) = 1 then
      begin
        Kind := ckFunction;
        Name := ExtractNameAfter(TrimmedLine, 'function');
      end
      else if Pos('class function ', LowerLine) = 1 then
      begin
        Kind := ckFunction;
        Name := ExtractNameAfter(TrimmedLine, 'class function');
      end
      else if Pos('property ', LowerLine) = 1 then
      begin
        Kind := ckProperty;
        Name := ExtractNameAfter(TrimmedLine, 'property');
      end
      else if Pos('=', TrimmedLine) > 1 then
      begin
        SeparatorPosition := Pos('=', TrimmedLine);
        Name := Trim(Copy(TrimmedLine, 1, SeparatorPosition - 1));
        if Pos('class', LowerLine) > SeparatorPosition then Kind := ckClass
        else if Pos('record', LowerLine) > SeparatorPosition then Kind := ckRecord
        else if SectionName = 'const' then Kind := ckConstant
        else Name := '';
      end
      else if (SectionName = 'var') and (Pos(':', TrimmedLine) > 1) then
      begin
        SeparatorPosition := Pos(':', TrimmedLine);
        Name := Trim(Copy(TrimmedLine, 1, SeparatorPosition - 1));
        if Pos(',', Name) = 0 then Kind := ckVariable else Name := '';
      end;
      AddSymbol(Name, Kind);
    end;
  finally
    Lines.Free;
  end;
end;

end.
