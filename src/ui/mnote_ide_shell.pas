unit mnote_ide_shell;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, ComCtrls, StdCtrls, Menus, SynEdit,
  SynEditTypes, mnote_tool_windows, mnote_language_registry,
  mnote_language_profile;

type
  { TMNoteIDEShell }

  TMNoteIDEShell = class(TComponent)
  private
    FWindowManager: TMNoteToolWindowManager;
    FHost: TWinControl;
    FCenterPanel: TPanel;
    FLeftPanel: TPanel;
    FLeftSplitter: TSplitter;
    FLeftPages: TPageControl;
    FSolutionPage: TTabSheet;
    FFilesPage: TTabSheet;
    FDatabasePage: TTabSheet;
    FRightPanel: TPanel;
    FRightSplitter: TSplitter;
    FRightPages: TPageControl;
    FAIPage: TTabSheet;
    FTasksPage: TTabSheet;
    FPropertiesPage: TTabSheet;
    FChangesPage: TTabSheet;
    FMonitorPage: TTabSheet;
    FComponentsLabPage: TTabSheet;
    FBottomPanel: TPanel;
    FBottomSplitter: TSplitter;
    FBottomPages: TPageControl;
    FSearchPage: TTabSheet;
    FSearchResultsList: TListView;
    FProblemsPage: TTabSheet;
    FOutputPage: TTabSheet;
    FTerminalPage: TTabSheet;
    FTaskListPage: TTabSheet;
    FProblemsList: TListView;
    FTaskList: TListView;
    FViewMenu: TMenuItem;
    FResetLayoutItem: TMenuItem;
    FViewItems: array[TMNoteToolWindowKind] of TMenuItem;
    FStatusBar: TStatusBar;
    FActiveEditor: TSynEdit;
    FActiveFile: string;
    FActiveLanguage: string;
    FActiveEncoding: string;
    FActiveProject: string;
    FAIState: string;
    function AddInfoPage(APages: TPageControl; const ACaption,
      AMessage: string): TTabSheet;
    procedure AddViewItem(AKind: TMNoteToolWindowKind; const ACaption: string);
    procedure CreateViewMenu(AMainMenu: TMainMenu);
    procedure ViewMenuClick(Sender: TObject);
    procedure ResetLayoutClick(Sender: TObject);
    procedure ToolVisibilityChanged(Sender: TObject;
      AKind: TMNoteToolWindowKind; AVisible: Boolean);
    procedure ActivateToolWindow(AKind: TMNoteToolWindowKind);
    procedure UpdatePanelVisibility;
    procedure CreateStatusBar;
    procedure EditorStatusChanged(Sender: TObject; Changes: TSynStatusChanges);
    procedure RefreshStatus;
    function LanguageFromFile(const AFileName: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AHost: TWinControl; ACenterPanel: TPanel;
      AEditorPages: TPageControl; AAIContent, APropertiesContent: TPanel;
      ASearchResults: TListBox; AOutput: TMemo; AMainMenu: TMainMenu);
    procedure ApplyLayout(ALeftWidth, ARightWidth, ABottomHeight: Integer;
      ALeftVisible, ARightVisible, ABottomVisible: Boolean;
      ALeftTab, ARightTab, ABottomTab: Integer);
    procedure CaptureLayout(out ALeftWidth, ARightWidth,
      ABottomHeight: Integer; out ALeftVisible, ARightVisible,
      ABottomVisible: Boolean; out ALeftTab, ARightTab, ABottomTab: Integer);
    procedure ResetLayout;
    procedure SetActiveEditor(AEditor: TSynEdit; const AFileName,
      AProject: string);
    procedure SetAIState(const AState: string);
    procedure ShowToolWindow(AKind: TMNoteToolWindowKind);
    property WindowManager: TMNoteToolWindowManager read FWindowManager;
    property LeftPanel: TPanel read FLeftPanel;
    property LeftPages: TPageControl read FLeftPages;
    property SolutionPage: TTabSheet read FSolutionPage;
    property FilesPage: TTabSheet read FFilesPage;
    property DatabasePage: TTabSheet read FDatabasePage;
    property RightPanel: TPanel read FRightPanel;
    property RightPages: TPageControl read FRightPages;
    property BottomPanel: TPanel read FBottomPanel;
    property BottomPages: TPageControl read FBottomPages;
    property SearchResultsList: TListView read FSearchResultsList;
    property TasksPage: TTabSheet read FTasksPage;
    property ChangesPage: TTabSheet read FChangesPage;
    property MonitorPage: TTabSheet read FMonitorPage;
    property ComponentsLabPage: TTabSheet read FComponentsLabPage;
    property ProblemsPage: TTabSheet read FProblemsPage;
    property OutputPage: TTabSheet read FOutputPage;
    property TerminalPage: TTabSheet read FTerminalPage;
    property ProblemsList: TListView read FProblemsList;
    property TaskList: TListView read FTaskList;
    property StatusBar: TStatusBar read FStatusBar;
  end;

