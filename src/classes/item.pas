unit item;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, SynCompletion, ExtCtrls, SynEdit,
  SynHighlighterPas, SynHighlighterAny, SynHighlighterPo, SynHighlighterCpp,
  SynHighlighterSQL, SynHighlighterPython, SynHighlighterPHP,
  SynHighlighterUnixShellScript, SynHighlighterBat, SynHighlighterJava,
  SynHighlighterJScript, SynHighlighterCss,
  Graphics, SynEditKeyCmds, SynEditTypes, SynEditHighlighter, LCLType, Variants,
  PythonEngine, PythonGUIInputOutput, setmain, funcoes, hint, Dialogs, StdCtrls,
  Menus, Forms, mnote_python_service, mnote_language_registry,
  mnote_language_profile, mnote_highlighter_factory, mnote_completion_types,
  mnote_completion_provider, mnote_completion_aggregator,
  mnote_static_completion_provider, mnote_document_completion_provider,
  mnote_snippet_completion_provider, mnote_project_symbol_index,
  mnote_database_completion_provider, mnote_pascal_symbol_parser,
  mnote_token_parser;

type
  TFuncPosition = record
    y1, y2: integer;
  end;

type
  // novas extensões adicionadas: JSON, XML, YAML, INI, MD
  TTypeItem  = (
    ti_NODEFINE,
    ti_E,
    ti_H,
    ti_CCP,
    ti_PAS,
    ti_Reg,
    ti_BAT,
    ti_CFG,
    ti_TXT,
    ti_SQL,
    ti_PY,
    ti_PHP,
    ti_JAVA,
    ti_JS,
    ti_HTML,
    ti_CSS,
    ti_JSON,
    ti_XML,
    ti_YAML,
    ti_INI,
    ti_MD,
    ti_INO,
    ti_SHELL,
    ti_ALL
  );

  TProjetoTipo = (
    pt_NODEFINE,
    pt_TEXT,
    pt_ProjetoRoot,
    pt_ProjetoSetup,
    pt_ProjetoSetupItem,
    pt_ProjetoFiles,
    pt_ProjetoDirFiles,
    pt_ProjetoFilesItem
  );

  TTipoInfo = (Name, Path);

  TPythonCtrl = class(TComponent)
  private
    FPythonEngine: TPythonEngine;
    FPythonGUIInputOutput1: TPythonGUIInputOutput;
    FVarsDict: PPyObject;
    FVarsGlobal: PPyObject;
    FVarsGlobalKeys: PPyObject;
    FVarsLocal: PPyObject;
    FVarsLocalKeys: PPyObject;
    FVarListGlobal_Size: NativeInt;
    FVarListLocal_Size: NativeInt;
    FVarsCheck: boolean;
  public
    property VarsDict: PPyObject read FVarsDict write FVarsDict;
    property PythonGUIInputOutput1: TPythonGUIInputOutput
      read FPythonGUIInputOutput1 write FPythonGUIInputOutput1;
    property VarsGlobal: PPyObject read FVarsGlobal write FVarsGlobal;
    property VarsLocal: PPyObject read FVarsLocal write FVarsLocal;
    property VarsGlobalKeys: PPyObject read FVarsGlobalKeys write FVarsGlobalKeys;
    property VarsLocalKeys: PPyObject read FVarsLocalKeys write FVarsLocalKeys;
    property PythonEngine: TPythonEngine read FPythonEngine write FPythonEngine;
    property VarListGlobal_Size: NativeInt read FVarListGlobal_Size write FVarListGlobal_Size;
    property VarListLocal_Size: NativeInt read FVarListLocal_Size write FVarListLocal_Size;
    property VarsCheck: boolean read FVarsCheck write FVarsCheck;
  end;

  { TItem }

  TItem = class(TComponent)
  private
    FListaItem: TObjectList;
    FPalavrasReservadas: TStringList;
    FItemType: TTypeItem;
    Fsyn: TSynEdit;
    FResultado: TCustomMemo;
    FSynAutoComplete: TSynAutoComplete;
    Ftimer: TTimer;
    FSender: TComponent;
    FPythonCtrl: TPythonCtrl;
    FError: Boolean;
    FLinhaError: integer;
    FColumError: integer;
    FFileError: String;

    FMainModule: PPyObject;

    FHighlighter: TSynCustomHighlighter;
    FLanguageProfileID: string;

    FsynCompletion: TSynCompletion;
    FCompletionAggregator: TMNoteCompletionAggregator;
    FCompletionItems: TMNoteCompletionItems;
    FCompletionContext: TMNoteCompletionContext;
    FSnippetCaret: TPoint;

    function PesquisaPar(param: string; lst: TStringlist): string;
    function GetPreservPath(const AFileName: string): string;
    function RunPythonComponente: Boolean;

    procedure Default();
    procedure SetItemType(value: TTypeItem);
    procedure SetSyn(value: TSynEdit);
    procedure TimerEvento(Sender: TObject);
    procedure SynCompletion1Execute(Sender: TObject);
    procedure CheckTipoArquivo();
    procedure ConfigurePHPHighlighter(var APHPHighlighter: TSynPHPSyn);
    procedure ConfigureCppHighlighter(var ACppHighlighter: TSynCppSyn);
    procedure ConfigureJScriptHighlighter(var AJScriptHighlighter: TSynJScriptSyn);
    procedure ConfigureJavaHighlighter(var AJavaHighlighter: TSynJavaSyn);
    procedure SynCompletion1CodeCompletion(var Value: string;
      SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
      Shift: TShiftState);
    procedure SynCompletion1SearchPosition(var APosition: integer);
    procedure CompletionAcceptTab(Sender: TObject);
    procedure CompletionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditorStatusChanged(Sender: TObject; Changes: TSynStatusChanges);
    procedure ConfigureCompletionProviders;
    procedure ApplySnippetCaret(Data: PtrInt);
    function CompletionCaption(AItem: TMNoteCompletionItem): string;
    function CurrentTextBeforeCaret: string;
    function CurrentLeafToken: string;
    procedure MessageHint(sender: TComponent; info: string);
  public
    Nome: String;
    FileName: String;
    DirName: String;
    FileExt: string;
    {$IFDEF WINDOWS}
    VolName: String;
    {$ENDIF}

    ProjetoTipo: TProjetoTipo;
    Salvo: Boolean;

    constructor Create(Sender: TComponent); override;
    destructor Destroy; override;

    procedure Mudou();
    procedure AtribuiNome(Arquivo: String);
    procedure AtribuiNovoNome();
    procedure Savefile(arquivo: string);
    procedure Loadfile(arquivo: string);
    procedure SetResultado(value: TCustomMemo);
    procedure Run();
    procedure HandleEditorKeyPress(AKey: Char);
    function FindDefinitionAtCaret(out AFileName: string;
      out ALine: Integer): Boolean;

    property ItemType: TTypeItem read FItemType write SetItemType;
    property syn: TSynEdit read Fsyn write SetSyn;
    property PalavrasReservadas: TStringlist read FPalavrasReservadas write FPalavrasReservadas;
    property SynAutoComplete: TSynAutoComplete read FSynAutoComplete write FSynAutoComplete;
    property Resultado: TCustomMemo read FResultado write SetResultado;
    property LinhaError: integer read FLinhaError;
    property Error: boolean read FError;
    property FileError: String read FFileError;
    property PythonCtrl: TPythonCtrl read FPythonCtrl;
  end;

