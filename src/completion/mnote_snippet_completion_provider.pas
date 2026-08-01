unit mnote_snippet_completion_provider;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_completion_types, mnote_completion_provider;

type
  { TMNoteSnippetCompletionProvider }

  TMNoteSnippetCompletionProvider = class(TInterfacedObject,
    IMNoteCompletionProvider)
  public
    function Supports(AContext: TMNoteCompletionContext): Boolean;
    procedure Collect(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems);
    function ResolveDocumentation(AItem: TMNoteCompletionItem): string;
    class function Expand(const ASnippet: string;
      out ACursorOffset: Integer): string; static;
  end;

implementation

procedure AddSnippet(AItems: TMNoteCompletionItems; const AName,
  ABody, ADocumentation: string);
var
  Item: TMNoteCompletionItem;
begin
  Item := TMNoteCompletionItem.Create(AName, ckSnippet, 'snippets', 15);
  Item.InsertText := ABody;
  Item.Documentation := ADocumentation;
  AItems.Add(Item);
end;

function TMNoteSnippetCompletionProvider.Supports(
  AContext: TMNoteCompletionContext): Boolean;
begin
  Result := AContext <> nil;
end;

procedure TMNoteSnippetCompletionProvider.Collect(
  AContext: TMNoteCompletionContext; AItems: TMNoteCompletionItems);
begin
  if SameText(AContext.LanguageID, 'pascal') then
  begin
    AddSnippet(AItems, 'class', '${1:TMinhaClasse} = class'#10+
      'private'#10+'public'#10+'end;', 'Declaração de classe Pascal');
    AddSnippet(AItems, 'procedure', 'procedure ${1:Nome};'#10+'begin'#10+
      '  $0'#10+'end;', 'Corpo de procedure Pascal');
    AddSnippet(AItems, 'tryfinally', 'try'#10+'  ${1:Codigo}'#10+'finally'#10+
      '  $0'#10+'end;', 'Bloco try/finally Pascal');
    AddSnippet(AItems, 'if', 'if ${1:Condicao} then'#10+'begin'#10+
      '  $0'#10+'end;', 'Bloco condicional Pascal');
    AddSnippet(AItems, 'for', 'for ${1:I} := 0 to ${2:Limite} do'#10+
      'begin'#10+'  $0'#10+'end;', 'Laço for Pascal');
  end
  else if SameText(AContext.LanguageID, 'sql') then
  begin
    AddSnippet(AItems, 'select', 'SELECT ${1:campos}'#10+'FROM ${2:tabela}'#10+
      'WHERE $0;', 'Consulta SELECT');
    AddSnippet(AItems, 'createtable', 'CREATE TABLE ${1:tabela} ('#10+
      '  ${2:id} INTEGER'#10+');', 'Criação de tabela');
  end;
end;

function TMNoteSnippetCompletionProvider.ResolveDocumentation(
  AItem: TMNoteCompletionItem): string;
begin
  if AItem = nil then Exit('');
  Result := AItem.Documentation;
end;

class function TMNoteSnippetCompletionProvider.Expand(const ASnippet: string;
  out ACursorOffset: Integer): string;
var
  I, ClosePosition, PlaceholderNumber: Integer;
  Placeholder, DefaultText: string;
begin
  Result := '';
  ACursorOffset := -1;
  I := 1;
  while I <= Length(ASnippet) do
  begin
    if (ASnippet[I] = '$') and (I < Length(ASnippet)) and
      (ASnippet[I + 1] = '0') then
    begin
      if ACursorOffset < 0 then ACursorOffset := Length(Result);
      Inc(I, 2);
      Continue;
    end;
    if (ASnippet[I] = '$') and (I + 2 <= Length(ASnippet)) and
      (ASnippet[I + 1] = '{') then
    begin
      ClosePosition := I + 2;
      while (ClosePosition <= Length(ASnippet)) and
        (ASnippet[ClosePosition] <> '}') do Inc(ClosePosition);
      if ClosePosition <= Length(ASnippet) then
      begin
        Placeholder := Copy(ASnippet, I + 2, ClosePosition - I - 2);
        PlaceholderNumber := StrToIntDef(Copy(Placeholder, 1,
          Pos(':', Placeholder) - 1), -1);
        DefaultText := Copy(Placeholder, Pos(':', Placeholder) + 1, MaxInt);
        if (PlaceholderNumber = 1) and (ACursorOffset < 0) then
          ACursorOffset := Length(Result);
        Result := Result + DefaultText;
        I := ClosePosition + 1;
        Continue;
      end;
    end;
    Result := Result + ASnippet[I];
    Inc(I);
  end;
  if ACursorOffset < 0 then ACursorOffset := Length(Result);
end;

end.
