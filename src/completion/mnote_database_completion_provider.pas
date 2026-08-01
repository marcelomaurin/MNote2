unit mnote_database_completion_provider;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_completion_types, mnote_completion_provider;

type
  TMNoteDatabaseCompletionProvider = class(TInterfacedObject,
    IMNoteCompletionProvider)
  private
    FValues: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Update(AValues: TStrings);
    procedure Clear;
    function Supports(AContext: TMNoteCompletionContext): Boolean;
    procedure Collect(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems);
    function ResolveDocumentation(AItem: TMNoteCompletionItem): string;
  end;

function MNoteDatabaseCompletions: TMNoteDatabaseCompletionProvider;

implementation

var
  GProvider: TMNoteDatabaseCompletionProvider;
  GProviderReference: IMNoteCompletionProvider;

constructor TMNoteDatabaseCompletionProvider.Create;
begin
  inherited Create;
  FValues := TStringList.Create;
end;

destructor TMNoteDatabaseCompletionProvider.Destroy;
begin
  FValues.Free;
  inherited Destroy;
end;

procedure TMNoteDatabaseCompletionProvider.Update(AValues: TStrings);
begin
  FValues.Clear;
  if AValues <> nil then FValues.Assign(AValues);
end;

procedure TMNoteDatabaseCompletionProvider.Clear;
begin
  FValues.Clear;
end;

function TMNoteDatabaseCompletionProvider.Supports(
  AContext: TMNoteCompletionContext): Boolean;
begin
  Result := (AContext <> nil) and SameText(AContext.LanguageID, 'sql');
end;

procedure TMNoteDatabaseCompletionProvider.Collect(
  AContext: TMNoteCompletionContext; AItems: TMNoteCompletionItems);
var
  Fields: TStringList;
  I: Integer;
  Item: TMNoteCompletionItem;
begin
  Fields := TStringList.Create;
  try
    Fields.StrictDelimiter := True;
    Fields.Delimiter := '|';
    for I := 0 to FValues.Count - 1 do
    begin
      Fields.DelimitedText := FValues[I];
      if Fields.Count < 2 then Continue;
      if Pos('.', Fields[0]) > 0 then
        Item := TMNoteCompletionItem.Create(Fields[0], ckField,
          'database', 40)
      else
        Item := TMNoteCompletionItem.Create(Fields[0], ckTable,
          'database', 40);
      Item.Documentation := Fields[1];
      Item.Signature := Fields[0];
      AItems.Add(Item);
    end;
  finally
    Fields.Free;
  end;
end;

function TMNoteDatabaseCompletionProvider.ResolveDocumentation(
  AItem: TMNoteCompletionItem): string;
begin
  if AItem = nil then Exit('');
  Result := AItem.Documentation;
end;

function MNoteDatabaseCompletions: TMNoteDatabaseCompletionProvider;
begin
  if GProvider = nil then
  begin
    GProvider := TMNoteDatabaseCompletionProvider.Create;
    GProviderReference := GProvider;
  end;
  Result := GProvider;
end;

finalization
  GProvider := nil;
  GProviderReference := nil;

end.
