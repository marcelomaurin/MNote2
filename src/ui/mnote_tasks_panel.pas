unit mnote_tasks_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, StrUtils, Forms, Controls, ComCtrls, StdCtrls, ExtCtrls, Dialogs,
  Clipbrd, CheckLst, fpjson, mnote_project_service, mnote_ai_plan_contract,
  mnote_document_export_service, aiproject_core;

type
  TMNotePlanRequestEvent = procedure(Sender: TObject;
    ARevision: Boolean) of object;
  TMNoteTaskLinkEvent = procedure(Sender: TObject;
    const AValue: string) of object;

  TMNoteTasksPanel = class(TComponent)
  private
    FService: TMNoteProjectService;
    FPages: TPageControl;
    FTasksTab: TTabSheet;
    FList: TListView;
    FDetails: TMemo;
    FLinks: TListBox;
    FAction: TComboBox;
    FSummaryLabels: array[0..2] of TLabel;
    FSummaryLists: array[0..2] of TListBox;
    FOnPlanRequested: TMNotePlanRequestEvent;
    FOnOpenFile: TMNoteTaskLinkEvent;
    FOnOpenCommit: TMNoteTaskLinkEvent;
    procedure RefreshList;
    procedure SelectionChanged(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure NewTask(Sender: TObject);
    procedure EditTask(Sender: TObject);
    procedure ApplyAction(Sender: TObject);
    procedure ExportTask(Sender: TObject);
    procedure ExportReport(Sender: TObject);
    procedure GeneratePlan(Sender: TObject);
    procedure RevisePlan(Sender: TObject);
    procedure LinkDoubleClick(Sender: TObject);
    function SelectedTask: TJSONObject;
    function EditTaskDialog(ATask: TJSONObject; ANew: Boolean): Boolean;
    procedure SaveAndRefresh;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; const AProjectRoot,
      AProjectName: string);
    procedure OpenProject(const AProjectRoot, AProjectName: string);
    procedure CloseProject;
    procedure Refresh;
    function ReviewAndApplyPlan(const AJSON, AInput: string;
      ARevision: Boolean; out AError: string): Boolean;
    property Service: TMNoteProjectService read FService;
    property OnPlanRequested: TMNotePlanRequestEvent read FOnPlanRequested
      write FOnPlanRequested;
    property OnOpenFile: TMNoteTaskLinkEvent read FOnOpenFile write FOnOpenFile;
    property OnOpenCommit: TMNoteTaskLinkEvent read FOnOpenCommit
      write FOnOpenCommit;
  end;

implementation

procedure AddColumn(AList: TListView; const ACaption: string; AWidth: Integer);
begin
  with AList.Columns.Add do
  begin
    Caption := ACaption;
    Width := AWidth;
  end;
end;

procedure TMNoteTasksPanel.Refresh;
begin
  RefreshList;
end;

function JSONArrayText(AData: TJSONData): string;
var
  ArrayData: TJSONArray;
  I: Integer;
begin
  Result := '';
  if not (AData is TJSONArray) then Exit;
  ArrayData := TJSONArray(AData);
  for I := 0 to ArrayData.Count - 1 do
  begin
    if Result <> '' then Result := Result + ', ';
    Result := Result + ArrayData.Strings[I];
  end;
end;

constructor TMNoteTasksPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FService := TMNoteProjectService.Create;
end;

destructor TMNoteTasksPanel.Destroy;
begin
  FService.Free;
  inherited Destroy;
end;

procedure TMNoteTasksPanel.Initialize(AParent: TWinControl;
  const AProjectRoot, AProjectName: string);
const
  SummaryCaptions: array[0..2] of string = ('Nenhum dado de Gantt.',
    'Nenhum evento de Timeline.', 'Nenhum risco registrado.');
  TabCaptions: array[0..2] of string = ('Gantt', 'Timeline', 'Risk Matrix');
var
  I: Integer;
  Toolbar: TPanel;
  Button: TButton;
  Tab: TTabSheet;