implementation

constructor TMNoteIDEShell.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWindowManager := TMNoteToolWindowManager.Create;
end;

destructor TMNoteIDEShell.Destroy;
begin
  if FActiveEditor <> nil then
    FActiveEditor.UnRegisterStatusChangedHandler(@EditorStatusChanged);
  FWindowManager.Free;
  inherited Destroy;
end;

function TMNoteIDEShell.AddInfoPage(APages: TPageControl; const ACaption,
  AMessage: string): TTabSheet;
var
  Info: TLabel;
begin
  Result := TTabSheet.Create(Self);
  Result.PageControl := APages;
  Result.Caption := ACaption;

  Info := TLabel.Create(Self);
  Info.Parent := Result;
  Info.Align := alTop;
  Info.BorderSpacing.Around := 10;
  Info.Caption := AMessage;
end;

procedure TMNoteIDEShell.AddViewItem(AKind: TMNoteToolWindowKind;
  const ACaption: string);
begin
  FViewItems[AKind] := TMenuItem.Create(Self);
  FViewItems[AKind].Caption := ACaption;
  FViewItems[AKind].Tag := Ord(AKind);
  FViewItems[AKind].OnClick := @ViewMenuClick;
  FViewMenu.Add(FViewItems[AKind]);
end;

procedure TMNoteIDEShell.CreateViewMenu(AMainMenu: TMainMenu);
begin
  FViewMenu := TMenuItem.Create(Self);
  FViewMenu.Caption := 'View';
  AMainMenu.Items.Add(FViewMenu);

  AddViewItem(twkSolution, 'Solution');
  AddViewItem(twkFiles, 'Files');
  AddViewItem(twkDatabase, 'Database');
  AddViewItem(twkAI, 'AI');
  AddViewItem(twkTasks, 'Tasks');
  AddViewItem(twkProperties, 'Properties');
  AddViewItem(twkChanges, 'Changes');
  AddViewItem(twkAIMonitor, 'AI Monitor');
  AddViewItem(twkComponentsLab, 'AI Components Lab');
  AddViewItem(twkSearch, 'Search Results');
  AddViewItem(twkProblems, 'Problems');
  AddViewItem(twkOutput, 'Output');
  AddViewItem(twkTerminal, 'Terminal');
  AddViewItem(twkTaskList, 'Task List');

  FViewMenu.AddSeparator;
  FResetLayoutItem := TMenuItem.Create(Self);
  FResetLayoutItem.Caption := 'Reset Layout';
  FResetLayoutItem.OnClick := @ResetLayoutClick;
  FViewMenu.Add(FResetLayoutItem);
end;

procedure TMNoteIDEShell.ViewMenuClick(Sender: TObject);
var
  Kind: TMNoteToolWindowKind;
begin
  Kind := TMNoteToolWindowKind(TMenuItem(Sender).Tag);
  if FWindowManager.IsVisible(Kind) then
    FWindowManager.Hide(Kind)
  else
  begin
    FWindowManager.Show(Kind);
    ActivateToolWindow(Kind);
  end;
end;

procedure TMNoteIDEShell.ResetLayoutClick(Sender: TObject);
begin
  ResetLayout;
end;

procedure TMNoteIDEShell.ToolVisibilityChanged(Sender: TObject;
  AKind: TMNoteToolWindowKind; AVisible: Boolean);
begin
  if FViewItems[AKind] <> nil then
    FViewItems[AKind].Checked := AVisible;
  UpdatePanelVisibility;
end;

