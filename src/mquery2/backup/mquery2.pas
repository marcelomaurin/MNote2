unit mquery2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Menus, ValEdit, SynEdit, SynHighlighterSQL, SynCompletion,
  ZConnection, ZDataset, ZPgEventAlerter, Tabela, views, View, strUtils, DB,
  csvdataset, SynEditTypes, SynGutterBase, SynEditMarks, SynEditKeyCmds,
  SynPluginSyncroEdit, SynGutterMarks, SynGutterLineNumber, SynGutterChanges,
  SynGutter, SynGutterCodeFolding, TAGraph, LCLType, Grids, Buttons,
  PairSplitter, DBCtrls, DBGrids, EditBtn, finds, ZClasses, ZCollections,
  ZCompatibility, ZTokenizer, ZSelectSchema, ZGenericSqlAnalyser, ZDbcLogging,
  ZVariant, ZPlainDriver, TypeDB, triggers, item, funcoes, chart, chatgpt,
  codigo, setmain, ZDbcIntfs, math, hint, Variants, LConvEncoding, base;

const
  sqltabela   = 'Você poderia me fornecer a consulta SQL que deseja analisar? Assim que eu receber o SQL, irei extrair os nomes das tabelas envolvidas e gerar um código em JSON com esses nomes. A resposta será apresentada dentro de uma caixa de texto apropriada para cópia, Desta forma refaça a pergunta mesmo nao havendo certeza da resposta,claramente formatada como um código JSON:';
  sqlMelhorias= 'Faça uma analise de melhorias do sql a seguir, gerando um codigo JSON onde cada melhoria fica listada em uma lista no campo melhoria, nao acrescentando numeração, apenas uma lista de melhorias como elementos deste campo';
  sqlEstetica = 'Por favor, forneça um código embelezado para o seguinte SQL. Gostaria que ele fosse apresentado em uma caixa de texto ou em um formato que me permita copiar e colar facilmente no meu editor de código. Aqui está o SQL: ';