implementation

procedure TItem.SynCompletion1SearchPosition(var APosition: integer);
begin
  SynCompletion1Execute(FSynCompletion);
  if FCompletionItems.Count > 0 then APosition := 0 else APosition := -1;
end;

procedure TItem.SynCompletion1CodeCompletion(var Value: string;
  SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
  Shift: TShiftState);
var
  CompletionIndex, CursorOffset, I: Integer;
  ExpandedText: string;
begin
  CompletionIndex := FSynCompletion.ItemList.IndexOf(Value);
  if (CompletionIndex < 0) or
    (CompletionIndex >= FCompletionItems.Count) then Exit;
  with FCompletionItems[CompletionIndex] do
  begin
    if Kind = ckSnippet then
    begin
      ExpandedText := TMNoteSnippetCompletionProvider.Expand(InsertText,
        CursorOffset);
      Value := ExpandedText;
      FSnippetCaret := SourceStart;
      for I := 1 to CursorOffset do
      begin
        if ExpandedText[I] = #10 then
        begin
          Inc(FSnippetCaret.Y);
          FSnippetCaret.X := 1;
        end
        else if ExpandedText[I] <> #13 then
          Inc(FSnippetCaret.X);
      end;
      Application.QueueAsyncCall(@ApplySnippetCaret, 0);
    end
    else
      Value := InsertText;
  end;
end;

procedure TItem.SynCompletion1Execute(Sender: TObject);
var
  I: Integer;
  Profile: TMNoteLanguageProfile;
  FullName: string;
begin
  FSynCompletion.ItemList.Clear;
  if (Fsyn = nil) or (FCompletionAggregator = nil) then Exit;
  Profile := MNoteLanguages.FindByExtension(FileExt);
  if Profile = nil then Exit;
  FullName := FileName;
  if DirName <> '' then
    FullName := IncludeTrailingPathDelimiter(DirName) + FileName;
  FCompletionContext.LanguageID := Profile.ID;
  FCompletionContext.TextBeforeCursor := CurrentTextBeforeCaret;
  FCompletionContext.Query := CurrentLeafToken;
  FCompletionContext.CurrentLine := Fsyn.LineText;
  FCompletionContext.DocumentText := Fsyn.Text;
  FCompletionContext.FileName := FullName;
  FCompletionContext.CursorLine := Fsyn.CaretY;
  FCompletionContext.CursorColumn := Fsyn.CaretX;
  FCompletionAggregator.Complete(FCompletionContext, FCompletionItems);
  for I := 0 to FCompletionItems.Count - 1 do
    FSynCompletion.ItemList.Add(CompletionCaption(FCompletionItems[I]));
end;

procedure TItem.CompletionAcceptTab(Sender: TObject);
begin
  if (FSetMain <> nil) and (FSetMain.CompletionAcceptMode = 1) then Exit;
  if Assigned(FSynCompletion.OnValidate) then
    FSynCompletion.OnValidate(FSynCompletion.TheForm, '', []);
end;

procedure TItem.CompletionKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (FSetMain <> nil) and
    (FSetMain.CompletionAcceptMode = 2) then Key := VK_UNKNOWN;
end;

