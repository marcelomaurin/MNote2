unit mnote_pascal_semantic_resolver;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_completion_types;

type
  { Lightweight semantic resolver for Pascal editor completion. It complements
    the CHATGPT project/agent components with editor-specific type resolution. }
  TMNotePascalSemanticResolver = class
  private
    class function IsIdentChar(AChar: Char): Boolean; static;
    class function ExtractQualifier(const ATextBeforeCursor: string): string; static;
    class function ExtractDeclaredType(const ALine, AName: string): string; static;
    class function ExtractMemberName(const ALine, AKeyword: string): string; static;
    class function FindVariableType(ALines: TStrings; const AName: string): string; static;
    class function FindClassStart(ALines: TStrings; const ATypeName: string): Integer; static;
    class function ExtractAncestor(const AClassLine: string): string; static;
    class procedure AddMember(AItems: TMNoteCompletionItems; const AName,
      ASignature, AFileName: string; ALine: Integer; AKind: TMNoteCompletionKind); static;
    class procedure CollectClassMembers(ALines: TStrings; const ATypeName,
      AFileName: string; AItems: TMNoteCompletionItems; AVisited: TStrings); static;
  public
    class function CollectQualifiedMembers(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems): Boolean; static;
  end;

implementation

class function TMNotePascalSemanticResolver.IsIdentChar(AChar: Char): Boolean;
begin
  Result := AChar in ['A'..'Z', 'a'..'z', '0'..'9', '_'];
end;

class function TMNotePascalSemanticResolver.ExtractQualifier(
  const ATextBeforeCursor: string): string;
var
  I, P: Integer;
begin
  Result := '';
  P := LastDelimiter('.', ATextBeforeCursor);
  if P <= 1 then Exit;
  I := P - 1;
  while (I > 0) and IsIdentChar(ATextBeforeCursor[I]) do Dec(I);
  Result := Copy(ATextBeforeCursor, I + 1, P - I - 1);
end;

class function TMNotePascalSemanticResolver.ExtractDeclaredType(
  const ALine, AName: string): string;
var
  S, LeftSide, RightSide, Candidate: string;
  P, I: Integer;
  Names: TStringList;
begin
  Result := '';
  S := Trim(ALine);
  P := Pos(':', S);
  if P <= 1 then Exit;

  LeftSide := Trim(Copy(S, 1, P - 1));
  RightSide := Trim(Copy(S, P + 1, MaxInt));
  if SameText(Copy(LeftSide, 1, 4), 'var ') then
    Delete(LeftSide, 1, 4);
  if SameText(Copy(LeftSide, 1, 6), 'const ') then Exit;

  Names := TStringList.Create;
  try
    Names.StrictDelimiter := True;
    Names.Delimiter := ',';
    Names.DelimitedText := LeftSide;
    for I := 0 to Names.Count - 1 do
      if SameText(Trim(Names[I]), AName) then
      begin
        Candidate := '';
        I := 1;
        while (I <= Length(RightSide)) and IsIdentChar(RightSide[I]) do
        begin
          Candidate := Candidate + RightSide[I];
          Inc(I);
        end;
        Result := Candidate;
        Exit;
      end;
  finally
    Names.Free;
  end;
end;

class function TMNotePascalSemanticResolver.ExtractMemberName(
  const ALine, AKeyword: string): string;
var
  S: string;
  I, P: Integer;
