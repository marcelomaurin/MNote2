unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, fpjson, SynEdit, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, Grids, PopupNotifier, item, types,
  setmain, TypeDB, folders, funcoes, LCLType, ValEdit, PairSplitter, chgtext,
  hint, registro, splash, setFolders, config, SynEditKeyCmds, PythonEngine,
  rxctrls, LogTreeView, uPoweredby, mquery2, porradawebapi,
  SynEditHighlighter, SynEditTypes, codigo, jsonmain, ToolsFalar, ToolsOuvir,
  newproject, uProjetoDB, IA, uPdfText, uDocText, mnote_python_service,
  mnote_version, mnote_ai_service, mnote_ide_shell, mnote_commands,
  mnote_command_palette, mnote_search_panel, mnote_search_types,
  mnote_editor_theme, mnote_theme_applier, SynGutter, mnote_language_toolbar,
  mnote_language_registry, mnote_language_profile, mnote_editor_options,
  mnote_tool_windows, mnote_project_symbol_index, mnote_token_estimator,
  mnote_tasks_panel, mnote_changes_panel, mnote_ai_change_contract,
  mnote_source_change_types, mnote_db_dictionary_panel, mnote_task_list_panel,
  mnote_output_panel, mnote_output_model, mnote_problems_panel,
  mnote_build_service, mnote_terminal_panel, mnote_ai_types,
  mnote_ai_session, mnote_ai_monitor_panel, ia_config, LCLIntf,
  mnote_ai_actions, mnote_database_completion_provider,
  mnote_sql_validation_service, mnote_ai_plan_contract,
  mnote_git_read_service, mnote_files_panel, mnote_components_lab_panel,
  mnote_project_context, mnote_solution_explorer_panel,
  mnote_neural_api_bootstrap, mnote_memory_map_panel,
  voice_output_config, confpython, mnote_voice_output_service, mnote_visual_identity;

