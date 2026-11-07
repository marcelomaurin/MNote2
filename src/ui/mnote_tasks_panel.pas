unit mnote_tasks_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, StrUtils, Forms, Controls, ComCtrls, StdCtrls, ExtCtrls, Dialogs,
  Graphics, Clipbrd, CheckLst, fpjson, jsonparser, mnote_project_service,
  mnote_ai_plan_contract, mnote_document_export_service, aiproject_core;

type
  TMNotePlanRequestEvent = procedure(Sender: TObject; ARevision: Boolean) of object;
  TMNoteTaskLinkEvent = procedure(Sender: TObject; const AValue: string) of object;
  TMNoteTaskExecuteAIEvent = procedure(Sender: TObject; const ATaskID, APrompt: string) of object;
  TMNoteOrchestratorActionEvent = procedure(Sender: TObject; const AAction, AContext: string) of object;

  { TMNoteTasksPanel }

  TMNoteTasksPanel = class(TComponent)
  private
    FService: TMNoteProjectService;
    FPages: TPageControl;

    // Aba 1: Tarefas & EAP
    FTasksTab: TTabSheet;
    FList: TListView;
    FDetails: TMemo;
    FLinks: TListBox;
    FAction: TComboBox;

    // Aba 2: Objetivos & Escopo
    FObjectivesTab: TTabSheet;
    FedProjectName: TEdit;
    FedProjectAuthor: TEdit;
    FedProjectVersion: TEdit;
    FmeProjectGoal: TMemo;
    FmeProjectScope: TMemo;
    FmeProjectConstraints: TMemo;
    FmeProjectDeliverables: TMemo;

    // Aba 3: Requisitos (RF / RNF)
    FRequirementsTab: TTabSheet;
    FlvFunctional: TListView;
    FlvNonFunctional: TListView;

    // Aba 4: Bancos & Conexões
    FDatabaseTab: TTabSheet;
    FcbDBType: TComboBox;
    FedDBHost: TEdit;
    FedDBPort: TEdit;
    FedDBName: TEdit;
    FedDBSchema: TEdit;
    FedDBUser: TEdit;
    FedDBPassword: TEdit;
    FlblDBStatus: TLabel;

    // Aba 5: Web APIs & Acessos Externos
    FAPIsTab: TTabSheet;
    FlvAPIs: TListView;
    FmeAPISpec: TMemo;

    // Aba 6: Orquestrador IA
    FOrchestratorTab: TTabSheet;
    FlblOrchestratorStatus: TLabel;
    FmeOrchestratorLog: TMemo;

    // Eventos
    FOnPlanRequested: TMNotePlanRequestEvent;
    FOnOpenFile: TMNoteTaskLinkEvent;
    FOnOpenCommit: TMNoteTaskLinkEvent;
    FOnExecuteTaskAI: TMNoteTaskExecuteAIEvent;
    FOnOrchestratorAction: TMNoteOrchestratorActionEvent;

    // Construtores de interface
    procedure BuildTasksTab;
    procedure BuildObjectivesTab;
    procedure BuildRequirementsTab;
    procedure BuildDatabaseTab;
    procedure BuildAPIsTab;
    procedure BuildOrchestratorTab;

    // Atualização de dados
    procedure RefreshList;
    procedure RefreshObjectives;
    procedure RefreshRequirements;
    procedure RefreshDatabase;
    procedure RefreshAPIs;
    procedure RefreshOrchestrator;

    // Handlers de tarefas
    procedure SelectionChanged(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure NewTask(Sender: TObject);
    procedure NewSummary(Sender: TObject);
    procedure NewMilestone(Sender: TObject);
    procedure EditTask(Sender: TObject);
    procedure DeleteTask(Sender: TObject);
    procedure IndentTask(Sender: TObject);
    procedure OutdentTask(Sender: TObject);
    procedure MoveTaskUp(Sender: TObject);
    procedure MoveTaskDown(Sender: TObject);
    procedure ApplyAction(Sender: TObject);
    procedure ExecuteTaskAIClick(Sender: TObject);
    procedure ExportTask(Sender: TObject);
    procedure ExportReport(Sender: TObject);
    procedure GeneratePlan(Sender: TObject);
    procedure RevisePlan(Sender: TObject);
    procedure LinkDoubleClick(Sender: TObject);

    // Handlers de Objetivos
    procedure SaveObjectivesClick(Sender: TObject);
    procedure SuggestObjectivesAIClick(Sender: TObject);

    // Handlers de Requisitos
    procedure AddRFClick(Sender: TObject);
    procedure EditRFClick(Sender: TObject);
    procedure DeleteRFClick(Sender: TObject);
    procedure AddRNFClick(Sender: TObject);
    procedure EditRNFClick(Sender: TObject);
    procedure DeleteRNFClick(Sender: TObject);
    procedure SaveRequirementsClick(Sender: TObject);
    procedure SuggestRequirementsAIClick(Sender: TObject);

    // Handlers de Banco
    procedure DBTypeChange(Sender: TObject);
    procedure TestDBConnectionClick(Sender: TObject);
    procedure SaveDBConnectionClick(Sender: TObject);

    // Handlers de APIs
    procedure AddAPIClick(Sender: TObject);
    procedure EditAPIClick(Sender: TObject);
    procedure DeleteAPIClick(Sender: TObject);
    procedure SaveAPIsClick(Sender: TObject);
    procedure APISelectionChanged(Sender: TObject; Item: TListItem; Selected: Boolean);

    // Handlers do Orquestrador
    procedure OrchestratorStep1Click(Sender: TObject);
    procedure OrchestratorStep2Click(Sender: TObject);
    procedure OrchestratorStep3Click(Sender: TObject);

    function SelectedTask: TJSONObject;
    function SelectedTaskIndex: Integer;
    function EditTaskDialog(ATask: TJSONObject; ANew: Boolean; const AKind: string = 'code'): Boolean;
    procedure SaveAndRefresh;
    function BuildTaskExecutionPrompt(ATask: TJSONObject): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; const AProjectRoot, AProjectName: string);
    procedure OpenProject(const AProjectRoot, AProjectName: string);
    procedure CloseProject;
    procedure Refresh;
    procedure ShowObjectivesTab;
    procedure ShowTasksTab;
    function ReviewAndApplyPlan(const AJSON, AInput: string; ARevision: Boolean; out AError: string): Boolean;

    property Service: TMNoteProjectService read FService;
    property OnPlanRequested: TMNotePlanRequestEvent read FOnPlanRequested write FOnPlanRequested;
    property OnOpenFile: TMNoteTaskLinkEvent read FOnOpenFile write FOnOpenFile;
    property OnOpenCommit: TMNoteTaskLinkEvent read FOnOpenCommit write FOnOpenCommit;
    property OnExecuteTaskAI: TMNoteTaskExecuteAIEvent read FOnExecuteTaskAI write FOnExecuteTaskAI;
    property OnOrchestratorAction: TMNoteOrchestratorActionEvent read FOnOrchestratorAction write FOnOrchestratorAction;
  end;

implementation

uses
  mquery2, setmain;

procedure AddColumn(AList: TListView; const ACaption: string; AWidth: Integer);
begin
  with AList.Columns.Add do
  begin
    Caption := ACaption;
    Width := AWidth;
  end;
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

function SafeGetArray(AObj: TJSONObject; const AName: string): TJSONArray;
var
  Data: TJSONData;
begin
  Result := nil;
  if AObj = nil then Exit;
  Data := AObj.Find(AName);
  if (Data <> nil) and (Data is TJSONArray) then
    Result := TJSONArray(Data);
end;

function SafeGetObject(AObj: TJSONObject; const AName: string): TJSONObject;
var
  Data: TJSONData;
begin
  Result := nil;
  if AObj = nil then Exit;
  Data := AObj.Find(AName);
  if (Data <> nil) and (Data is TJSONObject) then
    Result := TJSONObject(Data);
end;

function EnsureArray(AObj: TJSONObject; const AName: string): TJSONArray;
var
  Data: TJSONData;
begin
  Result := nil;
  if AObj = nil then Exit;
  Data := AObj.Find(AName);
  if (Data <> nil) and (Data is TJSONArray) then
    Result := TJSONArray(Data)
  else
  begin
    if Data <> nil then AObj.Delete(AName);
    Result := TJSONArray.Create;
    AObj.Add(AName, Result);
  end;
end;

function EnsureObject(AObj: TJSONObject; const AName: string): TJSONObject;
var
  Data: TJSONData;
begin
  Result := nil;
  if AObj = nil then Exit;
  Data := AObj.Find(AName);
  if (Data <> nil) and (Data is TJSONObject) then
    Result := TJSONObject(Data)
  else
  begin
    if Data <> nil then AObj.Delete(AName);
    Result := TJSONObject.Create;
    AObj.Add(AName, Result);
  end;
end;

procedure CalculateWBS(ATasks: TJSONArray);
var
  I, L, K: Integer;
  Counters: array[1..10] of Integer;
  WBSStr: string;
  Task: TJSONObject;
begin
  if ATasks = nil then Exit;
  for K := 1 to 10 do Counters[K] := 0;
  for I := 0 to ATasks.Count - 1 do
  begin
    if not (ATasks.Items[I] is TJSONObject) then Continue;
    Task := ATasks.Objects[I];
    L := Task.Get('level', 1);
    if L < 1 then L := 1;
    if L > 10 then L := 10;
    for K := L + 1 to 10 do Counters[K] := 0;
    Inc(Counters[L]);
    WBSStr := IntToStr(Counters[1]);
    for K := 2 to L do
      WBSStr := WBSStr + '.' + IntToStr(Counters[K]);
    if Task.IndexOfName('wbs') >= 0 then
      Task.Strings['wbs'] := WBSStr
    else
      Task.Add('wbs', WBSStr);
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

procedure TMNoteTasksPanel.Initialize(AParent: TWinControl; const AProjectRoot, AProjectName: string);
begin
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;

  FPages := TPageControl.Create(Self);
  FPages.Parent := AParent;
  FPages.Align := alClient;

  BuildTasksTab;
  BuildObjectivesTab;
  BuildRequirementsTab;
  BuildDatabaseTab;
  BuildAPIsTab;
  BuildOrchestratorTab;

  FPages.ActivePageIndex := 0;

  if DirectoryExists(AProjectRoot) then OpenProject(AProjectRoot, AProjectName)
  else CloseProject;
end;

procedure TMNoteTasksPanel.BuildTasksTab;
var
  Toolbar, DetailsPanel: TPanel;
  Btn: TButton;
  Splitter: TSplitter;
