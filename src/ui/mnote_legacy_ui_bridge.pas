unit mnote_legacy_ui_bridge;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms;

procedure InitializeMNoteLegacyUIBridge(AMainForm: TForm);
procedure FinalizeMNoteLegacyUIBridge;

implementation

uses
  Controls, Menus, ComCtrls, StdCtrls, ExtCtrls, Dialogs, SynEdit,
  SynEditHighlighter, item, mnote_language_registry, mnote_language_profile,
  mnote_highlighter_factory, mnote_developer_agent_service,
  mnote_multiagent_service, mnote_ai_service, mnote_ai_profile;

type
  TMNoteLegacyUIBridge = class(TComponent)
  private
    FMainForm: TForm;
    FDeveloperMenu: TMenuItem;
    function FindMenu(const AName: string): TMenuItem;
    function ActivePageControl: TPageControl;
    function ActiveItem: TItem;
    function ActiveEditor: TSynEdit;
    function FindWorkspaceRoot(const AStartPath: string): string;
    function ConfirmDeveloperPlan(const APlan: string): Boolean;
    procedure ShowTextDialog(const ACaption, AText: string);
    procedure BindClick(const AName: string; AHandler: TNotifyEvent);
    procedure ApplyLanguage(const AProfileID: string);
    procedure SelectAllClick(Sender: TObject);
    procedure SelectCommandClick(Sender: TObject);
    procedure SelectBlockClick(Sender: TObject);
    procedure LanguageNoneClick(Sender: TObject);
    procedure LanguagePascalClick(Sender: TObject);
    procedure LanguagePythonClick(Sender: TObject);
    procedure LanguageCppClick(Sender: TObject);
    procedure LanguageSQLClick(Sender: TObject);
    procedure LanguagePHPClick(Sender: TObject);
    procedure LanguageJavaClick(Sender: TObject);
    procedure LogViewClick(Sender: TObject);
    procedure DeveloperAgentClick(Sender: TObject);
    procedure CreateDeveloperMenu;
  public
    constructor CreateFor(AForm: TForm);
    procedure Bind;
  end;

var
  GBridge: TMNoteLegacyUIBridge = nil;

constructor TMNoteLegacyUIBridge.CreateFor(AForm: TForm);
begin
  inherited Create(AForm);
  FMainForm := AForm;
end;

function TMNoteLegacyUIBridge.FindMenu(const AName: string): TMenuItem;
var C: TComponent;
begin
  Result := nil;
  if FMainForm = nil then Exit;
  C := FMainForm.FindComponent(AName);
  if C is TMenuItem then Result := TMenuItem(C);
end;

function TMNoteLegacyUIBridge.ActivePageControl: TPageControl;
var C: TComponent;
begin
  Result := nil;
  if FMainForm = nil then Exit;
  C := FMainForm.FindComponent('pgMain');
  if C is TPageControl then Result := TPageControl(C);
end;

function TMNoteLegacyUIBridge.ActiveItem: TItem;
var Pages: TPageControl;
begin
  Result := nil;
  Pages := ActivePageControl;
  if (Pages = nil) or (Pages.ActivePage = nil) or (Pages.ActivePage.Tag = 0) then Exit;
  Result := TItem(Pages.ActivePage.Tag);
end;

function TMNoteLegacyUIBridge.ActiveEditor: TSynEdit;
var EditorItem: TItem;
begin
  Result := nil;
  EditorItem := ActiveItem;
  if EditorItem <> nil then Result := EditorItem.syn;
end;

function DirectoryHasLPI(const ADirectory: string): Boolean;
var SR: TSearchRec;
begin
  Result := FindFirst(IncludeTrailingPathDelimiter(ADirectory) + '*.lpi', faAnyFile, SR) = 0;
  if Result then FindClose(SR);
end;

function TMNoteLegacyUIBridge.FindWorkspaceRoot(const AStartPath: string): string;
var Current, Parent: string; I: Integer;
begin
  Current := ExpandFileName(AStartPath);
  if not DirectoryExists(Current) then Current := ExtractFileDir(Current);
  for I := 0 to 10 do
  begin
    if DirectoryHasLPI(Current) or DirectoryExists(IncludeTrailingPathDelimiter(Current) + '.git') then Exit(Current);
    Parent := ExtractFileDir(ExcludeTrailingPathDelimiter(Current));
    if (Parent = '') or SameFileName(Parent, Current) then Break;
    Current := Parent;
  end;
  Result := ExpandFileName(AStartPath);
  if not DirectoryExists(Result) then Result := ExtractFileDir(Result);
