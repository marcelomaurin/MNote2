unit mnote_changes_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, StrUtils, Controls, ComCtrls, StdCtrls, ExtCtrls, Dialogs,
  mnote_source_change_types, mnote_source_change_manager, mnote_unified_diff;

type
  TMNoteChangesPanel = class(TComponent)
  private
    FManager: TAISourceChangeManager;
    FChangeSet: TAISourceChangeSet;
    FTree: TTreeView;
    FOldText: TMemo;
    FNewText: TMemo;
    FApplyButton: TButton;
    FUndoButton: TButton;
    FOnApplied: TNotifyEvent;
    procedure TreeSelection(Sender: TObject);
    procedure TreeDoubleClick(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure RejectClick(Sender: TObject);
    procedure UndoClick(Sender: TObject);
    procedure RefreshTree;
    function SelectedChange: TAISourceChange;
    function SelectedHunkIndex: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; const AProjectRoot: string);
    procedure SetProjectRoot(const AProjectRoot: string);
    procedure Present(AChangeSet: TAISourceChangeSet);
    procedure PresentGitDiff(const ATitle, ADiff: string);
    function RollbackCurrent: Boolean;
    property Manager: TAISourceChangeManager read FManager;
    property ChangeSet: TAISourceChangeSet read FChangeSet;
    property OnApplied: TNotifyEvent read FOnApplied write FOnApplied;
  end;

implementation

function LoadText(const AFileName: string): string;
var Stream: TFileStream;
begin
  if not FileExists(AFileName) then Exit('');
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, Stream.Size);
    if Stream.Size > 0 then Stream.ReadBuffer(Result[1], Stream.Size);
  finally Stream.Free; end;
end;

constructor TMNoteChangesPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FManager := TAISourceChangeManager.Create;
end;

destructor TMNoteChangesPanel.Destroy;
begin
  FChangeSet.Free;
  FManager.Free;
  inherited Destroy;
end;

procedure TMNoteChangesPanel.Initialize(AParent: TWinControl;
  const AProjectRoot: string);
var
  Toolbar, Viewer: TPanel;
  Button: TButton;
  Splitter: TSplitter;
begin
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;
  FManager.RootPath := AProjectRoot;
  FManager.DryRun := False;
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent; Toolbar.Align := alTop; Toolbar.Height := 34;
  Toolbar.BevelOuter := bvNone;
  FApplyButton := TButton.Create(Self);
  FApplyButton.Parent := Toolbar; FApplyButton.Caption := 'Aprovar e aplicar';
  FApplyButton.SetBounds(4, 4, 112, 26); FApplyButton.OnClick := @ApplyClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Aceitar/rejeitar trecho';
  Button.SetBounds(120, 4, 142, 26); Button.OnClick := @TreeDoubleClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Rejeitar tudo';
  Button.SetBounds(266, 4, 88, 26); Button.OnClick := @RejectClick;
  FUndoButton := TButton.Create(Self);
  FUndoButton.Parent := Toolbar; FUndoButton.Caption := 'Undo set';
  FUndoButton.SetBounds(358, 4, 70, 26); FUndoButton.OnClick := @UndoClick;
  FTree := TTreeView.Create(Self);
  FTree.Parent := AParent; FTree.Align := alTop; FTree.Height := 150;
  FTree.ReadOnly := True; FTree.OnSelectionChanged := @TreeSelection;
  FTree.OnDblClick := @TreeDoubleClick;
  Viewer := TPanel.Create(Self);
  Viewer.Parent := AParent; Viewer.Align := alClient; Viewer.BevelOuter := bvNone;
  FOldText := TMemo.Create(Self);
  FOldText.Parent := Viewer; FOldText.Align := alLeft; FOldText.Width := 165;
  FOldText.ReadOnly := True; FOldText.ScrollBars := ssAutoBoth;
  Splitter := TSplitter.Create(Self);
  Splitter.Parent := Viewer; Splitter.Align := alLeft;
  FNewText := TMemo.Create(Self);
  FNewText.Parent := Viewer; FNewText.Align := alClient;
  FNewText.ReadOnly := True; FNewText.ScrollBars := ssAutoBoth;
  RefreshTree;
end;

procedure TMNoteChangesPanel.SetProjectRoot(const AProjectRoot: string);
begin
  FreeAndNil(FChangeSet);
  if Trim(AProjectRoot) = '' then FManager.RootPath := ''
  else FManager.RootPath := ExpandFileName(AProjectRoot);
  RefreshTree;
end;

procedure TMNoteChangesPanel.Present(AChangeSet: TAISourceChangeSet);
begin
  if AChangeSet = FChangeSet then Exit;
  FChangeSet.Free;
  FChangeSet := AChangeSet;
  RefreshTree;
end;

procedure TMNoteChangesPanel.PresentGitDiff(const ATitle, ADiff: string);
begin
  FreeAndNil(FChangeSet);
  FTree.Items.Clear;
  FTree.Items.Add(nil, ATitle + ' (somente leitura)');
  FOldText.Text := 'Diff obtido do Git sem operação de escrita.';
  FNewText.Text := ADiff;
  FApplyButton.Enabled := False;
  FUndoButton.Enabled := False;
end;

