unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, Grids, PopupNotifier, item, types, finds,
  setmain, TypeDB, folders, funcoes, LCLType, ValEdit, PairSplitter, chgtext,
  hint, registro, splash, setFolders, config, SynEditKeyCmds, PythonEngine,
  rxctrls, LogTreeView, uPoweredby, chatgpt, mquery2, porradawebapi,
  SynEditHighlighter, SynEditTypes, codigo, jsonmain, ToolsFalar, ToolsOuvir,
  newproject, uProjetoDB, IA, uPdfText, uDocText;

const versao = '2.53';

type

  { TfrmMNote }

  TfrmMNote = class(TForm)
    btHide: TToggleBox;
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
    procedure miIAThisSourceClick(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure miChatGPTClick(Sender: TObject);
    procedure micopyClick(Sender: TObject);
    procedure miIMGJSONClick(Sender: TObject);
    procedure miPasteClick(Sender: TObject);
    procedure miporradaClick(Sender: TObject);
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


    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);

    procedure MudaTodasaFontes();
  private
    { private declarations }
    FCHATGPT : TCHATGPT;
    strFind : String;
    FPos : integer;
    procedure QuestionChat();
    procedure AplicarEstilo(SynEdit: TSynEdit; StartLine, EndLine: Integer);
    procedure AnalisarSynEdit(SynEdit: TSynEdit);
    procedure CarregarParametros();
    procedure CarregarOld();
    procedure Carregar(arquivo : String);
    procedure SalvarTab(tb : TTabSheet);
    procedure synChange(Sender: TObject);
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
    procedure CloseTab();
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
  end;

  function FileLoad(const FullName: string): Boolean;

var
  frmMNote: TfrmMNote;

implementation

{$R *.lfm}

uses
  Sobre;

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
  if pgMain.ActivePage = nil then
  begin
    pnChatGPT.Visible:= false;
    Exit;
  end
  else
  begin
    pnChatGPT.Visible:= true;

  end;


  tb := pgMain.ActivePage;
  item := TItem(tb.Tag);
  if item = nil then Exit;

  fullfile := IncludeTrailingPathDelimiter(item.DirName) + item.FileName + '.RIA';

  if FileExists(fullfile) then
  begin
    pnChatGPT.Visible := True;
    try
      meDialog.Lines.LoadFromFile(fullfile);
    except
      on E: Exception do
        MessageHint('Erro ao carregar arquivo: ' + E.Message);
    end;
  end
  else
  begin
    //pnChatGPT.Visible := False;
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
end;

procedure TfrmMNote.SynEditkey(Sender: TObject; var Key: char);
var
  syn : TSynEdit;
begin
   syn := TSynedit(Sender);
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
begin
  if not FileExists(arquivo) then
  begin
    MessageHint(arquivo + ' not exists');
    Exit;
  end;

  idx := FindFilePage(arquivo);
  if idx <> -1 then
  begin
    pgMain.ActivePageIndex := idx;
    Exit;
  end;

  tb := NovoItem();
  item := TItem(tb.Tag);

  item.DirName  := ExtractFileDir(arquivo);
  item.FileExt  := ExtractFileExt(arquivo);
  item.FileName := ExtractFileName(arquivo);

  if (item.DirName = '') then
    item.DirName := ExtractFileDir(FSetMain.Defaultfolder);

  item.FileName := ExtractFileName(item.DirName + item.FileName);
  item.FileExt  := ExtractFileExt(arquivo);

  syn  := item.syn;
  ext  := LowerCase(ExtractFileExt(arquivo));

  try
    // carrega comportamento padrão do TItem
    item.Loadfile(arquivo);
    MudaDoc();
  except
    on E: Exception do
    begin
      tb.Free;
      MessageHint('File cannot be read: ' + E.Message);
      Exit;
    end;
  end;

  // para PDF/DOC/DOCX, substitui o conteúdo pelo texto extraído
  if (ext = '.pdf') or (ext = '.doc') or (ext = '.docx') then
  begin
    txt := LoadBinaryDocAsText(arquivo);
    syn.Lines.Text := txt;
    if Trim(txt) = '' then
      MessageHint('Nenhum texto extraído de ' + ExtractFileName(arquivo));
  end;

  tb.Tag        := PtrInt(item);
  tb.ImageIndex := 0;
  tb.PopupMenu  := popFechar;

  item.Salvo := True;

  if (FileGetAttr(arquivo) and faReadOnly) <> 0 then
    syn.ReadOnly := True;

  if item.Nome <> '' then
    tb.Caption := item.Nome
  else
    tb.Caption := ExtractFileName(arquivo);

  pgMain.Refresh;