begin
  Result := '';
  S := Trim(ALine);
  if Pos(LowerCase(AKeyword), LowerCase(S)) <> 1 then Exit;
  I := Length(AKeyword) + 1;
  while (I <= Length(S)) and (S[I] in [' ', #9]) do Inc(I);
  P := I;
  while (I <= Length(S)) and IsIdentChar(S[I]) do Inc(I);
  Result := Copy(S, P, I - P);
end;

class function TMNotePascalSemanticResolver.FindVariableType(ALines: TStrings;
  const AName: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := ALines.Count - 1 downto 0 do
  begin
    Result := ExtractDeclaredType(ALines[I], AName);
    if Result <> '' then Exit;
  end;
end;

class function TMNotePascalSemanticResolver.FindClassStart(ALines: TStrings;
  const ATypeName: string): Integer;
var
  I: Integer;
  S, L, Prefix: string;
begin
  Result := -1;
  Prefix := LowerCase(ATypeName) + ' = class';
  for I := 0 to ALines.Count - 1 do
  begin
    S := Trim(ALines[I]);
    L := LowerCase(S);
    if Pos(Prefix, L) = 1 then Exit(I);
  end;
end;

class function TMNotePascalSemanticResolver.ExtractAncestor(
  const AClassLine: string): string;
var
  S: string;
  P1, P2, I: Integer;
begin
  Result := '';
  S := Trim(AClassLine);
  P1 := Pos('class(', LowerCase(S));
  if P1 = 0 then Exit;
  Inc(P1, Length('class('));
  P2 := Pos(')', Copy(S, P1, MaxInt));
  if P2 <= 1 then Exit;
  S := Trim(Copy(S, P1, P2 - 1));
  I := 1;
  while (I <= Length(S)) and IsIdentChar(S[I]) do
  begin
    Result := Result + S[I];
    Inc(I);
  end;
end;

class procedure TMNotePascalSemanticResolver.AddMember(
  AItems: TMNoteCompletionItems; const AName, ASignature, AFileName: string;
  ALine: Integer; AKind: TMNoteCompletionKind);
var
  Item: TMNoteCompletionItem;
begin
  if (AName = '') or (AItems.FindByInsertText(AName) <> nil) then Exit;
  Item := TMNoteCompletionItem.Create(AName, AKind, 'semantico', 60);
  Item.Signature := Trim(ASignature);
  Item.FileName := AFileName;
  Item.Line := ALine;
  AItems.Add(Item);
end;

class procedure TMNotePascalSemanticResolver.CollectClassMembers(
  ALines: TStrings; const ATypeName, AFileName: string;
  AItems: TMNoteCompletionItems; AVisited: TStrings);
var
  S, L, Name, Ancestor: string;
  I, StartLine, Depth, P: Integer;
  Kind: TMNoteCompletionKind;
begin
  if (Trim(ATypeName) = '') or (AVisited.IndexOf(LowerCase(ATypeName)) >= 0) then Exit;
  AVisited.Add(LowerCase(ATypeName));

  StartLine := FindClassStart(ALines, ATypeName);
  if StartLine < 0 then Exit;

  Ancestor := ExtractAncestor(ALines[StartLine]);
  if Ancestor <> '' then
    CollectClassMembers(ALines, Ancestor, AFileName, AItems, AVisited);

  Depth := 0;
  for I := StartLine + 1 to ALines.Count - 1 do
  begin
    S := Trim(ALines[I]);
    L := LowerCase(S);
    if (S = '') or (S[1] = '{') or (Pos('//', S) = 1) then Continue;
    if L in ['private', 'protected', 'public', 'published', 'strict private',
      'strict protected'] then Continue;

    if Pos('class', L) > 0 then Inc(Depth);
    if L = 'end;' then
    begin
      if Depth = 0 then Break;
      Dec(Depth);
      Continue;
    end;

    Name := '';
    Kind := ckText;
    if Pos('procedure ', L) = 1 then
    begin
      Name := ExtractMemberName(S, 'procedure'); Kind := ckProcedure;
    end
    else if Pos('function ', L) = 1 then
    begin
      Name := ExtractMemberName(S, 'function'); Kind := ckFunction;
    end
    else if Pos('constructor ', L) = 1 then
    begin
      Name := ExtractMemberName(S, 'constructor'); Kind := ckProcedure;
    end
    else if Pos('destructor ', L) = 1 then
    begin
      Name := ExtractMemberName(S, 'destructor'); Kind := ckProcedure;
    end
    else if Pos('property ', L) = 1 then
    begin
      Name := ExtractMemberName(S, 'property'); Kind := ckProperty;
    end
    else
    begin
      P := Pos(':', S);
      if P > 1 then
      begin
        Name := Trim(Copy(S, 1, P - 1));
        if Pos(',', Name) > 0 then
          Name := Trim(Copy(Name, 1, Pos(',', Name) - 1));
        if Pos(' ', Name) = 0 then Kind := ckVariable else Name := '';
      end;
    end;
    AddMember(AItems, Name, S, AFileName, I + 1, Kind);
  end;
end;

class function TMNotePascalSemanticResolver.CollectQualifiedMembers(
  AContext: TMNoteCompletionContext; AItems: TMNoteCompletionItems): Boolean;
var
  Lines, Visited: TStringList;
  Qualifier, TypeName: string;
begin
  Result := False;
  if (AContext = nil) or (AItems = nil) or
    (not SameText(AContext.LanguageID, 'pascal')) then Exit;

  Qualifier := ExtractQualifier(AContext.TextBeforeCursor);
  if Qualifier = '' then Exit;

  Lines := TStringList.Create;
  Visited := TStringList.Create;
  try
    Lines.Text := AContext.DocumentText;
    Visited.CaseSensitive := False;
    Visited.Sorted := True;
    Visited.Duplicates := dupIgnore;

    TypeName := FindVariableType(Lines, Qualifier);
    if TypeName = '' then Exit;
    CollectClassMembers(Lines, TypeName, AContext.FileName, AItems, Visited);
    Result := AItems.Count > 0;
  finally
    Visited.Free;
    Lines.Free;
  end;
end;

end.