type

  { Tfrmmquery2 }

  Tfrmmquery2 = class(TForm)
    btAnalise1: TButton;
    btAnaliselite: TButton;
    btBanco: TButton;
    btBanco1: TButton;
    btChart: TButton;
    btChart1: TButton;
    btChartPost: TButton;
    btConectarLite: TButton;
    btExecutarlite: TButton;
    btExecutelite: TButton;
    btImportCSV: TButton;
    btcomparar: TButton;
    btcomparar1: TButton;
    btConectarMy: TButton;
    btConectarPost: TButton;
    btExecutar1: TButton;
    btExecute1: TButton;
    btImportCSVLite: TButton;
    btJSON1: TButton;
    btJSON2: TButton;
    btPermissao: TToggleBox;
    btExecutar: TButton;
    btExecute: TButton;
    btJSON: TButton;
    btAnalise: TButton;
    btPermissao1: TToggleBox;
    btIAPost: TButton;
    Button3: TButton;
    cbMake: TComboBox;
    cbMake1: TComboBox;
    ckGPT: TCheckBox;
    ckGPT1: TCheckBox;
    CSVDataset1: TCSVDataset;
    dbgridmy: TDBGrid;
    dbgridmy1: TDBGrid;
    dbgridpost: TDBGrid;
    dbnavmy: TDBNavigator;
    dbnavmy1: TDBNavigator;
    dbnavpost: TDBNavigator;
    dsmy: TDataSource;
    dslite: TDataSource;
    dspos: TDataSource;
    edBanco: TEdit;
    edBancoPost: TEdit;
    edErro: TMemo;
    edErro1: TMemo;
    edErro2: TMemo;
    edHostName: TEdit;
    edHostNamePost: TEdit;
    edDatabase: TFileNameEdit;
    edLog1: TMemo;
    edLogPost: TMemo;
    edPesqMy: TEdit;
    edPesqsqlite: TEdit;
    edSchemaPost: TEdit;
    edLog: TMemo;
    edPasswrd: TEdit;
    edPasswrdPost: TEdit;
    edPesqPost: TEdit;
    edSQL: TSynEdit;
    edSQL1: TSynEdit;
    edSQLPost: TSynEdit;
    edusuario: TEdit;
    edusuarioPost: TEdit;
    FindDialog1: TFindDialog;
    FontDialog1: TFontDialog;
    ImageList1: TImageList;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCol: TLabel;
    lbCol1: TLabel;
    lbCol2: TLabel;
    lblinha: TLabel;
    lblinha1: TLabel;
    lblinha2: TLabel;
    lbTables1: TListBox;
    ListBox1: TListBox;
    lbTables: TListBox;
    lstfind: TListBox;
    lstfind1: TListBox;
    lstfind2: TListBox;
    MainMenu1: TMainMenu;
    meIA: TMemo;
    MenuItem1: TMenuItem;
    dropPost: TMenuItem;
    miCNewEdit2: TMenuItem;
    miCreatelite: TMenuItem;
    midroplite: TMenuItem;
    miEmbelezar2: TMenuItem;
    miFont2: TMenuItem;
    miselectlite: TMenuItem;
    mnCriaDicionariolite: TMenuItem;
    Panel12: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel7: TPanel;
    pgbar1: TProgressBar;
    pgSQLite: TPageControl;
    pmDatabaseLite: TPopupMenu;
    pmTabelaLite: TPopupMenu;
    pmTabelasLite: TPopupMenu;
    pnBotton2: TPanel;
    pnErro2: TPanel;
    pnlProgresso1: TPanel;
    popSQLLite: TPopupMenu;
    Separator2: TMenuItem;
    miIA: TMenuItem;
    miCNewEdit1: TMenuItem;
    miDependencias: TMenuItem;
    miEmbelezar1: TMenuItem;
    miFont1: TMenuItem;
    miOcultar: TMenuItem;
    miRelacionamentos: TMenuItem;
    miGrupoTabelas: TMenuItem;
    mnCriaDicionario: TMenuItem;
    mnDicionario: TMenuItem;
    miDescricaoPost: TMenuItem;
    miEmbelezar: TMenuItem;
    miChart: TMenuItem;
    miCNewEdit: TMenuItem;
    MenuItem11: TMenuItem;
    midrop: TMenuItem;
    miselect: TMenuItem;
    miCreate: TMenuItem;
    miCFunction: TMenuItem;
    miCTrigger: TMenuItem;
    mnLTrigger: TMenuItem;
    mnFonte: TMenuItem;
    MenuItem8: TMenuItem;
    miNovaPesquisa: TMenuItem;
    niPesquisar: TMenuItem;
    miEditor: TMenuItem;
    miFont: TMenuItem;
    miEsconder: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    miMostrar: TMenuItem;
    miBenchmark: TMenuItem;
    MenuItem9: TMenuItem;
    N1: TMenuItem;
    mnCriarSeq: TMenuItem;
    mnRefresh: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel10: TPanel;
    Panel11: TPanel;
    pnIAbotton: TPanel;
    pnSQL: TPanel;
    pnIA: TPanel;
    pmDatabaseMy: TPopupMenu;
    pmTabelasPost: TPopupMenu;
    pnsqlpost: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    pgMain: TPageControl;
    pgMysql: TPageControl;
    Panel13: TPanel;
    pcPostgree: TPageControl;
    Panel1: TPanel;
    Panel14: TPanel;
    Panel4: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    pgbar: TProgressBar;
    pmTabelasMy: TPopupMenu;
    pnBotton: TPanel;
    pnBotton1: TPanel;
    pnErro: TPanel;
    pnErro1: TPanel;
    pnlProgresso: TPanel;
    popSeq: TPopupMenu;
    popMenu: TPopupMenu;
    popSQLMy: TPopupMenu;
    popfind: TPopupMenu;
    popmenuTrigger: TPopupMenu;
    pmTabelaPost: TPopupMenu;
    pmDatabasePost: TPopupMenu;
    pmTabelaMy: TPopupMenu;
    popSQLPost: TPopupMenu;
    PopupMenuTblPost: TPopupMenu;
    SaveDialog1: TSaveDialog;
    Separator1: TMenuItem;
    Separator3: TMenuItem;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    Splitter5: TSplitter;
    Splitter6: TSplitter;
    Splitter7: TSplitter;
    SynCompletion1: TSynCompletion;
    SynPluginSyncroEdit1: TSynPluginSyncroEdit;
    SynSQLSyn2: TSynSQLSyn;
    TabSheet1: TTabSheet;
    liteMain: TTabSheet;
    TabSheet2: TTabSheet;
    tbConxao1: TTabSheet;
    tbLog1: TTabSheet;
    tbSQL1: TTabSheet;
    tbTools1: TTabSheet;
    tsgrid1: TTabSheet;
    tsGridPostgres: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    ToggleBox3: TToggleBox;
    tsgrid: TTabSheet;
    tsSQLPostgreSQL: TTabSheet;
    tsAbout: TTabSheet;
    tsSetupPostres: TTabSheet;
    TabSheet7: TTabSheet;
    tbConxao: TTabSheet;
    tbLog: TTabSheet;
    tbSQL: TTabSheet;
    tbTools: TTabSheet;
    ToggleBox2: TToggleBox;
    tsMysql: TTabSheet;
    tspostgree: TTabSheet;
    TrayIcon1: TTrayIcon;
    tvsqlite: TTreeView;
    tvPost: TTreeView;
    tvMysql: TTreeView;
    vlistequivalente: TStringGrid;
    zconmysql: TZConnection;
    zconsqlite: TZConnection;
    zconpost: TZConnection;
    zmyqry: TZReadOnlyQuery;
    zmyqry1: TZReadOnlyQuery;
    zmyqry2: TZReadOnlyQuery;
    zliteqry: TZReadOnlyQuery;
    zliteqry1: TZReadOnlyQuery;
    zliteqry2: TZReadOnlyQuery;
    zpostqry: TZReadOnlyQuery;
    zpostqry1: TZReadOnlyQuery;
    zpostqry2: TZReadOnlyQuery;
    zpostqry3: TZReadOnlyQuery;
    Zqrypost: TZQuery;
    ZQryTransf: TZQuery;
    ZQryLiteTransf: TZQuery;

    procedure btAnaliseClick(Sender: TObject);
    procedure btAnaliseliteClick(Sender: TObject);
    procedure btBancoClick(Sender: TObject);
    procedure btBancoliteClick(Sender: TObject);
    procedure btbenchmarkClick(Sender: TObject);
    procedure btChartClick(Sender: TObject);
    procedure btChartPostClick(Sender: TObject);
    procedure btcompararClick(Sender: TObject);
    procedure btExecutar1Click(Sender: TObject);
    procedure btExecutarClick(Sender: TObject);
    procedure btExecutarliteClick(Sender: TObject);
    procedure btExecuteliteClick(Sender: TObject);
    procedure btIAPostClick(Sender: TObject);
    procedure btImportCSVClick(Sender: TObject);
    procedure btImportCSV1Click(Sender: TObject);
    procedure btImportCSVLiteClick(Sender: TObject);
    procedure btJSONClick(Sender: TObject);
    procedure btPermissaoChange(Sender: TObject);
    procedure btConectarMyClick(Sender: TObject);
    procedure btConectarLiteClick(Sender: TObject);
    procedure btConectarpostClick(Sender: TObject);
    procedure btExecuteClick(Sender: TObject);
    procedure btExecute2Click(Sender: TObject);
    procedure btExecutar2Click(Sender: TObject);
    procedure btExecute1Click(Sender: TObject);
    procedure btJSON1Click(Sender: TObject);
    procedure btJSON2Click(Sender: TObject);

    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure edPesqMyKeyPress(Sender: TObject; var Key: char);
    procedure edPesqPostKeyPress(Sender: TObject; var Key: char);
    procedure edPesqsqliteKeyPress(Sender: TObject; var Key: char);
    procedure edSchemaPostChange(Sender: TObject);
    procedure edSQLChange(Sender: TObject);
    procedure edSQLChangeUpdating(ASender: TObject; AnUpdating: Boolean);
    procedure edSQLClickLink(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edSQLCommandProcessed(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure edSQLEnter(Sender: TObject);
    procedure edSQLGutterClick(Sender: TObject; X, Y, Line: integer;
      mark: TSynEditMark);
    procedure edSQLKeyPress(Sender: TObject; var Key: char);
    procedure edSQLKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edSQLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure edSQLPaint(Sender: TObject; ACanvas: TCanvas);
    procedure edSQLPlaceBookmark(Sender: TObject; var Mark: TSynEditMark);
    procedure edSQLStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure edSQLSynGutterChange(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstfindClick(Sender: TObject);
    procedure dropPostClick(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure miCFunctionClick(Sender: TObject);
    procedure miChartClick(Sender: TObject);
    procedure miCNewEditClick(Sender: TObject);
    procedure miCreateClick(Sender: TObject);
    procedure miCreateliteClick(Sender: TObject);
    procedure miCTriggerClick(Sender: TObject);
    procedure miDescricaoPostClick(Sender: TObject);
    procedure midropClick(Sender: TObject);
    procedure midropliteClick(Sender: TObject);
    procedure miEmbelezarClick(Sender: TObject);
    procedure miEsconderClick(Sender: TObject);
    procedure miFontClick(Sender: TObject);
    procedure miIAClick(Sender: TObject);
    procedure miMostrarClick(Sender: TObject);
    procedure miBenchmarkClick(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure miNovaPesquisaClick(Sender: TObject);
    procedure miOcultarClick(Sender: TObject);
    procedure miOcultarPostClick(Sender: TObject);
    procedure miRelacionamentosClick(Sender: TObject);
    procedure miselectClick(Sender: TObject);
    procedure miselectliteClick(Sender: TObject);
    procedure mnCriaDicionarioClick(Sender: TObject);
    procedure mnCriaDicionarioliteClick(Sender: TObject);
    procedure mnCriarSeqClick(Sender: TObject);
    procedure mnDicionarioClick(Sender: TObject);
    procedure mnFonteClick(Sender: TObject);
    procedure mnLTriggerClick(Sender: TObject);
    procedure mnRefreshClick(Sender: TObject);
    procedure niPesquisarClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SynCompletion1PositionChanged(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
    procedure FieldClickChange(Sender: TObject);
    procedure ToggleBox2Change(Sender: TObject);
    procedure tvMysqlChange(Sender: TObject; Node: TTreeNode);
    procedure tvMysqlClick(Sender: TObject);
    procedure tvPostChange(Sender: TObject; Node: TTreeNode);
    procedure tvPostClick(Sender: TObject);
    procedure tvsqliteChange(Sender: TObject; Node: TTreeNode);
    procedure tvsqliteClick(Sender: TObject);

    function GeraSQLMy(Tabela : TTabela): string;
    function TipoConv(Tabela : TTabela; Posicao: integer): String;
    procedure PostApagaTabela(Nome: string);
    procedure vlistequivalenteClick(Sender: TObject);
    procedure zconpostAfterConnect(Sender: TObject);
    procedure ZPgEventAlerter1Notify(Sender: TObject; Event: string;
      ProcessID: Integer; Payload: string);
  private
    FCHATGPT : TCHATGPT;

    posicaofieldsmy : TTreeNode;
    tvitemmy : TTreeNode;
    posicaoViewmy : TTreeNode;
    posicaoProceduremy : TTreeNode;
    posicaoFunctionmy : TTreeNode;
    viewsmy : TViews;

    posicaofieldspost : TTreeNode;
    tvitempost : TTreeNode;
    tvDatabasePost : TTreeNode;
    tvTablePost : TTreeNode;
    posicaoViewPost : TTreeNode;
    posicaoProcedurePost : TTreeNode;
    posicaoFunctionPost : TTreeNode;
    posicaoSequencePost : TTreeNode;
    viewspost : TViews;
    sequences : TStringList;

    tvitemLite : TTreeNode;
    posicaofieldslite : TTreeNode;

    FPos : integer;
    strFind : String;

    procedure MontaCreateTrigger(Tabela : TTabela; posicao : integer);

    procedure ListarTabelasMy();
    procedure ListarTabelasPost();
    procedure ListarTabelasSQLite();

    procedure ProcuraTVMysql(Nome: String);
    procedure ProcuraTVPost(Nome: String);
    procedure ProcuraTVSQLite(Nome: String);

    procedure BuscaSequence(qry:TZReadOnlyQuery;  TypeDB: TypeDatabase);
    procedure ListarViewsMy();
    procedure ListarViewsPost();

    function FormataSQL(Info : string): string;
    function TrocarPalavra(Info : String; de: String; para : String): String;
    procedure setSelLength(var textComponent:TSynEdit; newValue:integer);
    procedure Analisemy(SQL : String);
    procedure Analisepost(SQL : String);

    function ConectSQLite: Boolean;
  public
    function CriaDicionarioSQLite(const ATargetFile: string): string;
    function BuildCreateTableSQLite(const ATabela: string): string;
    function CriaListaDependenciasSQLite(const outFile: string): string;
    function QuestionarSQLSQLite(const pergunta, deps, ddl: string): string;

    procedure ChartView; overload;
    procedure ChartView(AType: TChartCommType); overload;

    procedure RefreshPost();
    procedure RefreshMy();
    procedure RefreshSQLite();

    procedure Pesquisar(sender: TObject);
    procedure ProcessaErro(message : string);
    function RectIsEmpty(const aRect:TRect):Boolean;
    function ToRect(const aTopLeft, aBottomRight:TPoint):TRect; overload;
    function ToRect(const aTop, aLeft, aBottom, aRight : LongInt):TRect; overload;
    Function RectInRect(const aOuterRect, aInnerRect:TRect):Boolean;

    procedure QuestionSQLChatMy();
    procedure QuestionSQLChatPost();
    procedure QuestionSQLEmbeleza();
    procedure CriaTabela(NomeTabela: string; CSVDataSet: TCSVDataSet; ZQuery: TZQuery);
    procedure MigraCampos(NomeTabela: string; CSVDataSet: TCSVDataSet; ZQuery: TZQuery);

    function ConectPost: Boolean;
    function ConectMy: Boolean;
    function DescreveTabelaIAPost(tabela : string): string;
    function DescreveTabelaIAMy(const tabela: string): string;
    function CriaDicionarioPost(const ATargetFile: string): string;
    function CriaListaDependenciasPost(const outFile: string): string;
    function QuestionarSQLPost(const pergunta, deps, ddl: string): string;
    function ValidaConexao(TipoBanco: Integer ): Boolean;

    procedure OpenSelectPost();
    procedure OpenSelectMy();
    procedure OpenSelectLite();
  end;

var
  frmmquery2: Tfrmmquery2;

implementation

{$R *.lfm}

uses benchmark, main;

function SQLiteSelectedTableName: string;
begin
  Result := '';
  if (frmmquery2 = nil) then Exit;
  if (frmmquery2.tvsqlite.Selected = nil) then Exit;

  if frmmquery2.tvsqlite.Selected.Parent = frmmquery2.posicaofieldslite then
    Exit(frmmquery2.tvsqlite.Selected.Text);

  if (frmmquery2.tvsqlite.Selected.Parent <> nil) and
     (frmmquery2.tvsqlite.Selected.Parent.Data = Pointer(ETDBCampos)) and
     (frmmquery2.tvsqlite.Selected.Parent.Parent <> nil) then
    Exit(frmmquery2.tvsqlite.Selected.Parent.Parent.Text);

  if (frmmquery2.tvsqlite.Selected.Data = Pointer(ETDBCampos)) and
     (frmmquery2.tvsqlite.Selected.Parent <> nil) then
    Exit(frmmquery2.tvsqlite.Selected.Parent.Text);
end;

procedure Tfrmmquery2.ChartView;
var
  t: TChartCommType;
begin
  if Assigned(zpostqry1) and zpostqry1.Active then
    t := ccPostgres
  else if Assigned(zmyqry2) and zmyqry2.Active then
    t := ccMySQL
  else
  begin
    ShowMessage('Nenhum resultado ativo para plotar.');
    Exit;
  end;
  ChartView(t);
end;

procedure Tfrmmquery2.ChartView(AType: TChartCommType);
begin
  if (frmChart = nil) then
    frmChart := TfrmChart.Create(self);

  frmChart.CommType := AType;
  frmChart.Show;
end;

procedure Tfrmmquery2.QuestionSQLChatMy();
var
  resposta : string;
  codigo : TCodigo;
  item : TFonte;
  i : integer;
  tabelaList: TStringList;
begin
  tabelaList := TStringList.Create;
  frmMNote.NewContext();
  frmMNote.edChat.Text := sqltabela + edSQL.Text + ' faça em uma caixa de texto';
  frmMNote.FazPergunta();

  if (frmMNote.meCodes.Text <> '') then
  begin
    resposta := frmMNote.meCodes.Text;
    codigo := TCodigo.Create;
    codigo.AnalisaTexto(resposta);

    try
      for i := 0 to codigo.Count-1 do
      begin
        item := TFonte(codigo.Items[i]);
        tabelaList := CapturaJSONTabela(item.codigo);
        lbTables.Items.AddStrings(tabelaList);
      end;
    finally
      tabelaList.Free;
      codigo.Free;
    end;
  end;
end;

procedure Tfrmmquery2.QuestionSQLChatPost();
var
  resposta : string;
  codigo : TCodigo;
  item : TFonte;
  i : integer;
  tabelaList: TStringList;
begin
  tabelaList := TStringList.Create;
  frmMNote.NewContext();
  frmMNote.edChat.Text := sqltabela + edSQLPost.Text + ' faça em uma caixa de texto';
  frmMNote.FazPergunta();

  if (frmMNote.meCodes.Text <> '') then
  begin
    resposta := frmMNote.meCodes.Text;
    codigo := TCodigo.Create;
    codigo.AnalisaTexto(resposta);

    try
      for i := 0 to codigo.Count-1 do
      begin
        item := TFonte(codigo.Items[i]);
        tabelaList := CapturaJSONTabela(item.codigo);
        lbTables.Items.AddStrings(tabelaList);
      end;
    finally
      tabelaList.Free;
      codigo.Free;
    end;
  end;
end;

procedure Tfrmmquery2.QuestionSQLEmbeleza;
begin
  frmMNote.NewContext();
  frmMNote.edChat.Text := sqlEstetica + edSQL.Text;
  frmMNote.FazPergunta();
  if (frmMNote.meCodes.Text <> '') then
    edSQL.Text := frmMNote.meCodes.Text;
end;

procedure Tfrmmquery2.CriaTabela(NomeTabela: string; CSVDataSet: TCSVDataset; ZQuery: TZQuery);
var
  SQLCreateTable: string;
  i: Integer;
  FD: TFieldDef;
  sep: string = ', ';
begin
  SQLCreateTable := 'CREATE TABLE ' + JuntaNome(NomeTabela) + ' (';

  for i := 0 to CSVDataSet.FieldDefs.Count - 1 do
  begin
    FD := CSVDataSet.FieldDefs[i];
    SQLCreateTable += JuntaNome(FD.Name) + ' ';

    case FD.DataType of
      ftString:  SQLCreateTable += 'VARCHAR(' + IntToStr(Max(FD.Size, 1)) + ')';
      ftInteger: SQLCreateTable += 'INTEGER';
      ftFloat:   SQLCreateTable += 'FLOAT';
      ftBoolean: SQLCreateTable += 'BOOLEAN';
    else
      SQLCreateTable += 'TEXT';
    end;

    if i < CSVDataSet.FieldDefs.Count - 1 then
      SQLCreateTable += sep;
  end;

  SQLCreateTable += ');';

  try
    ZQuery.SQL.Text := SQLCreateTable;
    ZQuery.ExecSQL;
  except
    on E: Exception do
      ShowMessage('Erro ao criar a tabela: ' + E.Message);
  end;
end;

procedure Tfrmmquery2.MigraCampos(NomeTabela: string; CSVDataSet: TCSVDataset; ZQuery: TZQuery);
var
  SQLInsert, colVals: string;
  i: Integer;
begin
  if not CSVDataSet.Active then
    CSVDataSet.Open;

  CSVDataSet.First;
  while not CSVDataSet.EOF do
  begin
    colVals := '';
    for i := 0 to CSVDataSet.Fields.Count - 1 do
    begin
      if i > 0 then colVals += ', ';
      colVals += QuotedStr(CSVDataSet.Fields[i].AsString);
    end;

    SQLInsert := 'INSERT INTO ' + JuntaNome(NomeTabela) + ' VALUES (' + colVals + ');';
    ZQuery.SQL.Text := SQLInsert;
    ZQuery.ExecSQL;

    CSVDataSet.Next;
  end;

  CSVDataSet.Close;
end;

procedure Tfrmmquery2.FieldClickChange(Sender: TObject);
begin
  edSQL.Clear;
  edSQL.Text := 'ok';
end;

procedure Tfrmmquery2.ToggleBox2Change(Sender: TObject);
var
  usuario, senha: string;
begin
  if zconpost.Connected then
  begin
    usuario := InputBox('Criação de usuário', 'Usuário:', 'username');
    senha   := InputBox('Criação de usuário', 'Senha:', 'secret');

    edSQL.Text := Format('CREATE USER %s WITH PASSWORD %s;',
                         [JuntaNome(usuario), QuotedStr(senha)]);
    zqrypost.SQL.Text := edSQL.Text;
    zqrypost.ExecSQL;
  end
  else
    ShowMessage('Postgres não conectado!');
end;

function Tfrmmquery2.TrocarPalavra(Info: String; de: String; para: String): String;
begin
  Result := StringReplace(Info, de, para, [rfReplaceAll, rfIgnoreCase]);
end;

function Tfrmmquery2.FormataSQL(Info: string): string;
var
  r: Integer;
begin
  Info := StringReplace(Info, '`', '', [rfReplaceAll]);

  Info := TrocarPalavra(Info, 'FROM',     LineEnding + 'FROM');
  Info := TrocarPalavra(Info, 'WHERE',    LineEnding + 'WHERE');
  Info := TrocarPalavra(Info, 'SELECT',   LineEnding + 'SELECT');
  Info := TrocarPalavra(Info, 'INSERT',   LineEnding + 'INSERT');
  Info := TrocarPalavra(Info, 'UPDATE',   LineEnding + 'UPDATE');
  Info := TrocarPalavra(Info, 'ORDER BY', LineEnding + 'ORDER BY');
  Info := TrocarPalavra(Info, 'GROUP BY', LineEnding + 'GROUP BY');
  Info := TrocarPalavra(Info, 'THEN',     'THEN' + LineEnding);
  Info := TrocarPalavra(Info, 'ELSE',     LineEnding + 'ELSE' + LineEnding);
  Info := TrocarPalavra(Info, 'BEGIN',    LineEnding + 'BEGIN' + LineEnding);
  Info := TrocarPalavra(Info, 'END IF;',  LineEnding + 'END IF;' + LineEnding);
  Info := TrocarPalavra(Info, 'END;',     LineEnding + 'END;' + LineEnding);

  if Assigned(vlistequivalente) then
    for r := 1 to vlistequivalente.RowCount - 1 do
      Info := TrocarPalavra(Info, vlistequivalente.Cells[0, r], vlistequivalente.Cells[1, r]);

  Result := Info;
end;

procedure Tfrmmquery2.MontaCreateTrigger(Tabela: TTabela; posicao: integer);
begin
  edsql.Lines.Clear;
  edsql.Lines.Append('create or replace function '+tabela.triggers.Triggername[posicao]+ '() ');
  edsql.Lines.Append('RETURNS TRIGGER as $'+  tabela.triggers.Triggername[posicao] +'$ ');
  edsql.Lines.Append('BEGIN ');
  edsql.Lines.Append(' RETURN NULL; -- resultado é ignorado ');
  edsql.Lines.Append(' END; ');
  edsql.Lines.Append('$'+tabela.triggers.Triggername[posicao]+'$ LANGUAGE plpgsql;');
  edsql.Lines.Append('create TRIGGER '+tabela.triggers.Triggername[posicao]+ ' ');
  edsql.Lines.Append(Tabela.triggers.Time[posicao]+ ' ' +tabela.triggers.Event[posicao] );
  edsql.Lines.Append(' on '+ tabela.triggers.tablename);
  edsql.Lines.Append(' FOR EACH ROW ');
  edsql.Lines.Append('execute function '+tabela.triggers.Triggername[posicao]+'();');
end;

procedure Tfrmmquery2.tvMysqlChange(Sender: TObject; Node: TTreeNode);
var
  posicao : integer;
  tvBisavo : TTreeNode;
  tvAvo : TTreeNode;
  tvPai : TTreeNode;
  view : TView;
  Tabela : TTabela;
begin
  tvPai := nil;
  tvAvo := nil;
  tvBisavo := nil;
  tvMysql.PopupMenu := nil;

  if node <> nil then
  begin
    if (node.Parent <> nil) then
    begin
      if (node.parent = posicaofieldsmy) then
      begin
        if Node.data <> nil then
          tvMysql.PopupMenu := pmTabelasMy
        else
          edsql.Text := 'no data';
      end
      else
        edSQL.Text := '';

      tvPai := node.Parent;
      if tvPai <> nil then tvAvo := tvPai.Parent;
      if tvAvo <> nil then tvBisavo := tvAvo.Parent;

      if (tvPai = posicaoViewmy) then
      begin
        View := TView.Create(zmyqry1, node.Text, edBancoPost.Text, DBMysql);
        edsql.Text := FormataSQL(View.definicao.Text);
        View.Free;
      end;

      if (tvBisavo = posicaofieldsmy) then
      begin
        if (tvPai.Text = 'Primary Key') then
          tvMysql.PopupMenu := popSeq;

        if ((integer(tvPai.Data)) = IsETDTriggers()) then
        begin
          tvMysql.PopupMenu := popmenuTrigger;
          Tabela := TTabela(TObject(tvAvo.Data));
          posicao := Tabela.triggers.Triggername.IndexOf(node.Text);
          MontaCreateTrigger(Tabela, posicao);
        end;
      end;

      if (node = posicaofieldsmy) then
        tvMysql.PopupMenu := pmTabelasMy;
    end;
  end;
end;

procedure Tfrmmquery2.tvMysqlClick(Sender: TObject);
begin
end;

function Tfrmmquery2.GeraSQLMy(Tabela: TTabela): string;
var
  Comando: string;
  a: Integer;
begin
  Comando := '--Criado por MQuery2 em ' + DateToStr(Now) + LineEnding;
  Comando += 'CREATE TABLE ' + edSchemaPost.Text + '.' + Tabela.TableName + '(' + LineEnding;

  for a := 0 to Tabela.Count - 1 do
  begin
    if a > 0 then Comando += ',' + LineEnding;
    Comando += '  ' + Tabela.FieldName[a] + ' ' + TipoConv(Tabela, a);
  end;
  Comando += LineEnding;

  if Tabela.Chaves.PrimaryKeys.Count > 0 then
  begin
    Comando += ', PRIMARY KEY (';
    for a := 0 to Tabela.Chaves.PrimaryKeys.Count - 1 do
    begin
      if a > 0 then Comando += ',';
      Comando += Tabela.Chaves.PrimaryKeys[a];
    end;
    Comando += ')' + LineEnding;
  end;

  if Tabela.Chaves.CoinstraintName.Count > 0 then
  begin
    for a := 0 to Tabela.Chaves.CoinstraintName.Count - 1 do
    begin
      Comando += ', CONSTRAINT ' + Tabela.Chaves.CoinstraintName[a] +
                 ' FOREIGN KEY (' + Tabela.Chaves.CoinstraintColumn_Name[a] + ')' +
                 ' REFERENCES ' + Tabela.Chaves.Coinstraint_Reference_Table_Name[a] +
                 '(' + Tabela.Chaves.Coinstraint_Reference_Column_Name[a] + ')' + LineEnding;
    end;
  end;

  Comando += ');' + LineEnding;

  for a := 0 to Tabela.FieldName.Count - 1 do
    if Tabela.FieldComment[a] <> '' then
      Comando += 'COMMENT ON COLUMN ' + edSchemaPost.Text + '.' + Tabela.TableName + '.' +
                 Tabela.FieldName[a] + ' IS ' + QuotedStr(Tabela.FieldComment[a]) + ';' + LineEnding;

  Result := Comando;
end;

function Tfrmmquery2.TipoConv(Tabela: TTabela; Posicao: integer): String;
var
  output : string;
begin
  output := '';

  if Tabela.fieldtype[posicao] = 'char' then
    output := 'char('+Tabela.fieldstrtam[posicao]+')';
  if Tabela.fieldtype[posicao] = 'varchar' then
    output := 'varchar('+Tabela.fieldstrtam[posicao]+')';
  if Tabela.fieldtype[posicao] = 'text' then
    output := 'text';
  if Tabela.fieldtype[posicao] = 'tinyblob' then
    output := 'tinyblob';
  if Tabela.fieldtype[posicao] = 'mediumtext' then
    output := 'text';

  if Tabela.fieldtype[posicao] = 'smallint' then
    output := 'smallint';
  if Tabela.fieldtype[posicao] = 'decimal' then
    output := 'decimal('+Tabela.fieldnro_precision[posicao]+','+Tabela.fieldbintam[posicao]+')';
  if Tabela.fieldtype[posicao] = 'float' then
    output := 'float('+Tabela.fieldbintam[posicao]+','+Tabela.fieldnro_precision[posicao]+')';
  if Tabela.fieldtype[posicao] = 'real' then
    output := 'real';

  if Tabela.fieldtype[posicao] = 'int' then
  begin
    if (Tabela.fieldcolumnkey[posicao] = 'PRI') then
      output := 'integer'
    else
    begin
      if StrToIntDef(Tabela.fieldnro_precision[posicao], 0) < 3 then
        output := 'smallint'
      else if (StrToIntDef(Tabela.fieldnro_precision[posicao], 0) >= 3) and
              (StrToIntDef(Tabela.fieldnro_precision[posicao], 0) < 8) then
        output := 'integer'
      else
        output := 'decimal('+Tabela.fieldnro_precision[posicao]+')';
    end;
  end;

  if Tabela.fieldtype[posicao] = 'integer' then
    output := 'integer';

  if Tabela.fieldtype[posicao] = 'date' then output := 'date';
  if Tabela.fieldtype[posicao] = 'datetime' then output := 'timestamp';
  if Tabela.fieldtype[posicao] = 'Time' then output := 'time';
  if Tabela.fieldtype[posicao] = 'year' then output := 'interval[YEAR]';
  if Tabela.fieldtype[posicao] = 'time' then output := 'time';

  if Tabela.fieldtype[posicao] = 'blob' then output := 'bytea';
  if Tabela.fieldtype[posicao] = 'longblob' then output := 'bytea';

  if not (Tabela.fieldnullable[posicao] = 'YES') then
    output := output + ' NOT NULL ';

  Result := output;
end;

procedure Tfrmmquery2.ProcuraTVMysql(Nome: String);
var
  tv : TTreenode;
begin
  tv := posicaofieldsmy.FindNode(nome);
  if (tv <> nil) then tvMysql.Select(tv);
end;

procedure Tfrmmquery2.ProcuraTVPost(Nome: String);
var
  tv : TTreenode;
begin
  tv := posicaofieldspost.FindNode(nome);
  if (tv <> nil) then tvPost.Select(tv);
end;

procedure Tfrmmquery2.ProcuraTVSQLite(Nome: String);
var
  tv : TTreenode;
begin
  if posicaofieldslite = nil then Exit;
  tv := posicaofieldslite.FindNode(Nome);
  if (tv <> nil) then tvsqlite.Select(tv);
end;

procedure Tfrmmquery2.tvPostChange(Sender: TObject; Node: TTreeNode);
begin
  if(node = tvDatabasePost) then
    tvPost.PopupMenu := pmDatabasePost
  else
  begin
    if(node = tvTablePost) then
    begin
      ProcuraTVPost(Node.Text);
      tvPost.PopupMenu := pmTabelasPost;
    end
    else
    begin
      if (node <> nil) then
      begin
        if(node.ImageIndex= 14) then
          tvPost.PopupMenu := pmTabelaPost
        else
          tvPost.PopupMenu := nil;
      end
      else
        tvPost.PopupMenu := nil;
    end;
  end;
end;

procedure Tfrmmquery2.tvPostClick(Sender: TObject);
begin
end;

procedure Tfrmmquery2.tvsqliteChange(Sender: TObject; Node: TTreeNode);
var
  tvPai, tvAvo: TTreeNode;
begin
  tvsqlite.PopupMenu := nil;
  if Node = nil then Exit;

  tvPai := Node.Parent;
  tvAvo := nil;
  if tvPai <> nil then
    tvAvo := tvPai.Parent;

  if Node = tvitemLite then
  begin
    tvsqlite.PopupMenu := pmDatabaseLite;
    Exit;
  end;

  if Node = posicaofieldslite then
  begin
    tvsqlite.PopupMenu := pmTabelasLite;
    Exit;
  end;

  if (tvPai = posicaofieldslite) then
  begin
    tvsqlite.PopupMenu := pmTabelaLite;
    Exit;
  end;

  if (Node.Data = Pointer(ETDBCampos)) then
  begin
    tvsqlite.PopupMenu := popSQLLite;
    Exit;
  end;

  if (tvPai <> nil) and (tvPai.Data = Pointer(ETDBCampos)) then
  begin
    tvsqlite.PopupMenu := popSQLLite;
    Exit;
  end;

  tvsqlite.PopupMenu := nil;
end;

procedure Tfrmmquery2.tvsqliteClick(Sender: TObject);
var
  tbl: string;
begin
  tbl := SQLiteSelectedTableName;
  if Trim(tbl) <> '' then
    edPesqsqlite.Text := tbl;

  if (tvsqlite.Selected <> nil) and
     (tvsqlite.Selected.Parent = posicaofieldslite) then
  begin
    ProcuraTVSQLite(tvsqlite.Selected.Text);
    Exit;
  end;
end;

procedure Tfrmmquery2.FormCreate(Sender: TObject);
var
  tvitem : TTreeNode;
begin
  TrayIcon1.Visible := True;
  pgMain.PageIndex := 0;
  pgMysql.PageIndex := 0;

  tvitem := TTreeNode.Create(tvMysql.Items);
  tvitemmy := tvMysql.Items.AddObject(tvitem,'mysql', pointer(ETDBBanco));
  tvitemmy.ImageIndex := -1;

  tvitem := TTreeNode.Create(tvPost.Items);
  tvitempost := tvPost.Items.AddObject(tvitem,'Postgres', pointer(ETDBBanco));
  tvitempost.ImageIndex := -1;

  tvitem := TTreeNode.Create(tvsqlite.Items);
  tvitemLite := tvsqlite.Items.AddObject(tvitem,'SQLite', pointer(ETDBBanco));
  tvitemLite.ImageIndex := -1;

  {$IFDEF WINDOWS}
  zconpost.LibraryLocation := FSetMain.DLLPostPath;
  zconmysql.LibraryLocation := FSetMain.DLLMyPath;
  {$ENDIF}

  {$IFDEF LINUX}
  if (FSetMain.DLLPostPath<> '') then
    zconpost.LibraryLocation := FSetMain.DLLPostPath
  else
    ShowMessage('Set Postgre Path in config');

  if (FSetMain.DLLMyPath<>'') then
    zconmysql.LibraryLocation := FSetMain.DLLMyPath
  else
    ShowMessage('Set Mysql Path in config');
  {$ENDIF}

  edHostNamePost.Text := FSetmain.HostnamePost;
  edBancoPost.Text := FSetmain.BancoPOST;
  edusuarioPost.Text := FSetmain.UsernamePost;
  edPasswrdPost.Text := FSetmain.PasswordPost;
  edSchemaPost.Text := FSetmain.SchemaPost;
  edDatabase.Text := FSetMain.BancoSQLite;
end;

procedure Tfrmmquery2.setSelLength(var textComponent:TSynEdit; newValue:integer);
begin
  textComponent.SelEnd := textComponent.SelStart + newValue;
end;

procedure Tfrmmquery2.Analisemy(SQL: String);
begin
  lbTables.Items.Clear;
  QuestionSQLChatMy();
end;

procedure Tfrmmquery2.Analisepost(SQL: String);
begin
  lbTables.Items.Clear;
  QuestionSQLChatPost();
end;

procedure Tfrmmquery2.lstfindClick(Sender: TObject);
var
  find : TFinds;
begin
  if lstFind.SelCount > 0 then
  begin
    find := TFINDS(lstFind.items.objects[lstFind.ItemIndex]);
    FPOS := find.IPOS;
    FPos := find.IPos + length(find.strFind);
    find.syn.SetFocus;
    Self.ActiveControl := find.syn;
    find.syn.SelStart := find.IPos;
    setSelLength(find.syn, find.FLen);
    FPos := FPos + find.FLen - 1;
  end;
end;

procedure Tfrmmquery2.dropPostClick(Sender: TObject);
var
  item : TTreeNode;
  schema, tableName: string;
begin
  item := tvPost.Selected;
  if item = nil then Exit;

  tableName := item.Text;

  if Trim(edSchemaPost.Text) <> '' then
    schema := edSchemaPost.Text + '.'
  else
    schema := '';

  edSQL.Clear;
  edSQL.Lines.Text := '';
  edSQL.Lines.Append('DROP TABLE IF EXISTS ' + schema + tableName + ' CASCADE;');
  pcPostgree.ActivePage := tbSQL;
end;

procedure Tfrmmquery2.MenuItem12Click(Sender: TObject);
var
  a : integer;
begin
  for a := 0 to tvMysql.Items.Count-1 do
    if ((tvMysql.items[a].Parent = posicaofieldsmy) and
        (tvMysql.items[a].Parent.Data = pointer(ETDTabelas)) ) then
      tvMysql.items[a].Collapse(true);
end;

procedure Tfrmmquery2.PostApagaTabela(Nome: string);
begin
  edSQL.Text := 'drop table ' + Nome;
  zpostqry.SQL.Text := edSQL.Text;
  try
    zpostqry.ExecSQL;
    edSQL.Append('Executado com sucesso!');
  except
    ShowMessage('Falha na execução');
  end;
end;

procedure Tfrmmquery2.vlistequivalenteClick(Sender: TObject);
begin
end;

procedure Tfrmmquery2.zconpostAfterConnect(Sender: TObject);
begin
end;

procedure Tfrmmquery2.ZPgEventAlerter1Notify(Sender: TObject; Event: string;
  ProcessID: Integer; Payload: string);
begin
end;

procedure Tfrmmquery2.MenuItem1Click(Sender: TObject);
var
  nome : string;
begin
  nome := tvPost.Selected.Text;
  PostApagaTabela(nome);
end;

procedure Tfrmmquery2.MenuItem5Click(Sender: TObject);
begin
  SaveDialog1.Title := 'Salvar SQL';
  if SaveDialog1.Execute then
    edSQL.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure Tfrmmquery2.MenuItem6Click(Sender: TObject);
begin
end;

procedure Tfrmmquery2.MenuItem8Click(Sender: TObject);
begin
  pnBotton.Visible := false;
end;

procedure Tfrmmquery2.miCFunctionClick(Sender: TObject);
var
  tvAvo : TTreeNode;
  tvPai : TTreeNode;
  Tabela : TTabela;
  posicao : integer;
  Node: TTreeNode;
begin
  Node := tvMysql.Selected;
  tvPai := Node.Parent;
  tvAvo := tvPai.Parent;
  Tabela := TTabela(TObject(tvAvo.Data));
  posicao := Tabela.triggers.Triggername.IndexOf(node.Text);

  edsql.Lines.Clear;
  edsql.Lines.Append('create or replace function '+tabela.triggers.Triggername[posicao]+ '() ');
  edsql.Lines.Append('RETURNS TRIGGER as $'+  tabela.triggers.Triggername[posicao] +'$ ');
  edsql.Text := edsql.Text + FormataSQL(tabela.triggers.Source[posicao]);
  edsql.Lines.Append(' RETURN NULL; -- resultado é ignorado ');
  edsql.Lines.Append(' END; ');
  edsql.Lines.Append('$'+tabela.triggers.tablename+'$ LANGUAGE plpgsql; ');
end;

procedure Tfrmmquery2.miChartClick(Sender: TObject);
begin
  ChartView();
end;

procedure Tfrmmquery2.miCNewEditClick(Sender: TObject);
var
  ts : TTabSheet;
  item : TItem;
  syn1 : TSynEdit;
begin
  ts := frmMNote.NovoItem();
  item := TItem(ts.Tag);
  syn1 := item.syn;
  syn1.Text := edsql.Lines.Text;
end;

procedure Tfrmmquery2.miCreateClick(Sender: TObject);
begin
  edsql.Text := GeraSQLMy(TTabela(tvMysql.Selected.Data));
end;

procedure Tfrmmquery2.miCreateliteClick(Sender: TObject);
var
  tbl, ddl: string;
begin
  tbl := SQLiteSelectedTableName;
  if Trim(tbl) = '' then
  begin
    ShowMessage('Selecione uma tabela no SQLite.');
    Exit;
  end;

  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  zliteqry.Close;
  zliteqry.SQL.Text :=
    'SELECT sql '+
    'FROM sqlite_master '+
    'WHERE (type = ''table'' OR type = ''view'') '+
    '  AND name = :name';
  zliteqry.ParamByName('name').AsString := tbl;
  zliteqry.Open;

  ddl := '';
  if not zliteqry.IsEmpty then
    ddl := zliteqry.Fields[0].AsString;

  edSQL1.Clear;
  if Trim(ddl) <> '' then
    edSQL1.Lines.Text := ddl + ';'
  else
    edSQL1.Lines.Text := '-- Não encontrei o CREATE no sqlite_master para: ' + tbl;

  pgSQLite.ActivePage := tbSQL1;
end;

procedure Tfrmmquery2.miCTriggerClick(Sender: TObject);
var
  tvAvo : TTreeNode;
  tvPai : TTreeNode;
  Tabela : TTabela;
  posicao : integer;
  Node: TTreeNode;
begin
  Node := tvMysql.Selected;
  tvPai := Node.Parent;
  tvAvo := tvPai.Parent;
  Tabela := TTabela(TObject(tvAvo.Data));
  posicao := Tabela.triggers.Triggername.IndexOf(node.Text);

  edsql.Lines.Clear;
  edsql.Lines.Append('create or replace trigger '+tabela.triggers.Triggername[posicao]+ ' ');
  edsql.Lines.Append(Tabela.triggers.Time[posicao]+ ' ' +tabela.triggers.Event[posicao] );
  edsql.Lines.Append(' on '+ tabela.triggers.tablename);
  edsql.Text := edsql.Text + ' FOR EACH ROW ';
  edsql.Text := edsql.Text + 'execute function fnc_'+tabela.triggers.Triggername[posicao]+'();';
end;

procedure Tfrmmquery2.miDescricaoPostClick(Sender: TObject);
var
  item : ttreenode;
begin
  item := tvPost.Selected;
  edSQLPost.Text := DescreveTabelaIAPost(item.Text);
  pcPostgree.ActivePage := tsSQLPostgreSQL;
end;

procedure Tfrmmquery2.midropClick(Sender: TObject);
var
  item : ttreenode;
begin
  item := tvMysql.Selected;
  edSQL.Clear;
  edSQL.Lines.Text := '';
  edSql.Lines.Append('drop table '+ item.Text );
  pgMysql.ActivePage := tbSQL;
end;

procedure Tfrmmquery2.midropliteClick(Sender: TObject);
var
  tbl: string;
begin
  tbl := SQLiteSelectedTableName;
  if Trim(tbl) = '' then
  begin
    ShowMessage('Selecione uma tabela no SQLite.');
    Exit;
  end;

  edSQL1.Clear;
  edSQL1.Lines.Text := '';
  edSQL1.Lines.Append('DROP TABLE IF EXISTS ' + tbl + ';');
  pgSQLite.ActivePage := tbSQL1;
end;

procedure Tfrmmquery2.miEmbelezarClick(Sender: TObject);
begin
  QuestionSQLEmbeleza();
end;

procedure Tfrmmquery2.miEsconderClick(Sender: TObject);
begin
  Hide;
end;

procedure Tfrmmquery2.miFontClick(Sender: TObject);
begin
  FontDialog1.Font := edSQL.Font;
  if FontDialog1.Execute then
    edSQL.Font := FontDialog1.Font;
end;

procedure Tfrmmquery2.miIAClick(Sender: TObject);
begin
  pnIA.Visible := not pnIA.Visible;
end;

procedure Tfrmmquery2.miMostrarClick(Sender: TObject);
begin
  Show;
end;

procedure Tfrmmquery2.miBenchmarkClick(Sender: TObject);
begin
  frmBenchmark := TfrmBenchmark.Create(self);
  frmBenchmark.ShowModal;
end;

procedure Tfrmmquery2.MenuItem9Click(Sender: TObject);
begin
  exit;
end;

procedure Tfrmmquery2.miNovaPesquisaClick(Sender: TObject);
begin
  FPos := 0;
  FindDialog1.Execute;
end;

procedure Tfrmmquery2.miOcultarClick(Sender: TObject);
var
  a : integer;
begin
  for a:= 0 to tvPost.Items.Count-1 do
    if ((tvPost.items[a].Parent = posicaofieldspost) and
        (tvPost.items[a].Parent.Data = pointer(ETDTabelas)) ) then
      tvPost.items[a].Collapse(true);
end;

procedure Tfrmmquery2.miOcultarPostClick(Sender: TObject);
begin
end;

procedure Tfrmmquery2.miRelacionamentosClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);

  if (pgMain.ActivePage = liteMain) or ((not zconpost.Connected) and zconsqlite.Connected) then
  begin
    fileName := IncludeTrailingPathDelimiter(baseDir) + 'dependencias_sqlite.sql';
    edSQL1.Text := CriaListaDependenciasSQLite(fileName);
    pgSQLite.ActivePage := tbSQL1;
    ShowMessage('Dependências SQLite salvas em:' + LineEnding + fileName);
  end
  else
  begin
    fileName := IncludeTrailingPathDelimiter(baseDir) + 'dependencias_post.sql';
    edSQLPost.Text := CriaListaDependenciasPost(fileName);
    ShowMessage('Dependências salvas em:' + LineEnding + fileName);
  end;
end;

procedure Tfrmmquery2.miselectClick(Sender: TObject);
var
  item : ttreenode;
begin
  item := tvMysql.Selected;
  edSQL.Clear;
  edSQL.Lines.Text := '';
  edSql.Lines.Append('select * from '+ item.Text + ' limit 1000 ');
  pgMysql.ActivePage := tbSQL;
end;

procedure Tfrmmquery2.miselectliteClick(Sender: TObject);
var
  tbl: string;
begin
  tbl := SQLiteSelectedTableName;
  if Trim(tbl) = '' then
  begin
    ShowMessage('Selecione uma tabela no SQLite.');
    Exit;
  end;

  edSQL1.Clear;
  edSQL1.Lines.Text := '';
  edSQL1.Lines.Append('SELECT * FROM ' + tbl + ' LIMIT 1000;');
  pgSQLite.ActivePage := tbSQL1;
end;

procedure Tfrmmquery2.mnCriaDicionarioClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario.sql';

  edSQLPost.Text := CriaDicionarioPost(fileName);
  pcPostgree.ActivePage := tsSQLPostgreSQL;
end;

procedure Tfrmmquery2.mnCriaDicionarioliteClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario_sqlite.sql';

  edSQL1.Text := CriaDicionarioSQLite(fileName);
  pgSQLite.ActivePage := tbSQL1;

  ShowMessage('Dicionário SQLite salvo em:' + LineEnding + fileName);
end;

procedure Tfrmmquery2.mnCriarSeqClick(Sender: TObject);
var
  item : ttreenode;
begin
  item := tvMysql.Selected;
  edSQL.Clear;
  edSql.Lines.Append('--Sequence criada tabela '+ item.Parent.Parent.Text);
  edsql.Lines.Append('create sequence sq_'+item.Text);
  edsql.Lines.Append(' INCREMENT 1 ');
  edSQL.Lines.Append('START 1;');
  pgMain.ActivePage := tbSQL;
  edSql.SetFocus;
end;

procedure Tfrmmquery2.mnDicionarioClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario.sql';

  edSQLPost.Text := CriaDicionarioPost(fileName);
  ShowMessage('Dicionário salvo em:' + LineEnding + fileName);
end;

procedure Tfrmmquery2.mnFonteClick(Sender: TObject);
begin
  miFontClick(sender);
end;

procedure Tfrmmquery2.mnLTriggerClick(Sender: TObject);
var
  a : integer;
  pai : TTreeNode;
  contador : integer;
begin
  edSQL.Lines.Clear;
  contador := 0;
  pai := nil;
  edSQL.Lines.Append('Relação de Triggers do Mysql');

  for a := 0 to tvMysql.Items.Count-1 do
  begin
    if (tvMysql.Items[a].Data =  pointer(ETDTriggers))  then
    begin
      if (TtreeNode(tvMysql.Items[a].Parent).Text <> 'campos') then
      begin
        pai := tvMysql.Items[a];
        edSQL.Lines.Append(' ');
        edSQL.Lines.Append('Tabela:'+ TtreeNode(tvMysql.Items[a].Parent).Text);
      end;
    end
    else if (tvMysql.Items[a].Parent = pai) and (pai <> nil) then
    begin
      edSQL.Lines.Append('Trigger:'+ tvMysql.Items[a].Text);
      Inc(contador);
    end;
  end;

  edSql.Lines.Append('Total de Triggers:'+IntToStr(contador));
end;

procedure Tfrmmquery2.mnRefreshClick(Sender: TObject);
begin
  ListarTabelasPost();
end;

procedure Tfrmmquery2.niPesquisarClick(Sender: TObject);
begin
  strFind := findDialog1.FindText;
  Pesquisar(Sender);
end;

procedure Tfrmmquery2.PageControl1Change(Sender: TObject);
begin
end;

procedure Tfrmmquery2.SpeedButton1Click(Sender: TObject);
begin
  vlistequivalente.RowCount := vlistequivalente.RowCount + 1;
end;

procedure Tfrmmquery2.SpeedButton2Click(Sender: TObject);
begin
  if (vlistequivalente.RowCount > 1) then
    vlistequivalente.RowCount := vlistequivalente.RowCount - 1;
end;

procedure Tfrmmquery2.SynCompletion1PositionChanged(Sender: TObject);
begin
end;

procedure Tfrmmquery2.ToggleBox1Change(Sender: TObject);
begin
end;

function Tfrmmquery2.ConectMy: Boolean;
begin
  Result := False;

  if zconmysql.Connected then
    zconmysql.Disconnect;

  {$IFDEF WINDOWS}
  if (FSetMain <> nil) and (FSetMain.DLLMyPath <> '') then
    zconmysql.LibraryLocation := FSetMain.DLLMyPath
  else
    zconmysql.LibraryLocation := ExtractFilePath(Application.ExeName) + 'libmysql.dll';
  {$ENDIF}

  {$IFDEF LINUX}
  zconmysql.LibraryLocation := ExtractFilePath(Application.ExeName) + 'libs/linux64/libmysqlclient.so.21';
  {$ENDIF}

  zconmysql.Database := edBanco.Text;
  zconmysql.HostName := edHostName.Text;
  zconmysql.User     := edusuario.Text;
  zconmysql.Password := edPasswrd.Text;

  if FSetMain <> nil then
  begin
    FSetMain.HostnameMy   := edHostName.Text;
    FSetMain.BancoMy      := edBanco.Text;
    FSetMain.UsernameMy   := edusuario.Text;
    FSetMain.PasswordMy   := edPasswrd.Text;
  end;

  try
    zconmysql.Connect;
    Result := zconmysql.Connected;
  except
    Result := False;
  end;
end;

function Tfrmmquery2.ConectPost: Boolean;
begin
  Result := False;

  if zconpost.Connected then
    zconpost.Disconnect;

  {$IFDEF WINDOWS}
  if (FSetMain <> nil) and (FSetMain.DLLPostPath <> '') then
    zconpost.LibraryLocation := FSetMain.DLLPostPath
  else
    zconpost.LibraryLocation := ExtractFilePath(Application.ExeName) + 'libpq74.dll';
  {$ENDIF}

  {$IFDEF LINUX}
  zconpost.LibraryLocation := ExtractFilePath(Application.ExeName) + '/libs/linux64/libpq74.so';
  zconmysql.LibraryLocation := ExtractFilePath(Application.ExeName) + '/libs/linux64/libmysqlclient.so.21';
  {$ENDIF}

  zconpost.HostName := edHostNamePost.Text;
  zconpost.User     := edusuarioPost.Text;
  zconpost.Password := edPasswrdPost.Text;
  if Assigned(edBancoPost) then
    zconpost.Database := edBancoPost.Text;

  FSetmain.HostnamePost  := edHostNamePost.Text;
  FSETMAIN.SchemaPost    := edSchemaPost.Text;
  FSetmain.BancoPOST     := edBancoPost.Text;
  FSetmain.UsernamePost  := edusuarioPost.Text;
  FSetmain.PasswordPost  := edPasswrdPost.Text;
  FSetMain.SalvaContexto(false);

  try
    zconpost.Connect;
    Result := zconpost.Connected;
  except
    Result := False;
  end;
end;

function Tfrmmquery2.ConectSQLite: Boolean;
begin
  Result := False;

  if zconsqlite.Connected then
    zconsqlite.Disconnect;

  zconsqlite.Protocol := 'sqlite';
  zconsqlite.Database := Trim(edDatabase.Text);

  if FSetMain <> nil then
  begin
    FSetMain.BancoSQLite := Trim(edDatabase.Text);
    FSetMain.SalvaContexto(False);
  end;

  try
    zconsqlite.Connect;
    Result := zconsqlite.Connected;
  except
    Result := False;
  end;
end;

function Tfrmmquery2.CriaDicionarioSQLite(const ATargetFile: string): string;
var
  outSQL: TStringList;
  node: TTreeNode;
  tbl: string;
  targetAbsPath, targetDir: string;
begin
  Result := '';

  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  if (dmBase = nil) then
    dmBase := TdmBase.Create(Self);
  dmBase.DeleteTabelas;

  outSQL := TStringList.Create;
  try
    outSQL.Add('-- =========================================');
    outSQL.Add('-- Dicionário de dados (SQLite) - MQuery2');
    outSQL.Add('-- Gerado em: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    outSQL.Add('-- DB: ' + ExtractFileName(Trim(edDatabase.Text)));
    outSQL.Add('-- =========================================');
    outSQL.Add('');

    if (posicaofieldslite = nil) or (posicaofieldslite.GetFirstChild = nil) then
      RefreshSQLite;

    if (posicaofieldslite = nil) or (posicaofieldslite.GetFirstChild = nil) then
    begin
      ShowMessage('Nenhuma tabela encontrada no SQLite.');
      Exit;
    end;

    node := posicaofieldslite.GetFirstChild;
    while node <> nil do
    begin
      tbl := node.Text;

      outSQL.Add('-- ' + tbl);

      zliteqry.Close;
      zliteqry.SQL.Text :=
        'SELECT sql FROM sqlite_master WHERE type=''table'' AND name=:n';
      zliteqry.ParamByName('n').AsString := tbl;
      zliteqry.Open;

      if (not zliteqry.IsEmpty) and (Trim(zliteqry.Fields[0].AsString) <> '') then
        outSQL.Add(zliteqry.Fields[0].AsString + ';')
      else
        outSQL.Add(BuildCreateTableSQLite(tbl));

      if (FSetMain.Project <> '') then
        dmBase.RegistraTabela(tbl, ExtractFileName(Trim(edDatabase.Text)), BuildCreateTableSQLite(tbl));

      outSQL.Add('');
      node := node.GetNextSibling;
    end;

    Result := outSQL.Text;

    if Trim(ATargetFile) <> '' then
    begin
      targetAbsPath := ExpandFileName(ATargetFile);
      targetDir := ExtractFilePath(targetAbsPath);

      if targetDir <> '' then
        ForceDirectories(targetDir);

      outSQL.SaveToFile(targetAbsPath);
      edLog1.Append('Dicionário SQLite gerado em: ' + targetAbsPath);
    end;
  finally
    outSQL.Free;
  end;
end;

function Tfrmmquery2.BuildCreateTableSQLite(const ATabela: string): string;
var
  cols, pkCols, fkLines: TStringList;
  line, colName, colType, defVal: string;
  notNull: Integer;
  pkPos: Integer;
  i: Integer;
  fkMap: TStringList;
  fkId, fromCol, refTable, refCol, onUpdate, onDelete, matchName: string;
  idx: Integer;

  function QIdent(const S: string): string;
  begin
    Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"';
  end;

begin
  Result := '';

  cols := TStringList.Create;
  pkCols := TStringList.Create;
  fkLines := TStringList.Create;
  fkMap := TStringList.Create;
  try
    fkMap.NameValueSeparator := '=';
    fkMap.StrictDelimiter := True;

    zliteqry1.Close;
    zliteqry1.SQL.Text := 'PRAGMA table_info(' + QuotedStr(ATabela) + ')';
    zliteqry1.Open;

    while not zliteqry1.EOF do
    begin
      colName := zliteqry1.FieldByName('name').AsString;
      colType := Trim(zliteqry1.FieldByName('type').AsString);
      if colType = '' then
        colType := 'TEXT';

      line := '  ' + QIdent(colName) + ' ' + colType;

      notNull := zliteqry1.FieldByName('notnull').AsInteger;
      if notNull = 1 then
        line := line + ' NOT NULL';

      if not zliteqry1.FieldByName('dflt_value').IsNull then
      begin
        defVal := Trim(zliteqry1.FieldByName('dflt_value').AsString);
        if defVal <> '' then
          line := line + ' DEFAULT ' + defVal;
      end;

      cols.Add(line);

      pkPos := zliteqry1.FieldByName('pk').AsInteger;
      if pkPos > 0 then
      begin
        while pkCols.Count < pkPos do
          pkCols.Add('');
        pkCols[pkPos - 1] := QIdent(colName);
      end;

      zliteqry1.Next;
    end;
    zliteqry1.Close;

    zliteqry2.Close;
    zliteqry2.SQL.Text := 'PRAGMA foreign_key_list(' + QuotedStr(ATabela) + ')';
    zliteqry2.Open;

    while not zliteqry2.EOF do
    begin
      fkId      := zliteqry2.FieldByName('id').AsString;
      fromCol   := QIdent(zliteqry2.FieldByName('from').AsString);
      refTable  := QIdent(zliteqry2.FieldByName('table').AsString);
      refCol    := QIdent(zliteqry2.FieldByName('to').AsString);
      onUpdate  := Trim(zliteqry2.FieldByName('on_update').AsString);
      onDelete  := Trim(zliteqry2.FieldByName('on_delete').AsString);
      matchName := Trim(zliteqry2.FieldByName('match').AsString);

      idx := fkMap.IndexOfName(fkId);
      if idx < 0 then
      begin
        fkMap.Add(fkId + '=' + fromCol + '|' + refTable + '|' + refCol + '|' +
                  onUpdate + '|' + onDelete + '|' + matchName);
      end
      else
      begin
        line := fkMap.ValueFromIndex[idx];
        line := Copy(line, 1, Pos('|', line) - 1) + ',' + fromCol +
                Copy(line, Pos('|', line), MaxInt);

        Delete(line, 1, Pos('|', line));
        refTable := Copy(line, 1, Pos('|', line) - 1);
        Delete(line, 1, Pos('|', line));
        refCol := Copy(line, 1, Pos('|', line) - 1);
        Delete(line, 1, Pos('|', line));

        fkMap.ValueFromIndex[idx] :=
          fkMap.Names[idx] + '=' +
          Copy(fkMap.ValueFromIndex[idx], 1, Pos('|', fkMap.ValueFromIndex[idx]) - 1) + ',' + fromCol +
          Copy(fkMap.ValueFromIndex[idx], Pos('|', fkMap.ValueFromIndex[idx]), MaxInt);
      end;

      zliteqry2.Next;
    end;
    zliteqry2.Close;

    for i := 0 to fkMap.Count - 1 do
    begin
      line := fkMap.ValueFromIndex[i];

      fromCol   := Copy(line, 1, Pos('|', line) - 1);
      Delete(line, 1, Pos('|', line));

      refTable  := Copy(line, 1, Pos('|', line) - 1);
      Delete(line, 1, Pos('|', line));

      refCol    := Copy(line, 1, Pos('|', line) - 1);
      Delete(line, 1, Pos('|', line));

      onUpdate  := Copy(line, 1, Pos('|', line) - 1);
      Delete(line, 1, Pos('|', line));

      onDelete  := Copy(line, 1, Pos('|', line) - 1);
      Delete(line, 1, Pos('|', line));

      matchName := line;

      line := '  FOREIGN KEY (' + fromCol + ') REFERENCES ' + refTable + ' (' + refCol + ')';

      if onUpdate <> '' then
        if UpperCase(onUpdate) <> 'NO ACTION' then
          line := line + ' ON UPDATE ' + onUpdate;

      if onDelete <> '' then
        if UpperCase(onDelete) <> 'NO ACTION' then
          line := line + ' ON DELETE ' + onDelete;

      if (matchName <> '') and (UpperCase(matchName) <> 'NONE') then
        line := line + ' MATCH ' + matchName;

      fkLines.Add(line);
    end;

    Result := 'CREATE TABLE ' + QIdent(ATabela) + ' (' + LineEnding;

    for i := 0 to cols.Count - 1 do
    begin
      Result := Result + cols[i];
      if (i < cols.Count - 1) or (pkCols.Count > 0) or (fkLines.Count > 0) then
        Result := Result + ',';
      Result := Result + LineEnding;
    end;

    if pkCols.Count > 0 then
    begin
      Result := Result + '  PRIMARY KEY (' + pkCols.CommaText + ')';
      if fkLines.Count > 0 then
        Result := Result + ',';
      Result := Result + LineEnding;
    end;

    for i := 0 to fkLines.Count - 1 do
    begin
      Result := Result + fkLines[i];
      if i < fkLines.Count - 1 then
        Result := Result + ',';
      Result := Result + LineEnding;
    end;

    Result := Result + ');';
  finally
    cols.Free;
    pkCols.Free;
    fkLines.Free;
    fkMap.Free;
  end;
end;

function Tfrmmquery2.CriaListaDependenciasSQLite(const outFile: string): string;
var
  outTxt          : TStringList;
  nodeTable       : TTreeNode;
  childTable      : string;
  lastFkId        : string;
  curFkId         : string;
  parentTable     : string;
  childCols       : TStringList;
  parentCols      : TStringList;
  outFileAbs      : string;
begin
  Result := '';

  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  if posicaofieldslite = nil then
  begin
    ShowMessage('Estrutura de tabelas não carregada (posicaofieldslite = nil). Atualize a árvore do SQLite.');
    Exit;
  end;

  outTxt := TStringList.Create;
  childCols := TStringList.Create;
  parentCols := TStringList.Create;
  try
    outTxt.Add('-- =========================================');
    outTxt.Add('-- Lista de dependências (FK) - SQLite');
    outTxt.Add('-- DB: ' + ExtractFileName(Trim(edDatabase.Text)));
    outTxt.Add('-- Gerado em: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    outTxt.Add('-- Formato: TabelaFilha (colunas) depende da TabelaPai (colunas)');
    outTxt.Add('-- =========================================');
    outTxt.Add('');

    nodeTable := posicaofieldslite.GetFirstChild;
    while nodeTable <> nil do
    begin
      childTable := nodeTable.Text;

      zliteqry1.Close;
      zliteqry1.SQL.Text := 'PRAGMA foreign_key_list(' + QuotedStr(childTable) + ')';
      zliteqry1.Open;

      if not zliteqry1.IsEmpty then
      begin
        lastFkId := '';
        childCols.Clear;
        parentCols.Clear;
        parentTable := '';

        zliteqry1.First;
        while not zliteqry1.EOF do
        begin
          curFkId := zliteqry1.FieldByName('id').AsString;

          if (lastFkId <> '') and (curFkId <> lastFkId) then
          begin
            outTxt.Add(Format('%s (%s) depende da %s (%s);',
              [childTable,
               StringReplace(childCols.CommaText, ',', ', ', [rfReplaceAll]),
               parentTable,
               StringReplace(parentCols.CommaText, ',', ', ', [rfReplaceAll])]));
            childCols.Clear;
            parentCols.Clear;
          end;

          parentTable := zliteqry1.FieldByName('table').AsString;
          childCols.Add(zliteqry1.FieldByName('from').AsString);
          parentCols.Add(zliteqry1.FieldByName('to').AsString);

          lastFkId := curFkId;
          zliteqry1.Next;
        end;

        if (lastFkId <> '') and (childCols.Count > 0) then
        begin
          outTxt.Add(Format('%s (%s) depende da %s (%s);',
            [childTable,
             StringReplace(childCols.CommaText, ',', ', ', [rfReplaceAll]),
             parentTable,
             StringReplace(parentCols.CommaText, ',', ', ', [rfReplaceAll])]));
        end;

        outTxt.Add('');
      end;

      nodeTable := nodeTable.GetNextSibling;
    end;

    Result := outTxt.Text;

    if Trim(outFile) <> '' then
    begin
      outFileAbs := ExpandFileName(outFile);
      ForceDirectories(ExtractFileDir(outFileAbs));
      outTxt.SaveToFile(outFileAbs);
      edLog1.Append('Dependências SQLite salvas em: ' + outFileAbs);
    end;
  finally
    parentCols.Free;
    childCols.Free;
    outTxt.Free;
  end;
end;

procedure Tfrmmquery2.RefreshMy();
var
  tvitem: TTreeNode;
begin
  tvitemmy.DeleteChildren;

  if not ConectMy then
  begin
    MessageHint('Erro ao conectar no MySQL. Verifique host/usuário/senha/banco e a libmysql.');
    Exit;
  end;

  try
    tvitem := TTreeNode.Create(tvMysql.Items);
    tvitemmy.Text       := edBanco.Text;
    tvitemmy.ImageIndex := 13;

    posicaofieldsmy := tvMysql.Items.AddChildObject(tvitemmy, 'Tables', Pointer(ETDTabelas));
    posicaofieldsmy.ImageIndex := 15;
    posicaoViewmy := tvMysql.Items.AddChildObject(tvitemmy, 'Views', Pointer(ETDViews));
    posicaoProceduremy := tvMysql.Items.AddChildObject(tvitemmy, 'Procedure', Pointer(ETDProcedure));
    posicaoFunctionmy := tvMysql.Items.AddChildObject(tvitemmy, 'Functions', Pointer(ETDFunctions));

    ListarTabelasMy();
    ListarViewsMy();
  except
    on E: Exception do
      MessageHint('Erro ao preparar estrutura do MySQL: ' + E.Message);
  end;
end;

procedure Tfrmmquery2.RefreshPost;
var
  tvitem: TTreeNode;
begin
  tvitempost.DeleteChildren;
  SynSQLSyn2.TableNames.Clear;

  if not ConectPost then
  begin
    MessageHint('Erro ao conectar no PostgreSQL. Verifique host/usuário/senha/banco e a libpq.');
    Exit;
  end;

  try
    tvitem := TTreeNode.Create(tvPost.Items);
    tvitempost.Text := edBancoPost.Text;
    tvitempost.ImageIndex := 13;
    tvDatabasePost := tvitemPost;

    posicaofieldspost := tvPost.Items.AddChildObject(tvDatabasePost, 'tables', Pointer(ETDTabelas));
    posicaofieldspost.ImageIndex := 15;
    tvTablePost := posicaofieldspost;
    posicaoSequencePost := tvPost.Items.AddChildObject(tvDatabasePost, 'Sequences', Pointer(ETDTabelas));
    posicaoViewPost := tvPost.Items.AddChildObject(tvDatabasePost, 'Views', Pointer(ETDViews));
    posicaoProcedurePost := tvPost.Items.AddChildObject(tvDatabasePost, 'Procedure', Pointer(ETDProcedure));
    posicaoFunctionPost := tvPost.Items.AddChildObject(tvDatabasePost, 'Functions', Pointer(ETDFunctions));

    ListarTabelasPost();
    BuscaSequence(zpostqry1, DBPostgres);
    ListarViewsPost();
  except
    on E: Exception do
      MessageHint('Erro ao preparar estrutura do PostgreSQL: ' + E.Message);
  end;
end;

procedure Tfrmmquery2.RefreshSQLite;
var
  tvitem: TTreeNode;
begin
  if tvitemLite = nil then Exit;

  tvitemLite.DeleteChildren;

  if not ConectSQLite then
  begin
    MessageHint('Erro ao conectar no SQLite. Verifique o caminho do arquivo.');
    Exit;
  end;

  try
    tvitem := TTreeNode.Create(tvsqlite.Items);
    tvitemLite.Text := ExtractFileName(Trim(edDatabase.Text));
    tvitemLite.ImageIndex := 13;

    posicaofieldslite := tvsqlite.Items.AddChildObject(tvitemLite, 'tables', Pointer(ETDTabelas));
    posicaofieldslite.ImageIndex := 15;

    ListarTabelasSQLite;
    tvsqlite.FullExpand;
  except
    on E: Exception do
      MessageHint('Erro ao preparar estrutura do SQLite: ' + E.Message);
  end;
end;

procedure Tfrmmquery2.btConectarMyClick(Sender: TObject); begin RefreshMy; end;
procedure Tfrmmquery2.btConectarpostClick(Sender: TObject); begin RefreshPost; end;
procedure Tfrmmquery2.btConectarLiteClick(Sender: TObject); begin RefreshSQLite; end;

procedure Tfrmmquery2.btPermissaoChange(Sender: TObject);
var
  nome, banco: string;
begin
  if zconpost.Connected then
  begin
    banco := InputBox('Permissão de banco', 'Database:', 'database');
    nome  := InputBox('Permissão de banco', 'Usuário:', 'root');
    edSQL.Text := Format('GRANT ALL PRIVILEGES ON DATABASE %s TO %s;',
                         [JuntaNome(banco), JuntaNome(nome)]);
    zqrypost.SQL.Text := edSQL.Text;
    zqrypost.ExecSQL;
  end
  else
    ShowMessage('Postgres não conectado!');
end;

procedure Tfrmmquery2.btBancoClick(Sender: TObject);
var
  banco : string;
begin
  if zconpost.Connected then
  begin
    banco := InputBox('Criação de database','Banco:','database');
    edSQL.Text  := 'create database '+#39+banco+#39+';';
    zqrypost.SQL.Text := edSQL.Text;
    zqrypost.ExecSQL;
  end
  else
    ShowMessage('Postgres não conectado!');
end;

procedure Tfrmmquery2.btBancoliteClick(Sender: TObject);
var
  fn: string;
begin
  if Trim(edDatabase.Text) = '' then
  begin
    ShowMessage('Informe o caminho do arquivo SQLite em edDatabase.');
    Exit;
  end;

  fn := Trim(edDatabase.Text);
  ForceDirectories(ExtractFileDir(fn));

  if ConectSQLite then
  begin
    ShowMessage('SQLite pronto: ' + fn);
    RefreshSQLite;
  end
  else
    ShowMessage('Falha ao criar/conectar no SQLite.');
end;

procedure Tfrmmquery2.btAnaliseClick(Sender: TObject);
begin
  AnaliseMy(edSQL.Lines.Text);
end;

procedure Tfrmmquery2.btAnaliseliteClick(Sender: TObject);
begin
  lbTables.Items.Clear;

  frmMNote.NewContext();
  frmMNote.edChat.Text := sqltabela + edSQL1.Text + ' faça em uma caixa de texto';
  frmMNote.FazPergunta();
end;

procedure Tfrmmquery2.btbenchmarkClick(Sender: TObject); begin end;
procedure Tfrmmquery2.btChartClick(Sender: TObject); begin ChartView(ccMySQL); end;
procedure Tfrmmquery2.btChartPostClick(Sender: TObject); begin ChartView(ccPostgres); end;

procedure Tfrmmquery2.btcompararClick(Sender: TObject);
begin
  ShowMessage('Comparar: mantenho sua lógica original (não alterei aqui).');
end;

procedure Tfrmmquery2.btExecutar1Click(Sender: TObject); begin OpenSelectPost; end;
procedure Tfrmmquery2.btExecutarClick(Sender: TObject); begin OpenSelectMy; end;
procedure Tfrmmquery2.btExecutarliteClick(Sender: TObject); begin OpenSelectLite; end;
procedure Tfrmmquery2.btExecuteliteClick(Sender: TObject); begin btExecute2Click(Sender); end;
procedure Tfrmmquery2.btExecutar2Click(Sender: TObject); begin OpenSelectLite; end;

procedure Tfrmmquery2.btIAPostClick(Sender: TObject);
var
  deps, ddl, sqlIA: string;
  usingSQLite: Boolean;
begin
  usingSQLite :=
    (pgMain.ActivePage = liteMain) or
    ((pgSQLite <> nil) and (pgSQLite.ActivePage <> nil) and zconsqlite.Connected and not zconpost.Connected);

  if usingSQLite then
  begin
    if not zconsqlite.Connected then
    begin
      ShowMessage('SQLite não conectado!');
      Exit;
    end;

    deps  := CriaListaDependenciasSQLite('');
    ddl   := CriaDicionarioSQLite('');
    sqlIA := QuestionarSQLSQLite(meIA.Text, deps, ddl);

    edSQL1.Text := sqlIA;
    edLog1.Append('Question:' + meIA.Text);
    edLog1.Append('Return:' + sqlIA);
    pgSQLite.ActivePage := tbSQL1;
  end
  else
  begin
    if not zconpost.Connected then
    begin
      ShowMessage('PostgreSQL não conectado!');
      Exit;
    end;

    deps  := CriaListaDependenciasPost('');
    ddl   := CriaDicionarioPost('');
    sqlIA := QuestionarSQLPost(meIA.Text, deps, ddl);

    edSQLPost.Text := sqlIA;
    edLogPost.Append('Question:' + meIA.Text);
    edLogPost.Append('Return:' + sqlIA);
    pcPostgree.ActivePage := tsSQLPostgreSQL;
  end;
end;

procedure Tfrmmquery2.btImportCSVClick(Sender: TObject);
var
  tabela : string;
begin
  OpenDialog1.DefaultExt := '*.csv';
  if (zconmysql.Connected) then
  begin
    if OpenDialog1.Execute then
    begin
      try
        CSVDataset1.FileName := OpenDialog1.FileName;
        CSVDataset1.CSVOptions.Delimiter := ';';
        CSVDataset1.CSVOptions.FirstLineAsFieldNames := true;
        CSVDataset1.Open;

        tabela := InputBox('Table Create','table name:','newtable01');
        if tabela <> '' then
        begin
          CriaTabela(tabela, CSVDataset1, ZQryTransf);
          MigraCampos(tabela, CSVDataset1, ZQryTransf);
        end;
      except
        on E: Exception do
          ShowMessage('Erro ao carregar arquivo CSV: ' + E.Message);
      end;
    end;
  end
  else
    ShowMessage('Database Mysql no connection!');
end;

procedure Tfrmmquery2.btImportCSV1Click(Sender: TObject);
var
  tabela : string;
begin
  OpenDialog1.DefaultExt := '*.csv';

  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  if OpenDialog1.Execute then
  begin
    try
      CSVDataset1.FileName := OpenDialog1.FileName;
      CSVDataset1.CSVOptions.Delimiter := ';';
      CSVDataset1.CSVOptions.FirstLineAsFieldNames := true;
      CSVDataset1.Open;

      tabela := InputBox('SQLite Table Create','table name:','newtable01');
      if tabela <> '' then
      begin
        ZQryLiteTransf.Connection := zconsqlite;
        CriaTabela(tabela, CSVDataset1, ZQryLiteTransf);
        MigraCampos(tabela, CSVDataset1, ZQryLiteTransf);
        RefreshSQLite;
      end;
    except
      on E: Exception do
        ShowMessage('Erro ao importar CSV no SQLite: ' + E.Message);
    end;
  end;
end;

procedure Tfrmmquery2.btImportCSVLiteClick(Sender: TObject);
begin
  btImportCSV1Click(Sender);
end;

procedure Tfrmmquery2.btJSONClick(Sender: TObject);
var
  ts : TTabSheet;
  item : TItem;
  syn1 : TSynEdit;
begin
  ts := frmMNote.NovoItem();
  item := TItem(ts.Tag);
  syn1 := item.syn;

  case cbMake.ItemIndex of
    0: syn1.Text := DatasetToJsonString(dbgridmy.DataSource.DataSet);
    1: syn1.Text := DatasetTocsvString(dbgridmy.DataSource.DataSet);
  end;
end;

procedure Tfrmmquery2.btJSON1Click(Sender: TObject);
begin
  btJSONClick(Sender);
end;

procedure Tfrmmquery2.btJSON2Click(Sender: TObject);
begin
  btJSONClick(Sender);
end;

procedure Tfrmmquery2.btExecuteClick(Sender: TObject);
begin
  try
    zpostqry.SQL.Text := edSQLPost.Lines.Text;

    dsmy.DataSet := nil;
    dbnavpost.DataSource := nil;
    dbgridpost.DataSource := nil;

    edLog.Append('SQL Execute:' + edSQLPost.Lines.Text);
    zpostqry.ExecSQL;
  except
    on E: Exception do
    begin
      ShowMessage('Error:' + e.message);
      edLog.Append('Error:' + e.message);
    end;
  end;
end;

procedure Tfrmmquery2.btExecute1Click(Sender: TObject);
begin
  btExecuteClick(Sender);
end;

procedure Tfrmmquery2.btExecute2Click(Sender: TObject);
begin
  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  try
    ZQryLiteTransf.Connection := zconsqlite;
    ZQryLiteTransf.Close;
    ZQryLiteTransf.SQL.Text := edSQL1.Lines.Text;
    edLog1.Append('SQL Execute(SQLite):' + edSQL1.Lines.Text);
    ZQryLiteTransf.ExecSQL;
    RefreshSQLite;
  except
    on E: Exception do
    begin
      ShowMessage('Error(SQLite): ' + e.message);
      edLog1.Append('Error(SQLite): ' + e.message);
    end;
  end;
end;

procedure Tfrmmquery2.Button3Click(Sender: TObject); begin end;
procedure Tfrmmquery2.Button4Click(Sender: TObject); begin end;

procedure Tfrmmquery2.OpenSelectPost();
begin
  try
    zpostqry1.Close;
    zpostqry1.SQL.Text := edSQLPost.Lines.Text;

    dspos.DataSet := zpostqry1;
    edlog.Append('SQL OPEN:' + edSQLPost.Lines.Text);
    dbnavpost.DataSource := dspos;
    dbgridpost.DataSource := dspos;

    zpostqry1.Prepare;
    zpostqry1.Open;
    pcPostgree.ActivePage := tsGridPostgres;
  except
    on E: Exception do
    begin
      edLog.Append('Error:' + e.message);
      ShowMessage('Error:' + e.message);
    end;
  end;
end;

procedure Tfrmmquery2.OpenSelectMy();
begin
  try
    zmyqry2.SQL.Text := edSQL.Lines.Text;

    dsmy.DataSet := zmyqry2;
    edlog.Append('SQL OPEN:' + edSQL.Lines.Text);
    dbnavmy.DataSource := dsmy;
    dbgridmy.DataSource := dsmy;

    zmyqry2.Open;
    pgMysql.ActivePage := tsgrid;
  except
    on E: Exception do
    begin
      edLog.Append('Error:' + e.message);
      ShowMessage('Error:' + e.message);
    end;
  end;
end;

procedure Tfrmmquery2.OpenSelectLite();
begin
  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  try
    zliteqry2.Close;
    zliteqry2.SQL.Text := edSQL1.Lines.Text;
    zliteqry2.Open;

    dslite.DataSet := zliteqry2;
    edLog1.Append('SQL OPEN(SQLite):' + edSQL1.Lines.Text);
    dbnavmy1.DataSource := dslite;
    dbgridmy1.DataSource := dslite;

    pgSQLite.ActivePage := tsgrid1;
  except
    on E: Exception do
    begin
      edLog1.Append('Error(SQLite): ' + e.message);
      ShowMessage('Error(SQLite): ' + e.message);
    end;
  end;
end;

procedure Tfrmmquery2.edPesqMyKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then ProcuraTVMysql(edPesqMy.Text);
end;

procedure Tfrmmquery2.edPesqPostKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then ProcuraTVPost(edPesqPost.Text);
end;

procedure Tfrmmquery2.edPesqsqliteKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then ProcuraTVSQLite(edPesqsqlite.Text);
end;

procedure Tfrmmquery2.edSchemaPostChange(Sender: TObject); begin end;
procedure Tfrmmquery2.edSQLChange(Sender: TObject); begin end;
procedure Tfrmmquery2.edSQLChangeUpdating(ASender: TObject; AnUpdating: Boolean); begin end;
procedure Tfrmmquery2.edSQLClickLink(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); begin end;
procedure Tfrmmquery2.edSQLCommandProcessed(Sender: TObject; var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer); begin end;
procedure Tfrmmquery2.edSQLEnter(Sender: TObject); begin end;

procedure Tfrmmquery2.edSQLGutterClick(Sender: TObject; X, Y, Line: integer; mark: TSynEditMark);
begin
  lbCol.Caption := IntToStr(x);
  lblinha.Caption := IntToStr(y);
end;

procedure Tfrmmquery2.edSQLKeyPress(Sender: TObject; var Key: char); begin end;
procedure Tfrmmquery2.edSQLKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); begin end;
procedure Tfrmmquery2.edSQLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); begin end;
procedure Tfrmmquery2.edSQLPaint(Sender: TObject; ACanvas: TCanvas); begin end;
procedure Tfrmmquery2.edSQLPlaceBookmark(Sender: TObject; var Mark: TSynEditMark); begin end;
procedure Tfrmmquery2.edSQLStatusChange(Sender: TObject; Changes: TSynStatusChanges); begin end;
procedure Tfrmmquery2.edSQLSynGutterChange(Sender: TObject); begin end;

procedure Tfrmmquery2.FindDialog1Find(Sender: TObject);
begin
  strFind := findDialog1.FindText;
  Pesquisar(Sender);
end;

procedure Tfrmmquery2.ListarTabelasMy();
var
  Tabela : TTabela;
  tvitem : TTreeNode;
  tvtemp : TTreeNode;
  tvcolunas : TTreeNode;
  tvindice : TTreeNode;
  tvFK : TTreeNode;
  tvTrigger : TTreeNode;
  TabelaNome : string;
  a : integer;
begin
  zmyqry.Close;
  pnlProgresso.Visible := true;
  zmyqry.SQL.Text := 'select * from information_schema.tables';
  zmyqry.Open;
  zmyqry.First;
  pgbar.Max := zmyqry.RecordCount;
  pgbar.Position := 0;

  posicaofieldsmy.DeleteChildren;

  while not zmyqry.EOF do
  begin
    if zmyqry.FieldByName('table_schema').AsString = edBanco.Text then
    begin
      TabelaNome := zmyqry.FieldByName('table_name').AsString;
      SynCompletion1.ItemList.Append(TabelaNome);
      Tabela := TTabela.Create(zmyqry1, TabelaNome, DBMysql);

      tvitem := TTreenode.Create(tvMysql.Items);
      tvitem.ImageIndex := 14;
      tvitem := tvMysql.Items.AddNode(tvitem, posicaofieldsmy, TabelaNome, TObject(Tabela), naAddChild);

      tvcolunas := tvMysql.Items.AddChildObject(tvitem,'fields', TObject(ETDBCampos));
      tvcolunas.ImageIndex := 16;
      for a := 0 to tabela.Count-1 do
      begin
        tvTemp := tvMysql.Items.AddChildObject(tvcolunas, tabela.fieldname[a], Pointer(a));
        tvtemp.ImageIndex := 16;
      end;

      tvindice := tvMysql.Items.AddChildObject(tvitem,'Primary Key', Pointer(ETDBPK));
      tvindice.ImageIndex := 17;
      for a := 0 to tabela.chaves.primarykeys.Count-1 do
      begin
        tvTemp := tvMysql.Items.AddChildObject(tvindice, tabela.chaves.primarykeys[a], Pointer(a));
        tvTemp.ImageIndex := 18;
      end;

      tvFK := tvMysql.Items.AddChildObject(tvitem,'Chave Extrangeira', TObject(ETDBFK));
      for a := 0 to tabela.chaves.coinstraintname.Count-1 do
        tvMysql.Items.AddChildObject(tvFK, tabela.chaves.coinstraintname[a], Pointer(a));

      if (tabela.triggers.Triggername.Count > 0) then
      begin
        tvTrigger := tvMysql.Items.AddChildObject(tvitem,'Triggers', Pointer(ETDTriggers));
        for a := 0 to tabela.triggers.Triggername.Count-1 do
          tvMysql.Items.AddChildObject(tvTrigger, tabela.triggers.Triggername[a], Pointer(a));
      end;
    end;

    zmyqry.Next;
    pgbar.Position := pgbar.Position + 1;
    Application.ProcessMessages;
  end;

  pnlProgresso.Visible := false;
  tvMysql.FullExpand;
end;

procedure Tfrmmquery2.ListarTabelasSQLite();
var
  tvItem, tvCols, tvTemp, tvPK, tvFK: TTreeNode;
  tbl, colLine, fkLine: string;
  lastFkId, curFkId, parentTable: string;
  childCols, parentCols: TStringList;
begin
  if posicaofieldslite = nil then Exit;

  posicaofieldslite.DeleteChildren;

  zliteqry.Close;
  zliteqry.SQL.Text :=
    'SELECT name '+
    'FROM sqlite_master '+
    'WHERE type = ''table'' AND name NOT LIKE ''sqlite_%'' '+
    'ORDER BY name';
  zliteqry.Open;

  childCols := TStringList.Create;
  parentCols := TStringList.Create;
  try
    while not zliteqry.EOF do
    begin
      tbl := zliteqry.FieldByName('name').AsString;

      tvItem := TTreeNode.Create(tvsqlite.Items);
      tvItem.ImageIndex := 14;
      tvItem := tvsqlite.Items.AddNode(tvItem, posicaofieldslite, tbl, Pointer(nil), naAddChild);

      tvCols := tvsqlite.Items.AddChildObject(tvItem, 'fields', Pointer(ETDBCampos));
      tvCols.ImageIndex := 16;

      zliteqry1.Close;
      zliteqry1.SQL.Text := 'PRAGMA table_info(' + QuotedStr(tbl) + ')';
      zliteqry1.Open;

      tvPK := tvsqlite.Items.AddChildObject(tvItem, 'Primary Key', Pointer(ETDBPK));
      tvPK.ImageIndex := 17;

      while not zliteqry1.EOF do
      begin
        colLine := zliteqry1.FieldByName('name').AsString + ' : ' +
                   zliteqry1.FieldByName('type').AsString;

        if zliteqry1.FieldByName('notnull').AsInteger = 1 then
          colLine := colLine + ' NOT NULL';

        if not zliteqry1.FieldByName('dflt_value').IsNull then
          colLine := colLine + ' DEFAULT ' + zliteqry1.FieldByName('dflt_value').AsString;

        tvTemp := tvsqlite.Items.AddChildObject(tvCols, colLine, Pointer(0));
        tvTemp.ImageIndex := 19;

        if zliteqry1.FieldByName('pk').AsInteger > 0 then
        begin
          tvTemp := tvsqlite.Items.AddChildObject(tvPK,
            zliteqry1.FieldByName('name').AsString, Pointer(0));
          tvTemp.ImageIndex := 18;
        end;

        zliteqry1.Next;
      end;

      tvFK := tvsqlite.Items.AddChildObject(tvItem, 'Chave Estrangeira', Pointer(ETDBFK));

      zliteqry2.Close;
      zliteqry2.SQL.Text := 'PRAGMA foreign_key_list(' + QuotedStr(tbl) + ')';
      zliteqry2.Open;

      lastFkId := '';
      childCols.Clear;
      parentCols.Clear;
      parentTable := '';

      while not zliteqry2.EOF do
      begin
        curFkId := zliteqry2.FieldByName('id').AsString;

        if (lastFkId <> '') and (curFkId <> lastFkId) then
        begin
          fkLine := Format('%s (%s) -> %s (%s)',
            [tbl,
             StringReplace(childCols.CommaText, ',', ', ', [rfReplaceAll]),
             parentTable,
             StringReplace(parentCols.CommaText, ',', ', ', [rfReplaceAll])]);
          tvsqlite.Items.AddChildObject(tvFK, fkLine, Pointer(0));
          childCols.Clear;
          parentCols.Clear;
        end;

        parentTable := zliteqry2.FieldByName('table').AsString;
        childCols.Add(zliteqry2.FieldByName('from').AsString);
        parentCols.Add(zliteqry2.FieldByName('to').AsString);

        lastFkId := curFkId;
        zliteqry2.Next;
      end;

      if (lastFkId <> '') and (childCols.Count > 0) then
      begin
        fkLine := Format('%s (%s) -> %s (%s)',
          [tbl,
           StringReplace(childCols.CommaText, ',', ', ', [rfReplaceAll]),
           parentTable,
           StringReplace(parentCols.CommaText, ',', ', ', [rfReplaceAll])]);
        tvsqlite.Items.AddChildObject(tvFK, fkLine, Pointer(0));
      end;

      SynCompletion1.ItemList.Append(tbl);
      zliteqry.Next;
      Application.ProcessMessages;
    end;

    zliteqry.Close;
  finally
    childCols.Free;
    parentCols.Free;
  end;
end;

procedure Tfrmmquery2.BuscaSequence(qry: TZReadOnlyQuery; TypeDB: TypeDatabase);
var
  sql : string;
begin
  if posicaoSequencePost = nil then Exit;

  posicaoSequencePost.DeleteChildren;
  sequences := TStringList.Create;

  if TypeDB = DBPostgres then
  begin
    sql := 'select * from information_schema.sequences';
    qry.SQL.Text := sql;
    qry.Open;
    qry.First;
    while not qry.EOF do
    begin
      sequences.Add(qry.FieldByName('sequence_name').AsString);
      tvPost.Items.AddChildObject(posicaoSequencePost,
        qry.FieldByName('sequence_name').AsString, pointer(ETDSequence));
      qry.Next;
    end;
  end;

  qry.Close;
end;

procedure Tfrmmquery2.ListarViewsMy();
var
  a : integer;
begin
  viewsmy := TViews.Create(zmyqry, edBanco.Text, DBMysql);
  for a := 0 to viewsmy.items.Count-1 do
  begin
    tvMysql.Items.AddChildObject(posicaoViewmy, viewsmy.items[a], TObject(viewsmy.items.Objects[a]));
    SynCompletion1.ItemList.Append(viewsmy.items[a]);
  end;
end;

procedure Tfrmmquery2.ListarViewsPost();
var
  a : integer;
begin
  viewspost := TViews.Create(zpostqry, edBancoPost.Text, DBPostgres);
  for a := 0 to viewspost.items.Count-1 do
    tvPost.Items.AddChildObject(posicaoViewPost, viewspost.items[a], TObject(viewspost.items.Objects[a]));
end;

procedure Tfrmmquery2.ListarTabelasPost();
var
  tvItem, tvTemp, tvColunas, tvIndice, tvFK, tvTrigger: TTreeNode;
  TabelaNome, SchemaNome: string;
  ColLine : string;

  procedure OpenListaTabelas;
  begin
    zpostqry.Close;
    zpostqry.SQL.Text :=
      'SELECT schemaname, tablename '+
      'FROM pg_catalog.pg_tables '+
      'WHERE schemaname = :schema '+
      'ORDER BY tablename';
    zpostqry.ParamByName('schema').AsString := SchemaNome;
    try
      zpostqry.Open;
    except
      zpostqry.Close;
      zpostqry.SQL.Text :=
        'SELECT n.nspname AS schemaname, c.relname AS tablename '+
        'FROM pg_catalog.pg_class c '+
        'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '+
        'WHERE n.nspname = :schema '+
        '  AND c.relkind = ''r'' '+
        'ORDER BY c.relname';
      zpostqry.ParamByName('schema').AsString := SchemaNome;
      zpostqry.Open;
    end;
  end;

  procedure AddColunas(const ASchema, ATable: string; AParent: TTreeNode);
  begin
    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT a.attnum, a.attname AS column_name, '+
      '       pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type, '+
      '       NOT a.attnotnull AS is_nullable, '+
      '       pg_get_expr(ad.adbin, ad.adrelid) AS column_default '+
      'FROM pg_catalog.pg_attribute a '+
      'LEFT JOIN pg_catalog.pg_attrdef ad '+
      '  ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum '+
      'JOIN pg_catalog.pg_class c ON c.oid = a.attrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '+
      'WHERE n.nspname = :schema '+
      '  AND c.relname = :table '+
      '  AND a.attnum > 0 AND NOT a.attisdropped '+
      'ORDER BY a.attnum';
    zpostqry1.ParamByName('schema').AsString := ASchema;
    zpostqry1.ParamByName('table').AsString  := ATable;
    zpostqry1.Open;

    tvColunas := tvPost.Items.AddChildObject(AParent, 'fields', Pointer(ETDBCampos));
    tvColunas.ImageIndex := 16;

    while not zpostqry1.EOF do
    begin
      ColLine := zpostqry1.FieldByName('column_name').AsString + ' : ' +
                 zpostqry1.FieldByName('data_type').AsString;

      if not zpostqry1.FieldByName('is_nullable').AsBoolean then
        ColLine := ColLine + ' NOT NULL';

      if not zpostqry1.FieldByName('column_default').IsNull then
        ColLine := ColLine + ' DEFAULT ' + zpostqry1.FieldByName('column_default').AsString;

      tvTemp := tvPost.Items.AddChildObject(tvColunas, ColLine, Pointer(0));
      tvTemp.ImageIndex := 19;

      zpostqry1.Next;
    end;
  end;

  procedure AddPK(const ASchema, ATable: string; AParent: TTreeNode);
  begin
    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT c.conname, '+
      '       array_agg(a.attname ORDER BY u.ord) AS cols '+
      'FROM pg_catalog.pg_constraint c '+
      'JOIN pg_catalog.pg_class t ON t.oid = c.conrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'JOIN LATERAL unnest(c.conkey) WITH ORDINALITY AS u(attnum, ord) ON TRUE '+
      'JOIN pg_catalog.pg_attribute a ON a.attrelid = t.oid AND a.attnum = u.attnum '+
      'WHERE c.contype = ''p'' '+
      '  AND n.nspname = :schema '+
      '  AND t.relname = :table '+
      'GROUP BY c.conname '+
      'ORDER BY c.conname';
    zpostqry1.ParamByName('schema').AsString := ASchema;
    zpostqry1.ParamByName('table').AsString  := ATable;
    zpostqry1.Open;

    tvIndice := tvPost.Items.AddChildObject(AParent, 'Primary Key', Pointer(ETDBPK));
    tvIndice.ImageIndex := 17;

    while not zpostqry1.EOF do
    begin
      tvTemp := tvPost.Items.AddChildObject(
                  tvIndice,
                  zpostqry1.FieldByName('conname').AsString + ' ('+
                  zpostqry1.FieldByName('cols').AsString + ')',
                  Pointer(0)
                );
      tvTemp.ImageIndex := 18;
      zpostqry1.Next;
    end;
  end;

  procedure AddFK(const ASchema, ATable: string; AParent: TTreeNode);
  var
    FKLine: string;
  begin
    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT c.conname, '+
      '       n2.nspname AS ref_schema, t2.relname AS ref_table, '+
      '       array_agg(a1.attname ORDER BY u.ord) AS cols, '+
      '       array_agg(a2.attname ORDER BY u.ord) AS ref_cols, '+
      '       pg_get_constraintdef(c.oid, TRUE) AS def '+
      'FROM pg_catalog.pg_constraint c '+
      'JOIN pg_catalog.pg_class t1 ON t1.oid = c.conrelid '+
      'JOIN pg_catalog.pg_namespace n1 ON n1.oid = t1.relnamespace '+
      'JOIN pg_catalog.pg_class t2 ON t2.oid = c.confrelid '+
      'JOIN pg_catalog.pg_namespace n2 ON n2.oid = t2.relnamespace '+
      'JOIN LATERAL unnest(c.conkey) WITH ORDINALITY AS u(attnum, ord) ON TRUE '+
      'JOIN LATERAL unnest(c.confkey) WITH ORDINALITY AS v(attnum, ord) ON v.ord = u.ord '+
      'JOIN pg_catalog.pg_attribute a1 ON a1.attrelid = t1.oid AND a1.attnum = u.attnum '+
      'JOIN pg_catalog.pg_attribute a2 ON a2.attrelid = t2.oid AND a2.attnum = v.attnum '+
      'WHERE c.contype = ''f'' '+
      '  AND n1.nspname = :schema '+
      '  AND t1.relname = :table '+
      'GROUP BY c.conname, ref_schema, ref_table, c.oid '+
      'ORDER BY c.conname';
    zpostqry2.ParamByName('schema').AsString := ASchema;
    zpostqry2.ParamByName('table').AsString  := ATable;
    zpostqry2.Open;

    tvFK := tvPost.Items.AddChildObject(AParent, 'Chave Estrangeira', Pointer(ETDBFK));

    while not zpostqry2.EOF do
    begin
      FKLine :=
        zpostqry2.FieldByName('conname').AsString + ' ('+
        zpostqry2.FieldByName('cols').AsString + ') → '+
        zpostqry2.FieldByName('ref_schema').AsString + '.'+
        zpostqry2.FieldByName('ref_table').AsString + '('+
        zpostqry2.FieldByName('ref_cols').AsString + ')';

      tvTemp := tvPost.Items.AddChildObject(tvFK, FKLine, Pointer(0));
      tvPost.Items.AddChildObject(tvTemp, zpostqry2.FieldByName('def').AsString, Pointer(0));

      zpostqry2.Next;
    end;
  end;

  procedure AddTriggers(const ASchema, ATable: string; AParent: TTreeNode);
  begin
    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT tg.tgname, pg_get_triggerdef(tg.oid, TRUE) AS def '+
      'FROM pg_catalog.pg_trigger tg '+
      'JOIN pg_catalog.pg_class t ON t.oid = tg.tgrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'WHERE n.nspname = :schema '+
      '  AND t.relname = :table '+
      '  AND NOT tg.tgisinternal '+
      'ORDER BY tg.tgname';
    zpostqry1.ParamByName('schema').AsString := ASchema;
    zpostqry1.ParamByName('table').AsString  := ATable;
    zpostqry1.Open;

    if not zpostqry1.EOF then
    begin
      tvTrigger := tvPost.Items.AddChildObject(AParent, 'Triggers', Pointer(ETDTriggers));
      while not zpostqry1.EOF do
      begin
        tvTemp := tvPost.Items.AddChildObject(tvTrigger,
                   zpostqry1.FieldByName('tgname').AsString, Pointer(0));
        tvPost.Items.AddChildObject(tvTemp,
                   zpostqry1.FieldByName('def').AsString, Pointer(0));
        zpostqry1.Next;
      end;
    end;
  end;

var
  SchemaNome: string;
begin
  SchemaNome := Trim(edSchemaPost.Text);
  if SchemaNome = '' then SchemaNome := 'public';

  try
    posicaofieldspost.DeleteChildren;

    OpenListaTabelas;
    zpostqry.First;

    while not zpostqry.EOF do
    begin
      if SameText(zpostqry.FieldByName('schemaname').AsString, SchemaNome) then
      begin
        TabelaNome := zpostqry.FieldByName('tablename').AsString;

        SynSQLSyn2.TableNames.Append(TabelaNome);

        tvItem := TTreeNode.Create(tvPost.Items);
        tvItem.ImageIndex := 14;
        tvItem := tvPost.Items.AddNode(tvItem, posicaofieldspost, TabelaNome, Pointer(nil), naAddChild);

        AddColunas(SchemaNome, TabelaNome, tvItem);
        AddPK(SchemaNome, TabelaNome, tvItem);
        AddFK(SchemaNome, TabelaNome, tvItem);
        AddTriggers(SchemaNome, TabelaNome, tvItem);
      end;

      zpostqry.Next;
      Application.ProcessMessages;
    end;
  finally
    tvPost.FullExpand;
  end;
end;

function Tfrmmquery2.DescreveTabelaIAMy(const tabela: string) : string;
var
  createSQL: TStringList;
  colName, dataType, isNullable, defVal, extra: string;
  charLen: Variant;
  numPrec, numScale: Variant;
  firstCol: Boolean;
  pkCols: TStringList;

  function NeedsQuoting(const S: string): Boolean;
  var
    V: Double;
  begin
    if (S = '') then Exit(False);
    if SameText(S, 'NULL') then Exit(False);
    if SameText(S, 'CURRENT_TIMESTAMP') then Exit(False);
    if Pos('(', S) > 0 then Exit(False);
    if TryStrToFloat(S, V) then Exit(False);
    Result := True;
  end;

  function MyTypeWithLen(const baseType: string; const charLen, numPrec, numScale: Variant): string;
  begin
    Result := baseType;
    if SameText(baseType, 'varchar') or SameText(baseType, 'char') then
    begin
      if not VarIsNull(charLen) and (VarIsNumeric(charLen) or VarIsType(charLen, varInteger)) then
        Result := baseType + '(' + VarToStr(charLen) + ')';
    end
    else if SameText(baseType, 'decimal') or SameText(baseType, 'numeric') then
    begin
      if not VarIsNull(numPrec) then
      begin
        Result := baseType + '(' + VarToStr(numPrec);
        if not VarIsNull(numScale) then
          Result := Result + ',' + VarToStr(numScale);
        Result := Result + ')';
      end;
    end;
  end;

begin
  Result := '';

  if not zconmysql.Connected then
  begin
    ShowMessage('MySQL não conectado!');
    Exit;
  end;

  zmyqry.Close;
  zmyqry.SQL.Text :=
    'SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, ' +
    '       NUMERIC_PRECISION, NUMERIC_SCALE, IS_NULLABLE, COLUMN_DEFAULT, EXTRA ' +
    'FROM information_schema.COLUMNS ' +
    'WHERE TABLE_SCHEMA = :db AND TABLE_NAME = :tbl ' +
    'ORDER BY ORDINAL_POSITION';
  zmyqry.ParamByName('db').AsString  := edBanco.Text;
  zmyqry.ParamByName('tbl').AsString := tabela;
  zmyqry.Open;

  if zmyqry.IsEmpty then
  begin
    ShowMessage('Tabela "' + tabela + '" não encontrada em ' + edBanco.Text + '.');
    Exit;
  end;

  pkCols := TStringList.Create;
  pkCols.Sorted := False;
  try
    zmyqry1.Close;
    zmyqry1.SQL.Text :=
      'SELECT k.COLUMN_NAME ' +
      'FROM information_schema.TABLE_CONSTRAINTS tc ' +
      'JOIN information_schema.KEY_COLUMN_USAGE k ' +
      '  ON k.CONSTRAINT_NAME = tc.CONSTRAINT_NAME ' +
      ' AND k.TABLE_SCHEMA = tc.TABLE_SCHEMA ' +
      ' AND k.TABLE_NAME = tc.TABLE_NAME ' +
      'WHERE tc.TABLE_SCHEMA = :db ' +
      '  AND tc.TABLE_NAME   = :tbl ' +
      '  AND tc.CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
      'ORDER BY k.ORDINAL_POSITION';
    zmyqry1.ParamByName('db').AsString  := edBanco.Text;
    zmyqry1.ParamByName('tbl').AsString := tabela;
    zmyqry1.Open;

    while not zmyqry1.EOF do
    begin
      pkCols.Add(zmyqry1.FieldByName('COLUMN_NAME').AsString);
      zmyqry1.Next;
    end;

    createSQL := TStringList.Create;
    try
      createSQL.Add('CREATE TABLE `' + edBanco.Text + '`.`' + tabela + '` (');

      firstCol := True;
      zmyqry.First;
      while not zmyqry.EOF do
      begin
        colName   := zmyqry.FieldByName('COLUMN_NAME').AsString;
        dataType  := zmyqry.FieldByName('DATA_TYPE').AsString;
        charLen   := zmyqry.FieldByName('CHARACTER_MAXIMUM_LENGTH').Value;
        numPrec   := zmyqry.FieldByName('NUMERIC_PRECISION').Value;
        numScale  := zmyqry.FieldByName('NUMERIC_SCALE').Value;
        isNullable:= zmyqry.FieldByName('IS_NULLABLE').AsString;
        defVal    := zmyqry.FieldByName('COLUMN_DEFAULT').AsString;
        extra     := zmyqry.FieldByName('EXTRA').AsString;

        dataType := MyTypeWithLen(LowerCase(dataType), charLen, numPrec, numScale);

        if not firstCol then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ',';
        firstCol := False;

        createSQL.Add(Format('  `%s` %s', [colName, UpperCase(dataType)]));

        if SameText(isNullable, 'NO') then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' NOT NULL'
        else
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' NULL';

        if defVal <> '' then
        begin
          if NeedsQuoting(defVal) then
            createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' DEFAULT ' + QuotedStr(defVal)
          else
            createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' DEFAULT ' + defVal;
        end;

        if Pos('auto_increment', LowerCase(extra)) > 0 then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' AUTO_INCREMENT';

        zmyqry.Next;
      end;

      if pkCols.Count > 0 then
      begin
        createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ',';
        createSQL.Add('  PRIMARY KEY (' +
          StringReplace('`' + StringReplace(pkCols.CommaText, ',', '`,`', [rfReplaceAll]) + '`', '``', '`', [rfReplaceAll]) +
          ')');
      end;

      createSQL.Add(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;');
      Result := createSQL.Text;
    finally
      createSQL.Free;
    end;
  finally
    pkCols.Free;
  end;
end;

function Tfrmmquery2.CriaDicionarioPost(const ATargetFile: string): string;
var
  outSQL        : TStringList;
  schema        : string;
  tblNode       : TTreeNode;
  tblName       : string;
  targetAbsPath : string;
  targetDir     : string;

  function QIdent(const S: string): string;
  begin
    Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"';
  end;

  function BuildColumnsSQL(const ASchema, ATable: string): TStringList;
  var
    line, colname, dtype, defval: string;
    isnull: Boolean;
  begin
    Result := TStringList.Create;

    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT a.attnum, a.attname AS column_name, '+
      '       pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type, '+
      '       NOT a.attnotnull AS is_nullable, '+
      '       pg_get_expr(ad.adbin, ad.adrelid) AS column_default '+
      'FROM pg_catalog.pg_attribute a '+
      'LEFT JOIN pg_catalog.pg_attrdef ad '+
      '  ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum '+
      'JOIN pg_catalog.pg_class c ON c.oid = a.attrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '+
      'WHERE n.nspname = :schema '+
      '  AND c.relname = :table '+
      '  AND a.attnum > 0 AND NOT a.attisdropped '+
      'ORDER BY a.attnum';
    zpostqry1.ParamByName('schema').AsString := ASchema;
    zpostqry1.ParamByName('table').AsString  := ATable;
    zpostqry1.Open;

    while not zpostqry1.EOF do
    begin
      colname := zpostqry1.FieldByName('column_name').AsString;
      dtype   := zpostqry1.FieldByName('data_type').AsString;
      isnull  := zpostqry1.FieldByName('is_nullable').AsBoolean;

      line := '  ' + QIdent(colname) + ' ' + dtype;

      if not isnull then
        line := line + ' NOT NULL';

      if not zpostqry1.FieldByName('column_default').IsNull then
      begin
        defval := Trim(zpostqry1.FieldByName('column_default').AsString);
        if defval <> '' then
          line := line + ' DEFAULT ' + defval;
      end;

      Result.Add(line);
      zpostqry1.Next;
    end;
  end;

  function BuildPKSQL(const ASchema, ATable: string): TStringList;
  begin
    Result := TStringList.Create;

    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT c.conname, pg_get_constraintdef(c.oid, TRUE) AS def '+
      'FROM pg_catalog.pg_constraint c '+
      'JOIN pg_catalog.pg_class t ON t.oid = c.conrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'WHERE c.contype = ''p'' '+
      '  AND n.nspname = :schema '+
      '  AND t.relname = :table '+
      'ORDER BY c.conname';
    zpostqry2.ParamByName('schema').AsString := ASchema;
    zpostqry2.ParamByName('table').AsString  := ATable;
    zpostqry2.Open;

    while not zpostqry2.EOF do
    begin
      Result.Add(
        'ALTER TABLE ' + QIdent(ASchema) + '.' + QIdent(ATable) +
        ' ADD CONSTRAINT ' + QIdent(zpostqry2.FieldByName('conname').AsString) +
        ' ' + zpostqry2.FieldByName('def').AsString + ';'
      );
      zpostqry2.Next;
    end;
  end;

  function BuildFKSQL(const ASchema, ATable: string): TStringList;
  begin
    Result := TStringList.Create;

    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT c.conname, pg_get_constraintdef(c.oid, TRUE) AS def '+
      'FROM pg_catalog.pg_constraint c '+
      'JOIN pg_catalog.pg_class t ON t.oid = c.conrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'WHERE c.contype = ''f'' '+
      '  AND n.nspname = :schema '+
      '  AND t.relname = :table '+
      'ORDER BY c.conname';
    zpostqry2.ParamByName('schema').AsString := ASchema;
    zpostqry2.ParamByName('table').AsString  := ATable;
    zpostqry2.Open;

    while not zpostqry2.EOF do
    begin
      Result.Add(
        'ALTER TABLE ' + QIdent(ASchema) + '.' + QIdent(ATable) +
        ' ADD CONSTRAINT ' + QIdent(zpostqry2.FieldByName('conname').AsString) +
        ' ' + zpostqry2.FieldByName('def').AsString + ';'
      );
      zpostqry2.Next;
    end;
  end;

  function BuildIndexesSQL(const ASchema, ATable: string): TStringList;
  var
    ConstraintNames : TStringList;
    idxname : string;
  begin
    Result := TStringList.Create;

    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT c.conname '+
      'FROM pg_catalog.pg_constraint c '+
      'JOIN pg_catalog.pg_class t ON t.oid = c.conrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'WHERE c.contype IN (''p'',''u'') '+
      '  AND n.nspname = :schema '+
      '  AND t.relname = :table';
    zpostqry2.ParamByName('schema').AsString := ASchema;
    zpostqry2.ParamByName('table').AsString  := ATable;
    zpostqry2.Open;

    ConstraintNames := TStringList.Create;
    try
      ConstraintNames.CaseSensitive := False;
      while not zpostqry2.EOF do
      begin
        ConstraintNames.Add(zpostqry2.FieldByName('conname').AsString);
        zpostqry2.Next;
      end;

      zpostqry3.Close;
      zpostqry3.SQL.Text :=
        'SELECT schemaname, tablename, indexname, indexdef '+
        'FROM pg_catalog.pg_indexes '+
        'WHERE schemaname = :schema '+
        '  AND tablename  = :table '+
        'ORDER BY indexname';
      zpostqry3.ParamByName('schema').AsString := ASchema;
      zpostqry3.ParamByName('table').AsString  := ATable;
      zpostqry3.Open;

      while not zpostqry3.EOF do
      begin
        idxname := zpostqry3.FieldByName('indexname').AsString;
        if ConstraintNames.IndexOf(idxname) < 0 then
          Result.Add(zpostqry3.FieldByName('indexdef').AsString + ';');
        zpostqry3.Next;
      end;
    finally
      ConstraintNames.Free;
    end;
  end;

  function BuildTriggersSQL(const ASchema, ATable: string): TStringList;
  begin
    Result := TStringList.Create;

    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT tg.tgname, pg_get_triggerdef(tg.oid, TRUE) AS def '+
      'FROM pg_catalog.pg_trigger tg '+
      'JOIN pg_catalog.pg_class t ON t.oid = tg.tgrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'WHERE n.nspname = :schema '+
      '  AND t.relname = :table '+
      '  AND NOT tg.tgisinternal '+
      'ORDER BY tg.tgname';
    zpostqry1.ParamByName('schema').AsString := ASchema;
    zpostqry1.ParamByName('table').AsString  := ATable;
    zpostqry1.Open;

    while not zpostqry1.EOF do
    begin
      Result.Add(zpostqry1.FieldByName('def').AsString + ';');
      zpostqry1.Next;
    end;
  end;

  function BuildCreateTableSQL(const ASchema, ATable: string): string;
  var
    cols, pks, fks, idx, trg: TStringList;
    i: Integer;
  begin
    cols := nil; pks := nil; fks := nil; idx := nil; trg := nil;
    try
      cols := BuildColumnsSQL(ASchema, ATable);
      pks  := BuildPKSQL(ASchema, ATable);
      fks  := BuildFKSQL(ASchema, ATable);
      idx  := BuildIndexesSQL(ASchema, ATable);
      trg  := BuildTriggersSQL(ASchema, ATable);

      Result := 'CREATE TABLE ' + QIdent(ASchema) + '.' + QIdent(ATable) + ' (' + sLineBreak;
      for i := 0 to cols.Count - 1 do
      begin
        if i < cols.Count - 1 then
          Result := Result + cols[i] + ',' + sLineBreak
        else
          Result := Result + cols[i] + sLineBreak;
      end;
      Result := Result + ');' + sLineBreak;

      for i := 0 to pks.Count - 1 do Result := Result + pks[i] + sLineBreak;
      for i := 0 to fks.Count - 1 do Result := Result + fks[i] + sLineBreak;
      for i := 0 to idx.Count - 1 do Result := Result + idx[i] + sLineBreak;
      for i := 0 to trg.Count - 1 do Result := Result + trg[i] + sLineBreak;
    finally
      cols.Free;
      pks.Free;
      fks.Free;
      idx.Free;
      trg.Free;
    end;
  end;

var
  sqlCreate : string;
begin
  Result := '';

  if (dmBase = nil) then
    dmBase := TdmBase.Create(Self);
  dmBase.DeleteTabelas;

  if not zconpost.Connected then
  begin
    ShowMessage('PostgreSQL não conectado.');
    Exit;
  end;

  if (posicaofieldspost = nil) or (posicaofieldspost.GetFirstChild = nil) then
    RefreshPost;

  if (posicaofieldspost = nil) or (posicaofieldspost.GetFirstChild = nil) then
  begin
    ShowMessage('Nenhuma tabela encontrada no tvPost.');
    Exit;
  end;

  schema := Trim(edSchemaPost.Text);
  if schema = '' then schema := 'public';

  outSQL := TStringList.Create;
  try
    outSQL.Add('-- =========================================');
    outSQL.Add('-- Dicionário de dados gerado pelo MQuery2');
    outSQL.Add('-- ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    outSQL.Add('-- Database: ' + Trim(edBancoPost.Text) + ' | Schema: ' + schema);
    outSQL.Add('-- =========================================');
    outSQL.Add('');

    tblNode := posicaofieldspost.GetFirstChild;
    while tblNode <> nil do
    begin
      tblName := tblNode.Text;

      outSQL.Add('-- ' + tblName);
      sqlCreate := BuildCreateTableSQL(schema, tblName);
      outSQL.Add(sqlCreate);
      outSQL.Add('');

      if (FSetMain.Project <> '') then
      begin
        if (dmBase = nil) then
          dmBase := TdmBase.Create(Self);
        dmBase.RegistraTabela(tblName, '', sqlCreate);
      end;

      tblNode := tblNode.GetNextSibling;
      Application.ProcessMessages;
    end;

    targetAbsPath := ExpandFileName(ATargetFile);
    targetDir     := ExtractFilePath(targetAbsPath);
    if targetDir <> '' then
      ForceDirectories(targetDir);

    if (ATargetFile <> '') then
    begin
      outSQL.SaveToFile(targetAbsPath);
      edLog.Append('Dicionário gerado em: ' + targetAbsPath);
    end;

    Result := outSQL.Text;
  finally
    outSQL.Free;
  end;
end;

function Tfrmmquery2.CriaListaDependenciasPost(const outFile: string): string;
var
  outTxt          : TStringList;
  schema          : string;
  nodeTable       : TTreeNode;
  childTable      : string;

  lastConstraint  : string;
  curConstraint   : string;
  parentTable     : string;

  childCols       : TStringList;
  parentCols      : TStringList;
begin
  Result := '';

  if not zconpost.Connected then
  begin
    ShowMessage('PostgreSQL não conectado!');
    Exit;
  end;

  if posicaofieldspost = nil then
  begin
    ShowMessage('Estrutura de tabelas não carregada (posicaofieldspost = nil). Atualize a árvore do Postgres.');
    Exit;
  end;

  schema := Trim(edSchemaPost.Text);
  if schema = '' then schema := 'public';

  outTxt := TStringList.Create;
  childCols  := TStringList.Create;
  parentCols := TStringList.Create;
  try
    outTxt.Add('-- =========================================');
    outTxt.Add('-- Lista de dependências (FK) - PostgreSQL');
    outTxt.Add('-- Database: ' + Trim(edBancoPost.Text) + ' | Schema: ' + schema);
    outTxt.Add('-- Gerado em: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    outTxt.Add('-- Formato: TabelaFilha (colunas) depende da TabelaPai (colunas)');
    outTxt.Add('-- =========================================');
    outTxt.Add('');

    nodeTable := posicaofieldspost.GetFirstChild;
    while nodeTable <> nil do
    begin
      childTable := nodeTable.Text;

      zpostqry1.Close;
      zpostqry1.SQL.Text :=
        'SELECT tc.constraint_name, ' +
        '       kcu.column_name       AS child_col, ' +
        '       ccu.table_name        AS parent_table, ' +
        '       ccu.column_name       AS parent_col ' +
        'FROM information_schema.table_constraints tc ' +
        'JOIN information_schema.key_column_usage kcu ' +
        '  ON kcu.constraint_name = tc.constraint_name ' +
        ' AND kcu.table_schema    = tc.table_schema ' +
        'JOIN information_schema.constraint_column_usage ccu ' +
        '  ON ccu.constraint_name = tc.constraint_name ' +
        ' AND ccu.table_schema    = tc.table_schema ' +
        'WHERE tc.constraint_type = ''FOREIGN KEY'' ' +
        '  AND tc.table_schema    = :schema ' +
        '  AND tc.table_name      = :tbl ' +
        'ORDER BY tc.constraint_name, kcu.ordinal_position';
      zpostqry1.ParamByName('schema').AsString := schema;
      zpostqry1.ParamByName('tbl').AsString    := childTable;
      zpostqry1.Open;

      if not zpostqry1.IsEmpty then
      begin
        lastConstraint := '';
        childCols.Clear;
        parentCols.Clear;
        parentTable := '';

        zpostqry1.First;
        while not zpostqry1.EOF do
        begin
          curConstraint := zpostqry1.FieldByName('constraint_name').AsString;

          if (lastConstraint <> '') and (curConstraint <> lastConstraint) then
          begin
            outTxt.Add(Format('%s (%s) depende da %s (%s);',
              [childTable,
               StringReplace(childCols.CommaText, ',', ', ', [rfReplaceAll]),
               parentTable,
               StringReplace(parentCols.CommaText, ',', ', ', [rfReplaceAll])]));
            childCols.Clear;
            parentCols.Clear;
          end;

          parentTable := zpostqry1.FieldByName('parent_table').AsString;
          childCols.Add(zpostqry1.FieldByName('child_col').AsString);
          parentCols.Add(zpostqry1.FieldByName('parent_col').AsString);

          lastConstraint := curConstraint;
          zpostqry1.Next;
        end;

        if (lastConstraint <> '') and (childCols.Count > 0) then
        begin
          outTxt.Add(Format('%s (%s) depende da %s (%s);',
            [childTable,
             StringReplace(childCols.CommaText, ',', ', ', [rfReplaceAll]),
             parentTable,
             StringReplace(parentCols.CommaText, ',', ', ', [rfReplaceAll])]));
        end;

        outTxt.Add('');
      end;

      nodeTable := nodeTable.GetNextSibling;
    end;

    Result := outTxt.Text;

    if outFile <> '' then
    begin
      ForceDirectories(ExtractFileDir(outFile));
      outTxt.SaveToFile(outFile);
      edLog.Append('Dependências (FK) salvas em: ' + outFile);
    end;

  finally
    parentCols.Free;
    childCols.Free;
    outTxt.Free;
  end;
end;

function Tfrmmquery2.QuestionarSQLPost(const pergunta, deps, ddl: string): string;

  function StripCodeFences(const S: string): string;
  var
    R: string;
    p1, p2: SizeInt;
  begin
    R := S;
    p1 := Pos('```', R);
    if p1 > 0 then
    begin
      Delete(R, 1, p1 + 2);
      if (Length(R) >= 3) and (LowerCase(Copy(R, 1, 3)) = 'sql') then
        Delete(R, 1, 3);
      p2 := RPos('```', R);
      if p2 > 0 then
        R := Copy(R, 1, p2 - 1);
    end;
    Result := Trim(R);
  end;

var
  ctxDeps, ctxDDL, ask, outSQL: string;
  outAnsi: AnsiString;
  baseSchema: string;
begin
  Result := '';

  if not zconpost.Connected then
  begin
    ShowMessage('PostgreSQL não conectado!');
    Exit;
  end;

  if FCHATGPT = nil then
    FCHATGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  if Trim(deps) = '' then
    ctxDeps := CriaListaDependenciasPost('')
  else
    ctxDeps := deps;

  if Trim(ddl) = '' then
    ctxDDL := CriaDicionarioPost('')
  else
    ctxDDL := ddl;

  baseSchema := Trim(edSchemaPost.Text);
  if baseSchema = '' then baseSchema := 'public';

  FCHATGPT.Dev :=
    'Você é um assistente SQL para PostgreSQL.' + LineEnding +
    'REGRAS:' + LineEnding +
    '1) Responda SOMENTE com SQL válido, sem explicações ou comentários.' + LineEnding +
    '2) Use exatamente os nomes de schema/tabela/coluna informados.' + LineEnding +
    '3) Considere as dependências (FKs) e os DDLs fornecidos.' + LineEnding +
    '4) Se algo não for possível por falta de dados, use comentários SQL iniciando com -- TODO.' + LineEnding +
    '5) Não gerar dados fictícios; somente DDL/DML/queries necessárias.';

  ask :=
    'Pergunta do usuário:' + LineEnding +
    pergunta + LineEnding + LineEnding +
    '--- CONTEXTO: DEPENDÊNCIAS (FK) ---' + LineEnding +
    ctxDeps + LineEnding + LineEnding +
    '--- CONTEXTO: DDL COMPLETO DAS TABELAS ---' + LineEnding +
    ctxDDL + LineEnding + LineEnding +
    'Gere APENAS o SQL final (um único bloco).';

  FCHATGPT.TOKEN := FSetMain.CHATGPT;

  if FCHATGPT.SendQuestion(ask) then
    outSQL := StripCodeFences(FCHATGPT.Response)
  else
    outSQL := StripCodeFences(FCHATGPT.Response);

  outAnsi := UTF8ToAnsi(outSQL);
  Result := String(outAnsi);
end;

function Tfrmmquery2.QuestionarSQLSQLite(const pergunta, deps, ddl: string): string;

  function StripCodeFences(const S: string): string;
  var
    R: string;
    p1, p2: SizeInt;
  begin
    R := S;
    p1 := Pos('```', R);
    if p1 > 0 then
    begin
      Delete(R, 1, p1 + 2);
      if (Length(R) >= 3) and (LowerCase(Copy(R, 1, 3)) = 'sql') then
        Delete(R, 1, 3);
      p2 := RPos('```', R);
      if p2 > 0 then
        R := Copy(R, 1, p2 - 1);
    end;
    Result := Trim(R);
  end;

var
  ctxDeps, ctxDDL, ask, outSQL: string;
  outAnsi: AnsiString;
begin
  Result := '';

  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  if FCHATGPT = nil then
    FCHATGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  if Trim(deps) = '' then
    ctxDeps := CriaListaDependenciasSQLite('')
  else
    ctxDeps := deps;

  if Trim(ddl) = '' then
    ctxDDL := CriaDicionarioSQLite('')
  else
    ctxDDL := ddl;

  FCHATGPT.Dev :=
    'Você é um assistente SQL para SQLite.' + LineEnding +
    'REGRAS:' + LineEnding +
    '1) Responda SOMENTE com SQL válido para SQLite, sem explicações ou comentários.' + LineEnding +
    '2) Use exatamente os nomes de tabela/coluna informados.' + LineEnding +
    '3) Considere as dependências (FKs) e os DDLs fornecidos.' + LineEnding +
    '4) Se algo não for possível por falta de dados, use comentários SQL iniciando com -- TODO.' + LineEnding +
    '5) Não gerar dados fictícios; somente DDL/DML/queries necessárias.';

  ask :=
    'Pergunta do usuário:' + LineEnding +
    pergunta + LineEnding + LineEnding +
    '--- CONTEXTO: DEPENDÊNCIAS (FK) ---' + LineEnding +
    ctxDeps + LineEnding + LineEnding +
    '--- CONTEXTO: DDL COMPLETO DAS TABELAS ---' + LineEnding +
    ctxDDL + LineEnding + LineEnding +
    'Gere APENAS o SQL final (um único bloco).';

  FCHATGPT.TOKEN := FSetMain.CHATGPT;

  if FCHATGPT.SendQuestion(ask) then
    outSQL := StripCodeFences(FCHATGPT.Response)
  else
    outSQL := StripCodeFences(FCHATGPT.Response);

  outAnsi := UTF8ToAnsi(outSQL);
  Result := String(outAnsi);
end;

function Tfrmmquery2.ValidaConexao(TipoBanco: Integer): Boolean;
var
  Q: TZQuery;
  conexao: Boolean;
begin
  Result := False;

  try
    if (TipoBanco = 1) and (Trim(FSetMain.SchemaPost) <> '') then
    begin
      Q := TZQuery.Create(nil);
      try
        Q.Connection := zconpost;
        Q.SQL.Text := 'SET search_path TO ' + FSetMain.SchemaPost;
        Q.ExecSQL;
      finally
        Q.Free;
      end;
    end;

    conexao := False;

    if (frmmquery2 = nil) then
      frmmquery2 := Tfrmmquery2.Create(Self);

    case TipoBanco of
      0:
      begin
        frmmquery2.edHostName.Text := FSetMain.HostnameMy;
        frmmquery2.edBanco.Text    := FSetMain.BancoMy;
        frmmquery2.edusuario.Text  := FSetMain.UsernameMy;
        frmmquery2.edPasswrd.Text  := FSetMain.PasswordMy;

        conexao := frmmquery2.ConectMy;
      end;

      1:
      begin
        frmmquery2.edHostNamePost.Text := FSetMain.HostnamePost;
        frmmquery2.edSchemaPost.Text   := FSetMain.SchemaPost;
        frmmquery2.edBancoPost.Text    := FSetMain.BancoPOST;
        frmmquery2.edusuarioPost.Text  := FSetMain.UsernamePost;
        frmmquery2.edPasswrdPost.Text  := FSetMain.PasswordPost;

        conexao := frmmquery2.ConectPost;
      end;

      2:
      begin
        frmmquery2.edDatabase.Text := FSetMain.BancoSQLite;
        conexao := frmmquery2.ConectSQLite;
      end;

    else
      raise Exception.Create('TipoBanco inválido. Use 0=MySQL, 1=Postgres, 2=SQLite.');
    end;

    Result := conexao;

  except
    on E: Exception do
      Result := False;
  end;
end;

function Tfrmmquery2.DescreveTabelaIAPost(tabela: string): string;
begin
  Result := '-- TODO: implemente DescreveTabelaIAPost(' + tabela + ')';
end;

procedure Tfrmmquery2.Pesquisar(sender: TObject);

  procedure ScanSyn(syn: TSynEdit; lst: TListBox);
  var
    sFind, txt: string;
    p, startPos: Integer;
  begin
    if syn = nil then Exit;
    if lst = nil then Exit;

    sFind := Trim(strFind);
    if sFind = '' then Exit;

    txt := syn.Text;
    startPos := 1;

    while True do
    begin
      p := PosEx(sFind, txt, startPos);
      if p <= 0 then Break;
      startPos := p + Length(sFind);
    end;
  end;

begin
  lstfind.Clear;
  lstfind1.Clear;
  lstfind2.Clear;

  if Trim(strFind) = '' then
  begin
    ProcessaErro('Informe o texto para pesquisar.');
    Exit;
  end;

  ScanSyn(edSQL, lstfind);
  ScanSyn(edSQL1, lstfind1);
  ScanSyn(edSQLPost, lstfind2);
end;

procedure Tfrmmquery2.ProcessaErro(message: string);
begin
  if Assigned(edErro) then edErro.Append(message);
  if Assigned(edErro1) then edErro1.Append(message);
  if Assigned(edErro2) then edErro2.Append(message);

  MessageHint(message);
end;

function Tfrmmquery2.RectIsEmpty(const aRect: TRect): Boolean;
begin
  Result := (aRect.Left = 0) and (aRect.Top = 0) and (aRect.Right = 0) and (aRect.Bottom = 0);
end;

function Tfrmmquery2.ToRect(const aTopLeft, aBottomRight: TPoint): TRect;
begin
  Result.TopLeft := aTopLeft;
  Result.BottomRight := aBottomRight;
end;

function Tfrmmquery2.ToRect(const aTop, aLeft, aBottom, aRight: LongInt): TRect;
begin
  Result.Top := aTop;
  Result.Left := aLeft;
  Result.Bottom := aBottom;
  Result.Right := aRight;
end;

function Tfrmmquery2.RectInRect(const aOuterRect, aInnerRect: TRect): Boolean;
begin
  Result := (aInnerRect.Left   >= aOuterRect.Left)   and (aInnerRect.Left   <= aOuterRect.Right)  and
            (aInnerRect.Right  >= aOuterRect.Left)   and (aInnerRect.Right  <= aOuterRect.Right)  and
            (aInnerRect.Top    >= aOuterRect.Top)    and (aInnerRect.Top    <= aOuterRect.Bottom) and
            (aInnerRect.Bottom >= aOuterRect.Top)    and (aInnerRect.Bottom <= aOuterRect.Bottom);
end;

end.