type

  { TfrmMNote }

  TfrmMNote = class(TForm)
    btIA2: TButton;
    edChat: TMemo;
    FindDialog1: TFindDialog;
    FontDialog1: TFontDialog;
    ImageList1: TImageList;
    lstFind: TListBox;
    MainMenu1: TMainMenu;
    meChatHist: TSynEdit;
    meCodes: TSynEdit;
    meDialog: TMemo;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    btIA: TMenuItem;
    mequestion: TMemo;
    miIAThisSource: TMenuItem;
    mnCompile: TMenuItem;
    miToolsFalar: TMenuItem;
    miIMGJSON: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    miporrada: TMenuItem;
    miChatGPT: TMenuItem;
    miTestarPython: TMenuItem;
    miDiagnosticoPython: TMenuItem;
    mniJSONVALID: TMenuItem;
    mnidos2unix: TMenuItem;
    PageControl1: TPageControl;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    pcInspector: TPageControl;
    pgMain: TPageControl;
    pnChatGPT: TPanel;
    pnChatGPT2: TPanel;
    pmchatgpt: TPopupMenu;
    pnclient: TPanel;
    pnInspector: TPanel;
    pnWait: TPanel;
    Separator4: TMenuItem;
    miRedo: TMenuItem;
    miSelectAll: TMenuItem;
    miSelectCmd: TMenuItem;
    miSelectBlock: TMenuItem;
    Separator3: TMenuItem;
    Separator2: TMenuItem;
    miPaste: TMenuItem;
    micopy: TMenuItem;
    mnHideResult: TMenuItem;
    meResult: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    btNovo: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    mnNone: TMenuItem;
    mnJava: TMenuItem;
    mnSQL: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    mnrun: TMenuItem;
    mndebug: TMenuItem;
    mnclean: TMenuItem;
    mninstall: TMenuItem;
    mnPHP: TMenuItem;
    pnResult: TPanel;
    pmResult: TPopupMenu;
    Separator1: TMenuItem;
    miConfig: TMenuItem;
    miIAConfig: TMenuItem;
    miVoiceOutputConfig: TMenuItem;
    miPythonConfig: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem9: TMenuItem;
    miUndo: TMenuItem;
    mnFixW: TMenuItem;
    mnOnTopW: TMenuItem;
    mnDesktopCenterW: TMenuItem;
    mnDesktopCenter: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    mnFixar: TMenuItem;
    mnStay: TMenuItem;
    mnLazarus: TMenuItem;
    mnFechar2: TMenuItem;
    mnPython: TMenuItem;
    mnC: TMenuItem;
    mnAssociar: TMenuItem;
    mnfont: TMenuItem;
    mnSetup: TMenuItem;
    mnScript: TMenuItem;
    mnFechar: TMenuItem;
    mnCarregar: TMenuItem;
    MenuItem3: TMenuItem;
    mnSalvar: TMenuItem;
    mnSalvarComo: TMenuItem;
    MenuItem6: TMenuItem;
    mnPesqItem: TMenuItem;
    mnReplaceItem: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    popFechar: TPopupMenu;
    popFind: TPopupMenu;
    popSysEdit: TPopupMenu;
    PopupMenu1: TPopupMenu;
    ReplaceDialog1: TReplaceDialog;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    tsCode: TTabSheet;
    tsDialog: TTabSheet;
    tsGlobal: TTabSheet;
    tsHistory: TTabSheet;
    TrayIcon1: TTrayIcon;
    tsLocal: TTabSheet;
    tsQuestion: TTabSheet;
    vlGlobal: TValueListEditor;
    vlLocal: TValueListEditor;
    procedure btHideChange(Sender: TObject);
    procedure btIA2Click(Sender: TObject);
    procedure btIAClick(Sender: TObject);
    procedure edChatKeyPress(Sender: TObject; var Key: char);
    procedure FindDialog1Find(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstFindChangeBounds(Sender: TObject);
    procedure lstFindClick(Sender: TObject);
    procedure lstFindContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lstFindDblClick(Sender: TObject);
    procedure lstFindSelectionChange(Sender: TObject; User: boolean);
    procedure meChatHistChange(Sender: TObject);
    procedure meChatHistClick(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure MenuItem23Click(Sender: TObject);
    procedure MenuItem24Click(Sender: TObject);
    procedure MenuItem25Click(Sender: TObject);
    procedure MenuItem26Click(Sender: TObject);
    procedure miIAThisSourceClick(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure miChatGPTClick(Sender: TObject);
    procedure micopyClick(Sender: TObject);
    procedure miIMGJSONClick(Sender: TObject);
    procedure miPasteClick(Sender: TObject);
    procedure miporradaClick(Sender: TObject);
    procedure miTestarPythonClick(Sender: TObject);
    procedure miDiagnosticoPythonClick(Sender: TObject);
    procedure miRedoClick(Sender: TObject);
    procedure miSelectAllClick(Sender: TObject);
    procedure miSelectBlockClick(Sender: TObject);
    procedure miSelectCmdClick(Sender: TObject);
    procedure miToolsFalarClick(Sender: TObject);
    procedure mncleanClick(Sender: TObject);
    procedure mnCompileClick(Sender: TObject);
    procedure mndebugClick(Sender: TObject);
    procedure mnHideResultClick(Sender: TObject);
    procedure mnidos2unixClick(Sender: TObject);
    procedure mniJSONVALIDClick(Sender: TObject);
    procedure mninstallClick(Sender: TObject);
    procedure mnJavaClick(Sender: TObject);
    procedure mnNoneClick(Sender: TObject);
    procedure mnPHPClick(Sender: TObject);
    procedure mnSQLClick(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure mnrunClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure miConfigClick(Sender: TObject);
    procedure miIAConfigClick(Sender: TObject);
    procedure miVoiceOutputConfigClick(Sender: TObject);
    procedure miPythonConfigClick(Sender: TObject);
    procedure miUndoClick(Sender: TObject);
    procedure mnFixWClick(Sender: TObject);
    procedure mnOnTopWClick(Sender: TObject);
    procedure mnDesktopCenterWClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure mnDesktopCenterClick(Sender: TObject);
    procedure mnCClick(Sender: TObject);
    procedure mnFechar2Click(Sender: TObject);
    procedure mnFixarClick(Sender: TObject);
    procedure mnLazarusClick(Sender: TObject);
    procedure mnAssociarClick(Sender: TObject);
    procedure mnfontClick(Sender: TObject);
    procedure mnPythonClick(Sender: TObject);
    procedure mnScriptClick(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure mnFecharClick(Sender: TObject);
    procedure mnPesqItemClick(Sender: TObject);
    procedure mnReplaceItemClick(Sender: TObject);
    procedure mnSalvarClick(Sender: TObject);
    procedure mnSalvarComoClick(Sender: TObject);
    procedure mnCarregarClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure mnStayClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure pgMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure pnBottonClick(Sender: TObject);
    procedure pnChatGPT2Resize(Sender: TObject);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure pntvClick(Sender: TObject);
    procedure pgMainChange(Sender: TObject);
    procedure pgMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);


    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);

    procedure MudaTodasaFontes();
  private
    { private declarations }
    FIDEShell: TMNoteIDEShell;
    FCommandRegistry: TMNoteCommandRegistry;
    FCommandPalette: TMNoteCommandPalette;
    FSearchPanel: TMNoteSearchPanel;
    FThemeService: TMNoteEditorThemeService;
    FThemeMenu: TMenuItem;
    FThemeItems: array[0..2] of TMenuItem;
    FLanguageToolbar: TMNoteLanguageToolbar;
    FPythonService: TMNotePythonService;
    FTasksPanel: TMNoteTasksPanel;
    FChangesPanel: TMNoteChangesPanel;
    FDBDictionaryPanel: TMNoteDBDictionaryPanel;
    FTaskListPanel: TMNoteTaskListPanel;
    FOutputPanel: TMNoteOutputPanel;
    FProblemsPanel: TMNoteProblemsPanel;
    FBuildService: TMNoteBuildService;
    FTerminalPanel: TMNoteTerminalPanel;
    FAIMonitorPanel: TMNoteAIMonitorPanel;
    FFilesPanel: TMNoteFilesPanel;
    FComponentsLabPanel: TMNoteComponentsLabPanel;
    FProjectContext: TMNoteProjectContext;
    FSolutionExplorer: TMNoteSolutionExplorerPanel;
    FChatMemoryMapPanel: TMNoteMemoryMapPanel;
    FNeuralApiBootstrap: TMNoteNeuralApiBootstrap;
    FNeuralApiCheckStarted: Boolean;
    FPendingAIQuestion: string;
    FPendingAIInputWasVoice: Boolean;
    FPendingAIProposal: Boolean;
    FPendingSQLGeneration: Boolean;
    FPendingPlanGeneration: Boolean;
    FPendingPlanRevision: Boolean;
    FPendingPlanInput: string;
    FPendingChangeValidation: Boolean;
    FAIProposalRetryCount: Integer;
    FAIProposalRetryQuestion: string;
    FAIProposalDeveloperMessage: string;
    procedure InitializeCommands;
    procedure ExecuteCommand(const ACommandID: string; Sender: TObject);
    procedure CommandOpen(Sender: TObject);
    procedure CommandSave(Sender: TObject);
    procedure CommandSaveAll(Sender: TObject);
    procedure CommandClose(Sender: TObject);
    procedure CommandFind(Sender: TObject);
    procedure CommandReplace(Sender: TObject);
    procedure CollectPaletteFiles(AFiles: TStrings);
    procedure OpenPaletteFile(const AFileName: string);
    procedure CollectSearchDocuments(ADocuments: TMNoteSearchDocuments);
    procedure NavigateSearchResult(const AFileName: string;
      ALine, AColumn, ALength: Integer);
    function GetProjectSearchFolder(out AFolder: string): Boolean;
    function ActivateProject(const APath: string; APersist: Boolean): Boolean;
    procedure RefreshProjectIntegration;
    procedure CommandProjectNew(Sender: TObject);
    procedure CommandProjectOpen(Sender: TObject);
    procedure CommandProjectOpenFolder(Sender: TObject);
    procedure CommandProjectClose(Sender: TObject);
    procedure CommandProjectSave(Sender: TObject);
    procedure CommandProjectRefresh(Sender: TObject);
    procedure ShowProjectProperties(Sender: TObject);
    function ProjectSQLiteLibraryPath: string;
    procedure InitializeThemeMenu;
    procedure ThemeMenuClick(Sender: TObject);
    function ThemeFilePath(const AThemeName: string): string;
    procedure ApplyTheme(const AThemeName: string);
    procedure ApplyThemeToAll;
    procedure UpdateLanguageUI;
    procedure CommandProjectBuild(Sender: TObject);
    procedure CommandProjectRebuild(Sender: TObject);
    procedure CommandProjectBuildStop(Sender: TObject);
    procedure StartProjectBuild(ARebuild: Boolean);
    procedure BuildOutput(Sender: TObject; const AText: string;
      AIsStdErr: Boolean);
    procedure BuildCompleted(Sender: TObject; ASuccess: Boolean;
      AExitCode: Integer; const AOutput, AError: string);
    procedure CommandProjectRun(Sender: TObject);
    procedure CommandPythonRun(Sender: TObject);
    procedure CommandPythonStop(Sender: TObject);
    procedure CommandPythonEnvironment(Sender: TObject);
    procedure CommandSQLExecute(Sender: TObject);
    procedure CommandShowDatabase(Sender: TObject);
    procedure GenerateDataDictionary(Sender: TObject);
    procedure RefreshSolutionDatabase;
    procedure AskDatabaseAI(Sender: TObject);
    procedure GenerateDatabaseSQL(Sender: TObject);
    procedure ProjectTaskCreated(Sender: TObject);
    procedure ProjectPlanRequested(Sender: TObject; ARevision: Boolean);
    procedure OpenTaskFile(Sender: TObject; const AFileName: string);
    procedure OpenTaskCommit(Sender: TObject; const ACommit: string);
    procedure ChangesApplied(Sender: TObject);
    procedure CommandShowOutput(Sender: TObject);
    procedure CommandShowProperties(Sender: TObject);
    procedure CommandShowOutline(Sender: TObject);
    procedure CommandWebPreview(Sender: TObject);
    procedure CommandToggleComment(Sender: TObject);
    procedure CommandGotoDefinition(Sender: TObject);
    procedure CommandFindReferences(Sender: TObject);
    procedure CommandAIExplain(Sender: TObject);
    procedure CommandAIFindBugs(Sender: TObject);
    procedure CommandAISuggestImprovement(Sender: TObject);
    procedure CommandAICompletion(Sender: TObject);
    procedure CommandAIProposeChange(Sender: TObject);
    procedure CommandAIStop(Sender: TObject);
    procedure CommandAIProfiles(Sender: TObject);
    procedure CommandAIComponentsLab(Sender: TObject);
    procedure OpenInventoryFile(Sender: TObject; const AFileName: string);
    procedure RetryAIChangeContract(Data: PtrInt);
    procedure StartCodeAction(AAction: TMNoteAICodeAction;
      const ATitle: string);
    procedure AIStateChanged(Sender: TObject; AState: TMNoteAIState);
    procedure AISessionChanged(Sender: TObject);
    procedure AICompleted(Sender: TObject; ASuccess: Boolean;
      const AResponse, AError: string);
    function ConfirmAIAction(Sender: TObject;
      ADescriptor: TMNoteAIActionDescriptor; AParameters: TJSONObject;
      out AReason: string): Boolean;
    procedure PresentAIResponse(const AResponse: string; ASuccess: Boolean);
    procedure SpeakAIResponse(const AResponse: string);
    procedure VoiceCommandReceived(Sender: TObject; const ACommand: string);
    procedure NeuralApiBootstrapCompleted(Sender: TObject;
      AStatus: TMNoteNeuralApiStatus; const AInstallerFile, AError: string);
    procedure InitializeProjectSymbolIndex;
    procedure QuestionChat();
    procedure AplicarEstilo(SynEdit: TSynEdit; StartLine, EndLine: Integer);
    procedure AnalisarSynEdit(SynEdit: TSynEdit);
    procedure CarregarParametros();
    procedure CarregarOld();
    procedure Carregar(arquivo : String);
    procedure SalvarTab(tb : TTabSheet);
    procedure synChange(Sender: TObject);
    procedure UpdateIDEStatus;
    procedure SalvarComo(tb :TTabSheet);
    function Mudou(): boolean;
    function PerguntaSalvar(): boolean;
    procedure SalvarTudo();
    procedure CarregaContexto();
    procedure AssociarExtensao(item: Titem);
    procedure SynEditkey(Sender: TObject; var Key: char);
    function SubmeteChatGPT( info : string) : string;

    function FindFilePage(const Arquivo: string): Integer;  // helper
  public
    { public declarations }
    function NovoItem():TTabSheet;
    procedure CloseTab(APage: TTabSheet = nil);
    procedure AnalisaFonte();

    function ExistFileOpen(Arquivo : string): boolean;
    procedure LoadArquivo(arquivo : string);
    procedure NewContext();
    procedure FazPergunta();
    procedure CarregarHistorico();

    function FileLoad(const FullName: string): Boolean;
    function FileNewSave(const FullName: string; Texto : widestring): boolean;
    function FocusFile(const FullName: string): Boolean;
    function GetFile(const FullName: string): WideString;
    procedure RodaScript();
    procedure RodaSQL();
    procedure MudaDoc();
    procedure SalvarWorkspaceState;
    procedure RestaurarWorkspaceState;
    procedure TestarPythonConnector;
    procedure DiagnosticoPythonConnector;
    procedure RunCloseTabTest(Data: PtrInt);
    procedure RunSolutionExplorerTest(Data: PtrInt);
    procedure SyncSolutionDatabaseFromMQuery;
  end;

  function FileLoad(const FullName: string): Boolean;

var
  frmMNote: TfrmMNote;

implementation

{$R *.lfm}

uses
  Sobre, base, ZDataset, DateUtils, aidb_types;

{ -------------------------------------------------------------------- }
{  Helper para extrair texto de DOC/DOCX/PDF                           }
{ -------------------------------------------------------------------- }

function LoadBinaryDocAsText(const AFileName: string): string;
var
  ext: string;
begin
  Result := '';
  ext := LowerCase(ExtractFileExt(AFileName));

  // 🔹 Ajuste os nomes das funções abaixo conforme tiver em uPdfText/uDocText
  if ext = '.pdf' then
  begin
    // Ex.: função em uPdfText
    Result := PdfFileToText(AFileName);
  end
  else
  if (ext = '.doc') or (ext = '.docx') then
  begin
    // Ex.: função em uDocText
    Result := DocFileToText(AFileName);
  end;
end;

{ TfrmMNote }

function FileLoad(const FullName: string): Boolean;
begin
  result := frmMNote.FileLoad(FullName);
end;


function TfrmMNote.FocusFile(const FullName: string): Boolean;
var
  alvo: string;
  i: Integer;
  item: TItem;
  openedPath: string;
begin
  Result := False;
  if Trim(FullName) = '' then Exit;

  alvo := ExpandFileName(FullName);

  if not FileLoad(alvo) then
    Exit(False);

  for i := 0 to pgMain.PageCount - 1 do
  begin
    item := TItem(pgMain.Pages[i].Tag);
    if item <> nil then
    begin
      openedPath := ExpandFileName(IncludeTrailingPathDelimiter(item.DirName) + item.FileName);
      if SameText(openedPath, alvo) then
      begin
        pgMain.ActivePageIndex := i;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TfrmMNote.GetFile(const FullName: string): WideString;
var
  alvo: string;
  i: Integer;
  item: TItem;
  syn : TSynEdit;
  openedPath: string;
begin
  Result := '';
  if Trim(FullName) = '' then Exit;

  alvo := ExpandFileName(FullName);

  if not FileLoad(alvo) then
    Exit('');

  for i := 0 to pgMain.PageCount - 1 do
  begin
    item := TItem(pgMain.Pages[i].Tag);
    if item <> nil then
    begin
      openedPath := ExpandFileName(IncludeTrailingPathDelimiter(item.DirName) + item.FileName);
      if SameText(openedPath, alvo) then
      begin
        pgMain.ActivePageIndex := i;
        item := TItem(pgMain.Pages[i].Tag);
        syn  := item.syn;
        Result := syn.Lines.Text ;
        Exit;
      end;
    end;
  end;
end;

procedure TfrmMNote.RodaScript();
var
  tb: TTabSheet;
  syn: TSynEdit;
  item: TItem;
  i, n: NativeInt;

  gil: PyGILState_STATE;
  keyObj: PPyObject;
  valObj: PPyObject;
  reprObj: PPyObject;
  globalsDict, localsDict: PPyObject;

  nameU, valU: UnicodeString;
  nameS, valS: String;

  procedure AddRowSafe(AList: TValueListEditor; const AKey, AValue: String);
  begin
    if Assigned(AList) then
      AList.InsertRow(AKey, AValue, True);
  end;

  function InRangeY(ASyn: TSynEdit; AY: Integer): Boolean;
  begin
    Result := (ASyn <> nil) and (AY >= 1) and (AY <= ASyn.Lines.Count);
  end;

begin
  if (pgMain = nil) or (pgMain.PageCount = 0) then Exit;
  if (pgMain.ActivePageIndex < 0) or (pgMain.ActivePageIndex >= pgMain.PageCount) then Exit;

  tb := pgMain.Pages[pgMain.ActivePageIndex];
  if (tb = nil) or (tb.Tag = 0) then
  begin
    ShowMessage('Aba não está associada a um item válido.');
    Exit;
  end;

  item := TItem(tb.Tag);
  if (item = nil) then
  begin
    ShowMessage('Item não encontrado.');
    Exit;
  end;

  try
    mnSalvarClick(Self);
  except
    on E: Exception do
    begin
      ShowMessage('Falha ao salvar antes de executar: ' + E.Message);
      Exit;
    end;
  end;

  meResult.Lines.Clear;
  item.Resultado := meResult;
  pnInspector.Visible := False;
  if Assigned(vlGlobal) then vlGlobal.Strings.Clear;
  if Assigned(vlLocal)  then vlLocal.Strings.Clear;

  item.Run;

  syn := item.syn;
  if item.Error then
  begin
    if InRangeY(syn, item.LinhaError) then
      syn.CaretY := item.LinhaError;
    Exit;
  end;

  if (item.PythonCtrl <> nil) and item.PythonCtrl.VarsCheck then
  begin
    gil := item.PythonCtrl.PythonEngine.PyGILState_Ensure();
    try
      globalsDict := item.PythonCtrl.PythonEngine.PyEval_GetGlobals();
      localsDict  := item.PythonCtrl.PythonEngine.PyEval_GetLocals();

      n := item.PythonCtrl.VarListGlobal_Size;
      for i := 0 to n - 1 do
      begin
        keyObj := item.PythonCtrl.PythonEngine.PyList_GetItem(item.PythonCtrl.VarsGlobalKeys, i);
        if keyObj <> nil then
        begin
          nameU := item.PythonCtrl.PythonEngine.PyUnicodeAsString(keyObj);
          nameS := UTF8Encode(nameU);

          valS := '';
          if globalsDict <> nil then
          begin
            valObj := item.PythonCtrl.PythonEngine.PyDict_GetItem(globalsDict, keyObj);
            if valObj <> nil then
            begin
              reprObj := item.PythonCtrl.PythonEngine.PyObject_Repr(valObj);
              try
                if reprObj <> nil then
                begin
                  valU := item.PythonCtrl.PythonEngine.PyUnicodeAsString(reprObj);
                  valS := UTF8Encode(valU);
                end;
              finally
                if reprObj <> nil then
                  item.PythonCtrl.PythonEngine.Py_DecRef(reprObj);
              end;
            end;
          end;

          AddRowSafe(vlGlobal, nameS, valS);
        end;
      end;

      n := item.PythonCtrl.VarListLocal_Size;
      for i := 0 to n - 1 do
      begin
        keyObj := item.PythonCtrl.PythonEngine.PyList_GetItem(item.PythonCtrl.VarsLocalKeys, i);
        if keyObj <> nil then
        begin
          nameU := item.PythonCtrl.PythonEngine.PyUnicodeAsString(keyObj);
          nameS := UTF8Encode(nameU);

          valS := '';
          if localsDict <> nil then
          begin
            valObj := item.PythonCtrl.PythonEngine.PyDict_GetItem(localsDict, keyObj);
            if valObj <> nil then
            begin
              reprObj := item.PythonCtrl.PythonEngine.PyObject_Repr(valObj);
              try
                if reprObj <> nil then
                begin
                  valU := item.PythonCtrl.PythonEngine.PyUnicodeAsString(reprObj);
                  valS := UTF8Encode(valU);
                end;
              finally
                if reprObj <> nil then
                  item.PythonCtrl.PythonEngine.Py_DecRef(reprObj);
              end;
            end;
          end;

          AddRowSafe(vlLocal, nameS, valS);
        end;
      end;

    finally
      item.PythonCtrl.PythonEngine.PyGILState_Release(gil);
    end;

    pnInspector.Visible := True;
  end;
end;

procedure TfrmMNote.RodaSQL();
var
  tb: TTabSheet;
  syn: TSynEdit;
  item: TItem;
begin
   tb := pgMain.ActivePage;
   item := TItem(tb.Tag);
   syn := item.syn;

   if(frmmquery2.zconpost.Connected) then
   begin
      frmmquery2.edSQLPost.text := syn.Lines.text;
      frmmquery2.pgmain.ActivePage :=  frmmquery2.tspostgree;
      frmmquery2.show;
      frmmquery2.OpenSelectPost();
   end;
   if(frmmquery2.zconmysql.Connected) then
   begin
      frmmquery2.pgmain.ActivePage :=  frmmquery2.tsMysql;
      frmmquery2.edSQL.text := syn.Lines.text;
      frmmquery2.show;
      frmmquery2.OpenSelectMy();
   end;
end;

procedure TfrmMNote.MudaDoc();
var
  tb       : TTabSheet;
  item     : TItem;
  fullfile : string;
begin
  pnChatGPT.Visible := False;

  if pgMain.ActivePage = nil then Exit;

  tb := pgMain.ActivePage;
  item := TItem(tb.Tag);
  if item = nil then Exit;

  fullfile := IncludeTrailingPathDelimiter(item.DirName) + item.FileName + '.RIA';

  if FileExists(fullfile) then
  begin
    try
      meDialog.Lines.LoadFromFile(fullfile);
    except
      on E: Exception do
        MessageHint('Erro ao carregar arquivo: ' + E.Message);
    end;
  end
  else
  begin
    meDialog.Clear;
  end;
end;



function TfrmMNote.FileLoad(const FullName: string): Boolean;
var
  alvo: string;
begin
  Result := False;

  if Trim(FullName) = '' then
  begin
    LoadArquivo('');

    Result := (pgMain.PageCount > 0);
    Exit;
  end;

  alvo := ExpandFileName(FullName);

  if not FileExists(alvo) then
  begin
    MessageHint('File not found: ' + alvo);
    Exit(False);
  end;

  LoadArquivo(alvo);


  Result := ExistFileOpen(alvo);
end;

function TfrmMNote.FileNewSave(const FullName: string; Texto: widestring
  ): boolean;
var
   tb : TTabSheet;
   item: TItem;
   syn : TSynEdit;
begin
  Result := False;

  NovoItem();
  if (pgMain.ActivePage <> nil) then
  begin
    tb := pgMain.ActivePage;
    if (tb = nil) then Exit(False);

    item := TItem(tb.Tag);
    if item = nil then Exit(False);

    syn  := item.syn;
    syn.Text := Texto;

    item.DirName  := ExtractFileDir(FullName);
    item.FileName := ExtractFileName(FullName);
    item.FileExt  := ExtractFileExt(FullName);

    if (item.FileName <> '') then
      tb.Caption := ExtractFileName(item.FileName);

    if (FullName <> '') then
    begin
      try
        item.Savefile(FullName);
        item.Salvo := True;
        Result := True;
      except
        on E: Exception do
        begin
          MessageHint('Erro ao salvar arquivo: ' + E.Message);
          Result := False;
        end;
      end;
    end;

    pgMain.ActivePage := tb;
    UpdateIDEStatus;
  end;
end;

function TfrmMNote.FindFilePage(const Arquivo: string): Integer;
var
  i: Integer;
  item: TItem;
  alvo, atual: string;
begin
  Result := -1;
  if Trim(Arquivo) = '' then Exit;

  alvo := ExpandFileName(Arquivo);

  for i := 0 to pgMain.PageCount - 1 do
  begin
    item := TItem(pgMain.Pages[i].Tag);
    if item <> nil then
    begin
      if item.FileName <> '' then
        atual := ExpandFileName(IncludeTrailingPathDelimiter(item.DirName) + item.FileName)
      else
        atual := '';

      if (atual <> '') and SameText(alvo, atual) then
      begin
        Result := i;
        Exit;
      end;
    end;
  end;
end;

function TfrmMNote.ExistFileOpen(Arquivo: string): boolean;
begin
  Result := FindFilePage(Arquivo) <> -1;
end;

procedure TfrmMNote.synChange(Sender: TObject);
var
  item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  item.mudou();
  UpdateIDEStatus;
  if FSearchPanel <> nil then
    FSearchPanel.EditorChanged;
end;

procedure TfrmMNote.UpdateIDEStatus;
var
  Item: TItem;
  FullName, ProjectName: string;
begin
  if (FProjectContext <> nil) and FProjectContext.IsOpen then
    ProjectName := FProjectContext.DisplayName
  else ProjectName := '';
  if (pgMain.ActivePage = nil) or (pgMain.ActivePage.Tag = 0) then
  begin
    if FIDEShell <> nil then
      FIDEShell.SetActiveEditor(nil, '', ProjectName);
    if FSearchPanel <> nil then
      FSearchPanel.SetActiveEditor(nil, '');
    Exit;
  end;
  Item := TItem(pgMain.ActivePage.Tag);
  FullName := Item.FileName;
  if Item.DirName <> '' then
    FullName := IncludeTrailingPathDelimiter(Item.DirName) + Item.FileName;
  if FIDEShell <> nil then
    FIDEShell.SetActiveEditor(Item.syn, FullName, ProjectName);
  if FSearchPanel <> nil then
    FSearchPanel.SetActiveEditor(Item.syn, FullName);
  if FSolutionExplorer <> nil then FSolutionExplorer.SelectFile(FullName);
  UpdateLanguageUI;
end;

procedure TfrmMNote.UpdateLanguageUI;
var
  PageItem: TItem;
  Profile: TMNoteLanguageProfile;
begin
  if (FLanguageToolbar = nil) or (pgMain.ActivePage = nil) or
    (pgMain.ActivePage.Tag = 0) then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  Profile := MNoteLanguages.FindByExtension(PageItem.FileExt);
  FLanguageToolbar.SetProfile(Profile);
end;

procedure TfrmMNote.SynEditkey(Sender: TObject; var Key: char);
var
  syn : TSynEdit;
  PageItem: TItem;
begin
   syn := TSynedit(Sender);
   if (syn.Parent is TTabSheet) and (TTabSheet(syn.Parent).Tag <> 0) then
   begin
     PageItem := TItem(TTabSheet(syn.Parent).Tag);
     PageItem.HandleEditorKeyPress(Key);
   end;
   case Key of
      char(VK_C):
      begin
      end;
      char(VK_V):
      begin
      end;
      char(VK_X):
      begin
        syn.CommandProcessor(TSynEditorCommand(ecCut), ' ', nil);
      end;
   end;
end;

function TfrmMNote.SubmeteChatGPT(info: string): string;
var
  resultado : string;
begin
  if (FSetMain.CHATGPT = '') then
  begin
    Resultado := 'Inclua o token do chatgpt';
  end
  else
  begin
    Resultado:= 'Not yet';
  end;
  result := resultado;
end;

procedure TfrmMNote.Carregar(arquivo : String);
var
  tb  : TTabSheet;
  syn : TSynEdit;
  item: TItem;
  idx : Integer;
  ext : string;
  txt : string;
  fileSize: Int64;
  SR: TSearchRec;
begin
  RegistraEventosLog('--------------------------------------------------');
  RegistraEventosLog('[Ponto 1] Carregar: Solicitada carga do arquivo: "' + arquivo + '"');

  // Ponto 1: Verificação de existência e tamanho do arquivo
  if not FileExists(arquivo) then
  begin
    RegistraEventosLog('[Ponto 1 ERRO]: Arquivo nao existe no disco: ' + arquivo);
    MessageHint(arquivo + ' not exists');
    Exit;
  end;

  fileSize := 0;
  if FindFirst(arquivo, faAnyFile, SR) = 0 then
  begin
    fileSize := SR.Size;
    FindClose(SR);
  end;
  RegistraEventosLog(Format('[Ponto 1 OK]: Arquivo encontrado no disco. Tamanho: %d bytes', [fileSize]));

  // Ponto 2: Verificação se o arquivo já está aberto em alguma aba
  idx := FindFilePage(arquivo);
  if idx <> -1 then
  begin
    pgMain.ActivePageIndex := idx;
    RegistraEventosLog(Format('[Ponto 2 REUTILIZA]: Arquivo ja esta aberto no indice %d do pgMain. Aba reativada.', [idx]));
    UpdateIDEStatus;
    Exit;
  end;
  RegistraEventosLog('[Ponto 2 OK]: Arquivo nao estava aberto. Prosseguindo para criar nova aba.');

  // Ponto 3: Instanciação da aba e dos componentes (NovoItem)
  RegistraEventosLog('[Ponto 3]: Invocando NovoItem()...');
  tb := NovoItem();
  if (tb = nil) or (tb.Tag = 0) then
  begin
    RegistraEventosLog('[Ponto 3 ERRO]: NovoItem() falhou ou retornou Tag=0');
    MessageHint('Erro ao criar aba no editor');
    Exit;
  end;

  item := TItem(tb.Tag);
  if (item = nil) then
  begin
    RegistraEventosLog('[Ponto 3 ERRO]: Objeto TItem(tb.Tag) e nil');
    Exit;
  end;

  syn := item.syn;
  if (syn = nil) then
  begin
    RegistraEventosLog('[Ponto 3 ERRO]: Instancia syn (TSynEdit) no TItem e nil');
    Exit;
  end;
  RegistraEventosLog(Format('[Ponto 3 OK]: Aba instanciada com sucesso. (Caption Inicial: "%s", Pointer Item: %p, Pointer Syn: %p)',
    [tb.Caption, Pointer(item), Pointer(syn)]));

  // Ponto 4: Atribuição de caminhos e extensão
  item.DirName  := ExtractFileDir(arquivo);
  item.FileExt  := ExtractFileExt(arquivo);
  item.FileName := ExtractFileName(arquivo);

  if (item.DirName = '') and (FSetMain <> nil) then
    item.DirName := ExtractFileDir(FSetMain.Defaultfolder);

  ext := LowerCase(ExtractFileExt(arquivo));
  RegistraEventosLog(Format('[Ponto 4 OK]: Diretorio: "%s", Arquivo: "%s", Extensao: "%s"',
    [item.DirName, item.FileName, item.FileExt]));

  // Ponto 5: Leitura do arquivo via item.Loadfile
  RegistraEventosLog('[Ponto 5]: Executando item.Loadfile("' + arquivo + '")...');
  try
    item.Loadfile(arquivo);
    ApplyThemeToAll;
    MudaDoc();
    RegistraEventosLog('[Ponto 5 OK]: item.Loadfile concluido sem excecoes.');
  except
    on E: Exception do
    begin
      tb.Free;
      RegistraEventosLog('[Ponto 5 ERRO]: Excecao em item.Loadfile: ' + E.Message);
      MessageHint('File cannot be read: ' + E.Message);
      Exit;
    end;
  end;

  // Ponto 6: Processamento especial para arquivos binários (PDF/DOC/DOCX)
  if (ext = '.pdf') or (ext = '.doc') or (ext = '.docx') then
  begin
    RegistraEventosLog('[Ponto 6]: Extensao binaria detectada (' + ext + '). Invocando LoadBinaryDocAsText...');
    txt := LoadBinaryDocAsText(arquivo);
    if syn <> nil then
      syn.Lines.Text := txt;
    RegistraEventosLog(Format('[Ponto 6 OK]: Texto extraido. Tamanho: %d caracteres.', [Length(txt)]));
    if Trim(txt) = '' then
      MessageHint('Nenhum texto extraído de ' + ExtractFileName(arquivo));
  end;

  // Ponto 7: Configuração de propriedades visuais da aba
  tb.Tag        := PtrInt(item);
  tb.ImageIndex := 0;
  tb.PopupMenu  := popFechar;
  tb.TabVisible := True;
  tb.Visible    := True;

  item.Salvo := True;

  if (syn <> nil) and ((FileGetAttr(arquivo) and faReadOnly) <> 0) then
    syn.ReadOnly := True;

  if item.Nome <> '' then
    tb.Caption := item.Nome
  else
    tb.Caption := ExtractFileName(arquivo);

  RegistraEventosLog(Format('[Ponto 7 OK]: Titulo final da aba configurado: "%s"', [tb.Caption]));

  // Ponto 8: Garantia de visibilidade e alinhamento do editor
  pnclient.Visible := True;
  pgMain.Visible := True;
  pgMain.ActivePage := tb;
  if syn <> nil then
  begin
    syn.Parent := tb;
    syn.Align := alClient;
    syn.Visible := True;
    syn.BringToFront;
    syn.Invalidate;
    if syn.CanFocus then
      syn.SetFocus;
  end;
  pgMain.Refresh;
  Application.ProcessMessages;
  RegistraEventosLog('[Ponto 8 OK]: Controles visuais pnclient, pgMain e syn forçados para Visible=True e focados.');

  // Ponto 9: Sincronização do estado da IDE
  UpdateIDEStatus;
  RegistraEventosLog('[Ponto 9 OK]: UpdateIDEStatus executado.');

  // Ponto 10: Verificação final do estado de exibição
  if (syn <> nil) then
  begin
    RegistraEventosLog(Format('[Ponto 10 CONCLUSÃO]: CARGA FINALIZADA COM SUCESSO! Aba: "%s", Linhas no SynEdit: %d, CharCount: %d, Total Abas no pgMain: %d',
      [tb.Caption, syn.Lines.Count, Length(syn.Text), pgMain.PageCount]));
  end
  else
  begin
    RegistraEventosLog('[Ponto 10 ALERTA]: Carga finalizada, porem syn (TSynEdit) e nil na aba "' + tb.Caption + '"');
  end;
  RegistraEventosLog('--------------------------------------------------');
end;

procedure TfrmMNote.LoadArquivo(arquivo : string);
begin
  if (arquivo = '') then
  begin
    RegistraEventosLog('LoadArquivo: Abrindo dialogo de selecao de arquivo...');
    if (FSetMain <> nil) and (FSetMain.DEFAULTFOLDER <> '') then
      OpenDialog1.InitialDir := FSetMain.DEFAULTFOLDER
    else
      OpenDialog1.InitialDir := GetCurrentDir;

    try
      if OpenDialog1.execute then
      begin
        if FileExists(OpenDialog1.FileName) then
        begin
          RegistraEventosLog('LoadArquivo: Arquivo selecionado no dialogo: ' + OpenDialog1.FileName);
          Carregar(OpenDialog1.FileName);
          Application.ProcessMessages;
        end
        else
        begin
          RegistraEventosLog('LoadArquivo [AVISO]: Arquivo selecionado nao existe: ' + OpenDialog1.FileName);
          MessageHint('File not found!');
        end;
      end
      else
        RegistraEventosLog('LoadArquivo: Dialogo cancelado pelo usuario.');
    except
      on E: Exception do
      begin
        RegistraEventosLog('LoadArquivo [ERRO]: Excecao no dialogo de selecao: ' + E.Message);
        MessageHint('Erro ao carregar arquivo: ' + E.Message);
      end;
    end;
  end
  else
  begin
    RegistraEventosLog('LoadArquivo: Solicitada abertura direta do arquivo: ' + arquivo);
    if FileExists(arquivo) then
    begin
      try
        Carregar(arquivo);
      except
        on E: Exception do
        begin
          RegistraEventosLog('LoadArquivo [ERRO]: Falha ao carregar arquivo "' + arquivo + '": ' + E.Message);
          MessageHint('Erro ao carregar arquivo: ' + E.Message);
        end;
      end;
    end
    else
    begin
      RegistraEventosLog('LoadArquivo [AVISO]: Arquivo informado nao existe: ' + arquivo);
      MessageHint('File not found!');
    end;
  end;
end;

procedure TfrmMNote.NewContext;
begin
  mequestion.Text := '';
end;

procedure TfrmMNote.FazPergunta;
begin
   FPendingAIInputWasVoice := False;
   pnWait.Visible:=true;
   Application.ProcessMessages;
   QuestionChat();
   pnWait.Visible:=false;
end;

procedure TfrmMNote.CarregarHistorico();
var
  arquivo : string;
  syn : TSynEdit;
  item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  arquivo := IncludeTrailingPathDelimiter(item.DirName) + item.FileName + '_historico.RIA';

  if FileExists(arquivo) then
    meChatHist.Lines.LoadFromFile(arquivo)
  else
    meChatHist.Clear;
end;

function TfrmMNote.NovoItem():TTabSheet;
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  tb := pgMain.AddTabSheet();

  syn := TSynEdit.Create(tb);
  syn.Parent := tb;
  syn.Align:= alClient;
  syn.Visible := True;
  syn.Lines.Clear;
  syn.PopupMenu := popSysEdit;
  syn.OnChange:= @synChange;
  syn.Font := FSetMain.Font;
  syn.OnKeyPress:= @SynEditkey;

  item := TItem.create(self);
  item.AtribuiNovoNome();
  item.syn := syn;
  if FThemeService <> nil then
    TMNoteThemeApplier.Apply(syn, FThemeService.Current);

  tb.PopupMenu := popFechar;
  tb.Tag:= PtrInt(item);
  tb.ImageIndex:=0;

  tb.Caption:= item.Nome;
  pnclient.Visible := True;
  pgMain.Visible := True;
  pgMain.ActivePage := tb;
  pgMain.Refresh();
  application.ProcessMessages;
  UpdateIDEStatus;
  result := tb;
end;

procedure TfrmMNote.CloseTab(APage: TTabSheet = nil);
var
  page: TTabSheet;
  item: TItem;
begin
  if APage <> nil then
    page := APage
  else
    page := pgMain.ActivePage;

  if page = nil then Exit;
  item := TItem(page.Tag);

  // Os painéis mantêm referências ao editor ativo para busca, caret e status.
  // Desconecte-os enquanto o editor ainda existe; após remover a aba,
  // UpdateIDEStatus ligará a próxima aba ativa.
  if FSearchPanel <> nil then
    FSearchPanel.SetActiveEditor(nil, '');
  if FIDEShell <> nil then
    FIDEShell.SetActiveEditor(nil, '', '');

  // O item ainda precisa do editor vivo para remover handlers, completion e
  // highlighter no destrutor. Limpe o Tag e libere-o antes da aba, que é dona
  // do TSynEdit.
  page.Tag := 0;
  if item <> nil then
    item.Free;

  page.PageControl := nil;
  page.Free;
  UpdateIDEStatus;
end;

procedure TfrmMNote.RunCloseTabTest(Data: PtrInt);
begin
  NovoItem;
  CloseTab;
  Application.Terminate;
end;

procedure TfrmMNote.RunSolutionExplorerTest(Data: PtrInt);
var
  Tables: TStringList;
begin
  if (ParamCount < 2) or not DirectoryExists(ParamStr(2)) or
    (FSolutionExplorer = nil) then Halt(1);
  Tables := TStringList.Create;
  try
    Tables.Add('public.clientes');
    Tables.Add('public.pedidos');
    FSolutionExplorer.SetProject(ParamStr(2), 'Projeto de teste', '',
      mpkFolder);
    FSolutionExplorer.SetDatabase('teste.db', Tables);
    if not FSolutionExplorer.ContainsNode('projeto.lpi') then Halt(1);
    if not FSolutionExplorer.ContainsNode('src') then Halt(1);
    if not FSolutionExplorer.ContainsNode('Banco de dados ''teste.db''') then
      Halt(1);
    if not FSolutionExplorer.ContainsNode('Tabelas (2)') then Halt(1);
    if not FSolutionExplorer.ContainsNode('public.clientes') then Halt(1);
    if not FSolutionExplorer.ContainsNode('public.pedidos') then Halt(1);
  finally
    Tables.Free;
  end;
  Application.Terminate;
end;

procedure TfrmMNote.SyncSolutionDatabaseFromMQuery;
var
  DatabaseName: string;
  Tables: TStringList;
begin
  if (FSolutionExplorer = nil) or (frmmquery2 = nil) then Exit;
  Tables := TStringList.Create;
  try
    if frmmquery2.GetActiveDatabaseTree(DatabaseName, Tables) then
      FSolutionExplorer.SetDatabase(DatabaseName, Tables)
    else
      FSolutionExplorer.ClearDatabase;
  finally
    Tables.Free;
  end;
end;

procedure TfrmMNote.AnalisaFonte();
begin
   pnChatGPT.Visible:=true;
end;

procedure TfrmMNote.CarregarParametros();
var
  i: Integer;
  p: string;
begin
  for i := 1 to ParamCount do
  begin
    p := ParamStr(i);
    if FileExists(p) and (not ExistFileOpen(p)) then
    begin
      Carregar(p);

      Application.ProcessMessages;
    end;
  end;
end;

procedure TfrmMNote.CarregarOld();
var
   a : integer;
   lista : TStringlist;
   strparametros : string;
   info : string;
begin
  strparametros := FsetMain.lastfiles;
  lista := TStringList.create;
  try
    lista.Delimiter := ' ';
    lista.DelimitedText :=  strparametros;
    for a  := 0 to lista.Count-1 do
    begin
       info := lista[a];
       if(FileExists(info)) then
       begin
         if not ExistFileOpen(info) then
           Carregar(info);
         Application.ProcessMessages;
       end;
    end;
  finally
    lista.Free;
  end;
  application.ProcessMessages;
end;

procedure TfrmMNote.InitializeCommands;
var
  NavigationMenu, GoDefinitionItem, FindReferencesItem: TMenuItem;
  AIMenu, AICompletionItem, AIProposeItem, AILabItem: TMenuItem;
begin
  FreeAndNil(FCommandRegistry);
  FCommandRegistry := TMNoteCommandRegistry.Create;
  FCommandRegistry.RegisterCommand('file.open', 'Abrir arquivo', 'Arquivo',
    mnCarregar.ShortCut, @CommandOpen);
  FCommandRegistry.RegisterCommand('file.save', 'Salvar', 'Arquivo',
    mnSalvar.ShortCut, @CommandSave);
  FCommandRegistry.RegisterCommand('file.save_all', 'Salvar Tudo', 'Arquivo',
    MenuItem9.ShortCutKey2, @CommandSaveAll);
  FCommandRegistry.RegisterCommand('file.close', 'Fechar documento', 'Arquivo',
    mnFechar.ShortCut, @CommandClose);
  FCommandRegistry.RegisterCommand('edit.find', 'Localizar', 'Editar',
    mnPesqItem.ShortCut, @CommandFind);
  FCommandRegistry.RegisterCommand('edit.replace', 'Substituir', 'Editar',
    mnReplaceItem.ShortCut, @CommandReplace);
  FCommandRegistry.RegisterCommand('project.new', 'Novo Projeto', 'Projeto', 0,
    @CommandProjectNew);
  FCommandRegistry.RegisterCommand('project.open', 'Abrir Projeto',
    'Projeto', 0, @CommandProjectOpen);
  FCommandRegistry.RegisterCommand('project.open_folder', 'Abrir Pasta',
    'Projeto', 0, @CommandProjectOpenFolder);
  FCommandRegistry.RegisterCommand('project.save', 'Salvar Projeto', 'Projeto',
    0, @CommandProjectSave);
  FCommandRegistry.RegisterCommand('project.close', 'Fechar Projeto',
    'Projeto', 0, @CommandProjectClose);
  FCommandRegistry.RegisterCommand('project.refresh',
    'Atualizar Solution Explorer', 'Projeto', 0, @CommandProjectRefresh);
  FCommandRegistry.RegisterCommand('project.build', 'Build', 'Projeto', 0,
    @CommandProjectBuild);
  FCommandRegistry.RegisterCommand('project.rebuild', 'Rebuild', 'Projeto', 0,
    @CommandProjectRebuild);
  FCommandRegistry.RegisterCommand('project.build.stop', 'Parar Build',
    'Projeto', 0, @CommandProjectBuildStop);
  FCommandRegistry.RegisterCommand('project.run', 'Run', 'Projeto', 0,
    @CommandProjectRun);
  FCommandRegistry.RegisterCommand('python.run', 'Run Python', 'Python', 0,
    @CommandPythonRun);
  FCommandRegistry.RegisterCommand('python.stop', 'Stop Python', 'Python', 0,
    @CommandPythonStop);
  FCommandRegistry.RegisterCommand('python.environment', 'Ambiente', 'Python',
    0, @CommandPythonEnvironment);
  FCommandRegistry.RegisterCommand('sql.execute', 'Execute SQL', 'SQL', 0,
    @CommandSQLExecute);
  FCommandRegistry.RegisterCommand('database.show', 'Database', 'SQL', 0,
    @CommandShowDatabase);
  FCommandRegistry.RegisterCommand('database.dictionary', 'Dictionary', 'SQL',
    0, @CommandShowDatabase);
  FCommandRegistry.RegisterCommand('output.show', 'Output', 'IDE', 0,
    @CommandShowOutput);
  FCommandRegistry.RegisterCommand('variables.show', 'Variables', 'Python', 0,
    @CommandShowProperties);
  FCommandRegistry.RegisterCommand('outline.show', 'Outline', 'Pascal', 0,
    @CommandShowOutline);
  FCommandRegistry.RegisterCommand('web.preview', 'Preview', 'Web', 0,
    @CommandWebPreview);
  FCommandRegistry.RegisterCommand('editor.toggle_comment', 'Comentar',
    'Editar', 0, @CommandToggleComment);
  FCommandRegistry.RegisterCommand('symbol.navigate', 'Ir para definição',
    'Navegação', Menus.ShortCut(VK_F12, []), @CommandGotoDefinition);
  FCommandRegistry.RegisterCommand('symbol.references',
    'Localizar todas as referências', 'Navegação',
    Menus.ShortCut(VK_F12, [ssShift]), @CommandFindReferences);
  FCommandRegistry.RegisterCommand('ai.explain_code', 'Explain Code', 'IA',
    0, @CommandAIExplain);
  FCommandRegistry.RegisterCommand('ai.find_bugs', 'Find Bugs', 'IA', 0,
    @CommandAIFindBugs);
  FCommandRegistry.RegisterCommand('ai.suggest_improvement',
    'Suggest Improvement', 'IA', 0, @CommandAISuggestImprovement);
  FCommandRegistry.RegisterCommand('ai.complete_code',
    'Sugerir continuação com IA', 'IA',
    Menus.ShortCut(VK_SPACE, [ssCtrl, ssAlt]), @CommandAICompletion);
  FCommandRegistry.RegisterCommand('ai.propose_change',
    'Propor correção com IA', 'IA', 0, @CommandAIProposeChange);
  FCommandRegistry.RegisterCommand('ai.stop', 'Parar IA', 'IA', 0,
    @CommandAIStop);
  FCommandRegistry.RegisterCommand('ai.profiles', 'Configurar IAs',
    'IA', 0, @CommandAIProfiles);
  FCommandRegistry.RegisterCommand('ai.components_lab', 'AI Components Lab',
    'IA', 0, @CommandAIComponentsLab);

  NavigationMenu := TMenuItem.Create(Self);
  NavigationMenu.Caption := 'Navegação';
  MainMenu1.Items.Add(NavigationMenu);
  GoDefinitionItem := TMenuItem.Create(Self);
  GoDefinitionItem.Caption := 'Ir para definição';
  GoDefinitionItem.ShortCut := Menus.ShortCut(VK_F12, []);
  GoDefinitionItem.OnClick := @CommandGotoDefinition;
  NavigationMenu.Add(GoDefinitionItem);
  FindReferencesItem := TMenuItem.Create(Self);
  FindReferencesItem.Caption := 'Localizar todas as referências';
  FindReferencesItem.ShortCut := Menus.ShortCut(VK_F12, [ssShift]);
  FindReferencesItem.OnClick := @CommandFindReferences;
  NavigationMenu.Add(FindReferencesItem);
  AIMenu := TMenuItem.Create(Self);
  AIMenu.Caption := 'IA';
  MainMenu1.Items.Add(AIMenu);
  AICompletionItem := TMenuItem.Create(Self);
  AICompletionItem.Caption := 'Sugerir continuação';
  AICompletionItem.ShortCut := Menus.ShortCut(VK_SPACE, [ssCtrl, ssAlt]);
  AICompletionItem.OnClick := @CommandAICompletion;
  AIMenu.Add(AICompletionItem);
  AIProposeItem := TMenuItem.Create(Self);
  AIProposeItem.Caption := 'Propor correção com IA';
  AIProposeItem.OnClick := @CommandAIProposeChange;
  AIMenu.Add(AIProposeItem);
  AILabItem := TMenuItem.Create(Self);
  AILabItem.Caption := 'AI Components Lab';
  AILabItem.OnClick := @CommandAIComponentsLab;
  AIMenu.Add(AILabItem);
end;

procedure TfrmMNote.ExecuteCommand(const ACommandID: string; Sender: TObject);
begin
  if (FCommandRegistry = nil) or
    (not FCommandRegistry.Execute(ACommandID, Sender)) then
    MessageHint('Comando indisponível: ' + ACommandID);
end;

procedure TfrmMNote.CommandOpen(Sender: TObject);
begin
  LoadArquivo('');
end;

procedure TfrmMNote.CommandSave(Sender: TObject);
var
  tb: TTabSheet;
  item: TItem;
begin
  if pgMain.ActivePage = nil then Exit;
  tb := pgMain.ActivePage;
  item := TItem(tb.Tag);
  SalvarTab(tb);
  if item.FileName <> '' then
    MessageHint('Saved in ' + item.FileName);
end;

procedure TfrmMNote.CommandSaveAll(Sender: TObject);
var
  PageIndex: Integer;
begin
  for PageIndex := 0 to pgMain.PageCount - 1 do
    SalvarTab(pgMain.Pages[PageIndex]);
  MessageHint('All Saved!');
end;

procedure TfrmMNote.CommandClose(Sender: TObject);
begin
  CloseTab;
end;

procedure TfrmMNote.CommandFind(Sender: TObject);
begin
  if FSearchPanel <> nil then
    FSearchPanel.ShowFind
  else
    FindDialog1.Execute;
end;

procedure TfrmMNote.CommandReplace(Sender: TObject);
begin
  if FSearchPanel <> nil then
    FSearchPanel.ShowReplace
  else
    ReplaceDialog1.Execute;
end;

procedure TfrmMNote.CommandProjectBuild(Sender: TObject);
begin
  StartProjectBuild(False);
end;

procedure TfrmMNote.CommandProjectRebuild(Sender: TObject);
begin
  StartProjectBuild(True);
end;

procedure TfrmMNote.CommandProjectBuildStop(Sender: TObject);
begin
  if FBuildService <> nil then FBuildService.Cancel;
end;

procedure TfrmMNote.StartProjectBuild(ARebuild: Boolean);
var
  ProjectRoot, ErrorText: string;
begin
  if (FBuildService = nil) or (not GetProjectSearchFolder(ProjectRoot)) then
  begin
    MessageHint('Abra um projeto antes de compilar.');
    Exit;
  end;
  SalvarTudo;
  if FOutputPanel <> nil then
  begin
    FOutputPanel.Clear(mocBuild);
    if ARebuild then FOutputPanel.Add(mocBuild,
      'Rebuild iniciado...' + LineEnding)
    else FOutputPanel.Add(mocBuild, 'Build iniciado...' + LineEnding);
    FOutputPanel.Select(mocBuild);
  end;
  if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkOutput);
  if not FBuildService.Start(ProjectRoot, ARebuild, ErrorText) then
  begin
    if FOutputPanel <> nil then
      FOutputPanel.Add(mocBuild, ErrorText + LineEnding);
    MessageHint(ErrorText);
  end;
end;

procedure TfrmMNote.BuildOutput(Sender: TObject; const AText: string;
  AIsStdErr: Boolean);
begin
  if FOutputPanel <> nil then FOutputPanel.Add(mocBuild, AText);
end;

procedure TfrmMNote.BuildCompleted(Sender: TObject; ASuccess: Boolean;
  AExitCode: Integer; const AOutput, AError: string);
begin
  if FProblemsPanel <> nil then
    FProblemsPanel.ParseBuildOutput(AOutput, 'Build');
  if FOutputPanel <> nil then
  begin
    if ASuccess then
      FOutputPanel.Add(mocBuild, LineEnding +
        'Build concluído com sucesso.' + LineEnding)
    else
      FOutputPanel.Add(mocBuild, LineEnding + 'Build falhou: ' + AError +
        LineEnding);
  end;
  if not ASuccess then
  begin
    if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkProblems);
    MessageHint(Format('Build falhou (código %d).', [AExitCode]));
  end;
  if FPendingChangeValidation then
  begin
    FPendingChangeValidation := False;
    if ASuccess then
      MessageDlg('Changes', 'Validação pós-Apply concluída com sucesso.',
        mtInformation, [mbOK], 0)
    else if MessageDlg('Changes',
      'A validação pós-Apply falhou. Restaurar agora o change set?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      if not FChangesPanel.RollbackCurrent then
        MessageDlg('Changes', FChangesPanel.Manager.LastError, mtError,
          [mbOK], 0)
      else
        MessageHint('Rollback concluído após falha de validação.');
    end;
  end;
end;

procedure TfrmMNote.CommandProjectRun(Sender: TObject);
begin
  mnrunClick(Sender);
end;

procedure TfrmMNote.CommandPythonRun(Sender: TObject);
var
  PageItem: TItem;
begin
  if (pgMain.ActivePage = nil) or (FPythonService = nil) then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  if not FPythonService.ExecuteLines(PageItem.syn.Lines) then
    meResult.Text := FPythonService.LastError
  else
    meResult.Text := FPythonService.LastOutput;
  if FOutputPanel <> nil then
    FOutputPanel.SetText(mocPython, meResult.Text);
  CommandShowOutput(Sender);
end;

procedure TfrmMNote.CommandPythonStop(Sender: TObject);
begin
  if FPythonService <> nil then
    FPythonService.Stop;
  MessageHint('Execução Python interrompida.');
end;

procedure TfrmMNote.CommandPythonEnvironment(Sender: TObject);
begin
  if FPythonService = nil then Exit;
  FPythonService.GetDiagnosticReport(meResult.Lines);
  CommandShowOutput(Sender);
end;

procedure TfrmMNote.CommandSQLExecute(Sender: TObject);
begin
  if frmmquery2 = nil then
    frmmquery2 := Tfrmmquery2.Create(Self);
  RodaSQL;
end;

procedure TfrmMNote.CommandShowDatabase(Sender: TObject);
begin
  if FIDEShell <> nil then
    FIDEShell.ShowToolWindow(twkDatabase);
end;

procedure TfrmMNote.GenerateDataDictionary(Sender: TObject);
var
  Generated: Boolean;
  Completions: TStringList;
begin
  if FDBDictionaryPanel = nil then Exit;
  if FOutputPanel <> nil then
  begin
    FOutputPanel.Select(mocDatabase);
    FOutputPanel.Add(mocDatabase, 'Iniciando leitura de metadados da conexão ativa...' +
      LineEnding);
  end;
  if frmmquery2 = nil then frmmquery2 := Tfrmmquery2.Create(Self);
  Generated := False;
  if frmmquery2.zconpost.Connected then
    Generated := FDBDictionaryPanel.GenerateFor(frmmquery2.zconpost)
  else if frmmquery2.zconsqlite.Connected then
    Generated := FDBDictionaryPanel.GenerateFor(frmmquery2.zconsqlite)
  else
  begin
    MessageHint('Conecte PostgreSQL ou SQLite no MQuery2 antes de gerar o dicionário.');
    frmmquery2.Show;
  end;
  if Generated then
  begin
    if FOutputPanel <> nil then FOutputPanel.Add(mocDatabase,
      'Dicionário gerado: tabelas, colunas e relacionamentos carregados.' +
      LineEnding);
    MNoteAI.SetDatabaseDictionaryCache(FDBDictionaryPanel.Service.AsJSON);
    Completions := TStringList.Create;
    try
      FDBDictionaryPanel.Service.CollectSQLCompletions(Completions);
      MNoteDatabaseCompletions.Update(Completions);
    finally
      Completions.Free;
    end;
    RefreshSolutionDatabase;
  end;
  if (not Generated) and (FOutputPanel <> nil) then
    FOutputPanel.Add(mocDatabase, 'Dicionário não gerado: ' +
      FDBDictionaryPanel.Service.LastError + LineEnding);
end;

procedure TfrmMNote.RefreshSolutionDatabase;
var
  Tables: TStringList;
  Table: TAIDBTableInfo;
  DatabaseName, TableName: string;
  I: Integer;
begin
  if FSolutionExplorer = nil then Exit;
  if (FDBDictionaryPanel = nil) or
    (FDBDictionaryPanel.Service.Dictionary = nil) or
    (FDBDictionaryPanel.Service.Dictionary.DataDictionary = nil) then
  begin
    if frmmquery2 <> nil then SyncSolutionDatabaseFromMQuery
    else FSolutionExplorer.ClearDatabase;
    Exit;
  end;
  DatabaseName := '';
  if FDBDictionaryPanel.Service.Connection <> nil then
  begin
    DatabaseName := Trim(FDBDictionaryPanel.Service.Connection.Database);
    if Pos('sqlite', LowerCase(
      FDBDictionaryPanel.Service.Connection.Protocol)) > 0 then
      DatabaseName := ExtractFileName(DatabaseName);
    if DatabaseName = '' then
      DatabaseName := FDBDictionaryPanel.Service.Connection.Protocol;
  end;
  if DatabaseName = '' then DatabaseName := 'conexão ativa';
  Tables := TStringList.Create;
  try
    for I := 0 to FDBDictionaryPanel.Service.Dictionary.DataDictionary.Tables.Count - 1 do
    begin
      Table := FDBDictionaryPanel.Service.Dictionary.DataDictionary.Tables[I];
      TableName := Table.TableName;
      if Trim(Table.SchemaName) <> '' then
        TableName := Table.SchemaName + '.' + TableName;
      Tables.Add(TableName);
    end;
    FSolutionExplorer.SetDatabase(DatabaseName, Tables);
  finally
    Tables.Free;
  end;
end;

procedure TfrmMNote.ProjectTaskCreated(Sender: TObject);
begin
  if FTasksPanel <> nil then FTasksPanel.Refresh;
end;

procedure TfrmMNote.ProjectPlanRequested(Sender: TObject; ARevision: Boolean);
var
  Objective, ProjectRoot, ExistingPlan: string;
begin
  if (FTasksPanel = nil) or MNoteAI.IsBusy then
  begin
    if MNoteAI.IsBusy then MessageHint('Aguarde a operação de IA atual terminar.');
    Exit;
  end;
  Objective := '';
  if ARevision then
  begin
    if not InputQuery('Revisar plano com IA',
      'Descreva a correção desejada:', Objective) or (Trim(Objective) = '') then Exit;
    ExistingPlan := FTasksPanel.Service.Project.ProjectData.Objects[
      'planning'].FormatJSON;
    Objective := 'Revise o plano atual conforme esta solicitação: ' + Objective +
      LineEnding + 'PLANO ATUAL:' + LineEnding + ExistingPlan;
  end
  else if not InputQuery('Gerar plano com IA',
    'Descreva o objetivo do projeto:', Objective) or
    (Trim(Objective) = '') then Exit;
  if GetProjectSearchFolder(ProjectRoot) then MNoteAI.SetProjectRoot(ProjectRoot);
  FPendingPlanGeneration := True;
  FPendingPlanRevision := ARevision;
  FPendingPlanInput := Objective;
  FPendingAIQuestion := Objective;
  FPendingSQLGeneration := False;
  FPendingAIProposal := False;
  if not MNoteAI.SendRoutedAsync(aikPlanning, Objective,
    'Planeje somente após a etapa Entender. Não persista nada; o usuário revisará cada tarefa.') then
  begin
    FPendingPlanGeneration := False;
    MessageHint(MNoteAI.LastError);
  end;
end;

procedure TfrmMNote.OpenTaskFile(Sender: TObject; const AFileName: string);
var
  Root, FullName, RootPrefix: string;
begin
  if not GetProjectSearchFolder(Root) then Exit;
  RootPrefix := IncludeTrailingPathDelimiter(ExpandFileName(Root));
  FullName := ExpandFileName(RootPrefix + StringReplace(AFileName, '/',
    PathDelim, [rfReplaceAll]));
  if Pos(LowerCase(RootPrefix), LowerCase(FullName)) <> 1 then
  begin MessageHint('O vínculo aponta para fora do projeto.'); Exit; end;
  if not FileExists(FullName) then
  begin MessageHint('Arquivo vinculado não encontrado: ' + AFileName); Exit; end;
  OpenPaletteFile(FullName);
end;

procedure TfrmMNote.OpenTaskCommit(Sender: TObject; const ACommit: string);
var
  Root, Diff: string;
  Git: TMNoteGitReadService;
begin
  if not GetProjectSearchFolder(Root) then Exit;
  Git := TMNoteGitReadService.Create;
  try
    if not Git.CommitDiff(Root, ACommit, Diff) then
    begin MessageHint(Git.LastError); Exit; end;
    FChangesPanel.PresentGitDiff('Commit ' + ACommit, Diff);
    FIDEShell.ShowToolWindow(twkChanges);
  finally
    Git.Free;
  end;
end;

procedure TfrmMNote.ChangesApplied(Sender: TObject);
var
  ProjectRoot, ErrorText: string;
  Started: Boolean;
begin
  if (FBuildService = nil) or FBuildService.Running then
  begin
    if MessageDlg('Changes',
      'Não foi possível iniciar a validação porque já existe um build. ' +
      'Restaurar o change set agora?', mtConfirmation,
      [mbYes, mbNo], 0) = mrYes then
      FChangesPanel.RollbackCurrent;
    Exit;
  end;
  FPendingChangeValidation := True;
  ErrorText := '';
  if not GetProjectSearchFolder(ProjectRoot) then
  begin
    ErrorText := 'projeto não encontrado';
    Started := False;
  end
  else
    Started := FBuildService.Start(ProjectRoot, False, ErrorText);
  if not Started then
  begin
    FPendingChangeValidation := False;
    if MessageDlg('Changes',
      'Nenhuma validação de build pôde ser iniciada (' + ErrorText +
      '). Restaurar o change set?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      FChangesPanel.RollbackCurrent;
    Exit;
  end;
  if FOutputPanel <> nil then
  begin
    FOutputPanel.Clear(mocBuild);
    FOutputPanel.Add(mocBuild,
      'Validação pós-Apply iniciada sem regravar os editores...' + LineEnding);
    FOutputPanel.Select(mocBuild);
  end;
  FIDEShell.ShowToolWindow(twkOutput);
end;

procedure TfrmMNote.AskDatabaseAI(Sender: TObject);
var
  Question, ProjectRoot: string;
begin
  if (FDBDictionaryPanel = nil) or
    (Trim(FDBDictionaryPanel.Service.AsJSON) = '') then
  begin
    MessageHint('Gere o dicionário antes de consultar a IA.');
    Exit;
  end;
  Question := '';
  if not InputQuery('Dicionário e IA',
    'Pergunta sobre a estrutura do banco:', Question) or
    (Trim(Question) = '') then Exit;
  if GetProjectSearchFolder(ProjectRoot) then MNoteAI.SetProjectRoot(ProjectRoot);
  MNoteAI.SetDatabaseDictionaryCache(FDBDictionaryPanel.Service.AsJSON);
  FPendingAIQuestion := Question;
  FPendingSQLGeneration := False;
  if not MNoteAI.SendRoutedAsync(aikDatabase,
    Question + #10'Use a ação DBDictionary; cite somente objetos existentes no cache.',
    'Consulte somente metadados já carregados. Não abra conexão nem execute SQL.') then
    MessageHint(MNoteAI.LastError);
end;

procedure TfrmMNote.GenerateDatabaseSQL(Sender: TObject);
var
  Objective, ProjectRoot: string;
begin
  if (FDBDictionaryPanel = nil) or
    (Trim(FDBDictionaryPanel.Service.AsJSON) = '') then
  begin
    MessageHint('Gere o dicionário antes de solicitar SQL.');
    Exit;
  end;
  Objective := '';
  if not InputQuery('Gerar SQL sem executar',
    'Descreva o SQL desejado:', Objective) or
    (Trim(Objective) = '') then Exit;
  if GetProjectSearchFolder(ProjectRoot) then MNoteAI.SetProjectRoot(ProjectRoot);
  MNoteAI.SetDatabaseDictionaryCache(FDBDictionaryPanel.Service.AsJSON);
  FPendingAIQuestion := Objective;
  FPendingSQLGeneration := True;
  if not MNoteAI.SendRoutedAsync(aikDatabase,
    'Gere SQL para: ' + Objective + #10+
    'Primeiro use DBDictionary. Retorne somente SQL, sem markdown, e não execute.',
    'Use somente metadados do cache. A resposta será validada antes de ir ao editor.') then
  begin
    FPendingSQLGeneration := False;
    MessageHint(MNoteAI.LastError);
  end;
end;

procedure TfrmMNote.CommandShowOutput(Sender: TObject);
begin
  if FIDEShell <> nil then
    FIDEShell.ShowToolWindow(twkOutput);
end;

procedure TfrmMNote.CommandShowProperties(Sender: TObject);
begin
  if FIDEShell <> nil then
    FIDEShell.ShowToolWindow(twkProperties);
end;

procedure TfrmMNote.CommandShowOutline(Sender: TObject);
begin
  if FIDEShell <> nil then
    FIDEShell.ShowToolWindow(twkSolution);
end;

procedure TfrmMNote.CommandWebPreview(Sender: TObject);
var
  PageItem: TItem;
  FullName: string;
begin
  if pgMain.ActivePage = nil then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  FullName := IncludeTrailingPathDelimiter(PageItem.DirName) +
    PageItem.FileName;
  if FileExists(FullName) then
    OpenDocument(FullName)
  else
    MessageHint('Salve o arquivo antes de abrir o preview.');
end;

procedure TfrmMNote.CommandToggleComment(Sender: TObject);
var
  PageItem: TItem;
  Profile: TMNoteLanguageProfile;
  SourceText, ChangedText: string;
  LineIndex: Integer;
begin
  if pgMain.ActivePage = nil then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  Profile := MNoteLanguages.FindByExtension(PageItem.FileExt);
  if (Profile = nil) or (Profile.LineComment = '') then
  begin
    MessageHint('A linguagem atual não possui comentário de linha.');
    Exit;
  end;
  PageItem.syn.BeginUndoBlock;
  try
    if PageItem.syn.SelText <> '' then
    begin
      SourceText := PageItem.syn.SelText;
      ChangedText := TMNoteEditorOptions.ToggleLineComments(SourceText,
        Profile);
      PageItem.syn.SelText := ChangedText;
    end
    else
    begin
      LineIndex := PageItem.syn.CaretY - 1;
      SourceText := PageItem.syn.Lines[LineIndex];
      PageItem.syn.Lines[LineIndex] :=
        TMNoteEditorOptions.ToggleLineComments(SourceText, Profile);
    end;
  finally
    PageItem.syn.EndUndoBlock;
  end;
end;

procedure TfrmMNote.CommandGotoDefinition(Sender: TObject);
var
  PageItem: TItem;
  DefinitionFile: string;
  DefinitionLine: Integer;
begin
  if (pgMain.ActivePage = nil) or (pgMain.ActivePage.Tag = 0) then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  if PageItem.FindDefinitionAtCaret(DefinitionFile, DefinitionLine) then
    NavigateSearchResult(DefinitionFile, DefinitionLine, 1, 0)
  else
    MessageHint('Definição não encontrada no índice local.');
end;

procedure TfrmMNote.CommandFindReferences(Sender: TObject);
var
  PageItem: TItem;
  SymbolName: string;
begin
  if (pgMain.ActivePage = nil) or (pgMain.ActivePage.Tag = 0) or
    (FSearchPanel = nil) then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  SymbolName := PageItem.syn.GetWordAtRowCol(PageItem.syn.LogicalCaretXY);
  if SymbolName = '' then
  begin
    MessageHint('Posicione o cursor sobre um símbolo.');
    Exit;
  end;
  if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkSearch);
  FSearchPanel.FindAllReferences(SymbolName);
end;

procedure TfrmMNote.InitializeProjectSymbolIndex;
var
  ProjectRoot, CacheFile: string;
begin
  if not GetProjectSearchFolder(ProjectRoot) then Exit;
  CacheFile := IncludeTrailingPathDelimiter(ProjectRoot) + '.mnote' +
    PathDelim + 'symbols.cache';
  MNoteProjectSymbols.LoadCache(CacheFile);
  if MNoteProjectSymbols.IndexFolder(ProjectRoot) then
    MNoteProjectSymbols.SaveCache(CacheFile);
end;

procedure TfrmMNote.StartCodeAction(AAction: TMNoteAICodeAction;
  const ATitle: string);
var
  PageItem: TItem;
  CodeText, DeveloperMessage: string;
  Estimate: TMNoteTokenEstimate;
begin
  if (pgMain.ActivePage = nil) or (pgMain.ActivePage.Tag = 0) then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  CodeText := PageItem.syn.SelText;
  if CodeText = '' then CodeText := PageItem.syn.Text;
  Estimate := MNoteAI.EstimateContext(CodeText);
  meDialog.Lines.Text := Format('%s — estimativa: %d tokens + %d de margem; limite %d; %s',
    [ATitle, Estimate.EstimatedTokens, Estimate.SafetyMargin,
     Estimate.ContextLimit, Estimate.Method]);
  if Estimate.ExceedsLimit and
    (not ShowConfirm('O contexto estimado excede o limite configurado. Continuar?')) then
    Exit;
  DeveloperMessage := MNoteAI.BuildPrompt('assistente de programação',
    ATitle, 'somente analisar; não modificar arquivos nem executar comandos',
    'linguagem: ' + MNoteLanguages.FindByExtension(PageItem.FileExt).Name,
    'resposta técnica verificável, indicando incertezas');
  FPendingAIQuestion := ATitle;
  FPendingAIInputWasVoice := False;
  if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkAI);
  if not MNoteAI.SendCodeActionAsync(AAction, CodeText,
    DeveloperMessage) then MessageHint(MNoteAI.LastError);
end;

procedure TfrmMNote.CommandAIExplain(Sender: TObject);
begin
  StartCodeAction(aicaExplain, 'Explicar o código selecionado');
end;

procedure TfrmMNote.CommandAIFindBugs(Sender: TObject);
begin
  StartCodeAction(aicaFindBugs, 'Localizar bugs no código selecionado');
end;

procedure TfrmMNote.CommandAISuggestImprovement(Sender: TObject);
begin
  StartCodeAction(aicaSuggestImprovement,
    'Sugerir melhoria sem aplicar automaticamente');
end;

procedure TfrmMNote.CommandAICompletion(Sender: TObject);
begin
  StartCodeAction(aicaCompletion,
    'Sugerir continuação explícita do código');
end;

procedure TfrmMNote.CommandAIProposeChange(Sender: TObject);
var
  PageItem: TItem;
  ProjectRoot, FullName, RelativeName, ContextText: string;
begin
  if (FChangesPanel = nil) or (not GetProjectSearchFolder(ProjectRoot)) then
  begin MessageHint('Abra um projeto antes de propor alterações.'); Exit; end;
  if (pgMain.ActivePage = nil) or (pgMain.ActivePage.Tag = 0) then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  FullName := IncludeTrailingPathDelimiter(PageItem.DirName) + PageItem.FileName;
  if (FullName = '') or (not FileExists(FullName)) then
  begin MessageHint('Salve o arquivo antes de solicitar uma proposta.'); Exit; end;
  if not PageItem.Salvo then SalvarTab(pgMain.ActivePage);
  RelativeName := ExtractRelativePath(IncludeTrailingPathDelimiter(ProjectRoot), FullName);
  ContextText := PageItem.syn.SelText;
  if ContextText = '' then ContextText := PageItem.syn.Text;
  FAIProposalDeveloperMessage := MNoteAI.BuildPrompt(
    'engenheiro de software que apenas propõe mudanças revisáveis',
    'propor uma correção segura para o arquivo informado',
    'não executar comandos; não usar markdown; não adicionar campos; caminhos relativos',
    'arquivo: ' + RelativeName + LineEnding + 'conteúdo/seleção:' + LineEnding + ContextText,
    '{"task_id":"","request":"","model":"","changes":[' +
    '{"kind":"exact_replace|line_range|new_file","file":"relativo",' +
    '"expected_text":"obrigatório para replace/linha","new_text":"",' +
    '"expected_count":1,"start_line":1,"end_line":1,"content":"novo arquivo"}]}');
  FPendingAIQuestion := 'Propor correção com IA para ' + RelativeName;
  FPendingAIInputWasVoice := False;
  FPendingAIProposal := True;
  FAIProposalRetryCount := 0;
  if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkAI);
  if not MNoteAI.SendAsync(FPendingAIQuestion, FAIProposalDeveloperMessage) then
  begin FPendingAIProposal := False; MessageHint(MNoteAI.LastError); end;