end;

procedure TfrmMNote.LoadArquivo(arquivo : string);
begin
  if (arquivo = '') then
  begin
    OpenDialog1.InitialDir:= FSetMain.DEFAULTFOLDER;

    if OpenDialog1.execute then
    begin
      if FileExists(OpenDialog1.FileName) then
      begin
        Carregar(OpenDialog1.FileName);

        Application.ProcessMessages;

      end
      else
        MessageHint('File not found!');
    end;
  end
  else
  begin
    if FileExists(arquivo) then
      Carregar(arquivo)
    else
      MessageHint('File not found!');
  end;
end;

procedure TfrmMNote.NewContext;
begin
  mequestion.Text := '';
end;

procedure TfrmMNote.FazPergunta;
begin
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
  syn.Lines.Clear;
  syn.PopupMenu := popSysEdit;
  syn.OnChange:= @synChange;
  syn.Font := FSetMain.Font;
  syn.OnKeyPress:= @SynEditkey;

  item := TItem.create(self);
  item.AtribuiNovoNome();
  item.syn := syn;

  tb.PopupMenu := popFechar;
  tb.Tag:= PtrInt(item);
  tb.ImageIndex:=0;

  tb.Caption:= item.Nome;
  pgMain.ActivePage := tb;
  pgMain.Refresh();
  application.ProcessMessages;
  result := tb;
end;

procedure TfrmMNote.CloseTab();
var
  page: TTabSheet;
  item: TItem;
begin
  if pgMain.ActivePage = nil then Exit;

  page := pgMain.ActivePage;
  item := TItem(page.Tag);

  page.PageControl := nil;
  page.Free;

  if item <> nil then
    item.Free;
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

procedure TfrmMNote.FormCreate(Sender: TObject);
var
   filename: string;
   plataforma: string;
   biblioteca : string;
   basePath : string;
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

  frmSplash := TfrmSplash.Create(self);
  frmSplash.lbversao.Caption := versao + ' - ' + plataforma;
  frmSplash.show();
  Application.ProcessMessages;
  sleep(2000);

  filename := extractfilename(application.ExeName);
  if IsRun(filename) then
  begin
    if KillAppByName(filename) then
      MessageHint('Assumindo funções MNote anterior!');
  end;

  if (FSetMain = nil) then
    FsetMain := TsetMain.Create();

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

  if(FSetMain.Project<>'') then
  begin
     ProjetoDB := TProjetoDB.create(self);
     ProjetoDB.CarregarProjeto(FSetMain.Project,biblioteca);
  end;

  if(frmHint= nil) then
    frmHint := TfrmHint.create(self);

  CarregaContexto();

  if(frmIA=nil) then
    frmIA := TfrmIA.create(self);

  {$ifdef Darwin}
  {$else}
  {$endif}

  CarregarOld();
  CarregarParametros();

  frmRegistrar := TfrmRegistrar.Create(self);
  frmRegistrar.Identifica();
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
  if not Mudou() then
  begin
    if PerguntaSalvar() then
      SalvarTudo();
  end;
  CloseAction:= caFree;
end;

procedure TfrmMNote.FindDialog1Find(Sender: TObject);
var
   FindS: String;
   IPos, FLen, SLen: Integer;
   Res : integer;
   item: TItem;
   syn: TSynEdit;
   find : TFinds;
