unit item;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, SynCompletion, ExtCtrls, SynEdit,
  SynHighlighterPas, SynHighlighterAny, SynHighlighterPo, SynHighlighterCpp,
  SynHighlighterSQL, SynHighlighterPython, SynHighlighterPHP,
  SynHighlighterUnixShellScript, SynHighlighterBat, SynHighlighterJava,
  SynHighlighterJScript, SynHighlighterCss,
  Graphics, SynEditKeyCmds, LCLType, Variants,
  PythonEngine, PythonGUIInputOutput, setmain, funcoes, hint, Dialogs, StdCtrls;

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

    // highlighters
    FSynPasSyn1: TSynPasSyn;
    FSynBatSyn1: TSynBatSyn;
    FSynCppSyn1: TSynCppSyn;
    FSynCssSyn1: TSynCssSyn;
    FSynJavaSyn1: TSynJavaSyn;
    FSynJScriptSyn1: TSynJScriptSyn;
    FSynPHPSyn1: TSynPHPSyn;
    FSynPythonSyn1: TSynPythonSyn;
    FSynSQLSyn1: TSynSQLSyn;
    FSynSQLSyn2: TSynSQLSyn;
    FSynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    FSynAnySyn1: TSynAnySyn;

    FsynCompletion: TSynCompletion;

    function PesquisaPar(param: string; lst: TStringlist): string;

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
    procedure MessageHint(sender: TComponent; info: string);
    function getPascfuncs(SynEdit: TSynEdit): TFuncPosition;
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

function TItem.getPascfuncs(SynEdit: TSynEdit): TFuncPosition;
begin
  Result.y1 := -1;
  Result.y2 := -1;
  // função ainda não utilizada – mantida só como placeholder
end;

procedure TItem.SynCompletion1SearchPosition(var APosition: integer);
begin
  // reservado para futuras integrações de autocomplete por contexto (SQL, etc)
end;

procedure TItem.SynCompletion1CodeCompletion(var Value: string;
  SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
  Shift: TShiftState);
var
  listagem: TStringlist;
begin
  listagem := TStringlist.Create();
  try
    listagem.Text := SourceValue;
    if SourceStart.x > 0 then
    begin
      if syn.Lines[SourceStart.y - 1][SourceStart.x - 1] = '\' then
      begin
        SourceStart.x -= 1;
        SourceValue := '\' + SourceValue;
      end;
    end;
  finally
    listagem.Free;
  end;
end;

procedure TItem.SynCompletion1Execute(Sender: TObject);
var
  i: Integer;
begin
  FSynCompletion.ItemList.Clear;

  for i := 0 to FPalavrasReservadas.Count - 1 do
  begin
    if Pos(FSynCompletion.CurrentString, FPalavrasReservadas[i]) = 1 then
      FSynCompletion.ItemList.Add(FPalavrasReservadas[i]);
  end;
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
    Ftimer.Interval := 1000;
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

  if (FSynCompletion = nil) and (FSender <> nil) then
    FSynCompletion := TSynCompletion.Create(Fsender);

  if FSynCompletion <> nil then
  begin
    FSynCompletion.Editor := Fsyn;
    FSynCompletion.OnCodeCompletion := @SynCompletion1CodeCompletion;
    FSynCompletion.OnExecute := @SynCompletion1Execute;
    FSynCompletion.OnSearchPosition := @SynCompletion1SearchPosition;
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
begin
  if FileExt = '.pas' then
  begin
    if FSynPasSyn1 = nil then
      FSynPasSyn1 := TSynPasSyn.Create(FSender);
    Fsyn.Highlighter := FSynPasSyn1;
    FItemType := ti_PAS;
  end
  else
  if FileExt = '.sh' then
  begin
    if FSynUNIXShellScriptSyn1 = nil then
      FSynUNIXShellScriptSyn1 := TSynUNIXShellScriptSyn.Create(FSender);
    Fsyn.Highlighter := FSynUNIXShellScriptSyn1;
    FItemType := ti_SHELL;
  end
  else
  if FileExt = '.php' then
  begin
    if FSynPHPSyn1 = nil then
      FSynPHPSyn1 := TSynPHPSyn.Create(FSender);
    Fsyn.Highlighter := FSynPHPSyn1;
    ConfigurePHPHighlighter(FSynPHPSyn1);
    FItemType := ti_PHP;
  end
  else
  if (FileExt = '.c') or (FileExt = '.cpp') or (FileExt = '.h') then
  begin
    if FSynCppSyn1 = nil then
      FSynCppSyn1 := TSynCppSyn.Create(FSender);
    Fsyn.Highlighter := FSynCppSyn1;
    FItemType := ti_CCP;
    ConfigureCppHighlighter(FSynCppSyn1);
  end
  else
  if FileExt = '.sql' then
  begin
    if FSynSQLSyn1 = nil then
      FSynSQLSyn1 := TSynSQLSyn.Create(FSender);
    Fsyn.Highlighter := FSynSQLSyn1;
    FItemType := ti_SQL;
  end
  else
  if FileExt = '.py' then
  begin
    if FSynPythonSyn1 = nil then
      FSynPythonSyn1 := TSynPythonSyn.Create(FSender);
    Fsyn.Highlighter := FSynPythonSyn1;
    FItemType := ti_PY;
  end
  else
  if FileExt = '.java' then
  begin
    if FSynJavaSyn1 = nil then
      FSynJavaSyn1 := TSynJavaSyn.Create(FSender);
    Fsyn.Highlighter := FSynJavaSyn1;
    ConfigureJavaHighlighter(FSynJavaSyn1);
    FItemType := ti_JAVA;
  end
  else
  if FileExt = '.css' then
  begin
    if FSynCssSyn1 = nil then
      FSynCssSyn1 := TSynCssSyn.Create(FSender);
    Fsyn.Highlighter := FSynCssSyn1;
    FItemType := ti_CSS;
  end
  else
  if FileExt = '.js' then
  begin
    if FSynJScriptSyn1 = nil then
      FSynJScriptSyn1 := TSynJScriptSyn.Create(FSender);
    Fsyn.Highlighter := FSynJScriptSyn1;
    FItemType := ti_JS;
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
      FItemType := ti_JSON
    else
    if FileExt = '.xml' then
      FItemType := ti_XML
    else
    if (FileExt = '.yaml') or (FileExt = '.yml') then
      FItemType := ti_YAML
    else
    if FileExt = '.ini' then
      FItemType := ti_INI
    else
    if FileExt = '.md' then
      FItemType := ti_MD
    else
    if FileExt = '.html' then
      FItemType := ti_HTML
    else
    if FileExt = '.cfg' then
      FItemType := ti_CFG
    else
      FItemType := ti_TXT;
  end;