end;

procedure TfrmMNote.RetryAIChangeContract(Data: PtrInt);
begin
  if not FPendingAIProposal then Exit;
  if MNoteAI.IsBusy then
  begin Application.QueueAsyncCall(@RetryAIChangeContract, Data); Exit; end;
  if not MNoteAI.SendAsync(FAIProposalRetryQuestion,
    FAIProposalDeveloperMessage) then
  begin
    FPendingAIProposal := False;
    MessageHint(MNoteAI.LastError);
  end;
end;

procedure TfrmMNote.CommandAIStop(Sender: TObject);
begin
  MNoteAI.Cancel;
end;

procedure TfrmMNote.CommandAIProfiles(Sender: TObject);
begin
  with TfrmIAConfig.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmMNote.CommandAIComponentsLab(Sender: TObject);
begin
  if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkComponentsLab);
end;

procedure TfrmMNote.OpenInventoryFile(Sender: TObject;
  const AFileName: string);
begin
  OpenPaletteFile(AFileName);
end;

procedure TfrmMNote.AIStateChanged(Sender: TObject; AState: TMNoteAIState);
begin
  if FIDEShell <> nil then FIDEShell.SetAIState(MNoteAIStateName(AState));
end;

function TfrmMNote.ConfirmAIAction(Sender: TObject;
  ADescriptor: TMNoteAIActionDescriptor; AParameters: TJSONObject;
  out AReason: string): Boolean;