procedure TMNoteChangesPanel.RefreshTree;
var
  RootNode, FileNode: TTreeNode;
  I, J, HunkCount: Integer;
  Mark: string;
begin
  FTree.Items.Clear;
  FOldText.Clear; FNewText.Clear;
  if FChangeSet = nil then
  begin FTree.Items.Add(nil, 'Nenhuma mudança proposta.'); Exit; end;
  RootNode := FTree.Items.Add(nil, SourceChangeStatusName(FChangeSet.Status) +
    ' | origem ' + FChangeSet.Origin + ' | tarefa ' + FChangeSet.TaskID);
  for I := 0 to FChangeSet.Count - 1 do
  begin
    if FChangeSet[I].SelectedHunkCount = FChangeSet[I].HunkCount then
      Mark := '[x] '
    else if FChangeSet[I].SelectedHunkCount > 0 then Mark := '[-] '
    else if (FChangeSet[I].HunkCount = 0) and FChangeSet[I].Selected then
      Mark := '[x] '
    else Mark := '[ ] ';
    FileNode := FTree.Items.AddChild(RootNode, Mark + FChangeSet[I].FileName +
      ' | ' + Copy(FChangeSet[I].OriginalHash, 1, 8));
    FileNode.Data := FChangeSet[I];
    HunkCount := TMNoteUnifiedDiff.HunkCount(FChangeSet[I].Diff);
    for J := 1 to HunkCount do
      with FTree.Items.AddChild(FileNode,
        IfThen(FChangeSet[I].HunkSelected(J - 1), '[x] ', '[ ] ') +
        'hunk ' + IntToStr(J) +
        IfThen(FChangeSet[I].FallbackDiff, ' (fallback)', '')) do
        Data := FChangeSet[I];
  end;
  RootNode.Expand(True);
  FApplyButton.Enabled := FChangeSet.Status in [scsProposed, scsApproved];
  FUndoButton.Enabled := FChangeSet.Status = scsApplied;
end;

function TMNoteChangesPanel.SelectedHunkIndex: Integer;
var
  Node: TTreeNode;
begin
  Result := -1;
  if (FTree.Selected = nil) or (FTree.Selected.Level <> 2) then Exit;
  Node := FTree.Selected.Parent.GetFirstChild;
  while (Node <> nil) and (Node <> FTree.Selected) do
  begin
    Inc(Result);
    Node := Node.GetNextSibling;
  end;
  Inc(Result);
end;

function TMNoteChangesPanel.SelectedChange: TAISourceChange;
begin
  Result := nil;
  if (FTree.Selected <> nil) and (FTree.Selected.Data <> nil) then
    Result := TAISourceChange(FTree.Selected.Data);
end;

procedure TMNoteChangesPanel.TreeSelection(Sender: TObject);
var Change: TAISourceChange;
begin
  Change := SelectedChange;
  if Change = nil then Exit;
  if Change.Kind <> sckNewFile then
    FOldText.Text := LoadText(IncludeTrailingPathDelimiter(FManager.RootPath) +
      Change.FileName) else FOldText.Text := '(arquivo novo)';
  FNewText.Text := Change.ProposedContent;
end;

procedure TMNoteChangesPanel.TreeDoubleClick(Sender: TObject);
var
  Change: TAISourceChange;
  HunkIndex: Integer;
begin
  if (FChangeSet = nil) or (FChangeSet.Status <> scsProposed) then Exit;
  Change := SelectedChange;
  if Change = nil then Exit;
  HunkIndex := SelectedHunkIndex;
  if HunkIndex >= 0 then
  begin
    if not FManager.SetHunkSelected(Change, HunkIndex,
      not Change.HunkSelected(HunkIndex)) then
      MessageDlg('Changes', FManager.LastError, mtError, [mbOK], 0);
  end
  else if not FManager.SetAllHunksSelected(Change, not Change.Selected) then
    MessageDlg('Changes', FManager.LastError, mtError, [mbOK], 0);
  RefreshTree;
end;

procedure TMNoteChangesPanel.ApplyClick(Sender: TObject);
begin
  if FChangeSet = nil then Exit;
  if MessageDlg('Changes', 'Aplicar somente os arquivos marcados?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  if not FManager.Apply(FChangeSet, True) then
    MessageDlg('Changes', FManager.LastError, mtError, [mbOK], 0);
  RefreshTree;
  if (FChangeSet <> nil) and (FChangeSet.Status = scsApplied) and
    Assigned(FOnApplied) then FOnApplied(Self);
end;

function TMNoteChangesPanel.RollbackCurrent: Boolean;
begin
  Result := (FChangeSet <> nil) and FManager.Rollback(FChangeSet);
  RefreshTree;
end;

procedure TMNoteChangesPanel.RejectClick(Sender: TObject);
var I: Integer;
begin
  if FChangeSet = nil then Exit;
  FChangeSet.Status := scsRejected;
  for I := 0 to FChangeSet.Count - 1 do FChangeSet[I].Status := scsRejected;
  RefreshTree;
end;

procedure TMNoteChangesPanel.UndoClick(Sender: TObject);
begin
  if FChangeSet = nil then Exit;
  if MessageDlg('Changes', 'Restaurar o change set aplicado?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then Exit;
  if not RollbackCurrent then
    MessageDlg('Changes', FManager.LastError, mtError, [mbOK], 0);
end;

end.