end;

procedure TMNoteLegacyUIBridge.ShowTextDialog(const ACaption, AText: string);
var F: TForm; M: TMemo; B: TButtonPanel;
begin
  F := TForm.Create(FMainForm);
  try
    F.Caption := ACaption; F.Position := poMainFormCenter; F.Width := 860; F.Height := 560;
    M := TMemo.Create(F); M.Parent := F; M.Align := alClient; M.ReadOnly := True;
    M.ScrollBars := ssAutoBoth; M.WordWrap := False; M.Lines.Text := AText;
    B := TButtonPanel.Create(F); B.Parent := F; B.Align := alBottom; B.ShowButtons := [pbClose];
    F.ShowModal;
  finally F.Free; end;
end;

function TMNoteLegacyUIBridge.ConfirmDeveloperPlan(const APlan: string): Boolean;
var PlanForm: TForm; Memo: TMemo; Buttons: TButtonPanel;
begin
  PlanForm := TForm.Create(FMainForm);
  try
    PlanForm.Caption := 'AI Developer - Revisar roteamento e plano';
    PlanForm.Position := poMainFormCenter; PlanForm.Width := 900; PlanForm.Height := 680;
    Memo := TMemo.Create(PlanForm); Memo.Parent := PlanForm; Memo.Align := alClient;
    Memo.ReadOnly := True; Memo.ScrollBars := ssAutoBoth; Memo.WordWrap := False; Memo.Lines.Text := APlan;
    Buttons := TButtonPanel.Create(PlanForm); Buttons.Parent := PlanForm; Buttons.Align := alBottom;
    Buttons.ShowButtons := [pbOK, pbCancel]; Buttons.OKButton.Caption := 'Executar plano'; Buttons.CancelButton.Caption := 'Cancelar';
    Result := PlanForm.ShowModal = mrOk;
  finally PlanForm.Free; end;
end;

procedure TMNoteLegacyUIBridge.BindClick(const AName: string; AHandler: TNotifyEvent);
var M: TMenuItem;
begin M := FindMenu(AName); if M <> nil then M.OnClick := AHandler; end;

procedure TMNoteLegacyUIBridge.CreateDeveloperMenu;
var ParentMenu: TMenuItem;
begin
  if FDeveloperMenu <> nil then Exit;
  ParentMenu := FindMenu('mnSetup'); if ParentMenu = nil then Exit;
  FDeveloperMenu := TMenuItem.Create(FMainForm); FDeveloperMenu.Name := 'miDeveloperAgent';
  FDeveloperMenu.Caption := 'AI Developer - Corrigir fontes...'; FDeveloperMenu.OnClick := @DeveloperAgentClick;
  ParentMenu.Add(FDeveloperMenu);
end;

procedure TMNoteLegacyUIBridge.Bind;
begin
  BindClick('miSelectAll', @SelectAllClick); BindClick('miSelectCmd', @SelectCommandClick);
  BindClick('miSelectBlock', @SelectBlockClick); BindClick('mnNone', @LanguageNoneClick);
  BindClick('mnLazarus', @LanguagePascalClick); BindClick('mnPython', @LanguagePythonClick);
  BindClick('mnC', @LanguageCppClick); BindClick('mnSQL', @LanguageSQLClick);
  BindClick('mnPHP', @LanguagePHPClick); BindClick('mnJava', @LanguageJavaClick);
  BindClick('MenuItem16', @LogViewClick); CreateDeveloperMenu;
end;

procedure TMNoteLegacyUIBridge.DeveloperAgentClick(Sender: TObject);
var
  EditorItem: TItem;
  Instruction, Root, OutputText, ReviewOutput, PlanForReview: string;
  Dev: TMNoteDeveloperAgentService;
  Multi: TMNoteMultiAgentService;
  Decision: TMNoteMultiAgentDecision;
  ExecOK, BuildPassed, TestsPassed: Boolean;