begin
  FTasksTab := TTabSheet.Create(Self);
  FTasksTab.PageControl := FPages;
  FTasksTab.Caption := 'Tarefas (EAP)';

  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := FTasksTab;
  Toolbar.Align := alTop;
  Toolbar.Height := 34;
  Toolbar.BevelOuter := bvNone;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '+ Tarefa'; Btn.Left := 4; Btn.Top := 4; Btn.Width := 60;
  Btn.OnClick := @NewTask;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '+ Resumo'; Btn.Left := 66; Btn.Top := 4; Btn.Width := 64;
  Btn.OnClick := @NewSummary;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '+ Marco'; Btn.Left := 132; Btn.Top := 4; Btn.Width := 56;
  Btn.OnClick := @NewMilestone;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '->'; Btn.Hint := 'Indentar (Subtarefa)'; Btn.ShowHint := True;
  Btn.Left := 190; Btn.Top := 4; Btn.Width := 26; Btn.OnClick := @IndentTask;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '<-'; Btn.Hint := 'Recuar Nível'; Btn.ShowHint := True;
  Btn.Left := 218; Btn.Top := 4; Btn.Width := 26; Btn.OnClick := @OutdentTask;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '^'; Btn.Hint := 'Mover Acima'; Btn.ShowHint := True;
  Btn.Left := 246; Btn.Top := 4; Btn.Width := 24; Btn.OnClick := @MoveTaskUp;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := 'v'; Btn.Hint := 'Mover Abaixo'; Btn.ShowHint := True;
  Btn.Left := 272; Btn.Top := 4; Btn.Width := 24; Btn.OnClick := @MoveTaskDown;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := 'Editar'; Btn.Left := 298; Btn.Top := 4; Btn.Width := 46;
  Btn.OnClick := @EditTask;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := 'Excluir'; Btn.Left := 346; Btn.Top := 4; Btn.Width := 48;
  Btn.OnClick := @DeleteTask;

  FAction := TComboBox.Create(Self);
  FAction.Parent := Toolbar; FAction.Left := 396; FAction.Top := 4; FAction.Width := 86;
  FAction.Style := csDropDownList;
  FAction.Items.AddStrings(['Confirm', 'Reject', 'Start', 'Finish', 'Cancel', 'Block', 'Unblock', 'Reopen', 'Comment', 'Request Revision']);
  FAction.ItemIndex := 0;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := 'Aplicar'; Btn.Left := 484; Btn.Top := 4; Btn.Width := 50;
  Btn.OnClick := @ApplyAction;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '🤖 Implementar IA'; Btn.Left := 536; Btn.Top := 4; Btn.Width := 115;
  Btn.Font.Style := [fsBold];
  Btn.OnClick := @ExecuteTaskAIClick;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '📋 Plano IA'; Btn.Left := 653; Btn.Top := 4; Btn.Width := 74;
  Btn.OnClick := @GeneratePlan;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := '🔄 Revisar'; Btn.Left := 729; Btn.Top := 4; Btn.Width := 68;
  Btn.OnClick := @RevisePlan;

  Btn := TButton.Create(Self);
  Btn.Parent := Toolbar; Btn.Caption := 'Relatório'; Btn.Left := 799; Btn.Top := 4; Btn.Width := 65;
  Btn.OnClick := @ExportReport;

  FList := TListView.Create(Self);
  FList.Parent := FTasksTab;
  FList.Align := alClient;
  FList.ViewStyle := vsReport;
  FList.ReadOnly := True;
  FList.RowSelect := True;
  FList.OnSelectItem := @SelectionChanged;
  AddColumn(FList, 'EAP', 55);
  AddColumn(FList, 'ID', 52);
  AddColumn(FList, 'Título', 240);
  AddColumn(FList, 'Tipo', 85);
  AddColumn(FList, 'Status', 90);
  AddColumn(FList, 'Prior.', 60);
  AddColumn(FList, 'Responsável', 90);
  AddColumn(FList, '%', 38);
  AddColumn(FList, 'Horas', 45);

  Splitter := TSplitter.Create(Self);
  Splitter.Parent := FTasksTab;
  Splitter.Align := alBottom;
  Splitter.Height := 4;

  DetailsPanel := TPanel.Create(Self);
  DetailsPanel.Parent := FTasksTab;
  DetailsPanel.Align := alBottom;
  DetailsPanel.Height := 180;
  DetailsPanel.BevelOuter := bvNone;

  FDetails := TMemo.Create(Self);
  FDetails.Parent := DetailsPanel;
  FDetails.Align := alClient;
  FDetails.ReadOnly := True;
  FDetails.ScrollBars := ssAutoBoth;

  FLinks := TListBox.Create(Self);
  FLinks.Parent := DetailsPanel;
  FLinks.Align := alRight;
  FLinks.Width := 260;
  FLinks.OnDblClick := @LinkDoubleClick;
end;

procedure TMNoteTasksPanel.BuildObjectivesTab;
var
  Scroll: TScrollBox;
  TopPnl, BottomPnl: TPanel;
  Lbl: TLabel;
  Btn: TButton;
begin
  FObjectivesTab := TTabSheet.Create(Self);
  FObjectivesTab.PageControl := FPages;
  FObjectivesTab.Caption := 'Objetivo & Escopo';

  Scroll := TScrollBox.Create(Self);
  Scroll.Parent := FObjectivesTab;
  Scroll.Align := alClient;

  TopPnl := TPanel.Create(Self);
  TopPnl.Parent := Scroll;
  TopPnl.Align := alTop;
  TopPnl.Height := 60;
  TopPnl.BevelOuter := bvNone;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 10; Lbl.Top := 8; Lbl.Caption := 'Nome do Projeto:';
  FedProjectName := TEdit.Create(Self);
  FedProjectName.Parent := TopPnl; FedProjectName.Left := 10; FedProjectName.Top := 26; FedProjectName.Width := 300;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 320; Lbl.Top := 8; Lbl.Caption := 'Autor:';
  FedProjectAuthor := TEdit.Create(Self);
  FedProjectAuthor.Parent := TopPnl; FedProjectAuthor.Left := 320; FedProjectAuthor.Top := 26; FedProjectAuthor.Width := 180;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 510; Lbl.Top := 8; Lbl.Caption := 'Versão:';
  FedProjectVersion := TEdit.Create(Self);
  FedProjectVersion.Parent := TopPnl; FedProjectVersion.Left := 510; FedProjectVersion.Top := 26; FedProjectVersion.Width := 80;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Scroll; Lbl.Align := alTop; Lbl.BorderSpacing.Around := 6;
  Lbl.Caption := 'Objetivo Geral / Visão Arquitetural:';
  FmeProjectGoal := TMemo.Create(Self);
  FmeProjectGoal.Parent := Scroll; FmeProjectGoal.Align := alTop; FmeProjectGoal.Height := 90;
  FmeProjectGoal.ScrollBars := ssAutoVertical;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Scroll; Lbl.Align := alTop; Lbl.BorderSpacing.Around := 6;
  Lbl.Caption := 'Escopo do Projeto (O que deve ser desenvolvido):';
  FmeProjectScope := TMemo.Create(Self);
  FmeProjectScope.Parent := Scroll; FmeProjectScope.Align := alTop; FmeProjectScope.Height := 90;
  FmeProjectScope.ScrollBars := ssAutoVertical;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Scroll; Lbl.Align := alTop; Lbl.BorderSpacing.Around := 6;
  Lbl.Caption := 'Restrições e Fora de Escopo (O que NÃO fazer):';
  FmeProjectConstraints := TMemo.Create(Self);
  FmeProjectConstraints.Parent := Scroll; FmeProjectConstraints.Align := alTop; FmeProjectConstraints.Height := 70;
  FmeProjectConstraints.ScrollBars := ssAutoVertical;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Scroll; Lbl.Align := alTop; Lbl.BorderSpacing.Around := 6;
  Lbl.Caption := 'Critérios de Sucesso / Entregáveis Esperados:';
  FmeProjectDeliverables := TMemo.Create(Self);
  FmeProjectDeliverables.Parent := Scroll; FmeProjectDeliverables.Align := alTop; FmeProjectDeliverables.Height := 70;
  FmeProjectDeliverables.ScrollBars := ssAutoVertical;

  BottomPnl := TPanel.Create(Self);
  BottomPnl.Parent := FObjectivesTab;
  BottomPnl.Align := alBottom;
  BottomPnl.Height := 40;
  BottomPnl.BevelOuter := bvNone;

  Btn := TButton.Create(Self);
  Btn.Parent := BottomPnl; Btn.Caption := '💾 Salvar Objetivos'; Btn.Left := 10; Btn.Top := 6; Btn.Width := 140;
  Btn.OnClick := @SaveObjectivesClick;

  Btn := TButton.Create(Self);
  Btn.Parent := BottomPnl; Btn.Caption := '🤖 Aprimorar Objetivos com IA'; Btn.Left := 160; Btn.Top := 6; Btn.Width := 190;
  Btn.OnClick := @SuggestObjectivesAIClick;
end;

procedure TMNoteTasksPanel.BuildRequirementsTab;
var
  TopPnl, BottomPnl, PnlRF, PnlRNF: TPanel;
  Lbl: TLabel;
  Btn: TButton;
  Splitter: TSplitter;
