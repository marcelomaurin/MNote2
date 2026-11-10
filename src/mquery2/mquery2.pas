unit mquery2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Menus, ValEdit, SynEdit, SynHighlighterSQL, SynCompletion,
  ZConnection, ZDataset, ZPgEventAlerter, Tabela, views, View, strUtils, DB,
  csvdataset, SynEditTypes, SynGutterBase, SynEditMarks, SynEditKeyCmds,
  SynPluginSyncroEdit, SynGutterMarks, SynGutterLineNumber, SynGutterChanges,
  SynGutter, SynGutterCodeFolding, LCLType, Grids, Buttons,
  PairSplitter, DBCtrls, DBGrids, EditBtn, finds, ZClasses, ZCollections,
  ZCompatibility, ZTokenizer, ZSelectSchema, ZGenericSqlAnalyser, ZDbcLogging,
  ZVariant, ZPlainDriver, TypeDB, triggers, item, funcoes, chart,
  codigo, setmain, ZDbcIntfs, math, hint, Variants, LConvEncoding, base,
  mnote_ai_service, mnote_db_diagram_model, mnote_db_diagram_reader,
  mnote_db_diagram_form, fpjson, jsonparser,
  mquery_sqlassist, mquery_querytabs;

const
  sqltabela   = 'Você poderia me fornecer a consulta SQL que deseja analisar? Assim que eu receber o SQL, irei extrair os nomes das tabelas envolvidas e gerar um código em JSON com esses nomes. A resposta será apresentada dentro de uma caixa de texto apropriada para cópia, Desta forma refaça a pergunta mesmo nao havendo certeza da resposta,claramente formatada como um código JSON:';
  sqlMelhorias= 'Faça uma analise de melhorias do sql a seguir, gerando um codigo JSON onde cada melhoria fica listada em uma lista no campo melhoria, nao acrescentando numeração, apenas uma lista de melhorias como elementos deste campo';
  sqlEstetica = 'Por favor, forneça um código embelezado para o seguinte SQL. Gostaria que ele fosse apresentado em uma caixa de texto ou em um formato que me permita copiar e colar facilmente no meu editor de código. Aqui está o SQL: ';

type

  { Tfrmmquery2 }

  { Controles das abas criadas em codigo (SQL Server = 3, Oracle = 4) }
  TMQueryDynUI = record
    Tab, TSConn, TSSQL, TSGrid, TSLog, TSTools: TTabSheet;
    PC: TPageControl;
    Conn: TZConnection;
    ExecQry, GridQry: TZQuery;
    DS: TDataSource;
    Tree: TTreeView;
    SearchEdit, HostEdit, BancoEdit, UserEdit, PassEdit, SchemaEdit: TEdit;
    ConnectBtn, OpenBtn: TButton;
    SynEdit: TSynEdit;
    ErrorMemo, LogMemo, IAMemo: TMemo;
    IAPanel: TPanel;
    FindList: TListBox;
    LineLabel, ColLabel: TLabel;
    Nav: TDBNavigator;
    Grid: TDBGrid;
    MakeCombo: TComboBox;
  end;

  { Um lado da comparacao de estrutura (botao Comparar) }
  TCmpLado = record
    Engine: Integer;          // 0 MySQL, 1 PostgreSQL, 2 SQLite, 3 SQL Server, 4 Oracle
    Conn: TZConnection;
    Banco, Schema: string;
    Temp: Boolean;            // conexao temporaria criada so para comparar
  end;

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
    miLoadConnection: TMenuItem;
    miSaveConnection: TMenuItem;
    miConnSep: TMenuItem;
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
    tsSqlite: TTabSheet;
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
    tbConxao: TTabSheet;
    tbLog: TTabSheet;
    tbSQL: TTabSheet;
    tbTools: TTabSheet;
    ToggleBox2: TToggleBox;
    tsMysql: TTabSheet;
    tsPostgree: TTabSheet;
    TrayIcon1: TTrayIcon;
    tvsqlite: TTreeView;
    tvPost: TTreeView;
    tvMysql: TTreeView;
    zconmysql: TZConnection;
    zconsqlite: TZConnection;
    zconpost: TZConnection;
    zmyqry: TZReadOnlyQuery;
    zmyqry1: TZReadOnlyQuery;
    zmyqry2: TZQuery;
    zliteqry: TZReadOnlyQuery;
    zliteqry1: TZReadOnlyQuery;
    zliteqry2: TZQuery;
    zpostqry: TZReadOnlyQuery;
    zpostqry1: TZQuery;
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
    procedure miLoadConnectionClick(Sender: TObject);
    procedure miSaveConnectionClick(Sender: TObject);
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
    procedure zconpostAfterConnect(Sender: TObject);
    procedure ZPgEventAlerter1Notify(Sender: TObject; Event: string;
      ProcessID: Integer; Payload: string);

  private

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

    // ===== SQL Server (MSSQL) Dynamic Controls =====
    tsMSSQL: TTabSheet;
    pcMSSQL: TPageControl;
    tsConnMSSQL: TTabSheet;
    tsSQLMSSQL: TTabSheet;
    tsGridMSSQL: TTabSheet;
    tsLogMSSQL: TTabSheet;
    tsToolsMSSQL: TTabSheet;
    zconMSSQL: TZConnection;
    zmssqlqry: TZQuery;
    dsmssql: TDataSource;
    tvMSSQL: TTreeView;
    edHostMSSQL: TEdit;
    edBancoMSSQL: TEdit;
    edUserMSSQL: TEdit;
    edPassMSSQL: TEdit;
    edSchemaMSSQL: TEdit;
    btConectarMSSQL: TButton;
    edSQLMSSQL: TSynEdit;
    btExecMSSQL: TButton;
    dbgridMSSQL: TDBGrid;
    edErroMSSQL: TMemo;
    tvitemMSSQL: TTreeNode;
    posicaofieldsMSSQL: TTreeNode;

     // ===== Oracle Dynamic Controls =====
    tsOracle: TTabSheet;
    pcOracle: TPageControl;
    tsConnOracle: TTabSheet;
    tsSQLOracle: TTabSheet;
    tsGridOracle: TTabSheet;
    tsLogOracle: TTabSheet;
    tsToolsOracle: TTabSheet;
    zconOracle: TZConnection;
    zoracleqry: TZQuery;
    dsoracle: TDataSource;
    tvOracle: TTreeView;
    edHostOracle: TEdit;
    edBancoOracle: TEdit;
    edUserOracle: TEdit;
    edPassOracle: TEdit;
    edSchemaOracle: TEdit;
    btConectarOracle: TButton;
    edSQLOracle: TSynEdit;
    btExecOracle: TButton;
    dbgridOracle: TDBGrid;
    edErroOracle: TMemo;
    tvitemOracle: TTreeNode;
    posicaofieldsOracle: TTreeNode;

    FDyn: array[3..4] of TMQueryDynUI;

    pmDatabaseMSSQL: TPopupMenu;
    mnCriaDicionarioMSSQL: TMenuItem;
    pmDatabaseOracle: TPopupMenu;
    mnCriaDicionarioOracle: TMenuItem;
    pmTabelaMSSQL: TPopupMenu;
    pmTabelaOracle: TPopupMenu;
    btSalvarPost: TButton;
    btSalvarMy: TButton;
    btSalvarLite: TButton;
    FCompletions: array[0..4] of TSynCompletion;
    { Catalogo (tabelas/colunas) de cada banco: 0 MySQL, 1 PostgreSQL,
      2 SQLite, 3 SQL Server, 4 Oracle. Compartilhado pelo editor antigo
      e pelas abas de consulta. }
    FCatalogs: array[0..4] of TMQueryCatalog;
    FCompletionCtl: array[0..4] of TMQueryCompletionController;
    FQueryBooks: array[0..4] of TMQueryQueryBook;
    { Dono (schema) das tabelas Oracle carregadas na arvore; usado tambem
      pelo dicionario, comparacao, diagrama e dependencias. }
    FOracleOwner: string;
    function OracleOwner: string;
    function SalvarConexaoArquivo(const AFileName: string; AEngineIndex: Integer = -1): Boolean;
    function CarregarConexaoArquivo(const AFileName: string): Boolean;
    function GetActiveSQLEditor: TSynEdit;
    function EditorDoMenu(Sender: TObject): TSynEdit;
    function LocalizaBibliotecaBanco(const APasta: string;
      const AArquivos: array of string; const AConfigurado: string): string;
    procedure PreparaPastaBiblioteca(const ABiblioteca: string);

    // Comparar estrutura
    function CmpNomeMotor(AEngine: Integer): string;
    function CmpConexao(AEngine: Integer): TZConnection;
    function CmpDescreve(const ALado: TCmpLado): string;
    function CmpLadoPadrao(AEngine: Integer): TCmpLado;
    function CmpConexaoTemporaria(ABase: TZConnection; const ABanco: string): TZConnection;
    procedure CmpLerEstrutura(const ALado: TCmpLado; ATabelas: TStringList);
    function CmpNovaListaColunas: TStringList;
    function CmpNovaListaTabelas: TStringList;
    function CmpGeraRelatorio(const AOrigem, ADestino: TCmpLado; ATabA, ATabB: TStringList): string;
    function CmpEscolhe(const ATitulo: string; AOpcoes: TStrings): Integer;
    procedure ExecutaComandoMy(const ASQL: string);
    procedure ExecutaComandoPost(const ASQL: string);

    procedure btSalvarPostClick(Sender: TObject);
    procedure btSalvarMyClick(Sender: TObject);
    procedure btSalvarLiteClick(Sender: TObject);
    procedure btSalvarDynamicClick(Sender: TObject);
    procedure SalvarAlteracoes(AGrid: TDBGrid; ADataSet: TDataSet);

    procedure miScriptSelectClick(Sender: TObject);
    procedure miScriptInsertClick(Sender: TObject);
    procedure miScriptUpdateClick(Sender: TObject);
    procedure miScriptDeleteClick(Sender: TObject);

    function GetSelectedTableNode(ATree: TTreeView; AParentRoot: TTreeNode): TTreeNode;
    procedure ObterTabelaInfo(ATableNode: TTreeNode; out ATableName: string; AColunas, APKs: TStrings);
    procedure GerarScriptTabela(AEngineIndex: Integer; const ATipoScript: string);
    procedure InstallTableScriptMenus;
    procedure AddScriptMenuItems(AMenu: TPopupMenu; AEngineIndex: Integer);
    procedure InicializarGridEditing;

    procedure InicializarAutocomplete;
    procedure CriarCatalogos;
    procedure InstalarAbasConsultas;
    procedure ConfigurarCompletion(AComp: TSynCompletion; AEditor: TSynEdit);
    procedure AtualizarAutocomplete(AEngineIndex: Integer);
    function GetActiveEngineIndex: Integer;
    procedure pgMainChange(Sender: TObject);

    procedure mnCriaDicionarioMSSQLClick(Sender: TObject);
    procedure mnCriaDicionarioOracleClick(Sender: TObject);

    // Abas dinamicas de SQL Server (3) e Oracle (4), no mesmo padrao do PostgreSQL
    procedure CreateDynamicDBTab(AEngine: Integer; const ATitle: string);
    function DynEngineFromSender(Sender: TObject): Integer;
    function DynNome(AEngine: Integer): string;
    function DynQuoteIdent(AEngine: Integer; const AName: string): string;
    function DynExigeConexao(AEngine: Integer): Boolean;
    procedure DynLog(AEngine: Integer; const AMsg: string; AIsError: Boolean = False);
    function DynExecSQL(AEngine: Integer; const ASQL: string): Boolean;
    function CriaListaDependenciasDyn(AEngine: Integer): string;
    function QuestionarSQLDyn(AEngine: Integer; const APergunta: string): string;
    procedure DynOpenClick(Sender: TObject);
    procedure DynExecuteClick(Sender: TObject);
    procedure DynAnaliseClick(Sender: TObject);
    procedure DynIAClick(Sender: TObject);
    procedure DynChartClick(Sender: TObject);
    procedure DynMakeClick(Sender: TObject);
    procedure DynCriaBancoClick(Sender: TObject);
    procedure DynCriaUsuarioClick(Sender: TObject);
    procedure DynPermissaoClick(Sender: TObject);
    procedure DynPesqKeyPress(Sender: TObject; var Key: char);
    procedure DynSQLStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure DynFontClick(Sender: TObject);
    procedure DynNewEditClick(Sender: TObject);
    procedure DynEmbelezarClick(Sender: TObject);
    procedure DynToggleIAClick(Sender: TObject);

    procedure btConectarMSSQLClick(Sender: TObject);
    procedure tvMSSQLChange(Sender: TObject; Node: TTreeNode);
    procedure ListarTabelasMSSQL();
    function ConectMSSQL: Boolean;

    procedure btConectarOracleClick(Sender: TObject);
    procedure tvOracleChange(Sender: TObject; Node: TTreeNode);
    procedure ListarTabelasOracle();
    function ConectOracle: Boolean;

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
    function DynGridDataSet(AEngine: Integer): TDataSet;
    function QueryBook(AEngine: Integer): TMQueryQueryBook;
    function NovaConsulta(AEngine: Integer; const ATexto: string = ''): TMQueryQueryTab;
    procedure InstallDiagramMenus;
    procedure DiagramMenuClick(Sender: TObject);
    function DiagramConnection(AIndex: Integer; out ASchema: string): TZConnection;
    function GetDatabaseTree(AIndex: Integer; out AName, AContextId: string; ATables: TStrings): Boolean;
    procedure OpenDiagramContext(const AContextId, ATable: string);
    function CriaDicionarioSQLite(const ATargetFile: string): string;
    function BuildCreateTableSQLite(const ATabela: string): string;
    function CriaListaDependenciasSQLite(const outFile: string): string;
    function QuestionarSQLSQLite(const pergunta, deps, ddl: string): string;

    procedure ChartView; overload;
    procedure ChartView(AType: TChartCommType); overload;

    procedure RefreshPost();
    procedure RefreshMy();
    procedure RefreshSQLite();
    function GetActiveDatabaseTree(out ADatabaseName: string;
      ATables: TStrings): Boolean;

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
    function CriaDicionarioMSSQL(const ATargetFile: string): string;
    function CriaDicionarioOracle(const ATargetFile: string): string;
    function CriaListaDependenciasPost(const outFile: string): string;
    function QuestionarSQLPost(const pergunta, deps, ddl: string): string;
    function ValidaConexao(TipoBanco: Integer ): Boolean;

    procedure OpenSelectPost();
    procedure OpenSelectMy();
    procedure OpenSelectLite();
  end;

function MontarScriptSQL(const ATableName, ATipoScript: string; AColunas, APKs: TStrings): string;
function ExtractFieldName(const S: string): string;
procedure ExtractPKNames(const S: string; AList: TStrings);
function NormalizarTipoBanco(const ATipo: string): string;
function ConnectionToJsonString(const ATipo, AHost: string; APort: Integer; const ADatabase, AUsername, APassword, ASchema: string): string;
function JsonStringToConnection(const AJson: string; out ATipo, AHost: string; out APort: Integer; out ADatabase, AUsername, APassword, ASchema: string): Boolean;

var
  frmmquery2: Tfrmmquery2;

implementation

{$R *.lfm}

uses benchmark, main;

{$IFDEF WINDOWS}
function MQuerySetEnvironmentVariableW(lpName, lpValue: PWideChar): LongBool; stdcall;
  external 'kernel32.dll' name 'SetEnvironmentVariableW';
{$ENDIF}

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
  // O botao e um TToggleBox: OnChange dispara ao marcar e ao desmarcar.
  // Age so ao marcar e volta ao estado normal no final.
  if (Sender is TToggleBox) and not TToggleBox(Sender).Checked then Exit;
  try
    usuario := Trim(InputBox('Criação de usuário', 'Usuário:', 'username'));
    if usuario = '' then Exit;
    senha := InputBox('Criação de usuário', 'Senha:', 'secret');

    // ToggleBox2 fica na aba MySQL; ToggleBox3 na aba PostgreSQL
    if Sender = ToggleBox2 then
    begin
      edSQL.Text := Format('CREATE USER %s@''%%'' IDENTIFIED BY %s;',
                           [QuotedStr(JuntaNome(usuario)), QuotedStr(senha)]);
      ExecutaComandoMy(edSQL.Text);
    end
    else
    begin
      edSQLPost.Text := Format('CREATE USER %s WITH PASSWORD %s;',
                               [JuntaNome(usuario), QuotedStr(senha)]);
      ExecutaComandoPost(edSQLPost.Text);
    end;
  finally
    if Sender is TToggleBox then TToggleBox(Sender).Checked := False;
  end;
end;

function Tfrmmquery2.TrocarPalavra(Info: String; de: String; para: String): String;
begin
  Result := StringReplace(Info, de, para, [rfReplaceAll, rfIgnoreCase]);
end;

function Tfrmmquery2.FormataSQL(Info: string): string;
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
  if Node = tvitemmy then tvMysql.PopupMenu := pmDatabaseMy;

  if node <> nil then
  begin
    if (node.Parent <> nil) then
    begin
      if (node.parent = posicaofieldsmy) then
      begin
        tvMysql.PopupMenu := pmTabelaMy;
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
    if(node = tvTablePost) or (node = posicaofieldspost) then
    begin
      ProcuraTVPost(Node.Text);
      tvPost.PopupMenu := pmTabelasPost;
    end
    else
    begin
      if (node <> nil) then
      begin
        if(node.ImageIndex = 14) or ((node.Parent <> nil) and (node.Parent = posicaofieldspost)) then
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

  // Cria a aba SQL Server em codigo (mesmo padrao do PostgreSQL)
  CreateDynamicDBTab(3, 'SQL Server');

  // Initialize SQL Server tree node database parent
  tvitem := TTreeNode.Create(tvMSSQL.Items);
  tvitemMSSQL := tvMSSQL.Items.AddObject(tvitem,'SQL Server', pointer(ETDBBanco));
  tvitemMSSQL.ImageIndex := -1;

  // Cria a aba Oracle em codigo (mesmo padrao do PostgreSQL)
  CreateDynamicDBTab(4, 'Oracle');

  // Initialize Oracle tree node database parent
  tvitem := TTreeNode.Create(tvOracle.Items);
  tvitemOracle := tvOracle.Items.AddObject(tvitem,'Oracle', pointer(ETDBBanco));
  tvitemOracle.ImageIndex := -1;

  // Initialize dynamic popups for MSSQL and Oracle
  pmDatabaseMSSQL := TPopupMenu.Create(Self);
  mnCriaDicionarioMSSQL := TMenuItem.Create(pmDatabaseMSSQL);
  mnCriaDicionarioMSSQL.Caption := 'Criar Dicionário de Dados';
  mnCriaDicionarioMSSQL.OnClick := @mnCriaDicionarioMSSQLClick;
  pmDatabaseMSSQL.Items.Add(mnCriaDicionarioMSSQL);

  pmDatabaseOracle := TPopupMenu.Create(Self);
  mnCriaDicionarioOracle := TMenuItem.Create(pmDatabaseOracle);
  mnCriaDicionarioOracle.Caption := 'Criar Dicionário de Dados';
  mnCriaDicionarioOracle.OnClick := @mnCriaDicionarioOracleClick;
  pmDatabaseOracle.Items.Add(mnCriaDicionarioOracle);

  // InstallTableScriptMenus cria pmTabelaMSSQL/pmTabelaOracle e precisa vir
  // antes de InstallDiagramMenus, que acrescenta itens nesses menus.
  InstallTableScriptMenus;
  InstallDiagramMenus;
  InicializarGridEditing;
  CriarCatalogos;
  InicializarAutocomplete;
  pgMain.OnChange := @pgMainChange;
  InstalarAbasConsultas;

  {$IFDEF WINDOWS}
  zconpost.LibraryLocation := FSetMain.DLLPostPath;
  zconmysql.LibraryLocation := FSetMain.DLLMyPath;
  zconMSSQL.LibraryLocation := FSetMain.DLLMSSQLPath;
  zconOracle.LibraryLocation := FSetMain.DLLOraclePath;
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

  if Assigned(FSetMain) then
  begin
    edHostName.Text := FSetMain.HostnameMy;
    edBanco.Text := FSetMain.BancoMy;
    edusuario.Text := FSetMain.UsernameMy;
    edPasswrd.Text := FSetMain.PasswordMy;
  end;

  edHostNamePost.Text := FSetmain.HostnamePost;
  edBancoPost.Text := FSetmain.BancoPOST;
  edusuarioPost.Text := FSetmain.UsernamePost;
  edPasswrdPost.Text := FSetmain.PasswordPost;
  edSchemaPost.Text := FSetmain.SchemaPost;
  edDatabase.Text := FSetMain.BancoSQLite;

  // Load SQL Server inputs
  edHostMSSQL.Text := FSetMain.HostnameMSSQL;
  edBancoMSSQL.Text := FSetMain.BancoMSSQL;
  edUserMSSQL.Text := FSetMain.UsernameMSSQL;
  edPassMSSQL.Text := FSetMain.PasswordMSSQL;
  edSchemaMSSQL.Text := FSetMain.SchemaMSSQL;

  // Load Oracle inputs
  edHostOracle.Text := FSetMain.HostnameOracle;
  edBancoOracle.Text := FSetMain.BancoOracle;
  edUserOracle.Text := FSetMain.UsernameOracle;
  edPassOracle.Text := FSetMain.PasswordOracle;
  edSchemaOracle.Text := FSetMain.SchemaOracle;

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

function Tfrmmquery2.GetActiveSQLEditor: TSynEdit;
begin
  if pgMain.ActivePage = tsMysql then Result := edSQL
  else if pgMain.ActivePage = tsPostgree then Result := edSQLPost
  else if pgMain.ActivePage = tsSqlite then Result := edSQL1
  else if pgMain.ActivePage = tsMSSQL then Result := edSQLMSSQL
  else if pgMain.ActivePage = tsOracle then Result := edSQLOracle
  else Result := edSQL;
end;

procedure Tfrmmquery2.MenuItem5Click(Sender: TObject);
var
  ed: TSynEdit;
begin
  ed := GetActiveSQLEditor;
  SaveDialog1.Title := 'Salvar SQL';
  SaveDialog1.Filter := 'Arquivos SQL (*.sql)|*.sql|Todos os Arquivos (*.*)|*.*';
  SaveDialog1.DefaultExt := 'sql';
  if SaveDialog1.Execute then
    ed.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure Tfrmmquery2.MenuItem6Click(Sender: TObject);
var
  ed: TSynEdit;
begin
  ed := GetActiveSQLEditor;
  OpenDialog1.Title := 'Carregar SQL';
  OpenDialog1.Filter := 'Arquivos SQL (*.sql)|*.sql|Todos os Arquivos (*.*)|*.*';
  OpenDialog1.DefaultExt := 'sql';
  if OpenDialog1.Execute then
    ed.Lines.LoadFromFile(OpenDialog1.FileName);
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
begin
  ts := frmMNote.NovoItem();
  item := TItem(ts.Tag);
  item.syn.Text := EditorDoMenu(Sender).Lines.Text;
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
var
  ed: TSynEdit;
begin
  ed := EditorDoMenu(Sender);
  frmMNote.NewContext();
  frmMNote.edChat.Text := sqlEstetica + ed.Text;
  frmMNote.FazPergunta();
  if (frmMNote.meCodes.Text <> '') then
    ed.Text := frmMNote.meCodes.Text;
end;

procedure Tfrmmquery2.miEsconderClick(Sender: TObject);
begin
  Hide;
end;

function Tfrmmquery2.EditorDoMenu(Sender: TObject): TSynEdit;
var
  M: TMenu;
begin
  // Editor sobre o qual o menu de contexto foi aberto
  Result := nil;
  if Sender is TMenuItem then
  begin
    M := TMenuItem(Sender).GetParentMenu;
    if (M is TPopupMenu) and (TPopupMenu(M).PopupComponent is TSynEdit) then
      Result := TSynEdit(TPopupMenu(M).PopupComponent);
  end;
  if Result = nil then
    Result := GetActiveSQLEditor;
end;

procedure Tfrmmquery2.miFontClick(Sender: TObject);
var
  ed: TSynEdit;
begin
  ed := EditorDoMenu(Sender);
  FontDialog1.Font := ed.Font;
  if FontDialog1.Execute then
    ed.Font := FontDialog1.Font;
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

  if (pgMain.ActivePage = tsSqlite) or ((not zconpost.Connected) and zconsqlite.Connected) then
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
var
  DbPath: string;