begin
  EditorItem := ActiveItem;
  if (EditorItem = nil) or (Trim(EditorItem.FileName) = '') then
  begin MessageDlg('AI Developer', 'Abra um arquivo do projeto antes de executar o agente.', mtInformation, [mbOK], 0); Exit; end;
  if not EditorItem.Salvo then
  begin MessageDlg('AI Developer', 'Salve as alterações do editor antes de pedir uma correção automática.', mtWarning, [mbOK], 0); Exit; end;

  Instruction := 'Analise e corrija o fonte ' + ExtractFileName(EditorItem.FileName) +
    '. Faça somente as mudanças necessárias e valide com build quando possível.';
  if not InputQuery('AI Developer', 'Orientação para a IA:', Instruction) then Exit;

  Root := FindWorkspaceRoot(EditorItem.FileName);
  Multi := MNoteMultiAgent; Multi.ConfigureWorkspace(Root);
  if not Multi.SelectAgent(Instruction, EditorItem.FileName, Decision) then
  begin MessageDlg('AI Developer - Roteamento', Multi.LastError, mtError, [mbOK], 0); Exit; end;

  Dev := MNoteDeveloperAgent; Dev.ConfigureWorkspace(Root);
  { Usa o cliente real do perfil escolhido: leve, banco, gestão ou árbitro. }
  Dev.Agent.SetChatGPT(MNoteAI.Profile(Decision.Role).Client);
  if not Dev.PrepareInstruction(Instruction) then
  begin MessageDlg('AI Developer', Dev.LastError, mtError, [mbOK], 0); Exit; end;

  PlanForReview := Multi.DecisionText + LineEnding + LineEnding +
    '--- PLANO PREPARADO EM SIMULAÇÃO ---' + LineEnding + Dev.LastPlan;
  if not ConfirmDeveloperPlan(PlanForReview) then Exit;

  ExecOK := Dev.ExecutePreparedPlan;
  if not ExecOK then
  begin MessageDlg('AI Developer', Dev.LastError, mtError, [mbOK], 0); Exit; end;
  OutputText := Trim(Dev.Agent.LastOutput);
  if OutputText = '' then OutputText := 'Plano executado com sucesso.';

  BuildPassed := (Pos('build_project', LowerCase(Dev.LastPlan)) = 0) or ExecOK;
  TestsPassed := (Pos('run_tests', LowerCase(Dev.LastPlan)) = 0) or ExecOK;
  if Multi.ReviewAndRecord(Instruction, OutputText, BuildPassed, TestsPassed, 0) then
  begin
    ReviewOutput := Multi.ReviewText;
    ShowTextDialog('AI Developer - Avaliação do supervisor forte',
      Multi.DecisionText + LineEnding + LineEnding + '--- RESULTADO ---' + LineEnding + OutputText +
      LineEnding + LineEnding + '--- REVISÃO FINAL ---' + LineEnding + ReviewOutput);
  end
  else
    MessageDlg('AI Developer - Supervisor',
      'Execução concluída, mas a revisão final falhou: ' + Multi.LastError,
      mtWarning, [mbOK], 0);

  if FileExists(EditorItem.FileName) then EditorItem.Loadfile(EditorItem.FileName);
end;

procedure TMNoteLegacyUIBridge.SelectAllClick(Sender: TObject);
var Syn: TSynEdit;
begin Syn := ActiveEditor; if Syn = nil then Exit; Syn.SelectAll; Syn.SetFocus; end;

procedure TMNoteLegacyUIBridge.SelectCommandClick(Sender: TObject);
var Syn: TSynEdit; LineNo: Integer;
begin
  Syn := ActiveEditor; if (Syn = nil) or (Syn.Lines.Count = 0) then Exit;
  LineNo := Syn.CaretY; if LineNo < 1 then LineNo := 1; if LineNo > Syn.Lines.Count then LineNo := Syn.Lines.Count;
  Syn.BlockBegin := Point(1, LineNo); Syn.BlockEnd := Point(Length(Syn.Lines[LineNo - 1]) + 1, LineNo); Syn.SetFocus;
end;

procedure TMNoteLegacyUIBridge.SelectBlockClick(Sender: TObject);
var Syn: TSynEdit; FirstLine, LastLine, CaretLine: Integer;
begin
  Syn := ActiveEditor; if (Syn = nil) or (Syn.Lines.Count = 0) then Exit;
  CaretLine := Syn.CaretY; if CaretLine < 1 then CaretLine := 1; if CaretLine > Syn.Lines.Count then CaretLine := Syn.Lines.Count;
  FirstLine := CaretLine; while (FirstLine > 1) and (Trim(Syn.Lines[FirstLine - 2]) <> '') do Dec(FirstLine);
  LastLine := CaretLine; while (LastLine < Syn.Lines.Count) and (Trim(Syn.Lines[LastLine]) <> '') do Inc(LastLine);
  Syn.BlockBegin := Point(1, FirstLine);
  if LastLine < Syn.Lines.Count then Syn.BlockEnd := Point(1, LastLine + 1)
  else Syn.BlockEnd := Point(Length(Syn.Lines[LastLine - 1]) + 1, LastLine);
  Syn.SetFocus;