procedure TMNoteIDEShell.ActivateToolWindow(AKind: TMNoteToolWindowKind);
begin
  case AKind of
    twkSolution: FLeftPages.ActivePage := FSolutionPage;
    twkFiles: FLeftPages.ActivePage := FFilesPage;
    twkDatabase: FLeftPages.ActivePage := FDatabasePage;
    twkAI: FRightPages.ActivePage := FAIPage;
    twkTasks: FRightPages.ActivePage := FTasksPage;
    twkProperties: FRightPages.ActivePage := FPropertiesPage;
    twkChanges: FRightPages.ActivePage := FChangesPage;
    twkAIMonitor: FRightPages.ActivePage := FMonitorPage;
    twkComponentsLab: FRightPages.ActivePage := FComponentsLabPage;
    twkSearch: FBottomPages.ActivePage := FSearchPage;
    twkProblems: FBottomPages.ActivePage := FProblemsPage;
    twkOutput: FBottomPages.ActivePage := FOutputPage;
    twkTerminal: FBottomPages.ActivePage := FTerminalPage;
    twkTaskList: FBottomPages.ActivePage := FTaskListPage;
  end;
end;

procedure TMNoteIDEShell.UpdatePanelVisibility;
begin
  FLeftPanel.Visible :=
    FWindowManager.IsVisible(twkSolution) or
    FWindowManager.IsVisible(twkFiles) or
    FWindowManager.IsVisible(twkDatabase);
  FLeftSplitter.Visible := FLeftPanel.Visible;

  FRightPanel.Visible :=
    FWindowManager.IsVisible(twkAI) or
    FWindowManager.IsVisible(twkTasks) or
    FWindowManager.IsVisible(twkProperties) or
    FWindowManager.IsVisible(twkChanges) or
    FWindowManager.IsVisible(twkAIMonitor) or
    FWindowManager.IsVisible(twkComponentsLab);
  FRightSplitter.Visible := FRightPanel.Visible;

  FBottomPanel.Visible :=
    FWindowManager.IsVisible(twkSearch) or
    FWindowManager.IsVisible(twkProblems) or
    FWindowManager.IsVisible(twkOutput) or
    FWindowManager.IsVisible(twkTerminal) or
    FWindowManager.IsVisible(twkTaskList);
  FBottomSplitter.Visible := FBottomPanel.Visible;
end;

procedure TMNoteIDEShell.CreateStatusBar;
const
  Widths: array[0..6] of Integer = (250, 100, 110, 90, 90, 180, 100);
var
  Panel: TStatusPanel;
  I: Integer;
begin
  if not (Owner is TWinControl) then
    Exit;
  FStatusBar := TStatusBar.Create(Self);
  FStatusBar.Name := 'sbIDEStatus';
  FStatusBar.Parent := TWinControl(Owner);
  FStatusBar.Align := alBottom;
  FStatusBar.SimplePanel := False;
  for I := Low(Widths) to High(Widths) do
  begin
    Panel := FStatusBar.Panels.Add;
    Panel.Width := Widths[I];
  end;
  FAIState := 'Idle';
  RefreshStatus;
end;

function TMNoteIDEShell.LanguageFromFile(const AFileName: string): string;
var
  Profile: TMNoteLanguageProfile;
begin
  Profile := MNoteLanguages.FindByExtension(ExtractFileExt(AFileName));
  if Profile <> nil then
    Result := Profile.Name
  else
    Result := 'Text';
end;