begin
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;
  FPages := TPageControl.Create(Self);
  FPages.Parent := AParent;
  FPages.Align := alClient;
  FTasksTab := TTabSheet.Create(Self);
  FTasksTab.PageControl := FPages;
  FTasksTab.Caption := 'Tasks';
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := FTasksTab;
  Toolbar.Align := alTop;
  Toolbar.Height := 34;
  Toolbar.BevelOuter := bvNone;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Nova'; Button.Left := 4;
  Button.Top := 4; Button.Width := 52; Button.OnClick := @NewTask;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Editar'; Button.Left := 60;
  Button.Top := 4; Button.Width := 52; Button.OnClick := @EditTask;
  FAction := TComboBox.Create(Self);
  FAction.Parent := Toolbar; FAction.Left := 116; FAction.Top := 4;
  FAction.Width := 98; FAction.Style := csDropDownList;
  FAction.Items.AddStrings(['Confirm', 'Reject', 'Start', 'Finish', 'Cancel',
    'Block', 'Unblock', 'Reopen', 'Comment', 'Request Revision']);
  FAction.ItemIndex := 0;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Aplicar'; Button.Left := 218;
  Button.Top := 4; Button.Width := 56; Button.OnClick := @ApplyAction;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Exportar'; Button.Left := 278;
  Button.Top := 4; Button.Width := 60; Button.OnClick := @ExportTask;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Plano IA'; Button.Left := 342;
  Button.Top := 4; Button.Width := 66; Button.OnClick := @GeneratePlan;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Revisar IA'; Button.Left := 412;
  Button.Top := 4; Button.Width := 72; Button.OnClick := @RevisePlan;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Relatório'; Button.Left := 488;
  Button.Top := 4; Button.Width := 66; Button.OnClick := @ExportReport;
  FList := TListView.Create(Self);
  FList.Parent := FTasksTab;
  FList.Align := alTop;
  FList.Height := 190;
  FList.ViewStyle := vsReport;
  FList.ReadOnly := True;
  FList.RowSelect := True;
  FList.OnSelectItem := @SelectionChanged;
  AddColumn(FList, 'ID', 52); AddColumn(FList, 'Título', 150);
  AddColumn(FList, 'Status', 82); AddColumn(FList, 'Prior.', 55);
  AddColumn(FList, 'Responsável', 90); AddColumn(FList, '%', 38);
  AddColumn(FList, 'Horas', 45);
  FDetails := TMemo.Create(Self);
  FDetails.Parent := FTasksTab;
  FDetails.Align := alTop;
  FDetails.Height := 170;
  FDetails.ReadOnly := True;
  FDetails.ScrollBars := ssAutoBoth;
  FLinks := TListBox.Create(Self);
  FLinks.Parent := FTasksTab;
  FLinks.Align := alClient;
  FLinks.OnDblClick := @LinkDoubleClick;
  for I := 0 to 2 do
  begin
    Tab := TTabSheet.Create(Self);
    Tab.PageControl := FPages;
    Tab.Caption := TabCaptions[I];
    FSummaryLabels[I] := TLabel.Create(Self);
    FSummaryLabels[I].Parent := Tab;
    FSummaryLabels[I].Align := alTop;
    FSummaryLabels[I].BorderSpacing.Around := 12;
    FSummaryLabels[I].Caption := SummaryCaptions[I];
    FSummaryLists[I] := TListBox.Create(Self);
    FSummaryLists[I].Parent := Tab;
    FSummaryLists[I].Align := alClient;
    FSummaryLists[I].BorderSpacing.Around := 12;
  end;
  if DirectoryExists(AProjectRoot) then OpenProject(AProjectRoot, AProjectName)
  else CloseProject;
end;

procedure TMNoteTasksPanel.OpenProject(const AProjectRoot,
  AProjectName: string);
var
  ProjectFile, ProjectDisplayName, LoadError: string;
  Search: TSearchRec;
begin
  ProjectDisplayName := AProjectName;
  if ProjectDisplayName = '' then
    ProjectDisplayName := ExtractFileName(
      ExcludeTrailingPathDelimiter(AProjectRoot));
  if ProjectDisplayName = '' then ProjectDisplayName := 'MNote2';
  ProjectFile := '';
  if FindFirst(IncludeTrailingPathDelimiter(AProjectRoot) +
    '*.mnoteproj.json', faAnyFile, Search) = 0 then
  try
    repeat
      if Search.Attr and faDirectory = 0 then
      begin
        ProjectFile := IncludeTrailingPathDelimiter(AProjectRoot) + Search.Name;
        Break;
      end;
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
  if ProjectFile = '' then
    ProjectFile := IncludeTrailingPathDelimiter(AProjectRoot) +
      ProjectDisplayName + '.mnoteproj.json';
  if FileExists(ProjectFile) then
  begin
    if not FService.Load(ProjectFile) then
    begin
      LoadError := FService.LastError;
      CloseProject;
      MessageDlg('Projeto', LoadError, mtError, [mbOK], 0);
    end;
  end
  else
  begin
    FService.NewProject(ProjectDisplayName, AProjectRoot);
    if not FService.SaveAs(ProjectFile) then
      MessageDlg('Projeto', FService.LastError, mtError, [mbOK], 0);
  end;
  RefreshList;