procedure TItem.EditorStatusChanged(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if (scModified in Changes) and (FSetMain <> nil) and
    FSetMain.CompletionAutoTrigger and (Ftimer <> nil) then
  begin
    Ftimer.Enabled := False;
    Ftimer.Interval := 220;
    Ftimer.Enabled := True;
  end;
end;

procedure TItem.ConfigureCompletionProviders;
var
  Profile: TMNoteLanguageProfile;
  Provider: IMNoteCompletionProvider;
begin
  FreeAndNil(FCompletionAggregator);
  FCompletionAggregator := TMNoteCompletionAggregator.Create;
  Profile := MNoteLanguages.FindByExtension(FileExt);
  if Profile = nil then Exit;
  Provider := TMNoteStaticCompletionProvider.Create(Profile.ID, 'linguagem',
    FPalavrasReservadas);
  FCompletionAggregator.AddProvider(Provider);
  Provider := TMNoteSnippetCompletionProvider.Create;
  FCompletionAggregator.AddProvider(Provider);
  Provider := TMNoteDocumentCompletionProvider.Create;
  FCompletionAggregator.AddProvider(Provider);
  Provider := MNoteProjectSymbols;
  FCompletionAggregator.AddProvider(Provider);
  Provider := MNoteDatabaseCompletions;
  FCompletionAggregator.AddProvider(Provider);
end;

procedure TItem.ApplySnippetCaret(Data: PtrInt);
begin
  if Fsyn = nil then Exit;
  Fsyn.CaretXY := FSnippetCaret;
  Fsyn.SetFocus;
end;

function TItem.CompletionCaption(AItem: TMNoteCompletionItem): string;
var
  Details: string;
begin
  Details := AItem.Signature;
  if Details = '' then Details := AItem.Documentation;
  Details := StringReplace(Details, #13, ' ', [rfReplaceAll]);
  Details := StringReplace(Details, #10, ' ', [rfReplaceAll]);
  Result := AItem.Text + '    [' + CompletionKindName(AItem.Kind) + ']  ' +
    AItem.Origin;
  if Details <> '' then Result := Result + ' — ' + Details;
end;

function TItem.CurrentTextBeforeCaret: string;
begin
  Result := '';
  if (Fsyn = nil) or (Fsyn.CaretY < 1) or
    (Fsyn.CaretY > Fsyn.Lines.Count) then Exit;
  Result := Copy(Fsyn.Lines[Fsyn.CaretY - 1], 1, Fsyn.CaretX - 1);
end;

function TItem.CurrentLeafToken: string;
var
  Profile: TMNoteLanguageProfile;
  Token: string;
  SeparatorPosition: Integer;
begin
  Result := '';
  Profile := MNoteLanguages.FindByExtension(FileExt);
  if Profile = nil then Exit;
  Token := TMNoteTokenParser.CurrentToken(CurrentTextBeforeCaret,
    Profile.TokenCharacters);
  SeparatorPosition := LastDelimiter('.>:', Token);
  if SeparatorPosition > 0 then
    Result := Copy(Token, SeparatorPosition + 1, MaxInt)
  else
    Result := Token;
  Result := StringReplace(Result, '"', '', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '', [rfReplaceAll]);
end;

procedure TItem.ConfigurePHPHighlighter(var APHPHighlighter: TSynPHPSyn);
begin
  APHPHighlighter.CommentAttri.Foreground := clGreen;
  APHPHighlighter.CommentAttri.Style := [fsItalic];

  APHPHighlighter.KeyAttri.Foreground := clNavy;
  APHPHighlighter.KeywordAttribute.Style := [fsBold];

  APHPHighlighter.IdentifierAttri.Foreground := clBlack;
  APHPHighlighter.NumberAttri.Foreground := clTeal;
  APHPHighlighter.StringAttri.Foreground := clMaroon;
  APHPHighlighter.SymbolAttri.Foreground := clBlack;
end;

procedure TItem.ConfigureCppHighlighter(var ACppHighlighter: TSynCppSyn);
begin
  ACppHighlighter.CommentAttri.Foreground := clGreen;
  ACppHighlighter.CommentAttri.Style := [fsItalic];

  ACppHighlighter.KeyAttri.Foreground := clNavy;
  ACppHighlighter.KeywordAttribute.Style := [fsBold];

  ACppHighlighter.IdentifierAttri.Foreground := clBlack;
  ACppHighlighter.NumberAttri.Foreground := clTeal;
  ACppHighlighter.StringAttri.Foreground := clMaroon;
  ACppHighlighter.SymbolAttri.Foreground := clBlack;
end;

procedure TItem.ConfigureJScriptHighlighter(var AJScriptHighlighter: TSynJScriptSyn);
begin
  AJScriptHighlighter.CommentAttri.Foreground := clGreen;
  AJScriptHighlighter.CommentAttri.Style := [fsItalic];

  AJScriptHighlighter.KeyAttri.Foreground := clNavy;
  AJScriptHighlighter.KeywordAttribute.Style := [fsBold];

  AJScriptHighlighter.IdentifierAttri.Foreground := clBlack;
  AJScriptHighlighter.NumberAttri.Foreground := clTeal;
  AJScriptHighlighter.StringAttri.Foreground := clMaroon;
  AJScriptHighlighter.SymbolAttri.Foreground := clBlack;
end;

procedure TItem.ConfigureJavaHighlighter(var AJavaHighlighter: TSynJavaSyn);
begin
  AJavaHighlighter.CommentAttri.Foreground := clGreen;
  AJavaHighlighter.CommentAttri.Style := [fsItalic];

  AJavaHighlighter.KeyAttri.Foreground := clNavy;
  AJavaHighlighter.KeywordAttribute.Style := [fsBold];

  AJavaHighlighter.IdentifierAttri.Foreground := clBlack;
  AJavaHighlighter.NumberAttri.Foreground := clTeal;
  AJavaHighlighter.StringAttri.Foreground := clMaroon;
  AJavaHighlighter.SymbolAttri.Foreground := clBlack;
end;

procedure TItem.AtribuiNovoNome();
begin
  Default();
end;

procedure TItem.Default();
begin
  if Assigned(Ftimer) then
  begin
    Ftimer.Enabled := False;
    Ftimer.Interval := 220;
    Ftimer.OnTimer := @TimerEvento;
  end;

  FError := False;
  FLinhaError := 0;
  FColumError := 0;
  FFileError := '';

  if (FPythonCtrl <> nil) then
    FPythonCtrl.VarsCheck := False;

  if Assigned(FPalavrasReservadas) then
    FPalavrasReservadas.Clear;

  if FSynCompletion = nil then
    FSynCompletion := TSynCompletion.Create(Self);

  if FSynCompletion <> nil then
  begin
    FSynCompletion.Editor := Fsyn;
    FSynCompletion.OnCodeCompletion := @SynCompletion1CodeCompletion;
    FSynCompletion.OnExecute := @SynCompletion1Execute;
    FSynCompletion.OnSearchPosition := @SynCompletion1SearchPosition;
    FSynCompletion.OnKeyCompletePrefix := @CompletionAcceptTab;
    FSynCompletion.OnKeyDown := @CompletionKeyDown;
    FSynCompletion.ShortCut := ShortCut(VK_SPACE, [ssCtrl]);
    FSynCompletion.EndOfTokenChr := '()[]+-*/=<>;, ';
    FSynCompletion.CaseSensitive := False;
    FSynCompletion.Width := 620;
    FSynCompletion.LinesInWindow := 12;
    FSynCompletion.LongLineHintTime := 250;
    FSynCompletion.AutoUseSingleIdent := False;
  end;

  ItemType := ti_NODEFINE;
  ProjetoTipo := pt_NODEFINE;
  Nome := 'Novo';
  DirName := '';
  FileName := '';
  FileExt := '';

  {$IFDEF WINDOWS}
  VolName := '';
  {$ENDIF}
end;

procedure TItem.CheckTipoArquivo();
var
  Profile: TMNoteLanguageProfile;
  EditorOptions: TSynEditorOptions;
begin
  if Fsyn = nil then Exit;
  Profile := MNoteLanguages.FindByExtension(FileExt);
  if Profile = nil then
  begin
    Fsyn.Highlighter := nil;
    FreeAndNil(FHighlighter);
    FLanguageProfileID := '';
    ItemType := ti_NODEFINE;
    Exit;
  end;

  if (not SameText(FLanguageProfileID, Profile.ID)) or
    (FHighlighter = nil) then
  begin
    Fsyn.Highlighter := nil;
    FreeAndNil(FHighlighter);
    FHighlighter := TMNoteHighlighterFactory.CreateHighlighter(Self, Profile);
    Fsyn.Highlighter := FHighlighter;
    FLanguageProfileID := Profile.ID;
  end;
  ItemType := TTypeItem(Profile.LegacyType);
  Fsyn.TabWidth := Profile.TabWidth;
  EditorOptions := Fsyn.Options;
  if Profile.AutoIndent then
    Include(EditorOptions, eoAutoIndent)
  else
    Exclude(EditorOptions, eoAutoIndent);
  if Profile.UseTabs then
    Exclude(EditorOptions, eoTabsToSpaces)
  else
    Include(EditorOptions, eoTabsToSpaces);
  Fsyn.Options := EditorOptions;
  Exit;
{
  if FileExt = '.pas' then
  begin
    if FSynPasSyn1 = nil then
      FSynPasSyn1 := TSynPasSyn.Create(FSender);
    Fsyn.Highlighter := FSynPasSyn1;
    ItemType := ti_PAS;
  end
  else
  if FileExt = '.sh' then
  begin
    if FSynUNIXShellScriptSyn1 = nil then
      FSynUNIXShellScriptSyn1 := TSynUNIXShellScriptSyn.Create(FSender);
    Fsyn.Highlighter := FSynUNIXShellScriptSyn1;
    ItemType := ti_SHELL;
  end
  else
  if FileExt = '.php' then
  begin
    if FSynPHPSyn1 = nil then
      FSynPHPSyn1 := TSynPHPSyn.Create(FSender);
    Fsyn.Highlighter := FSynPHPSyn1;
    ConfigurePHPHighlighter(FSynPHPSyn1);
    ItemType := ti_PHP;
  end
  else
  if (FileExt = '.c') or (FileExt = '.cpp') or (FileExt = '.h') then
  begin
    if FSynCppSyn1 = nil then
      FSynCppSyn1 := TSynCppSyn.Create(FSender);
    Fsyn.Highlighter := FSynCppSyn1;
    ItemType := ti_CCP;
    ConfigureCppHighlighter(FSynCppSyn1);
  end
  else
  if FileExt = '.sql' then
  begin
    if FSynSQLSyn1 = nil then
      FSynSQLSyn1 := TSynSQLSyn.Create(FSender);
    Fsyn.Highlighter := FSynSQLSyn1;
    ItemType := ti_SQL;
  end
  else
  if FileExt = '.py' then
  begin
    if FSynPythonSyn1 = nil then
      FSynPythonSyn1 := TSynPythonSyn.Create(FSender);
    Fsyn.Highlighter := FSynPythonSyn1;
    ItemType := ti_PY;
  end
  else
  if FileExt = '.java' then
  begin
    if FSynJavaSyn1 = nil then
      FSynJavaSyn1 := TSynJavaSyn.Create(FSender);
    Fsyn.Highlighter := FSynJavaSyn1;
    ConfigureJavaHighlighter(FSynJavaSyn1);
    ItemType := ti_JAVA;
  end
  else
  if FileExt = '.css' then
  begin
    if FSynCssSyn1 = nil then
      FSynCssSyn1 := TSynCssSyn.Create(FSender);
    Fsyn.Highlighter := FSynCssSyn1;
    ItemType := ti_CSS;
  end
  else
  if FileExt = '.js' then
  begin
    if FSynJScriptSyn1 = nil then
      FSynJScriptSyn1 := TSynJScriptSyn.Create(FSender);
    Fsyn.Highlighter := FSynJScriptSyn1;
    ItemType := ti_JS;
    ConfigureJScriptHighlighter(FSynJScriptSyn1);
  end
  else
  // genérico para JSON / XML / YAML / INI / MD / HTML / TXT / CFG
  if (FileExt = '.json') or (FileExt = '.xml') or
     (FileExt = '.yaml') or (FileExt = '.yml') or
     (FileExt = '.ini') or (FileExt = '.md') or
     (FileExt = '.html') or (FileExt = '.txt') or
     (FileExt = '.cfg') then
  begin
    if FSynAnySyn1 = nil then
      FSynAnySyn1 := TSynAnySyn.Create(FSender);
    Fsyn.Highlighter := FSynAnySyn1;

    if FileExt = '.json' then
      ItemType := ti_JSON
    else
    if FileExt = '.xml' then
      ItemType := ti_XML
    else
    if (FileExt = '.yaml') or (FileExt = '.yml') then
      ItemType := ti_YAML
    else
    if FileExt = '.ini' then
      ItemType := ti_INI
    else
    if FileExt = '.md' then
      ItemType := ti_MD
    else
    if FileExt = '.html' then
      ItemType := ti_HTML
    else
    if FileExt = '.cfg' then
      ItemType := ti_CFG
    else
      ItemType := ti_TXT;
  end;
end;
}
end;

procedure TItem.SetItemType(value: TTypeItem);
var
  TxtPath, DciPath: string;
begin
  FItemType := value;
  if FPalavrasReservadas <> nil then
    FPalavrasReservadas.Clear;
  if FSynAutoComplete <> nil then
    FSynAutoComplete.AutoCompleteList.Clear;

  case FItemType of
    ti_PAS:
      begin
        TxtPath := GetPreservPath('pascallist.txt');
        DciPath := GetPreservPath('delphi32.dci');
      end;
    ti_PY:
      begin
        TxtPath := GetPreservPath('pythonlist.txt');
        DciPath := GetPreservPath('pythonlist.dci');
      end;
    ti_SQL:
      begin
        TxtPath := GetPreservPath('sqllist.txt');
        DciPath := GetPreservPath('sqllist.dci');
      end;
    ti_SHELL:
      begin
        TxtPath := GetPreservPath('shelllist.txt');
        DciPath := GetPreservPath('shelllist.dci');
      end;
    ti_CCP, ti_H, ti_INO:
      begin
        TxtPath := GetPreservPath('clist.txt');
        DciPath := GetPreservPath('c.dci');
      end;
    ti_PHP:
      begin
        TxtPath := GetPreservPath('phplist.txt');
        DciPath := GetPreservPath('phplist.dci');
      end;
    ti_JAVA:
      begin
        TxtPath := GetPreservPath('javalist.txt');
        DciPath := GetPreservPath('javalist.dci');
      end;
    ti_JS:
      begin
        TxtPath := GetPreservPath('jslist.txt');
        DciPath := GetPreservPath('jslist.dci');
      end;
    ti_CSS:
      begin
        TxtPath := GetPreservPath('csslist.txt');
        DciPath := GetPreservPath('csslist.dci');
      end;
    ti_HTML:
      begin
        TxtPath := GetPreservPath('htmllist.txt');
        DciPath := GetPreservPath('htmllist.dci');
      end;
    else
      begin
        TxtPath := '';
        DciPath := '';
      end;
  end;

  if (TxtPath <> '') and FileExists(TxtPath) and (FPalavrasReservadas <> nil) then
    FPalavrasReservadas.LoadFromFile(TxtPath);

  if (DciPath <> '') and FileExists(DciPath) and (FSynAutoComplete <> nil) then
    FSynAutoComplete.AutoCompleteList.LoadFromFile(DciPath);
  ConfigureCompletionProviders;
end;

procedure TItem.SetSyn(value: TSynEdit);
begin
  if Fsyn <> nil then
    Fsyn.UnRegisterStatusChangedHandler(@EditorStatusChanged);
  Fsyn := value;
  if FSynAutoComplete <> nil then
    FSynAutoComplete.Editor := value;
  if FSynCompletion <> nil then
    FSynCompletion.Editor := value;
  if Fsyn <> nil then
    Fsyn.RegisterStatusChangedHandler(@EditorStatusChanged, [scModified]);
end;

procedure TItem.TimerEvento(Sender: TObject);
var
  TextBeforeCaret, Token: string;
  Profile: TMNoteLanguageProfile;
  ScreenPoint: TPoint;
  MinimumCharacters: Integer;
begin
  Ftimer.Enabled := False;
  if (Fsyn = nil) or (not Fsyn.Focused) or FSynCompletion.IsActive then Exit;
  if (FSetMain <> nil) and (not FSetMain.CompletionAutoTrigger) then Exit;
  Profile := MNoteLanguages.FindByExtension(FileExt);
  if Profile = nil then Exit;
  TextBeforeCaret := CurrentTextBeforeCaret;
  Token := CurrentLeafToken;
  MinimumCharacters := 3;
  if FSetMain <> nil then MinimumCharacters := FSetMain.CompletionMinChars;
  if (TextBeforeCaret = '') or
    ((TextBeforeCaret[Length(TextBeforeCaret)] <> '.') and
     (Length(Token) < MinimumCharacters)) then Exit;
  ScreenPoint := Fsyn.ClientToScreen(Point(Fsyn.CaretXPix,
    Fsyn.CaretYPix + Fsyn.LineHeight + 1));
  FSynCompletion.Execute(Token, ScreenPoint.X, ScreenPoint.Y);
  Exit;
  // ainda não utilizado
end;

constructor TItem.Create(Sender: TComponent);
begin
  inherited Create(Sender);

  FSender := Sender;

  Ftimer := TTimer.Create(Self);
  FPalavrasReservadas := TStringList.Create;
  FCompletionItems := TMNoteCompletionItems.Create;
  FCompletionContext := TMNoteCompletionContext.Create;
  FSynCompletion := TSynCompletion.Create(Self);
  FSynAutoComplete := TSynAutoComplete.Create(FSynCompletion);

  FSynAutoComplete.ExecCommandID := ecSynAutoCompletionExecute;

  FPythonCtrl := TPythonCtrl.Create(Self);

  Default();
  Salvo := False;
end;

destructor TItem.Destroy;
begin
  (*
  // sempre testa Assigned antes de liberar
  //if Assigned(Ftimer) then
  //  FreeAndNil(Ftimer);

  if Assigned(FPalavrasReservadas) then
    FreeAndNil(FPalavrasReservadas);

  if Assigned(FListaItem) then
    FreeAndNil(FListaItem);

  //if Assigned(FSynCompletion) then
  //  FreeAndNil(FSynCompletion);

  //if Assigned(FSynAutoComplete) then
  //  FreeAndNil(FSynAutoComplete);

  if Assigned(FSynPasSyn1) then
    FreeAndNil(FSynPasSyn1);
  if Assigned(FSynBatSyn1) then
    FreeAndNil(FSynBatSyn1);
  if Assigned(FSynCppSyn1) then
    FreeAndNil(FSynCppSyn1);
  if Assigned(FSynCssSyn1) then
    FreeAndNil(FSynCssSyn1);
  if Assigned(FSynJavaSyn1) then
    FreeAndNil(FSynJavaSyn1);
  if Assigned(FSynJScriptSyn1) then
    FreeAndNil(FSynJScriptSyn1);
  //if Assigned(FSynPHPSyn1) then
  //  FreeAndNil(FSynPHPSyn1);
  if Assigned(FSynPythonSyn1) then
    FreeAndNil(FSynPythonSyn1);
  if Assigned(FSynSQLSyn1) then
    FreeAndNil(FSynSQLSyn1);
  if Assigned(FSynSQLSyn2) then
    FreeAndNil(FSynSQLSyn2);
  if Assigned(FSynUNIXShellScriptSyn1) then
    FreeAndNil(FSynUNIXShellScriptSyn1);
  if Assigned(FSynAnySyn1) then
    FreeAndNil(FSynAnySyn1);

  //if Assigned(FPythonCtrl) then
  //  FreeAndNil(FPythonCtrl);
  *)
  if Fsyn <> nil then
  begin
    Fsyn.UnRegisterStatusChangedHandler(@EditorStatusChanged);
    if Fsyn.Highlighter = FHighlighter then Fsyn.Highlighter := nil;
  end;
  FreeAndNil(FHighlighter);
  FreeAndNil(FCompletionAggregator);
  FreeAndNil(FCompletionItems);
  FreeAndNil(FCompletionContext);
  FreeAndNil(FPalavrasReservadas);
  FreeAndNil(FListaItem);
  inherited Destroy;
end;

procedure TItem.Mudou();
begin
  Salvo := False;
end;

procedure TItem.HandleEditorKeyPress(AKey: Char);
var
  FunctionName, FullName, Signature: string;
  Parser: TMNotePascalSymbolParser;
  Symbols: TMNoteCompletionItems;
  Symbol: TMNoteCompletionItem;
  HintPoint: TPoint;
  WordX: Integer;
begin
  if (AKey <> '(') or (Fsyn = nil) then Exit;
  WordX := Fsyn.CaretX - 1;
  if WordX < 1 then WordX := 1;
  FunctionName := Fsyn.GetWordAtRowCol(Point(WordX, Fsyn.CaretY));
  if FunctionName = '' then Exit;
  FullName := FileName;
  if DirName <> '' then
    FullName := IncludeTrailingPathDelimiter(DirName) + FileName;
  Symbols := TMNoteCompletionItems.Create;
  Parser := TMNotePascalSymbolParser.Create;
  try
    if SameText(FileExt, '.pas') or SameText(FileExt, '.pp') or
      SameText(FileExt, '.lpr') then
      Parser.Parse(Fsyn.Text, FullName, 'documento', Symbols);
    Symbol := Symbols.FindByInsertText(FunctionName);
    if Symbol = nil then Symbol := MNoteProjectSymbols.FindDefinition(FunctionName);
    if Symbol = nil then Exit;
    Signature := Symbol.Signature;
    if Signature = '' then Exit;
    Fsyn.Hint := Signature;
    Fsyn.ShowHint := True;
    Application.Hint := Signature;
    HintPoint := Fsyn.ClientToScreen(Point(Fsyn.CaretXPix,
      Fsyn.CaretYPix + Fsyn.LineHeight + 1));
    Application.ActivateHint(HintPoint);
  finally
    Parser.Free;
    Symbols.Free;
  end;
end;

function TItem.FindDefinitionAtCaret(out AFileName: string;
  out ALine: Integer): Boolean;
var
  SymbolName: string;
  Symbol: TMNoteCompletionItem;
  Parser: TMNotePascalSymbolParser;
  Symbols: TMNoteCompletionItems;
begin
  Result := False;
  AFileName := '';
  ALine := -1;
  if Fsyn = nil then Exit;
  SymbolName := Fsyn.GetWordAtRowCol(Fsyn.LogicalCaretXY);
  if SymbolName = '' then Exit;
  Symbol := MNoteProjectSymbols.FindDefinition(SymbolName);
  if Symbol <> nil then
  begin
    AFileName := Symbol.FileName;
    ALine := Symbol.Line;
    Exit((AFileName <> '') and (ALine > 0));
  end;
  Symbols := TMNoteCompletionItems.Create;
  Parser := TMNotePascalSymbolParser.Create;
  try
    AFileName := FileName;
    if DirName <> '' then
      AFileName := IncludeTrailingPathDelimiter(DirName) + FileName;
    Parser.Parse(Fsyn.Text, AFileName, 'documento', Symbols);
    Symbol := Symbols.FindByInsertText(SymbolName);
    if Symbol <> nil then ALine := Symbol.Line;
    Result := (AFileName <> '') and (ALine > 0);
  finally
    Parser.Free;
    Symbols.Free;
  end;
end;

procedure TItem.AtribuiNome(Arquivo: String);
begin
  if (Arquivo <> '') then
  begin
    Nome := ExtractFileName(Arquivo);
    DirName := ExtractFileDir(Arquivo);
    FileName := ExtractFileName(Arquivo);
    // *** importante: extensão sempre em minúsculo ***
    FileExt := LowerCase(ExtractFileExt(Arquivo));

    {$IFDEF WINDOWS}
    VolName := ExtractFileDrive(Arquivo);
    {$ENDIF}

    CheckTipoArquivo();
  end;
end;


procedure TItem.Savefile(arquivo: string);
begin
  // Atualiza nome / pasta / extensão e highlighter
  AtribuiNome(arquivo);
  CheckTipoArquivo();

  if Assigned(Fsyn) then
  begin
    // garante que diretório existe
    if (DirName <> '') and (not DirectoryExists(DirName)) then
      ForceDirectories(DirName);

    Fsyn.Lines.SaveToFile(arquivo);
    if (LowerCase(ExtractFileExt(arquivo)) = '.pas') or
      (LowerCase(ExtractFileExt(arquivo)) = '.pp') or
      (LowerCase(ExtractFileExt(arquivo)) = '.lpr') or
      (LowerCase(ExtractFileExt(arquivo)) = '.inc') then
      MNoteProjectSymbols.IndexFile(arquivo);
    Salvo := True;
  end
  else
  begin
    // só para ajudar a depurar se esquecer de setar o Syn
    MessageHint(FSender, 'SynEdit não atribuído ao TItem antes de salvar.');
  end;
end;


function TItem.PesquisaPar(param: string; lst: TStringlist): string;
var
  a: integer;
  resultado1: string;
begin
  resultado1 := '';
  for a := 0 to lst.Count - 1 do
  begin
    if (pos(param, lst.Strings[a]) >= 0) then
      resultado1 := Copy(lst.Strings[a], Length(param), Length(lst.Strings[a]));
  end;
  Result := resultado1;
end;

function TItem.GetPreservPath(const AFileName: string): string;
var
  AppPath, WorkPath: string;
begin
  // 1. Check in workspace source dir first (convenient for development)
  WorkPath := ExpandFileName(IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0))) + 'preserv' + PathDelim + AFileName);
  if FileExists(WorkPath) then
    Exit(WorkPath);

  // 2. Check in 'preserv' subdir of application executable path
  AppPath := ExtractFilePath(ParamStr(0)) + 'preserv' + PathDelim + AFileName;
  if FileExists(AppPath) then
    Exit(AppPath);

  // 3. Check in application directory directly
  AppPath := ExtractFilePath(ParamStr(0)) + AFileName;
  if FileExists(AppPath) then
    Exit(AppPath);

  // 4. Check using the original ApplicationName variable's location
  AppPath := ExtractFilePath(ApplicationName) + AFileName;
  if FileExists(AppPath) then
    Exit(AppPath);

  AppPath := ExtractFilePath(ApplicationName) + 'preserv' + PathDelim + AFileName;
  if FileExists(AppPath) then
    Exit(AppPath);

  // Fallback to workspace path
  Result := WorkPath;