begin
  Result := False;

  if zconsqlite.Connected then
    zconsqlite.Disconnect;

  DbPath := Trim(edDatabase.Text);
  if (Length(DbPath) >= 2) and (DbPath[1] = #34) and (DbPath[Length(DbPath)] = #34) then
    DbPath := Copy(DbPath, 2, Length(DbPath) - 2);

  zconsqlite.Protocol := 'sqlite';
  zconsqlite.Database := DbPath;

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
  try
  tvitemmy.DeleteChildren;
  posicaofieldsmy := nil;

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
  finally
    if frmMNote <> nil then frmMNote.SyncSolutionDatabaseFromMQuery;
  end;
end;

procedure Tfrmmquery2.RefreshPost;
var
  tvitem: TTreeNode;
begin
  try
  tvitempost.DeleteChildren;
  posicaofieldspost := nil;
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
    BuscaSequence(zpostqry, DBPostgres);
    ListarViewsPost();
  except
    on E: Exception do
      MessageHint('Erro ao preparar estrutura do PostgreSQL: ' + E.Message);
  end;
  finally
    if frmMNote <> nil then frmMNote.SyncSolutionDatabaseFromMQuery;
  end;
end;

procedure Tfrmmquery2.RefreshSQLite;
var
  tvitem: TTreeNode;
begin
  try
  if tvitemLite = nil then Exit;

  tvitemLite.DeleteChildren;
  posicaofieldslite := nil;

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
    AtualizarAutocomplete(2);
  except
    on E: Exception do
      MessageHint('Erro ao preparar estrutura do SQLite: ' + E.Message);
  end;
  finally
    if frmMNote <> nil then frmMNote.SyncSolutionDatabaseFromMQuery;
  end;
end;

procedure Tfrmmquery2.btConectarMyClick(Sender: TObject); begin RefreshMy; end;
procedure Tfrmmquery2.btConectarpostClick(Sender: TObject); begin RefreshPost; end;
procedure Tfrmmquery2.btConectarLiteClick(Sender: TObject); begin RefreshSQLite; end;

procedure Tfrmmquery2.btPermissaoChange(Sender: TObject);
var
  nome, banco: string;
begin
  // O botao e um TToggleBox: OnChange dispara ao marcar e ao desmarcar.
  if (Sender is TToggleBox) and not TToggleBox(Sender).Checked then Exit;
  try
    banco := Trim(InputBox('Permissão de banco', 'Database:', 'database'));
    if banco = '' then Exit;
    nome := Trim(InputBox('Permissão de banco', 'Usuário:', 'root'));
    if nome = '' then Exit;

    // btPermissao fica na aba MySQL; btPermissao1 na aba PostgreSQL
    if Sender = btPermissao then
    begin
      edSQL.Text := Format('GRANT ALL PRIVILEGES ON `%s`.* TO %s@''%%'';',
                           [JuntaNome(banco), QuotedStr(JuntaNome(nome))]);
      ExecutaComandoMy(edSQL.Text);
    end
    else
    begin
      edSQLPost.Text := Format('GRANT ALL PRIVILEGES ON DATABASE %s TO %s;',
                               [JuntaNome(banco), JuntaNome(nome)]);
      ExecutaComandoPost(edSQLPost.Text);
    end;
  finally
    if Sender is TToggleBox then TToggleBox(Sender).Checked := False;
  end;
end;

procedure Tfrmmquery2.btBancoClick(Sender: TObject);
var
  banco : string;
begin
  banco := Trim(InputBox('Criação de database', 'Banco:', 'database'));
  if banco = '' then Exit;

  // btBanco fica na aba MySQL; btBanco1 na aba PostgreSQL
  if Sender = btBanco then
  begin
    edSQL.Text := 'CREATE DATABASE `' + JuntaNome(banco) + '`;';
    ExecutaComandoMy(edSQL.Text);
  end
  else
  begin
    edSQLPost.Text := 'CREATE DATABASE "' + JuntaNome(banco) + '";';
    ExecutaComandoPost(edSQLPost.Text);
  end;
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
  // btAnalise1 fica na aba PostgreSQL; btAnalise na aba MySQL
  if Sender = btAnalise1 then
    Analisepost(edSQLPost.Lines.Text)
  else
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
procedure Tfrmmquery2.btChartClick(Sender: TObject);
begin
  // btChart1 fica na aba SQLite; btChart na aba MySQL
  if Sender = btChart1 then
    ChartView(ccSQLite)
  else
    ChartView(ccMySQL);
end;
procedure Tfrmmquery2.btChartPostClick(Sender: TObject); begin ChartView(ccPostgres); end;

{ ============================================================================
  Comparar estrutura
  Compara tabelas e colunas da conexao da aba (origem) com outra conexao
  aberta no Query Tools ou com outro banco/schema no mesmo servidor.
  Motores: 0 MySQL, 1 PostgreSQL, 2 SQLite, 3 SQL Server, 4 Oracle.
  ============================================================================ }

function Tfrmmquery2.CmpNomeMotor(AEngine: Integer): string;
begin
  case AEngine of
    0: Result := 'MySQL';
    1: Result := 'PostgreSQL';
    2: Result := 'SQLite';
    3: Result := 'SQL Server';
    4: Result := 'Oracle';
  else
    Result := '?';
  end;
end;

function Tfrmmquery2.CmpConexao(AEngine: Integer): TZConnection;
begin
  case AEngine of
    0: Result := zconmysql;
    1: Result := zconpost;
    2: Result := zconsqlite;
    3: Result := zconMSSQL;
    4: Result := zconOracle;
  else
    Result := nil;
  end;
end;

function Tfrmmquery2.CmpDescreve(const ALado: TCmpLado): string;
begin
  Result := CmpNomeMotor(ALado.Engine);
  if ALado.Engine = 2 then
    Result := Result + ' - arquivo ' + ALado.Banco
  else
  begin
    if ALado.Banco <> '' then
      Result := Result + ' - banco ' + ALado.Banco;
    if ALado.Schema <> '' then
      Result := Result + ' / schema ' + ALado.Schema;
  end;
end;

function Tfrmmquery2.CmpLadoPadrao(AEngine: Integer): TCmpLado;
begin
  Result.Engine := AEngine;
  Result.Conn := CmpConexao(AEngine);
  Result.Temp := False;
  Result.Banco := '';
  Result.Schema := '';
  if Result.Conn <> nil then
    Result.Banco := Result.Conn.Database;
  case AEngine of
    1:
      begin
        Result.Schema := Trim(edSchemaPost.Text);
        if Result.Schema = '' then Result.Schema := 'public';
      end;
    3:
      begin
        Result.Schema := Trim(edSchemaMSSQL.Text);
        if Result.Schema = '' then Result.Schema := 'dbo';
      end;
    4:
      begin
        Result.Schema := OracleOwner;
        if Result.Schema = '' then Result.Schema := UpperCase(zconOracle.User);
      end;
  end;
end;

function Tfrmmquery2.CmpConexaoTemporaria(ABase: TZConnection; const ABanco: string): TZConnection;
begin
  Result := TZConnection.Create(nil);
  try
    Result.Protocol := ABase.Protocol;
    Result.HostName := ABase.HostName;
    Result.Port := ABase.Port;
    Result.User := ABase.User;
    Result.Password := ABase.Password;
    Result.LibraryLocation := ABase.LibraryLocation;
    Result.ClientCodepage := ABase.ClientCodepage;
    Result.ControlsCodePage := ABase.ControlsCodePage;
    Result.Properties.Assign(ABase.Properties);
    Result.LoginPrompt := False;
    Result.Database := ABanco;
    Result.Connect;
  except
    Result.Free;
    raise;
  end;
end;

procedure Tfrmmquery2.CmpLerEstrutura(const ALado: TCmpLado; ATabelas: TStringList);
var
  Q, QCol: TZQuery;
  Tabelas: TStringList;
  I, Idx: Integer;
  Prefixo: string;

  procedure AddColuna(const ATabela, AColuna, ATipo: string);
  var
    P: Integer;
  begin
    P := ATabelas.IndexOf(ATabela);
    if P < 0 then
      P := ATabelas.AddObject(ATabela, CmpNovaListaColunas);
    TStringList(ATabelas.Objects[P]).Add(AColuna + '=' + Trim(ATipo));
  end;

begin
  Q := TZQuery.Create(nil);
  QCol := TZQuery.Create(nil);
  Tabelas := TStringList.Create;
  try
    Q.Connection := ALado.Conn;
    QCol.Connection := ALado.Conn;

    case ALado.Engine of
      0:
        begin
          Q.SQL.Text :=
            'SELECT c.TABLE_NAME AS TABELA, c.COLUMN_NAME AS COLUNA, c.COLUMN_TYPE AS TIPO ' +
            'FROM information_schema.COLUMNS c ' +
            'JOIN information_schema.TABLES t ON t.TABLE_SCHEMA = c.TABLE_SCHEMA ' +
            '  AND t.TABLE_NAME = c.TABLE_NAME AND t.TABLE_TYPE = ''BASE TABLE'' ' +
            'WHERE c.TABLE_SCHEMA = :banco ' +
            'ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION';
          Q.ParamByName('banco').AsString := ALado.Banco;
        end;
      1:
        begin
          Q.SQL.Text :=
            'SELECT c.table_name AS tabela, c.column_name AS coluna, ' +
            '  c.data_type || COALESCE(''('' || c.character_maximum_length || '')'', '''') AS tipo ' +
            'FROM information_schema.columns c ' +
            'JOIN information_schema.tables t ON t.table_schema = c.table_schema ' +
            '  AND t.table_name = c.table_name AND t.table_type = ''BASE TABLE'' ' +
            'WHERE c.table_schema = :esquema ' +
            'ORDER BY c.table_name, c.ordinal_position';
          Q.ParamByName('esquema').AsString := ALado.Schema;
        end;
      3:
        begin
          Prefixo := '';
          if ALado.Banco <> '' then
            Prefixo := '[' + StringReplace(ALado.Banco, ']', ']]', [rfReplaceAll]) + '].';
          Q.SQL.Text :=
            'SELECT c.TABLE_NAME AS TABELA, c.COLUMN_NAME AS COLUNA, ' +
            '  c.DATA_TYPE + CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN ''(max)'' ' +
            '    WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL ' +
            '    THEN ''('' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS varchar(10)) + '')'' ELSE '''' END AS TIPO ' +
            'FROM ' + Prefixo + 'INFORMATION_SCHEMA.COLUMNS c ' +
            'JOIN ' + Prefixo + 'INFORMATION_SCHEMA.TABLES t ON t.TABLE_SCHEMA = c.TABLE_SCHEMA ' +
            '  AND t.TABLE_NAME = c.TABLE_NAME AND t.TABLE_TYPE = ''BASE TABLE'' ' +
            'WHERE c.TABLE_SCHEMA = :esquema ' +
            'ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION';
          Q.ParamByName('esquema').AsString := ALado.Schema;
        end;
      4:
        begin
          Q.SQL.Text :=
            'SELECT TABLE_NAME AS TABELA, COLUMN_NAME AS COLUNA, ' +
            '  DATA_TYPE || CASE WHEN DATA_TYPE IN (''VARCHAR2'', ''CHAR'', ''NVARCHAR2'', ''NCHAR'') ' +
            '    THEN ''('' || CHAR_LENGTH || '')'' END AS TIPO ' +
            'FROM ALL_TAB_COLUMNS ' +
            'WHERE OWNER = :dono1 ' +
            '  AND TABLE_NAME IN (SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER = :dono2) ' +
            'ORDER BY TABLE_NAME, COLUMN_ID';
          Q.ParamByName('dono1').AsString := ALado.Schema;
          Q.ParamByName('dono2').AsString := ALado.Schema;
        end;
    end;

    if ALado.Engine = 2 then
    begin
      // SQLite: lista as tabelas e le as colunas de cada uma
      Q.SQL.Text :=
        'SELECT name FROM sqlite_master WHERE type = ''table'' ' +
        'AND name NOT LIKE ''sqlite_%'' ORDER BY name';
      Q.Open;
      while not Q.EOF do
      begin
        Tabelas.Add(Q.FieldByName('name').AsString);
        Q.Next;
      end;
      Q.Close;
      for I := 0 to Tabelas.Count - 1 do
      begin
        QCol.SQL.Text := 'PRAGMA table_info(''' +
          StringReplace(Tabelas[I], '''', '''''', [rfReplaceAll]) + ''')';
        QCol.Open;
        Idx := ATabelas.IndexOf(Tabelas[I]);
        if Idx < 0 then
          ATabelas.AddObject(Tabelas[I], CmpNovaListaColunas);
        while not QCol.EOF do
        begin
          AddColuna(Tabelas[I], QCol.FieldByName('name').AsString,
            QCol.FieldByName('type').AsString);
          QCol.Next;
        end;
        QCol.Close;
      end;
    end
    else
    begin
      Q.Open;
      while not Q.EOF do
      begin
        AddColuna(Q.FieldByName('TABELA').AsString,
          Q.FieldByName('COLUNA').AsString,
          Q.FieldByName('TIPO').AsString);
        Q.Next;
      end;
      Q.Close;
    end;
  finally
    Tabelas.Free;
    QCol.Free;
    Q.Free;
  end;
end;

function Tfrmmquery2.CmpNovaListaColunas: TStringList;
begin
  Result := TStringList.Create;
  Result.CaseSensitive := False;
end;

function Tfrmmquery2.CmpNovaListaTabelas: TStringList;
begin
  Result := TStringList.Create;
  Result.CaseSensitive := False;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;
  Result.OwnsObjects := True;
end;

function Tfrmmquery2.CmpGeraRelatorio(const AOrigem, ADestino: TCmpLado;
  ATabA, ATabB: TStringList): string;
var
  R, SoA, SoB, Detalhe: TStringList;
  I, J, K, QtdTabDif, QtdColDif: Integer;
  ColsA, ColsB: TStringList;
  MesmoMotor: Boolean;
  Nome: string;
begin
  R := TStringList.Create;
  SoA := TStringList.Create;
  SoB := TStringList.Create;
  Detalhe := TStringList.Create;
  try
    MesmoMotor := AOrigem.Engine = ADestino.Engine;
    QtdTabDif := 0;
    QtdColDif := 0;

    for I := 0 to ATabA.Count - 1 do
      if ATabB.IndexOf(ATabA[I]) < 0 then
        SoA.Add(ATabA[I]);
    for I := 0 to ATabB.Count - 1 do
      if ATabA.IndexOf(ATabB[I]) < 0 then
        SoB.Add(ATabB[I]);

    // Tabelas presentes nos dois lados
    for I := 0 to ATabA.Count - 1 do
    begin
      J := ATabB.IndexOf(ATabA[I]);
      if J < 0 then Continue;
      ColsA := TStringList(ATabA.Objects[I]);
      ColsB := TStringList(ATabB.Objects[J]);
      K := Detalhe.Count;

      for J := 0 to ColsA.Count - 1 do
      begin
        Nome := ColsA.Names[J];
        if ColsB.IndexOfName(Nome) < 0 then
          Detalhe.Add('    coluna só na origem:  ' + Nome + ' ' + ColsA.ValueFromIndex[J])
        else if MesmoMotor and
          not SameText(ColsA.ValueFromIndex[J], ColsB.Values[Nome]) then
          Detalhe.Add('    tipo diferente:       ' + Nome + '  origem ' +
            ColsA.ValueFromIndex[J] + '  destino ' + ColsB.Values[Nome]);
      end;
      for J := 0 to ColsB.Count - 1 do
        if ColsA.IndexOfName(ColsB.Names[J]) < 0 then
          Detalhe.Add('    coluna só no destino: ' + ColsB.Names[J] + ' ' + ColsB.ValueFromIndex[J]);

      if Detalhe.Count > K then
      begin
        Inc(QtdTabDif);
        Inc(QtdColDif, Detalhe.Count - K);
        Detalhe.Insert(K, '  ' + ATabA[I]);
      end;
    end;

    R.Add('COMPARAÇÃO DE ESTRUTURA');
    R.Add('Data:    ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));
    R.Add('Origem:  ' + CmpDescreve(AOrigem) + Format(' (%d tabelas)', [ATabA.Count]));
    R.Add('Destino: ' + CmpDescreve(ADestino) + Format(' (%d tabelas)', [ATabB.Count]));
    if not MesmoMotor then
      R.Add('Bancos de tipos diferentes: os tipos das colunas não são comparados, só os nomes.');
    R.Add('');

    R.Add(Format('== Tabelas só na origem (%d) ==', [SoA.Count]));
    for I := 0 to SoA.Count - 1 do R.Add('  ' + SoA[I]);
    R.Add('');
    R.Add(Format('== Tabelas só no destino (%d) ==', [SoB.Count]));
    for I := 0 to SoB.Count - 1 do R.Add('  ' + SoB[I]);
    R.Add('');
    R.Add(Format('== Diferenças em tabelas comuns (%d tabelas, %d colunas) ==',
      [QtdTabDif, QtdColDif]));
    R.AddStrings(Detalhe);
    R.Add('');

    if (SoA.Count = 0) and (SoB.Count = 0) and (QtdColDif = 0) then
      R.Add('Resultado: estruturas iguais.')
    else
      R.Add(Format('Resultado: %d tabela(s) só na origem, %d só no destino, ' +
        '%d diferença(s) de coluna em %d tabela(s) comum(ns).',
        [SoA.Count, SoB.Count, QtdColDif, QtdTabDif]));

    Result := R.Text;
  finally
    Detalhe.Free;
    SoB.Free;
    SoA.Free;
    R.Free;
  end;
end;

function Tfrmmquery2.CmpEscolhe(const ATitulo: string; AOpcoes: TStrings): Integer;
var
  F: TForm;
  RG: TRadioGroup;
  Barra: TPanel;
  BtOk, BtCancela: TButton;
begin
  Result := -1;
  F := TForm.CreateNew(nil);
  try
    F.Caption := ATitulo;
    F.BorderStyle := bsDialog;
    F.Position := poScreenCenter;
    F.Width := 480;
    F.Height := 110 + 26 * AOpcoes.Count;

    Barra := TPanel.Create(F);
    Barra.Parent := F;
    Barra.Align := alBottom;
    Barra.Height := 46;
    Barra.BevelOuter := bvNone;

    BtOk := TButton.Create(F);
    BtOk.Parent := Barra;
    BtOk.Caption := 'Comparar';
    BtOk.ModalResult := mrOk;
    BtOk.Default := True;
    BtOk.SetBounds(F.Width - 210, 9, 95, 28);

    BtCancela := TButton.Create(F);
    BtCancela.Parent := Barra;
    BtCancela.Caption := 'Cancelar';
    BtCancela.ModalResult := mrCancel;
    BtCancela.Cancel := True;
    BtCancela.SetBounds(F.Width - 108, 9, 95, 28);

    RG := TRadioGroup.Create(F);
    RG.Parent := F;
    RG.Align := alClient;
    RG.BorderSpacing.Around := 8;
    RG.Caption := 'Comparar com';
    RG.Items.Assign(AOpcoes);
    RG.ItemIndex := 0;

    if F.ShowModal = mrOk then
      Result := RG.ItemIndex;
  finally
    F.Free;
  end;
end;

procedure Tfrmmquery2.btcompararClick(Sender: TObject);
var
  E, K, Escolha: Integer;
  Origem, Destino: TCmpLado;
  Opcoes: TStringList;
  MotorOpcao: array of Integer;
  TabA, TabB: TStringList;
  Banco, Esquema, Relatorio: string;
  ts: TTabSheet;
  item: TItem;
begin
  // Botao Comparar das abas MySQL e PostgreSQL (LFM) e das abas SQL Server/Oracle (Tag)
  if Sender = btcomparar then
    E := 0
  else if Sender = btcomparar1 then
    E := 1
  else
    E := DynEngineFromSender(Sender);
  if E < 0 then Exit;

  if (CmpConexao(E) = nil) or (not CmpConexao(E).Connected) then
  begin
    ShowMessage(CmpNomeMotor(E) + ' não conectado!');
    Exit;
  end;
  Origem := CmpLadoPadrao(E);

  // Opcoes: outras conexoes abertas + outro banco no mesmo servidor
  Opcoes := TStringList.Create;
  try
    SetLength(MotorOpcao, 0);
    for K := 0 to 4 do
      if (K <> E) and (CmpConexao(K) <> nil) and CmpConexao(K).Connected then
      begin
        Opcoes.Add('Conexão aberta: ' + CmpDescreve(CmpLadoPadrao(K)));
        SetLength(MotorOpcao, Length(MotorOpcao) + 1);
        MotorOpcao[High(MotorOpcao)] := K;
      end;
    case E of
      2: Opcoes.Add('Outro arquivo SQLite');
      4: Opcoes.Add('Outro schema neste servidor Oracle');
    else
      Opcoes.Add('Outro banco neste servidor ' + CmpNomeMotor(E));
    end;
    SetLength(MotorOpcao, Length(MotorOpcao) + 1);
    MotorOpcao[High(MotorOpcao)] := -1;

    Escolha := CmpEscolhe('Comparar estrutura - origem: ' + CmpDescreve(Origem), Opcoes);
  finally
    Opcoes.Free;
  end;
  if Escolha < 0 then Exit;

  if MotorOpcao[Escolha] >= 0 then
    Destino := CmpLadoPadrao(MotorOpcao[Escolha])
  else
  begin
    Destino := Origem;
    case E of
      0:
        begin
          // MySQL le o information_schema de outro banco pela mesma conexao
          Banco := Trim(InputBox('Comparar', 'Outro banco no mesmo servidor MySQL:', ''));
          if Banco = '' then Exit;
          Destino.Banco := Banco;
        end;
      1:
        begin
          Banco := Trim(InputBox('Comparar', 'Banco no mesmo servidor PostgreSQL:', Origem.Banco));
          if Banco = '' then Exit;
          Esquema := Trim(InputBox('Comparar', 'Schema:', Origem.Schema));
          if Esquema = '' then Esquema := 'public';
          Destino.Banco := Banco;
          Destino.Schema := Esquema;
          if not SameText(Banco, Origem.Banco) then
            Destino.Temp := True;
        end;
      2:
        begin
          OpenDialog1.Title := 'Arquivo SQLite para comparar';
          OpenDialog1.Filter := 'Bancos SQLite (*.db;*.sqlite;*.sqlite3;*.db3)|*.db;*.sqlite;*.sqlite3;*.db3|Todos os arquivos (*.*)|*.*';
          if not OpenDialog1.Execute then Exit;
          Destino.Banco := OpenDialog1.FileName;
          Destino.Temp := True;
        end;
      3:
        begin
          // SQL Server le outro banco pela mesma conexao (banco.INFORMATION_SCHEMA)
          Banco := Trim(InputBox('Comparar', 'Banco no mesmo servidor SQL Server:', Origem.Banco));
          if Banco = '' then Exit;
          Esquema := Trim(InputBox('Comparar', 'Schema:', Origem.Schema));
          if Esquema = '' then Esquema := 'dbo';
          Destino.Banco := Banco;
          Destino.Schema := Esquema;
        end;
      4:
        begin
          Esquema := UpperCase(Trim(InputBox('Comparar', 'Schema (dono) no mesmo servidor Oracle:', '')));
          if Esquema = '' then Exit;
          Destino.Schema := Esquema;
        end;
    end;
  end;

  TabA := CmpNovaListaTabelas;
  TabB := CmpNovaListaTabelas;
  Screen.Cursor := crHourGlass;
  try
    try
      if Destino.Temp then
        Destino.Conn := CmpConexaoTemporaria(Origem.Conn, Destino.Banco);
      CmpLerEstrutura(Origem, TabA);
      CmpLerEstrutura(Destino, TabB);
      Relatorio := CmpGeraRelatorio(Origem, Destino, TabA, TabB);
    except
      on Ex: Exception do
      begin
        Screen.Cursor := crDefault;
        ShowMessage('Falha ao comparar: ' + Ex.Message);
        Exit;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
    if Destino.Temp and (Destino.Conn <> nil) and (Destino.Conn <> Origem.Conn) then
      Destino.Conn.Free;
    TabB.Free;
    TabA.Free;
  end;

  ts := frmMNote.NovoItem();
  item := TItem(ts.Tag);
  item.syn.Text := Relatorio;
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
    (pgMain.ActivePage = tsSqlite) or
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
  ds : TDataSet;
  formato : Integer;
begin
  // btJSON1 = PostgreSQL (somente JSON), btJSON2 = SQLite, btJSON = MySQL
  ds := nil;
  if Sender = btJSON1 then
  begin
    if dbgridpost.DataSource <> nil then ds := dbgridpost.DataSource.DataSet;
    formato := 0;
  end
  else if Sender = btJSON2 then
  begin
    if dbgridmy1.DataSource <> nil then ds := dbgridmy1.DataSource.DataSet;
    formato := cbMake1.ItemIndex;
  end
  else
  begin
    if dbgridmy.DataSource <> nil then ds := dbgridmy.DataSource.DataSet;
    formato := cbMake.ItemIndex;
  end;

  if (ds = nil) or (not ds.Active) then
  begin
    ShowMessage('Nenhum resultado ativo. Use Open primeiro.');
    Exit;
  end;

  ts := frmMNote.NovoItem();
  item := TItem(ts.Tag);
  case formato of
    1: item.syn.Text := DatasetTocsvString(ds);
  else
    item.syn.Text := DatasetToJsonString(ds);
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

procedure Tfrmmquery2.ExecutaComandoMy(const ASQL: string);
begin
  if not zconmysql.Connected then
  begin
    ShowMessage('Mysql não conectado!');
    Exit;
  end;
  try
    ZQryTransf.Close;
    ZQryTransf.SQL.Text := ASQL;
    edLog.Append('SQL Execute:' + ASQL);
    ZQryTransf.ExecSQL;
    edLog.Append(Format('Comando executado. %d linhas afetadas.', [ZQryTransf.RowsAffected]));
  except
    on E: Exception do
    begin
      edLog.Append('Error:' + E.Message);
      edErro.Append(E.Message);
      ShowMessage('Error:' + E.Message);
    end;
  end;
end;

procedure Tfrmmquery2.ExecutaComandoPost(const ASQL: string);
begin
  if not zconpost.Connected then
  begin
    ShowMessage('Postgres não conectado!');
    Exit;
  end;
  try
    Zqrypost.Close;
    Zqrypost.SQL.Text := ASQL;
    edLogPost.Append('SQL Execute:' + ASQL);
    Zqrypost.ExecSQL;
    edLogPost.Append(Format('Comando executado. %d linhas afetadas.', [Zqrypost.RowsAffected]));
  except
    on E: Exception do
    begin
      edLogPost.Append('Error:' + E.Message);
      edErro1.Append(E.Message);
      ShowMessage('Error:' + E.Message);
    end;
  end;
end;

procedure Tfrmmquery2.btExecuteClick(Sender: TObject);
begin
  // btExecute fica na aba MySQL; btExecute1 na aba PostgreSQL
  if Sender = btExecute then
    ExecutaComandoMy(edSQL.Lines.Text)
  else
    ExecutaComandoPost(edSQLPost.Lines.Text);
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
    edLogPost.Append('SQL OPEN:' + edSQLPost.Lines.Text);
    dbnavpost.DataSource := dspos;
    dbgridpost.DataSource := dspos;
    dbgridpost.ReadOnly := False;

    zpostqry1.Prepare;
    zpostqry1.Open;
    pcPostgree.ActivePage := tsGridPostgres;
  except
    on E: Exception do
    begin
      edLogPost.Append('Error:' + e.message);
      edErro1.Append(e.message);
      ShowMessage('Error:' + e.message);
    end;
  end;
end;

procedure Tfrmmquery2.OpenSelectMy();
begin
  try
    zmyqry2.Close;
    zmyqry2.SQL.Text := edSQL.Lines.Text;

    dsmy.DataSet := zmyqry2;
    edlog.Append('SQL OPEN:' + edSQL.Lines.Text);
    dbnavmy.DataSource := dsmy;
    dbgridmy.DataSource := dsmy;
    dbgridmy.ReadOnly := False;

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

    dslite.DataSet := zliteqry2;
    edLog1.Append('SQL OPEN(SQLite):' + edSQL1.Lines.Text);
    dbnavmy1.DataSource := dslite;
    dbgridmy1.DataSource := dslite;
    dbgridmy1.ReadOnly := False;

    zliteqry2.Open;

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
  if key <> #13 then Exit;
  // edPesqsqlite (aba SQLite) tambem esta ligado a este evento
  if Sender = edPesqsqlite then
    ProcuraTVSQLite(edPesqsqlite.Text)
  else
    ProcuraTVMysql(edPesqMy.Text);
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
  // Atualiza Linha/Coluna do editor clicado (antes gravava X/Y em pixels no MySQL)
  edSQLStatusChange(Sender, []);
end;

procedure Tfrmmquery2.edSQLKeyPress(Sender: TObject; var Key: char); begin end;
procedure Tfrmmquery2.edSQLKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); begin end;
procedure Tfrmmquery2.edSQLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); begin end;
procedure Tfrmmquery2.edSQLPaint(Sender: TObject; ACanvas: TCanvas); begin end;
procedure Tfrmmquery2.edSQLPlaceBookmark(Sender: TObject; var Mark: TSynEditMark); begin end;
procedure Tfrmmquery2.edSQLStatusChange(Sender: TObject; Changes: TSynStatusChanges);
var
  ed: TSynEdit;