end;

procedure TMNoteTasksPanel.CloseProject;
begin
  FService.NewProject('', '');
  RefreshList;
end;

function TMNoteTasksPanel.SelectedTask: TJSONObject;
begin
  Result := nil;
  if (FList = nil) or (FList.Selected = nil) then Exit;
  Result := FService.Tasks.GetTaskByID(FList.Selected.Caption);
end;

procedure TMNoteTasksPanel.RefreshList;
var
  I, J: Integer;
  Task, Hours: TJSONObject;
  Item: TListItem;
  Planning, Agile: TJSONObject;
  DataArray: TJSONArray;
begin
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to FService.Tasks.Count - 1 do
    begin
      Task := FService.Tasks.Tasks.Objects[I];
      Item := FList.Items.Add;
      Item.Caption := Task.Get('id', '');
      Item.SubItems.Add(Task.Get('title', ''));
      Item.SubItems.Add(Task.Get('status', 'draft'));
      Item.SubItems.Add(Task.Get('priority', ''));
      Item.SubItems.Add(Task.Get('assigned_to', ''));
      Item.SubItems.Add(IntToStr(Task.Get('progress_percent', 0)));
      if Task.Find('estimated_hours') is TJSONObject then
        Hours := Task.Objects['estimated_hours'] else Hours := nil;
      if Hours <> nil then Item.SubItems.Add(IntToStr(Hours.Get('mid_level', 0)))
      else Item.SubItems.Add('0');
    end;
  finally
    FList.Items.EndUpdate;
  end;
  Planning := FService.Project.ProjectData.Objects['planning'];
  Agile := FService.Project.ProjectData.Objects['agile_documents'];
  for I := 0 to 2 do
  begin
    FSummaryLists[I].Items.Clear;
    case I of
      0: DataArray := Planning.Arrays['gantt'];
      1: DataArray := Planning.Arrays['timeline'];
    else
      DataArray := Agile.Arrays['risk_map'];
    end;
    for J := 0 to DataArray.Count - 1 do
      FSummaryLists[I].Items.Add(DataArray.Items[J].AsJSON);
    if DataArray.Count > 0 then
      FSummaryLabels[I].Caption := IntToStr(DataArray.Count) + ' item(ns).'
    else
      FSummaryLabels[I].Caption := 'Nenhum item cadastrado.';
  end;
end;

