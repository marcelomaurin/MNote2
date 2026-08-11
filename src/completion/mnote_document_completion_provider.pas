unit mnote_document_completion_provider;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mnote_completion_types, mnote_completion_provider;

type
  { TMNoteDocumentCompletionProvider }

  TMNoteDocumentCompletionProvider = class(TInterfacedObject,
    IMNoteCompletionProvider)
  private
    FHash: QWord;
    FFileName: string;
    FCachedItems: TMNoteCompletionItems;
    FParseCount: Integer;
    function BufferHash(const AText: string): QWord;
    procedure Rebuild(AContext: TMNoteCompletionContext);
  public
    constructor Create;
    destructor Destroy; override;
    function Supports(AContext: TMNoteCompletionContext): Boolean;
    procedure Collect(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems);
    function ResolveDocumentation(AItem: TMNoteCompletionItem): string;
    property ParseCount: Integer read FParseCount;
  end;

implementation

uses
  mnote_pascal_symbol_parser, mnote_pascal_semantic_resolver;

constructor TMNoteDocumentCompletionProvider.Create;
begin
  inherited Create;
  FCachedItems := TMNoteCompletionItems.Create;
end;

destructor TMNoteDocumentCompletionProvider.Destroy;
begin
  FCachedItems.Free;
  inherited Destroy;
end;

function TMNoteDocumentCompletionProvider.BufferHash(const AText: string): QWord;
var
  I: Integer;
begin
  Result := QWord($CBF29CE484222325);
  for I := 1 to Length(AText) do
  begin
    Result := Result xor Byte(AText[I]);
    Result := Result * QWord($100000001B3);
  end;
end;

procedure TMNoteDocumentCompletionProvider.Rebuild(
  AContext: TMNoteCompletionContext);
var
  Parser: TMNotePascalSymbolParser;
begin
  FCachedItems.Clear;
  if SameText(AContext.LanguageID, 'pascal') then
  begin
    Parser := TMNotePascalSymbolParser.Create;
    try
      Parser.Parse(AContext.DocumentText, AContext.FileName, 'documento',
        FCachedItems);
    finally
      Parser.Free;
    end;
  end;
  FHash := BufferHash(AContext.DocumentText);
  FFileName := AContext.FileName;
  Inc(FParseCount);
end;

function TMNoteDocumentCompletionProvider.Supports(
  AContext: TMNoteCompletionContext): Boolean;
begin
  Result := (AContext <> nil) and (AContext.DocumentText <> '');
end;

procedure TMNoteDocumentCompletionProvider.Collect(
  AContext: TMNoteCompletionContext; AItems: TMNoteCompletionItems);
var
  I: Integer;
  CurrentHash: QWord;
  SemanticItems: TMNoteCompletionItems;
begin
  CurrentHash := BufferHash(AContext.DocumentText);
  if (CurrentHash <> FHash) or (FFileName <> AContext.FileName) then
    Rebuild(AContext);

  SemanticItems := TMNoteCompletionItems.Create;
  try
    if TMNotePascalSemanticResolver.CollectQualifiedMembers(AContext,
      SemanticItems) then
      for I := 0 to SemanticItems.Count - 1 do
        AItems.Add(SemanticItems[I].Clone);
  finally
    SemanticItems.Free;
  end;

  for I := 0 to FCachedItems.Count - 1 do
    AItems.Add(FCachedItems[I].Clone);
end;

function TMNoteDocumentCompletionProvider.ResolveDocumentation(
  AItem: TMNoteCompletionItem): string;
begin
  if AItem = nil then Exit('');
  Result := AItem.Signature;
end;

end.