begin
  if not (Sender is TSynEdit) then Exit;
  ed := TSynEdit(Sender);
  if ed = edSQLPost then
  begin
    lblinha1.Caption := IntToStr(ed.CaretY);
    lbCol1.Caption := IntToStr(ed.CaretX);
  end
  else if ed = edSQL1 then
  begin
    lblinha2.Caption := IntToStr(ed.CaretY);
    lbCol2.Caption := IntToStr(ed.CaretX);
  end
  else if ed = edSQL then
  begin
    lblinha.Caption := IntToStr(ed.CaretY);
    lbCol.Caption := IntToStr(ed.CaretX);
  end;
end;
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
  TabelaNome, BancoFiltro : string;
  a, QtdTabelas : integer;
begin
  zmyqry.Close;
  pnlProgresso.Visible := true;
  QtdTabelas := 0;
  BancoFiltro := Trim(edBanco.Text);
  try
    zmyqry.SQL.Text :=
      'SELECT table_name, table_schema '+
      'FROM information_schema.tables '+
      'WHERE (LOWER(table_schema) = LOWER(:banco) OR :banco = '''') '+
      '  AND table_type IN (''BASE TABLE'', ''SYSTEM VERSIONED'') '+
      'ORDER BY table_name';
    zmyqry.ParamByName('banco').AsString := BancoFiltro;
    try
      zmyqry.Open;
      if zmyqry.IsEmpty and (BancoFiltro <> '') then
      begin
        zmyqry.Close;
        zmyqry.SQL.Text := 'SHOW FULL TABLES WHERE Table_type = ''BASE TABLE''';
        zmyqry.Open;
      end;
    except
      zmyqry.Close;
      zmyqry.SQL.Text := 'SHOW FULL TABLES WHERE Table_type = ''BASE TABLE''';
      zmyqry.Open;
    end;

    pgbar.Max := zmyqry.RecordCount;
    pgbar.Position := 0;

    posicaofieldsmy.DeleteChildren;

    while not zmyqry.EOF do
    begin
      TabelaNome := zmyqry.Fields[0].AsString;
      if (zmyqry.FindField('table_name') <> nil) then
        TabelaNome := zmyqry.FieldByName('table_name').AsString
      else if (zmyqry.FindField('TABLE_NAME') <> nil) then
        TabelaNome := zmyqry.FieldByName('TABLE_NAME').AsString;

      TabelaNome := Trim(TabelaNome);
      if TabelaNome <> '' then
      begin
        Inc(QtdTabelas);
        SynCompletion1.ItemList.Append(TabelaNome);

        tvitem := tvMysql.Items.AddChildObject(posicaofieldsmy, TabelaNome, Pointer(nil));
        tvitem.ImageIndex := 14;

        try
          Tabela := TTabela.Create(zmyqry1, TabelaNome, DBMysql);
          tvitem.Data := TObject(Tabela);

          tvcolunas := tvMysql.Items.AddChildObject(tvitem, 'fields', TObject(ETDBCampos));
          tvcolunas.ImageIndex := 16;
          for a := 0 to tabela.Count - 1 do
          begin
            tvTemp := tvMysql.Items.AddChildObject(tvcolunas, tabela.fieldname[a], Pointer(a));
            tvtemp.ImageIndex := 16;
          end;

          tvindice := tvMysql.Items.AddChildObject(tvitem, 'Primary Key', Pointer(ETDBPK));
          tvindice.ImageIndex := 17;
          for a := 0 to tabela.chaves.primarykeys.Count - 1 do
          begin
            tvTemp := tvMysql.Items.AddChildObject(tvindice, tabela.chaves.primarykeys[a], Pointer(a));
            tvTemp.ImageIndex := 18;
          end;

          tvFK := tvMysql.Items.AddChildObject(tvitem, 'Chave Extrangeira', TObject(ETDBFK));
          for a := 0 to tabela.chaves.coinstraintname.Count - 1 do
            tvMysql.Items.AddChildObject(tvFK, tabela.chaves.coinstraintname[a], Pointer(a));

          if (tabela.triggers.Triggername.Count > 0) then
          begin
            tvTrigger := tvMysql.Items.AddChildObject(tvitem, 'Triggers', Pointer(ETDTriggers));
            for a := 0 to tabela.triggers.Triggername.Count - 1 do
              tvMysql.Items.AddChildObject(tvTrigger, tabela.triggers.Triggername[a], Pointer(a));
          end;
        except
          on E: Exception do
            RegistraEventosLog('ListarTabelasMy: falha ao montar a árvore da tabela: ' + E.Message);
        end;
      end;

      zmyqry.Next;
      pgbar.Position := pgbar.Position + 1;
      Application.ProcessMessages;
    end;
  finally
    pnlProgresso.Visible := false;
    posicaofieldsmy.Expanded := True;
    if posicaofieldsmy.Parent <> nil then
      posicaofieldsmy.Parent.Expanded := True;
    tvMysql.FullExpand;
    AtualizarAutocomplete(0);
    edlog.Append(Format('MySQL: %d tabelas carregadas.', [QtdTabelas]));
  end;
end;

procedure Tfrmmquery2.ListarTabelasSQLite();
var
  tvItem, tvCols, tvTemp, tvPK, tvFK: TTreeNode;
  tbl, colLine, fkLine: string;
  lastFkId, curFkId, parentTable: string;
  childCols, parentCols: TStringList;
  QtdTabelas: Integer;
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

  QtdTabelas := 0;
  childCols := TStringList.Create;
  parentCols := TStringList.Create;
  try
    while not zliteqry.EOF do
    begin
      tbl := Trim(zliteqry.FieldByName('name').AsString);
      if tbl <> '' then
      begin
        Inc(QtdTabelas);
        tvItem := tvsqlite.Items.AddChildObject(posicaofieldslite, tbl, Pointer(nil));
        tvItem.ImageIndex := 14;

        try
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
              tvTemp := tvsqlite.Items.AddChildObject(tvPK, zliteqry1.FieldByName('name').AsString, Pointer(0));
              tvTemp.ImageIndex := 18;
            end;

            zliteqry1.Next;
          end;
        except
          on E: Exception do
            RegistraEventosLog('ListarTabelasSQLite: falha ao ler colunas: ' + E.Message);
        end;

        try
          zliteqry1.Close;
          zliteqry1.SQL.Text := 'PRAGMA foreign_key_list(' + QuotedStr(tbl) + ')';
          zliteqry1.Open;

          if not zliteqry1.EOF then
          begin
            tvFK := tvsqlite.Items.AddChildObject(tvItem, 'Chave Estrangeira', Pointer(ETDBFK));
            lastFkId := '';
            parentTable := '';
            childCols.Clear;
            parentCols.Clear;

            while not zliteqry1.EOF do
            begin
              curFkId := zliteqry1.FieldByName('id').AsString;
              if (lastFkId <> '') and (curFkId <> lastFkId) then
              begin
                fkLine := 'FK_' + tbl + '_' + lastFkId + ' (' + childCols.CommaText + ') -> ' +
                          parentTable + ' (' + parentCols.CommaText + ')';
                tvTemp := tvsqlite.Items.AddChildObject(tvFK, fkLine, Pointer(0));
                childCols.Clear;
                parentCols.Clear;
              end;

              lastFkId := curFkId;
              parentTable := zliteqry1.FieldByName('table').AsString;
              childCols.Add(zliteqry1.FieldByName('from').AsString);
              parentCols.Add(zliteqry1.FieldByName('to').AsString);

              zliteqry1.Next;
            end;

            if lastFkId <> '' then
            begin
              fkLine := 'FK_' + tbl + '_' + lastFkId + ' (' + childCols.CommaText + ') -> ' +
                        parentTable + ' (' + parentCols.CommaText + ')';
              tvsqlite.Items.AddChildObject(tvFK, fkLine, Pointer(0));
            end;
          end;
        except
          on E: Exception do
            RegistraEventosLog('ListarTabelasSQLite: falha ao ler chaves estrangeiras: ' + E.Message);
        end;
      end;

      zliteqry.Next;
    end;
  finally
    childCols.Free;
    parentCols.Free;
    posicaofieldslite.Expanded := True;
    if posicaofieldslite.Parent <> nil then
      posicaofieldslite.Parent.Expanded := True;
    tvsqlite.FullExpand;
    AtualizarAutocomplete(2);
    edLog1.Append(Format('SQLite: %d tabelas carregadas.', [QtdTabelas]));
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
  QtdTabelas: Integer;

  procedure OpenListaTabelas;
  begin
    zpostqry.Close;
    zpostqry.SQL.Text :=
      'SELECT schemaname, tablename '+
      'FROM pg_catalog.pg_tables '+
      'WHERE (LOWER(schemaname) = LOWER(:schema) OR :schema = '''') '+
      'ORDER BY tablename';
    zpostqry.ParamByName('schema').AsString := SchemaNome;
    try
      zpostqry.Open;
      if zpostqry.IsEmpty and (SchemaNome <> '') then
      begin
        zpostqry.Close;
        zpostqry.SQL.Text :=
          'SELECT schemaname, tablename '+
          'FROM pg_catalog.pg_tables '+
          'WHERE schemaname NOT IN (''pg_catalog'', ''information_schema'') '+
          'ORDER BY tablename';
        zpostqry.Open;
      end;
    except
      zpostqry.Close;
      zpostqry.SQL.Text :=
        'SELECT n.nspname AS schemaname, c.relname AS tablename '+
        'FROM pg_catalog.pg_class c '+
        'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '+
        'WHERE (LOWER(n.nspname) = LOWER(:schema) OR :schema = '''') '+
        '  AND c.relkind IN (''r'', ''p'') '+
        'ORDER BY c.relname';
      zpostqry.ParamByName('schema').AsString := SchemaNome;
      try
        zpostqry.Open;
      except
        zpostqry.Close;
        zpostqry.SQL.Text :=
          'SELECT n.nspname AS schemaname, c.relname AS tablename '+
          'FROM pg_catalog.pg_class c '+
          'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '+
          'WHERE n.nspname NOT IN (''pg_catalog'', ''information_schema'') '+
          '  AND c.relkind IN (''r'', ''p'') '+
          'ORDER BY c.relname';
        zpostqry.Open;
      end;
    end;
  end;

  procedure AddColunas(const ASchema, ATable: string; AParent: TTreeNode);
  begin
    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT a.attnum, a.attname AS column_name, '+
      '       pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type, '+
      '       NOT a.attnotnull AS is_nullable, '+
      '       pg_get_expr(ad.adbin, ad.adrelid) AS column_default '+
      'FROM pg_catalog.pg_attribute a '+
      'LEFT JOIN pg_catalog.pg_attrdef ad '+
      '  ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum '+
      'JOIN pg_catalog.pg_class c ON c.oid = a.attrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '+
      'WHERE (LOWER(n.nspname) = LOWER(:schema) OR :schema = '''') '+
      '  AND c.relname = :table '+
      '  AND a.attnum > 0 AND NOT a.attisdropped '+
      'ORDER BY a.attnum';
    zpostqry2.ParamByName('schema').AsString := ASchema;
    zpostqry2.ParamByName('table').AsString  := ATable;
    zpostqry2.Open;

    tvColunas := tvPost.Items.AddChildObject(AParent, 'fields', Pointer(ETDBCampos));
    tvColunas.ImageIndex := 16;

    while not zpostqry2.EOF do
    begin
      ColLine := zpostqry2.FieldByName('column_name').AsString + ' : ' +
                 zpostqry2.FieldByName('data_type').AsString;

      if not zpostqry2.FieldByName('is_nullable').AsBoolean then
        ColLine := ColLine + ' NOT NULL';

      if not zpostqry2.FieldByName('column_default').IsNull then
        ColLine := ColLine + ' DEFAULT ' + zpostqry2.FieldByName('column_default').AsString;

      tvTemp := tvPost.Items.AddChildObject(tvColunas, ColLine, Pointer(0));
      tvTemp.ImageIndex := 19;

      zpostqry2.Next;
    end;
    zpostqry2.Close;
  end;

  procedure AddPK(const ASchema, ATable: string; AParent: TTreeNode);
  begin
    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT c.conname, '+
      '       array_agg(a.attname ORDER BY u.ord) AS cols '+
      'FROM pg_catalog.pg_constraint c '+
      'JOIN pg_catalog.pg_class t ON t.oid = c.conrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'JOIN LATERAL unnest(c.conkey) WITH ORDINALITY AS u(attnum, ord) ON TRUE '+
      'JOIN pg_catalog.pg_attribute a ON a.attrelid = t.oid AND a.attnum = u.attnum '+
      'WHERE c.contype = ''p'' '+
      '  AND (LOWER(n.nspname) = LOWER(:schema) OR :schema = '''') '+
      '  AND t.relname = :table '+
      'GROUP BY c.conname '+
      'ORDER BY c.conname';
    zpostqry2.ParamByName('schema').AsString := ASchema;
    zpostqry2.ParamByName('table').AsString  := ATable;
    zpostqry2.Open;

    tvIndice := tvPost.Items.AddChildObject(AParent, 'Primary Key', Pointer(ETDBPK));
    tvIndice.ImageIndex := 17;

    while not zpostqry2.EOF do
    begin
      tvTemp := tvPost.Items.AddChildObject(
                  tvIndice,
                  zpostqry2.FieldByName('conname').AsString + ' ('+
                  zpostqry2.FieldByName('cols').AsString + ')',
                  Pointer(0)
                );
      tvTemp.ImageIndex := 18;
      zpostqry2.Next;
    end;
    zpostqry2.Close;
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
      '  AND (LOWER(n1.nspname) = LOWER(:schema) OR :schema = '''') '+
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
    zpostqry2.Close;
  end;

  procedure AddTriggers(const ASchema, ATable: string; AParent: TTreeNode);
  begin
    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT tg.tgname, pg_get_triggerdef(tg.oid, TRUE) AS def '+
      'FROM pg_catalog.pg_trigger tg '+
      'JOIN pg_catalog.pg_class t ON t.oid = tg.tgrelid '+
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace '+
      'WHERE (LOWER(n.nspname) = LOWER(:schema) OR :schema = '''') '+
      '  AND t.relname = :table '+
      '  AND NOT tg.tgisinternal '+
      'ORDER BY tg.tgname';
    zpostqry2.ParamByName('schema').AsString := ASchema;
    zpostqry2.ParamByName('table').AsString  := ATable;
    zpostqry2.Open;

    if not zpostqry2.EOF then
    begin
      tvTrigger := tvPost.Items.AddChildObject(AParent, 'Triggers', Pointer(ETDTriggers));
      while not zpostqry2.EOF do
      begin
        tvTemp := tvPost.Items.AddChildObject(tvTrigger,
                   zpostqry2.FieldByName('tgname').AsString, Pointer(0));
        tvPost.Items.AddChildObject(tvTemp,
                   zpostqry2.FieldByName('def').AsString, Pointer(0));
        zpostqry2.Next;
      end;
    end;
    zpostqry2.Close;
  end;

begin
  SchemaNome := Trim(edSchemaPost.Text);
  if SchemaNome = '' then SchemaNome := 'public';

  QtdTabelas := 0;
  try
    posicaofieldspost.DeleteChildren;

    OpenListaTabelas;
    zpostqry.First;

    while not zpostqry.EOF do
    begin
      TabelaNome := zpostqry.FieldByName('tablename').AsString;
      if Trim(TabelaNome) <> '' then
      begin
        Inc(QtdTabelas);
        SynSQLSyn2.TableNames.Append(TabelaNome);

        tvItem := tvPost.Items.AddChildObject(posicaofieldspost, TabelaNome, Pointer(nil));
        tvItem.ImageIndex := 14;

        try AddColunas(SchemaNome, TabelaNome, tvItem); except end;
        try AddPK(SchemaNome, TabelaNome, tvItem); except end;
        try AddFK(SchemaNome, TabelaNome, tvItem); except end;
        try AddTriggers(SchemaNome, TabelaNome, tvItem); except end;
      end;

      zpostqry.Next;
      Application.ProcessMessages;
    end;
  finally
    posicaofieldspost.Expanded := True;
    if posicaofieldspost.Parent <> nil then
      posicaofieldspost.Parent.Expanded := True;
    tvPost.FullExpand;
    AtualizarAutocomplete(1);
    edlog.Append(Format('PostgreSQL: %d tabelas carregadas.', [QtdTabelas]));
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
      edLogPost.Append('Dicionário gerado em: ' + targetAbsPath);
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
      edLogPost.Append('Dependências (FK) salvas em: ' + outFile);
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
  ctxDeps, ctxDDL, ask, outSQL, DevMsg: string;
  outAnsi: AnsiString;
  baseSchema: string;
begin
  Result := '';

  if not zconpost.Connected then
  begin
    ShowMessage('PostgreSQL não conectado!');
    Exit;
  end;

  if (FSetMain.Provider <> 3) and (Trim(FSetMain.CHATGPT) = '') then
  begin
    if FSetMain.Provider = 4 then
      ShowMessage('Configure a chave de API/Token em SetMain.CHATGPT.')
    else
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

  ask :=
    'Pergunta do usuário:' + LineEnding +
    pergunta + LineEnding + LineEnding +
    '--- CONTEXTO: DEPENDÊNCIAS (FK) ---' + LineEnding +
    ctxDeps + LineEnding + LineEnding +
    '--- CONTEXTO: DDL COMPLETO DAS TABELAS ---' + LineEnding +
    ctxDDL + LineEnding + LineEnding +
    'Gere APENAS o SQL final (um único bloco).';

  DevMsg :=
    'Você é um assistente SQL para PostgreSQL.' + LineEnding +
    'REGRAS:' + LineEnding +
    '1) Responda SOMENTE com SQL válido, sem explicações ou comentários.' + LineEnding +
    '2) Use exatamente os nomes de schema/tabela/coluna informados.' + LineEnding +
    '3) Considere as dependências (FKs) e os DDLs fornecidos.' + LineEnding +
    '4) Se algo não for possível por falta de dados, use comentários SQL iniciando com -- TODO.' + LineEnding +
    '5) Não gerar dados fictícios; somente DDL/DML/queries necessárias.';

  if not MNoteAI.SendQuestion(ask, DevMsg, outSQL) then
  begin
    ShowMessage('Erro ao consultar IA: ' + MNoteAI.LastError);
    Exit;
  end;
  outSQL := StripCodeFences(outSQL);

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
  ctxDeps, ctxDDL, ask, outSQL, DevMsg: string;
  outAnsi: AnsiString;
begin
  Result := '';

  if not zconsqlite.Connected then
  begin
    ShowMessage('SQLite não conectado!');
    Exit;
  end;

  if (FSetMain.Provider <> 3) and (Trim(FSetMain.CHATGPT) = '') then
  begin
    if FSetMain.Provider = 4 then
      ShowMessage('Configure a chave de API/Token em SetMain.CHATGPT.')
    else
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

  ask :=
    'Pergunta do usuário:' + LineEnding +
    pergunta + LineEnding + LineEnding +
    '--- CONTEXTO: DEPENDÊNCIAS (FK) ---' + LineEnding +
    ctxDeps + LineEnding + LineEnding +
    '--- CONTEXTO: DDL COMPLETO DAS TABELAS ---' + LineEnding +
    ctxDDL + LineEnding + LineEnding +
    'Gere APENAS o SQL final (um único bloco).';

  DevMsg :=
    'Você é um assistente SQL para SQLite.' + LineEnding +
    'REGRAS:' + LineEnding +
    '1) Responda SOMENTE com SQL válido para SQLite, sem explicações ou comentários.' + LineEnding +
    '2) Use exatamente os nomes de tabela/coluna informados.' + LineEnding +
    '3) Considere as dependências (FKs) e os DDLs fornecidos.' + LineEnding +
    '4) Se algo não for possível por falta de dados, use comentários SQL iniciando com -- TODO.' + LineEnding +
    '5) Não gerar dados fictícios; somente DDL/DML/queries necessárias.';

  if not MNoteAI.SendQuestion(ask, DevMsg, outSQL) then
  begin
    ShowMessage('Erro ao consultar IA: ' + MNoteAI.LastError);
    Exit;
  end;
  outSQL := StripCodeFences(outSQL);

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

      3:
      begin
        frmmquery2.edHostMSSQL.Text := FSetMain.HostnameMSSQL;
        frmmquery2.edBancoMSSQL.Text := FSetMain.BancoMSSQL;
        frmmquery2.edUserMSSQL.Text := FSetMain.UsernameMSSQL;
        frmmquery2.edPassMSSQL.Text := FSetMain.PasswordMSSQL;
        frmmquery2.edSchemaMSSQL.Text := FSetMain.SchemaMSSQL;

        conexao := frmmquery2.ConectMSSQL;
      end;

      4:
      begin
        frmmquery2.edHostOracle.Text := FSetMain.HostnameOracle;
        frmmquery2.edBancoOracle.Text := FSetMain.BancoOracle;
        frmmquery2.edUserOracle.Text := FSetMain.UsernameOracle;
        frmmquery2.edPassOracle.Text := FSetMain.PasswordOracle;
        frmmquery2.edSchemaOracle.Text := FSetMain.SchemaOracle;

        conexao := frmmquery2.ConectOracle;
      end;

    else
      raise Exception.Create('TipoBanco inválido. Use 0=MySQL, 1=Postgres, 2=SQLite, 3=MSSQL, 4=Oracle.');
    end;

    Result := conexao;

  except
    on E: Exception do
      Result := False;
  end;
end;

function Tfrmmquery2.DescreveTabelaIAPost(tabela: string): string;
var
  schema, line, indexName: string;
  definitions, suffixes, constraintNames: TStringList;
  cont: Integer;

  function QIdent(const value: string): string;
  begin
    Result := '"' + StringReplace(value, '"', '""', [rfReplaceAll]) + '"';
  end;
begin
  Result := '';
  if not zconpost.Connected then
  begin
    ShowMessage('PostgreSQL não conectado!');
    Exit;
  end;
  tabela := Trim(tabela);
  if tabela = '' then
  begin
    ShowMessage('Selecione uma tabela PostgreSQL.');
    Exit;
  end;
  schema := Trim(edSchemaPost.Text);
  if schema = '' then schema := 'public';

  definitions := TStringList.Create;
  suffixes := TStringList.Create;
  constraintNames := TStringList.Create;
  try
    constraintNames.CaseSensitive := False;
    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT a.attname AS column_name, ' +
      '       pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type, ' +
      '       a.attnotnull AS not_null, ' +
      '       pg_get_expr(ad.adbin, ad.adrelid) AS column_default ' +
      'FROM pg_catalog.pg_attribute a ' +
      'LEFT JOIN pg_catalog.pg_attrdef ad ' +
      '  ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum ' +
      'JOIN pg_catalog.pg_class c ON c.oid = a.attrelid ' +
      'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' +
      'WHERE n.nspname = :schema AND c.relname = :table ' +
      '  AND a.attnum > 0 AND NOT a.attisdropped ' +
      'ORDER BY a.attnum';
    zpostqry1.ParamByName('schema').AsString := schema;
    zpostqry1.ParamByName('table').AsString := tabela;
    zpostqry1.Open;
    while not zpostqry1.EOF do
    begin
      line := '  ' + QIdent(zpostqry1.FieldByName('column_name').AsString) +
        ' ' + zpostqry1.FieldByName('data_type').AsString;
      if zpostqry1.FieldByName('not_null').AsBoolean then
        line := line + ' NOT NULL';
      if not zpostqry1.FieldByName('column_default').IsNull then
        line := line + ' DEFAULT ' +
          zpostqry1.FieldByName('column_default').AsString;
      definitions.Add(line);
      zpostqry1.Next;
    end;
    if definitions.Count = 0 then
    begin
      ShowMessage('Tabela "' + tabela + '" não encontrada no schema ' +
        schema + '.');
      Exit;
    end;

    zpostqry2.Close;
    zpostqry2.SQL.Text :=
      'SELECT c.conname, pg_get_constraintdef(c.oid, TRUE) AS def ' +
      'FROM pg_catalog.pg_constraint c ' +
      'JOIN pg_catalog.pg_class t ON t.oid = c.conrelid ' +
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace ' +
      'WHERE c.contype IN (''p'',''u'',''f'',''c'') ' +
      '  AND n.nspname = :schema AND t.relname = :table ' +
      'ORDER BY c.conname';
    zpostqry2.ParamByName('schema').AsString := schema;
    zpostqry2.ParamByName('table').AsString := tabela;
    zpostqry2.Open;
    while not zpostqry2.EOF do
    begin
      constraintNames.Add(zpostqry2.FieldByName('conname').AsString);
      definitions.Add('  CONSTRAINT ' +
        QIdent(zpostqry2.FieldByName('conname').AsString) + ' ' +
        zpostqry2.FieldByName('def').AsString);
      zpostqry2.Next;
    end;

    zpostqry3.Close;
    zpostqry3.SQL.Text :=
      'SELECT indexname, indexdef FROM pg_catalog.pg_indexes ' +
      'WHERE schemaname = :schema AND tablename = :table ' +
      'ORDER BY indexname';
    zpostqry3.ParamByName('schema').AsString := schema;
    zpostqry3.ParamByName('table').AsString := tabela;
    zpostqry3.Open;
    while not zpostqry3.EOF do
    begin
      indexName := zpostqry3.FieldByName('indexname').AsString;
      if constraintNames.IndexOf(indexName) < 0 then
        suffixes.Add(zpostqry3.FieldByName('indexdef').AsString + ';');
      zpostqry3.Next;
    end;

    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT pg_get_triggerdef(tg.oid, TRUE) AS def ' +
      'FROM pg_catalog.pg_trigger tg ' +
      'JOIN pg_catalog.pg_class t ON t.oid = tg.tgrelid ' +
      'JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace ' +
      'WHERE n.nspname = :schema AND t.relname = :table ' +
      '  AND NOT tg.tgisinternal ORDER BY tg.tgname';
    zpostqry1.ParamByName('schema').AsString := schema;
    zpostqry1.ParamByName('table').AsString := tabela;
    zpostqry1.Open;
    while not zpostqry1.EOF do
    begin
      suffixes.Add(zpostqry1.FieldByName('def').AsString + ';');
      zpostqry1.Next;
    end;

    Result := 'CREATE TABLE ' + QIdent(schema) + '.' + QIdent(tabela) +
      ' (' + LineEnding;
    for cont := 0 to definitions.Count - 1 do
    begin
      Result := Result + definitions[cont];
      if cont < definitions.Count - 1 then Result := Result + ',';
      Result := Result + LineEnding;
    end;
    Result := Result + ');' + LineEnding;
    for cont := 0 to suffixes.Count - 1 do
      Result := Result + suffixes[cont] + LineEnding;
  finally
    constraintNames.Free;
    suffixes.Free;
    definitions.Free;
  end;