var
  Details: string;
begin
  AReason := '';
  if ADescriptor = nil then
  begin
    AReason := 'A ação solicitada não possui descritor válido.';
    Exit(False);
  end;
  if AParameters <> nil then Details := AParameters.FormatJSON
  else Details := '{}';
  Result := MessageDlg('Confirmar ação da IA',
    'A IA solicitou a ação real "' + ADescriptor.Name + '".' +
    LineEnding + 'Efeito: ' + MNoteAIActionEffectName(ADescriptor.Effect) +
    LineEnding + 'Parâmetros:' + LineEnding + Details + LineEnding +
    LineEnding + 'Deseja executar?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
  if not Result then AReason := 'A ação foi recusada pelo usuário.';
end;

procedure TfrmMNote.AISessionChanged(Sender: TObject);
var
  Step: TMNoteAISessionStep;
begin
  if FChatMemoryMapPanel <> nil then FChatMemoryMapPanel.RefreshMap;
  if FAIMonitorPanel <> nil then FAIMonitorPanel.Refresh;
  if (FOutputPanel <> nil) and (MNoteAI.Session.Count > 0) then
  begin
    Step := MNoteAI.Session[MNoteAI.Session.Count - 1];
    FOutputPanel.Add(mocAgent, Format('%d. %s — %s — %d ms',
      [Step.Order, MNoteAIRoleName(Step.Role), Step.Status, Step.LatencyMS]) +
      LineEnding);
  end;
end;

procedure TfrmMNote.AICompleted(Sender: TObject; ASuccess: Boolean;
  const AResponse, AError: string);
var
  ResponseText: string;
  SQLText, SQLValidationError, SQLProtocol: string;
  ChangeSet: TAISourceChangeSet;
  ContractError: string;
  SQLValidator: TMNoteSQLValidationService;
  SQLPage: TTabSheet;
  GeneratedItem: TItem;
  PlanError, UnderstandingJSON, Questions: string;
  PlanReady: Boolean;
begin
  ResponseText := AResponse;
  if (not ASuccess) and (Trim(ResponseText) = '') then ResponseText := AError;
  if Trim(ResponseText) = '' then
    ResponseText := 'A operação terminou sem resposta.';
  if FPendingPlanGeneration then
  begin
    FPendingPlanGeneration := False;
    if not ASuccess then
    begin
      PresentAIResponse(ResponseText, False);
      Exit;
    end;
    if Pos('PLANNING_NEEDS_INFORMATION' + LineEnding, AResponse) = 1 then
    begin
      UnderstandingJSON := Copy(AResponse,
        Length('PLANNING_NEEDS_INFORMATION' + LineEnding) + 1, MaxInt);
      if TMNoteAIPlanContract.ValidateUnderstanding(UnderstandingJSON,
        PlanReady, Questions, PlanError) then
        PresentAIResponse('A IA de Gestão interrompeu o planejamento para confirmar:' +
          LineEnding + Questions + LineEnding + LineEnding + UnderstandingJSON, True)
      else
        PresentAIResponse('A etapa Entender retornou um contrato inválido: ' +
          PlanError + LineEnding + UnderstandingJSON, False);
      Exit;
    end;
    if FTasksPanel.ReviewAndApplyPlan(AResponse, FPendingPlanInput,
      FPendingPlanRevision, PlanError) then
      PresentAIResponse('Plano revisado e salvo após sua confirmação.', True)
    else
      PresentAIResponse(PlanError + LineEnding + LineEnding + AResponse,
        Pos('cancelado pelo usuário', LowerCase(PlanError)) > 0);
    Exit;
  end;
  if FPendingSQLGeneration then
  begin
    FPendingSQLGeneration := False;
    if not ASuccess then
    begin
      PresentAIResponse(ResponseText, False);
      Exit;
    end;
    SQLText := TMNoteSQLValidationService.StripMarkdown(AResponse);
    SQLProtocol := 'generic';
    if (frmmquery2 <> nil) and frmmquery2.zconpost.Connected then
      SQLProtocol := frmmquery2.zconpost.Protocol
    else if (frmmquery2 <> nil) and frmmquery2.zconsqlite.Connected then
      SQLProtocol := frmmquery2.zconsqlite.Protocol;
    SQLValidator := TMNoteSQLValidationService.Create;
    try
      if not SQLValidator.ValidatePlaceholders(SQLText, SQLProtocol) then
      begin
        PresentAIResponse('O SQL proposto foi recusado pela validação local: ' +
          SQLValidator.LastError + LineEnding + LineEnding + AResponse, False);
        Exit;
      end;
      if ((UpperCase(Copy(Trim(SQLText), 1, 6)) = 'SELECT') or
          (UpperCase(Copy(Trim(SQLText), 1, 4)) = 'WITH')) and
        (frmmquery2 <> nil) then
      begin
        if frmmquery2.zconpost.Connected then
          SQLValidator.ValidateWithExplain(frmmquery2.zconpost, SQLText)
        else if frmmquery2.zconsqlite.Connected then
          SQLValidator.ValidateWithExplain(frmmquery2.zconsqlite, SQLText);
        SQLValidationError := SQLValidator.LastError;
        if SQLValidationError <> '' then
        begin
          PresentAIResponse('O SQL proposto não passou no EXPLAIN: ' +
            SQLValidationError + LineEnding + LineEnding + SQLText, False);
          Exit;
        end;
      end;
    finally
      SQLValidator.Free;
    end;
    if not ShowConfirm('SQL validado e não executado. Abrir em uma nova aba para revisão?') then
    begin
      PresentAIResponse(SQLText, True);
      Exit;
    end;
    SQLPage := NovoItem;
    GeneratedItem := TItem(SQLPage.Tag);
    GeneratedItem.FileExt := '.sql';
    GeneratedItem.syn.Text := SQLText;
    SQLPage.Caption := 'SQL gerado (não executado)';
    PresentAIResponse('SQL validado e transferido para uma nova aba. Nada foi executado.', True);
    Exit;
  end;
  if FPendingAIProposal then
  begin
    if ASuccess and TMNoteAIChangeContract.Parse(AResponse,
      FChangesPanel.Manager, ChangeSet, ContractError) then
    begin
      FPendingAIProposal := False;
      FChangesPanel.Present(ChangeSet);
      if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkChanges);
      PresentAIResponse('Proposta estruturada validada. Revise o diff em Changes; nenhum arquivo foi alterado.', True);
      Exit;
    end;
    if ASuccess and TMNoteAIChangeContract.MayRetry(aceInvalidContract,
      FAIProposalRetryCount) then
    begin
      Inc(FAIProposalRetryCount);
      FAIProposalRetryQuestion := 'Corrija somente o contrato JSON. Erro: ' +
        ContractError + LineEnding + 'Resposta inválida anterior:' + LineEnding +
        AResponse;
      Application.QueueAsyncCall(@RetryAIChangeContract, 0);
      Exit;
    end;
    FPendingAIProposal := False;
    if ASuccess then
    begin
      ResponseText := 'Contrato inválido: ' + ContractError +
        LineEnding + LineEnding + 'Resposta bruta:' + LineEnding + AResponse;
      ASuccess := False;
    end;
  end;
  PresentAIResponse(ResponseText, ASuccess);