begin
  pnResult.Visible:= true;

  strFind:= FindDialog1.FindText;
  item := TItem(frmMNote.pgMain.ActivePage.Tag);
  syn := item.syn;
  IPOS := 0;
  FPOS := 0;
  item := TItem(frmMNote.pgMain.ActivePage.Tag);
  syn := item.syn;
  FLen := Length(strFind);
  SLen := Length(syn.Text);

  FindS := FindDialog1.FindText;
  lstFind.Items.clear;

  repeat
    if(frMatchCase in FindDialog1.Options ) then
      IPos := Pos(strFind, Copy(syn.Text,FPos+1,SLen-FPos))
    else
      IPos := Pos(AnsiUpperCase(strFind),AnsiUpperCase( Copy(syn.Text,FPos+1,SLen-FPos)));

    if (IPOS>0) then
    begin
         FPos := FPos + IPos;
         find := TFinds.create(syn ,frmMNote.pgMain.ActivePage , item, FPOS, strFind);
         lstFind.Visible := true;
         lstFind.Items.AddObject('Pos:'+inttostr(FPOS),tobject(find));
    end
    else
    begin
         FPOS := 0;
         break;
    end;
  until (IPOS <=0);

  If lstFind.Count = 0 then
  begin
      Res := Application.MessageBox('Text was not found!',
             'Find',  mb_OK + mb_ICONWARNING);
      FPos := 0;
  end;
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
begin
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

  Fsetmain.SalvaContexto(False);

  if Fsetmain <> nil then
    FreeAndNil(Fsetmain);

  if FCHATGPT <> nil then
    FreeAndNil(FCHATGPT);
end;

procedure TfrmMNote.FormShow(Sender: TObject);
begin
  if (frmSplash <> nil) then
  begin
    frmSplash.hide;
    frmSplash.Free;
    frmSplash := nil;
  end;
  if(Fsetmain.ToolsFalar) then
  begin
    if(frmToolsfalar= nil) then
      frmToolsfalar := TfrmToolsFalar.create(self);
    frmToolsfalar.Conectar();
  end;
  if(Fsetmain.ToolsOuvir) then
  begin
    if(frmToolsOuvir= nil) then
      frmToolsOuvir := TfrmToolsOuvir.create(self);
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

procedure TfrmMNote.lstFindChangeBounds(Sender: TObject);
begin
end;

procedure TfrmMNote.lstFindClick(Sender: TObject);
var
   find : TFinds;
procedure setSelLength(var textComponent:TSynEdit; newValue:integer);
begin
     textComponent.SelEnd:=textComponent.SelStart+newValue ;
end;

begin
    If lstFind.SelCount > 0 then
    begin
        find := TFINDS(lstFind.items.objects[lstFind.ItemIndex]);
        frmMNote.pgMain.ActivePage := find.tb;
        FPOS := find.IPOS;

        FPos := find.IPos + length(find.strFind);
        find.syn.SetFocus;
        frmMnote.ActiveControl := find.syn;
        find.syn.SelStart:= find.IPos;
        setSelLength(find.syn, find.FLen);
        FPos:=FPos+find.FLen-1;
    end;
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
  frmSobre.lbversao.Caption := versao + ' - ' + plataforma;
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
  frmNewProject := TfrmNewProject.create(self);
  frmNewProject.ShowModal;
  frmNewProject.free;
  frmNewProject := nil;
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
var
   item : TItem;
   syn  : TSynEdit;
   I : NativeInt;
   variavel : PPyObject;
   variavelname : string;