end;

procedure TItem.SetItemType(value: TTypeItem);
begin
  FItemType := value;
  case FItemType of
    ti_PAS:
      begin
        FSynAutoComplete.AutoCompleteList.Clear;
        if FileExists(ExtractFilePath(ApplicationName) + 'delphi32.dci') then
          FSynAutoComplete.AutoCompleteList.LoadFromFile(
            ExtractFilePath(ApplicationName) + 'delphi32.dci');
      end;
    ti_PY:
      begin
        FSynAutoComplete.AutoCompleteList.Clear;
        if FileExists(ExtractFilePath(ApplicationName) + 'pythonlist.dci') then
          FSynAutoComplete.AutoCompleteList.LoadFromFile(
            ExtractFilePath(ApplicationName) + 'pythonlist.dci');
      end;
    ti_SQL:
      begin
        FSynAutoComplete.AutoCompleteList.Clear;
        if FileExists(ExtractFilePath(ApplicationName) + 'sqllist.dci') then
          FSynAutoComplete.AutoCompleteList.LoadFromFile(
            ExtractFilePath(ApplicationName) + 'sqllist.dci');
      end;
    ti_SHELL, ti_CCP, ti_H, ti_INO:
      begin
        FSynAutoComplete.AutoCompleteList.Clear;
        if FileExists(ExtractFilePath(ApplicationName) + 'c.dci') then
          FSynAutoComplete.AutoCompleteList.LoadFromFile(
            ExtractFilePath(ApplicationName) + 'c.dci');
      end;
    ti_PHP:
      begin
        FSynAutoComplete.AutoCompleteList.Clear;
        if FileExists(ExtractFilePath(ApplicationName) + 'phplist.dci') then
          FSynAutoComplete.AutoCompleteList.LoadFromFile(
            ExtractFilePath(ApplicationName) + 'phplist.dci');
      end;
    ti_JAVA:
      begin
        FSynAutoComplete.AutoCompleteList.Clear;
        if FileExists(ExtractFilePath(ApplicationName) + 'javalist.dci') then
          FSynAutoComplete.AutoCompleteList.LoadFromFile(
            ExtractFilePath(ApplicationName) + 'javalist.dci');
      end;
    ti_TXT, ti_CFG, ti_JSON, ti_XML, ti_YAML, ti_INI, ti_MD, ti_HTML:
      begin
        FSynAutoComplete.AutoCompleteList.Clear;
      end;
  end;
end;

procedure TItem.SetSyn(value: TSynEdit);
begin
  Fsyn := value;
  if FSynAutoComplete <> nil then
    FSynAutoComplete.Editor := value;
end;

procedure TItem.TimerEvento(Sender: TObject);
begin
  // ainda não utilizado
end;

constructor TItem.Create(Sender: TComponent);
begin
  inherited Create(Sender);

  FSender := Sender;

  Ftimer := TTimer.Create(FSender);
  FPalavrasReservadas := TStringList.Create;
  FSynCompletion := TSynCompletion.Create(FSender);
  FSynAutoComplete := TSynAutoComplete.Create(FSynCompletion);

  FSynAutoComplete.ExecCommandID := ecSynAutoCompletionExecute;

  FPythonCtrl := TPythonCtrl.Create(FSender);

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
  inherited Destroy;
end;

procedure TItem.Mudou();
begin
  Salvo := False;
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

procedure TItem.Run();
var
  Output: string;
  filenamerun: string;
  PyMainModule: PPyObject;
begin
  case FItemType of
    ti_PY:
      begin
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