procedure TMNoteIDEShell.EditorStatusChanged(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if Sender = FActiveEditor then
    RefreshStatus;
end;

procedure TMNoteIDEShell.RefreshStatus;
var
  Line, Column: Integer;
  ModifiedText: string;
begin
  if FStatusBar = nil then
    Exit;
  Line := 0;
  Column := 0;
  ModifiedText := 'Saved';
  if FActiveEditor <> nil then
  begin
    Line := FActiveEditor.CaretY;
    Column := FActiveEditor.CaretX;
    if FActiveEditor.Modified then
      ModifiedText := 'Modified';
  end;
  FStatusBar.Panels[0].Text := 'File: ' + FActiveFile;
  FStatusBar.Panels[1].Text := FActiveLanguage;
  FStatusBar.Panels[2].Text := Format('Ln %d, Col %d', [Line, Column]);
  FStatusBar.Panels[3].Text := FActiveEncoding;
  FStatusBar.Panels[4].Text := ModifiedText;
  FStatusBar.Panels[5].Text := 'Project: ' + FActiveProject;
  FStatusBar.Panels[6].Text := 'AI: ' + FAIState;
end;

procedure TMNoteIDEShell.SetActiveEditor(AEditor: TSynEdit;
  const AFileName, AProject: string);
begin
  if FActiveEditor <> AEditor then
  begin
    if FActiveEditor <> nil then
      FActiveEditor.UnRegisterStatusChangedHandler(@EditorStatusChanged);
    FActiveEditor := AEditor;
    if FActiveEditor <> nil then
      FActiveEditor.RegisterStatusChangedHandler(@EditorStatusChanged,
        [scCaretX, scCaretY, scModified]);
  end;
  FActiveFile := AFileName;
  FActiveLanguage := LanguageFromFile(AFileName);
  FActiveEncoding := 'UTF-8';
  FActiveProject := AProject;
  RefreshStatus;
end;

procedure TMNoteIDEShell.SetAIState(const AState: string);
begin
  FAIState := AState;
  RefreshStatus;
end;

procedure TMNoteIDEShell.ShowToolWindow(AKind: TMNoteToolWindowKind);
begin
  FWindowManager.Show(AKind);
  ActivateToolWindow(AKind);
end;

procedure TMNoteIDEShell.ApplyLayout(ALeftWidth, ARightWidth,
  ABottomHeight: Integer; ALeftVisible, ARightVisible,
  ABottomVisible: Boolean; ALeftTab, ARightTab, ABottomTab: Integer);
var
  Kind: TMNoteToolWindowKind;
begin
  if ALeftWidth < 120 then ALeftWidth := 240;
  if ARightWidth < 160 then ARightWidth := 340;
  if ABottomHeight < 100 then ABottomHeight := 180;
  FLeftPanel.Width := ALeftWidth;
  FRightPanel.Width := ARightWidth;
  FBottomPanel.Height := ABottomHeight;

  if not ALeftVisible then
    for Kind := twkSolution to twkDatabase do
      FWindowManager.Hide(Kind);
  if not ARightVisible then
    for Kind := twkAI to twkComponentsLab do
      FWindowManager.Hide(Kind);
  if not ABottomVisible then
    for Kind := twkSearch to twkTaskList do
      FWindowManager.Hide(Kind);

  if (ALeftTab >= 0) and (ALeftTab < FLeftPages.PageCount) then
    FLeftPages.ActivePageIndex := ALeftTab;
  if (ARightTab >= 0) and (ARightTab < FRightPages.PageCount) then
    FRightPages.ActivePageIndex := ARightTab;
  if (ABottomTab >= 0) and (ABottomTab < FBottomPages.PageCount) then
    FBottomPages.ActivePageIndex := ABottomTab;
  UpdatePanelVisibility;
end;

procedure TMNoteIDEShell.CaptureLayout(out ALeftWidth, ARightWidth,
  ABottomHeight: Integer; out ALeftVisible, ARightVisible,
  ABottomVisible: Boolean; out ALeftTab, ARightTab, ABottomTab: Integer);
begin
  ALeftWidth := FLeftPanel.Width;
  ARightWidth := FRightPanel.Width;
  ABottomHeight := FBottomPanel.Height;
  ALeftVisible := FLeftPanel.Visible;
  ARightVisible := FRightPanel.Visible;
  ABottomVisible := FBottomPanel.Visible;
  ALeftTab := FLeftPages.ActivePageIndex;
  ARightTab := FRightPages.ActivePageIndex;
  ABottomTab := FBottomPages.ActivePageIndex;
end;

procedure TMNoteIDEShell.ResetLayout;
var
  Kind: TMNoteToolWindowKind;
begin
  FLeftPanel.Width := 240;
  FRightPanel.Width := 340;
  FBottomPanel.Height := 180;
  for Kind := Low(TMNoteToolWindowKind) to High(TMNoteToolWindowKind) do
    FWindowManager.Show(Kind);
  FLeftPages.ActivePage := FSolutionPage;
  FRightPages.ActivePage := FAIPage;
  FBottomPages.ActivePage := FSearchPage;

  UpdatePanelVisibility;
end;

procedure TMNoteIDEShell.Initialize(AHost: TWinControl; ACenterPanel: TPanel;
  AEditorPages: TPageControl; AAIContent, APropertiesContent: TPanel;
  ASearchResults: TListBox; AOutput: TMemo; AMainMenu: TMainMenu);
begin
  FHost := AHost;
  FCenterPanel := ACenterPanel;

  FCenterPanel.Parent := FHost;
  FCenterPanel.Align := alClient;
  FCenterPanel.Visible := True;
  AEditorPages.Align := alClient;

  FLeftPanel := TPanel.Create(Self);
  FLeftPanel.Name := 'pnIDELeft';
  FLeftPanel.Parent := FHost;
  FLeftPanel.Align := alLeft;
  FLeftPanel.Width := 240;
  FLeftPanel.BevelOuter := bvNone;

  FLeftSplitter := TSplitter.Create(Self);
  FLeftSplitter.Name := 'spIDELeft';
  FLeftSplitter.Parent := FHost;
  FLeftSplitter.Align := alLeft;
  FLeftSplitter.Width := 5;
  FLeftSplitter.Left := FLeftPanel.Width;

  FLeftPages := TPageControl.Create(Self);
  FLeftPages.Name := 'pcIDELeft';
  FLeftPages.Parent := FLeftPanel;
  FLeftPages.Align := alClient;

  FSolutionPage := AddInfoPage(FLeftPages, 'Solution',
    'Projetos e arquivos da solução');
  FFilesPage := AddInfoPage(FLeftPages, 'Files',
    'Arquivos e pastas do projeto');
  FDatabasePage := AddInfoPage(FLeftPages, 'Database',
    'Conexões e dicionário de dados');
  FLeftPages.ActivePage := FSolutionPage;

  FRightPanel := TPanel.Create(Self);
  FRightPanel.Name := 'pnIDERight';
  FRightPanel.Parent := FHost;
  FRightPanel.Align := alRight;
  FRightPanel.Width := 340;
  FRightPanel.BevelOuter := bvNone;

  FRightSplitter := TSplitter.Create(Self);
  FRightSplitter.Name := 'spIDERight';
  FRightSplitter.Parent := FHost;
  FRightSplitter.Align := alRight;
  FRightSplitter.Width := 5;
  FRightSplitter.Left := FHost.ClientWidth - FRightPanel.Width -
    FRightSplitter.Width;

  FRightPages := TPageControl.Create(Self);
  FRightPages.Name := 'pcIDERight';
  FRightPages.Parent := FRightPanel;
  FRightPages.Align := alClient;

  FAIPage := TTabSheet.Create(Self);
  FAIPage.PageControl := FRightPages;
  FAIPage.Caption := 'AI';
  AAIContent.Parent := FAIPage;
  AAIContent.Align := alClient;
  AAIContent.Visible := True;

  FTasksPage := AddInfoPage(FRightPages, 'Tasks',
    'Tarefas do projeto');

  FPropertiesPage := TTabSheet.Create(Self);
  FPropertiesPage.PageControl := FRightPages;
  FPropertiesPage.Caption := 'Properties';
  APropertiesContent.Parent := FPropertiesPage;
  APropertiesContent.Align := alClient;
  APropertiesContent.Visible := True;

  FChangesPage := AddInfoPage(FRightPages, 'Changes',
    'Mudanças propostas e histórico');
  FMonitorPage := AddInfoPage(FRightPages, 'AI Monitor',
    'Sessão, papéis, chamadas e orçamentos');
  FComponentsLabPage := AddInfoPage(FRightPages, 'Components Lab',
    'Capacidades opcionais e dependências reais');
  FRightPages.ActivePage := FAIPage;

  FBottomPanel := TPanel.Create(Self);
  FBottomPanel.Name := 'pnIDEBottom';
  FBottomPanel.Parent := FHost;
  FBottomPanel.Align := alBottom;
  FBottomPanel.Height := 180;
  FBottomPanel.BevelOuter := bvNone;

  FBottomSplitter := TSplitter.Create(Self);
  FBottomSplitter.Name := 'spIDEBottom';
  FBottomSplitter.Parent := FHost;
  FBottomSplitter.Align := alBottom;
  FBottomSplitter.Height := 5;
  FBottomSplitter.Top := FHost.ClientHeight - FBottomPanel.Height -
    FBottomSplitter.Height;

  FBottomPages := TPageControl.Create(Self);
  FBottomPages.Name := 'pcIDEBottom';
  FBottomPages.Parent := FBottomPanel;
  FBottomPages.Align := alClient;

  FSearchPage := TTabSheet.Create(Self);
  FSearchPage.PageControl := FBottomPages;
  FSearchPage.Caption := 'Search Results';
  ASearchResults.Visible := False;
  FSearchResultsList := TListView.Create(Self);
  FSearchResultsList.Parent := FSearchPage;
  FSearchResultsList.Align := alClient;
  FSearchResultsList.ViewStyle := vsReport;
  FSearchResultsList.ReadOnly := True;
  FSearchResultsList.RowSelect := True;
  with FSearchResultsList.Columns.Add do
  begin
    Caption := 'File';
    Width := 280;
  end;
  with FSearchResultsList.Columns.Add do
  begin
    Caption := 'Line';
    Width := 60;
  end;
  with FSearchResultsList.Columns.Add do
  begin
    Caption := 'Column';
    Width := 70;
  end;
  with FSearchResultsList.Columns.Add do
  begin
    Caption := 'Preview';
    Width := 520;
  end;

  FProblemsPage := TTabSheet.Create(Self);
  FProblemsPage.PageControl := FBottomPages;
  FProblemsPage.Caption := 'Problems';
  FProblemsList := TListView.Create(Self);
  FProblemsList.Parent := FProblemsPage;
  FProblemsList.Align := alClient;
  FProblemsList.ViewStyle := vsReport;
  FProblemsList.ReadOnly := True;
  with FProblemsList.Columns.Add do
  begin
    Caption := 'Severity';
    Width := 80;
  end;
  with FProblemsList.Columns.Add do
  begin
    Caption := 'Message';
    Width := 360;
  end;
  with FProblemsList.Columns.Add do
  begin
    Caption := 'File';
    Width := 240;
  end;
  with FProblemsList.Columns.Add do
  begin
    Caption := 'Line';
    Width := 60;
  end;

  FOutputPage := TTabSheet.Create(Self);
  FOutputPage.PageControl := FBottomPages;
  FOutputPage.Caption := 'Output';
  AOutput.Parent := FOutputPage;
  AOutput.Align := alClient;
  AOutput.Visible := True;

  FTerminalPage := AddInfoPage(FBottomPages, 'Terminal',
    'Terminal do projeto');

  FTaskListPage := TTabSheet.Create(Self);
  FTaskListPage.PageControl := FBottomPages;
  FTaskListPage.Caption := 'Task List';
  FTaskList := TListView.Create(Self);
  FTaskList.Parent := FTaskListPage;
  FTaskList.Align := alClient;
  FTaskList.ViewStyle := vsReport;
  FTaskList.ReadOnly := True;
  with FTaskList.Columns.Add do
  begin
    Caption := 'Token';
    Width := 80;
  end;
  with FTaskList.Columns.Add do
  begin
    Caption := 'Description';
    Width := 420;
  end;
  with FTaskList.Columns.Add do
  begin
    Caption := 'File';
    Width := 260;
  end;
  FBottomPages.ActivePage := FSearchPage;

  CreateViewMenu(AMainMenu);
  FWindowManager.OnVisibilityChanged := @ToolVisibilityChanged;

  FWindowManager.Show(twkSolution);
  FWindowManager.Show(twkFiles);
  FWindowManager.Show(twkDatabase);
  FWindowManager.Show(twkAI);
  FWindowManager.Show(twkTasks);
  FWindowManager.Show(twkProperties);
  FWindowManager.Show(twkChanges);
  FWindowManager.Show(twkAIMonitor);
  FWindowManager.Show(twkComponentsLab);
  FWindowManager.Show(twkSearch);
  FWindowManager.Show(twkProblems);
  FWindowManager.Show(twkOutput);
  FWindowManager.Show(twkTerminal);
  FWindowManager.Show(twkTaskList);
  CreateStatusBar;
  UpdatePanelVisibility;
end;

end.