begin
   mnSalvarClick(self);
   item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
   meResult.Lines.clear;
   item.Resultado := meResult;

   item.Run();
   syn := item.syn;
   if (item.PythonCtrl.VarsCheck) then
   begin
      pnInspector.Visible:=true;
   end;
   if item.Error then
   begin
      syn.CaretY:= item.LinhaError;
   end
   else
   begin
     if (item.PythonCtrl.VarsCheck) then
     begin
         for I := 0 to item.PythonCtrl.VarListGlobal_Size -1  do
         begin
               variavel := item.PythonCtrl.PythonEngine.PyList_GetItem(item.PythonCtrl.VarsGlobalKeys,I);
               variavelname := item.PythonCtrl.PythonEngine.PyUnicodeAsString(variavel);
               vlGlobal.InsertRow(variavelname,'',true);
         end;
         for I := 0 to item.PythonCtrl.VarListLocal_Size -1  do
         begin
               variavel := item.PythonCtrl.PythonEngine.PyList_GetItem(item.PythonCtrl.VarsLocalKeys,I);
               variavelname := item.PythonCtrl.PythonEngine.PyUnicodeAsString(variavel);
               vlLocal.InsertRow(variavelname,'',true);
         end;
     end;
   end;
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
  codigo   : TCodigo;
  item     : TFonte;
  i        : integer;
  pergunta: WideString;
  fonte    : widestring;
  mapa : widestring;
  ritem : TItem;
  syn : TSynEdit;
begin
  if (FCHATGPT = nil) then
    FCHATGPT := TCHATGPT.Create(self);


  ritem := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := ritem.syn;
  fonte := syn.Lines.Text;
  mequestion.Lines.Add(edChat.Text);

  mapa := frmIA.mePensamento.Lines.text;

  FCHATGPT.TOKEN := FSetMain.CHATGPT;
  FCHATGPT.Dev:= 'Voce é um assistente pessoal e teve as seguintes perguntas anteriores: '+meChatHist.Text+' , caso sugira alguma mudança sempre faça com alteração completa do fonte apresentado. ';

  pergunta := 'Com base no fonte:'+fonte+ ' e no mapa de memoria da aplicacao '+mapa +', responda a seguinte pergunta: '+ edChat.Text;
  FCHATGPT.SendQuestion( pergunta);

  resposta := FCHATGPT.Response;

  if FSetMain.ToolsFalar then
  begin
    if (frmToolsfalar = nil) then
      frmToolsfalar := TfrmToolsFalar.Create(self);
    frmToolsfalar.edFalar.Text := resposta;
    frmToolsfalar.edIP.text := FSetMain.IPFALAR;
    frmToolsfalar.Conectar();
    Application.ProcessMessages;
    frmToolsfalar.Falar();
  end;

  meChatHist.Lines.Add('');
  meChatHist.Lines.Add('Question: ' + edChat.Text);
  meChatHist.Lines.Add('Response: ' + resposta);

  meDialog.Lines.Clear;
  meDialog.Lines.Add('Question: ' + edChat.Text);
  meDialog.Lines.Add('Response: ' + resposta);

  meCodes.Lines.BeginUpdate;
  try
    meCodes.Lines.Clear;
    codigo := TCodigo.Create;
    try
      codigo.AnalisaTexto(resposta);
      for i := 0 to codigo.Count - 1 do
      begin
        item := TFonte(codigo.Items[i]);
        meCodes.Lines.Add(item.codigo);
        meCodes.Lines.Add('');
      end;
    finally
      if(codigo.Count=1) then
      begin
        if(ShowConfirm('Change code?')) then
        begin
            syn.Text:= meCodes.Text;
        end;
      end;
      codigo.Free;
    end;
  finally
    meCodes.Lines.EndUpdate;
  end;

  edChat.Text := '';
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
var
   pagecont : integer;
   tb :TTabSheet;
begin
  for pagecont:=0 to pgMain.PageCount-1 do
  begin
      tb := pgMain.Pages[pagecont];
      SalvarTab(tb);
   end;
   MessageHint('All Saved!');
end;

procedure TfrmMNote.mnFecharClick(Sender: TObject);
begin
     CloseTab();
end;

procedure TfrmMNote.mnPesqItemClick(Sender: TObject);
begin
  FindDialog1.Execute;
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
var
  tb   : TTabSheet;
  item : TItem;
begin
  if pgMain.ActivePage = nil then Exit;

  tb := pgMain.ActivePage;
  item := TItem(tb.Tag);
  SalvarTab(tb);
  if item.FileName <> '' then
    MessageHint('Saved in ' + item.FileName);
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
  LoadArquivo('');
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

begin
  MudaDoc();
end;

procedure TfrmMNote.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
end;

procedure TfrmMNote.TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
end;

end.