end;

procedure TfrmMNote.PresentAIResponse(const AResponse: string;
  ASuccess: Boolean);
var
  CodeBlocks: TCodigo;
  CodeItem: TFonte;
  I: Integer;
begin
  if FOutputPanel <> nil then
    FOutputPanel.SetText(mocAI, AResponse);
  meChatHist.Lines.Add('');
  meChatHist.Lines.Add('Question: ' + FPendingAIQuestion);
  meChatHist.Lines.Add('Response: ' + AResponse);
  meDialog.Lines.Clear;
  meDialog.Lines.Add('Question: ' + FPendingAIQuestion);
  meDialog.Lines.Add('Response: ' + AResponse);
  meCodes.Lines.Clear;
  if ASuccess then
  begin
    CodeBlocks := TCodigo.Create;
    try
      CodeBlocks.AnalisaTexto(AResponse);
      for I := 0 to CodeBlocks.Count - 1 do
      begin
        CodeItem := TFonte(CodeBlocks.Items[I]);
        meCodes.Lines.Add(CodeItem.codigo);
        meCodes.Lines.Add('');
      end;
    finally
      CodeBlocks.Free;
    end;
  end;
  if FPendingAIInputWasVoice and ASuccess then SpeakAIResponse(AResponse);
  edChat.Clear;
end;

procedure TfrmMNote.SpeakAIResponse(const AResponse: string);
begin
  if not MNoteVoiceOutput.Speak(AResponse) and
    FSetMain.VoiceOutputEnabled then
    MessageHint('Voice Output: ' + MNoteVoiceOutput.LastError);
end;

procedure TfrmMNote.VoiceCommandReceived(Sender: TObject;
  const ACommand: string);
begin
  if Trim(ACommand) = '' then
  begin
    SpeakAIResponse('Estou ouvindo.');
    Exit;
  end;
  edChat.Text := ACommand;
  FPendingAIInputWasVoice := True;
  QuestionChat;
end;

procedure TfrmMNote.CollectPaletteFiles(AFiles: TStrings);
var
  PageIndex: Integer;
  PageItem: TItem;
  FullName: string;
begin
  for PageIndex := 0 to pgMain.PageCount - 1 do
  begin
    PageItem := TItem(pgMain.Pages[PageIndex].Tag);
    if (PageItem = nil) or (PageItem.FileName = '') then Continue;
    FullName := IncludeTrailingPathDelimiter(PageItem.DirName) +
      PageItem.FileName;
    if AFiles.IndexOf(FullName) < 0 then
      AFiles.Add(FullName);
  end;
end;

procedure TfrmMNote.OpenPaletteFile(const AFileName: string);
begin
  if not FocusFile(AFileName) then
    LoadArquivo(AFileName);
end;

procedure TfrmMNote.CollectSearchDocuments(
  ADocuments: TMNoteSearchDocuments);
var
  PageIndex: Integer;
  PageItem: TItem;
  FullName: string;
begin
  for PageIndex := 0 to pgMain.PageCount - 1 do
  begin
    PageItem := TItem(pgMain.Pages[PageIndex].Tag);
    if PageItem = nil then Continue;
    FullName := PageItem.FileName;
    if PageItem.DirName <> '' then
      FullName := IncludeTrailingPathDelimiter(PageItem.DirName) +
        PageItem.FileName;
    if FullName = '' then
      FullName := pgMain.Pages[PageIndex].Caption;
    ADocuments.Add(TMNoteSearchDocument.Create(FullName,
      PageItem.syn.Text));
  end;
end;

procedure TfrmMNote.NavigateSearchResult(const AFileName: string;
  ALine, AColumn, ALength: Integer);
var
  PageItem: TItem;
begin
  if (AFileName <> '') and (not FocusFile(AFileName)) and
    FileExists(AFileName) then
    LoadArquivo(AFileName);
  if (pgMain.ActivePage = nil) or (pgMain.ActivePage.Tag = 0) then Exit;
  PageItem := TItem(pgMain.ActivePage.Tag);
  PageItem.syn.SetFocus;
  ActiveControl := PageItem.syn;
  PageItem.syn.CaretXY := Point(AColumn, ALine);
  PageItem.syn.BlockBegin := Point(AColumn, ALine);
  PageItem.syn.BlockEnd := Point(AColumn + ALength, ALine);
end;

function TfrmMNote.GetProjectSearchFolder(out AFolder: string): Boolean;
begin
  AFolder := '';
  if FProjectContext <> nil then
  begin
    if FProjectContext.IsOpen then AFolder := FProjectContext.RootPath;
    Exit(FProjectContext.IsOpen and DirectoryExists(AFolder));
  end;
  if FSetMain = nil then Exit(False);
  if Trim(FSetMain.Project) <> '' then
  begin
    if DirectoryExists(FSetMain.Project) then
      AFolder := ExpandFileName(FSetMain.Project)
    else
      AFolder := ExpandFileName(ExtractFileDir(FSetMain.Project));
  end
  else if DirectoryExists(FSetMain.Defaultfolder) then
    AFolder := ExpandFileName(FSetMain.Defaultfolder)
  else if (pgMain.ActivePage <> nil) and (pgMain.ActivePage.Tag <> 0) then
    AFolder := TItem(pgMain.ActivePage.Tag).DirName;
  Result := DirectoryExists(AFolder);
end;

function TfrmMNote.ActivateProject(const APath: string;
  APersist: Boolean): Boolean;
begin
  Result := False;
  if FProjectContext = nil then
    FProjectContext := TMNoteProjectContext.Create;
  if not FProjectContext.Open(APath) then
  begin
    MessageHint(FProjectContext.LastError);
    Exit;
  end;
  FSetMain.Project := FProjectContext.PreferredPath;
  FSetMain.Defaultfolder := FProjectContext.RootPath;
  if APersist then FSetMain.SalvaContexto(False);
  RefreshProjectIntegration;
  Result := True;
end;

procedure TfrmMNote.RefreshProjectIntegration;
var
  Root, ProjectDisplayName: string;
begin
  if (FProjectContext = nil) or not FProjectContext.IsOpen then Exit;
  Root := FProjectContext.RootPath;
  ProjectDisplayName := FProjectContext.DisplayName;
  if ProjetoDB <> nil then FreeAndNil(ProjetoDB);
  if (FProjectContext.Kind = mpkLegacyDatabase) and
    FileExists(FProjectContext.ProjectFile) then
  begin
    ProjetoDB := TProjetoDB.Create(Self);
    ProjetoDB.CarregarProjeto(FProjectContext.ProjectFile,
      ProjectSQLiteLibraryPath);
  end;
  MNoteAI.SetProjectRoot(Root);
  if FSolutionExplorer <> nil then
    FSolutionExplorer.SetProject(Root, ProjectDisplayName,
      FProjectContext.ProjectFile,
      FProjectContext.Kind);
  RefreshSolutionDatabase;
  if FFilesPanel <> nil then FFilesPanel.SetProjectRoot(Root);
  if FComponentsLabPanel <> nil then FComponentsLabPanel.SetProjectRoot(Root);
  if FTerminalPanel <> nil then FTerminalPanel.SetWorkingDirectory(Root);
  if FTasksPanel <> nil then FTasksPanel.OpenProject(Root, ProjectDisplayName);
  if FTaskListPanel <> nil then
    FTaskListPanel.Scan(Root);
  if FChangesPanel <> nil then FChangesPanel.SetProjectRoot(Root);
  MNoteProjectSymbols.Clear;
  InitializeProjectSymbolIndex;
  UpdateIDEStatus;
  if FIDEShell <> nil then FIDEShell.ShowToolWindow(twkSolution);
  MessageHint('Projeto ativo: ' + ProjectDisplayName);
end;

procedure TfrmMNote.CommandProjectNew(Sender: TObject);
var
  Dialog: TSelectDirectoryDialog;
  Location, ProjectName, Description: string;
begin
  Dialog := TSelectDirectoryDialog.Create(Self);
  try
    Dialog.Title := 'Localização do novo projeto';
    if DirectoryExists(FSetMain.Defaultfolder) then
      Dialog.InitialDir := FSetMain.Defaultfolder;
    if not Dialog.Execute then Exit;
    Location := Dialog.FileName;
  finally
    Dialog.Free;
  end;
  ProjectName := '';
  if not InputQuery('Novo projeto', 'Nome do projeto:', ProjectName) then Exit;
  Description := '';
  if not InputQuery('Novo projeto', 'Descrição (opcional):', Description) then
    Exit;
  if FProjectContext = nil then
    FProjectContext := TMNoteProjectContext.Create;
  if not FProjectContext.CreateNew(Location, ProjectName, Description, True) then
  begin
    MessageHint(FProjectContext.LastError);
    Exit;
  end;
  FSetMain.Project := FProjectContext.PreferredPath;
  FSetMain.Defaultfolder := FProjectContext.RootPath;
  FSetMain.SalvaContexto(False);
  RefreshProjectIntegration;
