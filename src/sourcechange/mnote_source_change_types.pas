unit mnote_source_change_types;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson;

type
  TAISourceChangeStatus = (scsProposed, scsApproved, scsApplied, scsFailed,
    scsReverted, scsRejected);
  TAISourceChangeKind = (sckExactReplace, sckLineRange, sckNewFile);

  TAISourceChange = class
  private
    FHunkSelection: array of Boolean;
  public
    ID: string;
    TaskID: string;
    FileName: string;
    OriginalHash: string;
    AppliedHash: string;
    ExpectedText: string;
    NewText: string;
    ProposedContent: string;
    Diff: string;
    Status: TAISourceChangeStatus;
    Kind: TAISourceChangeKind;
    ExpectedCount: Integer;
    StartLine: Integer;
    EndLine: Integer;
    Selected: Boolean;
    FallbackDiff: Boolean;
    procedure InitializeHunks(AHunkCount: Integer);
    function HunkCount: Integer;
    function HunkSelected(AIndex: Integer): Boolean;
    procedure SelectHunk(AIndex: Integer; ASelected: Boolean);
    procedure SelectAllHunks(ASelected: Boolean);
    function SelectedHunkCount: Integer;
    function ToJSON: TJSONObject;
  end;

  TAISourceChangeSet = class
  private
    FChanges: TObjectList;
    function GetCount: Integer;
    function GetChange(AIndex: Integer): TAISourceChange;
  public
    ID: string;
    TaskID: string;
    RequestText: string;
    ModelName: string;
    Origin: string;
    CreatedAt: string;
    Status: TAISourceChangeStatus;
    constructor Create;
    destructor Destroy; override;
    function Add: TAISourceChange;
    function ToJSON: TJSONObject;
    property Count: Integer read GetCount;
    property Changes[AIndex: Integer]: TAISourceChange read GetChange; default;
  end;

function SourceChangeStatusName(AStatus: TAISourceChangeStatus): string;

implementation

function SourceChangeStatusName(AStatus: TAISourceChangeStatus): string;
const
  Names: array[TAISourceChangeStatus] of string = ('Proposed', 'Approved',
    'Applied', 'Failed', 'Reverted', 'Rejected');
begin
  Result := Names[AStatus];
end;

function TAISourceChange.ToJSON: TJSONObject;
var
  Hunks: TJSONArray;
  I: Integer;
begin
  Hunks := TJSONArray.Create;
  for I := 0 to HunkCount - 1 do Hunks.Add(HunkSelected(I));
  Result := TJSONObject.Create(['id', ID, 'task_id', TaskID,
    'file', FileName, 'original_hash', OriginalHash,
    'applied_hash', AppliedHash, 'expected_text', ExpectedText,
    'new_text', NewText, 'proposed_content', ProposedContent, 'diff', Diff,
    'status', SourceChangeStatusName(Status), 'kind', Ord(Kind),
    'expected_count', ExpectedCount, 'start_line', StartLine,
    'end_line', EndLine, 'selected', Selected,
    'diff_fallback', FallbackDiff, 'hunks_selected', Hunks]);
end;

procedure TAISourceChange.InitializeHunks(AHunkCount: Integer);
begin
  if AHunkCount < 0 then AHunkCount := 0;
  SetLength(FHunkSelection, AHunkCount);
  SelectAllHunks(True);
end;

function TAISourceChange.HunkCount: Integer;
begin
  Result := Length(FHunkSelection);
end;

function TAISourceChange.HunkSelected(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < HunkCount) and
    FHunkSelection[AIndex];
end;

procedure TAISourceChange.SelectHunk(AIndex: Integer; ASelected: Boolean);
begin
  if (AIndex >= 0) and (AIndex < HunkCount) then
    FHunkSelection[AIndex] := ASelected;
end;

procedure TAISourceChange.SelectAllHunks(ASelected: Boolean);
var
  I: Integer;
begin
  for I := 0 to HunkCount - 1 do FHunkSelection[I] := ASelected;
end;

function TAISourceChange.SelectedHunkCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to HunkCount - 1 do
    if FHunkSelection[I] then Inc(Result);
end;

constructor TAISourceChangeSet.Create;
begin
  inherited Create;
  FChanges := TObjectList.Create(True);
  ID := FormatDateTime('yyyymmddhhnnsszzz', Now);
  CreatedAt := FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss', Now);
  Origin := 'user';
  Status := scsProposed;
end;

destructor TAISourceChangeSet.Destroy;
begin
  FChanges.Free;
  inherited Destroy;
end;

function TAISourceChangeSet.Add: TAISourceChange;
begin
  Result := TAISourceChange.Create;
  Result.ID := ID + '-' + IntToStr(FChanges.Count + 1);
  Result.TaskID := TaskID;
  Result.Status := scsProposed;
  Result.Selected := True;
  FChanges.Add(Result);
end;

function TAISourceChangeSet.GetCount: Integer;
begin
  Result := FChanges.Count;
end;

function TAISourceChangeSet.GetChange(AIndex: Integer): TAISourceChange;
begin
  Result := TAISourceChange(FChanges[AIndex]);
end;

function TAISourceChangeSet.ToJSON: TJSONObject;
var
  ArrayData: TJSONArray;
  I: Integer;
begin
  ArrayData := TJSONArray.Create;
  for I := 0 to Count - 1 do ArrayData.Add(Changes[I].ToJSON);
  Result := TJSONObject.Create(['id', ID, 'task_id', TaskID,
    'request', RequestText, 'model', ModelName, 'origin', Origin,
    'created_at', CreatedAt, 'status', SourceChangeStatusName(Status),
    'changes', ArrayData]);
end;

end.
