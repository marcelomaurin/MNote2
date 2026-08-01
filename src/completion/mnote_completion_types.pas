unit mnote_completion_types;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TMNoteCompletionKind = (ckText, ckKeyword, ckSnippet, ckUnit, ckClass,
    ckRecord, ckProcedure, ckFunction, ckProperty, ckConstant, ckVariable,
    ckSchema, ckTable, ckField, ckView, ckRoutine);

  { TMNoteCompletionItem }

  TMNoteCompletionItem = class
  private
    FText: string;
    FKind: TMNoteCompletionKind;
    FSignature: string;
    FDocumentation: string;
    FOrigin: string;
    FPriority: Integer;
    FInsertText: string;
    FScore: Integer;
    FFileName: string;
    FLine: Integer;
  public
    constructor Create(const AText: string; AKind: TMNoteCompletionKind;
      const AOrigin: string; APriority: Integer = 0);
    function Clone: TMNoteCompletionItem;
    property Text: string read FText write FText;
    property Kind: TMNoteCompletionKind read FKind write FKind;
    property Signature: string read FSignature write FSignature;
    property Documentation: string read FDocumentation write FDocumentation;
    property Origin: string read FOrigin write FOrigin;
    property Priority: Integer read FPriority write FPriority;
    property InsertText: string read FInsertText write FInsertText;
    property Score: Integer read FScore write FScore;
    property FileName: string read FFileName write FFileName;
    property Line: Integer read FLine write FLine;
  end;

  { TMNoteCompletionItems }

  TMNoteCompletionItems = class
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TMNoteCompletionItem;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AItem: TMNoteCompletionItem): Integer;
    procedure Clear;
    function FindByInsertText(const AText: string): TMNoteCompletionItem;
    procedure Sort;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TMNoteCompletionItem read GetItem; default;
  end;

  { TMNoteCompletionContext }

  TMNoteCompletionContext = class
  public
    LanguageID: string;
    Query: string;
    CurrentLine: string;
    TextBeforeCursor: string;
    DocumentText: string;
    FileName: string;
    CursorLine: Integer;
    CursorColumn: Integer;
  end;

function CompletionKindName(AKind: TMNoteCompletionKind): string;

implementation

function CompareCompletionItems(Item1, Item2: Pointer): Integer;
var
  LeftItem, RightItem: TMNoteCompletionItem;
begin
  LeftItem := TMNoteCompletionItem(Item1);
  RightItem := TMNoteCompletionItem(Item2);
  if LeftItem.Score <> RightItem.Score then
    Exit(RightItem.Score - LeftItem.Score);
  if LeftItem.Priority <> RightItem.Priority then
    Exit(RightItem.Priority - LeftItem.Priority);
  Result := CompareText(LeftItem.Text, RightItem.Text);
  if Result = 0 then
    Result := CompareStr(LeftItem.Text, RightItem.Text);
end;

constructor TMNoteCompletionItem.Create(const AText: string;
  AKind: TMNoteCompletionKind; const AOrigin: string; APriority: Integer);
begin
  inherited Create;
  FText := AText;
  FInsertText := AText;
  FKind := AKind;
  FOrigin := AOrigin;
  FPriority := APriority;
  FLine := -1;
end;

function TMNoteCompletionItem.Clone: TMNoteCompletionItem;
begin
  Result := TMNoteCompletionItem.Create(Text, Kind, Origin, Priority);
  Result.Signature := Signature;
  Result.Documentation := Documentation;
  Result.InsertText := InsertText;
  Result.Score := Score;
  Result.FileName := FileName;
  Result.Line := Line;
end;

constructor TMNoteCompletionItems.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True);
end;

destructor TMNoteCompletionItems.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMNoteCompletionItems.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TMNoteCompletionItems.GetItem(AIndex: Integer): TMNoteCompletionItem;
begin
  Result := TMNoteCompletionItem(FItems[AIndex]);
end;

function TMNoteCompletionItems.Add(AItem: TMNoteCompletionItem): Integer;
begin
  if AItem = nil then
    raise Exception.Create('O item de conclusão não pode ser nulo.');
  Result := FItems.Add(AItem);
end;

procedure TMNoteCompletionItems.Clear;
begin
  FItems.Clear;
end;

function TMNoteCompletionItems.FindByInsertText(
  const AText: string): TMNoteCompletionItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Items[I].InsertText, AText) then Exit(Items[I]);
end;

procedure TMNoteCompletionItems.Sort;
begin
  FItems.Sort(@CompareCompletionItems);
end;

function CompletionKindName(AKind: TMNoteCompletionKind): string;
begin
  case AKind of
    ckKeyword: Result := 'palavra-chave';
    ckSnippet: Result := 'snippet';
    ckUnit: Result := 'unit';
    ckClass: Result := 'classe';
    ckRecord: Result := 'record';
    ckProcedure: Result := 'procedure';
    ckFunction: Result := 'function';
    ckProperty: Result := 'property';
    ckConstant: Result := 'constante';
    ckVariable: Result := 'variável';
    ckSchema: Result := 'schema';
    ckTable: Result := 'tabela';
    ckField: Result := 'campo';
    ckView: Result := 'view';
    ckRoutine: Result := 'rotina';
    else Result := 'texto';
  end;
end;

end.