end;

procedure TfrmMNote.CommandProjectOpen(Sender: TObject);
var
  Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(Self);
  try
    Dialog.Title := 'Abrir projeto';
    Dialog.Filter := 'Projetos MNote2/Lazarus (*.mnoteproj.json;*.lpi;*.lpr;*.db)|'+
      '*.mnoteproj.json;*.lpi;*.lpr;*.db|Todos os arquivos (*.*)|*.*';
    if DirectoryExists(FSetMain.Defaultfolder) then
      Dialog.InitialDir := FSetMain.Defaultfolder;
    if Dialog.Execute then ActivateProject(Dialog.FileName, True);
  finally
    Dialog.Free;
  end;
end;

procedure TfrmMNote.CommandProjectOpenFolder(Sender: TObject);
var
  Dialog: TSelectDirectoryDialog;
begin
  Dialog := TSelectDirectoryDialog.Create(Self);
  try
    Dialog.Title := 'Abrir pasta como projeto';
    if DirectoryExists(FSetMain.Defaultfolder) then
      Dialog.InitialDir := FSetMain.Defaultfolder;
    if Dialog.Execute then ActivateProject(Dialog.FileName, True);
  finally
    Dialog.Free;
  end;
end;

procedure TfrmMNote.CommandProjectClose(Sender: TObject);
begin
  if (FProjectContext = nil) or not FProjectContext.IsOpen then Exit;
  if MessageDlg('Fechar projeto', 'Fechar o projeto ativo? Os documentos '+
    'abertos permanecerão no editor.', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then Exit;
  FProjectContext.Close;
  FSetMain.Project := '';
  FSetMain.SalvaContexto(False);
  MNoteProjectSymbols.Clear;
  MNoteAI.SetProjectRoot(GetCurrentDir);
  if FSolutionExplorer <> nil then FSolutionExplorer.ClearProject;
  if FFilesPanel <> nil then FFilesPanel.SetProjectRoot('');
  if FComponentsLabPanel <> nil then FComponentsLabPanel.SetProjectRoot('');
  if FTerminalPanel <> nil then FTerminalPanel.SetWorkingDirectory('');
  if FTasksPanel <> nil then FTasksPanel.CloseProject;
  if FTaskListPanel <> nil then FTaskListPanel.Scan('');
  if FChangesPanel <> nil then FChangesPanel.SetProjectRoot('');
  if ProjetoDB <> nil then FreeAndNil(ProjetoDB);
  UpdateIDEStatus;
end;

procedure TfrmMNote.CommandProjectSave(Sender: TObject);
begin
  if (FTasksPanel = nil) or (FProjectContext = nil) or
    not FProjectContext.IsOpen then
  begin
    MessageHint('Nenhum projeto aberto.');
    Exit;
  end;
  if FTasksPanel.Service.Save then
    MessageHint('Projeto salvo.')
  else MessageHint(FTasksPanel.Service.LastError);
end;

procedure TfrmMNote.CommandProjectRefresh(Sender: TObject);
begin
  if FSolutionExplorer <> nil then FSolutionExplorer.Refresh;
  RefreshSolutionDatabase;
  if FFilesPanel <> nil then FFilesPanel.Refresh;
  if FTaskListPanel <> nil then
  begin
    if (FProjectContext <> nil) and FProjectContext.IsOpen then
      FTaskListPanel.Scan(FProjectContext.RootPath);
  end;
  MNoteProjectSymbols.Clear;
  InitializeProjectSymbolIndex;
end;

procedure TfrmMNote.ShowProjectProperties(Sender: TObject);
begin
  if (FProjectContext = nil) or not FProjectContext.IsOpen then
  begin
    MessageHint('Nenhum projeto aberto.');
    Exit;
  end;
  MessageDlg('Propriedades do projeto',
    'Nome: ' + FProjectContext.DisplayName + LineEnding +
    'Tipo: ' + MNoteProjectKindName(FProjectContext.Kind) + LineEnding +
    'Pasta: ' + FProjectContext.RootPath + LineEnding +
    'Arquivo: ' + FProjectContext.ProjectFile,
    mtInformation, [mbOK], 0);
end;

function TfrmMNote.ProjectSQLiteLibraryPath: string;
var
  BasePath: string;
begin
  BasePath := ExtractFileDir(Application.ExeName);
  {$IFDEF WINDOWS}
  if Pos('\src', LowerCase(BasePath)) > 0 then
    Result := ExpandFileName(BasePath + '\..\libs\sqlite\win32\sqlite3.dll')
  else Result := BasePath + '\libs\sqlite\win32\sqlite3.dll';
  {$ENDIF}
  {$IFDEF LINUX}
  Result := IncludeTrailingPathDelimiter(BasePath) +
    'libs/linux64/libsqlite3.so';
  {$ENDIF}
end;

procedure TfrmMNote.InitializeThemeMenu;
const
  ThemeNames: array[0..2] of string = ('Light', 'Dark', 'Blue');
var
  I: Integer;
begin
  FThemeMenu := TMenuItem.Create(Self);
  FThemeMenu.Caption := 'Theme';
  MainMenu1.Items.Add(FThemeMenu);
  for I := Low(FThemeItems) to High(FThemeItems) do
  begin
    FThemeItems[I] := TMenuItem.Create(Self);
    FThemeItems[I].Caption := ThemeNames[I];
    FThemeItems[I].RadioItem := True;
    FThemeItems[I].GroupIndex := 42;
    FThemeItems[I].AutoCheck := False;
    FThemeItems[I].Tag := I;
    FThemeItems[I].OnClick := @ThemeMenuClick;
    FThemeMenu.Add(FThemeItems[I]);
  end;
end;

procedure TfrmMNote.ThemeMenuClick(Sender: TObject);
begin
  ApplyTheme(TMenuItem(Sender).Caption);
end;

function TfrmMNote.ThemeFilePath(const AThemeName: string): string;
var
  ThemeFile: string;
begin
  ThemeFile := LowerCase(AThemeName) + '.json';
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
    'themes' + PathDelim + ThemeFile;
  if FileExists(Result) then Exit;
  Result := ExpandFileName(IncludeTrailingPathDelimiter(
    ExtractFilePath(Application.ExeName)) + '..' + PathDelim + 'themes' +
    PathDelim + ThemeFile);
  if FileExists(Result) then Exit;
  Result := ExpandFileName('themes' + PathDelim + ThemeFile);
end;

procedure TfrmMNote.ApplyTheme(const AThemeName: string);
var
  I: Integer;
  ThemeName: string;
begin
  if FThemeService = nil then Exit;
  ThemeName := AThemeName;
  if Trim(ThemeName) = '' then ThemeName := 'Light';
  if not FThemeService.LoadFromFile(ThemeFilePath(ThemeName)) then
    ThemeName := 'Light';
  FSetMain.EditorTheme := ThemeName;
  for I := Low(FThemeItems) to High(FThemeItems) do
    FThemeItems[I].Checked := SameText(FThemeItems[I].Caption, ThemeName);
  ApplyThemeToAll;
end;

procedure TfrmMNote.ApplyThemeToAll;
var
  I: Integer;
  PageItem: TItem;
begin
  if FThemeService = nil then Exit;
  for I := 0 to pgMain.PageCount - 1 do
  begin
    PageItem := TItem(pgMain.Pages[I].Tag);
    if (PageItem = nil) or (PageItem.syn = nil) then Continue;
    TMNoteThemeApplier.Apply(PageItem.syn, FThemeService.Current);
    PageItem.syn.Font := FSetMain.Font;
    if FSetMain.EditorTabWidth > 0 then
      PageItem.syn.TabWidth := FSetMain.EditorTabWidth;
    if FSetMain.EditorShowSpaces then
      PageItem.syn.VisibleSpecialChars :=
        [vscSpace, vscTabAtFirst, vscTabAtLast]
    else
      PageItem.syn.VisibleSpecialChars := [];
    if PageItem.syn.Gutter.LineNumberPart <> nil then
      PageItem.syn.Gutter.LineNumberPart.Visible :=
        FSetMain.EditorShowLineNumbers;
  end;
end;

procedure TfrmMNote.FormCreate(Sender: TObject);
var
   filename: string;
   plataforma: string;
   biblioteca : string;
   basePath : string;
   ProjectRoot, ProjectName: string;
   ChatMemoryTab: TTabSheet;
begin
  LimpaEventosLog;
  RegistraEventosLog('========================================');
  RegistraEventosLog('=== INICIANDO MNOTE2 ===');
  {$IFDEF MSWINDOWS}
    plataforma := 'Windows ';
  {$ENDIF}
  {$IFDEF LINUX}
    plataforma := 'Linux ';
  {$ENDIF}

  {$IFDEF CPU64}
    plataforma := plataforma + '64 bits';
  {$ELSE}
    plataforma := plataforma + '32 bits';
  {$ENDIF}

  frmSplash := TfrmSplash.Create(self);
  frmSplash.lbversao.Caption := MNOTE_APP_VERSION + ' - ' + plataforma;
  frmSplash.ShowAnimated;

  filename := extractfilename(application.ExeName);
  if IsRun(filename) then
  begin
    if KillAppByName(filename) then
      MessageHint('Assumindo funções MNote anterior!');
  end;

  frmSplash.UpdateStatus('Carregando preferências e projeto...', 28);

  if (FSetMain = nil) then
    FsetMain := TsetMain.Create();

  FProjectContext := TMNoteProjectContext.Create;
  if (Trim(FSetMain.Project) <> '') and
    (not FProjectContext.Open(FSetMain.Project)) then
    FProjectContext.Close;

  FThemeService := TMNoteEditorThemeService.Create;
  InitializeCommands;
  FPythonService := TMNotePythonService.Create(Self);

  frmSplash.UpdateStatus('Montando o ambiente de desenvolvimento...', 46);

  Panel4.Align := alClient;
  pnChatGPT.Visible := False;
  pnResult.Visible := False;
  Splitter1.Visible := False;
  Splitter2.Visible := False;
  Splitter3.Visible := False;
  FIDEShell := TMNoteIDEShell.Create(Self);
  FIDEShell.Initialize(Panel4, pnclient, pgMain, pnChatGPT2, pnInspector,
    lstFind, meResult, MainMenu1);
  FSolutionExplorer := TMNoteSolutionExplorerPanel.Create(Self);
  FSolutionExplorer.OnOpenFile := @OpenInventoryFile;
  FSolutionExplorer.OnNewProject := @CommandProjectNew;
  FSolutionExplorer.OnOpenProject := @CommandProjectOpen;
  FSolutionExplorer.OnOpenFolder := @CommandProjectOpenFolder;
  FSolutionExplorer.OnProjectProperties := @ShowProjectProperties;
  FSolutionExplorer.Initialize(FIDEShell.SolutionPage);
  FOutputPanel := TMNoteOutputPanel.Create(Self);
  FOutputPanel.Initialize(FIDEShell.OutputPage, meResult);
  FProblemsPanel := TMNoteProblemsPanel.Create(Self);
  FProblemsPanel.OnNavigate := @NavigateSearchResult;
  FProblemsPanel.Initialize(FIDEShell.ProblemsPage, FIDEShell.ProblemsList);
  FBuildService := TMNoteBuildService.Create;
  FBuildService.OnOutput := @BuildOutput;
  FBuildService.OnCompleted := @BuildCompleted;
  FNeuralApiBootstrap := TMNoteNeuralApiBootstrap.Create;
  FNeuralApiBootstrap.OnCompleted := @NeuralApiBootstrapCompleted;
  FAIMonitorPanel := TMNoteAIMonitorPanel.Create(Self);
  FAIMonitorPanel.Initialize(FIDEShell.MonitorPage, MNoteAI);
  FDBDictionaryPanel := TMNoteDBDictionaryPanel.Create(Self);
  FDBDictionaryPanel.OnGenerateRequested := @GenerateDataDictionary;
  FDBDictionaryPanel.OnUseAIRequested := @AskDatabaseAI;
  FDBDictionaryPanel.OnGenerateSQLRequested := @GenerateDatabaseSQL;
  FDBDictionaryPanel.Initialize(FIDEShell.DatabasePage);
  MNoteAI.OnStateChanged := @AIStateChanged;
  MNoteAI.OnCompleted := @AICompleted;
  MNoteAI.OnSessionChanged := @AISessionChanged;
  MNoteAI.OnActionConfirm := @ConfirmAIAction;
  ChatMemoryTab := TTabSheet.Create(PageControl1);
  ChatMemoryTab.PageControl := PageControl1;
  ChatMemoryTab.Caption := 'Mapa de memória';
  FChatMemoryMapPanel := TMNoteMemoryMapPanel.Create(Self);
  FChatMemoryMapPanel.Parent := ChatMemoryTab;
  FChatMemoryMapPanel.SetMemoryMap(MNoteAI.SessionMemory);
  FCommandPalette := TMNoteCommandPalette.Create(Self);
  FCommandPalette.OnCollectFiles := @CollectPaletteFiles;
  FCommandPalette.OnOpenFile := @OpenPaletteFile;
  FCommandPalette.Initialize(Panel1, MainMenu1, FCommandRegistry);
  FLanguageToolbar := TMNoteLanguageToolbar.Create(Self);
  FLanguageToolbar.Initialize(Panel1, FCommandRegistry);
  FSearchPanel := TMNoteSearchPanel.Create(Self);
  FSearchPanel.OnCollectDocuments := @CollectSearchDocuments;
  FSearchPanel.OnNavigate := @NavigateSearchResult;
  FSearchPanel.OnGetProjectFolder := @GetProjectSearchFolder;
  FSearchPanel.Initialize(Panel4, MainMenu1, FIDEShell.SearchResultsList);
  ProjectRoot := '';
  if FProjectContext.IsOpen then ProjectRoot := FProjectContext.RootPath;
  if ProjectRoot <> '' then MNoteAI.SetProjectRoot(ProjectRoot)
  else MNoteAI.SetProjectRoot(GetCurrentDir);
  FFilesPanel := TMNoteFilesPanel.Create(Self);
  FFilesPanel.OnOpenFile := @OpenInventoryFile;
  FFilesPanel.Initialize(FIDEShell.FilesPage, ProjectRoot,
    FSetMain.UseAIDiskScanner);
  FComponentsLabPanel := TMNoteComponentsLabPanel.Create(Self);
  FComponentsLabPanel.Initialize(FIDEShell.ComponentsLabPage, ProjectRoot,
    FSetMain.ToolsOuvir or FSetMain.ToolsFalar);
  FTerminalPanel := TMNoteTerminalPanel.Create(Self);
  FTerminalPanel.Initialize(FIDEShell.TerminalPage, ProjectRoot);
  if FProjectContext.IsOpen then ProjectName := FProjectContext.DisplayName
  else ProjectName := '';
  FTasksPanel := TMNoteTasksPanel.Create(Self);
  FTasksPanel.Initialize(FIDEShell.TasksPage, ProjectRoot, ProjectName);
  FTasksPanel.OnPlanRequested := @ProjectPlanRequested;
  FTasksPanel.OnOpenFile := @OpenTaskFile;
  FTasksPanel.OnOpenCommit := @OpenTaskCommit;
  FTaskListPanel := TMNoteTaskListPanel.Create(Self);
  FTaskListPanel.OnNavigate := @NavigateSearchResult;
  FTaskListPanel.OnTaskCreated := @ProjectTaskCreated;
  FTaskListPanel.Initialize(FIDEShell.TaskList, FTasksPanel.Service);
  FTaskListPanel.Scan(ProjectRoot);
  FChangesPanel := TMNoteChangesPanel.Create(Self);
  FChangesPanel.Initialize(FIDEShell.ChangesPage, ProjectRoot);
  FChangesPanel.OnApplied := @ChangesApplied;
  frmSplash.UpdateStatus('Restaurando painéis e ferramentas...', 72);
  if FProjectContext.IsOpen then
    FSolutionExplorer.SetProject(ProjectRoot, ProjectName,
      FProjectContext.ProjectFile, FProjectContext.Kind)
  else FSolutionExplorer.ClearProject;
  InitializeProjectSymbolIndex;
  InitializeThemeMenu;
  ApplyTheme(FSetMain.EditorTheme);
  FIDEShell.ApplyLayout(FSetMain.IDELeftWidth, FSetMain.IDERightWidth,
    FSetMain.IDEBottomHeight, FSetMain.IDELeftVisible,
    FSetMain.IDERightVisible, FSetMain.IDEBottomVisible,
    FSetMain.IDELeftTab, FSetMain.IDERightTab, FSetMain.IDEBottomTab);

  basePath := ExtractFileDir(Application.ExeName);
  {$IFDEF WINDOWS}
  if (Pos('\src', basePath) > 0) then
    biblioteca := basePath + '\..\libs\sqlite\win32\sqlite3.dll'
  else
    biblioteca := basePath + '\libs\sqlite\win32\sqlite3.dll';
  {$ENDIF}

  {$IFDEF LINUX}
  biblioteca := basePath + 'libs/linux64/libsqlite3.so';
  {$ENDIF}

  if (FSetMain.Project <> '') and
    SameText(ExtractFileExt(FSetMain.Project), '.db') then
  begin
     ProjetoDB := TProjetoDB.create(self);
     ProjetoDB.CarregarProjeto(FSetMain.Project,biblioteca);
     try
       RestaurarWorkspaceState;
     except
       // Silencia erros para nao interromper a carga inicial da IDE
     end;
  end;

  if(frmHint= nil) then
    frmHint := TfrmHint.create(self);

  frmSplash.UpdateStatus('Aplicando configurações do usuário...', 88);
  CarregaContexto();

  if(frmIA=nil) then
    frmIA := TfrmIA.create(self);

  {$ifdef Darwin}
  {$else}
  {$endif}

  CarregarOld();
  CarregarParametros();
  ApplyThemeToAll;
  MNoteBuildProfessionalIcons(ImageList1);
  FIDEShell.ApplyIcons(ImageList1);
  MNoteApplyMenuIcons(MainMenu1);
  MNoteApplyVisualIdentity(Self);

  frmSplash.UpdateStatus('Finalizando a inicialização...', 96);
  (*
  try
    RegistraEventosLog('Startup: Instanciando frmRegistrar e executando Identifica...');
    frmRegistrar := TfrmRegistrar.Create(self);
    frmRegistrar.Identifica();
  except
    on E: Exception do
      RegistraEventosLog('Startup [AVISO]: Excecao no registro/SSL isolada com sucesso: ' + E.Message);
  end;
  *)
  RegistraEventosLog('Startup [OK]: Inicializacao da IDE concluida com sucesso (' + plataforma + ')');

end;

procedure TfrmMNote.CarregaContexto();
begin
  FSetMain.CarregaContexto();
  Left:= FsetMain.posx;
  top:= FSetMain.posy;
  Width:=   FSetMain.width;
  Height:= FSetMain.Height;
  if FSetMain.stay then
  begin
    FormStyle:= fsStayOnTop;
    mnStay.Caption:='Normal';
    mnOnTopW.Caption:='Normal';
  end
  else
  begin
    FormStyle:= fsNormal;
    mnStay.Caption:='On Top';
    mnOnTopW.Caption:='On Top';
  end;
  if not FSetMain.fixar then
  begin
    BorderStyle:=bsSizeable;
    mnFixar.Caption:='Fix';
    mnFixW.Caption:='Fix';
  end
  else
  begin
    BorderStyle:=bsSingle;
    mnFixar.Caption:= 'Move';
    mnFixW.caption := 'Move' ;
  end;
end;

procedure TfrmMNote.AssociarExtensao(item: Titem);
var
   arquivo: string;
   ext : string;
begin
   ext := ExtractFileExt(item.FileName);
   arquivo := Application.ExeName;

   if not (ext = '') then
   begin
        ext := copy(ext,2,Length(ext));
        {$ifdef WINDOWS}
        if IsAdministrator then
        begin
          if not VerificaRegExt(ext) then
          begin
             if ShowConfirm('Associa extensão '+ext + ' a aplicação!') then
             begin
                  if  RegistrarExtensao(  ExtractFileExt(application.ExeName), 'Aplicativo de edição de texto', ExtractFileName(application.ExeName), Application.ExeName) then
                  begin
                  end
                  else
                  begin
                  end;
             end;
          end;
        end
        else
        begin
        end;
        {$endif}
   end;
end;

procedure TfrmMNote.mnStayClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
  begin
    FormStyle:= fsStayOnTop;
    Fsetmain.stay := true;
    mnStay.Caption:='Normal';
    mnOnTopW.Caption:='Normal';
  end
  else
  begin
    FormStyle:=fsNormal;
    Fsetmain.stay := false;
    mnStay.Caption:='On Top';
    mnOnTopW.Caption:='On Top';
  end;
  refresh;
  Fsetmain.SalvaContexto(false);
end;

function TfrmMNote.Mudou(): boolean;
var
   a : integer;
   resultado : boolean;
   syn : TSynEdit;
   item : TItem;
   tb :TTabSheet;
begin
   resultado := true;
   for a := 0 to pgMain.PageCount-1 do
   begin
      tb := pgMain.Pages[a];
      item := TItem(tb.tag);
      syn := item.syn;
      resultado :=  resultado and  item.Salvo;
   end;
   result := resultado;
end;

function TfrmMNote.PerguntaSalvar(): boolean;
var
   reply, BOXStyle : integer;
   resultado : boolean;
begin
   resultado := false;
   BoxStyle := MB_ICONQuestion + MB_YESNO;
   Reply := Application.MessageBox('Do you want to save the files?', 'Confirm', BOXStyle);
   if Reply = IDYES then
     resultado := true;
   result := resultado;
end;

procedure TfrmMNote.SalvarTudo();
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   a : integer;
begin
   for a := 0 to pgMain.PageCount-1 do
   begin
      tb := pgMain.Pages[a];
      item := TItem(tb.tag);
      syn := item.syn;
      if not(item.Salvo) then
        SalvarTab(tb);
   end;
end;

procedure TfrmMNote.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  try
    SalvarWorkspaceState;
  except
    // Silencia erros no fechamento para garantir encerramento limpo
  end;

  if not Mudou() then
  begin
    if PerguntaSalvar() then
      SalvarTudo();
  end;
  CloseAction:= caFree;
end;

procedure TfrmMNote.FindDialog1Find(Sender: TObject);
begin
  if FSearchPanel <> nil then
    FSearchPanel.ShowFind;
end;

procedure TfrmMNote.AplicarEstilo(SynEdit: TSynEdit; StartLine, EndLine: Integer);
var
  i: Integer;
  TempAttr: TSynHighlighterAttributes;
begin
  TempAttr := TSynHighlighterAttributes.Create('TempHighlight', '');
  try
    TempAttr.Background := clBlack;
    TempAttr.Foreground := clWhite;
    TempAttr.Style := [];
    for i := StartLine to EndLine do
    begin
      // exemplo conceitual
    end;
  finally
    TempAttr.Free;
  end;
end;

procedure TfrmMNote.AnalisarSynEdit(SynEdit: TSynEdit);
var
  StartPos, EndPos: Integer;
  InCodeBlock: Boolean;
  i: Integer;
  Line: string;
begin
  InCodeBlock := False;
  StartPos := -1;
  EndPos := -1;

  for i := 0 to SynEdit.Lines.Count - 1 do
  begin
    Line := SynEdit.Lines[i];

    if Pos('```', Line) > 0 then
    begin
      if not InCodeBlock then
      begin
        StartPos := i;
        InCodeBlock := True;
      end
      else
      begin
        EndPos := i;
        InCodeBlock := False;
        AplicarEstilo(SynEdit, StartPos, EndPos);
        StartPos := -1;
        EndPos := -1;
      end;
    end;
  end;
end;

procedure TfrmMNote.edChatKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    FazPergunta;
  end;
end;

procedure TfrmMNote.btIAClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  //pnChatGPT.Visible:= not pnChatGPT.Visible;
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;

  edChat.clear;
  edChat.Lines.Append('Analise esse fonte e comente sobre ele, apresentando um resumo tecnico bem elaborado:');
  edChat.Lines.Append(syn.Lines.text);
  FazPergunta;
end;

procedure TfrmMNote.btHideChange(Sender: TObject);
begin
  //pnChatGPT.Visible:= false;
end;

procedure TfrmMNote.btIA2Click(Sender: TObject);
begin
    frmIA.show;
end;

procedure TfrmMNote.btNovoClick(Sender: TObject);
begin
  NovoItem();
end;

procedure TfrmMNote.FormDestroy(Sender: TObject);
var
  info       : string;
  syn        : TSynEdit;
  tb         : TTabSheet;
  item       : TItem;
  a          : Integer;
  LeftWidth, RightWidth, BottomHeight: Integer;
  LeftTab, RightTab, BottomTab: Integer;
  LeftVisible, RightVisible, BottomVisible: Boolean;
  ProjectRoot, CacheFile: string;
begin
  if FNeuralApiBootstrap <> nil then
  begin
    FNeuralApiBootstrap.OnCompleted := nil;
    FreeAndNil(FNeuralApiBootstrap);
  end;
  MNoteAI.OnCompleted := nil;
  MNoteAI.OnStateChanged := nil;
  MNoteAI.OnSessionChanged := nil;
  MNoteAI.Cancel;
  if frmToolsOuvir <> nil then frmToolsOuvir.OnCommand := nil;
  Fsetmain.posx   := Left;
  Fsetmain.posy   := Top;
  Fsetmain.Width  := Width;
  Fsetmain.Height := Height;

  if (frmFolders <> nil) then
    FreeAndNil(frmFolders);

  info := '';
  for a := 0 to pgMain.PageCount - 1 do
  begin
    tb   := pgMain.Pages[a];
    item := TItem(tb.Tag);
    syn  := item.syn;
    info := info + IncludeTrailingPathDelimiter(item.DirName) + item.FileName + ' ';
  end;

  FSetMain.lastfiles := info;

  FIDEShell.CaptureLayout(LeftWidth, RightWidth, BottomHeight,
    LeftVisible, RightVisible, BottomVisible, LeftTab, RightTab, BottomTab);
  FSetMain.IDELeftWidth := LeftWidth;
  FSetMain.IDERightWidth := RightWidth;
  FSetMain.IDEBottomHeight := BottomHeight;
  FSetMain.IDELeftVisible := LeftVisible;
  FSetMain.IDERightVisible := RightVisible;
  FSetMain.IDEBottomVisible := BottomVisible;
  FSetMain.IDELeftTab := LeftTab;
  FSetMain.IDERightTab := RightTab;
  FSetMain.IDEBottomTab := BottomTab;

  Fsetmain.SalvaContexto(False);

  if GetProjectSearchFolder(ProjectRoot) then
  begin
    CacheFile := IncludeTrailingPathDelimiter(ProjectRoot) + '.mnote' +
      PathDelim + 'symbols.cache';
    MNoteProjectSymbols.SaveCache(CacheFile);
  end;

  FreeAndNil(FPythonService);
  FreeAndNil(FChatMemoryMapPanel);
  FreeAndNil(FLanguageToolbar);
  FreeAndNil(FTasksPanel);
  FreeAndNil(FChangesPanel);
  FreeAndNil(FTaskListPanel);
  FreeAndNil(FDBDictionaryPanel);
  if FBuildService <> nil then
  begin
    FBuildService.OnOutput := nil;
    FBuildService.OnCompleted := nil;
    FreeAndNil(FBuildService);
  end;
  FreeAndNil(FTerminalPanel);
  FreeAndNil(FFilesPanel);
  FreeAndNil(FComponentsLabPanel);
  FreeAndNil(FSolutionExplorer);
  FreeAndNil(FProjectContext);
  FreeAndNil(FProblemsPanel);
  FreeAndNil(FOutputPanel);
  FreeAndNil(FAIMonitorPanel);

  if Fsetmain <> nil then
    FreeAndNil(Fsetmain);

  FreeAndNil(FSearchPanel);
  FreeAndNil(FCommandPalette);
  FreeAndNil(FCommandRegistry);
  FreeAndNil(FThemeService);

end;

procedure TfrmMNote.FormShow(Sender: TObject);
begin
  if (frmSplash <> nil) then
  begin
    frmSplash.CloseAnimated;
    frmSplash.Free;
    frmSplash := nil;
  end;
  if (not FNeuralApiCheckStarted) and (FNeuralApiBootstrap <> nil) then
  begin
    FNeuralApiCheckStarted := True;
    FNeuralApiBootstrap.Start;
  end;
  if(Fsetmain.ToolsOuvir) then
  begin
    if(frmToolsOuvir= nil) then
      frmToolsOuvir := TfrmToolsOuvir.create(self);
    frmToolsOuvir.WakeWord := FSetMain.VoiceWakeWord;
    frmToolsOuvir.OnCommand := @VoiceCommandReceived;
    frmToolsOuvir.Conectar();
  end;

  if frmmquery2 = nil then
    frmmquery2 := Tfrmmquery2.Create(self);

  if (frmFolders = nil) then
  begin
    frmFolders := TfrmFolders.Create(self);
    frmFolders.flagMudanca:= true;
  end;
end;

procedure TfrmMNote.NeuralApiBootstrapCompleted(Sender: TObject;
  AStatus: TMNoteNeuralApiStatus; const AInstallerFile, AError: string);
var
  PromptText: string;
begin
  case AStatus of
    nasInstalled: Exit;
    nasUnavailable, nasError:
      begin
        if Trim(AError) <> '' then
          MessageHint('neural-api: ' + AError);
        Exit;
      end;
    nasDownloaded:
      PromptText := 'O instalador mais recente do neural-api foi baixado e ' +
        'validado.' + LineEnding + LineEnding + 'Deseja instalá-lo agora?';
    nasInstallerReady:
      PromptText := 'A pasta neural-api ainda não existe, mas já há um ' +
        'instalador validado.' + LineEnding + LineEnding +
        'Deseja instalá-lo agora?';
  end;
  if (AInstallerFile <> '') and
    (MessageDlg('neural-api', PromptText, mtConfirmation,
      [mbYes, mbNo], 0) = mrYes) and not OpenDocument(AInstallerFile) then
    MessageHint('Não foi possível abrir o instalador: ' + AInstallerFile);
end;

procedure TfrmMNote.lstFindChangeBounds(Sender: TObject);
begin
end;

procedure TfrmMNote.lstFindClick(Sender: TObject);
begin
  if (FSearchPanel <> nil) and (lstFind.ItemIndex >= 0) then
    FSearchPanel.NavigateResult(lstFind.ItemIndex);
end;

procedure TfrmMNote.lstFindContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
end;

procedure TfrmMNote.lstFindDblClick(Sender: TObject);
begin
end;

procedure TfrmMNote.lstFindSelectionChange(Sender: TObject; User: boolean);
begin
end;

procedure TfrmMNote.meChatHistChange(Sender: TObject);
begin
end;

procedure TfrmMNote.meChatHistClick(Sender: TObject);
begin
end;

procedure TfrmMNote.MenuItem10Click(Sender: TObject);
var
   plataforma : string;
begin
   {$IFDEF MSWINDOWS}
    plataforma := 'Windows ';
  {$ENDIF}
  {$IFDEF LINUX}
    plataforma := 'Linux ';
  {$ENDIF}

  {$IFDEF CPU64}
    plataforma := plataforma + '64 bits';
  {$ELSE}
    plataforma := plataforma + '32 bits';
  {$ENDIF}
  frmSobre := TfrmSobre.Create(self);
  frmSobre.lbversao.Caption := MNOTE_APP_VERSION + ' - ' + plataforma;
  frmSobre.showmodal();
  frmSobre.destroy();
  frmSobre := nil;
end;

procedure TfrmMNote.MenuItem12Click(Sender: TObject);
begin
end;

procedure TfrmMNote.MenuItem14Click(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.CutToClipboard;
end;

procedure TfrmMNote.MenuItem18Click(Sender: TObject);
begin
  meChatHist.Text := '';
  meDialog.text:= '';
  meCodes.text := '';
end;

procedure TfrmMNote.MenuItem19Click(Sender: TObject);
begin
  meCodes.SelectAll;
  meCodes.CopyToClipboard;

end;

procedure TfrmMNote.MenuItem20Click(Sender: TObject);
begin
  NewContext();
end;

procedure TfrmMNote.MenuItem21Click(Sender: TObject);
begin
  if (frmToolsOuvir= nil) then
    frmToolsOuvir := TfrmToolsOuvir.create(self);
  frmToolsOuvir.show();
end;

procedure TfrmMNote.MenuItem23Click(Sender: TObject);
begin
  CommandProjectNew(Sender);
end;

procedure TfrmMNote.MenuItem24Click(Sender: TObject);
begin
  CommandProjectOpen(Sender);
end;

procedure TfrmMNote.MenuItem25Click(Sender: TObject);
begin
  CommandProjectClose(Sender);
end;

procedure TfrmMNote.MenuItem26Click(Sender: TObject);
begin
  CommandProjectSave(Sender);
end;

procedure TfrmMNote.miIAThisSourceClick(Sender: TObject);
begin
  AnalisaFonte();
end;

procedure TfrmMNote.MenuItem7Click(Sender: TObject);
begin
end;

procedure TfrmMNote.miChatGPTClick(Sender: TObject);
begin
  frmIA.show;
end;

procedure TfrmMNote.micopyClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.CopyToClipboard;
end;

procedure TfrmMNote.miIMGJSONClick(Sender: TObject);
begin
  if (frmmainJSON = nil) then
    frmmainJSON := TfrmmainJSON.create(self);
  frmmainJSON.show;
end;

procedure TfrmMNote.miPasteClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.PasteFromClipboard;
end;

procedure TfrmMNote.miporradaClick(Sender: TObject);
begin
  frmporradawebapi := Tfrmporradawebapi.Create(self);
  frmporradawebapi.ShowModal;
  frmporradawebapi.free;
  frmporradawebapi:= nil;
end;

procedure TfrmMNote.miRedoClick(Sender: TObject);
var
  item : TItem;
  syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Redo;
end;

procedure TfrmMNote.miSelectAllClick(Sender: TObject);
begin
end;

procedure TfrmMNote.miSelectBlockClick(Sender: TObject);
begin
end;

procedure TfrmMNote.miSelectCmdClick(Sender: TObject);
begin
end;

procedure TfrmMNote.miToolsFalarClick(Sender: TObject);
begin
  if (frmToolsFalar= nil) then
    frmToolsFalar := TfrmToolsFalar.create(self);
  frmToolsFalar.show();
end;

procedure TfrmMNote.mncleanClick(Sender: TObject);
var
     Output : string;
     filename : string;
begin
     mnSalvarClick(self);
     filename := FSetMain.CleanScript;
     if (filename <> '') then
     begin
       {$IFDEF WINDOWS}
          if(Callprg(filename, '', Output)=true) then
          begin
               MessageHint('Clean script '+ filename);
               meResult.Lines.Text:= Output;
               pnResult.Visible:= true;
          end
          else
          begin
               MessageHint('fail clean script '+ filename);
               pnResult.Visible:= false;
          end;
       {$ENDIF}
     end
     else
     begin
         MessageHint('Config clean need! '+ filename);
         pnResult.Visible:= false;
     end;
end;

procedure TfrmMNote.mnCompileClick(Sender: TObject);
begin
  CommandProjectBuild(Sender);
end;

procedure TfrmMNote.mndebugClick(Sender: TObject);
var
     Output : string;
     filename : string;
begin
   mnSalvarClick(self);
   filename := FSetMain.DebugScript;
   if (filename <> '') then
   begin
      {$IFDEF WINDOWS}
        if(Callprg(filename,'', Output)=true) then
        begin
             MessageHint('Debug script '+ filename);
             meResult.Lines.Text:= Output;
             pnResult.Visible:= true;
        end
        else
        begin
             MessageHint('fail debug script '+ filename);
             pnResult.Visible:= false;
        end;
      {$ENDIF}
   end
   else
   begin
       MessageHint('Config Debug need! '+ filename);
       pnResult.Visible:= false;
   end;
end;

procedure TfrmMNote.mnHideResultClick(Sender: TObject);
begin
  pnResult.Visible:=false;
end;

procedure TfrmMNote.mnidos2unixClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  if (pgMain.PageCount <>0 ) then
  begin
    item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
    syn := item.syn;
    RemoveCtrlMFromSynEdit(syn);
  end;
end;

procedure TfrmMNote.mniJSONVALIDClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  if (pgMain.PageCount <>0 ) then
  begin
    item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
    syn := item.syn;
    if ValidateJson(syn) then
      ShowMessage('JSON VALID!')
    else
      ShowMessage('JSON NOT VALID!');
  end;
end;

procedure TfrmMNote.mninstallClick(Sender: TObject);
var
     Output : string;
     filename : string;
begin
   mnSalvarClick(self);
   filename := FSetMain.Install;
   if (filename <> '') then
   begin
     {$IFDEF WINDOWS}
        if(Callprg(filename, '', Output)=true) then
        begin
             MessageHint('Install script '+ filename);
             meResult.Lines.Text:= Output;
             pnResult.Visible:= true;
        end
        else
        begin
             MessageHint('fail Install script '+ filename);
             pnResult.Visible:= false;
        end;
     {$ENDIF}
   end
   else
   begin
       MessageHint('Config Install need! '+ filename);
       pnResult.Visible:= false;
   end;
end;

procedure TfrmMNote.mnJavaClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Highlighter := nil;
end;

procedure TfrmMNote.mnNoneClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Highlighter := nil;
end;

procedure TfrmMNote.mnPHPClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Highlighter := nil;
end;

procedure TfrmMNote.mnSQLClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  // configurar highlighter SQL se desejar
end;

procedure TfrmMNote.MenuItem15Click(Sender: TObject);
begin
  if (frmFolders = nil) then
    frmFolders := TfrmFolders.Create(self);
  {$ifndef Darwin}
  if frmFolders.Showing then
    frmFolders.hide
  else
    frmFolders.show();
  {$else}
   MessageHint('Folder not run in MACOS');
  {$ENDIF}
end;

procedure TfrmMNote.MenuItem16Click(Sender: TObject);
begin
end;

procedure TfrmMNote.mnrunClick(Sender: TObject);
var
 tb : TTabSheet;
 syn : TSynEdit;
 item : TItem;
begin
  if(pgMain.ActivePage=nil) then
  begin
    MessageHint('No tab sheet ');
    exit();
  end;
  tb := pgMain.ActivePage;
  item := TItem(tb.Tag);
  syn := item.syn;

  if(item.ItemType = ti_SQL) then
    RodaSQL()
  else
    RodaScript();
end;

procedure TfrmMNote.MenuItem4Click(Sender: TObject);
begin
  if frmmquery2 = nil then
    frmmquery2 := Tfrmmquery2.Create(self);

  if frmmquery2.Showing then
    frmmquery2.Hide
  else
    frmmquery2.Show;
end;

procedure TfrmMNote.miConfigClick(Sender: TObject);
begin
  frmConfig := TfrmConfig.create(self);
  frmConfig.showmodal();
  frmConfig.free();
end;

procedure TfrmMNote.miUndoClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Undo;
end;

procedure TfrmMNote.mnFixWClick(Sender: TObject);
begin
  mnFixarClick(self);
end;

procedure TfrmMNote.mnOnTopWClick(Sender: TObject);
begin
  mnStayClick(self);
end;

procedure TfrmMNote.mnDesktopCenterWClick(Sender: TObject);
begin
  mnDesktopCenterClick(self);
end;

procedure TfrmMNote.MenuItem1Click(Sender: TObject);
begin
end;

procedure TfrmMNote.MenuItem2Click(Sender: TObject);
begin
    lstFind.Visible:= false;
    pnResult.Visible:=false;
end;

procedure TfrmMNote.mnDesktopCenterClick(Sender: TObject);
var
  WA: TRect;
begin
  WA := Screen.WorkAreaRect;
  Left := WA.Left + (WA.Width  - Width)  div 2;
  Top  := WA.Top  + (WA.Height - Height) div 2;

  Fsetmain.posx := Left;
  Fsetmain.posy := Top;
  Fsetmain.width := Width;
  Fsetmain.Height := Height;
end;

procedure TfrmMNote.mnCClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  // configurar highlighter C se desejar
end;

procedure TfrmMNote.mnFechar2Click(Sender: TObject);
begin
  CloseTab();
end;

procedure TfrmMNote.mnFixarClick(Sender: TObject);
begin
    if (BorderStyle = bsNone) then
    begin
      BorderStyle:=bsSingle;
      Fsetmain.fixar := false;
      mnFixar.Caption:='Fix';
      mnFixW.caption := 'Fix';
      self.refresh;
    end
    else
    begin
      BorderStyle:=bsNone;
      Fsetmain.fixar := true;
      mnFixar.Caption:='Move';
      mnFixW.caption := 'Move';
      self.refresh;
    end;
    Fsetmain.SalvaContexto(false);
end;

procedure TfrmMNote.mnLazarusClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  // configurar highlighter Pascal se desejar
end;

procedure TfrmMNote.mnAssociarClick(Sender: TObject);
begin
end;

procedure TfrmMNote.MudaTodasaFontes();
var
   item : TItem;
   syn  : TSynEdit;
   a : integer;
begin
  for a := 0 to pgMain.PageCount-1 do
  begin
       item := TItem(pgMain.Pages[a].Tag);
       syn := item.syn;
       syn.Font := FSetMain.Font;
  end;
  meChatHist.Font := FSetMain.Font;
  meCodes.font := FSetMain.Font;
  mequestion.font := FSetMain.Font;
  meDialog.font := FSetMain.Font;
end;

procedure TfrmMNote.QuestionChat();
var
  resposta : string;
  i        : integer;
  pergunta : WideString;
  fonte    : WideString;
  mapa     : WideString;
  ritem    : TItem;
  syn      : TSynEdit;
  DevMsg   : string;
  Estimate: TMNoteTokenEstimate;
  FirstLine, LastLine: Integer;
  ContextLines: TStringList;
begin
  if (pgMain = nil) or (pgMain.ActivePage = nil) then
  begin
    MessageHint('Nenhuma aba ativa para analisar.');
    Exit;
  end;

  ritem := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  if ritem = nil then
  begin
    MessageHint('Item da aba não encontrado.');
    Exit;
  end;

  syn := ritem.syn;
  if syn = nil then
  begin
    MessageHint('Editor da aba não encontrado.');
    Exit;
  end;

  fonte := syn.SelText;
  if fonte = '' then
  begin
    ContextLines := TStringList.Create;
    try
      FirstLine := syn.CaretY - 20;
      if FirstLine < 1 then FirstLine := 1;
      LastLine := syn.CaretY + 20;
      if LastLine > syn.Lines.Count then LastLine := syn.Lines.Count;
      for i := FirstLine to LastLine do ContextLines.Add(syn.Lines[i - 1]);
      fonte := ContextLines.Text;
    finally
      ContextLines.Free;
    end;
  end;
  mequestion.Lines.Add(edChat.Text);

  if Assigned(frmIA) then
    mapa := frmIA.mePensamento.Lines.Text
  else
    mapa := '';

  { A camada roteada monta o contrato de cada papel. Aqui enviamos apenas o
    pedido e um contexto local limitado, evitando aninhar prompts completos. }
  if Length(mapa) > 6000 then mapa := Copy(mapa, Length(mapa) - 5999, 6000);
  pergunta := 'PEDIDO DO USUÁRIO:'#10 + edChat.Text +
    #10#10'CONTEXTO LOCAL DO EDITOR:'#10 + fonte +
    #10#10'MEMÓRIA RECENTE:'#10 + mapa;

  DevMsg :=
    'Voce é um assistente pessoal e teve as seguintes perguntas anteriores: ' +
    meChatHist.Text +
    ' , caso sugira alguma mudança sempre faça com alteração completa do fonte apresentado. ';

  if Length(DevMsg) > 6000 then
    DevMsg := Copy(DevMsg, Length(DevMsg) - 5999, 6000);
  Estimate := MNoteAI.EstimateContext(pergunta + DevMsg);
  meDialog.Lines.Text := Format('Contexto — estimativa: %d tokens + %d de margem; limite %d; %s',
    [Estimate.EstimatedTokens, Estimate.SafetyMargin, Estimate.ContextLimit,
     Estimate.Method]);
  if Estimate.ExceedsLimit and
    (not ShowConfirm('O contexto estimado excede o limite configurado. Continuar?')) then
    Exit;
  FPendingAIQuestion := edChat.Text;
  if GetProjectSearchFolder(resposta) then MNoteAI.SetProjectRoot(resposta);
  if not MNoteAI.SendRoutedAsync(aikConversation, pergunta, DevMsg) then
    MessageHint(MNoteAI.LastError);
end;

procedure TfrmMNote.miIAConfigClick(Sender: TObject);
begin
  with TfrmIAConfig.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmMNote.miVoiceOutputConfigClick(Sender: TObject);
begin
  with TfrmVoiceOutputConfig.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmMNote.miPythonConfigClick(Sender: TObject);
begin
  with TfrmconfPython.Create(Self) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmMNote.mnfontClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  FontDialog1.Font := syn.Font;

  if FontDialog1.Execute then
  begin
      syn.Font := FontDialog1.Font;
      FSetMain.Font := FontDialog1.Font;
      meChatHist.Font := FontDialog1.Font;
      meCodes.font := FontDialog1.Font;
      mequestion.font := FontDialog1.Font;
      meDialog.font := FontDialog1.Font;
      MudaTodasaFontes();
      FSetMain.SalvaContexto(false);
  end;
end;

procedure TfrmMNote.mnPythonClick(Sender: TObject);
var
   item : TItem;
   syn  : TSynEdit;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  // configurar highlighter Python se desejar
end;

procedure TfrmMNote.mnScriptClick(Sender: TObject);
begin
end;

procedure TfrmMNote.MenuItem6Click(Sender: TObject);
begin
  close;
end;

procedure TfrmMNote.MenuItem8Click(Sender: TObject);
begin
end;

procedure TfrmMNote.MenuItem9Click(Sender: TObject);
begin
  ExecuteCommand('file.save_all', Sender);
end;

procedure TfrmMNote.mnFecharClick(Sender: TObject);
begin
  ExecuteCommand('file.close', Sender);
end;

procedure TfrmMNote.mnPesqItemClick(Sender: TObject);
begin
  ExecuteCommand('edit.find', Sender);
end;

procedure TfrmMNote.mnReplaceItemClick(Sender: TObject);
begin
  ExecuteCommand('edit.replace', Sender);
end;

procedure TfrmMNote.SalvarComo(tb: TTabSheet);
var
  item: TItem;
  syn : TSynEdit;
begin
  item := TItem(tb.Tag);
  syn  := item.syn;

  if item.FileName <> '' then
    SaveDialog1.InitialDir := ExtractFilePath(item.FileName)
  else
    SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);

  if SaveDialog1.Execute then
  begin
    item.Savefile(SaveDialog1.FileName);
    item.DirName:= ExtractFileDir(SaveDialog1.FileName);
    item.FileName:=ExtractFileName(SaveDialog1.FileName);
    item.FileExt:= ExtractFileExt(SaveDialog1.FileName);

    tb.Caption := ExtractFileName(SaveDialog1.FileName);

    item.Salvo := False;
    SalvarTab(tb);
    ApplyThemeToAll;
  end;
end;

procedure TfrmMNote.SalvarTab(tb: TTabSheet);
var
  item: TItem;
  syn : TSynEdit;
  fullname : string;
begin
  item := TItem(tb.Tag);
  syn  := item.syn;

  if( item.FileName = '') then
  begin
    SalvarComo(tb);
    Exit;
  end;
  if(item.DirName='') then
    item.DirName := ExtractFileDir(Application.ExeName);

  //if not item.Salvo then
  //begin
  fullname:= IncludeTrailingPathDelimiter(item.DirName)+item.FileName;
  syn.Lines.SaveToFile(fullname);
  item.Salvo := True;
  //end;
end;

procedure TfrmMNote.mnSalvarClick(Sender: TObject);
begin
  ExecuteCommand('file.save', Sender);
end;

procedure TfrmMNote.mnSalvarComoClick(Sender: TObject);
var
   tb : TTabSheet;
begin
   if (pgMain.ActivePage <> nil) then
   begin
     tb := pgMain.ActivePage;
     SalvarComo(tb);
   end;
end;

procedure TfrmMNote.mnCarregarClick(Sender: TObject);
begin
  ExecuteCommand('file.open', Sender);
end;

procedure TfrmMNote.MenuItem3Click(Sender: TObject);
begin
end;

procedure TfrmMNote.PageControl1Change(Sender: TObject);
begin
end;

procedure TfrmMNote.Panel1Click(Sender: TObject);
begin
end;

procedure TfrmMNote.pgMainChanging(Sender: TObject; var AllowChange: Boolean);
begin
end;

procedure TfrmMNote.pnBottonClick(Sender: TObject);
begin
end;

procedure TfrmMNote.pnChatGPT2Resize(Sender: TObject);
begin
end;

procedure TfrmMNote.ReplaceDialog1Find(Sender: TObject);
begin
end;

procedure TfrmMNote.ReplaceDialog1Replace(Sender: TObject);
var
   tb : TTabSheet;
begin
   if (pgMain.ActivePage <> nil) then
   begin
      tb := pgMain.ActivePage;
      // implementar se quiser replace manual
   end;
end;

procedure TfrmMNote.pntvClick(Sender: TObject);
begin
end;

procedure TfrmMNote.pgMainChange(Sender: TObject);
var
  tb: TTabSheet;
  item: TItem;
begin
  MudaDoc();

  if (frmFolders <> nil) and (pgMain.ActivePage <> nil) then
  begin
    tb := pgMain.ActivePage;
    item := TItem(tb.Tag);
    if (item <> nil) and (item.syn <> nil) then
      frmFolders.AtualizarOutline(item.syn.Lines.Text);
  end;
  UpdateIDEStatus;
end;

procedure TfrmMNote.pgMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TabIndex: Integer;
  R: TRect;
  ImgWidth: Integer;
  TargetPage: TTabSheet;
begin
  if (Button <> mbLeft) or (pgMain = nil) then Exit;

  TabIndex := pgMain.IndexOfTabAt(X, Y);
  if (TabIndex < 0) or (TabIndex >= pgMain.PageCount) then Exit;

  R := pgMain.TabRect(TabIndex);
  ImgWidth := 16;
  if (pgMain.Images <> nil) and (pgMain.Images.Width > 0) then
    ImgWidth := pgMain.Images.Width;

  if (X >= R.Left) and (X <= R.Left + ImgWidth + 14) and
     (Y >= R.Top) and (Y <= R.Bottom) then
  begin
    TargetPage := pgMain.Pages[TabIndex];
    CloseTab(TargetPage);
  end;
end;

procedure TfrmMNote.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
end;

procedure TfrmMNote.TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
end;

procedure TfrmMNote.SalvarWorkspaceState;
var
  i, dirId, fsId, posX, posY, ativa, abaIndex: Integer;
  item: TItem;
  tb: TTabSheet;
  caminhoCompleto: string;
  Q: TZQuery;
begin
  if (dmBase = nil) or (dmBase.zconlocal = nil) or (not dmBase.zconlocal.Connected) then Exit;

  Q := TZQuery.Create(Self);
  try
    Q.Connection := dmBase.zconlocal;
    Q.SQL.Text := 'DELETE FROM workspace_tabs;';
    Q.ExecSQL;

    for i := 0 to pgMain.PageCount - 1 do
    begin
      tb := pgMain.Pages[i];
      if tb = nil then Continue;
      item := TItem(tb.Tag);
      if item = nil then Continue;

      caminhoCompleto := IncludeTrailingPathDelimiter(item.DirName) + item.FileName;
      if (Trim(item.FileName) <> '') and FileExists(caminhoCompleto) then
      begin
        dirId := dmBase.Buscafs_IDpeloDiretorio(item.DirName);
        if dirId <= 0 then
        begin
          dirId := dmBase.EnsureDirUnderParent(dmBase.EnsureRootId, item.DirName, DateTimeToUnix(Now));
        end;

        if dirId > 0 then
        begin
          dmBase.UpsertFile(dirId, item.FileName, caminhoCompleto);
          fsId := dmBase.Buscafs_IDpeloNome(dirId, item.FileName);
        end
        else
          fsId := 0;

        if fsId > 0 then
        begin
          posX := 1;
          posY := 1;
          if item.syn <> nil then
          begin
            posX := item.syn.CaretX;
            posY := item.syn.CaretY;
          end;

          if pgMain.ActivePageIndex = i then
            ativa := 1
          else
            ativa := 0;

          abaIndex := i;

          Q.SQL.Text :=
            'INSERT INTO workspace_tabs (id_fs, pos_x, pos_y, aba_index, ativa) ' +
            'VALUES (:fs, :x, :y, :aba, :act);';
          Q.ParamByName('fs').AsInteger := fsId;
          Q.ParamByName('x').AsInteger := posX;
          Q.ParamByName('y').AsInteger := posY;
          Q.ParamByName('aba').AsInteger := abaIndex;
          Q.ParamByName('act').AsInteger := ativa;
          Q.ExecSQL;
        end;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMNote.RestaurarWorkspaceState;
var
  Q: TZQuery;
  fsId, posX, posY, ativa, abaIndex, idxActive: Integer;
  caminhoCompleto: string;
  item: TItem;
  tb: TTabSheet;
begin
  if (dmBase = nil) or (dmBase.zconlocal = nil) or (not dmBase.zconlocal.Connected) then Exit;

  while pgMain.PageCount > 0 do
    CloseTab();

  Q := TZQuery.Create(Self);
  try
    Q.Connection := dmBase.zconlocal;
    Q.SQL.Text :=
      'SELECT id_fs, pos_x, pos_y, aba_index, ativa ' +
      'FROM workspace_tabs ' +
      'ORDER BY aba_index ASC;';
    Q.Open;

    idxActive := -1;
    while not Q.EOF do
    begin
      fsId := Q.FieldByName('id_fs').AsInteger;
      posX := Q.FieldByName('pos_x').AsInteger;
      posY := Q.FieldByName('pos_y').AsInteger;
      abaIndex := Q.FieldByName('aba_index').AsInteger;
      ativa := Q.FieldByName('ativa').AsInteger;

      caminhoCompleto := dmBase.ObterCaminhoCompletoFS(fsId);
      if (caminhoCompleto <> '') and FileExists(caminhoCompleto) then
      begin
        if FileLoad(caminhoCompleto) then
        begin
          if pgMain.PageCount > 0 then
          begin
            tb := pgMain.Pages[pgMain.PageCount - 1];
            if tb <> nil then
            begin
              item := TItem(tb.Tag);
              if (item <> nil) and (item.syn <> nil) then
              begin
                item.syn.CaretX := posX;
                item.syn.CaretY := posY;
              end;
            end;
          end;

          if ativa = 1 then
            idxActive := pgMain.PageCount - 1;
        end;
      end;
      Q.Next;
    end;

    if (idxActive >= 0) and (idxActive < pgMain.PageCount) then
      pgMain.ActivePageIndex := idxActive;

  finally
    Q.Free;
  end;
end;

procedure TfrmMNote.TestarPythonConnector;
var
  Py: TMNotePythonService;
  Report: TStringList;
begin
  Py := TMNotePythonService.Create(Self);
  Report := TStringList.Create;
  try
    if Py.ExecuteCode(
      'print("MNOTE2_PYTHON_OK")' + LineEnding +
      'x = 10 + 20' + LineEnding +
      'print("x=", x)'
    ) then
    begin
      if Assigned(meResult) then
      begin
        meResult.Lines.Add('Python executado com sucesso.');
        meResult.Lines.Add(Py.LastOutput);
        meResult.Lines.Add('x = ' + Py.GetVar('x'));
      end;
    end
    else
    begin
      Py.GetDiagnosticReport(Report);

      if Assigned(meResult) then
      begin
        meResult.Lines.Add('Erro no Python Connector:');
        meResult.Lines.Add(Py.LastError);
        meResult.Lines.Add('');
        meResult.Lines.AddStrings(Report);
      end;
    end;
  finally
    Report.Free;
    Py.Free;
  end;
end;

procedure TfrmMNote.DiagnosticoPythonConnector;
var
  Py: TMNotePythonService;
  Report: TStringList;
begin
  Py := TMNotePythonService.Create(Self);
  Report := TStringList.Create;
  try
    Py.Start;
    Py.GetDiagnosticReport(Report);

    if Assigned(meResult) then
    begin
      meResult.Lines.Clear;
      meResult.Lines.AddStrings(Report);
    end;
  finally
    Report.Free;
    Py.Free;
  end;
end;

procedure TfrmMNote.miTestarPythonClick(Sender: TObject);
begin
  TestarPythonConnector;
end;

procedure TfrmMNote.miDiagnosticoPythonClick(Sender: TObject);
begin
  DiagnosticoPythonConnector;
end;

end.