begin
  FRequirementsTab := TTabSheet.Create(Self);
  FRequirementsTab.PageControl := FPages;
  FRequirementsTab.Caption := 'Requisitos (RF/RNF)';

  PnlRF := TPanel.Create(Self);
  PnlRF.Parent := FRequirementsTab;
  PnlRF.Align := alTop;
  PnlRF.Height := 240;
  PnlRF.BevelOuter := bvNone;

  TopPnl := TPanel.Create(Self);
  TopPnl.Parent := PnlRF; TopPnl.Align := alTop; TopPnl.Height := 32; TopPnl.BevelOuter := bvNone;
  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 8; Lbl.Top := 8; Lbl.Caption := 'Requisitos Funcionais (RF):';
  Lbl.Font.Style := [fsBold];

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '+ RF'; Btn.Left := 220; Btn.Top := 4; Btn.Width := 50;
  Btn.OnClick := @AddRFClick;
  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := 'Editar'; Btn.Left := 274; Btn.Top := 4; Btn.Width := 50;
  Btn.OnClick := @EditRFClick;
  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := 'Excluir'; Btn.Left := 328; Btn.Top := 4; Btn.Width := 50;
  Btn.OnClick := @DeleteRFClick;

  FlvFunctional := TListView.Create(Self);
  FlvFunctional.Parent := PnlRF;
  FlvFunctional.Align := alClient;
  FlvFunctional.ViewStyle := vsReport;
  FlvFunctional.ReadOnly := True;
  FlvFunctional.RowSelect := True;
  AddColumn(FlvFunctional, 'ID', 60);
  AddColumn(FlvFunctional, 'Título', 200);
  AddColumn(FlvFunctional, 'Prioridade', 80);
  AddColumn(FlvFunctional, 'Status', 80);
  AddColumn(FlvFunctional, 'Descrição', 300);

  Splitter := TSplitter.Create(Self);
  Splitter.Parent := FRequirementsTab;
  Splitter.Align := alTop;
  Splitter.Height := 4;

  PnlRNF := TPanel.Create(Self);
  PnlRNF.Parent := FRequirementsTab;
  PnlRNF.Align := alClient;
  PnlRNF.BevelOuter := bvNone;

  TopPnl := TPanel.Create(Self);
  TopPnl.Parent := PnlRNF; TopPnl.Align := alTop; TopPnl.Height := 32; TopPnl.BevelOuter := bvNone;
  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 8; Lbl.Top := 8; Lbl.Caption := 'Requisitos Não-Funcionais (RNF - Performance, Segurança, Stack):';
  Lbl.Font.Style := [fsBold];

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '+ RNF'; Btn.Left := 440; Btn.Top := 4; Btn.Width := 50;
  Btn.OnClick := @AddRNFClick;
  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := 'Editar'; Btn.Left := 494; Btn.Top := 4; Btn.Width := 50;
  Btn.OnClick := @EditRNFClick;
  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := 'Excluir'; Btn.Left := 548; Btn.Top := 4; Btn.Width := 50;
  Btn.OnClick := @DeleteRNFClick;

  FlvNonFunctional := TListView.Create(Self);
  FlvNonFunctional.Parent := PnlRNF;
  FlvNonFunctional.Align := alClient;
  FlvNonFunctional.ViewStyle := vsReport;
  FlvNonFunctional.ReadOnly := True;
  FlvNonFunctional.RowSelect := True;
  AddColumn(FlvNonFunctional, 'ID', 60);
  AddColumn(FlvNonFunctional, 'Categoria', 120);
  AddColumn(FlvNonFunctional, 'Prioridade', 80);
  AddColumn(FlvNonFunctional, 'Descrição', 400);

  BottomPnl := TPanel.Create(Self);
  BottomPnl.Parent := FRequirementsTab;
  BottomPnl.Align := alBottom;
  BottomPnl.Height := 40;
  BottomPnl.BevelOuter := bvNone;

  Btn := TButton.Create(Self);
  Btn.Parent := BottomPnl; Btn.Caption := '💾 Salvar Requisitos'; Btn.Left := 10; Btn.Top := 6; Btn.Width := 140;
  Btn.OnClick := @SaveRequirementsClick;

  Btn := TButton.Create(Self);
  Btn.Parent := BottomPnl; Btn.Caption := '🤖 Sugerir Requisitos com IA'; Btn.Left := 160; Btn.Top := 6; Btn.Width := 190;
  Btn.OnClick := @SuggestRequirementsAIClick;
end;

procedure TMNoteTasksPanel.BuildDatabaseTab;
var
  Lbl: TLabel;
  Btn: TButton;
  TopPnl: TPanel;
begin
  FDatabaseTab := TTabSheet.Create(Self);
  FDatabaseTab.PageControl := FPages;
  FDatabaseTab.Caption := 'Bancos & Conexões';

  TopPnl := TPanel.Create(Self);
  TopPnl.Parent := FDatabaseTab;
  TopPnl.Align := alClient;
  TopPnl.BevelOuter := bvNone;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 20; Lbl.Top := 15; Lbl.Caption := 'Tipo de Banco de Dados:';
  FcbDBType := TComboBox.Create(Self);
  FcbDBType.Parent := TopPnl; FcbDBType.Left := 20; FcbDBType.Top := 33; FcbDBType.Width := 200;
  FcbDBType.Style := csDropDownList;
  FcbDBType.Items.AddStrings(['MySQL / MariaDB', 'PostgreSQL', 'SQLite', 'Microsoft SQL Server', 'Oracle Database']);
  FcbDBType.ItemIndex := 1;
  FcbDBType.OnChange := @DBTypeChange;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 20; Lbl.Top := 70; Lbl.Caption := 'Hostname (ou Host:Porta):';
  FedDBHost := TEdit.Create(Self);
  FedDBHost.Parent := TopPnl; FedDBHost.Left := 20; FedDBHost.Top := 88; FedDBHost.Width := 260;
  FedDBHost.Text := '127.0.0.1';

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 290; Lbl.Top := 70; Lbl.Caption := 'Porta:';
  FedDBPort := TEdit.Create(Self);
  FedDBPort.Parent := TopPnl; FedDBPort.Left := 290; FedDBPort.Top := 88; FedDBPort.Width := 80;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 20; Lbl.Top := 125; Lbl.Caption := 'Banco de Dados (Database):';
  FedDBName := TEdit.Create(Self);
  FedDBName.Parent := TopPnl; FedDBName.Left := 20; FedDBName.Top := 143; FedDBName.Width := 260;
  FedDBName.Text := 'meubanco';

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 290; Lbl.Top := 125; Lbl.Caption := 'Schema (Esquema opcional):';
  FedDBSchema := TEdit.Create(Self);
  FedDBSchema.Parent := TopPnl; FedDBSchema.Left := 290; FedDBSchema.Top := 143; FedDBSchema.Width := 160;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 20; Lbl.Top := 180; Lbl.Caption := 'Usuário:';
  FedDBUser := TEdit.Create(Self);
  FedDBUser.Parent := TopPnl; FedDBUser.Left := 20; FedDBUser.Top := 198; FedDBUser.Width := 200;
  FedDBUser.Text := 'postgres';

  Lbl := TLabel.Create(Self);
  Lbl.Parent := TopPnl; Lbl.Left := 230; Lbl.Top := 180; Lbl.Caption := 'Senha:';
  FedDBPassword := TEdit.Create(Self);
  FedDBPassword.Parent := TopPnl; FedDBPassword.Left := 230; FedDBPassword.Top := 198; FedDBPassword.Width := 220;
  FedDBPassword.EchoMode := emPassword;
  FedDBPassword.PasswordChar := '*';

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '🔌 Testar Conexão'; Btn.Left := 20; Btn.Top := 245; Btn.Width := 150;
  Btn.OnClick := @TestDBConnectionClick;

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '💾 Salvar Conexão no Projeto'; Btn.Left := 180; Btn.Top := 245; Btn.Width := 190;
  Btn.OnClick := @SaveDBConnectionClick;

  FlblDBStatus := TLabel.Create(Self);
  FlblDBStatus.Parent := TopPnl; FlblDBStatus.Left := 20; FlblDBStatus.Top := 285;
  FlblDBStatus.Caption := 'Status: Não testado.';
  FlblDBStatus.Font.Style := [fsBold];
end;

procedure TMNoteTasksPanel.BuildAPIsTab;
var
  TopPnl, SplitterPnl: TPanel;
  Lbl: TLabel;
  Btn: TButton;
  Splitter: TSplitter;
begin
  FAPIsTab := TTabSheet.Create(Self);
  FAPIsTab.PageControl := FPages;
  FAPIsTab.Caption := 'Web APIs';

  TopPnl := TPanel.Create(Self);
  TopPnl.Parent := FAPIsTab; TopPnl.Align := alTop; TopPnl.Height := 34; TopPnl.BevelOuter := bvNone;

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '+ Nova API'; Btn.Left := 8; Btn.Top := 4; Btn.Width := 85;
  Btn.OnClick := @AddAPIClick;

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := 'Editar'; Btn.Left := 98; Btn.Top := 4; Btn.Width := 60;
  Btn.OnClick := @EditAPIClick;

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := 'Excluir'; Btn.Left := 162; Btn.Top := 4; Btn.Width := 60;
  Btn.OnClick := @DeleteAPIClick;

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '💾 Salvar APIs'; Btn.Left := 228; Btn.Top := 4; Btn.Width := 95;
  Btn.OnClick := @SaveAPIsClick;

  FlvAPIs := TListView.Create(Self);
  FlvAPIs.Parent := FAPIsTab;
  FlvAPIs.Align := alTop;
  FlvAPIs.Height := 180;
  FlvAPIs.ViewStyle := vsReport;
  FlvAPIs.ReadOnly := True;
  FlvAPIs.RowSelect := True;
  FlvAPIs.OnSelectItem := @APISelectionChanged;
  AddColumn(FlvAPIs, 'ID', 60);
  AddColumn(FlvAPIs, 'Nome', 150);
  AddColumn(FlvAPIs, 'URL Base / Endpoint', 250);
  AddColumn(FlvAPIs, 'Método', 70);
  AddColumn(FlvAPIs, 'Autenticação', 100);

  Splitter := TSplitter.Create(Self);
  Splitter.Parent := FAPIsTab;
  Splitter.Align := alTop;
  Splitter.Height := 4;

  SplitterPnl := TPanel.Create(Self);
  SplitterPnl.Parent := FAPIsTab;
  SplitterPnl.Align := alClient;
  SplitterPnl.BevelOuter := bvNone;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := SplitterPnl; Lbl.Align := alTop; Lbl.BorderSpacing.Around := 4;
  Lbl.Caption := 'Especificação de Contratos, Headers e Payloads JSON:';

  FmeAPISpec := TMemo.Create(Self);
  FmeAPISpec.Parent := SplitterPnl;
  FmeAPISpec.Align := alClient;
  FmeAPISpec.ScrollBars := ssAutoBoth;
end;

procedure TMNoteTasksPanel.BuildOrchestratorTab;
var
  TopPnl: TPanel;
  Btn: TButton;
  Lbl: TLabel;
