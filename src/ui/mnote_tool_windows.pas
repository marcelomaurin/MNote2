unit mnote_tool_windows;

{$mode objfpc}{$H+}

interface

uses
  Classes;

type
  TMNoteToolWindowKind = (
    twkSolution,
    twkFiles,
    twkDatabase,
    twkAI,
    twkTasks,
    twkProperties,
    twkChanges,
    twkAIMonitor,
    twkComponentsLab,
    twkSearch,
    twkProblems,
    twkOutput,
    twkTerminal,
    twkTaskList
  );

  TMNoteToolWindowVisibilityEvent = procedure(Sender: TObject;
    AKind: TMNoteToolWindowKind; AVisible: Boolean) of object;

  { TMNoteToolWindowManager }

  TMNoteToolWindowManager = class
  private
    FVisible: set of TMNoteToolWindowKind;
    FOnVisibilityChanged: TMNoteToolWindowVisibilityEvent;
    procedure SetVisible(AKind: TMNoteToolWindowKind; AVisible: Boolean);
  public
    procedure Show(AKind: TMNoteToolWindowKind);
    procedure Hide(AKind: TMNoteToolWindowKind);
    procedure Toggle(AKind: TMNoteToolWindowKind);
    function IsVisible(AKind: TMNoteToolWindowKind): Boolean;
    procedure Clear;
    property OnVisibilityChanged: TMNoteToolWindowVisibilityEvent
      read FOnVisibilityChanged write FOnVisibilityChanged;
  end;

implementation

procedure TMNoteToolWindowManager.SetVisible(AKind: TMNoteToolWindowKind;
  AVisible: Boolean);
begin
  if IsVisible(AKind) = AVisible then
    Exit;
  if AVisible then
    Include(FVisible, AKind)
  else
    Exclude(FVisible, AKind);
  if Assigned(FOnVisibilityChanged) then
    FOnVisibilityChanged(Self, AKind, AVisible);
end;

procedure TMNoteToolWindowManager.Show(AKind: TMNoteToolWindowKind);
begin
  SetVisible(AKind, True);
end;

procedure TMNoteToolWindowManager.Hide(AKind: TMNoteToolWindowKind);
begin
  SetVisible(AKind, False);
end;

procedure TMNoteToolWindowManager.Toggle(AKind: TMNoteToolWindowKind);
begin
  SetVisible(AKind, not IsVisible(AKind));
end;

function TMNoteToolWindowManager.IsVisible(AKind: TMNoteToolWindowKind): Boolean;
begin
  Result := AKind in FVisible;
end;

procedure TMNoteToolWindowManager.Clear;
var
  Kind: TMNoteToolWindowKind;
begin
  for Kind := Low(TMNoteToolWindowKind) to High(TMNoteToolWindowKind) do
    Hide(Kind);
end;

end.
