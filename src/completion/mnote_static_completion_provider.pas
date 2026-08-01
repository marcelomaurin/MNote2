unit mnote_static_completion_provider;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_completion_types, mnote_completion_provider;

type
  { TMNoteStaticCompletionProvider }

  TMNoteStaticCompletionProvider = class(TInterfacedObject,
    IMNoteCompletionProvider)
  private
    FLanguageID: string;
    FValues: TStringList;
    FOrigin: string;
  public
    constructor Create(const ALanguageID, AOrigin: string;
      AValues: TStrings);
    destructor Destroy; override;
    function Supports(AContext: TMNoteCompletionContext): Boolean;
    procedure Collect(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems);
    function ResolveDocumentation(AItem: TMNoteCompletionItem): string;
  end;

implementation

constructor TMNoteStaticCompletionProvider.Create(const ALanguageID,
  AOrigin: string; AValues: TStrings);
begin
  inherited Create;
  FLanguageID := ALanguageID;
  FOrigin := AOrigin;
  FValues := TStringList.Create;
  if AValues <> nil then FValues.Assign(AValues);
end;

destructor TMNoteStaticCompletionProvider.Destroy;
begin
  FValues.Free;
  inherited Destroy;
end;

function TMNoteStaticCompletionProvider.Supports(
  AContext: TMNoteCompletionContext): Boolean;
begin
  Result := (AContext <> nil) and
    ((FLanguageID = '') or SameText(FLanguageID, AContext.LanguageID));
end;

procedure TMNoteStaticCompletionProvider.Collect(
  AContext: TMNoteCompletionContext; AItems: TMNoteCompletionItems);
var
  I: Integer;
  Value, DisplayText, Documentation: string;
  SeparatorPosition: Integer;
  Item: TMNoteCompletionItem;
begin
  for I := 0 to FValues.Count - 1 do
  begin
    Value := Trim(FValues[I]);
    if (Value = '') or (Value[1] = '#') then Continue;
    DisplayText := Value;
    Documentation := '';
    SeparatorPosition := Pos('|', Value);
    if SeparatorPosition > 0 then
    begin
      DisplayText := Trim(Copy(Value, 1, SeparatorPosition - 1));
      Documentation := Trim(Copy(Value, SeparatorPosition + 1, MaxInt));
    end;
    Item := TMNoteCompletionItem.Create(DisplayText, ckKeyword, FOrigin, 10);
    Item.Documentation := Documentation;
    AItems.Add(Item);
  end;
end;

function TMNoteStaticCompletionProvider.ResolveDocumentation(
  AItem: TMNoteCompletionItem): string;
begin
  if AItem = nil then Exit('');
  Result := AItem.Documentation;
end;

end.