end;

procedure Tfrmmquery2.InstallDiagramMenus;
  procedure Add(Menu: TPopupMenu; Index: Integer);
  var Item: TMenuItem;
  begin
    if Menu = nil then Exit;
    Item := TMenuItem.Create(Self); Item.Caption := 'Abrir diagrama do banco';
    Item.Tag := Index; Item.OnClick := @DiagramMenuClick; Menu.Items.Add(Item);
  end;
begin
  Add(pmDatabaseMy, 0); Add(pmTabelasMy, 0); Add(pmTabelaMy, 0);
  Add(pmDatabasePost, 1); Add(pmTabelasPost, 1); Add(pmTabelaPost, 1);
  Add(pmDatabaseLite, 2); Add(pmTabelasLite, 2); Add(pmTabelaLite, 2);
  Add(pmDatabaseMSSQL, 3); Add(pmTabelaMSSQL, 3);
  Add(pmDatabaseOracle, 4); Add(pmTabelaOracle, 4);
  tvMysql.RightClickSelect := True; tvPost.RightClickSelect := True;
  tvsqlite.RightClickSelect := True; tvMSSQL.RightClickSelect := True;
  tvOracle.RightClickSelect := True;
end;

function Tfrmmquery2.DiagramConnection(AIndex: Integer; out ASchema: string): TZConnection;
begin
  Result := nil; ASchema := '';
  case AIndex of
    0: Result := zconmysql;
    1: begin Result := zconpost; ASchema := Trim(edSchemaPost.Text); if ASchema = '' then ASchema := 'public'; end;
    2: Result := zconsqlite;
    3: begin Result := zconMSSQL; ASchema := Trim(edSchemaMSSQL.Text);
         if ASchema = '' then ASchema := 'dbo'; end;
    4: begin Result := zconOracle; ASchema := OracleOwner;
         if ASchema = '' then ASchema := UpperCase(zconOracle.User); end;
  end;
end;

procedure Tfrmmquery2.DiagramMenuClick(Sender: TObject);
var C: TZConnection; Schema, TableName: string; Tree: TTreeView; ParentNode: TTreeNode;
begin
  C := DiagramConnection(TMenuItem(Sender).Tag, Schema); Tree := nil; ParentNode := nil;
  case TMenuItem(Sender).Tag of
    0: begin Tree := tvMysql; ParentNode := posicaofieldsmy; end;
    1: begin Tree := tvPost; ParentNode := posicaofieldspost; end;
    2: begin Tree := tvsqlite; ParentNode := posicaofieldslite; end;
    3: begin Tree := tvMSSQL; ParentNode := posicaofieldsMSSQL; end;
    4: begin Tree := tvOracle; ParentNode := posicaofieldsOracle; end;
  end;
  TableName := '';
  if (Tree <> nil) and (Tree.Selected <> nil) and (ParentNode <> nil) and
    (Tree.Selected.Parent = ParentNode) then TableName := Tree.Selected.Text;
  OpenDatabaseDiagram(Self, C, Schema, TableName);
end;

function Tfrmmquery2.GetDatabaseTree(AIndex: Integer; out AName, AContextId: string; ATables: TStrings): Boolean;
var C: TZConnection; Schema: string; ParentNode, Node: TTreeNode;
begin
  Result := False; AName := ''; AContextId := ''; ATables.Clear;
  C := DiagramConnection(AIndex, Schema);
  if (C = nil) or not C.Connected then Exit;
  AName := C.Protocol + ' / ' + C.HostName + ' / ' + C.Database;
  if Schema <> '' then AName := AName + ' / ' + Schema;
  AContextId := DiagramContextKey(DiagramConnectionContext(C, Schema));
  ParentNode := nil;
  case AIndex of
    0: ParentNode := posicaofieldsmy;
    1: ParentNode := posicaofieldspost;
    2: ParentNode := posicaofieldslite;
    3: ParentNode := posicaofieldsMSSQL;
    4: ParentNode := posicaofieldsOracle;
  end;
  if ParentNode <> nil then begin
    Node := ParentNode.GetFirstChild;
    while Node <> nil do begin ATables.Add(Node.Text); Node := Node.GetNextSibling; end;
  end;
  Result := True;
end;

procedure Tfrmmquery2.OpenDiagramContext(const AContextId, ATable: string);
var I: Integer; C: TZConnection; Schema: string;
begin
  for I := 0 to 4 do begin
    C := DiagramConnection(I, Schema);
    if (C <> nil) and C.Connected and
      (DiagramContextKey(DiagramConnectionContext(C, Schema)) = AContextId) then begin
      OpenDatabaseDiagram(Self, C, Schema, ATable); Exit;
    end;
  end;
  MessageDlg('Diagrama', 'A conexão desta pasta mudou ou foi desconectada. Atualize a árvore após reconectar.', mtInformation, [mbOK], 0);
end;

function Tfrmmquery2.GetActiveDatabaseTree(out ADatabaseName: string;
  ATables: TStrings): Boolean;
var
  ParentNode, Node: TTreeNode;
begin
  Result := False;
  ADatabaseName := '';
  if ATables = nil then Exit;
  ATables.Clear;
  ParentNode := nil;
  if (pgMain.ActivePage = tsSqlite) and zconsqlite.Connected then
  begin
    ADatabaseName := ExtractFileName(Trim(edDatabase.Text));
    ParentNode := posicaofieldslite;
  end
  else if (pgMain.ActivePage = tsPostgree) and zconpost.Connected then
  begin
    ADatabaseName := Trim(edBancoPost.Text);
    ParentNode := posicaofieldspost;
  end
  else if (pgMain.ActivePage = tsMysql) and zconmysql.Connected then
  begin
    ADatabaseName := Trim(edBanco.Text);
    ParentNode := posicaofieldsmy;
  end
  else if zconpost.Connected then
  begin
    ADatabaseName := Trim(edBancoPost.Text);
    ParentNode := posicaofieldspost;
  end
  else if zconsqlite.Connected then
  begin
    ADatabaseName := ExtractFileName(Trim(edDatabase.Text));
    ParentNode := posicaofieldslite;
  end
  else if zconmysql.Connected then
  begin
    ADatabaseName := Trim(edBanco.Text);
    ParentNode := posicaofieldsmy;
  end;
  if ParentNode = nil then Exit;
  Node := ParentNode.GetFirstChild;
  while Node <> nil do
  begin
    ATables.Add(Node.Text);
    Node := Node.GetNextSibling;
  end;
  if ADatabaseName = '' then ADatabaseName := 'conexão ativa';
  Result := True;
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


var
  E: Integer;

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
  for E := Low(FDyn) to High(FDyn) do
    if FDyn[E].FindList <> nil then
    begin
      FDyn[E].FindList.Clear;
      ScanSyn(FDyn[E].SynEdit, FDyn[E].FindList);
    end;
end;

procedure Tfrmmquery2.ProcessaErro(message: string);
begin
  if Assigned(edErro) then edErro.Append(message);
  if Assigned(edErro1) then edErro1.Append(message);
  if Assigned(edErro2) then edErro2.Append(message);
  if Assigned(edErroMSSQL) then edErroMSSQL.Append(message);
  if Assigned(edErroOracle) then edErroOracle.Append(message);

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

{ ============================================================================
  Abas dinamicas de SQL Server (3) e Oracle (4)
  Mesmo padrao e funcionalidades da aba PostgreSQL:
    Connection | SQL (editor, IA, erros, pesquisa, Linha/Coluna,
    Analysis/Open/Execute) | Grid (navegador, Salvar, Chart, Make) | Log | Tools
  ============================================================================ }

procedure Tfrmmquery2.CreateDynamicDBTab(AEngine: Integer; const ATitle: string);
var
  U: TMQueryDynUI;
  leftPanel, searchPanel, rightPanel, sqlBarPanel, sqlBtnPanel, findPanel,
  erroPanel, iaBarPanel, iaBtnPanel, sqlPanel, gridBarPanel: TPanel;
  splitter, sqlSplitter: TSplitter;
  pm: TPopupMenu;
  saveBtn: TButton;
  ConnectHandler, DicHandler: TNotifyEvent;
  TreeHandler: TTVChangedEvent;

  function NewTab(const ACaption: string): TTabSheet;
  begin
    Result := TTabSheet.Create(Self);
    Result.PageControl := U.PC;
    Result.Caption := ACaption;
  end;

  function NewPanel(AParent: TWinControl; AAlign: TAlign; ASize, ATop: Integer): TPanel;
  begin
    Result := TPanel.Create(Self);
    Result.Parent := AParent;
    Result.Top := ATop;
    if AAlign in [alLeft, alRight] then
      Result.Width := ASize
    else
      Result.Height := ASize;
    Result.Align := AAlign;
    Result.Caption := '';
  end;

  function NewLabel(AParent: TWinControl; ALeft, ATop: Integer;
    const ACaption: string): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := AParent;
    Result.Left := ALeft;
    Result.Top := ATop;
    Result.Caption := ACaption;
  end;

  function NewEdit(AParent: TWinControl; ALeft, ATop, AWidth: Integer;
    const AText: string): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := AParent;
    Result.Left := ALeft;
    Result.Top := ATop;
    Result.Width := AWidth;
    Result.Text := AText;
  end;

  function NewButton(AParent: TWinControl; ALeft, ATop, AWidth, AHeight: Integer;
    const ACaption: string; AHandler: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := AParent;
    Result.Left := ALeft;
    Result.Top := ATop;
    Result.Width := AWidth;
    Result.Height := AHeight;
    Result.Caption := ACaption;
    Result.Tag := AEngine;
    Result.OnClick := AHandler;
  end;

  function NewMemo(AParent: TWinControl): TMemo;
  begin
    Result := TMemo.Create(Self);
    Result.Parent := AParent;
    Result.Align := alClient;
    Result.ScrollBars := ssAutoBoth;
  end;

  procedure NewMenuItem(const ACaption: string; AHandler: TNotifyEvent);
  var
    mi: TMenuItem;
  begin
    mi := TMenuItem.Create(pm);
    mi.Caption := ACaption;
    mi.Tag := AEngine;
    mi.OnClick := AHandler;
    pm.Items.Add(mi);
  end;

begin
  FillChar(U, SizeOf(U), 0);

  if AEngine = 3 then
  begin
    ConnectHandler := @btConectarMSSQLClick;
    TreeHandler := @tvMSSQLChange;
    DicHandler := @mnCriaDicionarioMSSQLClick;
  end
  else
  begin
    ConnectHandler := @btConectarOracleClick;
    TreeHandler := @tvOracleChange;
    DicHandler := @mnCriaDicionarioOracleClick;
  end;

  // Conexao: uma consulta para comandos/metadados e outra para a grade
  U.Conn := TZConnection.Create(Self);
  U.ExecQry := TZQuery.Create(Self);
  U.ExecQry.Connection := U.Conn;
  U.GridQry := TZQuery.Create(Self);
  U.GridQry.Connection := U.Conn;
  U.DS := TDataSource.Create(Self);
  U.DS.DataSet := U.GridQry;

  // Aba principal
  U.Tab := TTabSheet.Create(Self);
  U.Tab.PageControl := pgMain;
  U.Tab.Caption := ATitle;

  // Arvore a esquerda com campo de pesquisa (como no PostgreSQL)
  leftPanel := NewPanel(U.Tab, alLeft, 201, 0);
  searchPanel := NewPanel(leftPanel, alTop, 25, 0);
  U.SearchEdit := TEdit.Create(Self);
  U.SearchEdit.Parent := searchPanel;
  U.SearchEdit.Align := alTop;
  U.SearchEdit.Tag := AEngine;
  U.SearchEdit.TextHint := 'Pesquisar tabela (Enter)';
  U.SearchEdit.OnKeyPress := @DynPesqKeyPress;

  U.Tree := TTreeView.Create(Self);
  U.Tree.Parent := leftPanel;
  U.Tree.Align := alClient;
  U.Tree.Images := ImageList1;
  U.Tree.ReadOnly := True;
  U.Tree.RightClickSelect := True;
  U.Tree.OnChange := TreeHandler;

  splitter := TSplitter.Create(Self);
  splitter.Parent := U.Tab;
  splitter.Left := leftPanel.Left + leftPanel.Width + 1;
  splitter.Align := alLeft;
  splitter.Width := 5;

  rightPanel := NewPanel(U.Tab, alClient, 0, 0);

  U.PC := TPageControl.Create(Self);
  U.PC.Parent := rightPanel;
  U.PC.Align := alClient;

  // 1. Connection
  U.TSConn := NewTab(ATitle + ' Connection');
  if AEngine = 4 then
    NewLabel(U.TSConn, 24, 16, 'Servidor (host ou host:porta):')
  else
    NewLabel(U.TSConn, 24, 16, 'Hostname:');
  U.HostEdit := NewEdit(U.TSConn, 24, 32, 216, '127.0.0.1');
  if AEngine = 4 then
    NewLabel(U.TSConn, 25, 71, 'Schema (dono das tabelas; vazio = usuário):')
  else
    NewLabel(U.TSConn, 25, 71, 'Schema:');
  U.SchemaEdit := NewEdit(U.TSConn, 25, 87, 216, '');
  NewLabel(U.TSConn, 24, 120, 'Banco:');
  U.BancoEdit := NewEdit(U.TSConn, 25, 136, 215, '');
  NewLabel(U.TSConn, 24, 176, 'Usuario:');
  U.UserEdit := NewEdit(U.TSConn, 25, 192, 168, '');
  NewLabel(U.TSConn, 24, 232, 'Senha:');
  U.PassEdit := NewEdit(U.TSConn, 25, 248, 168, '');
  U.PassEdit.PasswordChar := '*';
  U.PassEdit.EchoMode := emPassword;
  U.ConnectBtn := NewButton(U.TSConn, 296, 304, 75, 25, 'Conectar', ConnectHandler);

  // 2. SQL  (paineis inferiores na mesma ordem do PostgreSQL, de baixo para cima)
  U.TSSQL := NewTab('SQL');

  sqlBarPanel := NewPanel(U.TSSQL, alBottom, 41, 10000);
  NewLabel(sqlBarPanel, 8, 8, 'Linha:');
  U.LineLabel := NewLabel(sqlBarPanel, 48, 8, '0');
  NewLabel(sqlBarPanel, 96, 8, 'Coluna:');
  U.ColLabel := NewLabel(sqlBarPanel, 144, 8, '0');
  sqlBtnPanel := NewPanel(sqlBarPanel, alRight, 300, 0);
  sqlBtnPanel.BevelOuter := bvNone;
  NewButton(sqlBtnPanel, 6, 8, 88, 25, 'Analysis', @DynAnaliseClick);
  U.OpenBtn := NewButton(sqlBtnPanel, 100, 8, 88, 25, 'Open', @DynOpenClick);
  NewButton(sqlBtnPanel, 199, 8, 88, 25, 'Execute', @DynExecuteClick);

  findPanel := NewPanel(U.TSSQL, alBottom, 50, 9000);
  U.FindList := TListBox.Create(Self);
  U.FindList.Parent := findPanel;
  U.FindList.Align := alClient;
  U.FindList.OnClick := @lstfindClick;

  sqlSplitter := TSplitter.Create(Self);
  sqlSplitter.Parent := U.TSSQL;
  sqlSplitter.Top := 8000;
  sqlSplitter.Align := alBottom;
  sqlSplitter.Height := 5;

  erroPanel := NewPanel(U.TSSQL, alBottom, 74, 7000);
  U.ErrorMemo := NewMemo(erroPanel);
  U.ErrorMemo.ReadOnly := True;

  U.IAPanel := NewPanel(U.TSSQL, alBottom, 162, 6000);
  iaBarPanel := NewPanel(U.IAPanel, alBottom, 50, 0);
  iaBtnPanel := NewPanel(iaBarPanel, alRight, 100, 0);
  iaBtnPanel.BevelOuter := bvNone;
  NewButton(iaBtnPanel, 8, 8, 84, 28, 'ASK', @DynIAClick);
  U.IAMemo := NewMemo(U.IAPanel);

  pm := TPopupMenu.Create(Self);
  NewMenuItem('Fonte', @DynFontClick);
  NewMenuItem('Copy to New Edit', @DynNewEditClick);
  NewMenuItem('Beautify Code', @DynEmbelezarClick);
  NewMenuItem('-', nil);
  NewMenuItem('IA', @DynToggleIAClick);

  sqlPanel := NewPanel(U.TSSQL, alClient, 0, 0);
  U.SynEdit := TSynEdit.Create(Self);
  U.SynEdit.Parent := sqlPanel;
  U.SynEdit.Align := alClient;
  U.SynEdit.Highlighter := SynSQLSyn2;
  U.SynEdit.Font.Name := 'Courier New';
  U.SynEdit.Font.Height := -19;
  U.SynEdit.Font.Pitch := fpFixed;
  U.SynEdit.Font.Quality := fqDraft;
  U.SynEdit.Tag := AEngine;
  U.SynEdit.PopupMenu := pm;
  U.SynEdit.OnStatusChange := @DynSQLStatusChange;

  // 3. Grid
  U.TSGrid := NewTab('Grid');
  gridBarPanel := NewPanel(U.TSGrid, alTop, 50, 0);
  U.Nav := TDBNavigator.Create(Self);
  U.Nav.Parent := gridBarPanel;
  U.Nav.Left := 36;
  U.Nav.Top := 17;
  U.Nav.Width := 241;
  U.Nav.Height := 25;
  U.Nav.DataSource := U.DS;
  saveBtn := NewButton(gridBarPanel, 285, 17, 75, 25, 'Salvar', @btSalvarDynamicClick);
  saveBtn.Hint := 'Salva as alterações feitas no grid diretamente no banco de dados';
  saveBtn.ShowHint := True;
  NewButton(gridBarPanel, 368, 17, 75, 25, 'Chart', @DynChartClick);
  U.MakeCombo := TComboBox.Create(Self);
  U.MakeCombo.Parent := gridBarPanel;
  U.MakeCombo.Left := 452;
  U.MakeCombo.Top := 17;
  U.MakeCombo.Width := 151;
  U.MakeCombo.Style := csDropDownList;
  U.MakeCombo.Items.Add('JSON');
  U.MakeCombo.Items.Add('CSV');
  U.MakeCombo.ItemIndex := 0;
  NewButton(gridBarPanel, 612, 17, 75, 25, 'Make', @DynMakeClick);

  U.Grid := TDBGrid.Create(Self);
  U.Grid.Parent := U.TSGrid;
  U.Grid.Align := alClient;
  U.Grid.DataSource := U.DS;
  U.Grid.ReadOnly := False;

  // 4. Log
  U.TSLog := NewTab('Log');
  U.LogMemo := NewMemo(U.TSLog);
  U.LogMemo.ReadOnly := True;

  // 5. Tools
  U.TSTools := NewTab('Tools');
  if AEngine = 4 then
    NewButton(U.TSTools, 15, 40, 186, 25, 'Cria schema', @DynCriaBancoClick)
  else
    NewButton(U.TSTools, 15, 40, 186, 25, 'Cria database', @DynCriaBancoClick);
  NewButton(U.TSTools, 15, 90, 186, 25, 'Criar usuario', @DynCriaUsuarioClick);
  NewButton(U.TSTools, 15, 139, 186, 25, 'Permissão', @DynPermissaoClick);
  NewButton(U.TSTools, 15, 211, 186, 25, 'Comparar', @btcompararClick);
  NewButton(U.TSTools, 15, 262, 186, 25, 'Dicionário de Dados', DicHandler);
  NewButton(U.TSTools, 15, 311, 186, 25, 'Diagrama ER do Banco', @DiagramMenuClick);

  U.PC.ActivePage := U.TSConn;
  FDyn[AEngine] := U;

  // Campos usados pelo restante da unidade (conexao, scripts, dicionario, diagrama)
  if AEngine = 3 then
  begin
    tsMSSQL := U.Tab;           pcMSSQL := U.PC;
    tsConnMSSQL := U.TSConn;    tsSQLMSSQL := U.TSSQL;
    tsGridMSSQL := U.TSGrid;    tsLogMSSQL := U.TSLog;
    tsToolsMSSQL := U.TSTools;
    zconMSSQL := U.Conn;        zmssqlqry := U.ExecQry;
    dsmssql := U.DS;            tvMSSQL := U.Tree;
    edHostMSSQL := U.HostEdit;  edBancoMSSQL := U.BancoEdit;
    edUserMSSQL := U.UserEdit;  edPassMSSQL := U.PassEdit;
    edSchemaMSSQL := U.SchemaEdit;
    btConectarMSSQL := U.ConnectBtn;
    edSQLMSSQL := U.SynEdit;    btExecMSSQL := U.OpenBtn;
    dbgridMSSQL := U.Grid;      edErroMSSQL := U.ErrorMemo;
  end
  else
  begin
    tsOracle := U.Tab;          pcOracle := U.PC;
    tsConnOracle := U.TSConn;   tsSQLOracle := U.TSSQL;
    tsGridOracle := U.TSGrid;   tsLogOracle := U.TSLog;
    tsToolsOracle := U.TSTools;
    zconOracle := U.Conn;       zoracleqry := U.ExecQry;
    dsoracle := U.DS;           tvOracle := U.Tree;
    edHostOracle := U.HostEdit; edBancoOracle := U.BancoEdit;
    edUserOracle := U.UserEdit; edPassOracle := U.PassEdit;
    edSchemaOracle := U.SchemaEdit;
    btConectarOracle := U.ConnectBtn;
    edSQLOracle := U.SynEdit;   btExecOracle := U.OpenBtn;
    dbgridOracle := U.Grid;     edErroOracle := U.ErrorMemo;
  end;
end;

function Tfrmmquery2.DynGridDataSet(AEngine: Integer): TDataSet;
begin
  Result := nil;
  if (AEngine >= Low(FDyn)) and (AEngine <= High(FDyn)) then
    Result := FDyn[AEngine].GridQry;
end;

function Tfrmmquery2.DynEngineFromSender(Sender: TObject): Integer;
begin
  Result := -1;
  if Sender is TComponent then
    Result := TComponent(Sender).Tag;
  if (Result < Low(FDyn)) or (Result > High(FDyn)) then
    Result := GetActiveEngineIndex;
  if (Result < Low(FDyn)) or (Result > High(FDyn)) then
    Result := -1;
end;

function Tfrmmquery2.DynNome(AEngine: Integer): string;
begin
  if AEngine = 4 then
    Result := 'Oracle'
  else
    Result := 'SQL Server';
end;

function Tfrmmquery2.DynQuoteIdent(AEngine: Integer; const AName: string): string;
begin
  if AEngine = 4 then
    Result := '"' + StringReplace(Trim(AName), '"', '""', [rfReplaceAll]) + '"'
  else
    Result := '[' + StringReplace(Trim(AName), ']', ']]', [rfReplaceAll]) + ']';
end;

function Tfrmmquery2.DynExigeConexao(AEngine: Integer): Boolean;
begin
  Result := (FDyn[AEngine].Conn <> nil) and FDyn[AEngine].Conn.Connected;
  if not Result then
    ShowMessage(DynNome(AEngine) + ' não conectado!');
end;

procedure Tfrmmquery2.DynLog(AEngine: Integer; const AMsg: string; AIsError: Boolean);
begin
  if (AEngine < Low(FDyn)) or (AEngine > High(FDyn)) then Exit;
  if FDyn[AEngine].LogMemo <> nil then
    FDyn[AEngine].LogMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' ' + AMsg);
  if AIsError and (FDyn[AEngine].ErrorMemo <> nil) then
    FDyn[AEngine].ErrorMemo.Lines.Add(AMsg);
end;

function Tfrmmquery2.DynExecSQL(AEngine: Integer; const ASQL: string): Boolean;
begin
  Result := False;
  try
    FDyn[AEngine].ExecQry.Close;
    FDyn[AEngine].ExecQry.SQL.Text := ASQL;
    DynLog(AEngine, 'SQL Execute:' + ASQL);
    FDyn[AEngine].ExecQry.ExecSQL;
    DynLog(AEngine, Format('Comando executado. %d linhas afetadas.',
      [FDyn[AEngine].ExecQry.RowsAffected]));
    Result := True;
  except
    on E: Exception do
    begin
      DynLog(AEngine, 'Error:' + E.Message, True);
      ShowMessage('Error:' + E.Message);
    end;
  end;
end;

procedure Tfrmmquery2.DynOpenClick(Sender: TObject);
var
  E: Integer;
  SQL: string;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not DynExigeConexao(E) then Exit;

  SQL := Trim(FDyn[E].SynEdit.Lines.Text);
  if SQL = '' then
  begin
    ShowMessage('Digite um comando SQL.');
    Exit;
  end;

  FDyn[E].ErrorMemo.Clear;
  try
    FDyn[E].GridQry.Close;
    FDyn[E].GridQry.SQL.Text := FDyn[E].SynEdit.Lines.Text;
    DynLog(E, 'SQL OPEN:' + SQL);
    FDyn[E].Grid.ReadOnly := False;
    FDyn[E].GridQry.Open;
    DynLog(E, Format('%d registros retornados.', [FDyn[E].GridQry.RecordCount]));
    FDyn[E].PC.ActivePage := FDyn[E].TSGrid;
  except
    on Ex: Exception do
    begin
      DynLog(E, 'Error:' + Ex.Message, True);
      ShowMessage('Error:' + Ex.Message);
    end;
  end;
end;

procedure Tfrmmquery2.DynExecuteClick(Sender: TObject);
var
  E: Integer;
  SQL: string;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not DynExigeConexao(E) then Exit;

  SQL := Trim(FDyn[E].SynEdit.Lines.Text);
  if SQL = '' then
  begin
    ShowMessage('Digite um comando SQL.');
    Exit;
  end;

  FDyn[E].ErrorMemo.Clear;
  DynExecSQL(E, FDyn[E].SynEdit.Lines.Text);
end;

procedure Tfrmmquery2.DynAnaliseClick(Sender: TObject);
var
  E: Integer;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;

  frmMNote.NewContext();
  frmMNote.edChat.Text := sqltabela + FDyn[E].SynEdit.Text + ' faça em uma caixa de texto';
  frmMNote.FazPergunta();
end;

function Tfrmmquery2.CriaListaDependenciasDyn(AEngine: Integer): string;
var
  Q: TZQuery;
  L: TStringList;
  Dono: string;