end;

procedure TItem.Loadfile(arquivo: string);
begin
  // Atualiza nome / pasta / extensão e highlighter
  AtribuiNome(arquivo);
  CheckTipoArquivo();

  if Assigned(Fsyn) then
  begin
    if FileExists(arquivo) then
    begin
      Fsyn.Lines.LoadFromFile(arquivo);
      Salvo := True;
    end
    else
    begin
      Fsyn.Lines.Clear;
      Salvo := False;
      MessageHint(FSender, 'Arquivo não encontrado: ' + arquivo);
    end;
  end
  else
  begin
    // se esqueceram de chamar Item.syn := TSynEditDaAba;
    MessageHint(FSender, 'SynEdit não atribuído ao TItem antes de carregar arquivo.');
  end;
end;


procedure TItem.SetResultado(value: TCustomMemo);
begin
  FResultado := value;
end;

procedure TItem.MessageHint(sender: TComponent; info: string);
var
  frmHint: TfrmHint;
begin
  frmHint := TfrmHint.Create(sender);
  try
    frmHint.messagehint(info);
  finally
    frmHint.Free;
  end;
end;

function TItem.RunPythonComponente: Boolean;
var
  Py: TMNotePythonService;
  Report: TStringList;
begin
  Result := False;
  FError := False;
  FFileError := '';
  FLinhaError := 0;
  FColumError := 0;

  if Fsyn = nil then
  begin
    FError := True;
    FFileError := 'Editor não atribuído.';
    Exit(False);
  end;

  Py := TMNotePythonService.Create(Self);
  Report := TStringList.Create;
  try
    if Assigned(FResultado) then
      FResultado.Lines.Clear;

    Result := Py.ExecuteLines(Fsyn.Lines);

    if Assigned(FResultado) then
    begin
      if Py.LastOutput <> '' then
        FResultado.Lines.Add(Py.LastOutput);

      if not Result then
      begin
        FResultado.Lines.Add('Erro Python:');
        FResultado.Lines.Add(Py.LastError);
        FResultado.Lines.Add('');
        FResultado.Lines.Add('Diagnóstico:');
        Py.GetDiagnosticReport(Report);
        FResultado.Lines.AddStrings(Report);
      end;
    end;

    if not Result then
    begin
      FError := True;
      FFileError := Py.LastError;
    end;
  finally
    Report.Free;
    Py.Free;
  end;