begin
  FOrchestratorTab := TTabSheet.Create(Self);
  FOrchestratorTab.PageControl := FPages;
  FOrchestratorTab.Caption := 'Orquestrador IA';

  TopPnl := TPanel.Create(Self);
  TopPnl.Parent := FOrchestratorTab;
  TopPnl.Align := alTop;
  TopPnl.Height := 90;
  TopPnl.BevelOuter := bvNone;

  FlblOrchestratorStatus := TLabel.Create(Self);
  FlblOrchestratorStatus.Parent := TopPnl; FlblOrchestratorStatus.Left := 10; FlblOrchestratorStatus.Top := 8;
  FlblOrchestratorStatus.Caption := 'Fluxo de Orquestração: Projeto pronto para análise.';
  FlblOrchestratorStatus.Font.Style := [fsBold];

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '1️⃣ Analisar Projeto & Requisitos';
  Btn.Left := 10; Btn.Top := 36; Btn.Width := 200; Btn.OnClick := @OrchestratorStep1Click;

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '2️⃣ Planejar Tarefas EAP';
  Btn.Left := 216; Btn.Top := 36; Btn.Width := 160; Btn.OnClick := @OrchestratorStep2Click;

  Btn := TButton.Create(Self);
  Btn.Parent := TopPnl; Btn.Caption := '3️⃣ Executar Próxima Tarefa com IA';
  Btn.Left := 382; Btn.Top := 36; Btn.Width := 220; Btn.OnClick := @OrchestratorStep3Click;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := FOrchestratorTab; Lbl.Align := alTop; Lbl.BorderSpacing.Around := 6;
  Lbl.Caption := 'Log da Orquestração e Orientações da IA:';

  FmeOrchestratorLog := TMemo.Create(Self);
  FmeOrchestratorLog.Parent := FOrchestratorTab;
  FmeOrchestratorLog.Align := alClient;
  FmeOrchestratorLog.ReadOnly := True;
  FmeOrchestratorLog.ScrollBars := ssAutoBoth;
end;

procedure TMNoteTasksPanel.OpenProject(const AProjectRoot, AProjectName: string);
var
  ProjectFile, ProjectDisplayName, LoadError: string;
  Search: TSearchRec;
begin
  ProjectDisplayName := AProjectName;
  if ProjectDisplayName = '' then
    ProjectDisplayName := ExtractFileName(ExcludeTrailingPathDelimiter(AProjectRoot));
  if ProjectDisplayName = '' then ProjectDisplayName := 'MNote2';

  ProjectFile := '';
  if FindFirst(IncludeTrailingPathDelimiter(AProjectRoot) + '*.mnoteproj.json', faAnyFile, Search) = 0 then
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
    ProjectFile := IncludeTrailingPathDelimiter(AProjectRoot) + ProjectDisplayName + '.mnoteproj.json';

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

  Refresh;
end;

procedure TMNoteTasksPanel.CloseProject;
begin
  FService.NewProject('', '');
  Refresh;
end;

procedure TMNoteTasksPanel.Refresh;
begin
  RefreshList;
  RefreshObjectives;
  RefreshRequirements;
  RefreshDatabase;
  RefreshAPIs;
  RefreshOrchestrator;
end;

procedure TMNoteTasksPanel.ShowObjectivesTab;
begin
  if FPages <> nil then FPages.ActivePage := FObjectivesTab;
end;

procedure TMNoteTasksPanel.ShowTasksTab;
begin
  if FPages <> nil then FPages.ActivePage := FTasksTab;
end;

procedure TMNoteTasksPanel.RefreshList;
var
  I: Integer;
  Task: TJSONObject;
  Item: TListItem;
  TasksArray: TJSONArray;
  WBSVal, TitleVal, KindVal, StatusVal, PriorityVal, AssignedVal: string;
  LevelVal, ProgVal, HoursVal: Integer;
  EstObj: TJSONObject;
begin
  TasksArray := FService.Tasks.Tasks;
  CalculateWBS(TasksArray);

  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    if TasksArray <> nil then
      for I := 0 to TasksArray.Count - 1 do
      begin
        if not (TasksArray.Items[I] is TJSONObject) then Continue;
        Task := TasksArray.Objects[I];

        WBSVal := Task.Get('wbs', '');
        LevelVal := Task.Get('level', 1);
        KindVal := Task.Get('kind', 'code');
        TitleVal := Task.Get('title', '');
        if LevelVal > 1 then
          TitleVal := StringOfChar(' ', (LevelVal - 1) * 3) + TitleVal;

        StatusVal := Task.Get('status', 'planned');
        PriorityVal := Task.Get('priority', 'medium');
        AssignedVal := Task.Get('assigned_to', 'Dev');
        ProgVal := Task.Get('progress_percent', 0);

        HoursVal := 1;
        EstObj := SafeGetObject(Task, 'estimated_hours');
        if EstObj <> nil then
          HoursVal := EstObj.Get('mid_level', 1);

        Item := FList.Items.Add;
        Item.Caption := WBSVal;
        Item.SubItems.Add(Task.Get('id', ''));
        Item.SubItems.Add(TitleVal);
        Item.SubItems.Add(KindVal);
        Item.SubItems.Add(StatusVal);
        Item.SubItems.Add(PriorityVal);
        Item.SubItems.Add(AssignedVal);
        Item.SubItems.Add(IntToStr(ProgVal));
        Item.SubItems.Add(IntToStr(HoursVal));
      end;
  finally
    FList.Items.EndUpdate;
  end;
end;

procedure TMNoteTasksPanel.RefreshObjectives;
var
  ProjObj: TJSONObject;
begin
  FedProjectName.Text := FService.Project.Name;
  FmeProjectGoal.Text := FService.Project.Goal;
  FmeProjectScope.Text := FService.Project.Scope;
  FmeProjectConstraints.Text := FService.Project.Constraints;
  FmeProjectDeliverables.Text := FService.Project.ExpectedDeliverables;

  ProjObj := SafeGetObject(FService.Project.ProjectData, 'project');
  if ProjObj <> nil then
  begin
    FedProjectAuthor.Text := ProjObj.Get('author', '');
    FedProjectVersion.Text := ProjObj.Get('revision', '1.0');
  end;
end;

procedure TMNoteTasksPanel.RefreshRequirements;
var
  Agile: TJSONObject;
  FRArray, NFRArray: TJSONArray;
  I: Integer;
  Obj: TJSONObject;
  Item: TListItem;
begin
  FlvFunctional.Items.BeginUpdate;
  try
    FlvFunctional.Items.Clear;
    Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
    if Agile <> nil then
    begin
      FRArray := SafeGetArray(Agile, 'functional_requirements');
      if FRArray <> nil then
        for I := 0 to FRArray.Count - 1 do
          if FRArray.Items[I] is TJSONObject then
          begin
            Obj := FRArray.Objects[I];
            Item := FlvFunctional.Items.Add;
            Item.Caption := Obj.Get('id', '');
            Item.SubItems.Add(Obj.Get('title', ''));
            Item.SubItems.Add(Obj.Get('priority', 'medium'));
            Item.SubItems.Add(Obj.Get('status', 'draft'));
            Item.SubItems.Add(Obj.Get('description', ''));
          end;
    end;
  finally
    FlvFunctional.Items.EndUpdate;
  end;

  FlvNonFunctional.Items.BeginUpdate;
  try
    FlvNonFunctional.Items.Clear;
    if Agile <> nil then
    begin
      NFRArray := SafeGetArray(Agile, 'non_functional_requirements');
      if NFRArray <> nil then
        for I := 0 to NFRArray.Count - 1 do
          if NFRArray.Items[I] is TJSONObject then
          begin
            Obj := NFRArray.Objects[I];
            Item := FlvNonFunctional.Items.Add;
            Item.Caption := Obj.Get('id', '');
            Item.SubItems.Add(Obj.Get('category', 'performance'));
            Item.SubItems.Add(Obj.Get('priority', 'medium'));
            Item.SubItems.Add(Obj.Get('description', ''));
          end;
    end;
  finally
    FlvNonFunctional.Items.EndUpdate;
  end;
end;

procedure TMNoteTasksPanel.RefreshDatabase;
var
  Agile: TJSONObject;
  DBArray: TJSONArray;
  Obj: TJSONObject;
begin
  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  DBArray := SafeGetArray(Agile, 'database_connections');
  if (DBArray <> nil) and (DBArray.Count > 0) and (DBArray.Items[0] is TJSONObject) then
  begin
    Obj := DBArray.Objects[0];
    FcbDBType.ItemIndex := Obj.Get('db_type', 1);
    FedDBHost.Text := Obj.Get('host', '127.0.0.1');
    FedDBPort.Text := Obj.Get('port', '');
    FedDBName.Text := Obj.Get('database', '');
    FedDBSchema.Text := Obj.Get('schema', '');
    FedDBUser.Text := Obj.Get('user', '');
  end;
end;

procedure TMNoteTasksPanel.RefreshAPIs;
var
  Agile: TJSONObject;
  APIArray: TJSONArray;
  I: Integer;
  Obj: TJSONObject;
  Item: TListItem;
begin
  FlvAPIs.Items.BeginUpdate;
  try
    FlvAPIs.Items.Clear;
    Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
    if Agile <> nil then
    begin
      APIArray := SafeGetArray(Agile, 'external_apis');
      if APIArray <> nil then
        for I := 0 to APIArray.Count - 1 do
          if APIArray.Items[I] is TJSONObject then
          begin
            Obj := APIArray.Objects[I];
            Item := FlvAPIs.Items.Add;
            Item.Caption := Obj.Get('id', '');
            Item.SubItems.Add(Obj.Get('name', ''));
            Item.SubItems.Add(Obj.Get('base_url', ''));
            Item.SubItems.Add(Obj.Get('method', 'GET'));
            Item.SubItems.Add(Obj.Get('auth_type', 'Bearer'));
          end;
    end;
  finally
    FlvAPIs.Items.EndUpdate;
  end;
end;

procedure TMNoteTasksPanel.RefreshOrchestrator;
var
  Total, Done, InProg: Integer;
  TasksArray: TJSONArray;
  I: Integer;
  Task: TJSONObject;
  Status: string;
begin
  Total := 0; Done := 0; InProg := 0;
  TasksArray := FService.Tasks.Tasks;
  if TasksArray <> nil then
  begin
    Total := TasksArray.Count;
    for I := 0 to Total - 1 do
      if TasksArray.Items[I] is TJSONObject then
      begin
        Task := TasksArray.Objects[I];
        Status := LowerCase(Task.Get('status', ''));
        if (Status = 'done') or (Status = 'concluida') then Inc(Done)
        else if (Status = 'in_progress') or (Status = 'review') then Inc(InProg);
      end;
  end;

  FlblOrchestratorStatus.Caption := Format('Projeto: %s | Total Tarefas: %d | Concluídas: %d | Em Andamento: %d',
    [FService.Project.Name, Total, Done, InProg]);

  FmeOrchestratorLog.Lines.Clear;
  FmeOrchestratorLog.Lines.Add('=== FLUXO DE ORQUESTRAÇÃO POR IA ===');
  FmeOrchestratorLog.Lines.Add('1. Defina o Objetivo e Escopo na aba Objetivos.');
  FmeOrchestratorLog.Lines.Add('2. Cadastre ou gere os Requisitos Funcionais e Não Funcionais.');
  FmeOrchestratorLog.Lines.Add('3. Configure o Banco de Dados e as Web APIs para que a IA conheça o ecossistema.');
  FmeOrchestratorLog.Lines.Add('4. Gere a EAP e as tarefas usando o botão "Plano IA".');
  FmeOrchestratorLog.Lines.Add('5. Selecione qualquer tarefa e clique em "🤖 Implementar com IA" para gerar o código.');