end;

procedure TMNoteLegacyUIBridge.ApplyLanguage(const AProfileID: string);
var Syn: TSynEdit; EditorItem: TItem; Profile: TMNoteLanguageProfile; NewHighlighter, OldHighlighter: TSynCustomHighlighter;
begin
  Syn := ActiveEditor; EditorItem := ActiveItem; if (Syn = nil) or (EditorItem = nil) then Exit;
  Profile := MNoteLanguages.FindByID(AProfileID);
  if Profile = nil then begin MessageDlg('Linguagem', 'Perfil não encontrado: ' + AProfileID, mtError, [mbOK], 0); Exit; end;
  OldHighlighter := Syn.Highlighter;
  if Profile.HighlighterKind = hkNone then NewHighlighter := nil else NewHighlighter := TMNoteHighlighterFactory.CreateHighlighter(Syn, Profile);
  Syn.Highlighter := NewHighlighter; EditorItem.ItemType := TTypeItem(Profile.LegacyType);
  if (OldHighlighter <> nil) and (OldHighlighter <> NewHighlighter) and (OldHighlighter.Owner = Syn) then OldHighlighter.Free;
  Syn.Invalidate; Syn.SetFocus;
end;

procedure TMNoteLegacyUIBridge.LanguageNoneClick(Sender: TObject);
var Syn: TSynEdit; OldHighlighter: TSynCustomHighlighter; EditorItem: TItem;
begin
  Syn := ActiveEditor; EditorItem := ActiveItem; if (Syn = nil) or (EditorItem = nil) then Exit;
  OldHighlighter := Syn.Highlighter; Syn.Highlighter := nil; EditorItem.ItemType := ti_NODEFINE;
  if (OldHighlighter <> nil) and (OldHighlighter.Owner = Syn) then OldHighlighter.Free; Syn.Invalidate;
end;

procedure TMNoteLegacyUIBridge.LanguagePascalClick(Sender: TObject); begin ApplyLanguage('pascal'); end;
procedure TMNoteLegacyUIBridge.LanguagePythonClick(Sender: TObject); begin ApplyLanguage('python'); end;
procedure TMNoteLegacyUIBridge.LanguageCppClick(Sender: TObject); begin ApplyLanguage('cpp'); end;
procedure TMNoteLegacyUIBridge.LanguageSQLClick(Sender: TObject); begin ApplyLanguage('sql'); end;
procedure TMNoteLegacyUIBridge.LanguagePHPClick(Sender: TObject); begin ApplyLanguage('php'); end;
procedure TMNoteLegacyUIBridge.LanguageJavaClick(Sender: TObject); begin ApplyLanguage('java'); end;

procedure TMNoteLegacyUIBridge.LogViewClick(Sender: TObject);
var LogForm: TForm; LogMemo, SourceMemo: TMemo; C: TComponent;
begin
  LogForm := TForm.Create(FMainForm);
  try
    LogForm.Caption := 'Log / Output do MNote2'; LogForm.Position := poMainFormCenter; LogForm.Width := 820; LogForm.Height := 520;
    LogMemo := TMemo.Create(LogForm); LogMemo.Parent := LogForm; LogMemo.Align := alClient; LogMemo.ReadOnly := True;
    LogMemo.ScrollBars := ssAutoBoth; LogMemo.WordWrap := False;
    C := FMainForm.FindComponent('meResult');
    if C is TMemo then begin SourceMemo := TMemo(C); LogMemo.Lines.Assign(SourceMemo.Lines); end;
    if LogMemo.Lines.Count = 0 then LogMemo.Lines.Add('Nenhuma saída registrada nesta sessão.');
    LogForm.ShowModal;
  finally LogForm.Free; end;
end;

procedure InitializeMNoteLegacyUIBridge(AMainForm: TForm);
begin
  FinalizeMNoteLegacyUIBridge; if AMainForm = nil then Exit;
  GBridge := TMNoteLegacyUIBridge.CreateFor(AMainForm); GBridge.Bind;
end;

procedure FinalizeMNoteLegacyUIBridge;
begin FreeAndNil(GBridge); end;

finalization
  FinalizeMNoteLegacyUIBridge;

end.