procedure TMNoteTasksPanel.SelectionChanged(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  Task: TJSONObject;
  History: TJSONArray;
  Entry: TJSONObject;
  Dependencies, Files, Commits: TJSONArray;
  I: Integer;
begin
  if not Selected then Exit;
  Task := SelectedTask;
  if Task = nil then Exit;
  FDetails.Lines.Text := 'Descrição:'#13#10 + Task.Get('description', '') +
    #13#10#13#10 + 'Descrição longa:'#13#10 + Task.Get('long_description', '') +
    #13#10#13#10 + 'Critérios:'#13#10 + Task.Get('acceptance_criteria', '') +
    #13#10#13#10 + 'Dependências: ' + JSONArrayText(Task.Find('dependencies')) +
    #13#10 + 'Entregável: ' + Task.Get('deliverable', '') +
    #13#10 + 'Arquivos: ' + JSONArrayText(Task.Find('files_affected')) +
    #13#10 + 'Exclusivos: ' + JSONArrayText(Task.Find('exclusive_files')) +
    #13#10 + 'Commits: ' + JSONArrayText(Task.Find('commits')) +
    #13#10#13#10 + 'Notas:'#13#10 + Task.Get('notes', '');
  History := FService.Project.ProjectData.Arrays['task_actions'];
  for I := 0 to History.Count - 1 do
  begin
    Entry := History.Objects[I];
    if SameText(Entry.Get('task_id', ''), Task.Get('id', '')) then
      FDetails.Lines.Add(Format('%s: %s (%s -> %s) %s',
        [Entry.Get('created_at', ''), Entry.Get('action', ''),
         Entry.Get('previous_status', ''), Entry.Get('new_status', ''),
         Entry.Get('comment', '')]));
  end;
  FLinks.Items.Clear;
  Dependencies := Task.Arrays['dependencies'];
  for I := 0 to Dependencies.Count - 1 do
    FLinks.Items.Add('DEPENDÊNCIA: ' + Dependencies.Strings[I]);
  Files := Task.Arrays['files_affected'];
  for I := 0 to Files.Count - 1 do FLinks.Items.Add('ARQUIVO: ' + Files.Strings[I]);
  Commits := Task.Arrays['commits'];
  for I := 0 to Commits.Count - 1 do FLinks.Items.Add('COMMIT: ' + Commits.Strings[I]);
end;

function TMNoteTasksPanel.EditTaskDialog(ATask: TJSONObject;
  ANew: Boolean): Boolean;
var
  Dialog: TForm;
  TitleEdit, PriorityEdit, AssignedEdit, HoursEdit: TEdit;
  DescriptionEdit, LongEdit: TMemo;
  OkButton, CancelButton: TButton;
  Labels: array[0..5] of TLabel;
  I: Integer;
  Captions: array[0..5] of string = ('Título', 'Descrição', 'Descrição longa',
    'Prioridade', 'Estimativa (horas)', 'Responsável');
  ID: string;
begin
  Dialog := TForm.Create(nil);
  try
    Dialog.Caption := IfThen(ANew, 'Nova tarefa', 'Editar tarefa');
    Dialog.Position := poScreenCenter;
    Dialog.Width := 480; Dialog.Height := 470;
    for I := 0 to 5 do begin Labels[I] := TLabel.Create(Dialog);
      Labels[I].Parent := Dialog; Labels[I].Caption := Captions[I]; end;
    Labels[0].SetBounds(12, 12, 120, 18);
    TitleEdit := TEdit.Create(Dialog); TitleEdit.Parent := Dialog;
    TitleEdit.SetBounds(12, 30, 440, 25);
    Labels[1].SetBounds(12, 62, 120, 18);
    DescriptionEdit := TMemo.Create(Dialog); DescriptionEdit.Parent := Dialog;
    DescriptionEdit.SetBounds(12, 80, 440, 70);
    Labels[2].SetBounds(12, 158, 120, 18);
    LongEdit := TMemo.Create(Dialog); LongEdit.Parent := Dialog;
    LongEdit.SetBounds(12, 176, 440, 100);
    Labels[3].SetBounds(12, 284, 100, 18);
    PriorityEdit := TEdit.Create(Dialog); PriorityEdit.Parent := Dialog;
    PriorityEdit.SetBounds(12, 302, 120, 25);
    Labels[4].SetBounds(146, 284, 120, 18);
    HoursEdit := TEdit.Create(Dialog); HoursEdit.Parent := Dialog;
    HoursEdit.SetBounds(146, 302, 120, 25);
    Labels[5].SetBounds(280, 284, 120, 18);
    AssignedEdit := TEdit.Create(Dialog); AssignedEdit.Parent := Dialog;
    AssignedEdit.SetBounds(280, 302, 172, 25);
    if ATask <> nil then begin
      TitleEdit.Text := ATask.Get('title', '');
      DescriptionEdit.Text := ATask.Get('description', '');
      LongEdit.Text := ATask.Get('long_description', '');
      PriorityEdit.Text := ATask.Get('priority', 'normal');
      AssignedEdit.Text := ATask.Get('assigned_to', '');
      if ATask.Find('estimated_hours') is TJSONObject then
        HoursEdit.Text := IntToStr(ATask.Objects['estimated_hours'].Get('mid_level', 0));
    end else begin PriorityEdit.Text := 'normal'; HoursEdit.Text := '1'; end;
    OkButton := TButton.Create(Dialog); OkButton.Parent := Dialog;
    OkButton.Caption := 'OK'; OkButton.ModalResult := mrOk;
    OkButton.SetBounds(282, 390, 80, 28);
    CancelButton := TButton.Create(Dialog); CancelButton.Parent := Dialog;
    CancelButton.Caption := 'Cancelar'; CancelButton.ModalResult := mrCancel;
    CancelButton.SetBounds(372, 390, 80, 28);
    Result := Dialog.ShowModal = mrOk;
    if not Result then Exit;
    if Trim(TitleEdit.Text) = '' then begin Result := False; Exit; end;
    if ANew then
    begin
      ID := FService.Tasks.AddTask(TitleEdit.Text, DescriptionEdit.Text,
        PriorityEdit.Text, 'DEV', AssignedEdit.Text,
        StrToIntDef(HoursEdit.Text, 1));
      ATask := FService.Tasks.GetTaskByID(ID);
    end;
    Result := FService.Tasks.UpdateTask(ATask.Get('id', ''), TitleEdit.Text,
      DescriptionEdit.Text, LongEdit.Text, PriorityEdit.Text,
      AssignedEdit.Text, StrToIntDef(HoursEdit.Text, 1));
  finally
    Dialog.Free;
  end;
end;

procedure TMNoteTasksPanel.SaveAndRefresh;
begin
  if not FService.Save then
    MessageDlg('Tasks', FService.LastError, mtError, [mbOK], 0);
  RefreshList;
end;

procedure TMNoteTasksPanel.NewTask(Sender: TObject);
begin
  if EditTaskDialog(nil, True) then SaveAndRefresh;
end;

procedure TMNoteTasksPanel.EditTask(Sender: TObject);
var Task: TJSONObject;
begin
  Task := SelectedTask;
  if (Task <> nil) and EditTaskDialog(Task, False) then SaveAndRefresh;
end;

procedure TMNoteTasksPanel.ApplyAction(Sender: TObject);
var
  Task: TJSONObject;
  Comment, Head, Reason: string;
  Action: TAIProjectTaskAction;
begin
  Task := SelectedTask;
  if Task = nil then Exit;
  Comment := '';
  if FAction.ItemIndex in [8, 9] then
    if not InputQuery('Ação de tarefa', 'Comentário:', Comment) then Exit;
  Head := '';
  Action := TAIProjectTaskAction(FAction.ItemIndex);
  if Action = taFinishTask then
  begin
    if FService.CurrentGitHead(Head, Reason) then
    begin
      if MessageDlg('Tasks', 'Vincular o commit HEAD ' + Copy(Head, 1, 12) +
        ' à tarefa concluída?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Head := '';
    end
    else
      MessageDlg('Tasks', 'O commit não será vinculado: ' + Reason,
        mtInformation, [mbOK], 0);
  end;
  if not FService.ApplyTaskAction(Task.Get('id', ''), 'MNote2', Action,
    Comment, Head) then
    MessageDlg('Tasks', FService.LastError, mtWarning, [mbOK], 0)
  else SaveAndRefresh;
end;

procedure TMNoteTasksPanel.GeneratePlan(Sender: TObject);
begin
  if Assigned(FOnPlanRequested) then FOnPlanRequested(Self, False);
end;

procedure TMNoteTasksPanel.RevisePlan(Sender: TObject);
begin
  if Assigned(FOnPlanRequested) then FOnPlanRequested(Self, True);
end;

procedure TMNoteTasksPanel.LinkDoubleClick(Sender: TObject);
var
  Value: string;
  I: Integer;
begin
  if FLinks.ItemIndex < 0 then Exit;
  Value := FLinks.Items[FLinks.ItemIndex];
  I := Pos(': ', Value);
  if I = 0 then Exit;
  if Pos('DEPENDÊNCIA:', Value) = 1 then
  begin
    Value := Copy(Value, I + 2, MaxInt);
    for I := 0 to FList.Items.Count - 1 do
      if SameText(FList.Items[I].Caption, Value) then
      begin FList.Items[I].Selected := True; FList.Items[I].MakeVisible(False); Exit; end;
  end
  else if Pos('ARQUIVO:', Value) = 1 then
  begin
    Value := Copy(Value, I + 2, MaxInt);
    if Assigned(FOnOpenFile) then FOnOpenFile(Self, Value);
  end
  else if Pos('COMMIT:', Value) = 1 then
  begin
    Value := Copy(Value, I + 2, MaxInt);
    if Assigned(FOnOpenCommit) then FOnOpenCommit(Self, Value);
  end;
end;

function TMNoteTasksPanel.ReviewAndApplyPlan(const AJSON, AInput: string;
  ARevision: Boolean; out AError: string): Boolean;
var
  Plan: TJSONObject;
  Tasks: TJSONArray;
  Dialog: TForm;
  Checklist: TCheckListBox;
  Preview: TMemo;
  Info: TLabel;
  OkButton, CancelButton: TButton;
  SelectedIDs: TStringList;
  I: Integer;
  RevisionTitle: string;
begin
  Result := False;
  AError := '';
  Plan := nil;
  if not TMNoteAIPlanContract.ParsePlan(AJSON, Plan, AError) then Exit;
  Dialog := TForm.Create(nil);
  SelectedIDs := TStringList.Create;
  try
    Dialog.Caption := IfThen(ARevision, 'Revisar plano proposto pela IA',
      'Revisar plano proposto pela IA');
    Dialog.Position := poScreenCenter;
    Dialog.Width := 820;
    Dialog.Height := 580;
    Info := TLabel.Create(Dialog);
    Info.Parent := Dialog;
    Info.SetBounds(12, 10, 780, 20);
    Info.Caption := 'Marque as tarefas que serão persistidas. Nada é salvo antes desta confirmação.';
    Checklist := TCheckListBox.Create(Dialog);
    Checklist.Parent := Dialog;
    Checklist.SetBounds(12, 34, 350, 475);
    Tasks := Plan.Arrays['tasks'];
    for I := 0 to Tasks.Count - 1 do
    begin
      Checklist.Items.Add(Tasks.Objects[I].Strings['id'] + ' — ' +
        Tasks.Objects[I].Strings['title']);
      Checklist.Checked[I] := True;
    end;
    Preview := TMemo.Create(Dialog);
    Preview.Parent := Dialog;
    Preview.SetBounds(370, 34, 425, 475);
    Preview.ReadOnly := True;
    Preview.ScrollBars := ssAutoBoth;
    Preview.Lines.Text := Plan.FormatJSON;
    OkButton := TButton.Create(Dialog);
    OkButton.Parent := Dialog;
    OkButton.Caption := 'Confirmar e salvar';
    OkButton.ModalResult := mrOk;
    OkButton.SetBounds(630, 518, 110, 28);
    CancelButton := TButton.Create(Dialog);
    CancelButton.Parent := Dialog;
    CancelButton.Caption := 'Cancelar';
    CancelButton.ModalResult := mrCancel;
    CancelButton.SetBounds(744, 518, 70, 28);
    if Dialog.ShowModal <> mrOk then
    begin AError := 'Plano cancelado pelo usuário; nenhuma tarefa foi alterada.'; Exit; end;
    SelectedIDs.CaseSensitive := False;
    for I := 0 to Checklist.Count - 1 do
      if Checklist.Checked[I] then SelectedIDs.Add(Tasks.Objects[I].Strings['id']);
    RevisionTitle := IfThen(ARevision, 'Revisão de plano por IA',
      'Plano inicial por IA');
    if not TMNoteAIPlanContract.ApplyPlan(FService.Project, Plan, SelectedIDs,
      AInput, RevisionTitle, AError) then Exit;
    if not FService.Save then
    begin AError := FService.LastError; Exit; end;
    RefreshList;
    Result := True;
  finally
    SelectedIDs.Free;
    Dialog.Free;
    Plan.Free;
  end;
end;

procedure TMNoteTasksPanel.ExportTask(Sender: TObject);
var
  Task: TJSONObject;
  FileName, Markdown, Root: string;
begin
  Task := SelectedTask;
  if Task = nil then Exit;
  Root := ExtractFileDir(FService.FileName);
  if FService.ExportTaskMarkdown(Task.Get('id', ''),
    IncludeTrailingPathDelimiter(Root) + 'tasks', FileName, Markdown) then
  begin
    Clipboard.AsText := Markdown;
    MessageDlg('Tasks', 'Contrato salvo em ' + FileName +
      ' e copiado para a área de transferência.', mtInformation, [mbOK], 0);
  end
  else MessageDlg('Tasks', FService.LastError, mtWarning, [mbOK], 0);
end;

procedure TMNoteTasksPanel.ExportReport(Sender: TObject);
var
  Dialog: TSaveDialog;
  Exporter: TMNoteDocumentExportService;
  DocumentFormat: TMNoteDocumentFormat;
  Content: string;
begin
  Dialog := TSaveDialog.Create(nil);
  Exporter := TMNoteDocumentExportService.Create;
  try
    Dialog.Title := 'Exportar análise, plano e tarefas';
    Dialog.Filter := 'Texto (*.txt)|*.txt|PDF (*.pdf)|*.pdf';
    Dialog.DefaultExt := 'txt';
    if not Dialog.Execute then Exit;
    if Dialog.FilterIndex = 2 then DocumentFormat := mdfPDF
    else DocumentFormat := mdfText;
    Content := FService.Project.ProjectData.FormatJSON;
    if not Exporter.ExportDocument('Plano e tarefas do projeto', Content,
      Dialog.FileName, DocumentFormat) then
      MessageDlg('Relatório', Exporter.LastError, mtError, [mbOK], 0)
    else
      MessageDlg('Relatório', 'Documento criado em:' + LineEnding +
        Dialog.FileName, mtInformation, [mbOK], 0);
  finally
    Exporter.Free;
    Dialog.Free;
  end;
end;

end.