end;

procedure TMNoteTasksPanel.SaveAndRefresh;
var
  SaveDlg: TSaveDialog;
begin
  if FService.FileName = '' then
  begin
    SaveDlg := TSaveDialog.Create(nil);
    try
      SaveDlg.Title := 'Salvar Projeto MNote';
      SaveDlg.Filter := 'Projeto MNote (*.mnoteproj.json)|*.mnoteproj.json|Todos os arquivos (*.*)|*.*';
      SaveDlg.DefaultExt := 'mnoteproj.json';
      if SaveDlg.Execute then
      begin
        if not FService.SaveAs(SaveDlg.FileName) then
          MessageDlg('Projeto', FService.LastError, mtError, [mbOK], 0);
      end;
    finally
      SaveDlg.Free;
    end;
  end
  else
  begin
    if not FService.Save then
      MessageDlg('Tarefas', FService.LastError, mtError, [mbOK], 0);
  end;
  Refresh;
end;

function TMNoteTasksPanel.SelectedTaskIndex: Integer;
begin
  Result := -1;
  if (FList = nil) or (FList.Selected = nil) then Exit;
  Result := FList.Selected.Index;
end;

function TMNoteTasksPanel.SelectedTask: TJSONObject;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := SelectedTaskIndex;
  if (Idx >= 0) and (Idx < FService.Tasks.Tasks.Count) then
    Result := FService.Tasks.Tasks.Objects[Idx];
end;

procedure TMNoteTasksPanel.SelectionChanged(Sender: TObject; Item: TListItem; Selected: Boolean);
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

  FDetails.Lines.Text := 'EAP: ' + Task.Get('wbs', '') + ' | ID: ' + Task.Get('id', '') +
    ' | Tipo: ' + Task.Get('kind', 'code') + LineEnding +
    'Título: ' + Task.Get('title', '') + LineEnding +
    'Status: ' + Task.Get('status', 'draft') + ' | Prioridade: ' + Task.Get('priority', 'medium') +
    ' | Responsável: ' + Task.Get('assigned_to', 'Dev') + LineEnding +
    '------------------------------------------------------------' + LineEnding +
    'Descrição:' + LineEnding + Task.Get('description', '') + LineEnding + LineEnding +
    'Especificação Arquitetural / Descrição Longa:' + LineEnding + Task.Get('long_description', '') + LineEnding + LineEnding +
    'Critérios de Aceite:' + LineEnding + Task.Get('acceptance_criteria', '') + LineEnding + LineEnding +
    'Dependências: ' + JSONArrayText(Task.Find('dependencies')) + LineEnding +
    'Arquivos Afetados: ' + JSONArrayText(Task.Find('files_affected')) + LineEnding +
    'Commits: ' + JSONArrayText(Task.Find('commits')) + LineEnding + LineEnding +
    'Notas:' + LineEnding + Task.Get('notes', '');

  History := SafeGetArray(FService.Project.ProjectData, 'task_actions');
  if History <> nil then
  begin
    FDetails.Lines.Add(LineEnding + '--- Histórico de Ações ---');
    for I := 0 to History.Count - 1 do
    begin
      if History.Items[I] is TJSONObject then
      begin
        Entry := History.Objects[I];
        if SameText(Entry.Get('task_id', ''), Task.Get('id', '')) then
          FDetails.Lines.Add(Format('%s: %s (%s -> %s) %s',
            [Entry.Get('created_at', ''), Entry.Get('action', ''),
             Entry.Get('previous_status', ''), Entry.Get('new_status', ''),
             Entry.Get('comment', '')]));
      end;
    end;
  end;

  FLinks.Items.Clear;
  Dependencies := SafeGetArray(Task, 'dependencies');
  if Dependencies <> nil then
    for I := 0 to Dependencies.Count - 1 do
      FLinks.Items.Add('DEPENDÊNCIA: ' + Dependencies.Strings[I]);
  Files := SafeGetArray(Task, 'files_affected');
  if Files <> nil then
    for I := 0 to Files.Count - 1 do
      FLinks.Items.Add('ARQUIVO: ' + Files.Strings[I]);
  Commits := SafeGetArray(Task, 'commits');
  if Commits <> nil then
    for I := 0 to Commits.Count - 1 do
      FLinks.Items.Add('COMMIT: ' + Commits.Strings[I]);
end;

function TMNoteTasksPanel.EditTaskDialog(ATask: TJSONObject; ANew: Boolean; const AKind: string = 'code'): Boolean;
var
  Dialog: TForm;
  TitleEdit, HoursEdit, AssignedEdit, FilesEdit, CriteriaEdit: TEdit;
  DescriptionEdit, LongEdit: TMemo;
  KindCombo, PriorityCombo, StatusCombo: TComboBox;
  OkButton, CancelButton: TButton;
  Lbl: TLabel;
  ID, SelectedKind: string;
begin
  Dialog := TForm.Create(nil);
  try
    Dialog.Caption := IfThen(ANew, 'Nova Tarefa do Projeto', 'Editar Tarefa');
    Dialog.Position := poScreenCenter;
    Dialog.Width := 560; Dialog.Height := 540;

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(12, 10, 80, 18); Lbl.Caption := 'Tipo:';
    KindCombo := TComboBox.Create(Dialog); KindCombo.Parent := Dialog; KindCombo.SetBounds(12, 28, 140, 24);
    KindCombo.Style := csDropDownList;
    KindCombo.Items.AddStrings(['code', 'summary', 'milestone', 'database', 'api', 'test', 'general']);
    KindCombo.ItemIndex := KindCombo.Items.IndexOf(AKind);
    if KindCombo.ItemIndex < 0 then KindCombo.ItemIndex := 0;

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(160, 10, 100, 18); Lbl.Caption := 'Prioridade:';
    PriorityCombo := TComboBox.Create(Dialog); PriorityCombo.Parent := Dialog; PriorityCombo.SetBounds(160, 28, 110, 24);
    PriorityCombo.Style := csDropDownList;
    PriorityCombo.Items.AddStrings(['high', 'medium', 'low']);
    PriorityCombo.ItemIndex := 1;

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(280, 10, 100, 18); Lbl.Caption := 'Status:';
    StatusCombo := TComboBox.Create(Dialog); StatusCombo.Parent := Dialog; StatusCombo.SetBounds(280, 28, 120, 24);
    StatusCombo.Style := csDropDownList;
    StatusCombo.Items.AddStrings(['suggested', 'planned', 'in_progress', 'review', 'done', 'blocked']);
    StatusCombo.ItemIndex := 1;

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(410, 10, 80, 18); Lbl.Caption := 'Horas:';
    HoursEdit := TEdit.Create(Dialog); HoursEdit.Parent := Dialog; HoursEdit.SetBounds(410, 28, 120, 24);
    HoursEdit.Text := '2';

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(12, 60, 100, 18); Lbl.Caption := 'Título:';
    TitleEdit := TEdit.Create(Dialog); TitleEdit.Parent := Dialog; TitleEdit.SetBounds(12, 78, 520, 24);

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(12, 110, 100, 18); Lbl.Caption := 'Responsável:';
    AssignedEdit := TEdit.Create(Dialog); AssignedEdit.Parent := Dialog; AssignedEdit.SetBounds(12, 128, 250, 24);
    AssignedEdit.Text := 'Dev';

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(270, 110, 150, 18); Lbl.Caption := 'Arquivos Afetados:';
    FilesEdit := TEdit.Create(Dialog); FilesEdit.Parent := Dialog; FilesEdit.SetBounds(270, 128, 262, 24);

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(12, 160, 150, 18); Lbl.Caption := 'Critérios de Aceite:';
    CriteriaEdit := TEdit.Create(Dialog); CriteriaEdit.Parent := Dialog; CriteriaEdit.SetBounds(12, 178, 520, 24);

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(12, 210, 100, 18); Lbl.Caption := 'Descrição:';
    DescriptionEdit := TMemo.Create(Dialog); DescriptionEdit.Parent := Dialog; DescriptionEdit.SetBounds(12, 228, 520, 80);

    Lbl := TLabel.Create(Dialog); Lbl.Parent := Dialog; Lbl.SetBounds(12, 316, 200, 18); Lbl.Caption := 'Especificação / Detalhes Arquiteturais:';
    LongEdit := TMemo.Create(Dialog); LongEdit.Parent := Dialog; LongEdit.SetBounds(12, 334, 520, 110);

    if ATask <> nil then
    begin
      TitleEdit.Text := ATask.Get('title', '');
      DescriptionEdit.Text := ATask.Get('description', '');
      LongEdit.Text := ATask.Get('long_description', '');
      CriteriaEdit.Text := ATask.Get('acceptance_criteria', '');
      AssignedEdit.Text := ATask.Get('assigned_to', 'Dev');
      SelectedKind := ATask.Get('kind', 'code');
      KindCombo.ItemIndex := KindCombo.Items.IndexOf(SelectedKind);
      PriorityCombo.ItemIndex := PriorityCombo.Items.IndexOf(ATask.Get('priority', 'medium'));
      StatusCombo.ItemIndex := StatusCombo.Items.IndexOf(ATask.Get('status', 'planned'));
      if SafeGetObject(ATask, 'estimated_hours') <> nil then
        HoursEdit.Text := IntToStr(SafeGetObject(ATask, 'estimated_hours').Get('mid_level', 1));
      FilesEdit.Text := JSONArrayText(ATask.Find('files_affected'));
    end;

    OkButton := TButton.Create(Dialog); OkButton.Parent := Dialog; OkButton.Caption := 'Salvar';
    OkButton.ModalResult := mrOk; OkButton.SetBounds(350, 460, 85, 30);

    CancelButton := TButton.Create(Dialog); CancelButton.Parent := Dialog; CancelButton.Caption := 'Cancelar';
    CancelButton.ModalResult := mrCancel; CancelButton.SetBounds(447, 460, 85, 30);

    Result := Dialog.ShowModal = mrOk;
    if not Result then Exit;
    if Trim(TitleEdit.Text) = '' then Exit(False);

    if ANew then
    begin
      ID := FService.Tasks.AddTask(TitleEdit.Text, DescriptionEdit.Text,
        PriorityCombo.Text, 'DEV', AssignedEdit.Text, StrToIntDef(HoursEdit.Text, 1));
      ATask := FService.Tasks.GetTaskByID(ID);
      if ATask <> nil then
      begin
        if ATask.IndexOfName('kind') >= 0 then ATask.Strings['kind'] := KindCombo.Text
        else ATask.Add('kind', KindCombo.Text);
        if ATask.IndexOfName('level') < 0 then ATask.Add('level', 1);
      end;
    end;

    if ATask <> nil then
    begin
      FService.Tasks.UpdateTask(ATask.Get('id', ''), TitleEdit.Text,
        DescriptionEdit.Text, LongEdit.Text, PriorityCombo.Text,
        AssignedEdit.Text, StrToIntDef(HoursEdit.Text, 1));

      if ATask.IndexOfName('kind') >= 0 then ATask.Strings['kind'] := KindCombo.Text
      else ATask.Add('kind', KindCombo.Text);

      if ATask.IndexOfName('status') >= 0 then ATask.Strings['status'] := StatusCombo.Text
      else ATask.Add('status', StatusCombo.Text);

      if ATask.IndexOfName('acceptance_criteria') >= 0 then ATask.Strings['acceptance_criteria'] := CriteriaEdit.Text
      else ATask.Add('acceptance_criteria', CriteriaEdit.Text);
    end;
  finally
    Dialog.Free;
  end;