end;

procedure TItem.Run();
var
  Output: string;
  filenamerun: string;
  PyMainModule: PPyObject;
begin
  case FItemType of
    ti_PY:
      begin
        if FSetMain.UsePythonConnector then
        begin
          RunPythonComponente;
          Exit;
        end;

        if (FSetMain.DLLPath <> '') then
        begin
          if (FPythonCtrl.PythonEngine = nil) then
            FPythonCtrl.PythonEngine := TPythonEngine.Create(FSender);

          if (FResultado <> nil) then
            FResultado.Lines.Clear;

          if (FPythonCtrl.PythonGUIInputOutput1 = nil) then
            FPythonCtrl.PythonGUIInputOutput1 := TPythonGUIInputOutput.Create(FSender);

          FPythonCtrl.PythonEngine.Name := 'PythonEngine';
          FPythonCtrl.PythonEngine.AutoLoad := True;
          FPythonCtrl.PythonEngine.FatalAbort := True;
          FPythonCtrl.PythonEngine.FatalMsgDlg := True;
          FPythonCtrl.PythonEngine.UseLastKnownVersion := True;
          FPythonCtrl.PythonEngine.AutoLoad := True;
          FFileError := '';

          FPythonCtrl.PythonEngine.DllPath := FSetMain.DLLPath;
          FPythonCtrl.PythonEngine.AutoFinalize := True;
          FPythonCtrl.PythonEngine.InitThreads := True;
          FPythonCtrl.PythonEngine.PyFlags := [pfInteractive];
          FPythonCtrl.PythonEngine.IO := FPythonCtrl.PythonGUIInputOutput1;

          if (FResultado <> nil) then
            FPythonCtrl.PythonGUIInputOutput1.Output := FResultado;

          if not FPythonCtrl.PythonEngine.Initialized then
            FPythonCtrl.PythonEngine.LoadDll;

          try
            FPythonCtrl.PythonEngine.ExecStrings(Fsyn.Lines);

            if (PythonCtrl.VarsCheck) then
            begin
              FMainModule := PythonCtrl.PythonEngine.PyImport_ImportModule('__main__');

              FPythonCtrl.FVarsDict := FPythonCtrl.PythonEngine.PyModule_GetDict(FMainModule);

              PyMainModule := FPythonCtrl.PythonEngine.PyImport_AddModule('__main__');
              FPythonCtrl.VarsDict := FPythonCtrl.PythonEngine.PyModule_GetDict(PyMainModule);

              // estes dicionários deveriam ser PyDict_New, mas são pouco utilizados
              FPythonCtrl.FVarsGlobal := @FPythonCtrl.FPythonEngine.PyDict_New;
              FPythonCtrl.VarsGlobalKeys := FPythonCtrl.PythonEngine.PyDict_Keys(FPythonCtrl.VarsGlobal);
              if (FPythonCtrl.VarsGlobalKeys <> nil) then
                FPythonCtrl.VarListGlobal_Size := FPythonCtrl.PythonEngine.PyList_Size(FPythonCtrl.VarsGlobalKeys);

              FPythonCtrl.VarsLocal := @FPythonCtrl.PythonEngine.PyDict_New;
              FPythonCtrl.VarsLocalKeys := FPythonCtrl.PythonEngine.PyDict_Keys(FPythonCtrl.VarsLocal);
              if (FPythonCtrl.VarsLocalKeys <> nil) then
                FPythonCtrl.VarListLocal_Size := FPythonCtrl.PythonEngine.PyList_Size(FPythonCtrl.VarsLocalKeys);
            end;

            FError := False;
          except
            on E: EPythonError do
            begin
              FError := True;
              if FResultado <> nil then
                FResultado.Append('Erro Python: ' + E.Message);
            end;
            on E: EPySyntaxError do
            begin
              FLinhaError := E.ELineNumber;
              FColumError := E.EEndOffset;
              FFileError := E.EFileName;
              if FResultado <> nil then
                FResultado.Append('Erro Python: ' + E.EFileName + ' ' + E.ELineStr);
            end;
            on E: EPyIndentationError do
            begin
              FLinhaError := E.ELineNumber;
              FColumError := E.EEndOffset;
              FFileError := E.EFileName;
              if FResultado <> nil then
                FResultado.Append('Erro Python: ' + E.EFileName + ' ' + E.ELineStr);
            end;
          end;
        end
        else
        begin
          filenamerun := FSetMain.RunScript + ' ' + FileName;
          if (filenamerun <> '') then
          begin
            {$IFDEF WINDOWS}
            if (Callprg(filenamerun, '', Output) = True) then
              MessageHint(Fsender, 'Run script ' + filenamerun)
            else
              MessageHint(Fsender, 'fail run script ' + filenamerun);
            {$ENDIF}
          end
          else
            MessageHint(Fsender, 'Config RUN need!' + filenamerun);
        end;
      end;

    ti_CCP:
      begin
        filenamerun := FSetMain.RunScript;
        if (filenamerun <> '') then
        begin
          {$IFDEF WINDOWS}
          if (Callprg(filenamerun, '', Output) = True) then
            MessageHint(Fsender, 'Run script ' + filenamerun)
          else
            MessageHint(Fsender, 'fail run script ' + filenamerun);
          {$ENDIF}
          {$IFDEF LINUX}
          if (Callprg('/bin/bash', ' -c ' + LineEnding + filenamerun, Output) = True) then
            MessageHint(Fsender, 'Run script ' + filenamerun)
          else
            MessageHint(Fsender, 'fail run script ' + filenamerun);
          {$ENDIF}
        end
        else
          MessageHint(Fsender, 'Config RUN need!' + filenamerun);
      end;

  else
    begin
      filenamerun := FSetMain.RunScript;
      if (filenamerun <> '') then
      begin
        {$IFDEF WINDOWS}
        if (Callprg(filenamerun, '', Output) = True) then
          MessageHint(Fsender, 'Run script ' + filenamerun)
        else
          MessageHint(Fsender, 'fail run script ' + filenamerun);
        {$ENDIF}
      end
      else
        MessageHint(Fsender, 'Config RUN need!' + filenamerun);
    end;
  end;
end;

end.