begin
  Result := '';
  if (FDyn[AEngine].Conn = nil) or (not FDyn[AEngine].Conn.Connected) then Exit;

  Q := TZQuery.Create(nil);
  L := TStringList.Create;
  try
    Q.Connection := FDyn[AEngine].Conn;
    if AEngine = 4 then
    begin
      Dono := OracleOwner;
      Q.SQL.Text :=
        'SELECT a.constraint_name AS FK_NAME, a.owner AS PARENT_SCHEMA, ' +
        '       a.table_name AS PARENT_TABLE, a.column_name AS PARENT_COLUMN, ' +
        '       b.owner AS REF_SCHEMA, b.table_name AS REF_TABLE, b.column_name AS REF_COLUMN ' +
        'FROM all_cons_columns a ' +
        'JOIN all_constraints c ON c.owner = a.owner AND c.constraint_name = a.constraint_name ' +
        'JOIN all_cons_columns b ON b.owner = c.r_owner AND b.constraint_name = c.r_constraint_name ' +
        '                       AND b.position = a.position ' +
        'WHERE c.constraint_type = ''R'' AND a.owner = :owner ' +
        'ORDER BY a.table_name, a.constraint_name, a.position';
      Q.ParamByName('owner').AsString := Dono;
    end
    else
      Q.SQL.Text :=
        'SELECT fk.name AS FK_NAME, SCHEMA_NAME(tp.schema_id) AS PARENT_SCHEMA, ' +
        '       tp.name AS PARENT_TABLE, cp.name AS PARENT_COLUMN, ' +
        '       SCHEMA_NAME(tr.schema_id) AS REF_SCHEMA, tr.name AS REF_TABLE, cr.name AS REF_COLUMN ' +
        'FROM sys.foreign_keys fk ' +
        'JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id ' +
        'JOIN sys.tables tp ON tp.object_id = fkc.parent_object_id ' +
        'JOIN sys.columns cp ON cp.object_id = fkc.parent_object_id AND cp.column_id = fkc.parent_column_id ' +
        'JOIN sys.tables tr ON tr.object_id = fkc.referenced_object_id ' +
        'JOIN sys.columns cr ON cr.object_id = fkc.referenced_object_id AND cr.column_id = fkc.referenced_column_id ' +
        'ORDER BY tp.name, fk.name';
    try
      Q.Open;
      while not Q.EOF do
      begin
        L.Add(Format('%s.%s.%s -> %s.%s.%s (%s)', [
          Q.FieldByName('PARENT_SCHEMA').AsString,
          Q.FieldByName('PARENT_TABLE').AsString,
          Q.FieldByName('PARENT_COLUMN').AsString,
          Q.FieldByName('REF_SCHEMA').AsString,
          Q.FieldByName('REF_TABLE').AsString,
          Q.FieldByName('REF_COLUMN').AsString,
          Q.FieldByName('FK_NAME').AsString]));
        Q.Next;
      end;
    except
      on E: Exception do
        DynLog(AEngine, 'Falha ao listar dependências: ' + E.Message);
    end;
    Result := L.Text;
  finally
    L.Free;
    Q.Free;
  end;
end;

function Tfrmmquery2.QuestionarSQLDyn(AEngine: Integer; const APergunta: string): string;

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
  ctxDeps, ctxDDL, ask, outSQL, DevMsg, Dialeto: string;
begin
  Result := '';

  if (FSetMain.Provider <> 3) and (Trim(FSetMain.CHATGPT) = '') then
  begin
    if FSetMain.Provider = 4 then
      ShowMessage('Configure a chave de API/Token em SetMain.CHATGPT.')
    else
      ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  ctxDeps := CriaListaDependenciasDyn(AEngine);
  if AEngine = 4 then
  begin
    ctxDDL := CriaDicionarioOracle('');
    Dialeto := 'Oracle (SQL e PL/SQL). Não termine comandos com ponto e vírgula';
  end
  else
  begin
    ctxDDL := CriaDicionarioMSSQL('');
    Dialeto := 'Microsoft SQL Server (T-SQL)';
  end;

  ask :=
    'Pergunta do usuário:' + LineEnding +
    APergunta + LineEnding + LineEnding +
    '--- CONTEXTO: DEPENDÊNCIAS (FK) ---' + LineEnding +
    ctxDeps + LineEnding + LineEnding +
    '--- CONTEXTO: DDL COMPLETO DAS TABELAS ---' + LineEnding +
    ctxDDL + LineEnding + LineEnding +
    'Gere APENAS o SQL final (um único bloco).';

  DevMsg :=
    'Você é um assistente SQL para ' + Dialeto + '.' + LineEnding +
    'REGRAS:' + LineEnding +
    '1) Responda SOMENTE com SQL válido, sem explicações ou comentários.' + LineEnding +
    '2) Use exatamente os nomes de schema/tabela/coluna informados.' + LineEnding +
    '3) Considere as dependências (FKs) e os DDLs fornecidos.' + LineEnding +
    '4) Se algo não for possível por falta de dados, use comentários SQL iniciando com -- TODO.' + LineEnding +
    '5) Não gerar dados fictícios; somente DDL/DML/queries necessárias.';

  if not MNoteAI.SendQuestion(ask, DevMsg, outSQL) then
  begin
    ShowMessage('Erro ao consultar IA: ' + MNoteAI.LastError);
    Exit;
  end;
  Result := StripCodeFences(outSQL);
end;

procedure Tfrmmquery2.DynIAClick(Sender: TObject);
var
  E: Integer;
  sqlIA: string;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not DynExigeConexao(E) then Exit;

  if Trim(FDyn[E].IAMemo.Text) = '' then
  begin
    ShowMessage('Escreva a pergunta para a IA.');
    Exit;
  end;

  sqlIA := QuestionarSQLDyn(E, FDyn[E].IAMemo.Text);
  if sqlIA = '' then Exit;

  FDyn[E].SynEdit.Text := sqlIA;
  DynLog(E, 'Question:' + FDyn[E].IAMemo.Text);
  DynLog(E, 'Return:' + sqlIA);
  FDyn[E].PC.ActivePage := FDyn[E].TSSQL;
end;

procedure Tfrmmquery2.DynChartClick(Sender: TObject);
var
  E: Integer;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not FDyn[E].GridQry.Active then
  begin
    ShowMessage('Nenhum resultado ativo para plotar. Use Open primeiro.');
    Exit;
  end;
  if E = 4 then
    ChartView(ccOracle)
  else
    ChartView(ccMSSQL);
end;

procedure Tfrmmquery2.DynMakeClick(Sender: TObject);
var
  E: Integer;
  ts: TTabSheet;
  item: TItem;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not FDyn[E].GridQry.Active then
  begin
    ShowMessage('Nenhum resultado ativo. Use Open primeiro.');
    Exit;
  end;

  ts := frmMNote.NovoItem();
  item := TItem(ts.Tag);
  case FDyn[E].MakeCombo.ItemIndex of
    1: item.syn.Text := DatasetTocsvString(FDyn[E].GridQry);
  else
    item.syn.Text := DatasetToJsonString(FDyn[E].GridQry);
  end;
end;

procedure Tfrmmquery2.DynCriaBancoClick(Sender: TObject);
var
  E: Integer;
  nome, senha: string;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not DynExigeConexao(E) then Exit;

  if E = 4 then
  begin
    // No Oracle um schema e criado junto com o usuario dono dele
    nome := Trim(InputBox('Criação de schema', 'Schema (usuário dono):', 'novo_schema'));
    if nome = '' then Exit;
    senha := InputBox('Criação de schema', 'Senha:', 'secret');
    FDyn[E].SynEdit.Text := 'CREATE USER ' + DynQuoteIdent(E, UpperCase(nome)) +
      ' IDENTIFIED BY ' + DynQuoteIdent(E, senha);
    if DynExecSQL(E, FDyn[E].SynEdit.Text) then
      DynExecSQL(E, 'GRANT CONNECT, RESOURCE TO ' + DynQuoteIdent(E, UpperCase(nome)));
  end
  else
  begin
    nome := Trim(InputBox('Criação de database', 'Banco:', 'database'));
    if nome = '' then Exit;
    FDyn[E].SynEdit.Text := 'CREATE DATABASE ' + DynQuoteIdent(E, nome) + ';';
    DynExecSQL(E, FDyn[E].SynEdit.Text);
  end;
end;

procedure Tfrmmquery2.DynCriaUsuarioClick(Sender: TObject);
var
  E: Integer;
  usuario, senha: string;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not DynExigeConexao(E) then Exit;

  usuario := Trim(InputBox('Criação de usuário', 'Usuário:', 'username'));
  if usuario = '' then Exit;
  senha := InputBox('Criação de usuário', 'Senha:', 'secret');

  if E = 4 then
  begin
    FDyn[E].SynEdit.Text := 'CREATE USER ' + DynQuoteIdent(E, UpperCase(usuario)) +
      ' IDENTIFIED BY ' + DynQuoteIdent(E, senha);
    if DynExecSQL(E, FDyn[E].SynEdit.Text) then
      DynExecSQL(E, 'GRANT CREATE SESSION TO ' + DynQuoteIdent(E, UpperCase(usuario)));
  end
  else
  begin
    FDyn[E].SynEdit.Text :=
      'CREATE LOGIN ' + DynQuoteIdent(E, usuario) + ' WITH PASSWORD = ' + QuotedStr(senha) + ';' + LineEnding +
      'CREATE USER ' + DynQuoteIdent(E, usuario) + ' FOR LOGIN ' + DynQuoteIdent(E, usuario) + ';';
    DynExecSQL(E, FDyn[E].SynEdit.Text);
  end;
end;

procedure Tfrmmquery2.DynPermissaoClick(Sender: TObject);
var
  E: Integer;
  usuario: string;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if not DynExigeConexao(E) then Exit;

  if E = 4 then
  begin
    usuario := Trim(InputBox('Permissão', 'Usuário:', 'username'));
    if usuario = '' then Exit;
    FDyn[E].SynEdit.Text := 'GRANT CONNECT, RESOURCE TO ' + DynQuoteIdent(E, UpperCase(usuario));
  end
  else
  begin
    usuario := Trim(InputBox('Permissão no banco conectado', 'Usuário:', 'username'));
    if usuario = '' then Exit;
    FDyn[E].SynEdit.Text := 'ALTER ROLE db_owner ADD MEMBER ' + DynQuoteIdent(E, usuario) + ';';
  end;
  DynExecSQL(E, FDyn[E].SynEdit.Text);
end;

procedure Tfrmmquery2.DynPesqKeyPress(Sender: TObject; var Key: char);
var
  E, I: Integer;
  Raiz, N: TTreeNode;
  Alvo: string;
begin
  if Key <> #13 then Exit;
  Key := #0;
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;

  if E = 4 then Raiz := posicaofieldsOracle else Raiz := posicaofieldsMSSQL;
  Alvo := LowerCase(Trim(FDyn[E].SearchEdit.Text));
  if (Raiz = nil) or (Alvo = '') then Exit;

  // Primeiro nome exato, depois nome que contem o texto
  for I := 0 to Raiz.Count - 1 do
    if LowerCase(Raiz.Items[I].Text) = Alvo then
    begin
      FDyn[E].Tree.Select(Raiz.Items[I]);
      Raiz.Items[I].MakeVisible;
      Exit;
    end;
  for I := 0 to Raiz.Count - 1 do
  begin
    N := Raiz.Items[I];
    if Pos(Alvo, LowerCase(N.Text)) > 0 then
    begin
      FDyn[E].Tree.Select(N);
      N.MakeVisible;
      Exit;
    end;
  end;
end;

procedure Tfrmmquery2.DynSQLStatusChange(Sender: TObject; Changes: TSynStatusChanges);
var
  E: Integer;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  if FDyn[E].LineLabel <> nil then
    FDyn[E].LineLabel.Caption := IntToStr(FDyn[E].SynEdit.CaretY);
  if FDyn[E].ColLabel <> nil then
    FDyn[E].ColLabel.Caption := IntToStr(FDyn[E].SynEdit.CaretX);
end;

procedure Tfrmmquery2.DynFontClick(Sender: TObject);
var
  E: Integer;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  FontDialog1.Font := FDyn[E].SynEdit.Font;
  if FontDialog1.Execute then
    FDyn[E].SynEdit.Font := FontDialog1.Font;
end;

procedure Tfrmmquery2.DynNewEditClick(Sender: TObject);
var
  E: Integer;
  ts: TTabSheet;
  item: TItem;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  ts := frmMNote.NovoItem();
  item := TItem(ts.Tag);
  item.syn.Text := FDyn[E].SynEdit.Lines.Text;
end;

procedure Tfrmmquery2.DynEmbelezarClick(Sender: TObject);
var
  E: Integer;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  frmMNote.NewContext();
  frmMNote.edChat.Text := sqlEstetica + FDyn[E].SynEdit.Text;
  frmMNote.FazPergunta();
  if frmMNote.meCodes.Text <> '' then
    FDyn[E].SynEdit.Text := frmMNote.meCodes.Text;
end;

procedure Tfrmmquery2.DynToggleIAClick(Sender: TObject);
var
  E: Integer;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  FDyn[E].IAPanel.Visible := not FDyn[E].IAPanel.Visible;
end;

{ ============================================================================
  Bibliotecas de cliente (Oracle e SQL Server) em libs\<banco>\<plataforma>
    Oracle:     libs\oracle\win32\oci.dll        (Oracle Instant Client 32 bits)
    SQL Server: libs\mssql\win32\sybdb.dll       (FreeTDS 32 bits)
                ou libs\mssql\win32\ntwdblib.dll (DB-Library da Microsoft)
  Tambem aceita uma subpasta (ex.: libs\oracle\win32\instantclient_19_28),
  o caminho configurado em Configurações de banco e a pasta do executavel.
  ============================================================================ }

function Tfrmmquery2.LocalizaBibliotecaBanco(const APasta: string;
  const AArquivos: array of string; const AConfigurado: string): string;
var
  Pastas: TStringList;
  ExeDir, Plat: string;
  I, J: Integer;

  function ProcuraEm(const ADir, AArquivo: string): string;
  var
    SR: TSearchRec;
    Base: string;
  begin
    Result := '';
    if (ADir = '') or not DirectoryExists(ADir) then Exit;
    Base := IncludeTrailingPathDelimiter(ExpandFileName(ADir));
    if FileExists(Base + AArquivo) then
      Exit(Base + AArquivo);
    // Um nivel de subpastas (o zip do Instant Client cria instantclient_xx_yy)
    if FindFirst(Base + '*', faDirectory, SR) = 0 then
    try
      repeat
        if ((SR.Attr and faDirectory) <> 0) and (SR.Name <> '.') and (SR.Name <> '..') and
          FileExists(Base + SR.Name + PathDelim + AArquivo) then
          Exit(Base + SR.Name + PathDelim + AArquivo);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;

begin
  Result := '';
  // Arquivo indicado explicitamente nas configuracoes tem prioridade
  if (Trim(AConfigurado) <> '') and FileExists(Trim(AConfigurado)) then
    Exit(ExpandFileName(Trim(AConfigurado)));

  {$IFDEF WINDOWS}
    {$IFDEF CPU64} Plat := 'win64'; {$ELSE} Plat := 'win32'; {$ENDIF}
  {$ELSE}
    Plat := 'Linux';
  {$ENDIF}
  ExeDir := ExtractFilePath(Application.ExeName);

  Pastas := TStringList.Create;
  try
    // Instalado: <app>\libs\...   Desenvolvimento (exe em src): <projeto>\libs\...
    Pastas.Add(ExeDir + 'libs' + PathDelim + APasta + PathDelim + Plat);
    Pastas.Add(ExeDir + '..' + PathDelim + 'libs' + PathDelim + APasta + PathDelim + Plat);
    if (Trim(AConfigurado) <> '') and DirectoryExists(Trim(AConfigurado)) then
      Pastas.Add(Trim(AConfigurado));
    Pastas.Add(ExeDir);

    for I := 0 to Pastas.Count - 1 do
      for J := Low(AArquivos) to High(AArquivos) do
      begin
        Result := ProcuraEm(Pastas[I], AArquivos[J]);
        if Result <> '' then Exit;
      end;
  finally
    Pastas.Free;
  end;
end;

procedure Tfrmmquery2.PreparaPastaBiblioteca(const ABiblioteca: string);
{$IFDEF WINDOWS}
var
  Dir, Atual: string;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  // As DLLs que o cliente carrega (ex.: oraociei19.dll do Instant Client)
  // ficam na mesma pasta; o Windows so as encontra se a pasta estiver no PATH.
  Dir := ExcludeTrailingPathDelimiter(ExtractFilePath(ABiblioteca));
  if Dir = '' then Exit;
  Atual := GetEnvironmentVariable('PATH');
  if Pos(LowerCase(Dir) + ';', LowerCase(Atual) + ';') = 0 then
    MQuerySetEnvironmentVariableW(PWideChar(UnicodeString('PATH')),
      PWideChar(UnicodeString(Dir + ';' + Atual)));
  {$ENDIF}
end;

function Tfrmmquery2.ConectMSSQL: Boolean;
var
  Biblioteca: string;
begin
  Result := False;

  if zconMSSQL.Connected then
    zconMSSQL.Disconnect;

  zconMSSQL.Protocol := 'mssql';
  zconMSSQL.HostName := edHostMSSQL.Text;
  zconMSSQL.Database := edBancoMSSQL.Text;
  zconMSSQL.User     := edUserMSSQL.Text;
  zconMSSQL.Password := edPassMSSQL.Text;

  // Set properties in settings
  if FSetMain <> nil then
  begin
    FSetMain.HostnameMSSQL := edHostMSSQL.Text;
    FSetMain.BancoMSSQL    := edBancoMSSQL.Text;
    FSetMain.UsernameMSSQL := edUserMSSQL.Text;
    FSetMain.PasswordMSSQL := edPassMSSQL.Text;
    FSetMain.SchemaMSSQL   := edSchemaMSSQL.Text;
    FSetMain.SalvaContexto(False);
  end;

  // Cliente SQL Server: libs\mssql\win32\sybdb.dll (FreeTDS) ou ntwdblib.dll
  Biblioteca := '';
  if FSetMain <> nil then Biblioteca := FSetMain.DLLMSSQLPath;
  {$IFDEF WINDOWS}
  Biblioteca := LocalizaBibliotecaBanco('mssql', ['sybdb.dll', 'libsybdb-5.dll', 'ntwdblib.dll'], Biblioteca);
  {$ELSE}
  Biblioteca := LocalizaBibliotecaBanco('mssql', ['libsybdb.so.5', 'libsybdb.so'], Biblioteca);
  {$ENDIF}
  if Biblioteca = '' then
  begin
    DynLog(3, 'Cliente SQL Server não encontrado (sybdb.dll ou ntwdblib.dll). Copie as DLLs ' +
      '32 bits do FreeTDS para libs\mssql\win32 (veja o LEIA-ME.txt dessa pasta).', True);
    Exit;
  end;
  PreparaPastaBiblioteca(Biblioteca);
  zconMSSQL.LibraryLocation := Biblioteca;
  // sybdb (FreeTDS) usa o protocolo FreeTDS; ntwdblib usa o protocolo mssql
  if Pos('sybdb', LowerCase(ExtractFileName(Biblioteca))) > 0 then
    zconMSSQL.Protocol := 'FreeTDS_MsSQL>=2005'
  else
    zconMSSQL.Protocol := 'mssql';
  DynLog(3, 'Cliente SQL Server: ' + Biblioteca + ' (protocolo ' + zconMSSQL.Protocol + ')');

  try
    zconMSSQL.Connect;
    Result := zconMSSQL.Connected;
  except
    on E: Exception do
    begin
      DynLog(3, 'Erro de Conexão: ' + E.Message, True);
      Result := False;
    end;
  end;
end;

function Tfrmmquery2.OracleOwner: string;
begin
  // Dono das tabelas da arvore carregada (pode ter caido para o usuario)
  if FOracleOwner <> '' then
    Exit(FOracleOwner);
  Result := UpperCase(Trim(edSchemaOracle.Text));
  // Numero no campo Schema e quase sempre a porta digitada no lugar errado
  if (Result <> '') and (StrToIntDef(Result, -1) >= 0) then
  begin
    DynLog(4, 'O campo Schema contém "' + Result + '", que parece uma porta. ' +
      'Usando o usuário como schema. Para outra porta, use host:porta no servidor.', True);
    Result := '';
  end;
  if Result = '' then
    Result := UpperCase(Trim(edUserOracle.Text));
end;

function Tfrmmquery2.ConectOracle: Boolean;
var
  Biblioteca, ConnStr, SIDStr, Erro1: string;
begin
  Result := False;

  if zconOracle.Connected then
    zconOracle.Disconnect;

  FOracleOwner := '';
  zconOracle.Protocol := 'oracle';
  zconOracle.HostName := Trim(edHostOracle.Text);
  // O ZEOS usa so o campo Database no Oracle: com servidor informado,
  // monta a conexao direta //host:porta/servico (dispensa tnsnames.ora).
  ConnStr := BuildOracleConnectString(edHostOracle.Text, edBancoOracle.Text,
    zconOracle.Port, False);
  zconOracle.Database := ConnStr;
  zconOracle.User     := edUserOracle.Text;
  zconOracle.Password := edPassOracle.Text;

  // Set properties in settings
  if FSetMain <> nil then
  begin
    FSetMain.HostnameOracle := edHostOracle.Text;
    FSetMain.BancoOracle    := edBancoOracle.Text;
    FSetMain.UsernameOracle := edUserOracle.Text;
    FSetMain.PasswordOracle := edPassOracle.Text;
    FSetMain.SchemaOracle   := edSchemaOracle.Text;
    FSetMain.SalvaContexto(False);
  end;

  // Cliente Oracle: libs\oracle\win32\oci.dll (Oracle Instant Client 32 bits)
  Biblioteca := '';
  if FSetMain <> nil then Biblioteca := FSetMain.DLLOraclePath;
  {$IFDEF WINDOWS}
  Biblioteca := LocalizaBibliotecaBanco('oracle', ['oci.dll'], Biblioteca);
  {$ELSE}
  Biblioteca := LocalizaBibliotecaBanco('oracle', ['libclntsh.so'], Biblioteca);
  {$ENDIF}
  if Biblioteca = '' then
  begin
    DynLog(4, 'Cliente Oracle não encontrado (oci.dll). Extraia o Oracle Instant Client ' +
      '32 bits em libs\oracle\win32 (veja o LEIA-ME.txt dessa pasta).', True);
    Exit;
  end;
  PreparaPastaBiblioteca(Biblioteca);
  zconOracle.LibraryLocation := Biblioteca;
  DynLog(4, 'Cliente Oracle: ' + Biblioteca);
  DynLog(4, 'Conectando em: ' + ConnStr);

  Erro1 := '';
  try
    zconOracle.Connect;
    Result := zconOracle.Connected;
  except
    on E: Exception do
    begin
      Erro1 := E.Message;
      Result := False;
    end;
  end;

  // Nome de servico desconhecido no servidor: tenta o mesmo nome como SID
  if (not Result) and (Pos('ORA-12514', Erro1) > 0) then
  begin
    SIDStr := BuildOracleConnectString(edHostOracle.Text, edBancoOracle.Text,
      zconOracle.Port, True);
    if SIDStr <> ConnStr then
    begin
      DynLog(4, 'Serviço "' + Trim(edBancoOracle.Text) +
        '" não reconhecido; tentando como SID: ' + SIDStr);
      if zconOracle.Connected then zconOracle.Disconnect;
      zconOracle.Database := SIDStr;
      try
        zconOracle.Connect;
        Result := zconOracle.Connected;
        Erro1 := '';
      except
        on E: Exception do
          Erro1 := Erro1 + LineEnding + 'Como SID: ' + E.Message;
      end;
    end;
  end;

  if not Result then
  begin
    DynLog(4, 'Erro de Conexão: ' + Erro1, True);
    if (Pos('ORA-12154', Erro1) > 0) and (Trim(edHostOracle.Text) = '') then
      DynLog(4, 'Dica: informe o servidor (host ou host:porta) para conexão ' +
        'direta, ou coloque um tnsnames.ora em ' +
        ExtractFilePath(Biblioteca) + 'network\admin.', True);
  end;
end;

procedure Tfrmmquery2.btConectarMSSQLClick(Sender: TObject);
var
  tvitem: TTreeNode;
begin
  try
  tvitemMSSQL.DeleteChildren;
  posicaofieldsMSSQL := nil;
  edErroMSSQL.Clear;

  if not ConectMSSQL then
  begin
    DynLog(3, 'Falha ao conectar no SQL Server.', True);
    if pcMSSQL <> nil then pcMSSQL.ActivePage := tsLogMSSQL;
    Exit;
  end;

  try
    tvitemMSSQL.Text := edBancoMSSQL.Text;
    tvitemMSSQL.ImageIndex := 13;

    posicaofieldsMSSQL := tvMSSQL.Items.AddChildObject(tvitemMSSQL, 'tables', Pointer(ETDTabelas));
    posicaofieldsMSSQL.ImageIndex := 15;

    ListarTabelasMSSQL();
    DynLog(3, 'Conectado com sucesso ao SQL Server!');
    if pcMSSQL <> nil then pcMSSQL.ActivePage := tsSQLMSSQL;
  except
    on E: Exception do
    begin
      DynLog(3, 'Erro ao listar tabelas: ' + E.Message, True);
      if pcMSSQL <> nil then pcMSSQL.ActivePage := tsLogMSSQL;
    end;
  end;
  finally
    if frmMNote <> nil then frmMNote.SyncSolutionDatabaseFromMQuery;
  end;
end;

procedure Tfrmmquery2.btConectarOracleClick(Sender: TObject);
var
  tvitem: TTreeNode;
begin
  try
  tvitemOracle.DeleteChildren;
  posicaofieldsOracle := nil;
  edErroOracle.Clear;

  if not ConectOracle then
  begin
    DynLog(4, 'Falha ao conectar no Oracle.', True);
    if pcOracle <> nil then pcOracle.ActivePage := tsLogOracle;
    Exit;
  end;

  try
    tvitemOracle.Text := edBancoOracle.Text;
    tvitemOracle.ImageIndex := 13;

    posicaofieldsOracle := tvOracle.Items.AddChildObject(tvitemOracle, 'tables', Pointer(ETDTabelas));
    posicaofieldsOracle.ImageIndex := 15;

    ListarTabelasOracle();
    DynLog(4, 'Conectado com sucesso ao Oracle!');
    if pcOracle <> nil then pcOracle.ActivePage := tsSQLOracle;
  except
    on E: Exception do
    begin
      DynLog(4, 'Erro ao listar tabelas: ' + E.Message, True);
      if pcOracle <> nil then pcOracle.ActivePage := tsLogOracle;
    end;
  end;
  finally
    if frmMNote <> nil then frmMNote.SyncSolutionDatabaseFromMQuery;
  end;
end;

procedure Tfrmmquery2.ListarTabelasMSSQL();
var
  tvItem, tvColunas: TTreeNode;
  SchemaNome, TabelaNome, ColLine: string;
  colQry: TZQuery;
  QtdTabelas: Integer;
