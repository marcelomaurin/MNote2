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
    class procedure AddMember(AItems: TMNoteCompletionItems; const AName,
      ASignature, AFileName: string; ALine: Integer; AKind: TMNoteCompletionKind); static;
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
  S, L, Needle: string;
  P, I: Integer;
begin
  Result := '';
  S := Trim(ALine);
  L := LowerCase(S);
  Needle := LowerCase(AName);
  P := Pos(Needle, L);
  if P <= 0 then Exit;
  if (P > 1) and IsIdentChar(S[P - 1]) then Exit;
  I := P + Length(AName);
  if (I <= Length(S)) and IsIdentChar(S[I]) then Exit;
  while (I <= Length(S)) and (S[I] in [' ', #9]) do Inc(I);
  if (I > Length(S)) or (S[I] <> ':') then Exit;
  Inc(I);
  while (I <= Length(S)) and (S[I] in [' ', #9]) do Inc(I);
  P := I;
  while (I <= Length(S)) and IsIdentChar(S[I]) do Inc(I);
  Result := Copy(S, P, I - P);
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

class function TMNotePascalSemanticResolver.CollectQualifiedMembers(
  AContext: TMNoteCompletionContext; AItems: TMNoteCompletionItems): Boolean;
var
  Lines: TStringList;
  Qualifier, TypeName, S, L, Name: string;
  I, StartLine, Depth, P: Integer;
  Kind: TMNoteCompletionKind;
begin
  Result := False;
  if (AContext = nil) or (AItems = nil) or
    (not SameText(AContext.LanguageID, 'pascal')) then Exit;
  Qualifier := ExtractQualifier(AContext.TextBeforeCursor);
  if Qualifier = '' then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := AContext.DocumentText;
    TypeName := FindVariableType(Lines, Qualifier);
    if TypeName = '' then Exit;
    StartLine := FindClassStart(Lines, TypeName);
    if StartLine < 0 then Exit;

    Depth := 0;
    for I := StartLine + 1 to Lines.Count - 1 do
    begin
      S := Trim(Lines[I]);
      L := LowerCase(S);
      if Pos('class', L) > 0 then Inc(Depth);
      if (L = 'end;') then
      begin
        if Depth = 0 then Break;
        Dec(Depth);
      end;
      if (S = '') or (S[1] = '{') or (Pos('//', S) = 1) then Continue;

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
          if (Pos(' ', Name) = 0) and (Pos(',', Name) = 0) then Kind := ckVariable
          else Name := '';
        end;
      end;
      AddMember(AItems, Name, S, AContext.FileName, I + 1, Kind);
    end;
    Result := AItems.Count > 0;
  finally
    Lines.Free;
  end;
end;

end.