end;

procedure TMNoteTasksPanel.NewTask(Sender: TObject);
begin
  if EditTaskDialog(nil, True, 'code') then SaveAndRefresh;
end;

procedure TMNoteTasksPanel.NewSummary(Sender: TObject);
begin
  if EditTaskDialog(nil, True, 'summary') then SaveAndRefresh;
end;

procedure TMNoteTasksPanel.NewMilestone(Sender: TObject);
begin
  if EditTaskDialog(nil, True, 'milestone') then SaveAndRefresh;
end;

procedure TMNoteTasksPanel.EditTask(Sender: TObject);
var
  Task: TJSONObject;
begin
  Task := SelectedTask;
  if (Task <> nil) and EditTaskDialog(Task, False, Task.Get('kind', 'code')) then SaveAndRefresh;
end;

procedure TMNoteTasksPanel.DeleteTask(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := SelectedTaskIndex;
  if Idx < 0 then Exit;
  if MessageDlg('Tarefas', 'Deseja excluir a tarefa selecionada?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FService.Tasks.Tasks.Delete(Idx);
    SaveAndRefresh;
  end;
end;

procedure TMNoteTasksPanel.IndentTask(Sender: TObject);
var
  Idx, L, MaxL: Integer;
  Task, PrevTask: TJSONObject;
begin
  Idx := SelectedTaskIndex;
  if Idx <= 0 then Exit;
  Task := FService.Tasks.Tasks.Objects[Idx];
  PrevTask := FService.Tasks.Tasks.Objects[Idx - 1];
  L := Task.Get('level', 1);
  MaxL := PrevTask.Get('level', 1) + 1;
  if L < MaxL then
  begin
    if Task.IndexOfName('level') >= 0 then Task.Integers['level'] := L + 1
    else Task.Add('level', L + 1);
    SaveAndRefresh;
    if (FList <> nil) and (Idx < FList.Items.Count) then
      FList.Items[Idx].Selected := True;
  end;
end;

procedure TMNoteTasksPanel.OutdentTask(Sender: TObject);
var
  Idx, L: Integer;
  Task: TJSONObject;
begin
  Idx := SelectedTaskIndex;
  if Idx < 0 then Exit;
  Task := FService.Tasks.Tasks.Objects[Idx];
  L := Task.Get('level', 1);
  if L > 1 then
  begin
    if Task.IndexOfName('level') >= 0 then Task.Integers['level'] := L - 1
    else Task.Add('level', L - 1);
    SaveAndRefresh;
    if (FList <> nil) and (Idx < FList.Items.Count) then
      FList.Items[Idx].Selected := True;
  end;
end;

procedure TMNoteTasksPanel.MoveTaskUp(Sender: TObject);
var
  Idx: Integer;
  Tasks: TJSONArray;
  Item: TJSONData;
begin
  Idx := SelectedTaskIndex;
  if Idx <= 0 then Exit;
  Tasks := FService.Tasks.Tasks;
  Item := Tasks.Items[Idx];
  Tasks.Extract(Idx);
  Tasks.Insert(Idx - 1, Item);
  SaveAndRefresh;
  if (FList <> nil) and (Idx - 1 < FList.Items.Count) then
    FList.Items[Idx - 1].Selected := True;
end;

procedure TMNoteTasksPanel.MoveTaskDown(Sender: TObject);
var
  Idx: Integer;
  Tasks: TJSONArray;
  Item: TJSONData;
begin
  Idx := SelectedTaskIndex;
  Tasks := FService.Tasks.Tasks;
  if (Idx < 0) or (Idx >= Tasks.Count - 1) then Exit;
  Item := Tasks.Items[Idx];
  Tasks.Extract(Idx);
  Tasks.Insert(Idx + 1, Item);
  SaveAndRefresh;
  if (FList <> nil) and (Idx + 1 < FList.Items.Count) then
    FList.Items[Idx + 1].Selected := True;
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
      if MessageDlg('Tarefas', 'Vincular o commit HEAD ' + Copy(Head, 1, 12) +
        ' à tarefa concluída?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        Head := '';
    end;
  end;
  if not FService.ApplyTaskAction(Task.Get('id', ''), 'MNote2', Action, Comment, Head) then
    MessageDlg('Tarefas', FService.LastError, mtWarning, [mbOK], 0)
  else SaveAndRefresh;
end;

function TMNoteTasksPanel.BuildTaskExecutionPrompt(ATask: TJSONObject): string;
var
  Lines: TStringList;
  Agile: TJSONObject;
  FRArray, NFRArray, DBArray, APIArray, FilesArray: TJSONArray;
  I: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Add('=== CONTEXTO DO PROJETO ===');
    Lines.Add('Nome do Projeto: ' + FService.Project.Name);
    if FService.Project.Goal <> '' then
      Lines.Add('Objetivo Geral: ' + FService.Project.Goal);
    if FService.Project.Scope <> '' then
      Lines.Add('Escopo: ' + FService.Project.Scope);
    if FService.Project.Constraints <> '' then
      Lines.Add('Restrições / Não-Fazer: ' + FService.Project.Constraints);
    if FService.Project.ExpectedDeliverables <> '' then
      Lines.Add('Critérios de Sucesso: ' + FService.Project.ExpectedDeliverables);

    Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
    if Agile <> nil then
    begin
      FRArray := SafeGetArray(Agile, 'functional_requirements');
      if (FRArray <> nil) and (FRArray.Count > 0) then
      begin
        Lines.Add('');
        Lines.Add('=== REQUISITOS FUNCIONAIS ===');
        for I := 0 to FRArray.Count - 1 do
          Lines.Add('- ' + FRArray.Items[I].AsJSON);
      end;

      NFRArray := SafeGetArray(Agile, 'non_functional_requirements');
      if (NFRArray <> nil) and (NFRArray.Count > 0) then
      begin
        Lines.Add('');
        Lines.Add('=== REQUISITOS NÃO FUNCIONAIS ===');
        for I := 0 to NFRArray.Count - 1 do
          Lines.Add('- ' + NFRArray.Items[I].AsJSON);
      end;

      DBArray := SafeGetArray(Agile, 'database_connections');
      if (DBArray <> nil) and (DBArray.Count > 0) then
      begin
        Lines.Add('');
        Lines.Add('=== BANCOS DE DADOS E CONEXÕES ===');
        for I := 0 to DBArray.Count - 1 do
          Lines.Add('- ' + DBArray.Items[I].AsJSON);
      end;

      APIArray := SafeGetArray(Agile, 'external_apis');
      if (APIArray <> nil) and (APIArray.Count > 0) then
      begin
        Lines.Add('');
        Lines.Add('=== WEB APIS E ACESSOS EXTERNOS ===');
        for I := 0 to APIArray.Count - 1 do
          Lines.Add('- ' + APIArray.Items[I].AsJSON);
      end;
    end;

    Lines.Add('');
    Lines.Add('=== TAREFA ESPECÍFICA A IMPLEMENTAR ===');
    Lines.Add('ID: ' + ATask.Get('id', ''));
    Lines.Add('WBS: ' + ATask.Get('wbs', ''));
    Lines.Add('Título: ' + ATask.Get('title', ''));
    Lines.Add('Tipo: ' + ATask.Get('kind', 'code'));
    Lines.Add('Prioridade: ' + ATask.Get('priority', 'medium'));
    if ATask.Get('description', '') <> '' then
      Lines.Add('Descrição: ' + ATask.Get('description', ''));
    if ATask.Get('long_description', '') <> '' then
      Lines.Add('Especificação Arquitetural: ' + ATask.Get('long_description', ''));
    if ATask.Get('acceptance_criteria', '') <> '' then
      Lines.Add('Critérios de Aceite: ' + ATask.Get('acceptance_criteria', ''));

    FilesArray := SafeGetArray(ATask, 'files_affected');
    if (FilesArray <> nil) and (FilesArray.Count > 0) then
      Lines.Add('Arquivos Afetados: ' + FilesArray.AsJSON);

    Lines.Add('');
    Lines.Add('=== INSTRUÇÕES PARA A IA ===');
    Lines.Add('Implemente o código completo para atender esta tarefa.');
    Lines.Add('Gere código de produção, limpo, seguro e alinhado aos padrões do projeto.');
    Lines.Add('Indique claramente onde o código deve ser inserido ou salvo.');

    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TMNoteTasksPanel.ExecuteTaskAIClick(Sender: TObject);
var
  Task: TJSONObject;
  Prompt: string;
begin
  Task := SelectedTask;
  if Task = nil then
  begin
    MessageDlg('Tarefas', 'Selecione uma tarefa para implementar com IA.', mtInformation, [mbOK], 0);
    Exit;
  end;

  Prompt := BuildTaskExecutionPrompt(Task);
  if Assigned(FOnExecuteTaskAI) then
    FOnExecuteTaskAI(Self, Task.Get('id', ''), Prompt);
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
      if SameText(FList.Items[I].SubItems[0], Value) then
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
    Dialog.Caption := IfThen(ARevision, 'Revisar plano proposto pela IA', 'Revisar plano proposto pela IA');
    Dialog.Position := poScreenCenter;
    Dialog.Width := 820; Dialog.Height := 580;
    Info := TLabel.Create(Dialog); Info.Parent := Dialog; Info.SetBounds(12, 10, 780, 20);
    Info.Caption := 'Marque as tarefas que serão persistidas. Nada é salvo antes desta confirmação.';
    Checklist := TCheckListBox.Create(Dialog); Checklist.Parent := Dialog; Checklist.SetBounds(12, 34, 350, 475);
    Tasks := SafeGetArray(Plan, 'tasks');
    if Tasks <> nil then
      for I := 0 to Tasks.Count - 1 do
      begin
        Checklist.Items.Add(Tasks.Objects[I].Strings['id'] + ' — ' + Tasks.Objects[I].Strings['title']);
        Checklist.Checked[I] := True;
      end;
    Preview := TMemo.Create(Dialog); Preview.Parent := Dialog; Preview.SetBounds(370, 34, 425, 475);
    Preview.ReadOnly := True; Preview.ScrollBars := ssAutoBoth;
    Preview.Lines.Text := Plan.FormatJSON;

    OkButton := TButton.Create(Dialog); OkButton.Parent := Dialog; OkButton.Caption := 'Confirmar e salvar';
    OkButton.ModalResult := mrOk; OkButton.SetBounds(630, 518, 110, 28);
    CancelButton := TButton.Create(Dialog); CancelButton.Parent := Dialog; CancelButton.Caption := 'Cancelar';
    CancelButton.ModalResult := mrCancel; CancelButton.SetBounds(744, 518, 70, 28);

    if Dialog.ShowModal <> mrOk then
    begin AError := 'Plano cancelado pelo usuário; nenhuma tarefa foi alterada.'; Exit; end;

    SelectedIDs.CaseSensitive := False;
    for I := 0 to Checklist.Count - 1 do
      if Checklist.Checked[I] then SelectedIDs.Add(Tasks.Objects[I].Strings['id']);
    RevisionTitle := IfThen(ARevision, 'Revisão de plano por IA', 'Plano inicial por IA');
    if not TMNoteAIPlanContract.ApplyPlan(FService.Project, Plan, SelectedIDs, AInput, RevisionTitle, AError) then Exit;
    if not FService.Save then
    begin AError := FService.LastError; Exit; end;
    Refresh;
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
    MessageDlg('Tarefas', 'Contrato salvo em ' + FileName + ' e copiado para a área de transferência.', mtInformation, [mbOK], 0);
  end
  else MessageDlg('Tarefas', FService.LastError, mtWarning, [mbOK], 0);
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
    if not Exporter.ExportDocument('Plano e tarefas do projeto', Content, Dialog.FileName, DocumentFormat) then
      MessageDlg('Relatório', Exporter.LastError, mtError, [mbOK], 0)
    else
      MessageDlg('Relatório', 'Documento criado em:' + LineEnding + Dialog.FileName, mtInformation, [mbOK], 0);
  finally
    Exporter.Free;
    Dialog.Free;
  end;
end;

procedure TMNoteTasksPanel.SaveObjectivesClick(Sender: TObject);
var
  ProjObj: TJSONObject;
begin
  FService.Project.Name := Trim(FedProjectName.Text);
  FService.Project.Goal := FmeProjectGoal.Text;
  FService.Project.Scope := FmeProjectScope.Text;
  FService.Project.Constraints := FmeProjectConstraints.Text;
  FService.Project.ExpectedDeliverables := FmeProjectDeliverables.Text;

  ProjObj := EnsureObject(FService.Project.ProjectData, 'project');
  if ProjObj <> nil then
  begin
    if ProjObj.IndexOfName('author') >= 0 then ProjObj.Strings['author'] := Trim(FedProjectAuthor.Text)
    else ProjObj.Add('author', Trim(FedProjectAuthor.Text));

    if ProjObj.IndexOfName('revision') >= 0 then ProjObj.Strings['revision'] := Trim(FedProjectVersion.Text)
    else ProjObj.Add('revision', Trim(FedProjectVersion.Text));
  end;

  SaveAndRefresh;
  MessageDlg('Objetivos', 'Objetivos e escopo salvos no projeto com sucesso.', mtInformation, [mbOK], 0);
end;

procedure TMNoteTasksPanel.SuggestObjectivesAIClick(Sender: TObject);
var
  Prompt: string;
begin
  Prompt := 'Analise e aprimore os objetivos, escopo e critérios de sucesso para o seguinte projeto:' + LineEnding +
    'Nome: ' + FedProjectName.Text + LineEnding +
    'Objetivo Atual: ' + FmeProjectGoal.Text + LineEnding +
    'Escopo: ' + FmeProjectScope.Text;
  if Assigned(FOnOrchestratorAction) then
    FOnOrchestratorAction(Self, 'suggest_objectives', Prompt);
end;

procedure TMNoteTasksPanel.AddRFClick(Sender: TObject);
var
  Agile: TJSONObject;
  FRArray: TJSONArray;
  RFObj: TJSONObject;
  TitleStr, DescStr: string;
  NewID: string;
begin
  TitleStr := '';
  if not InputQuery('Novo Requisito Funcional', 'Título do Requisito (ex: Autenticação de Usuários):', TitleStr) then Exit;
  DescStr := '';
  if not InputQuery('Novo Requisito Funcional', 'Descrição detalhada:', DescStr) then Exit;

  Agile := EnsureObject(FService.Project.ProjectData, 'agile_documents');
  FRArray := EnsureArray(Agile, 'functional_requirements');

  NewID := 'RF' + Format('%.3d', [FRArray.Count + 1]);
  RFObj := TJSONObject.Create([
    'id', NewID,
    'title', TitleStr,
    'description', DescStr,
    'priority', 'high',
    'status', 'approved'
  ]);
  FRArray.Add(RFObj);
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.EditRFClick(Sender: TObject);
var
  Agile: TJSONObject;
  FRArray: TJSONArray;
  Idx: Integer;
  RFObj: TJSONObject;
  TitleStr, DescStr: string;
begin
  if (FlvFunctional.Selected = nil) then Exit;
  Idx := FlvFunctional.Selected.Index;
  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  FRArray := SafeGetArray(Agile, 'functional_requirements');
  if (FRArray = nil) or (Idx >= FRArray.Count) then Exit;

  RFObj := FRArray.Objects[Idx];
  TitleStr := RFObj.Get('title', '');
  if not InputQuery('Editar Requisito Funcional', 'Título:', TitleStr) then Exit;
  DescStr := RFObj.Get('description', '');
  if not InputQuery('Editar Requisito Funcional', 'Descrição:', DescStr) then Exit;

  RFObj.Strings['title'] := TitleStr;
  RFObj.Strings['description'] := DescStr;
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.DeleteRFClick(Sender: TObject);
var
  Agile: TJSONObject;
  FRArray: TJSONArray;
  Idx: Integer;
begin
  if (FlvFunctional.Selected = nil) then Exit;
  Idx := FlvFunctional.Selected.Index;
  if MessageDlg('Requisitos', 'Deseja excluir este Requisito Funcional?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  FRArray := SafeGetArray(Agile, 'functional_requirements');
  if (FRArray = nil) or (Idx >= FRArray.Count) then Exit;

  FRArray.Delete(Idx);
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.AddRNFClick(Sender: TObject);
var
  Agile: TJSONObject;
  NFRArray: TJSONArray;
  Obj: TJSONObject;
  CatStr, DescStr: string;
  NewID: string;
begin
  CatStr := 'performance';
  if not InputQuery('Novo Requisito Não-Funcional', 'Categoria (performance, seguranca, arquitetura, stack):', CatStr) then Exit;
  DescStr := '';
  if not InputQuery('Novo Requisito Não-Funcional', 'Descrição detalhada do RNF:', DescStr) then Exit;

  Agile := EnsureObject(FService.Project.ProjectData, 'agile_documents');
  NFRArray := EnsureArray(Agile, 'non_functional_requirements');

  NewID := 'RNF' + Format('%.3d', [NFRArray.Count + 1]);
  Obj := TJSONObject.Create([
    'id', NewID,
    'category', CatStr,
    'description', DescStr,
    'priority', 'high'
  ]);
  NFRArray.Add(Obj);
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.EditRNFClick(Sender: TObject);
var
  Agile: TJSONObject;
  NFRArray: TJSONArray;
  Idx: Integer;
  Obj: TJSONObject;
  CatStr, DescStr: string;
begin
  if (FlvNonFunctional.Selected = nil) then Exit;
  Idx := FlvNonFunctional.Selected.Index;
  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  NFRArray := SafeGetArray(Agile, 'non_functional_requirements');
  if (NFRArray = nil) or (Idx >= NFRArray.Count) then Exit;

  Obj := NFRArray.Objects[Idx];
  CatStr := Obj.Get('category', '');
  if not InputQuery('Editar RNF', 'Categoria:', CatStr) then Exit;
  DescStr := Obj.Get('description', '');
  if not InputQuery('Editar RNF', 'Descrição:', DescStr) then Exit;

  Obj.Strings['category'] := CatStr;
  Obj.Strings['description'] := DescStr;
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.DeleteRNFClick(Sender: TObject);
var
  Agile: TJSONObject;
  NFRArray: TJSONArray;
  Idx: Integer;
begin
  if (FlvNonFunctional.Selected = nil) then Exit;
  Idx := FlvNonFunctional.Selected.Index;
  if MessageDlg('Requisitos', 'Deseja excluir este Requisito Não-Funcional?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  NFRArray := SafeGetArray(Agile, 'non_functional_requirements');
  if (NFRArray = nil) or (Idx >= NFRArray.Count) then Exit;

  NFRArray.Delete(Idx);
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.SaveRequirementsClick(Sender: TObject);
begin
  SaveAndRefresh;
  MessageDlg('Requisitos', 'Requisitos salvos no projeto com sucesso.', mtInformation, [mbOK], 0);
end;

procedure TMNoteTasksPanel.SuggestRequirementsAIClick(Sender: TObject);
var
  Prompt: string;
begin
  Prompt := 'A partir do objetivo e escopo do projeto ' + FService.Project.Name + ':' + LineEnding +
    'Objetivo: ' + FService.Project.Goal + LineEnding +
    'Escopo: ' + FService.Project.Scope + LineEnding +
    'Sugira uma lista completa de Requisitos Funcionais (RF) e Não-Funcionais (RNF) para o sistema.';
  if Assigned(FOnOrchestratorAction) then
    FOnOrchestratorAction(Self, 'suggest_requirements', Prompt);
end;

procedure TMNoteTasksPanel.DBTypeChange(Sender: TObject);
begin
  if FcbDBType.ItemIndex = 2 then // SQLite
  begin
    FedDBHost.Enabled := False;
    FedDBPort.Enabled := False;
    FedDBSchema.Enabled := False;
    FedDBUser.Enabled := False;
    FedDBPassword.Enabled := False;
  end
  else
  begin
    FedDBHost.Enabled := True;
    FedDBPort.Enabled := True;
    FedDBSchema.Enabled := True;
    FedDBUser.Enabled := True;
    FedDBPassword.Enabled := True;
  end;
end;

procedure TMNoteTasksPanel.TestDBConnectionClick(Sender: TObject);
var
  DBType: Integer;
  Success: Boolean;
begin
  DBType := FcbDBType.ItemIndex;
  if DBType < 0 then DBType := 0;

  case DBType of
    0:
    begin
      FSetMain.HostnameMy := Trim(FedDBHost.Text);
      FSetMain.BancoMy := Trim(FedDBName.Text);
      FSetMain.UsernameMy := Trim(FedDBUser.Text);
      if FedDBPassword.Text <> '' then FSetMain.PasswordMy := FedDBPassword.Text;
    end;
    1:
    begin
      FSetMain.HostnamePost := Trim(FedDBHost.Text);
      FSetMain.BancoPOST := Trim(FedDBName.Text);
      FSetMain.SchemaPost := Trim(FedDBSchema.Text);
      FSetMain.UsernamePost := Trim(FedDBUser.Text);
      if FedDBPassword.Text <> '' then FSetMain.PasswordPost := FedDBPassword.Text;
    end;
    2:
      FSetMain.BancoSQLite := Trim(FedDBName.Text);
    3:
    begin
      FSetMain.HostnameMSSQL := Trim(FedDBHost.Text);
      FSetMain.BancoMSSQL := Trim(FedDBName.Text);
      FSetMain.SchemaMSSQL := Trim(FedDBSchema.Text);
      FSetMain.UsernameMSSQL := Trim(FedDBUser.Text);
      if FedDBPassword.Text <> '' then FSetMain.PasswordMSSQL := FedDBPassword.Text;
    end;
    4:
    begin
      FSetMain.HostnameOracle := Trim(FedDBHost.Text);
      FSetMain.BancoOracle := Trim(FedDBName.Text);
      FSetMain.SchemaOracle := Trim(FedDBSchema.Text);
      FSetMain.UsernameOracle := Trim(FedDBUser.Text);
      if FedDBPassword.Text <> '' then FSetMain.PasswordOracle := FedDBPassword.Text;
    end;
  end;

  if frmmquery2 = nil then
    frmmquery2 := Tfrmmquery2.Create(Application);

  Success := frmmquery2.ValidaConexao(DBType);
  if Success then
  begin
    FlblDBStatus.Caption := 'Status: Conexão estabelecida com sucesso!';
    FlblDBStatus.Font.Color := clGreen;
    MessageDlg('Banco de Dados', 'Conexão com o banco de dados validada com sucesso!', mtInformation, [mbOK], 0);
  end
  else
  begin
    FlblDBStatus.Caption := 'Status: Falha ao conectar.';
    FlblDBStatus.Font.Color := clRed;
    MessageDlg('Banco de Dados', 'Falha ao conectar com o banco de dados.' + LineEnding +
      'Verifique se o serviço do banco está ativo, as credenciais estão corretas e as bibliotecas clientes 32-bit estão instaladas em libs\.', mtWarning, [mbOK], 0);
  end;
end;

procedure TMNoteTasksPanel.SaveDBConnectionClick(Sender: TObject);
var
  Agile: TJSONObject;
  DBArray: TJSONArray;
  DBObj: TJSONObject;
begin
  Agile := EnsureObject(FService.Project.ProjectData, 'agile_documents');
  DBArray := EnsureArray(Agile, 'database_connections');
  DBArray.Clear;
  DBObj := TJSONObject.Create([
    'db_type', FcbDBType.ItemIndex,
    'db_name', FcbDBType.Text,
    'host', Trim(FedDBHost.Text),
    'port', Trim(FedDBPort.Text),
    'schema', Trim(FedDBSchema.Text),
    'database', Trim(FedDBName.Text),
    'user', Trim(FedDBUser.Text)
  ]);
  DBArray.Add(DBObj);
  SaveAndRefresh;
  MessageDlg('Banco de Dados', 'Configuração de conexão salva no projeto com sucesso.', mtInformation, [mbOK], 0);
end;

procedure TMNoteTasksPanel.AddAPIClick(Sender: TObject);
var
  Agile: TJSONObject;
  APIArray: TJSONArray;
  Obj: TJSONObject;
  NameStr, UrlStr, MethodStr, AuthStr, NewID: string;
begin
  NameStr := '';
  if not InputQuery('Nova Web API', 'Nome do Serviço / API:', NameStr) then Exit;
  UrlStr := 'https://api.exemplo.com/v1';
  if not InputQuery('Nova Web API', 'URL Base / Endpoint:', UrlStr) then Exit;
  MethodStr := 'GET';
  if not InputQuery('Nova Web API', 'Método HTTP (GET/POST/PUT/DELETE):', MethodStr) then Exit;
  AuthStr := 'Bearer';
  if not InputQuery('Nova Web API', 'Tipo de Autenticação (Bearer / ApiKey / Basic / None):', AuthStr) then Exit;

  Agile := EnsureObject(FService.Project.ProjectData, 'agile_documents');
  APIArray := EnsureArray(Agile, 'external_apis');

  NewID := 'API' + Format('%.3d', [APIArray.Count + 1]);
  Obj := TJSONObject.Create([
    'id', NewID,
    'name', NameStr,
    'base_url', UrlStr,
    'method', MethodStr,
    'auth_type', AuthStr,
    'description', '',
    'payload_spec', ''
  ]);
  APIArray.Add(Obj);
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.EditAPIClick(Sender: TObject);
var
  Agile: TJSONObject;
  APIArray: TJSONArray;
  Idx: Integer;
  Obj: TJSONObject;
  NameStr, UrlStr: string;
begin
  if FlvAPIs.Selected = nil then Exit;
  Idx := FlvAPIs.Selected.Index;
  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  APIArray := SafeGetArray(Agile, 'external_apis');
  if (APIArray = nil) or (Idx >= APIArray.Count) then Exit;

  Obj := APIArray.Objects[Idx];
  NameStr := Obj.Get('name', '');
  if not InputQuery('Editar API', 'Nome:', NameStr) then Exit;
  UrlStr := Obj.Get('base_url', '');
  if not InputQuery('Editar API', 'URL Base:', UrlStr) then Exit;

  Obj.Strings['name'] := NameStr;
  Obj.Strings['base_url'] := UrlStr;
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.DeleteAPIClick(Sender: TObject);
var
  Agile: TJSONObject;
  APIArray: TJSONArray;
  Idx: Integer;
begin
  if FlvAPIs.Selected = nil then Exit;
  Idx := FlvAPIs.Selected.Index;
  if MessageDlg('Web APIs', 'Deseja excluir esta especificação de API?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  APIArray := SafeGetArray(Agile, 'external_apis');
  if (APIArray = nil) or (Idx >= APIArray.Count) then Exit;

  APIArray.Delete(Idx);
  SaveAndRefresh;
end;

procedure TMNoteTasksPanel.SaveAPIsClick(Sender: TObject);
var
  Agile: TJSONObject;
  APIArray: TJSONArray;
  Idx: Integer;
  Obj: TJSONObject;
begin
  if FlvAPIs.Selected <> nil then
  begin
    Idx := FlvAPIs.Selected.Index;
    Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
    if Agile <> nil then
    begin
      APIArray := SafeGetArray(Agile, 'external_apis');
      if (APIArray <> nil) and (Idx < APIArray.Count) then
      begin
        Obj := APIArray.Objects[Idx];
        if Obj.IndexOfName('payload_spec') >= 0 then Obj.Strings['payload_spec'] := FmeAPISpec.Text
        else Obj.Add('payload_spec', FmeAPISpec.Text);
      end;
    end;
  end;
  SaveAndRefresh;
  MessageDlg('Web APIs', 'Especificações de APIs salvas com sucesso.', mtInformation, [mbOK], 0);
end;

procedure TMNoteTasksPanel.APISelectionChanged(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  Agile: TJSONObject;
  APIArray: TJSONArray;
  Idx: Integer;
begin
  if not Selected then Exit;
  Idx := Item.Index;
  Agile := SafeGetObject(FService.Project.ProjectData, 'agile_documents');
  if Agile = nil then Exit;
  APIArray := SafeGetArray(Agile, 'external_apis');
  if (APIArray = nil) or (Idx >= APIArray.Count) then Exit;

  FmeAPISpec.Text := APIArray.Objects[Idx].Get('payload_spec', '');
end;

procedure TMNoteTasksPanel.OrchestratorStep1Click(Sender: TObject);
begin
  SuggestRequirementsAIClick(Sender);
end;

procedure TMNoteTasksPanel.OrchestratorStep2Click(Sender: TObject);
begin
  GeneratePlan(Sender);
end;

procedure TMNoteTasksPanel.OrchestratorStep3Click(Sender: TObject);
var
  TasksArray: TJSONArray;
  I: Integer;
  Task: TJSONObject;
  Status: string;
begin
  TasksArray := FService.Tasks.Tasks;
  if (TasksArray = nil) or (TasksArray.Count = 0) then
  begin
    MessageDlg('Orquestrador', 'Nenhuma tarefa cadastrada. Execute o Passo 2 para gerar o plano EAP.', mtInformation, [mbOK], 0);
    Exit;
  end;

  for I := 0 to TasksArray.Count - 1 do
    if TasksArray.Items[I] is TJSONObject then
    begin
      Task := TasksArray.Objects[I];
      Status := LowerCase(Task.Get('status', ''));
      if (Status = 'planned') or (Status = 'suggested') or (Status = 'in_progress') then
      begin
        if (FList <> nil) and (I < FList.Items.Count) then
          FList.Items[I].Selected := True;
        ExecuteTaskAIClick(Sender);
        Exit;
      end;
    end;

  MessageDlg('Orquestrador', 'Todas as tarefas do projeto já foram concluídas ou revisadas!', mtInformation, [mbOK], 0);
end;

end.