begin
  SchemaNome := Trim(edSchemaMSSQL.Text);
  if SchemaNome = '' then SchemaNome := 'dbo';

  posicaofieldsMSSQL.DeleteChildren;
  QtdTabelas := 0;

  zmssqlqry.Close;
  zmssqlqry.SQL.Text :=
    'SELECT TABLE_SCHEMA, TABLE_NAME '+
    'FROM INFORMATION_SCHEMA.TABLES '+
    'WHERE TABLE_TYPE = ''BASE TABLE'' '+
    '  AND (LOWER(TABLE_SCHEMA) = LOWER(:schema) OR :schema = '''') '+
    'ORDER BY TABLE_NAME';
  zmssqlqry.ParamByName('schema').AsString := SchemaNome;
  try
    zmssqlqry.Open;
    if zmssqlqry.IsEmpty and (SchemaNome <> '') then
    begin
      zmssqlqry.Close;
      zmssqlqry.SQL.Text :=
        'SELECT TABLE_SCHEMA, TABLE_NAME '+
        'FROM INFORMATION_SCHEMA.TABLES '+
        'WHERE TABLE_TYPE = ''BASE TABLE'' '+
        'ORDER BY TABLE_NAME';
      zmssqlqry.Open;
    end;
  except
    zmssqlqry.Close;
    zmssqlqry.SQL.Text :=
      'SELECT TABLE_SCHEMA, TABLE_NAME '+
      'FROM INFORMATION_SCHEMA.TABLES '+
      'WHERE TABLE_TYPE = ''BASE TABLE'' '+
      'ORDER BY TABLE_NAME';
    zmssqlqry.Open;
  end;

  colQry := TZQuery.Create(Self);
  colQry.Connection := zconMSSQL;
  try
    while not zmssqlqry.EOF do
    begin
      TabelaNome := zmssqlqry.FieldByName('TABLE_NAME').AsString;
      if Trim(TabelaNome) <> '' then
      begin
        Inc(QtdTabelas);
        tvItem := tvMSSQL.Items.AddChildObject(posicaofieldsMSSQL, TabelaNome, Pointer(nil));
        tvItem.ImageIndex := 14;

        try
          colQry.Close;
          colQry.SQL.Text :=
            'SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT '+
            'FROM INFORMATION_SCHEMA.COLUMNS '+
            'WHERE TABLE_NAME = :table '+
            'ORDER BY ORDINAL_POSITION';
          colQry.ParamByName('table').AsString := TabelaNome;
          colQry.Open;

          tvColunas := tvMSSQL.Items.AddChildObject(tvItem, 'fields', Pointer(ETDBCampos));
          tvColunas.ImageIndex := 16;

          while not colQry.EOF do
          begin
            ColLine := colQry.FieldByName('COLUMN_NAME').AsString + ' : ' +
                       colQry.FieldByName('DATA_TYPE').AsString;
            if colQry.FieldByName('IS_NULLABLE').AsString = 'NO' then
              ColLine := ColLine + ' NOT NULL';
            if not colQry.FieldByName('COLUMN_DEFAULT').IsNull then
              ColLine := ColLine + ' DEFAULT ' + colQry.FieldByName('COLUMN_DEFAULT').AsString;

            tvMSSQL.Items.AddChildObject(tvColunas, ColLine, Pointer(0));
            colQry.Next;
          end;
        except
          on E: Exception do
            RegistraEventosLog('ListarTabelasMSSQL: falha ao ler colunas: ' + E.Message);
        end;
      end;
      zmssqlqry.Next;
    end;
  finally
    colQry.Free;
    posicaofieldsMSSQL.Expanded := True;
    if posicaofieldsMSSQL.Parent <> nil then
      posicaofieldsMSSQL.Parent.Expanded := True;
    tvMSSQL.FullExpand;
    AtualizarAutocomplete(3);
    DynLog(3, Format('SQL Server: %d tabelas carregadas.', [QtdTabelas]));
  end;
end;

procedure Tfrmmquery2.ListarTabelasOracle();
var
  tvItem, tvColunas: TTreeNode;
  Dono, TabelaNome, ColLine: string;
  colQry: TZQuery;
  QtdTabelas, Idx: Integer;
  Campos: TStringList;   // tabela -> no "fields" (o pai e o no da tabela)

  // Le um grupo (PK, FK, indices ou triggers) do schema inteiro em uma
  // consulta e pendura um no por tabela. A consulta deve trazer TABLE_NAME,
  // OBJ_NAME e, conforme o modo, COL_NAME, R_OWNER/R_TABLE/R_COLUMN,
  // UNIQUENESS ou EXTRA. Ordem: TABLE_NAME, OBJ_NAME, posicao.
  // AModo: 0 PK, 1 FK, 2 indice, 3 trigger.
  procedure CarregaGrupo(const ASQL, ATitulo: string; ADado: Pointer;
    AImgGrupo, AImgItem, AModo: Integer);
  var
    Q: TZQuery;
    Tab, Nome, TabAtual, NomeAtual, Cols, RCols, Extra: string;
    Grupo: TTreeNode;

    procedure Emite;
    var
      K: Integer;
      Linha: string;
      N: TTreeNode;
    begin
      if NomeAtual = '' then Exit;
      if not Campos.Find(TabAtual, K) then Exit;
      if Grupo = nil then
      begin
        Grupo := tvOracle.Items.AddChildObject(TTreeNode(Campos.Objects[K]).Parent,
          ATitulo, ADado);
        Grupo.ImageIndex := AImgGrupo;
      end;
      case AModo of
        1: Linha := NomeAtual + ' (' + Cols + ') → ' + Extra + '(' + RCols + ')';
        2: Linha := NomeAtual + ' (' + Cols + ')' + Extra;
        3: Linha := NomeAtual + ' - ' + Extra;
      else
        Linha := NomeAtual + ' (' + Cols + ')';
      end;
      N := tvOracle.Items.AddChildObject(Grupo, Linha, Pointer(0));
      N.ImageIndex := AImgItem;
    end;

  begin
    Q := TZQuery.Create(nil);
    try
      try
        Q.Connection := zconOracle;
        Q.SQL.Text := ASQL;
        Q.ParamByName('p_owner').AsString := Dono;
        Q.Open;
        TabAtual := '';
        NomeAtual := '';
        Cols := '';
        RCols := '';
        Extra := '';
        Grupo := nil;
        while not Q.EOF do
        begin
          Tab := Q.FieldByName('TABLE_NAME').AsString;
          Nome := Q.FieldByName('OBJ_NAME').AsString;
          if (Tab <> TabAtual) or (Nome <> NomeAtual) then
          begin
            Emite;
            if Tab <> TabAtual then
              Grupo := nil;
            TabAtual := Tab;
            NomeAtual := Nome;
            Cols := '';
            RCols := '';
            Extra := '';
          end;
          case AModo of
            1:
              begin
                Extra := Q.FieldByName('R_OWNER').AsString + '.' +
                         Q.FieldByName('R_TABLE').AsString;
                if RCols <> '' then RCols := RCols + ', ';
                RCols := RCols + Q.FieldByName('R_COLUMN').AsString;
              end;
            2:
              if Q.FieldByName('UNIQUENESS').AsString = 'UNIQUE' then
                Extra := ' UNIQUE'
              else
                Extra := '';
            3:
              Extra := Q.FieldByName('EXTRA').AsString;
          end;
          if AModo <> 3 then
          begin
            if Cols <> '' then Cols := Cols + ', ';
            Cols := Cols + Q.FieldByName('COL_NAME').AsString;
          end;
          Q.Next;
        end;
        Emite;
      except
        on E: Exception do
          DynLog(4, 'Oracle (' + ATitulo + '): ' + E.Message, True);
      end;
    finally
      Q.Free;
    end;
  end;

begin
  // Dono das tabelas: schema informado ou, na falta dele, o proprio usuario.
  // Parametros nao podem ter nome reservado do Oracle (TABLE, USER...):
  // isso gera ORA-01745. Por isso :p_owner.
  FOracleOwner := '';
  Dono := OracleOwner;

  posicaofieldsOracle.DeleteChildren;
  QtdTabelas := 0;
  Campos := TStringList.Create;
  Campos.CaseSensitive := True;
  Campos.Sorted := True;
  Campos.Duplicates := dupIgnore;
  colQry := TZQuery.Create(Self);
  colQry.Connection := zconOracle;
  tvOracle.Items.BeginUpdate;
  try
    try
      zoracleqry.Close;
      zoracleqry.SQL.Text :=
        'SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER = :p_owner ' +
        // SECONDARY = 'Y': tabelas internas de indices de dominio (DR$..., Oracle Text);
        // DROPPED = 'YES': lixeira (BIN$...)
        '  AND SECONDARY = ''N'' AND DROPPED = ''NO'' ORDER BY TABLE_NAME';
      zoracleqry.ParamByName('p_owner').AsString := Dono;
      zoracleqry.Open;
      if zoracleqry.IsEmpty then
      begin
        DynLog(4, 'Nenhuma tabela visível no schema "' + Dono +
          '". Usando as tabelas do próprio usuário. Se as tabelas pertencem ' +
          'a outro schema, informe-o no campo Schema.');
        zoracleqry.Close;
        zoracleqry.SQL.Text :=
          'SELECT USER AS DONO, TABLE_NAME FROM USER_TABLES ' +
          'WHERE SECONDARY = ''N'' AND DROPPED = ''NO'' ORDER BY TABLE_NAME';
        zoracleqry.Open;
        if not zoracleqry.IsEmpty then
          Dono := zoracleqry.FieldByName('DONO').AsString;
      end;

      while not zoracleqry.EOF do
      begin
        TabelaNome := zoracleqry.FieldByName('TABLE_NAME').AsString;
        if Trim(TabelaNome) <> '' then
        begin
          Inc(QtdTabelas);
          tvItem := tvOracle.Items.AddChildObject(posicaofieldsOracle, TabelaNome, Pointer(nil));
          tvItem.ImageIndex := 14;
          tvColunas := tvOracle.Items.AddChildObject(tvItem, 'fields', Pointer(ETDBCampos));
          tvColunas.ImageIndex := 16;
          Campos.AddObject(TabelaNome, tvColunas);
        end;
        zoracleqry.Next;
      end;
      zoracleqry.Close;

      // Colunas de todas as tabelas em uma unica consulta (antes: uma por tabela)
      colQry.SQL.Text :=
        'SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, NULLABLE ' +
        'FROM ALL_TAB_COLUMNS WHERE OWNER = :p_owner ' +
        'ORDER BY TABLE_NAME, COLUMN_ID';
      colQry.ParamByName('p_owner').AsString := Dono;
      colQry.Open;
      while not colQry.EOF do
      begin
        if Campos.Find(colQry.FieldByName('TABLE_NAME').AsString, Idx) then
        begin
          ColLine := colQry.FieldByName('COLUMN_NAME').AsString + ' : ' +
                     colQry.FieldByName('DATA_TYPE').AsString;
          if colQry.FieldByName('NULLABLE').AsString = 'N' then
            ColLine := ColLine + ' NOT NULL';
          tvOracle.Items.AddChildObject(TTreeNode(Campos.Objects[Idx]), ColLine, Pointer(0));
        end;
        colQry.Next;
      end;
      colQry.Close;
    except
      on E: Exception do
        DynLog(4, 'Erro ao listar tabelas do Oracle: ' + E.Message, True);
    end;

    if Campos.Count > 0 then
    begin
      // Chave primaria: mesmo formato das outras arvores ("NOME (COL1, COL2)"),
      // usado tambem pelos scripts UPDATE/DELETE para montar o WHERE.
      CarregaGrupo(
        'SELECT c.TABLE_NAME, c.CONSTRAINT_NAME AS OBJ_NAME, cc.COLUMN_NAME AS COL_NAME ' +
        'FROM ALL_CONSTRAINTS c ' +
        'JOIN ALL_CONS_COLUMNS cc ON cc.OWNER = c.OWNER ' +
        '  AND cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME AND cc.TABLE_NAME = c.TABLE_NAME ' +
        'WHERE c.OWNER = :p_owner AND c.CONSTRAINT_TYPE = ''P'' ' +
        'ORDER BY c.TABLE_NAME, c.CONSTRAINT_NAME, cc.POSITION',
        'Primary Key', Pointer(ETDBPK), 17, 18, 0);

      CarregaGrupo(
        'SELECT c.TABLE_NAME, c.CONSTRAINT_NAME AS OBJ_NAME, cc.COLUMN_NAME AS COL_NAME, ' +
        '       rc.OWNER AS R_OWNER, rc.TABLE_NAME AS R_TABLE, rcc.COLUMN_NAME AS R_COLUMN ' +
        'FROM ALL_CONSTRAINTS c ' +
        'JOIN ALL_CONS_COLUMNS cc ON cc.OWNER = c.OWNER ' +
        '  AND cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME AND cc.TABLE_NAME = c.TABLE_NAME ' +
        'JOIN ALL_CONSTRAINTS rc ON rc.OWNER = c.R_OWNER ' +
        '  AND rc.CONSTRAINT_NAME = c.R_CONSTRAINT_NAME ' +
        'JOIN ALL_CONS_COLUMNS rcc ON rcc.OWNER = rc.OWNER ' +
        '  AND rcc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME AND rcc.POSITION = cc.POSITION ' +
        'WHERE c.OWNER = :p_owner AND c.CONSTRAINT_TYPE = ''R'' ' +
        'ORDER BY c.TABLE_NAME, c.CONSTRAINT_NAME, cc.POSITION',
        'Chave Estrangeira', Pointer(ETDBFK), 17, 18, 1);

      CarregaGrupo(
        'SELECT i.TABLE_NAME, i.INDEX_NAME AS OBJ_NAME, ic.COLUMN_NAME AS COL_NAME, ' +
        '       i.UNIQUENESS ' +
        'FROM ALL_INDEXES i ' +
        'JOIN ALL_IND_COLUMNS ic ON ic.INDEX_OWNER = i.OWNER ' +
        '  AND ic.INDEX_NAME = i.INDEX_NAME ' +
        'WHERE i.TABLE_OWNER = :p_owner ' +
        'ORDER BY i.TABLE_NAME, i.INDEX_NAME, ic.COLUMN_POSITION',
        'Índices', Pointer(nil), 17, 18, 2);

      CarregaGrupo(
        'SELECT TABLE_NAME, TRIGGER_NAME AS OBJ_NAME, ' +
        '       TRIGGERING_EVENT || '' ('' || STATUS || '')'' AS EXTRA ' +
        'FROM ALL_TRIGGERS ' +
        'WHERE TABLE_OWNER = :p_owner AND BASE_OBJECT_TYPE = ''TABLE'' ' +
        'ORDER BY TABLE_NAME, TRIGGER_NAME',
        'Triggers', Pointer(ETDTriggers), 17, 18, 3);
    end;
  finally
    tvOracle.Items.EndUpdate;
    colQry.Free;
    Campos.Free;
    posicaofieldsOracle.Expanded := True;
    if posicaofieldsOracle.Parent <> nil then
      posicaofieldsOracle.Parent.Expanded := True;
    FOracleOwner := Dono;
    AtualizarAutocomplete(4);
    DynLog(4, Format('Oracle: %d tabelas carregadas do schema %s.', [QtdTabelas, Dono]));
  end;
end;

procedure Tfrmmquery2.tvMSSQLChange(Sender: TObject; Node: TTreeNode);
begin
  if Node = tvitemMSSQL then
    tvMSSQL.PopupMenu := pmDatabaseMSSQL
  else if (Node <> nil) and (Node.Parent = posicaofieldsMSSQL) then
    tvMSSQL.PopupMenu := pmTabelaMSSQL
  else
    tvMSSQL.PopupMenu := nil;
end;

procedure Tfrmmquery2.tvOracleChange(Sender: TObject; Node: TTreeNode);
begin
  if Node = tvitemOracle then
    tvOracle.PopupMenu := pmDatabaseOracle
  else if (Node <> nil) and (Node.Parent = posicaofieldsOracle) then
    tvOracle.PopupMenu := pmTabelaOracle
  else
    tvOracle.PopupMenu := nil;
end;

procedure Tfrmmquery2.mnCriaDicionarioMSSQLClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  if not zconMSSQL.Connected then
  begin
    ShowMessage('SQL Server não conectado!');
    Exit;
  end;

  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario_mssql.sql';

  edSQLMSSQL.Text := CriaDicionarioMSSQL(fileName);
  pgMain.ActivePage := tsMSSQL;
  if pcMSSQL <> nil then pcMSSQL.ActivePage := tsSQLMSSQL;

  ShowMessage('Dicionário SQL Server salvo em:' + LineEnding + fileName);
end;

procedure Tfrmmquery2.mnCriaDicionarioOracleClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  if not zconOracle.Connected then
  begin
    ShowMessage('Oracle não conectado!');
    Exit;
  end;

  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario_oracle.sql';

  edSQLOracle.Text := CriaDicionarioOracle(fileName);
  pgMain.ActivePage := tsOracle;
  if pcOracle <> nil then pcOracle.ActivePage := tsSQLOracle;

  ShowMessage('Dicionário Oracle salvo em:' + LineEnding + fileName);
end;

function Tfrmmquery2.CriaDicionarioMSSQL(const ATargetFile: string): string;
var
  outSQL        : TStringList;
  schema        : string;
  tblNode       : TTreeNode;
  tblName       : string;
  targetAbsPath : string;
  targetDir     : string;
  sqlCreate     : string;

  function QIdent(const S: string): string;
  begin
    Result := '[' + StringReplace(S, ']', ']]', [rfReplaceAll]) + ']';
  end;

  function BuildColumnsSQL(const ASchema, ATable: string): TStringList;
  var
    qry: TZQuery;
    line, colname, dtype, defval: string;
    charlen: Integer;
    isnull: Boolean;
  begin
    Result := TStringList.Create;
    qry := TZQuery.Create(nil);
    try
      qry.Connection := zconMSSQL;
      qry.SQL.Text :=
        'SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_DEFAULT ' +
        'FROM INFORMATION_SCHEMA.COLUMNS ' +
        'WHERE TABLE_SCHEMA = :schema ' +
        '  AND TABLE_NAME = :table ' +
        'ORDER BY ORDINAL_POSITION';
      qry.ParamByName('schema').AsString := ASchema;
      qry.ParamByName('table').AsString  := ATable;
      qry.Open;

      while not qry.EOF do
      begin
        colname := qry.FieldByName('COLUMN_NAME').AsString;
        dtype   := qry.FieldByName('DATA_TYPE').AsString;
        isnull  := qry.FieldByName('IS_NULLABLE').AsString = 'YES';

        line := '  ' + QIdent(colname) + ' ' + dtype;

        if not qry.FieldByName('CHARACTER_MAXIMUM_LENGTH').IsNull then
        begin
          charlen := qry.FieldByName('CHARACTER_MAXIMUM_LENGTH').AsInteger;
          if charlen = -1 then
            line := line + '(MAX)'
          else if (dtype = 'varchar') or (dtype = 'nvarchar') or (dtype = 'char') or (dtype = 'nchar') then
            line := line + '(' + IntToStr(charlen) + ')';
        end;

        if not isnull then
          line := line + ' NOT NULL'
        else
          line := line + ' NULL';

        if not qry.FieldByName('COLUMN_DEFAULT').IsNull then
        begin
          defval := Trim(qry.FieldByName('COLUMN_DEFAULT').AsString);
          if defval <> '' then
            line := line + ' DEFAULT ' + defval;
        end;

        Result.Add(line);
        qry.Next;
      end;
    finally
      qry.Free;
    end;
  end;

  function BuildPKSQL(const ASchema, ATable: string): TStringList;
  var
    qry: TZQuery;
    constraintName, cols, col: string;
  begin
    Result := TStringList.Create;
    qry := TZQuery.Create(nil);
    try
      qry.Connection := zconMSSQL;
      qry.SQL.Text :=
        'SELECT tc.CONSTRAINT_NAME, kcu.COLUMN_NAME ' +
        'FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc ' +
        'JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS kcu ' +
        '  ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME ' +
        '  AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA ' +
        '  AND tc.TABLE_NAME = kcu.TABLE_NAME ' +
        'WHERE tc.CONSTRAINT_TYPE = ''PRIMARY KEY'' ' +
        '  AND tc.TABLE_SCHEMA = :schema ' +
        '  AND tc.TABLE_NAME = :table ' +
        'ORDER BY kcu.ORDINAL_POSITION';
      qry.ParamByName('schema').AsString := ASchema;
      qry.ParamByName('table').AsString  := ATable;
      qry.Open;

      constraintName := '';
      cols := '';
      while not qry.EOF do
      begin
        constraintName := qry.FieldByName('CONSTRAINT_NAME').AsString;
        col := qry.FieldByName('COLUMN_NAME').AsString;
        if cols <> '' then cols := cols + ', ';
        cols := cols + QIdent(col);
        qry.Next;
      end;

      if constraintName <> '' then
      begin
        Result.Add(
          'ALTER TABLE ' + QIdent(ASchema) + '.' + QIdent(ATable) +
          ' ADD CONSTRAINT ' + QIdent(constraintName) +
          ' PRIMARY KEY (' + cols + ');'
        );
      end;
    finally
      qry.Free;
    end;
  end;

  function BuildFKSQL(const ASchema, ATable: string): TStringList;
  var
    qry: TZQuery;
    constraintName, lastConstraint, parentCols, refCols, refTable: string;
    col, refCol: string;
  begin
    Result := TStringList.Create;
    qry := TZQuery.Create(nil);
    try
      qry.Connection := zconMSSQL;
      qry.SQL.Text :=
        'SELECT fk.name AS constraint_name, c1.name AS column_name, ' +
        '       t2.name AS referenced_table, c2.name AS referenced_column ' +
        'FROM sys.foreign_keys fk ' +
        'INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id ' +
        'INNER JOIN sys.tables t1 ON fkc.parent_object_id = t1.object_id ' +
        'INNER JOIN sys.columns c1 ON fkc.parent_object_id = c1.object_id AND fkc.parent_column_id = c1.column_id ' +
        'INNER JOIN sys.tables t2 ON fkc.referenced_object_id = t2.object_id ' +
        'INNER JOIN sys.columns c2 ON fkc.referenced_object_id = c2.object_id AND fkc.referenced_column_id = c2.column_id ' +
        'WHERE t1.name = :table ' +
        '  AND SCHEMA_NAME(t1.schema_id) = :schema ' +
        'ORDER BY fk.name, fkc.constraint_column_id';
      qry.ParamByName('schema').AsString := ASchema;
      qry.ParamByName('table').AsString  := ATable;
      qry.Open;

      lastConstraint := '';
      parentCols := '';
      refCols := '';
      refTable := '';

      while not qry.EOF do
      begin
        constraintName := qry.FieldByName('constraint_name').AsString;
        col := qry.FieldByName('column_name').AsString;
        refTable := qry.FieldByName('referenced_table').AsString;
        refCol := qry.FieldByName('referenced_column').AsString;

        if (lastConstraint <> '') and (lastConstraint <> constraintName) then
        begin
          Result.Add(
            'ALTER TABLE ' + QIdent(ASchema) + '.' + QIdent(ATable) +
            ' ADD CONSTRAINT ' + QIdent(lastConstraint) +
            ' FOREIGN KEY (' + parentCols + ') REFERENCES ' + QIdent(ASchema) + '.' + QIdent(refTable) + ' (' + refCols + ');'
          );
          parentCols := '';
          refCols := '';
        end;

        lastConstraint := constraintName;
        if parentCols <> '' then parentCols := parentCols + ', ';
        parentCols := parentCols + QIdent(col);
        if refCols <> '' then refCols := refCols + ', ';
        refCols := refCols + QIdent(refCol);

        qry.Next;
      end;

      if lastConstraint <> '' then
      begin
        Result.Add(
          'ALTER TABLE ' + QIdent(ASchema) + '.' + QIdent(ATable) +
          ' ADD CONSTRAINT ' + QIdent(lastConstraint) +
          ' FOREIGN KEY (' + parentCols + ') REFERENCES ' + QIdent(ASchema) + '.' + QIdent(refTable) + ' (' + refCols + ');'
        );
      end;
    finally
      qry.Free;
    end;
  end;

  function BuildCreateTableSQL(const ASchema, ATable: string): string;
  var
    cols, pks, fks: TStringList;
    i: Integer;
  begin
    cols := nil; pks := nil; fks := nil;
    try
      cols := BuildColumnsSQL(ASchema, ATable);
      pks  := BuildPKSQL(ASchema, ATable);
      fks  := BuildFKSQL(ASchema, ATable);

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
    finally
      cols.Free;
      pks.Free;
      fks.Free;
    end;
  end;

begin
  Result := '';

  if (dmBase = nil) then
    dmBase := TdmBase.Create(Self);
  dmBase.DeleteTabelas;

  if not zconMSSQL.Connected then
  begin
    ShowMessage('SQL Server não conectado.');
    Exit;
  end;

  if (posicaofieldsMSSQL = nil) or (posicaofieldsMSSQL.GetFirstChild = nil) then
  begin
    ShowMessage('Nenhuma tabela encontrada no SQL Server.');
    Exit;
  end;

  schema := Trim(edSchemaMSSQL.Text);
  if schema = '' then schema := 'dbo';

  outSQL := TStringList.Create;
  try
    outSQL.Add('-- =========================================');
    outSQL.Add('-- Dicionário de dados gerado pelo MQuery2');
    outSQL.Add('-- ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    outSQL.Add('-- Database: ' + Trim(edBancoMSSQL.Text) + ' | Schema: ' + schema);
    outSQL.Add('-- =========================================');
    outSQL.Add('');

    tblNode := posicaofieldsMSSQL.GetFirstChild;
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
      DynLog(3, 'Dicionário gerado em: ' + targetAbsPath);
    end;

    Result := outSQL.Text;
  finally
    outSQL.Free;
  end;
end;

function Tfrmmquery2.CriaDicionarioOracle(const ATargetFile: string): string;
var
  outSQL        : TStringList;
  Cols, PKs, FKs, Idxs, TabCom, ColCom: TStringList;  // tabela -> TStringList (linhas)
  qry           : TZQuery;
  schema        : string;
  tblNode       : TTreeNode;
  tblName       : string;
  targetAbsPath : string;
  targetDir     : string;
  sqlCreate     : string;
  Erros         : Integer;

  function QIdent(const S: string): string;
  begin
    Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"';
  end;

  function NovoMapa: TStringList;
  begin
    Result := TStringList.Create;
    Result.CaseSensitive := True;
    Result.Sorted := True;
    Result.OwnsObjects := True;
  end;

  function Lista(AMap: TStringList; const ATabela: string): TStringList;
  var
    Idx: Integer;
  begin
    if not AMap.Find(ATabela, Idx) then
      Idx := AMap.AddObject(ATabela, TStringList.Create);
    Result := TStringList(AMap.Objects[Idx]);
  end;

  function Busca(AMap: TStringList; const ATabela: string): TStringList;
  var
    Idx: Integer;
  begin
    if AMap.Find(ATabela, Idx) then
      Result := TStringList(AMap.Objects[Idx])
    else
      Result := nil;
  end;

  function IntOuNulo(const ACampo: string): Integer;
  begin
    if qry.FieldByName(ACampo).IsNull then
      Result := -1
    else
      Result := qry.FieldByName(ACampo).AsInteger;
  end;

  // Uma consulta por tipo de informacao para o schema inteiro (antes eram
  // tres consultas por tabela). Parametro :p_owner: TABLE e palavra
  // reservada do Oracle e causava ORA-01745.
  procedure LerColunas;
  var
    line, defval: string;
  begin
    qry.Close;
    qry.SQL.Text :=
      'SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_LENGTH, CHAR_LENGTH, ' +
      '       CHAR_USED, DATA_PRECISION, DATA_SCALE, NULLABLE, DATA_DEFAULT ' +
      'FROM ALL_TAB_COLUMNS ' +
      'WHERE OWNER = :p_owner ' +
      'ORDER BY TABLE_NAME, COLUMN_ID';
    qry.ParamByName('p_owner').AsString := schema;
    qry.Open;
    while not qry.EOF do
    begin
      line := '  ' + QIdent(qry.FieldByName('COLUMN_NAME').AsString) + ' ' +
        OracleColumnTypeSQL(qry.FieldByName('DATA_TYPE').AsString,
          Max(0, IntOuNulo('DATA_LENGTH')), Max(0, IntOuNulo('CHAR_LENGTH')),
          qry.FieldByName('CHAR_USED').AsString,
          IntOuNulo('DATA_PRECISION'), IntOuNulo('DATA_SCALE'));
      if not qry.FieldByName('DATA_DEFAULT').IsNull then
      begin
        defval := Trim(qry.FieldByName('DATA_DEFAULT').AsString);
        if defval <> '' then
          line := line + ' DEFAULT ' + defval;
      end;
      if qry.FieldByName('NULLABLE').AsString = 'N' then
        line := line + ' NOT NULL';
      Lista(Cols, qry.FieldByName('TABLE_NAME').AsString).Add(
        qry.FieldByName('COLUMN_NAME').AsString + #9 + line);
      qry.Next;
    end;
    qry.Close;
  end;

  procedure LerPKs;
  begin
    qry.Close;
    qry.SQL.Text :=
      'SELECT c.TABLE_NAME, c.CONSTRAINT_NAME, cc.COLUMN_NAME ' +
      'FROM ALL_CONSTRAINTS c ' +
      'JOIN ALL_CONS_COLUMNS cc ON cc.OWNER = c.OWNER ' +
      '  AND cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME AND cc.TABLE_NAME = c.TABLE_NAME ' +
      'WHERE c.OWNER = :p_owner AND c.CONSTRAINT_TYPE = ''P'' ' +
      'ORDER BY c.TABLE_NAME, cc.POSITION';
    qry.ParamByName('p_owner').AsString := schema;
    qry.Open;
    while not qry.EOF do
    begin
      Lista(PKs, qry.FieldByName('TABLE_NAME').AsString).Add(
        qry.FieldByName('CONSTRAINT_NAME').AsString + #9 +
        qry.FieldByName('COLUMN_NAME').AsString);
      qry.Next;
    end;
    qry.Close;
  end;

  procedure LerFKs;
  begin
    qry.Close;
    qry.SQL.Text :=
      'SELECT c.TABLE_NAME, c.CONSTRAINT_NAME, cc.COLUMN_NAME, ' +
      '       rc.OWNER AS R_OWNER, rc.TABLE_NAME AS R_TABLE, rcc.COLUMN_NAME AS R_COLUMN ' +
      'FROM ALL_CONSTRAINTS c ' +
      'JOIN ALL_CONS_COLUMNS cc ON cc.OWNER = c.OWNER ' +
      '  AND cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME AND cc.TABLE_NAME = c.TABLE_NAME ' +
      'JOIN ALL_CONSTRAINTS rc ON rc.OWNER = c.R_OWNER ' +
      '  AND rc.CONSTRAINT_NAME = c.R_CONSTRAINT_NAME ' +
      'JOIN ALL_CONS_COLUMNS rcc ON rcc.OWNER = rc.OWNER ' +
      '  AND rcc.CONSTRAINT_NAME = rc.CONSTRAINT_NAME AND rcc.POSITION = cc.POSITION ' +
      'WHERE c.OWNER = :p_owner AND c.CONSTRAINT_TYPE = ''R'' ' +
      'ORDER BY c.TABLE_NAME, c.CONSTRAINT_NAME, cc.POSITION';
    qry.ParamByName('p_owner').AsString := schema;
    qry.Open;
    while not qry.EOF do
    begin
      Lista(FKs, qry.FieldByName('TABLE_NAME').AsString).Add(
        qry.FieldByName('CONSTRAINT_NAME').AsString + #9 +
        qry.FieldByName('COLUMN_NAME').AsString + #9 +
        qry.FieldByName('R_OWNER').AsString + #9 +
        qry.FieldByName('R_TABLE').AsString + #9 +
        qry.FieldByName('R_COLUMN').AsString);
      qry.Next;
    end;
    qry.Close;
  end;

  // Descricoes (COMMENT ON) da tabela e das colunas
  procedure LerComentarios;
  begin
    qry.Close;
    qry.SQL.Text :=
      'SELECT TABLE_NAME, COMMENTS FROM ALL_TAB_COMMENTS ' +
      'WHERE OWNER = :p_owner AND COMMENTS IS NOT NULL';
    qry.ParamByName('p_owner').AsString := schema;
    qry.Open;
    while not qry.EOF do
    begin
      Lista(TabCom, qry.FieldByName('TABLE_NAME').AsString).Add(
        qry.FieldByName('COMMENTS').AsString);
      qry.Next;
    end;
    qry.Close;

    qry.SQL.Text :=
      'SELECT TABLE_NAME, COLUMN_NAME, COMMENTS FROM ALL_COL_COMMENTS ' +
      'WHERE OWNER = :p_owner AND COMMENTS IS NOT NULL';
    qry.ParamByName('p_owner').AsString := schema;
    qry.Open;
    while not qry.EOF do
    begin
      Lista(ColCom, qry.FieldByName('TABLE_NAME').AsString).Add(
        qry.FieldByName('COLUMN_NAME').AsString + #9 +
        qry.FieldByName('COMMENTS').AsString);
      qry.Next;
    end;
    qry.Close;
  end;

  // Descricao de uma coluna (texto completo) ou '' se nao houver
  function DescricaoColuna(const ATabela, AColuna: string): string;
  var
    L: TStringList;
    i, P: Integer;
  begin
    Result := '';
    L := Busca(ColCom, ATabela);
    if L = nil then Exit;
    for i := 0 to L.Count - 1 do
    begin
      P := Pos(#9, L[i]);
      if (P > 0) and (Copy(L[i], 1, P - 1) = AColuna) then
        Exit(Copy(L[i], P + 1, MaxInt));
    end;
  end;

  function UmaLinha(const S: string): string;
  begin
    Result := Trim(StringReplace(StringReplace(S, #13, ' ', [rfReplaceAll]),
      #10, ' ', [rfReplaceAll]));
  end;

  // Indices que nao sustentam PK/UK (esses ja saem como constraint)
  procedure LerIndices;
  begin
    qry.Close;
    qry.SQL.Text :=
      'SELECT i.TABLE_NAME, i.INDEX_NAME, i.INDEX_TYPE, i.UNIQUENESS, ' +
      '       ic.COLUMN_NAME, ic.DESCEND ' +
      'FROM ALL_INDEXES i ' +
      'JOIN ALL_IND_COLUMNS ic ON ic.INDEX_OWNER = i.OWNER AND ic.INDEX_NAME = i.INDEX_NAME ' +
      'WHERE i.TABLE_OWNER = :p_owner ' +
      '  AND NOT EXISTS (SELECT 1 FROM ALL_CONSTRAINTS k ' +
      '                  WHERE k.OWNER = i.TABLE_OWNER AND k.INDEX_NAME = i.INDEX_NAME ' +
      '                    AND k.CONSTRAINT_TYPE IN (''P'', ''U'')) ' +
      'ORDER BY i.TABLE_NAME, i.INDEX_NAME, ic.COLUMN_POSITION';
    qry.ParamByName('p_owner').AsString := schema;
    qry.Open;
    while not qry.EOF do
    begin
      Lista(Idxs, qry.FieldByName('TABLE_NAME').AsString).Add(
        qry.FieldByName('INDEX_NAME').AsString + #9 +
        qry.FieldByName('INDEX_TYPE').AsString + #9 +
        qry.FieldByName('UNIQUENESS').AsString + #9 +
        qry.FieldByName('COLUMN_NAME').AsString + #9 +
        qry.FieldByName('DESCEND').AsString);
      qry.Next;
    end;
    qry.Close;
  end;

  function MontaIndices(const ATabela: string): string;
  var
    L: TStringList;
    i: Integer;
    S, nome, atual, tipo, unico, cols, col: string;

    procedure Fecha;
    begin
      if atual = '' then Exit;
      if Pos('DOMAIN', tipo) > 0 then
        S := S + '-- Índice de domínio ' + atual + ' (' + cols + '): tipo ' + tipo +
          ', recriar manualmente (ex.: Oracle Text).' + sLineBreak
      else if Pos('FUNCTION', tipo) > 0 then
        S := S + '-- Índice baseado em função ' + atual + ' (' + cols + '): ' +
          'a expressão não é exportada.' + sLineBreak
      else
      begin
        S := S + 'CREATE ';
        if unico = 'UNIQUE' then
          S := S + 'UNIQUE '
        else if Pos('BITMAP', tipo) > 0 then
          S := S + 'BITMAP ';
        S := S + 'INDEX ' + QIdent(schema) + '.' + QIdent(atual) + ' ON ' +
          QIdent(schema) + '.' + QIdent(ATabela) + ' (' + cols + ');' + sLineBreak;
      end;
    end;

  begin
    Result := '';
    L := Busca(Idxs, ATabela);
    if (L = nil) or (L.Count = 0) then Exit;
    S := '';
    atual := '';
    cols := '';
    for i := 0 to L.Count - 1 do
    begin
      nome := ExtractDelimited(1, L[i], [#9]);
      if nome <> atual then
      begin
        Fecha;
        atual := nome;
        tipo := UpperCase(ExtractDelimited(2, L[i], [#9]));
        unico := UpperCase(ExtractDelimited(3, L[i], [#9]));
        cols := '';
      end;
      col := QIdent(ExtractDelimited(4, L[i], [#9]));
      if SameText(ExtractDelimited(5, L[i], [#9]), 'DESC') then
        col := col + ' DESC';
      if cols <> '' then cols := cols + ', ';
      cols := cols + col;
    end;
    Fecha;
    Result := S;
  end;

  function MontaPK(const ATabela: string): string;
  var
    L: TStringList;
    i: Integer;
    cols: string;
  begin
    Result := '';
    L := Busca(PKs, ATabela);
    if (L = nil) or (L.Count = 0) then Exit;
    cols := '';
    for i := 0 to L.Count - 1 do
    begin
      if cols <> '' then cols := cols + ', ';
      cols := cols + QIdent(ExtractDelimited(2, L[i], [#9]));
    end;
    Result := 'ALTER TABLE ' + QIdent(schema) + '.' + QIdent(ATabela) +
      ' ADD CONSTRAINT ' + QIdent(ExtractDelimited(1, L[0], [#9])) +
      ' PRIMARY KEY (' + cols + ');' + sLineBreak;
  end;

  function MontaFKs(const ATabela: string): string;
  var
    L: TStringList;
    i: Integer;
    S, nome, atual, cols, rcols, rdono, rtab: string;
  begin
    Result := '';
    L := Busca(FKs, ATabela);
    if (L = nil) or (L.Count = 0) then Exit;
    S := '';
    atual := '';
    cols := '';
    rcols := '';
    rdono := '';
    rtab := '';
    for i := 0 to L.Count do
    begin
      if i < L.Count then
        nome := ExtractDelimited(1, L[i], [#9])
      else
        nome := '';
      // fecha a FK anterior quando muda o nome (ou no fim da lista)
      if (atual <> '') and (nome <> atual) then
      begin
        S := S + 'ALTER TABLE ' + QIdent(schema) + '.' + QIdent(ATabela) +
          ' ADD CONSTRAINT ' + QIdent(atual) +
          ' FOREIGN KEY (' + cols + ') REFERENCES ' +
          QIdent(rdono) + '.' + QIdent(rtab) + ' (' + rcols + ');' + sLineBreak;
        cols := '';
        rcols := '';
      end;
      if i = L.Count then Break;
      atual := nome;
      rdono := ExtractDelimited(3, L[i], [#9]);
      rtab := ExtractDelimited(4, L[i], [#9]);
      if cols <> '' then cols := cols + ', ';
      cols := cols + QIdent(ExtractDelimited(2, L[i], [#9]));
      if rcols <> '' then rcols := rcols + ', ';
      rcols := rcols + QIdent(ExtractDelimited(5, L[i], [#9]));
    end;
    Result := S;
  end;

  function MontaCreate(const ATabela: string): string;
  var
    L, TC: TStringList;
    i, P: Integer;
    S, Coluna, Linha, Desc, Comentarios: string;
  begin
    S := '';
    TC := Busca(TabCom, ATabela);
    if (TC <> nil) and (TC.Count > 0) then
      S := S + '-- ' + UmaLinha(TC[0]) + sLineBreak;
    S := S + 'CREATE TABLE ' + QIdent(schema) + '.' + QIdent(ATabela) + ' (' + sLineBreak;
    Comentarios := '';
    if (TC <> nil) and (TC.Count > 0) then
      Comentarios := 'COMMENT ON TABLE ' + QIdent(schema) + '.' + QIdent(ATabela) +
        ' IS ' + QuotedStr(TC[0]) + ';' + sLineBreak;
    L := Busca(Cols, ATabela);
    if (L <> nil) and (L.Count > 0) then
    begin
      for i := 0 to L.Count - 1 do
      begin
        P := Pos(#9, L[i]);
        Coluna := Copy(L[i], 1, P - 1);
        Linha := Copy(L[i], P + 1, MaxInt);
        if i < L.Count - 1 then
          Linha := Linha + ',';
        Desc := DescricaoColuna(ATabela, Coluna);
        if Desc <> '' then
        begin
          Linha := Linha + '  -- ' + UmaLinha(Desc);
          Comentarios := Comentarios + 'COMMENT ON COLUMN ' + QIdent(schema) + '.' +
            QIdent(ATabela) + '.' + QIdent(Coluna) + ' IS ' + QuotedStr(Desc) + ';' + sLineBreak;
        end;
        S := S + Linha + sLineBreak;
      end;
    end
    else
      S := S + '  -- colunas não disponíveis para este usuário' + sLineBreak;
    S := S + ');' + sLineBreak;
    Result := S + MontaPK(ATabela) + MontaFKs(ATabela) + MontaIndices(ATabela) + Comentarios;
  end;

begin
  Result := '';

  if (dmBase = nil) then
    dmBase := TdmBase.Create(Self);
  dmBase.DeleteTabelas;

  if not zconOracle.Connected then
  begin
    ShowMessage('Oracle não conectado.');
    Exit;
  end;

  if (posicaofieldsOracle = nil) or (posicaofieldsOracle.GetFirstChild = nil) then
  begin
    ShowMessage('Nenhuma tabela encontrada no Oracle.');
    Exit;
  end;

  schema := OracleOwner;

  Cols := NovoMapa;
  PKs := NovoMapa;
  FKs := NovoMapa;
  Idxs := NovoMapa;
  TabCom := NovoMapa;
  ColCom := NovoMapa;
  qry := TZQuery.Create(nil);
  qry.Connection := zconOracle;
  qry.ParamCheck := True;
  outSQL := TStringList.Create;
  Erros := 0;
  Screen.Cursor := crSQLWait;
  try
    DynLog(4, 'Dicionário Oracle: lendo o schema ' + schema + '...');

    try
      LerColunas;
    except
      on E: Exception do
      begin
        Inc(Erros);
        DynLog(4, 'Dicionário Oracle (colunas): ' + E.Message, True);
      end;
    end;
    try
      LerPKs;
    except
      on E: Exception do
      begin
        Inc(Erros);
        DynLog(4, 'Dicionário Oracle (chaves primárias): ' + E.Message, True);
      end;
    end;
    try
      LerFKs;
    except
      on E: Exception do
      begin
        Inc(Erros);
        DynLog(4, 'Dicionário Oracle (chaves estrangeiras): ' + E.Message, True);
      end;
    end;
    try
      LerIndices;
    except
      on E: Exception do
      begin
        Inc(Erros);
        DynLog(4, 'Dicionário Oracle (índices): ' + E.Message, True);
      end;
    end;
    try
      LerComentarios;
    except
      on E: Exception do
      begin
        Inc(Erros);
        DynLog(4, 'Dicionário Oracle (descrições): ' + E.Message, True);
      end;
    end;

    outSQL.Add('-- =========================================');
    outSQL.Add('-- Dicionário de dados gerado pelo MQuery2');
    outSQL.Add('-- ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    outSQL.Add('-- Database: ' + Trim(edBancoOracle.Text) + ' | Schema: ' + schema);
    outSQL.Add('-- =========================================');
    outSQL.Add('');

    tblNode := posicaofieldsOracle.GetFirstChild;
    while tblNode <> nil do
    begin
      tblName := tblNode.Text;

      outSQL.Add('-- ' + tblName);
      sqlCreate := MontaCreate(tblName);
      outSQL.Add(sqlCreate);
      outSQL.Add('');

      if (FSetMain.Project <> '') then
      begin
        if (dmBase = nil) then
          dmBase := TdmBase.Create(Self);
        dmBase.RegistraTabela(tblName, '', sqlCreate);
      end;

      tblNode := tblNode.GetNextSibling;
    end;

    targetAbsPath := ExpandFileName(ATargetFile);
    targetDir     := ExtractFilePath(targetAbsPath);
    if (ATargetFile <> '') and (targetDir <> '') then
      ForceDirectories(targetDir);

    if (ATargetFile <> '') then
    begin
      outSQL.SaveToFile(targetAbsPath);
      DynLog(4, 'Dicionário gerado em: ' + targetAbsPath);
    end;

    Result := outSQL.Text;
    DynLog(4, Format('Dicionário Oracle: %d tabela(s), %d erro(s).',
      [posicaofieldsOracle.Count, Erros]));
  finally
    Screen.Cursor := crDefault;
    outSQL.Free;
    qry.Free;
    Cols.Free;
    PKs.Free;
    FKs.Free;
    Idxs.Free;
    TabCom.Free;
    ColCom.Free;
  end;

  if Erros > 0 then
    ShowMessage('O dicionário foi gerado, mas houve ' + IntToStr(Erros) +
      ' erro(s) ao ler o catálogo do Oracle. Veja a aba Log.');
end;


function ExtractFieldName(const S: string): string;
var
  P: Integer;
begin
  P := Pos(':', S);
  if P > 0 then
    Result := Trim(Copy(S, 1, P - 1))
  else
    Result := Trim(S);
end;

procedure ExtractPKNames(const S: string; AList: TStrings);
var
  P1, P2: Integer;
  ColsStr, Item: string;
  Parts: TStringList;
  I: Integer;
begin
  if AList = nil then Exit;
  P1 := Pos('(', S);
  P2 := Pos(')', S);
  if (P1 > 0) and (P2 > P1) then
  begin
    ColsStr := Copy(S, P1 + 1, P2 - P1 - 1);
    ColsStr := StringReplace(ColsStr, '{', '', [rfReplaceAll]);
    ColsStr := StringReplace(ColsStr, '}', '', [rfReplaceAll]);
    Parts := TStringList.Create;
    try
      Parts.Delimiter := ',';
      Parts.StrictDelimiter := True;
      Parts.DelimitedText := ColsStr;
      for I := 0 to Parts.Count - 1 do
      begin
        Item := Trim(Parts[I]);
        if (Item <> '') and (AList.IndexOf(Item) < 0) then
          AList.Add(Item);
      end;
    finally
      Parts.Free;
    end;
  end
  else
  begin
    Item := ExtractFieldName(S);
    if (Item <> '') and (AList.IndexOf(Item) < 0) then
      AList.Add(Item);
  end;
end;

function MontarScriptSQL(const ATableName, ATipoScript: string; AColunas, APKs: TStrings): string;
var
  SQLText: string;
  I: Integer;
  ColName: string;
  HasCol: Boolean;
begin
  Result := '';
  if Trim(ATableName) = '' then Exit;

  if SameText(ATipoScript, 'SELECT') then
  begin
    SQLText := 'SELECT' + sLineBreak;
    if (AColunas <> nil) and (AColunas.Count > 0) then
    begin
      for I := 0 to AColunas.Count - 1 do
      begin
        if I < AColunas.Count - 1 then
          SQLText := SQLText + '  ' + AColunas[I] + ',' + sLineBreak
        else
          SQLText := SQLText + '  ' + AColunas[I] + sLineBreak;
      end;
    end
    else
      SQLText := SQLText + '  *' + sLineBreak;

    SQLText := SQLText + 'FROM ' + ATableName + ';' + sLineBreak;
  end
  else if SameText(ATipoScript, 'INSERT') then
  begin
    SQLText := 'INSERT INTO ' + ATableName + ' (' + sLineBreak;
    if (AColunas <> nil) and (AColunas.Count > 0) then
    begin
      for I := 0 to AColunas.Count - 1 do
      begin
        if I < AColunas.Count - 1 then
          SQLText := SQLText + '  ' + AColunas[I] + ',' + sLineBreak
        else
          SQLText := SQLText + '  ' + AColunas[I] + sLineBreak;
      end;
      SQLText := SQLText + ') VALUES (' + sLineBreak;
      for I := 0 to AColunas.Count - 1 do
      begin
        ColName := AColunas[I];
        if (APKs <> nil) and (APKs.IndexOf(ColName) >= 0) then
        begin
          if I < AColunas.Count - 1 then
            SQLText := SQLText + '  1, -- ' + ColName + sLineBreak
          else
            SQLText := SQLText + '  1  -- ' + ColName + sLineBreak;
        end
        else
        begin
          if I < AColunas.Count - 1 then
            SQLText := SQLText + '  ' + QuotedStr('valor_' + ColName) + ',' + sLineBreak
          else
            SQLText := SQLText + '  ' + QuotedStr('valor_' + ColName) + sLineBreak;
        end;
      end;
      SQLText := SQLText + ');' + sLineBreak;
    end
    else
      SQLText := SQLText + '  /* colunas */' + sLineBreak + ') VALUES (' + sLineBreak + '  /* valores */' + sLineBreak + ');' + sLineBreak;
  end
  else if SameText(ATipoScript, 'UPDATE') then
  begin
    SQLText := 'UPDATE ' + ATableName + sLineBreak + 'SET' + sLineBreak;
    HasCol := False;
    if (AColunas <> nil) and (AColunas.Count > 0) then
    begin
      for I := 0 to AColunas.Count - 1 do
      begin
        ColName := AColunas[I];
        if (APKs = nil) or (APKs.Count = 0) or (APKs.IndexOf(ColName) < 0) then
        begin
          if HasCol then
            SQLText := SQLText + ',' + sLineBreak;
          SQLText := SQLText + '  ' + ColName + ' = ' + QuotedStr('valor_' + ColName);
          HasCol := True;
        end;
      end;
    end;
    if not HasCol then
    begin
      if (AColunas <> nil) and (AColunas.Count > 0) then
        SQLText := SQLText + '  ' + AColunas[0] + ' = ' + QuotedStr('valor_' + AColunas[0])
      else
        SQLText := SQLText + '  /* coluna = valor */';
    end;
    SQLText := SQLText + sLineBreak + 'WHERE' + sLineBreak;
    if (APKs <> nil) and (APKs.Count > 0) then
    begin
      for I := 0 to APKs.Count - 1 do
      begin
        if I = 0 then
          SQLText := SQLText + '  ' + APKs[I] + ' = 1' + sLineBreak
        else
          SQLText := SQLText + '  AND ' + APKs[I] + ' = 1' + sLineBreak;
      end;
      SQLText := SQLText + ';' + sLineBreak;
    end
    else
      SQLText := SQLText + '  /* informe a condição */ 1 = 1;' + sLineBreak;
  end
  else if SameText(ATipoScript, 'DELETE') then
  begin
    SQLText := 'DELETE FROM ' + ATableName + sLineBreak + 'WHERE' + sLineBreak;
    if (APKs <> nil) and (APKs.Count > 0) then
    begin
      for I := 0 to APKs.Count - 1 do
      begin
        if I = 0 then
          SQLText := SQLText + '  ' + APKs[I] + ' = 1' + sLineBreak
        else
          SQLText := SQLText + '  AND ' + APKs[I] + ' = 1' + sLineBreak;
      end;
      SQLText := SQLText + ';' + sLineBreak;
    end
    else
      SQLText := SQLText + '  /* informe a condição */ 1 = 0;' + sLineBreak;
  end;

  Result := SQLText;
end;

procedure Tfrmmquery2.btSalvarPostClick(Sender: TObject);
begin
  SalvarAlteracoes(dbgridpost, zpostqry1);
end;

procedure Tfrmmquery2.btSalvarMyClick(Sender: TObject);
begin
  SalvarAlteracoes(dbgridmy, zmyqry2);
end;

procedure Tfrmmquery2.btSalvarLiteClick(Sender: TObject);
begin
  SalvarAlteracoes(dbgridmy1, zliteqry2);
end;

procedure Tfrmmquery2.btSalvarDynamicClick(Sender: TObject);
var
  E: Integer;
begin
  E := DynEngineFromSender(Sender);
  if E < 0 then Exit;
  SalvarAlteracoes(FDyn[E].Grid, FDyn[E].GridQry);
end;

procedure Tfrmmquery2.SalvarAlteracoes(AGrid: TDBGrid; ADataSet: TDataSet);
var
  Qry: TZQuery;
begin
  if (ADataSet = nil) or (not ADataSet.Active) then
  begin
    ShowMessage('Nenhum conjunto de dados aberto para salvar.');
    Exit;
  end;

  try
    if AGrid <> nil then
      AGrid.EditorMode := False;

    if ADataSet.State in [dsEdit, dsInsert] then
      ADataSet.Post;

    if ADataSet is TZQuery then
    begin
      Qry := TZQuery(ADataSet);
      if (Qry.Connection <> nil) and (not Qry.Connection.AutoCommit) then
        Qry.Connection.Commit;
    end;

    ShowMessage('Modificações salvas com sucesso no banco de dados!');
  except
    on E: Exception do
      ShowMessage('Erro ao salvar no banco de dados: ' + E.Message);
  end;
end;

function Tfrmmquery2.GetSelectedTableNode(ATree: TTreeView; AParentRoot: TTreeNode): TTreeNode;
var
  N: TTreeNode;
begin
  Result := nil;
  if (ATree = nil) or (ATree.Selected = nil) or (AParentRoot = nil) then Exit;
  N := ATree.Selected;
  while (N <> nil) and (N.Parent <> AParentRoot) do
    N := N.Parent;
  if (N <> nil) and (N.Parent = AParentRoot) then
    Result := N;
end;

procedure Tfrmmquery2.ObterTabelaInfo(ATableNode: TTreeNode; out ATableName: string; AColunas, APKs: TStrings);
var
  ChildNode, SubNode: TTreeNode;
  RawText, ColName: string;
begin
  ATableName := '';
  if AColunas <> nil then AColunas.Clear;
  if APKs <> nil then APKs.Clear;
  if ATableNode = nil then Exit;

  ATableName := Trim(ATableNode.Text);

  ChildNode := ATableNode.GetFirstChild;
  while ChildNode <> nil do
  begin
    if SameText(ChildNode.Text, 'fields') or (ChildNode.Data = Pointer(ETDBCampos)) then
    begin
      SubNode := ChildNode.GetFirstChild;
      while SubNode <> nil do
      begin
        RawText := SubNode.Text;
        ColName := ExtractFieldName(RawText);
        if (ColName <> '') and (AColunas <> nil) and (AColunas.IndexOf(ColName) < 0) then
          AColunas.Add(ColName);
        SubNode := SubNode.GetNextSibling;
      end;
    end
    else if SameText(ChildNode.Text, 'Primary Key') or (ChildNode.Data = Pointer(ETDBPK)) then
    begin
      SubNode := ChildNode.GetFirstChild;
      while SubNode <> nil do
      begin
        if APKs <> nil then
          ExtractPKNames(SubNode.Text, APKs);
        SubNode := SubNode.GetNextSibling;
      end;
    end;
    ChildNode := ChildNode.GetNextSibling;
  end;
end;

procedure Tfrmmquery2.GerarScriptTabela(AEngineIndex: Integer; const ATipoScript: string);
var
  Tree: TTreeView;
  ParentRoot: TTreeNode;
  TableNode: TTreeNode;
  TableName: string;
  Colunas, PKs: TStringList;
  SQLText: string;
begin
  Tree := nil;
  ParentRoot := nil;

  case AEngineIndex of
    0: begin Tree := tvMysql; ParentRoot := posicaofieldsmy; end;
    1: begin Tree := tvPost; ParentRoot := posicaofieldspost; end;
    2: begin Tree := tvsqlite; ParentRoot := posicaofieldslite; end;
    3: begin Tree := tvMSSQL; ParentRoot := posicaofieldsMSSQL; end;
    4: begin Tree := tvOracle; ParentRoot := posicaofieldsOracle; end;
  end;

  if (Tree = nil) or (Tree.Selected = nil) or (ParentRoot = nil) then
  begin
    ShowMessage('Selecione uma tabela na árvore.');
    Exit;
  end;

  TableNode := GetSelectedTableNode(Tree, ParentRoot);
  if TableNode = nil then
  begin
    ShowMessage('Selecione uma tabela válida.');
    Exit;
  end;

  Colunas := TStringList.Create;
  PKs := TStringList.Create;
  try
    ObterTabelaInfo(TableNode, TableName, Colunas, PKs);
    SQLText := MontarScriptSQL(TableName, ATipoScript, Colunas, PKs);

    case AEngineIndex of
      0:
      begin
        edSQL.Clear;
        edSQL.Lines.Text := SQLText;
        pgMysql.ActivePage := tbSQL;
        pgMain.ActivePage := tsMysql;
        edSQL.SetFocus;
      end;
      1:
      begin
        edSQLPost.Clear;
        edSQLPost.Lines.Text := SQLText;
        pcPostgree.ActivePage := tsSQLPostgreSQL;
        pgMain.ActivePage := tsPostgree;
        edSQLPost.SetFocus;
      end;
      2:
      begin
        edSQL1.Clear;
        edSQL1.Lines.Text := SQLText;
        pgSQLite.ActivePage := tbSQL1;
        pgMain.ActivePage := tsSqlite;
        edSQL1.SetFocus;
      end;
      3:
      begin
        edSQLMSSQL.Clear;
        edSQLMSSQL.Lines.Text := SQLText;
        pgMain.ActivePage := tsMSSQL;
        if pcMSSQL <> nil then pcMSSQL.ActivePage := tsSQLMSSQL;
        edSQLMSSQL.SetFocus;
      end;
      4:
      begin
        edSQLOracle.Clear;
        edSQLOracle.Lines.Text := SQLText;
        pgMain.ActivePage := tsOracle;
        if pcOracle <> nil then pcOracle.ActivePage := tsSQLOracle;
        edSQLOracle.SetFocus;
      end;
    end;
  finally
    Colunas.Free;
    PKs.Free;
  end;
end;

procedure Tfrmmquery2.miScriptSelectClick(Sender: TObject);
begin
  GerarScriptTabela(TMenuItem(Sender).Tag, 'SELECT');
end;

procedure Tfrmmquery2.miScriptInsertClick(Sender: TObject);
begin
  GerarScriptTabela(TMenuItem(Sender).Tag, 'INSERT');
end;

procedure Tfrmmquery2.miScriptUpdateClick(Sender: TObject);
begin
  GerarScriptTabela(TMenuItem(Sender).Tag, 'UPDATE');
end;

procedure Tfrmmquery2.miScriptDeleteClick(Sender: TObject);
begin
  GerarScriptTabela(TMenuItem(Sender).Tag, 'DELETE');
end;

procedure Tfrmmquery2.AddScriptMenuItems(AMenu: TPopupMenu; AEngineIndex: Integer);
var
  Sep: TMenuItem;
  MenuScripts: TMenuItem;
  ItemSelect, ItemInsert, ItemUpdate, ItemDelete: TMenuItem;
begin
  if AMenu = nil then Exit;

  if AMenu.Items.Count > 0 then
  begin
    Sep := TMenuItem.Create(Self);
    Sep.Caption := '-';
    AMenu.Items.Add(Sep);
  end;

  MenuScripts := TMenuItem.Create(Self);
  MenuScripts.Caption := 'Gerar Script';
  AMenu.Items.Add(MenuScripts);

  ItemSelect := TMenuItem.Create(Self);
  ItemSelect.Caption := 'SELECT';
  ItemSelect.Tag := AEngineIndex;
  ItemSelect.OnClick := @miScriptSelectClick;
  MenuScripts.Add(ItemSelect);

  ItemInsert := TMenuItem.Create(Self);
  ItemInsert.Caption := 'INSERT';
  ItemInsert.Tag := AEngineIndex;
  ItemInsert.OnClick := @miScriptInsertClick;
  MenuScripts.Add(ItemInsert);

  ItemUpdate := TMenuItem.Create(Self);
  ItemUpdate.Caption := 'UPDATE';
  ItemUpdate.Tag := AEngineIndex;
  ItemUpdate.OnClick := @miScriptUpdateClick;
  MenuScripts.Add(ItemUpdate);

  ItemDelete := TMenuItem.Create(Self);
  ItemDelete.Caption := 'DELETE';
  ItemDelete.Tag := AEngineIndex;
  ItemDelete.OnClick := @miScriptDeleteClick;
  MenuScripts.Add(ItemDelete);
end;

procedure Tfrmmquery2.InstallTableScriptMenus;
begin
  if pmTabelaMSSQL = nil then
    pmTabelaMSSQL := TPopupMenu.Create(Self);
  if pmTabelaOracle = nil then
    pmTabelaOracle := TPopupMenu.Create(Self);

  AddScriptMenuItems(pmTabelaMy, 0);
  AddScriptMenuItems(pmTabelaPost, 1);
  AddScriptMenuItems(pmTabelaLite, 2);
  AddScriptMenuItems(pmTabelaMSSQL, 3);
  AddScriptMenuItems(pmTabelaOracle, 4);
end;

procedure Tfrmmquery2.InicializarGridEditing;
begin
  // PostgreSQL Panel6
  btSalvarPost := TButton.Create(Self);
  btSalvarPost.Parent := Panel6;
  btSalvarPost.Caption := 'Salvar';
  btSalvarPost.Hint := 'Salva as alterações feitas no grid diretamente no banco de dados';
  btSalvarPost.ShowHint := True;
  btSalvarPost.Left := dbnavpost.Left + dbnavpost.Width + 8;
  btSalvarPost.Top := dbnavpost.Top;
  btSalvarPost.Width := 75;
  btSalvarPost.Height := dbnavpost.Height;
  btSalvarPost.OnClick := @btSalvarPostClick;

  // MySQL Panel3
  btSalvarMy := TButton.Create(Self);
  btSalvarMy.Parent := Panel3;
  btSalvarMy.Caption := 'Salvar';
  btSalvarMy.Hint := 'Salva as alterações feitas no grid diretamente no banco de dados';
  btSalvarMy.ShowHint := True;
  btSalvarMy.Left := dbnavmy.Left + dbnavmy.Width + 8;
  btSalvarMy.Top := dbnavmy.Top;
  btSalvarMy.Width := 75;
  btSalvarMy.Height := dbnavmy.Height;
  btSalvarMy.OnClick := @btSalvarMyClick;

  // SQLite Panel18
  btSalvarLite := TButton.Create(Self);
  btSalvarLite.Parent := Panel18;
  btSalvarLite.Caption := 'Salvar';
  btSalvarLite.Hint := 'Salva as alterações feitas no grid diretamente no banco de dados';
  btSalvarLite.ShowHint := True;
  btSalvarLite.Left := dbnavmy1.Left + dbnavmy1.Width + 8;
  btSalvarLite.Top := dbnavmy1.Top;
  btSalvarLite.Width := 75;
  btSalvarLite.Height := dbnavmy1.Height;
  btSalvarLite.OnClick := @btSalvarLiteClick;
end;

procedure Tfrmmquery2.ConfigurarCompletion(AComp: TSynCompletion; AEditor: TSynEdit);
begin
  if (AComp = nil) or (AEditor = nil) then Exit;
  AComp.Editor := AEditor;
  AComp.ShortCut := Menus.ShortCut(VK_SPACE, [ssCtrl]);
  AComp.EndOfTokenChr := '()[]+-*/=<>;, ';
  AComp.CaseSensitive := False;
  AComp.Width := 400;
  AComp.LinesInWindow := 12;
  AComp.AutoUseSingleIdent := False;
end;

procedure Tfrmmquery2.InicializarAutocomplete;
var
  I: Integer;
begin
  FCompletions[0] := SynCompletion1;
  ConfigurarCompletion(FCompletions[0], edSQL);

  if FCompletions[1] = nil then
    FCompletions[1] := TSynCompletion.Create(Self);
  ConfigurarCompletion(FCompletions[1], edSQLPost);

  if FCompletions[2] = nil then
    FCompletions[2] := TSynCompletion.Create(Self);
  ConfigurarCompletion(FCompletions[2], edSQL1);

  if FCompletions[3] = nil then
    FCompletions[3] := TSynCompletion.Create(Self);
  ConfigurarCompletion(FCompletions[3], edSQLMSSQL);

  if FCompletions[4] = nil then
    FCompletions[4] := TSynCompletion.Create(Self);
  ConfigurarCompletion(FCompletions[4], edSQLOracle);

  // O controlador troca a lista fixa por sugestoes conforme o contexto
  // (tabelas apos FROM/JOIN, colunas apos "apelido.") e abre sozinho no ".".
  for I := 0 to 4 do
    if (FCompletions[I] <> nil) and (FCompletions[I].Editor <> nil) and
       (FCompletionCtl[I] = nil) then
      FCompletionCtl[I] := TMQueryCompletionController.CreateFor(Self,
        FCompletions[I], TSynEdit(FCompletions[I].Editor), FCatalogs[I]);

  for I := 0 to 4 do
    AtualizarAutocomplete(I);
end;

procedure Tfrmmquery2.CriarCatalogos;
var
  I: Integer;
begin
  for I := 0 to 4 do
    if FCatalogs[I] = nil then
      FCatalogs[I] := TMQueryCatalog.Create(Self);
end;

procedure Tfrmmquery2.InstalarAbasConsultas;
begin
  // Aba "Consultas" logo apos a aba de conexao de cada banco
  FQueryBooks[0] := TMQueryQueryBook.CreateBook(Self, pgMysql, zconmysql,
    FCatalogs[0], edSQL, 'MySQL', 1);
  FQueryBooks[1] := TMQueryQueryBook.CreateBook(Self, pcPostgree, zconpost,
    FCatalogs[1], edSQLPost, 'PostgreSQL', 1);
  FQueryBooks[2] := TMQueryQueryBook.CreateBook(Self, pgSQLite, zconsqlite,
    FCatalogs[2], edSQL1, 'SQLite', 1);
  if pcMSSQL <> nil then
    FQueryBooks[3] := TMQueryQueryBook.CreateBook(Self, pcMSSQL, zconMSSQL,
      FCatalogs[3], edSQLMSSQL, 'SQL Server', 1);
  if pcOracle <> nil then
    FQueryBooks[4] := TMQueryQueryBook.CreateBook(Self, pcOracle, zconOracle,
      FCatalogs[4], edSQLOracle, 'Oracle', 1);
end;

function Tfrmmquery2.QueryBook(AEngine: Integer): TMQueryQueryBook;
begin
  Result := nil;
  if (AEngine >= Low(FQueryBooks)) and (AEngine <= High(FQueryBooks)) then
    Result := FQueryBooks[AEngine];
end;

function Tfrmmquery2.NovaConsulta(AEngine: Integer; const ATexto: string): TMQueryQueryTab;
var
  B: TMQueryQueryBook;
begin
  Result := nil;
  B := QueryBook(AEngine);
  if B = nil then Exit;
  Result := B.NewQuery(ATexto);
  B.Show;
end;

function Tfrmmquery2.GetActiveEngineIndex: Integer;
begin
  if pgMain.ActivePage = tsMysql then Result := 0
  else if pgMain.ActivePage = tsPostgree then Result := 1
  else if pgMain.ActivePage = tsSqlite then Result := 2
  else if pgMain.ActivePage = tsMSSQL then Result := 3
  else if pgMain.ActivePage = tsOracle then Result := 4
  else Result := -1;
end;

procedure Tfrmmquery2.pgMainChange(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := GetActiveEngineIndex;
  if Idx >= 0 then
    AtualizarAutocomplete(Idx);
end;

procedure Tfrmmquery2.AtualizarAutocomplete(AEngineIndex: Integer);
var
  ParentRoot, TblNode, ChildNode, ColNode: TTreeNode;
  TblName, ColName: string;
  Cat: TMQueryCatalog;
begin
  if (AEngineIndex < 0) or (AEngineIndex > 4) then Exit;
  Cat := FCatalogs[AEngineIndex];
  if Cat = nil then Exit;

  ParentRoot := nil;
  case AEngineIndex of
    0: ParentRoot := posicaofieldsmy;
    1: ParentRoot := posicaofieldspost;
    2: ParentRoot := posicaofieldslite;
    3: ParentRoot := posicaofieldsMSSQL;
    4: ParentRoot := posicaofieldsOracle;
  end;

  // O catalogo e montado a partir da arvore ja carregada (tabela -> "fields")
  Cat.Clear;
  if ParentRoot = nil then Exit;

  TblNode := ParentRoot.GetFirstChild;
  while TblNode <> nil do
  begin
    TblName := Trim(TblNode.Text);
    if TblName <> '' then
    begin
      Cat.AddTable(TblName);
      ChildNode := TblNode.GetFirstChild;
      while ChildNode <> nil do
      begin
        if SameText(ChildNode.Text, 'fields') or (ChildNode.Data = Pointer(ETDBCampos)) then
        begin
          ColNode := ChildNode.GetFirstChild;
          while ColNode <> nil do
          begin
            ColName := ExtractFieldName(ColNode.Text);
            if ColName <> '' then
              Cat.AddColumn(TblName, ColName);
            ColNode := ColNode.GetNextSibling;
          end;
        end;
        ChildNode := ChildNode.GetNextSibling;
      end;
    end;
    TblNode := TblNode.GetNextSibling;
  end;
end;

function NormalizarTipoBanco(const ATipo: string): string;
var
  S: string;
begin
  S := LowerCase(Trim(ATipo));
  if (Pos('mysql', S) > 0) or (Pos('mariadb', S) > 0) then
    Result := 'mysql'
  else if (Pos('post', S) > 0) or (Pos('pg', S) > 0) then
    Result := 'postgres'
  else if Pos('sqlite', S) > 0 then
    Result := 'sqlite'
  else if (Pos('sqlserver', S) > 0) or (Pos('mssql', S) > 0) or (Pos('server', S) > 0) then
    Result := 'sqlserver'
  else if Pos('oracle', S) > 0 then
    Result := 'oracle'
  else
    Result := S;
end;

function ConnectionToJsonString(const ATipo, AHost: string; APort: Integer;
  const ADatabase, AUsername, APassword, ASchema: string): string;
var
  JObj: TJSONObject;
begin
  JObj := TJSONObject.Create;
  try
    JObj.Add('type', NormalizarTipoBanco(ATipo));
    if Trim(AHost) <> '' then
      JObj.Add('host', Trim(AHost));
    if APort > 0 then
      JObj.Add('port', APort);
    if Trim(ADatabase) <> '' then
      JObj.Add('database', Trim(ADatabase));
    if Trim(AUsername) <> '' then
      JObj.Add('username', Trim(AUsername));
    if Trim(APassword) <> '' then
      JObj.Add('password', APassword);
    if Trim(ASchema) <> '' then
      JObj.Add('schema', Trim(ASchema));
    Result := JObj.FormatJSON;
  finally
    JObj.Free;
  end;
end;

function JsonStringToConnection(const AJson: string;
  out ATipo, AHost: string; out APort: Integer;
  out ADatabase, AUsername, APassword, ASchema: string): Boolean;
var
  JData: TJSONData;
  JObj: TJSONObject;
begin
  Result := False;
  ATipo := '';
  AHost := '';
  APort := 0;
  ADatabase := '';
  AUsername := '';
  APassword := '';
  ASchema := '';

  if Trim(AJson) = '' then Exit;

  try
    JData := GetJSON(AJson);
    try
      if (JData is TJSONObject) then
      begin
        JObj := TJSONObject(JData);
        if JObj.Find('type') <> nil then
          ATipo := JObj.Get('type', '')
        else if JObj.Find('driver') <> nil then
          ATipo := JObj.Get('driver', '')
        else if JObj.Find('banco') <> nil then
          ATipo := JObj.Get('banco', '');

        ATipo := NormalizarTipoBanco(ATipo);

        AHost := JObj.Get('host', '');
        APort := JObj.Get('port', 0);

        if JObj.Find('database') <> nil then
          ADatabase := JObj.Get('database', '')
        else if JObj.Find('banco') <> nil then
          ADatabase := JObj.Get('banco', '');

        if JObj.Find('username') <> nil then
          AUsername := JObj.Get('username', '')
        else if JObj.Find('user') <> nil then
          AUsername := JObj.Get('user', '');

        if JObj.Find('password') <> nil then
          APassword := JObj.Get('password', '')
        else if JObj.Find('pass') <> nil then
          APassword := JObj.Get('pass', '');

        ASchema := JObj.Get('schema', '');

        Result := (ATipo <> '');
      end;
    finally
      JData.Free;
    end;
  except
    Result := False;
  end;
end;

function Tfrmmquery2.SalvarConexaoArquivo(const AFileName: string; AEngineIndex: Integer): Boolean;
var
  tipo, host, db, user, pass, schema, jsonText: string;
  porta: Integer;
  sl: TStringList;
begin
  Result := False;
  if AEngineIndex < 0 then
    AEngineIndex := GetActiveEngineIndex;

  porta := 0;
  host := '';
  db := '';
  user := '';
  pass := '';
  schema := '';

  case AEngineIndex of
    0:
    begin
      tipo := 'mysql';
      host := Trim(edHostName.Text);
      db := Trim(edBanco.Text);
      user := Trim(edusuario.Text);
      pass := edPasswrd.Text;
      porta := 3306;
    end;
    1:
    begin
      tipo := 'postgres';
      host := Trim(edHostNamePost.Text);
      db := Trim(edBancoPost.Text);
      user := Trim(edusuarioPost.Text);
      pass := edPasswrdPost.Text;
      schema := Trim(edSchemaPost.Text);
      if zconpost.Port > 0 then
        porta := zconpost.Port
      else
        porta := 5432;
    end;
    2:
    begin
      tipo := 'sqlite';
      db := Trim(edDatabase.Text);
      porta := 0;
    end;
    3:
    begin
      tipo := 'sqlserver';
      host := Trim(edHostMSSQL.Text);
      db := Trim(edBancoMSSQL.Text);
      user := Trim(edUserMSSQL.Text);
      pass := edPassMSSQL.Text;
      schema := Trim(edSchemaMSSQL.Text);
      if zconMSSQL.Port > 0 then
        porta := zconMSSQL.Port
      else
        porta := 1433;
    end;
    4:
    begin
      tipo := 'oracle';
      host := Trim(edHostOracle.Text);
      db := Trim(edBancoOracle.Text);
      user := Trim(edUserOracle.Text);
      pass := edPassOracle.Text;
      schema := Trim(edSchemaOracle.Text);
      if zconOracle.Port > 0 then
        porta := zconOracle.Port
      else
        porta := 1521;
    end;
    else
    begin
      ShowMessage('Selecione uma aba de banco de dados (MySQL, PostgreSQL, SQLite, SQL Server ou Oracle).');
      Exit;
    end;
  end;

  jsonText := ConnectionToJsonString(tipo, host, porta, db, user, pass, schema);
  sl := TStringList.Create;
  try
    sl.Text := jsonText;
    sl.SaveToFile(AFileName);
    Result := True;
  finally
    sl.Free;
  end;
end;

function Tfrmmquery2.CarregarConexaoArquivo(const AFileName: string): Boolean;
var
  sl: TStringList;
  tipo, host, db, user, pass, schema: string;
  porta: Integer;
begin
  Result := False;
  if not FileExists(AFileName) then
  begin
    ShowMessage('Arquivo não encontrado: ' + AFileName);
    Exit;
  end;

  sl := TStringList.Create;
  try
    sl.LoadFromFile(AFileName);
    if not JsonStringToConnection(sl.Text, tipo, host, porta, db, user, pass, schema) then
    begin
      ShowMessage('Formato de arquivo .con inválido ou tipo de banco não identificado.');
      Exit;
    end;
  finally
    sl.Free;
  end;

  case tipo of
    'mysql':
    begin
      pgMain.ActivePage := tsMysql;
      if host <> '' then edHostName.Text := host;
      if db <> '' then edBanco.Text := db;
      if user <> '' then edusuario.Text := user;
      if pass <> '' then edPasswrd.Text := pass;
      RefreshMy;
      Result := True;
    end;
    'postgres':
    begin
      pgMain.ActivePage := tsPostgree;
      if host <> '' then edHostNamePost.Text := host;
      if db <> '' then edBancoPost.Text := db;
      if user <> '' then edusuarioPost.Text := user;
      if pass <> '' then edPasswrdPost.Text := pass;
      if schema <> '' then edSchemaPost.Text := schema;
      if porta > 0 then zconpost.Port := porta;
      RefreshPost;
      Result := True;
    end;
    'sqlite':
    begin
      pgMain.ActivePage := tsSqlite;
      if db <> '' then edDatabase.Text := db;
      RefreshSQLite;
      Result := True;
    end;
    'sqlserver':
    begin
      pgMain.ActivePage := tsMSSQL;
      if host <> '' then edHostMSSQL.Text := host;
      if db <> '' then edBancoMSSQL.Text := db;
      if user <> '' then edUserMSSQL.Text := user;
      if pass <> '' then edPassMSSQL.Text := pass;
      if schema <> '' then edSchemaMSSQL.Text := schema;
      if porta > 0 then zconMSSQL.Port := porta;
      btConectarMSSQLClick(nil);
      Result := True;
    end;
    'oracle':
    begin
      pgMain.ActivePage := tsOracle;
      if host <> '' then edHostOracle.Text := host;
      if db <> '' then edBancoOracle.Text := db;
      if user <> '' then edUserOracle.Text := user;
      if pass <> '' then edPassOracle.Text := pass;
      if schema <> '' then edSchemaOracle.Text := schema;
      if porta > 0 then zconOracle.Port := porta;
      btConectarOracleClick(nil);
      Result := True;
    end;
    else
    begin
      ShowMessage('Tipo de banco desconhecido: ' + tipo);
      Exit;
    end;
  end;
end;

procedure Tfrmmquery2.miLoadConnectionClick(Sender: TObject);
begin
  OpenDialog1.Title := 'Load Connection';
  OpenDialog1.Filter := 'Arquivos de Conexão (*.con)|*.con|Arquivos JSON (*.json)|*.json|Todos os Arquivos (*.*)|*.*';
  OpenDialog1.DefaultExt := 'con';
  if OpenDialog1.Execute then
  begin
    if CarregarConexaoArquivo(OpenDialog1.FileName) then
      ShowMessage('Conexão carregada com sucesso a partir de ' + ExtractFileName(OpenDialog1.FileName));
  end;
end;

procedure Tfrmmquery2.miSaveConnectionClick(Sender: TObject);
var
  idx: Integer;
  sugestao: string;
begin
  idx := GetActiveEngineIndex;
  if idx < 0 then
  begin
    ShowMessage('Selecione uma aba de banco de dados (MySQL, PostgreSQL, SQLite, SQL Server ou Oracle) para salvar a conexão.');
    Exit;
  end;

  case idx of
    0: sugestao := 'mysql_conexao.con';
    1: sugestao := 'postgres_conexao.con';
    2: sugestao := 'sqlite_conexao.con';
    3: sugestao := 'sqlserver_conexao.con';
    4: sugestao := 'oracle_conexao.con';
  end;

  SaveDialog1.Title := 'Save Connection';
  SaveDialog1.Filter := 'Arquivos de Conexão (*.con)|*.con|Arquivos JSON (*.json)|*.json|Todos os Arquivos (*.*)|*.*';
  SaveDialog1.DefaultExt := 'con';
  SaveDialog1.FileName := sugestao;
  if SaveDialog1.Execute then
  begin
    if SalvarConexaoArquivo(SaveDialog1.FileName, idx) then
      ShowMessage('Conexão salva com sucesso em ' + ExtractFileName(SaveDialog1.FileName));
  end;
end;

end.