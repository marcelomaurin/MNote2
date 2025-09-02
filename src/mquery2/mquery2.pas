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
  PairSplitter, DBCtrls, DBGrids, finds, ZClasses, ZCollections, ZCompatibility,
  ZTokenizer, ZSelectSchema, ZGenericSqlAnalyser, ZDbcLogging, ZVariant,
  ZPlainDriver, TypeDB, triggers, item, funcoes, chart, chatgpt, codigo,
  setmain, ZDbcIntfs, math, hint, Variants, LConvEncoding, base; //ZURL

const
  sqltabela = 'Você poderia me fornecer a consulta SQL que deseja analisar? Assim que eu receber o SQL, irei extrair os nomes das tabelas envolvidas e gerar um código em JSON com esses nomes. A resposta será apresentada dentro de uma caixa de texto apropriada para cópia, Desta forma refaça a pergunta mesmo nao havendo certeza da resposta,claramente formatada como um código JSON:';
  sqlMelhorias = 'Faça uma analise de melhorias do sql a seguir, gerando um codigo JSON onde cada melhoria fica listada em uma lista no campo melhoria, nao acrescentando numeração, apenas uma lista de melhorias como elementos deste campo';
  sqlEstetica = 'Por favor, forneça um código embelezado para o seguinte SQL. Gostaria que ele fosse apresentado em uma caixa de texto ou em um formato que me permita copiar e colar facilmente no meu editor de código. Aqui está o SQL: ';

type

  { TForm1 }

  { Tfrmmquery2 }

  Tfrmmquery2= class(TForm)
    btAnalise1: TButton;
    btBanco: TButton;
    btBanco1: TButton;
    btChart: TButton;
    btChartPost: TButton;
    btImportCSV: TButton;
    btcomparar: TButton;
    btcomparar1: TButton;
    btConectarMy: TButton;
    btConectarPost: TButton;
    btExecutar1: TButton;
    btExecute1: TButton;
    btJSON1: TButton;
    btPermissao: TToggleBox;
    btExecutar: TButton;
    btExecute: TButton;
    btJSON: TButton;
    btAnalise: TButton;
    btPermissao1: TToggleBox;
    btIAPost: TButton;
    Button3: TButton;
    cbMake: TComboBox;
    ckGPT: TCheckBox;
    CSVDataset1: TCSVDataset;
    dbgridmy: TDBGrid;
    dbgridpost: TDBGrid;
    dbnavmy: TDBNavigator;
    dbnavpost: TDBNavigator;
    dsmy: TDataSource;
    dspos: TDataSource;
    edBanco: TEdit;
    edBancoPost: TEdit;
    edErro: TMemo;
    edErro1: TMemo;
    edHostName: TEdit;
    edHostNamePost: TEdit;
    edLogPost: TMemo;
    edPesqMy: TEdit;
    edSchemaPost: TEdit;
    edLog: TMemo;
    edPasswrd: TEdit;
    edPasswrdPost: TEdit;
    edPesqPost: TEdit;
    edSQL: TSynEdit;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCol: TLabel;
    lbCol1: TLabel;
    lblinha: TLabel;
    lblinha1: TLabel;
    ListBox1: TListBox;
    lbTables: TListBox;
    lstfind: TListBox;
    lstfind1: TListBox;
    MainMenu1: TMainMenu;
    meIA: TMemo;
    MenuItem1: TMenuItem;
    dropPost: TMenuItem;
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
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    Splitter5: TSplitter;
    Splitter6: TSplitter;
    SynCompletion1: TSynCompletion;
    SynPluginSyncroEdit1: TSynPluginSyncroEdit;
    SynSQLSyn2: TSynSQLSyn;
    TabSheet1: TTabSheet;
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
    tvPost: TTreeView;
    tvMysql: TTreeView;
    vlistequivalente: TStringGrid;
    zconmysql: TZConnection;
    zconpost: TZConnection;
    zmyqry: TZReadOnlyQuery;
    zmyqry1: TZReadOnlyQuery;
    zmyqry2: TZReadOnlyQuery;
    zpostqry: TZReadOnlyQuery;
    zpostqry1: TZReadOnlyQuery;
    Zqrypost: TZQuery;
    ZQryTransf: TZQuery;
    procedure btAnaliseClick(Sender: TObject);
    procedure btBancoClick(Sender: TObject);
    procedure btbenchmarkClick(Sender: TObject);
    procedure btChartClick(Sender: TObject);
    procedure btChartPostClick(Sender: TObject);
    procedure btcompararClick(Sender: TObject);
    procedure btExecutar1Click(Sender: TObject);
    procedure btExecutarClick(Sender: TObject);
    procedure btIAPostClick(Sender: TObject);
    procedure btImportCSVClick(Sender: TObject);
    procedure btJSONClick(Sender: TObject);
    procedure btPermissaoChange(Sender: TObject);
    procedure btConectarMyClick(Sender: TObject);
    procedure btConectarpostClick(Sender: TObject);
    procedure btExecuteClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure edPesqMyKeyPress(Sender: TObject; var Key: char);
    procedure edPesqPostKeyPress(Sender: TObject; var Key: char);
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
    procedure edSQLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
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
    procedure miCTriggerClick(Sender: TObject);
    procedure miDescricaoPostClick(Sender: TObject);
    procedure midropClick(Sender: TObject);
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
    procedure mnCriaDicionarioClick(Sender: TObject);
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
    function GeraSQLMy(Tabela : TTabela): string;
    function TipoConv(Tabela : TTabela; Posicao: integer): String;
    procedure tvPostChange(Sender: TObject; Node: TTreeNode);
    procedure tvPostClick(Sender: TObject);
    procedure PostApagaTabela(Nome: string);
    procedure vlistequivalenteClick(Sender: TObject);
    procedure zconpostAfterConnect(Sender: TObject);
    procedure ZPgEventAlerter1Notify(Sender: TObject; Event: string;
      ProcessID: Integer; Payload: string);
  private
    FCHATGPT : TCHATGPT;
    posicaofieldsmy : TTreeNode;
    posicaofieldspost : TTreeNode;
    tvitemPost : TTreeNode;
    tvitemMy : TTreeNode;
    tvDatabasePost : TTreeNode;
    tvDatabaseMy : TTreeNode;
    tvTablePost : TTreeNode;
    tvTableMy : TTreeNode;
    posicaoViewmy : TTreeNode;
    posicaoProceduremy : TTreeNode;
    posicaoFunctionmy : TTreeNode;
    posicaoViewPost : TTreeNode;
    posicaoProcedurePost : TTreeNode;
    posicaoFunctionPost : TTreeNode;
    posicaoSequencePost : TTreeNode;
    viewsmy : TViews;
    viewspost : TViews;
    sequences : TStringList;
    FPos : integer;
    strFind : String;
    procedure MontaCreateTrigger(Tabela : TTabela; posicao : integer);
    procedure ListarTabelasMy();
    procedure ListarTabelasPost();
    procedure ProcuraTVMysql(Nome: String);
    procedure ProcuraTVPost(Nome: String);
    procedure BuscaSequence(qry:TZReadOnlyQuery;  TypeDB: TypeDatabase);
    procedure ListarViewsMy();
    procedure ListarViewsPost();
    function FormataSQL(Info : string): string;
    function TrocarPalavra(Info : String; de: String; para : String): String;
    procedure setSelLength(var textComponent:TSynEdit; newValue:integer);
    procedure Analisemy(SQL : String);
    procedure Analisepost(SQL : String);
  public
    procedure ChartView; overload;
    procedure ChartView(AType: TChartCommType); overload;

    procedure RefreshPost();
    procedure RefreshMy();
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
    // Função que migra os campos do CSVDataSet para a tabela criada
    procedure MigraCampos(NomeTabela: string; CSVDataSet: TCSVDataSet; ZQuery: TZQuery);
    function ConectPost: Boolean;
    function ConectMy: Boolean;
    function DescreveTabelaIAPost(tabela : string): string;
    function DescreveTabelaIAMy(const tabela: string): string;
    function CriaDicionarioPost(const ATargetFile: string): string;
    function CriaListaDependenciasPost(const outFile: string): string;
    function QuestionarSQLPost(const pergunta, deps, ddl: string): string;
    function ValidaConexao(TipoBanco: Integer ): Boolean;
  end;

var
  frmmquery2: Tfrmmquery2;

implementation

{$R *.lfm}

uses benchmark, main;

{ TForm1 }


procedure Tfrmmquery2.ChartView;
var
  t: TChartCommType;
begin
  // comportamento padrão: detectar o ativo
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

  frmChart.CommType := AType;  // <<— aqui o chart define o dataset internamente
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
    tabelaList := TStringList.create();
    frmMNote.NewContext();
    frmMNote.edChat.text := sqltabela + edSQL.text+' faça em uma caixa de texto';
    frmMNote.FazPergunta();
    if (frmMNote.meCodes.text<>'') then
    begin
      resposta := frmMNote.meCodes.text;

     //Captura o fonte
     // Captura os blocos de código
     codigo := TCodigo.create();
     codigo.AnalisaTexto(resposta);


     try
        // Itera por cada bloco de código capturado
        for i := 0 to codigo.Count-1 do
        begin
          item := TFonte(codigo.Items[i]);
          // Chama a função CapturaTabela
          tabelaList := CapturaJSONTabela(item.codigo);

          lbTables.Items.AddStrings(tabelaList);
        end;
     finally
        tabelaList.Free;
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
    tabelaList := TStringList.create();
    frmMNote.NewContext();
    frmMNote.edChat.text := sqltabela + edSQLPost.text+' faça em uma caixa de texto';
    frmMNote.FazPergunta();
    if (frmMNote.meCodes.text<>'') then
    begin
      resposta := frmMNote.meCodes.text;

     //Captura o fonte
     // Captura os blocos de código
     codigo := TCodigo.create();
     codigo.AnalisaTexto(resposta);


     try
        // Itera por cada bloco de código capturado
        for i := 0 to codigo.Count-1 do
        begin
          item := TFonte(codigo.Items[i]);
          // Chama a função CapturaTabela
          tabelaList := CapturaJSONTabela(item.codigo);

          lbTables.Items.AddStrings(tabelaList);
        end;
     finally
        tabelaList.Free;
     end;

    end;
end;


procedure Tfrmmquery2.QuestionSQLEmbeleza;
var
  resposta : string;
  codigo : TCodigo;
  item : TFonte;
  i : integer;
  tabelaList: TStringList;
begin
  frmMNote.NewContext();
  frmMNote.edChat.text := sqlEstetica + edSQL.text;
  frmMNote.FazPergunta();
  if (frmMNote.meCodes.text<>'') then
  begin
      edSQL.text := frmMNote.meCodes.text;
  end;

(*
     if(FCHATGPT = nil) then
     begin
         FCHATGPT := TCHATGPT.create(self);
     end;
     //mequestion.Text := sqltabela + edSQL.text;

     FCHATGPT.TOKEN:= FSetMain.CHATGPT;
     if (FCHATGPT.SendQuestion(sqlEstetica + edSQL.text) ) then
     begin
        //Armazena pergunta historica
        resposta := FCHATGPT.Response;
     end
     else
     begin
       resposta := '';
     end;

     //Armazena no historico
     //meChatHist.Caption :=  meChatHist.Caption + #13+ #13+ 'Question: '+edChat.Text+#13;
     //meChatHist.Caption := meChatHist.Caption + 'Response: '+ resposta+#13;
     //meChatHist.Caption:=meChatHist.Caption+#13;

     //Armazena no Dialogo
     //meDialog.Caption :=  'Question: '+edChat.Text+#13;
     //meDialog.Caption := meDialog.Caption + 'Response: '+ resposta+#13;
     //meDialog.Caption:=meDialog.Caption+#13;


     //Captura o fonte
     // Captura os blocos de código
     codigo := TCodigo.create();
     if (resposta<>'') then
     begin
       codigo.AnalisaTexto(resposta);
     end;


      // Limpa o texto existente
      //meCodes.Clear;


      try
        // Itera por cada bloco de código capturado
        for i := 0 to codigo.Count-1 do
        begin
          item := TFonte(codigo.Items[i]);
          // Chama a função CapturaTabela
          //tabelaList := CapturaJSONTabela(item.codigo);
          // Aqui você pode adicionar o tipo e o código ao memo ou tratar conforme necessário
          //meCodes.Lines.Add('Tipo: ' + item.Tipo);
          //meCodes.Lines.text := meCodes.Lines.text + item.codigo;
          //lbTables.Items.AddStrings(tabelaList);
          edSQL.Text:=item.codigo;
        end;
      finally
        //tabelaList.Free;
      end;


      // Se houver pelo menos um bloco de código, foca no componente meCodes
      //if (codigo.Count > 0) then
        //tsCode.SetFocus;

     //edChat.Text:= '';
     *)

end;

procedure Tfrmmquery2.CriaTabela(NomeTabela: string; CSVDataSet: TCSVDataSet; ZQuery: TZQuery);
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

procedure Tfrmmquery2.MigraCampos(NomeTabela: string; CSVDataSet: TCSVDataSet; ZQuery: TZQuery);
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
      if i > 0 then
        colVals += ', ';
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
    edSQL.clear;
    edSQL.text := 'ok';

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

function Tfrmmquery2.TrocarPalavra(Info: String; de: String; para: String
  ): String;
begin
  Result := StringReplace(Info, de, para, [rfReplaceAll, rfIgnoreCase]);
end;



function Tfrmmquery2.FormataSQL(Info: string): string;
// começa em 1 (linha 0 geralmente é header)
var r: Integer;
begin
  // remove crases
  Info := StringReplace(Info, '`', '', [rfReplaceAll]);

  // quebra em palavras-chave
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

  // aplica equivalências da grid, se houver
  if Assigned(vlistequivalente) then
  begin

    for r := 1 to vlistequivalente.RowCount - 1 do
      Info := TrocarPalavra(Info, vlistequivalente.Cells[0, r], vlistequivalente.Cells[1, r]);
  end;

  Result := Info;
end;



procedure Tfrmmquery2.MontaCreateTrigger(Tabela : TTabela; posicao : integer);
begin
     edsql.Lines.clear;
     edsql.Lines.Append('create or replace function '+tabela.triggers.Triggername[posicao]+ '() ');
     edsql.Lines.Append('RETURNS TRIGGER as $'+  tabela.triggers.Triggername[posicao] +'$ ' );
     edsql.Lines.Append('BEGIN ');
     //edsql.text := edsql.text + FormataSQL(tabela.triggers.Source[posicao]);
     edsql.Lines.Append(' RETURN NULL; -- resultado é ignorado ');
     edsql.Lines.Append(' END; ');
     //edsql.text := edsql.text + FormataSQL(tabela.triggers.Source[posicao]);


     edsql.Lines.Append( '$'+tabela.triggers.Triggername[posicao]+'$ LANGUAGE plpgsql;');
     //edsql.Lines.Append( 'DROP TRIGGER IF EXISTS '+tabela.triggers.Triggername[posicao]+' '+#39+edSchemaPost.Text+#39+'.'+#39+tabela.triggers.tablename+#39+';');
     edsql.Lines.Append('create TRIGGER '+tabela.triggers.Triggername[posicao]+ ' ');
     edsql.Lines.Append(Tabela.triggers.Time[posicao]+ ' ' +tabela.triggers.Event[posicao] );
     edsql.Lines.Append(' on '+ tabela.triggers.tablename);
     //edsql.text := edsql.text + FormataSQL(tabela.triggers.Source[posicao]);
     edsql.Lines.Append( ' FOR EACH ROW ');
     edsql.Lines.Append( 'execute function '+tabela.triggers.Triggername[posicao]+'();');
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
      if (node.parent =posicaofieldsmy) then
      begin
       //edSQL.Text:= Node.Text;
       if Node.data <> nil then
       begin
           //edsql.Text:= GeraSQLMy(TTabela(Node.Data))
           tvMysql.PopupMenu := pmTabelasMy;
       end
       else
         edsql.Text:= 'no data';
      end
       else
      begin
        edSQL.Text:= '';
      end;
      (*Verifica se eh Avo da Tabela*)
      tvPai := node.Parent;
      if tvPai <> nil then
        tvAvo :=  tvPai.Parent;
      if tvAvo <> nil then
        tvBisavo := tvAvo.Parent;

      if (tvPai =  posicaoViewmy) then (*É um view*)
      begin
         View := TView.create(zmyqry1,node.Text,edBancoPost.text,DBMysql);
         edsql.Text :=  formatasql(view.definicao.text);
      end;

      if (tvBisavo = posicaofieldsmy) then (*Se o bisavo for tabelas*)
      begin
        if (tvPai.Text = 'Primary Key') then
        begin
            tvMysql.PopupMenu := popSeq;
        end;

        if((integer(tvPai.Data)) = IsETDTriggers()) then (*trigger*)
        begin
          tvMysql.PopupMenu := popmenuTrigger;

          Tabela := TTabela(TObject(tvAvo.Data));
          posicao := Tabela.triggers.Triggername.IndexOf(node.Text);
          MontaCreateTrigger(Tabela, posicao);

        end;
      end;

      if (node = posicaofieldsmy) then
      begin
        tvMysql.PopupMenu := pmTabelasMy;
      end;
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

  // colunas
  for a := 0 to Tabela.Count - 1 do
  begin
    if a > 0 then
      Comando += ',' + LineEnding;
    Comando += '  ' + Tabela.FieldName[a] + ' ' + TipoConv(Tabela, a);
  end;
  Comando += LineEnding;

  // primary key
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

  // foreign keys (se houver pares válidos)
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

  // comentários
  for a := 0 to Tabela.FieldName.Count - 1 do
    if Tabela.FieldComment[a] <> '' then
      Comando += 'COMMENT ON COLUMN ' + edSchemaPost.Text + '.' + Tabela.TableName + '.' +
                 Tabela.FieldName[a] + ' IS ' + QuotedStr(Tabela.FieldComment[a]) + ';' + LineEnding;

  Result := Comando;
end;

function Tfrmmquery2.TipoConv(Tabela : TTabela; Posicao: integer): String;
var
  output : string;
begin
  (* Tipo de dados string *)
  if Tabela.fieldtype[posicao] = 'char' then
  begin
    output := 'char('+Tabela.fieldstrtam[posicao]+')';

  end;
  if Tabela.fieldtype[posicao] = 'varchar' then output := 'varchar('+Tabela.fieldstrtam[posicao]+')';
  if Tabela.fieldtype[posicao] = 'text' then output := 'text ';
  if Tabela.fieldtype[posicao] = 'tinyblob' then output := 'tinyblob';
  if Tabela.fieldtype[posicao] = 'mediumtext' then output := 'text';


  (* Tipos de dados numericos *)
  if Tabela.fieldtype[posicao] = 'smallint' then output := 'smallint';
  if Tabela.fieldtype[posicao] = 'decimal' then output := 'decimal('+Tabela.fieldnro_precision[posicao]+','+Tabela.fieldbintam[posicao]+')';
  if Tabela.fieldtype[posicao] = 'float' then output := 'float('+Tabela.fieldbintam[posicao]+','+Tabela.fieldnro_precision[posicao]+')';
  if Tabela.fieldtype[posicao] = 'real' then output := 'real';
  if Tabela.fieldtype[posicao] = 'int' then
  begin
    if (Tabela.fieldcolumnkey[posicao] = 'PRI') then
    begin
        //output := 'int('+Tabela.fieldnro_precision[posicao]+')';
        output := 'integer';
    end
    else
    begin
      if strtoint(Tabela.fieldnro_precision[posicao])<3 then
          output := 'smallint';
      if    (strtoint(Tabela.fieldnro_precision[posicao])>=3)
        and (strtoint(Tabela.fieldnro_precision[posicao])<8) then
          output := 'integer';
      if    (strtoint(Tabela.fieldnro_precision[posicao])>=8)   then
          output := 'decimal('+Tabela.fieldnro_precision[posicao]+')' ;


    end;
  end;
  if Tabela.fieldtype[posicao] = 'integer' then
  begin
      output := 'integer';
  end;

  (*Tipos de dados Date Time *)
  if Tabela.fieldtype[posicao] = 'date' then output := 'Date';
  if Tabela.fieldtype[posicao] = 'datetime' then output := 'timestamp';
  if Tabela.fieldtype[posicao] = 'Time' then output := 'Time';
  if Tabela.fieldtype[posicao] = 'year' then output := 'interval[YEAR]';
  if Tabela.fieldtype[posicao] = 'time' then output := 'time';
  (*tipos binarios *)
  if Tabela.fieldtype[posicao] = 'blob' then output := 'bytea';
  if Tabela.fieldtype[posicao] = 'longblob' then output := 'bytea';

  (*Verifica se exige null*)
  if not(Tabela.fieldnullable[posicao] = 'YES') then
    Output := Output + ' NOT NULL ';
  (*Saida do processamento*)
  result := output;
end;

procedure Tfrmmquery2.ProcuraTVMysql(Nome: String);
var
  tv : TTreenode;
begin
   tv := posicaofieldsmy.FindNode(nome);
   if (tv <> nil) then
   begin
      tvMysql.Select(tv);
   end;
end;

procedure Tfrmmquery2.ProcuraTVPost(Nome: String);
var
  tv : TTreenode;
begin
   tv := posicaofieldspost.FindNode(nome);

   if (tv <> nil) then
   begin
      tvPost.Select(tv);
   end;

end;


procedure Tfrmmquery2.tvPostChange(Sender: TObject; Node: TTreeNode);
begin
  if(node = tvDatabasePost) then
  begin
      tvPost.PopupMenu := pmDatabasePost;
  end
  else
  begin
    if(node = tvTablePost) then
    begin
        //procuraTVMysql(Node.Text);
        ProcuraTVPost(Node.Text);
        //tvPost.PopupMenu := PopupMenuTblPost;
        tvPost.PopupMenu :=  pmTabelasPost;
    end
    else
    begin
        if (node <> nil) then
        begin
           //Tabela
           if(node.ImageIndex= 14) then
           begin
             tvPost.PopupMenu :=  pmTabelaPost;
           end
           else
           begin
             tvPost.PopupMenu := nil;
           end;
        end
        else
        begin
             tvPost.PopupMenu := nil;
        end;
    end;

  end;
  (*
  if (Node = posicaofieldspost) then
  begin
    tvPost.PopupMenu :=  pmTabelaPost;
  end;
  *)

end;

procedure Tfrmmquery2.tvPostClick(Sender: TObject);
begin

end;

procedure Tfrmmquery2.FormCreate(Sender: TObject);
var
  tvitem : TTreeNode;
begin
  TrayIcon1.Visible:= true;
  pgMain.PageIndex:=0;
  pgMysql.PageIndex:=0;
  tvitem := TTreeNode.Create(tvMysql.Items);
  tvitemmy := tvMysql.Items.AddObject(tvitem,'mysql', pointer(ETDBBanco));
  tvitemmy.ImageIndex:=-1;
  {$IFDEF WINDOWS}
  zconpost.LibraryLocation:= FSetMain.DLLPostPath;

  zconmysql.LibraryLocation:= FSetMain.DLLMyPath;
  {$ENDIF}
  {$IFDEF LINUX}
  //zconpost.LibraryLocation:= ExtractFilePath(application.exename) +'/libs/linux64/libpq74.so';
  if (FSetMain.DLLPostPath<> '') then
  begin
       zconpost.LibraryLocation:= FSetMain.DLLPostPath;
  end
  else
  begin
    ShowMessage('Set Postgre Path in config');
  end;
  //zconmysql.LibraryLocation:= ExtractFilePath(application.exename) +'/libs/linux64/libmysqlclient.so.21';
  if (FSetMain.DLLMyPath<>'') then
  begin
       zconmysql.LibraryLocation:= FSetMain.DLLMyPath;
  end
    else
  begin
    ShowMessage('Set Mysql Path in config');
  end;

  {$ENDIF}

  //Carrega o contexto
  edHostNamePost.Text :=FSetmain.HostnamePost;
  edBancoPost.text := FSetmain.BancoPOST;
  edusuarioPost.Text :=   FSetmain.UsernamePost;
  edPasswrdPost.Text :=   FSetmain.PasswordPost;
  edSchemaPost.text :=   FSetmain.SchemaPost;


  tvitem := TTreeNode.Create(tvPost.Items);
  tvitempost := tvpost.Items.AddObject(tvitem,'Postgres', pointer(ETDBBanco));
  tvitempost.ImageIndex:=-1;


end;

procedure Tfrmmquery2.setSelLength(var textComponent:TSynEdit; newValue:integer);
begin
textComponent.SelEnd:=textComponent.SelStart+newValue ;
end;

procedure Tfrmmquery2.Analisemy(SQL: String);
begin
   lbTables.Items.Clear;
   QuestionSQLChatMy();
   //lbTables.Items := PegaTabelas(sql);
end;

procedure Tfrmmquery2.Analisepost(SQL: String);
begin
   lbTables.Items.Clear;
   QuestionSQLChatPost();
end;

procedure Tfrmmquery2.lstfindClick(Sender: TObject);
var
   find : TFinds;
   res : boolean;

begin

    If lstFind.SelCount > 0 then
    begin


        find := TFINDS(lstFind.items.objects[lstFind.ItemIndex]);
        //pgMain.ActivePage := find.tb;
        FPOS := find.IPOS;


        FPos := find.IPos + length(find.strFind);
        //   Hoved.BringToFront;       {Edit control must have focus in }
        find.syn.SetFocus;
        Self.ActiveControl := find.syn;
        find.syn.SelStart:= find.IPos;  // -1;   mike   {Select the string found by POS}
        setSelLength(find.syn, find.FLen);     //edErro.SelLength := FLen;
        //Found := True;
        FPos:=FPos+find.FLen-1;   //mike - move just past end of found item

    end;

end;

procedure Tfrmmquery2.dropPostClick(Sender: TObject);
var
  item : TTreeNode;
  tvPai : TTreeNode;
  tvAvo : TTreeNode;
  schema, tableName: string;
begin
  item  := tvPost.Selected;
  if item = nil then Exit;

  tvPai := item.Parent;
  tvAvo := nil;
  if tvPai <> nil then
    tvAvo := tvPai.Parent;

  tableName := item.Text;

  // se tiver schema definido, usa
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
  for a:= 0 to tvMysql.Items.Count-1 do
  begin
    if ((tvMysql.items[a].Parent = posicaofieldsmy) and (tvMysql.items[a].Parent.Data = pointer(ETDTabelas)) ) then
    begin
      tvMysql.items[a].Collapse(true);
    end;
  end;
end;

procedure Tfrmmquery2.PostApagaTabela(Nome: string);
begin
    edSQL.text := 'drop table '+nome;
    zpostqry.sql.Text:= edSQL.text;
    try
    zpostqry.ExecSQL;
    edSQL.Append('Executado com sucesso!');
    except
      showmessage('Falha na execução');
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
  nome := tvPost.Selected.text;
  //nome := TTreeNode(sender).text;
  PostApagaTabela(nome);
end;

procedure Tfrmmquery2.MenuItem5Click(Sender: TObject);
begin
  SaveDialog1.Title:= 'Salvar SQL';

  if SaveDialog1.Execute then
  begin
       edSQL.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure Tfrmmquery2.MenuItem6Click(Sender: TObject);
begin

end;

procedure Tfrmmquery2.MenuItem8Click(Sender: TObject);
begin
  pnBotton.Visible:= false;
end;

procedure Tfrmmquery2.miCFunctionClick(Sender: TObject);
var
  tvBisavo : TTreeNode;
  tvAvo : TTreeNode;
  tvPai : TTreeNode;
  view : TView;
  Tabela : TTabela;
  posicao : integer;
  Node: TTreeNode;
begin
  Node := tvMysql.Selected;
  tvPai := Node.Parent;
  tvAvo := tvPai.Parent;
  Tabela := TTabela(TObject(tvAvo.Data));
  posicao := Tabela.triggers.Triggername.IndexOf(node.Text);
  edsql.Lines.clear;
  edsql.Lines.Append('create or replace function '+tabela.triggers.Triggername[posicao]+ '() ');
  edsql.Lines.Append('RETURNS TRIGGER as $'+  tabela.triggers.Triggername[posicao] +'$ ' );
  //edsql.Lines.Append('BEGIN ');
  edsql.text := edsql.text + FormataSQL(tabela.triggers.Source[posicao]);
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
  tvPai : ttreenode;
  tvAvo : ttreenode;
  syn1 : TSynEdit;

begin
  ts :=  frmMNote.NovoItem();
  item := TItem(ts.Tag);

  syn1 := item.syn;
  syn1.Text := edsql.Lines.text;

end;

procedure Tfrmmquery2.miCreateClick(Sender: TObject);
begin
  edsql.Text:= GeraSQLMy(TTabela(tvMysql.Selected.Data))
end;

procedure Tfrmmquery2.miCTriggerClick(Sender: TObject);
var
  tvBisavo : TTreeNode;
  tvAvo : TTreeNode;
  tvPai : TTreeNode;
  view : TView;
  Tabela : TTabela;
  posicao : integer;
  Node: TTreeNode;
begin
   Node := tvMysql.Selected;
   tvPai := Node.Parent;
   tvAvo := tvPai.Parent;
   Tabela := TTabela(TObject(tvAvo.Data));
   posicao := Tabela.triggers.Triggername.IndexOf(node.Text);
   edsql.Lines.clear;
   edsql.Lines.Append('create or replace trigger '+tabela.triggers.Triggername[posicao]+ ' ');
   edsql.Lines.Append(Tabela.triggers.Time[posicao]+ ' ' +tabela.triggers.Event[posicao] );
   edsql.Lines.Append(' on '+ tabela.triggers.tablename);
   //edsql.text := edsql.text + FormataSQL(tabela.triggers.Source[posicao]);
   edsql.text := ' FOR EACH ROW ';
   edsql.text := 'execute function fnc_'+tabela.triggers.Triggername[posicao]+'();';

end;

procedure Tfrmmquery2.miDescricaoPostClick(Sender: TObject);
var
item : ttreenode;
begin
  item := tvPost.Selected;

  edSQLPost.Text:= DescreveTabelaIAPost(item.Text);
  pcPostgree.ActivePage := tsSQLPostgreSQL;
end;

procedure Tfrmmquery2.midropClick(Sender: TObject);

  var
  item : ttreenode;
  tvPai : ttreenode;
  tvAvo : ttreenode;
begin
  item := tvMysql.Selected;
  tvPai := item.parent;
  tvAvo := tvPai.parent;
  //ShowMessage(item.text);
  edSQL.clear;
  edSQL.Lines.text := '';
  edSql.Lines.Append('drop table '+ item.text );
  pgMysql.ActivePage := tbSQL;
  //edSql.SetFocus;
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
var
   tb : TTabSheet;
begin
  FontDialog1.Font :=  edSQL.Font;
  if FontDialog1.Execute then
  begin
      edSQL.Font := FontDialog1.Font;
  end;

end;

procedure Tfrmmquery2.miIAClick(Sender: TObject);
begin
  pnIA.Visible:=not pnIA.Visible;
end;

procedure Tfrmmquery2.miMostrarClick(Sender: TObject);
begin
  Show;
end;

procedure Tfrmmquery2.miBenchmarkClick(Sender: TObject);
begin
   frmBenchmark := TfrmBenchmark.create(self);
   frmBenchmark.showmodal;
end;

procedure Tfrmmquery2.MenuItem9Click(Sender: TObject);
begin
  exit;
end;

procedure Tfrmmquery2.miNovaPesquisaClick(Sender: TObject);
begin
  FPos:= 0;
  if FindDialog1.Execute then
  begin

  end;
end;

procedure Tfrmmquery2.miOcultarClick(Sender: TObject);
var
   a : integer;
begin
  for a:= 0 to tvPost.Items.Count-1 do
  begin
    if ((tvPost.items[a].Parent = posicaofieldspost) and (tvPost.items[a].Parent.Data = pointer(ETDTabelas)) ) then
    begin
      tvPost.items[a].Collapse(true);
    end;
  end;
end;

procedure Tfrmmquery2.miOcultarPostClick(Sender: TObject);
begin

end;

procedure Tfrmmquery2.miRelacionamentosClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  {$IFDEF WINDOWS}
  // AppData (config do app). Se preferir Roaming, use APPDATA.
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dependencias_post.sql';

  edSQLPost.Text := CriaListaDependenciasPost(fileName);
  ShowMessage('Dependências salvas em:' + LineEnding + fileName);
end;

procedure Tfrmmquery2.miselectClick(Sender: TObject);
var
  item : ttreenode;
  tvPai : ttreenode;
  tvAvo : ttreenode;
begin
  item := tvMysql.Selected;
  tvPai := item.parent;
  tvAvo := tvPai.parent;
  //ShowMessage(item.text);
  edSQL.clear;
  edSQL.Lines.text := '';
  //edSql.Lines.Append('--Select criada tabela '+ item.text);
  edSql.Lines.Append('select * from '+ item.text + ' limit 1000 ');
  pgMysql.ActivePage := tbSQL;
  //edSql.SetFocus;



end;

procedure Tfrmmquery2.mnCriaDicionarioClick(Sender: TObject);
begin

end;

procedure Tfrmmquery2.mnCriarSeqClick(Sender: TObject);
var
  item : ttreenode;
  tvPai : ttreenode;
  tvAvo : ttreenode;

begin
  item := tvMysql.Selected;
  tvPai := item.parent;
  tvAvo := tvPai.parent;
  //ShowMessage(item.text);
  edSQL.clear;
  edSql.Lines.Append('--Sequence criada tabela '+ tvAvo.text);
  edsql.lines.append('create sequence sq_'+item.text);
  edsql.Lines.append(' INCREMENT 1 ');
  edSQL.Lines.Append('START 1;');

  pgMain.ActivePage := tbSQL;
  edSql.SetFocus;
end;

procedure Tfrmmquery2.mnDicionarioClick(Sender: TObject);
var
  baseDir, fileName: string;
begin
  {$IFDEF WINDOWS}
  // AppData do usuário (pasta de configuração da aplicação)
  baseDir := GetAppConfigDir(False);      // ex.: C:\Users\<user>\AppData\Local\<AppName>\
  {$ELSE}
  // Linux/macOS: pasta do usuário
  baseDir := GetUserDir;                  // ex.: /home/<user>/
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario.sql';

  // injeta o caminho por parâmetro
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
   b : integer;
   pai : TTreeNode;
   contador : integer;
begin
   edSQL.Lines.clear;
   contador := 0;
   pai := nil;
   edSQL.Lines.Append('Relação de Triggers do Mysql');
   for a := 0 to tvMysql.Items.Count-1 do
   begin
     if (tvMysql.Items[a].Data =  pointer(ETDTriggers))  then
     begin
        if (TtreeNode(tvMysql.Items[a].Parent).text <> 'campos') then
        begin
          pai := tvMysql.Items[a] ;
          edSQL.Lines.append(' ');
          edSQL.Lines.Append('Tabela:'+ TtreeNode(tvMysql.Items[a].Parent).text);
        end;
     end
     else
     begin
       if (tvMysql.Items[a].Parent = pai)  and (pai <> nil) then
       begin
         edSQL.Lines.Append('Trigger:'+ tvMysql.Items[a].Text);
         inc(contador);
       end;
     end;

   end;
   edSql.Lines.Append('Total de Triggers:'+inttostr(contador));
end;

procedure Tfrmmquery2.mnRefreshClick(Sender: TObject);
begin
  ListarTabelasPost();
end;

procedure Tfrmmquery2.niPesquisarClick(Sender: TObject);
begin
  strFind:= findDialog1.FindText;
  Pesquisar(Sender);
end;

procedure Tfrmmquery2.PageControl1Change(Sender: TObject);
begin

end;

procedure Tfrmmquery2.SpeedButton1Click(Sender: TObject);
begin
  vlistequivalente.RowCount:= vlistequivalente.RowCount+1;
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

// ==== implementation ====
function Tfrmmquery2.ConectMy: Boolean;
begin
  Result := False;

  // Garante desconexão limpa
  if zconmysql.Connected then
    zconmysql.Disconnect;

  {$IFDEF WINDOWS}
  // Caminhos das DLLs
  // Deixe o Postgres para o bloco do Postgres; aqui só MySQL:
  // Se você já usa um path centralizado:
  if (FSetMain <> nil) and (FSetMain.DLLMyPath <> '') then
  begin
    zconmysql.LibraryLocation := FSetMain.DLLMyPath;
  end
  else
    zconmysql.LibraryLocation := ExtractFilePath(Application.ExeName) + 'libmysql.dll';
  {$ENDIF}

  {$IFDEF LINUX}
  zconmysql.LibraryLocation := ExtractFilePath(Application.ExeName) + 'libs/linux64/libmysqlclient.so.21';
  {$ENDIF}

  // Parâmetros de conexão
  zconmysql.Database := edBanco.Text;
  zconmysql.HostName := edHostName.Text;
  zconmysql.User     := edusuario.Text;
  zconmysql.Password := edPasswrd.Text;


  // Se usar porta: zconmysql.Port := StrToIntDef(edPortaMy.Text, 3306);

  // Opcional: guardar no FSetMain (segue seu padrão)
  if FSetMain <> nil then
  begin
    FSetMain.HostnameMy   := edHostName.Text;
    FSetMain.BancoMy      := edBanco.Text;
    FSetMain.UsernameMy   := edusuario.Text;
    FSetMain.PasswordMy   := edPasswrd.Text;
    // FSetMain.SchemaMy  := ''; // MySQL não usa schema como o Postgres (usa database)
  end;

  try
    zconmysql.Connect;
    Result := zconmysql.Connected;
  except
    on E: Exception do
    begin
      // Falha silenciosa, quem chama decide UI
      Result := False;
    end;
  end;
end;

function Tfrmmquery2.DescreveTabelaIAPost(tabela: string): string;
var
  createSQL: TStringList;
  schema, colName, dataType, typeStr, isNullable, colDefault: string;
  charLen, numPrec, numScale: Integer;
  hasCharLen, hasNumPrec, hasNumScale: Boolean;
  pkCols: TStringList;
  i: Integer;
begin
  Result := '';

  if not zconpost.Connected then
    Exit;

  schema := Trim(edSchemaPost.Text);
  if schema = '' then
    schema := 'public';

  // Colunas + metadados (tamanho, precisão, default, nulidade)
  Zqrypost.Close;
  Zqrypost.SQL.Text :=
    'SELECT column_name, data_type, ' +
    '       character_maximum_length, numeric_precision, numeric_scale, ' +
    '       is_nullable, column_default ' +
    'FROM information_schema.columns ' +
    'WHERE table_schema = ' + QuotedStr(schema) + ' AND table_name = ' + QuotedStr(tabela) + ' ' +
    'ORDER BY ordinal_position';
  Zqrypost.Open;

  if Zqrypost.IsEmpty then
    Exit; // tabela não encontrada

  // Primary Key (ordem correta)
  pkCols := TStringList.Create;
  pkCols.Sorted := False;
  try
    zpostqry1.Close;
    zpostqry1.SQL.Text :=
      'SELECT kcu.column_name ' +
      'FROM information_schema.table_constraints tc ' +
      'JOIN information_schema.key_column_usage kcu ' +
      '  ON kcu.constraint_name = tc.constraint_name ' +
      ' AND kcu.table_schema = tc.table_schema ' +
      ' AND kcu.table_name   = tc.table_name ' +
      'WHERE tc.table_schema = :schema ' +
      '  AND tc.table_name   = :tbl ' +
      '  AND tc.constraint_type = ''PRIMARY KEY'' ' +
      'ORDER BY kcu.ordinal_position';
    zpostqry1.ParamByName('schema').AsString := schema;
    zpostqry1.ParamByName('tbl').AsString    := tabela;
    zpostqry1.Open;
    while not zpostqry1.EOF do
    begin
      pkCols.Add(zpostqry1.FieldByName('column_name').AsString);
      zpostqry1.Next;
    end;

    // Montagem do CREATE
    createSQL := TStringList.Create;
    try
      createSQL.Add('CREATE TABLE ' + schema + '.' + tabela + ' (');

      Zqrypost.First;
      i := 0;
      while not Zqrypost.EOF do
      begin
        colName    := Zqrypost.FieldByName('column_name').AsString;
        dataType   := Zqrypost.FieldByName('data_type').AsString;
        isNullable := Zqrypost.FieldByName('is_nullable').AsString;
        if not Zqrypost.FieldByName('column_default').IsNull then
          colDefault := Zqrypost.FieldByName('column_default').AsString
        else
          colDefault := '';

        hasCharLen := not Zqrypost.FieldByName('character_maximum_length').IsNull;
        if hasCharLen then
          charLen := Zqrypost.FieldByName('character_maximum_length').AsInteger;

        hasNumPrec := not Zqrypost.FieldByName('numeric_precision').IsNull;
        if hasNumPrec then
          numPrec := Zqrypost.FieldByName('numeric_precision').AsInteger;

        hasNumScale := not Zqrypost.FieldByName('numeric_scale').IsNull;
        if hasNumScale then
          numScale := Zqrypost.FieldByName('numeric_scale').AsInteger;

        // Normaliza tipo com tamanho/precisão quando aplicável
        if SameText(dataType, 'character varying') then
        begin
          if hasCharLen then typeStr := Format('VARCHAR(%d)', [charLen]) else typeStr := 'VARCHAR';
        end
        else if SameText(dataType, 'character') then
        begin
          if hasCharLen then typeStr := Format('CHAR(%d)', [charLen]) else typeStr := 'CHAR';
        end
        else if SameText(dataType, 'numeric') or SameText(dataType, 'decimal') then
        begin
          if hasNumPrec then
          begin
            if hasNumScale then
              typeStr := Format('NUMERIC(%d,%d)', [numPrec, numScale])
            else
              typeStr := Format('NUMERIC(%d)', [numPrec]);
          end
          else
            typeStr := 'NUMERIC';
        end
        else if SameText(dataType, 'timestamp without time zone') then typeStr := 'TIMESTAMP'
        else if SameText(dataType, 'timestamp with time zone')  then typeStr := 'TIMESTAMPTZ'
        else if SameText(dataType, 'time without time zone')    then typeStr := 'TIME'
        else if SameText(dataType, 'time with time zone')       then typeStr := 'TIMETZ'
        else if SameText(dataType, 'double precision')          then typeStr := 'DOUBLE PRECISION'
        else if SameText(dataType, 'integer')                   then typeStr := 'INTEGER'
        else if SameText(dataType, 'bigint')                    then typeStr := 'BIGINT'
        else if SameText(dataType, 'smallint')                  then typeStr := 'SMALLINT'
        else if SameText(dataType, 'boolean')                   then typeStr := 'BOOLEAN'
        else if SameText(dataType, 'text')                      then typeStr := 'TEXT'
        else if SameText(dataType, 'date')                      then typeStr := 'DATE'
        else if SameText(dataType, 'bytea')                     then typeStr := 'BYTEA'
        else
          typeStr := UpperCase(dataType);

        // vírgula na linha anterior (exceto primeira)
        if i > 0 then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ',';

        // linha da coluna
        createSQL.Add('  ' + colName + ' ' + typeStr);

        // DEFAULT (usa expressão exatamente como no catálogo)
        if colDefault <> '' then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' DEFAULT ' + colDefault;

        // NOT NULL
        if SameText(isNullable, 'NO') then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' NOT NULL';

        Inc(i);
        Zqrypost.Next;
      end;

      // PRIMARY KEY
      if pkCols.Count > 0 then
      begin
        createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ',';
        createSQL.Add('  CONSTRAINT ' + tabela + '_pkey PRIMARY KEY (' +
                      StringReplace(pkCols.CommaText, ',', ', ', [rfReplaceAll]) + ')');
      end;

      createSQL.Add(');');

      Result := createSQL.Text;
    finally
      createSQL.Free;
    end;
  finally
    pkCols.Free;
  end;
end;

procedure Tfrmmquery2.RefreshMy();
var
  tvitem: TTreeNode;
begin
  // Limpa nós anteriores
  tvitemmy.DeleteChildren;

  // Tenta conectar
  if not ConectMy then
  begin
    MessageHint('Erro ao conectar no MySQL. Verifique host/usuário/senha/banco e a libmysql.');
    Exit;
  end;

  try
    // Conectado: monta a árvore
    tvitem := TTreeNode.Create(tvMysql.Items); // para manter seu padrão de criação
    tvitemmy.Text       := edBanco.Text;
    tvitemmy.ImageIndex := 13;

    posicaofieldsmy     := tvMysql.Items.AddChildObject(tvitemmy, 'Tables',    Pointer(ETDTabelas));
    posicaofieldsmy.ImageIndex := 15;
    posicaoViewmy       := tvMysql.Items.AddChildObject(tvitemmy, 'Views',     Pointer(ETDViews));
    posicaoProceduremy  := tvMysql.Items.AddChildObject(tvitemmy, 'Procedure', Pointer(ETDProcedure));
    posicaoFunctionmy   := tvMysql.Items.AddChildObject(tvitemmy, 'Functions', Pointer(ETDFunctions));

    // Popular nós
    ListarTabelasMy();
    ListarViewsMy();
  except
    on E: Exception do
    begin
      MessageHint('Erro ao preparar estrutura do MySQL: ' + E.Message);
      Exit;
    end;
  end;
end;

procedure Tfrmmquery2.btConectarMyClick(Sender: TObject);
begin
  refreshMy();
end;


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
       edSQL.text  := 'create database '+#39+banco+#39+';';
       zqrypost.sql.text := edSQL.text;
       Zqrypost.ExecSQL;
  end
  else
  begin
     showmessage('Postgres não conectado!');
  end;
end;

procedure Tfrmmquery2.btAnaliseClick(Sender: TObject);
begin
   AnaliseMy(edSQL.Lines.Text);
end;

procedure Tfrmmquery2.btbenchmarkClick(Sender: TObject);
begin

end;

procedure Tfrmmquery2.btChartClick(Sender: TObject);
begin
  ChartView(ccMySQL);   // força Postgres
end;

procedure Tfrmmquery2.btChartPostClick(Sender: TObject);
begin
    ChartView(ccPostgres);      // força MySQL
end;

procedure Tfrmmquery2.btcompararClick(Sender: TObject);
var
  a : integer;
  nodeachado : TTreeNode;
  nome : string;
  achou : boolean;
begin
  edSQL.Lines.clear;
  for a:=  2 to tvMysql.Items.Count-1 do
  begin
      nome :=  tvMysql.Items[a].text;
      nodeachado :=tvPost.Items.FindNodeWithText(nome);
      if nodeachado = nil then
      begin
          achou := false;
          if (nome <> 'linha') then
          begin
              if (tvMysql.Items[a].Parent = posicaofieldspost) then
              begin
                   edSQL.Lines.Append('Não encontrou tabela:'+nome);
                   achou := true;
              end;
              if (tvMysql.Items[a].Parent = posicaoViewPost) then
              begin
                   edSQL.Lines.Append('Não encontrou View:'+nome);
                   achou := true;
              end;
              if (tvMysql.Items[a].Parent = posicaoFunctionPost) then
              begin
                   edSQL.Lines.Append('Não encontrou Function:'+nome);
                   achou := true;
              end;
              if (tvMysql.Items[a].Parent = posicaoProcedurePost) then
              begin
                   edSQL.Lines.Append('Não encontrou Procedure:'+nome);
                   achou := true;
              end;
              (*
              if (tvMysql.Items[a].Parent = posicaoSequencePost) then
              begin
                   edSQL.Lines.Append('Não encontrou Sequencia:'+nome);
                   achou := true;
              end;
              *)


              if (achou = false) then
              begin
                   edSQL.Lines.Append('Não encontrou item:'+nome);
              end;

          end;

      end;

  end;

   //tbSQL.SetFocus;
   //pgMain.Pages[].SetFocus;
   ShowMessage('Finalizou a pesquisa!');
end;

procedure Tfrmmquery2.btExecutar1Click(Sender: TObject);
begin
  try
    zpostqry1.close;
    zpostqry1.sql.text := edSQLPost.Lines.Text;


    dspos.DataSet := zpostqry1;
    edlog.Append('SQL OPEN:'+edSQLPost.Lines.Text);
    dbnavpost.DataSource := dspos;
    dbgridpost.DataSource := dspos;

    zpostqry1.Prepare;
    zpostqry1.open;
    pcPostgree.ActivePage := tsGridPostgres;

  except
     on E: Exception do
     begin
          edLog.Append('Error:'+e.message);
          ShowMessage('Error:'+e.message);
     end;

  end;
end;

procedure Tfrmmquery2.btExecutarClick(Sender: TObject);
begin
  try
    //zpostqry1.sql.text := edSQL.Lines.Text;
   zmyqry2.sql.text := edSQL.Lines.Text;    ;

    dsmy.DataSet := zmyqry2;
    edlog.Append('SQL OPEN:'+edSQL.Lines.Text);
    dbnavmy.DataSource := dsmy;
    dbgridmy.DataSource := dsmy;

    zmyqry2.Open;
    //zpostqry1.open;
    pgMysql.ActivePage := tsgrid;
  except
     on E: Exception do
     begin
          edLog.Append('Error:'+e.message);
          ShowMessage('Error:'+e.message);
     end;

  end;

end;

procedure Tfrmmquery2.btIAPostClick(Sender: TObject);
var
  deps, ddl, sqlIA: string;
begin
  // Se preferir, passe strings vazias e a função monta internamente
  deps  := CriaListaDependenciasPost('');
  ddl   := CriaDicionarioPost('');
  sqlIA := QuestionarSQLPost(meIA.text, deps, ddl);
  edSQLPost.Text := sqlIA;
  edLogPost.Append('Question:'+meIA.text);
  edLogPost.Append('Return:'+sqlIA);

end;

procedure Tfrmmquery2.btImportCSVClick(Sender: TObject);
var
  tabela : string;
begin
  OpenDialog1.DefaultExt:='*.csv';
  if(zconmysql.Connected) then
  begin
    if(OpenDialog1.Execute) then
    begin
         try
           CSVDataset1.FileName:= OpenDialog1.FileName;
           CSVDataset1.CSVOptions.Delimiter:=';';
           CSVDataset1.CSVOptions.FirstLineAsFieldNames := true;
           CSVDataset1.open;
           tabela := InputBox('Table Create','table name:','newtable01');
           if(tabela <> '') then
           begin
               CriaTabela(tabela,CSVDataSet1, ZQryTransf);
               MigraCampos(tabela, CSVDataSet1,ZQryTransf);
           end;
         except
         on E: Exception do
           begin
                // Trate o erro conforme necessário
                ShowMessage('Erro ao carregar arquivo CSV: ' + E.Message);
           end;
         end;
    end;
  end
  else
  begin
    ShowMessage('Database Mysql no connection!');
  end;
end;

procedure Tfrmmquery2.btJSONClick(Sender: TObject);
var
  ts : TTabSheet;
  item : TItem;
  tvPai : ttreenode;
  tvAvo : ttreenode;
  syn1 : TSynEdit;

begin
  ts :=  frmMNote.NovoItem();
  item := TItem(ts.Tag);

  syn1 := item.syn;
  case cbMake.ItemIndex of
       0:   //JSON
       begin
           syn1.text :=  DatasetToJsonString( dbgridmy.DataSource.DataSet);
       end;
       1: //CSV
       begin
         syn1.text :=  DatasetTocsvString( dbgridmy.DataSource.DataSet);

       end;
  end;

end;

procedure Tfrmmquery2.btConectarpostClick(Sender: TObject);
begin
     refreshPost();
end;

procedure Tfrmmquery2.btExecuteClick(Sender: TObject);
begin
    try
    zpostqry.sql.text := edSQLPost.Lines.Text;

    dsmy.DataSet := nil;
    dbnavpost.DataSource := nil;
    dbgridpost.DataSource := nil;
    edLog.Append('SQL Execute:'+edSQLPost.Lines.Text);
    zpostqry.ExecSQL;

  except
     on E: Exception do
     begin
          ShowMessage('Error:'+e.message);
          edLog.Append('Error:'+e.message);
     end;
  end;
end;

// Na seção implementation da mesma unit
function Tfrmmquery2.ConectPost: Boolean;
begin
  Result := False;

  // Sempre começa desconectando
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

  // Credenciais / alvo
  zconpost.HostName := edHostNamePost.Text;
  zconpost.User     := edusuarioPost.Text;
  zconpost.Password := edPasswrdPost.Text;
  // Se você tiver o edit do DB/schema, preencha:
  if Assigned(edBancoPost) then
    zconpost.Database := edBancoPost.Text;

  // Guarda no FSetMain (opcional, mas mantive seu fluxo)
  FSetmain.HostnamePost  := edHostNamePost.Text;
  FSETMAIN.SchemaPost    := edSchemaPost.text;
  FSetmain.BancoPOST     := edBancoPost.Text;
  FSetmain.UsernamePost  := edusuarioPost.Text;
  FSetmain.PasswordPost  := edPasswrdPost.Text;
  FSetMain.SalvaContexto(false);
  // Se tiver um edit de schema, coloque aqui:
  // FSetmain.SchemaPost := edSchemaPost.Text;

  try
    zconpost.Connect;
    Result := zconpost.Connected;
  except
    on E: Exception do
    begin
      // Não dispara UI aqui — apenas falha silenciosa e retorna False
      // A UI fica por conta do chamador (RefreshPost)
      Result := False;
    end;
  end;
end;

procedure Tfrmmquery2.RefreshPost;
var
  tvitem: TTreeNode;
begin
  tvitempost.DeleteChildren;
  SynSQLSyn2.TableNames.Clear;

  // Tenta conectar. Se falhar, avisa e sai.
  if not ConectPost then
  begin
    MessageHint('Erro ao conectar no PostgreSQL. Verifique host/usuário/senha/banco e a libpq.');
    Exit;
  end;

  try
    // Conectado: monta a árvore/estruturas
    tvitem := TTreeNode.Create(tvPost.Items); // mantém seu padrão
    tvitempost.Text := edBancoPost.Text;
    tvitempost.ImageIndex := 13;
    tvDatabasePost := tvitemPost;  //Atribui para o database post

    posicaofieldspost    := tvPost.Items.AddChildObject(tvDatabasePost, 'tables',    Pointer(ETDTabelas));
    posicaofieldspost.ImageIndex := 15;
    tvTablePost := posicaofieldspost; //Atribui para as tabelas
    posicaoSequencePost  := tvPost.Items.AddChildObject(tvDatabasePost, 'Sequences', Pointer(ETDTabelas));
    posicaoViewPost      := tvPost.Items.AddChildObject(tvDatabasePost, 'Views',     Pointer(ETDViews));
    posicaoProcedurePost := tvPost.Items.AddChildObject(tvDatabasePost, 'Procedure', Pointer(ETDProcedure));
    posicaoFunctionPost  := tvPost.Items.AddChildObject(tvDatabasePost, 'Functions', Pointer(ETDFunctions));

    // Popula nós
    ListarTabelasPost();
    BuscaSequence(zpostqry1, DBPostgres);
    ListarViewsPost();
  except
    on E: Exception do
    begin
      MessageHint('Erro ao preparar estrutura do PostgreSQL: ' + E.Message);
      Exit;
    end;
  end;
end;




procedure Tfrmmquery2.Pesquisar(sender: TObject);
Var
     finds : TFinds;
     syn : TSynEdit;
     //item : TItem;
     tb : TTabsheet;
     arquivo : string;
     Findstr: String;
     Found : boolean;
     IPos, FLen, SLen: Integer; {Internpos, Lengde søkestreng, lengde memotekst}
     Res : integer;
begin
    //IPOS := 0;
    //FPOS := 0;
    syn := edSQL;
    //item := TItem(syn.tag);

    {FPos is global}
    Found:= False;
    FLen := Length(strFind);
    SLen := Length(syn.Text);
    Findstr := findDialog1.FindText;
    lstFind.Items.clear;

    repeat

       //following 'if' added by mike
       if frMatchcase in findDialog1.Options then
          IPos := Pos(strFind, Copy(syn.Text,FPos+1,SLen-FPos))
       else
          IPos := Pos(AnsiUpperCase(strFind),AnsiUpperCase( Copy(syn.Text,FPos+1,SLen-FPos)));

       if (IPOS>0) then
       begin
         FPos := FPos + IPos;
         ///constructor create(fsyn: TSynEdit; ftb: TTabSheet; fitem: TItem; FIPOS: integer; fstrFind : string);
         finds := TFinds.create(syn ,tb, nil,FPOS, strFind);

         lstFind.Items.AddObject('Pos:'+inttostr(FPOS),tobject(finds));

       end
       else
       begin
         FPOS := 0;
         break;
       end;
    until (IPOS <=0);

    If lstFind.Count > 0 then begin
      pnBotton.Visible:= true;
    end
    Else
    begin
      pnBotton.Visible:= false;
      Res := Application.MessageBox('Text was not found!',
             'Find',  mb_OK + mb_ICONWARNING);
      FPos := 0;     //mike  nb user might cancel dialog, so setting here is not enough
    end;             //   - also do it before exec of dialog.

end;

function Tfrmmquery2.RectIsEmpty(const aRect:TRect):Boolean;
begin
  Result :=  (aRect.Left  = 0) and (aRect.Top    = 0)
         and (aRect.Right = 0) and (aRect.Bottom = 0);
end;


function Tfrmmquery2.ToRect(const aTopLeft, aBottomRight:TPoint):TRect; overload;
begin
  Result.TopLeft     := aTopLeft;
  Result.BottomRight := aBottomRight;
end;

function Tfrmmquery2.ToRect(const aTop, aLeft, aBottom, aRight : LongInt):TRect; overload;
begin
  Result.Top    := aTop;
  Result.Left   := aLeft;
  Result.Bottom := aBottom;
  Result.Right  := aRight;
end;

function Tfrmmquery2.RectInRect(const aOuterRect, aInnerRect: TRect): Boolean;
begin
  Result := (aInnerRect.Left   >= aOuterRect.Left) and (aInnerRect.Left   <= aOuterRect.Right)  and
            (aInnerRect.Right  >= aOuterRect.Left) and (aInnerRect.Right  <= aOuterRect.Right)  and
            (aInnerRect.Top    >= aOuterRect.Top)  and (aInnerRect.Top    <= aOuterRect.Bottom) and
            (aInnerRect.Bottom >= aOuterRect.Top)  and (aInnerRect.Bottom <= aOuterRect.Bottom);
end;


procedure Tfrmmquery2.ProcessaErro(message: string);
var
     pos1 : integer;
     pos2 : integer;
     pos3 : integer;
     linha : integer;
     info : string;
     info2 : string;
     bloco : string;
     Resultado : integer;
     FSearchOpts:TSynSearchOptions;
     FSrch_rng: TPoint;
     FInBlock : TRect;
     vOutOfBlock :Boolean;
begin
     pos1 := pos('LINE ',message);
     if (pos1 <> 0) then
     begin
          info := copy(message,pos1+4,length(message)-(pos1+4));
          pos2 := pos (':',info);
          info2 := copy(info,1,pos2-1);
          linha := strtoint(info2);
          pos1 := pos(info,':')+1;

          info2 := copy(info,pos1,length(info));
          bloco := copy(info2, pos(':',info2)+2,pos(#10,info2)-(pos(':',info2)+2));
          Resultado := edsql.SearchReplaceEx(bloco, bloco, FSearchOpts, FSrch_rng);
          if  (Resultado > 0) then
          begin
              (*
              if (not RectIsEmpty(FInBlock)) and (not RectInRect(FInBlock,ToRect(edsql.BlockBegin, edsql.BlockEnd))) then
              begin
                 vOutOfBlock := True;
                 Resultado := 0;
              end;
              *)
              //edSQL.BlockBegin := FInBlock.;
          end;
     end;
end;

procedure Tfrmmquery2.Button3Click(Sender: TObject);
var
  tvitem : TTreeNode;
  isCreateTable, isCreateSequence: Boolean;
begin
  try
    pnErro.Visible := False;

    if zconpost.Connected then
    begin
      isCreateTable   := AnsiContainsText(edSQL.Lines.Text, 'create table');
      isCreateSequence:= AnsiContainsText(edSQL.Lines.Text, 'create sequence');

      if isCreateTable then
      begin
        // verifica no tree do MySQL (você fazia isso), mantendo a lógica
        tvitem := posicaofieldsmy.FindNode(tvMysql.Selected.Text);
        if tvitem = nil then
        begin
          zqrypost.Close;
          zqrypost.SQL.Text := edSQL.Text;
          zqrypost.Prepare;
          zqrypost.ExecSQL;
        end
        else
          ShowMessage('Tabela existe');
      end;

      if isCreateSequence then
      begin
        tvitem := posicaoSequencePost.FindNode(tvMysql.Selected.Text);
        if tvitem = nil then
        begin
          zqrypost.Close;
          zqrypost.SQL.Text := edSQL.Text;
          zqrypost.Prepare;
          zqrypost.ExecSQL;
        end
        else
          ShowMessage('Sequence existe');
      end;
    end;

  except
    {$IFDEF DARWIN}
    on E: Exception do
    {$ELSE}
    on E: Exception do
    {$ENDIF}
    begin
      pnErro.Visible := True;
      edErro.Text := E.Message;
      ProcessaErro(E.Message);
    end;
  end;

  RefreshPost();
end;

procedure Tfrmmquery2.edPesqMyKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
  begin
      procuraTVMysql(edPesqMy.text);
  end;
end;

procedure Tfrmmquery2.edPesqPostKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
  begin
      procuraTVPost(edPesqPost.text);
  end;
end;

procedure Tfrmmquery2.edSchemaPostChange(Sender: TObject);
begin

end;

procedure Tfrmmquery2.edSQLChange(Sender: TObject);
begin

end;

procedure Tfrmmquery2.edSQLChangeUpdating(ASender: TObject; AnUpdating: Boolean);
begin

end;

procedure Tfrmmquery2.edSQLClickLink(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

end;

procedure Tfrmmquery2.edSQLCommandProcessed(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
begin

end;

procedure Tfrmmquery2.edSQLEnter(Sender: TObject);
begin

end;

procedure Tfrmmquery2.edSQLGutterClick(Sender: TObject; X, Y, Line: integer;
  mark: TSynEditMark);
begin
   lbCol.Caption:= inttostr(x);
   lblinha.Caption:= inttostr(y);
end;

procedure Tfrmmquery2.edSQLKeyPress(Sender: TObject; var Key: char);
begin

end;

procedure Tfrmmquery2.edSQLKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin

end;

procedure Tfrmmquery2.edSQLMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin

end;

procedure Tfrmmquery2.edSQLPaint(Sender: TObject; ACanvas: TCanvas);
begin

end;

procedure Tfrmmquery2.edSQLPlaceBookmark(Sender: TObject; var Mark: TSynEditMark);
begin

end;

procedure Tfrmmquery2.edSQLStatusChange(Sender: TObject; Changes: TSynStatusChanges
  );
begin

end;

procedure Tfrmmquery2.edSQLSynGutterChange(Sender: TObject);
begin

end;

procedure Tfrmmquery2.FindDialog1Find(Sender: TObject);
begin
  strFind:= findDialog1.FindText;
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
  zmyqry.close;
  pnlProgresso.Visible:= true;
  zmyqry.sql.text :=   'select * from information_schema.tables';
  zmyqry.open;
  zmyqry.First;
  pgbar.Max:= zmyqry.RecordCount;
  pgbar.Position:=0;
  posicaofieldsmy.DeleteChildren;
  while not zmyqry.EOF do
  begin
     if zmyqry.FieldByName('table_schema').asstring = edBanco.text then
     begin
       TabelaNome := zmyqry.FieldByName('table_name').asstring;
       SynCompletion1.ItemList.Append(TabelaNome);
       Tabela := TTabela.create(zmyqry1,TabelaNome, DBMysql);

       tvitem := TTreenode.Create(tvMysql.items);
       tvitem.ImageIndex:= 14;
       tvitem := tvMysql.Items.AddNode(tvitem,posicaofieldsmy,TabelaNome,TObject(Tabela),naAddChild);

       (*Adiciona colunas da tabela*)
       tvcolunas := tvMysql.Items.AddChildObject(tvitem,'fields', tobject(ETDBCampos));
       tvcolunas.ImageIndex:=16;
       for a:= 0 to tabela.count-1 do
       begin
         tvTemp := tvMysql.items.AddChildObject(tvcolunas,tabela.fieldname[a],pointer(a));
         tvtemp.ImageIndex:=16;
       end;

       (*adiciona pk da tabela*)
       tvindice := tvMysql.Items.AddChildObject(tvitem,'Primary Key',pointer(ETDBPK));
       tvindice.ImageIndex:=17;
       for a := 0 to tabela.chaves.primarykeys.Count-1 do
       begin
         tvTemp := tvMysql.items.AddChildObject(tvindice,tabela.chaves.primarykeys[a],pointer(a));
         tvTemp.ImageIndex:=18;
       end;

       (*adiciona pk da tabela*)
       tvFK := tvMysql.Items.AddChildObject(tvitem,'Chave Extrangeira',tobject(ETDBFK));
       for a := 0 to tabela.chaves.coinstraintname.Count-1 do
       begin
         tvMysql.items.AddChildObject(tvFK,tabela.chaves.coinstraintname[a],pointer(a));
       end;
       if (tabela.triggers.Triggername.Count > 0) then
       begin
         (*adiciona trigger*)
         tvTrigger := tvMysql.Items.AddChildObject(tvitem,'Triggers',pointer(ETDTriggers));
         for a := 0 to tabela.triggers.Triggername.Count-1 do
         begin
           tvMysql.items.AddChildObject(tvTrigger,tabela.triggers.Triggername[a],pointer(a));
         end;

       end;


     end;
     zmyqry.next;
     pgbar.Position:=pgbar.Position+1;
     Application.ProcessMessages;
  end;
  pnlProgresso.Visible:= false;
  tvMysql.FullExpand;
end;

procedure Tfrmmquery2.BuscaSequence(qry:TZReadOnlyQuery;  TypeDB: TypeDatabase);
var
  sql : string;
begin
    posicaoSequencePost.DeleteChildren;
    sequences := TStringList.create();
    if TypeDB = DBPostgres then (*Apenas Postgres tem sequence*)
    begin
       sql := 'select * from information_schema.sequences ';
       qry.SQL.Text:= sql;
       qry.Open;
       qry.first;
       while not qry.EOF do
       begin
         sequences.Add(qry.FieldByName('sequence_name').asstring);
         tvPost.Items.AddChildObject(posicaoSequencePost,qry.FieldByName('sequence_name').asstring, pointer(ETDSequence));
         qry.next;
       end;
    end;
    qry.close;

end;

procedure Tfrmmquery2.ListarViewsMy();
var
  a : integer;
begin
   viewsmy := TViews.create(zmyqry,edBanco.Text, DBMysql);

   for a := 0 to viewsmy.items.Count-1 do
   begin
      tvMysql.Items.AddChildObject(posicaoViewmy,viewsmy.items[a],TObject(viewsmy.items.Objects[a]));
      SynCompletion1.ItemList.Append(viewsmy.items[a]);
   end;
end;

procedure Tfrmmquery2.ListarViewsPost();
var
  a : integer;
begin
   viewspost := TViews.create(zpostqry,edBancoPost.Text, DBPostgres);

   for a := 0 to viewspost.items.Count-1 do
   begin
      tvPost.Items.AddChildObject(posicaoViewPost,viewspost.items[a],TObject(viewspost.items.Objects[a]));
   end;
end;


procedure Tfrmmquery2.ListarTabelasPost();
var
  Tabela : TTabela;
  tvitem : TTreeNode;
  tvtemp : Ttreenode;
  tvcolunas : TTreeNode;
  tvindice : TTreeNode;
  tvFK : TTreeNode;
  tvTrigger : TTreeNode;
  TabelaNome : string;
  a : integer;
begin
  try
    zpostqry.close;
    //pnlProgresso1.Visible:= true;
    zpostqry.sql.text := 'select * from information_schema.tables '+
                 ' where table_schema = '+#39+edSchemaPost.text+#39+
                 ' and table_type = '+#39+'BASE TABLE'+ #39+
                 ' order by table_name';


    //zmyqry.sql.text :=   'select * from tb_parametro';
    zpostqry.open;
    zpostqry.First;
    //pgbar1.Max:= zpostqry.RecordCount;
    //pgbar1.Position:=0;
    posicaofieldspost.DeleteChildren;
    while not zpostqry.EOF do
    begin
      if zpostqry.FieldByName('table_schema').asstring = edSchemaPost.text then
      begin

        TabelaNome := zpostqry.FieldByName('table_name').asstring;
        SynSQLSyn2.TableNames.Append(zpostqry.FieldByName('table_name').asstring);
        Tabela := TTabela.create(zpostqry1,TabelaNome, DBPostgres);
        tvitem := TTreenode.Create(tvPost.items);
        tvitem.ImageIndex:= 14;
        tvitem := tvPost.Items.AddNode(tvitem,posicaofieldspost,TabelaNome,pointer(Tabela),naAddChild);
      end;

      (*Adiciona colunas da tabela*)
      tvcolunas := tvPost.Items.AddChildObject(tvitem,'fields', pointer(ETDBCampos));
      tvcolunas.ImageIndex:=16;
      for a:= 0 to tabela.count-1 do
      begin
        tvtemp := tvPost.items.AddChildObject(tvcolunas,tabela.fieldname[a],pointer(a));
        tvtemp.ImageIndex:=19;
      end;

      (*adiciona pk da tabela*)
      tvindice := tvPost.Items.AddChildObject(tvitem,'Primary Key',pointer(ETDBPK));
      tvindice.ImageIndex:=17;
      for a := 0 to tabela.chaves.primarykeys.Count-1 do
      begin
        tvtemp := tvPost.items.AddChildObject(tvindice,tabela.chaves.primarykeys[a],pointer(a));
        tvtemp.ImageIndex:= 18;
      end;

      (*adiciona pk da tabela*)
      tvFK := tvPost.Items.AddChildObject(tvitem,'Chave Extrangeira',pointer(ETDBFK));
      for a := 0 to tabela.chaves.coinstraintname.Count-1 do
      begin
        tvPost.items.AddChildObject(tvFK,tabela.chaves.coinstraintname[a],pointer(a));
      end;

      if (tabela.triggers.Triggername.Count > 0) then
      begin
         (*adiciona trigger*)
         tvTrigger := tvPost.Items.AddChildObject(tvitem,'Triggers',pointer(ETDTriggers));
         for a := 0 to tabela.triggers.Triggername.Count-1 do
         begin
           tvPost.items.AddChildObject(tvTrigger,tabela.triggers.Triggername[a],pointer(a));
         end;

      end;


      zpostqry.next;
      //pgbar1.Position:=pgbar1.Position+1;
      Application.ProcessMessages;
    end;

  finally
    //pnlProgresso1.Visible:= false;
    tvpost.FullExpand;

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
    // Não cita NULL, CURRENT_TIMESTAMP, expressões e números
    if (S = '') then Exit(False);
    if SameText(S, 'NULL') then Exit(False);
    if SameText(S, 'CURRENT_TIMESTAMP') then Exit(False);
    if Pos('(', S) > 0 then Exit(False);      // ex: (current_timestamp())
    if TryStrToFloat(S, V) then Exit(False);  // numérico
    Result := True;
  end;

  function MyTypeWithLen(const baseType: string; const charLen, numPrec, numScale: Variant): string;
  begin
    // Monta o tipo com (len) ou (prec,scale) quando aplicável
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
  if not zconmysql.Connected then
  begin
    ShowMessage('MySQL não conectado!');
    Exit;
  end;

  // 1) Colunas
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

  // 2) Primary key
  pkCols := TStringList.Create;
  pkCols.Sorted := False; // manter ordem
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

    // 3) Monta o CREATE
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
        isNullable:= zmyqry.FieldByName('IS_NULLABLE').AsString; // 'YES'/'NO'
        defVal    := zmyqry.FieldByName('COLUMN_DEFAULT').AsString; // pode vir vazio
        extra     := zmyqry.FieldByName('EXTRA').AsString; // ex: auto_increment

        // normaliza tipo com tamanhos
        dataType := MyTypeWithLen(LowerCase(dataType), charLen, numPrec, numScale);

        // vírgula separadora
        if not firstCol then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ',';
        firstCol := False;

        // linha da coluna
        createSQL.Add(Format('  `%s` %s', [colName, UpperCase(dataType)]));

        // NOT NULL / NULL
        if SameText(isNullable, 'NO') then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' NOT NULL'
        else
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' NULL';

        // DEFAULT
        if defVal <> '' then
        begin
          if NeedsQuoting(defVal) then
            createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' DEFAULT ' + QuotedStr(defVal)
          else
            createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' DEFAULT ' + defVal;
        end;

        // AUTO_INCREMENT etc
        if Pos('auto_increment', LowerCase(extra)) > 0 then
          createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ' AUTO_INCREMENT';

        zmyqry.Next;
      end;

      // PRIMARY KEY
      if pkCols.Count > 0 then
      begin
        createSQL[createSQL.Count-1] := createSQL[createSQL.Count-1] + ','; // vírgula da última coluna
        createSQL.Add('  PRIMARY KEY (' +
          StringReplace('`' + StringReplace(pkCols.CommaText, ',', '`,`', [rfReplaceAll]) + '`', '``', '`', [rfReplaceAll]) +
          ')');
      end;

      createSQL.Add(') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;');

      // Mostra no editor principal de SQL do MySQL
      //edSQL.Text := createSQL.Text;
      //pgMysql.ActivePage := tbSQL;
      result := createSQL.Text;
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
  sql : string;
begin
  Result := '';
  if(dmbase = nil) then
       dmbase := Tdmbase.create(self);
  dmbase.DeleteTabelas();

  if not zconpost.Connected then
  begin
    ShowMessage('PostgreSQL não conectado.');
    Exit;
  end;

  // Garante que o tree esteja carregado
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

    // 1) Varrer as tabelas NO TREE (tvPost -> posicaofieldspost)
    tblNode := posicaofieldspost.GetFirstChild;
    while tblNode <> nil do
    begin
      tblName := tblNode.Text;
      outSQL.Add('-- ' + tblName);
      SQL := DescreveTabelaIAPost(tblName);
      // 2) Gerar o CREATE de cada tabela
      outSQL.Add(SQL);
      outSQL.Add('');

      //Verifica se tem projeto
      if(FSetMain.Project<>'') then
      begin
        if(dmbase = nil) then
            dmbase := tdmbase.create(self);
        dmbase.RegistraTabela(tblName, '', SQL);
      end;
      tblNode := tblNode.GetNextSibling;

    end;

    // 3) Salvar no arquivo passado por PARÂMETRO
    targetAbsPath := ExpandFileName(ATargetFile);
    targetDir     := ExtractFilePath(targetAbsPath);
    if targetDir <> '' then
      ForceDirectories(targetDir);
    if(ATargetFile  <>'') then
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

    // Percorre os nós de "tables" no tvPost
    nodeTable := posicaofieldspost.GetFirstChild;
    while nodeTable <> nil do
    begin
      // cada filho direto de posicaofieldspost é uma tabela
      childTable := nodeTable.Text;

      // Consulta todas as FKs da tabela, agrupando por constraint
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

          // Mudou de constraint? imprime a anterior agrupada
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

          // Acumula colunas da constraint atual
          parentTable := zpostqry1.FieldByName('parent_table').AsString;
          childCols.Add(zpostqry1.FieldByName('child_col').AsString);
          parentCols.Add(zpostqry1.FieldByName('parent_col').AsString);

          lastConstraint := curConstraint;
          zpostqry1.Next;
        end;

        // flush final da última constraint
        if (lastConstraint <> '') and (childCols.Count > 0) then
        begin
          outTxt.Add(Format('%s (%s) depende da %s (%s);',
            [childTable,
             StringReplace(childCols.CommaText, ',', ', ', [rfReplaceAll]),
             parentTable,
             StringReplace(parentCols.CommaText, ',', ', ', [rfReplaceAll])]));
        end;

        outTxt.Add(''); // linha em branco após cada tabela
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

  // opcional: ASCII 7-bit estrito
  function ToASCII7(const S: AnsiString): AnsiString;
  var i: SizeInt;
  begin
    Result := S;
    for i := 1 to Length(Result) do
      if Ord(Result[i]) > 127 then
        Result[i] := '?';
  end;

var
  ctxDeps, ctxDDL, ask, outSQL: string;
  outAnsi: AnsiString; // <<— importante: AnsiString para manter bytes ANSI
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
    ctxDeps := CriaListaDependenciasPost('') else ctxDeps := deps;

  if Trim(ddl) = '' then
    ctxDDL := CriaDicionarioPost('') else ctxDDL := ddl;

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
  begin
    outSQL := StripCodeFences(FCHATGPT.Response);
  end
  else
  begin
    outSQL := StripCodeFences(FCHATGPT.Response);
  end;
  if FCHATGPT.SendQuestion(ask) then
    outSQL := StripCodeFences(FCHATGPT.Response)
  else
    outSQL := StripCodeFences(FCHATGPT.Response);

  // ===== conversão UTF-8 -> ANSI da página de código do sistema =====
  outAnsi := UTF8ToAnsi(outSQL);        // cross-platform (usa code page do sistema)

  // Se você quiser CP1252 especificamente (ex.: Windows pt-BR), use:
  // outAnsi := UTF8ToCP1252(outSQL);

  // Se quiser ASCII 7-bit estrito, descomente:
  // outAnsi := ToASCII7(outAnsi);

  // Retorna como string (ASCII/ANSI apenas tem chars <=127/255, então é seguro)
  Result := String(outAnsi);
end;

function Tfrmmquery2.ValidaConexao(TipoBanco : Integer ): Boolean;
var
  Q: TZQuery;
  Proto: string;
  conexao : boolean;
begin


  // 2) configura e registra a conexão no zconlocal
  Result := False;
  try
    //if zconlocal.Connected then
    //  zconlocal.Disconnect;

    case TipoBanco of
      0: Proto := 'mysql';       // ajuste para 'mysql-8' se você usa client 8.x
      1: Proto := 'postgresql';  // ajuste p/ 'postgresql-12' etc. se preferir
    else
      raise Exception.Create('DATABASETYPE inválido. Use 0=MySQL ou 1=Postgres.');
    end;

    // 3) aplica schema se for Postgres e informado
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

    conexao := false;
    if (frmmquery2= nil) then
    begin
       frmmquery2 := Tfrmmquery2.create(self);
    end;
    if (TipoBanco=0) then //Mysql
    begin
        //FSetMain.BancoMy:=;

    end;

    if (TipoBanco=1) then
    begin


        frmmquery2.edHostNamePost.text := FSetMain.HostnamePost;
        frmmquery2.edSchemaPost.text := FSetMain.SchemaPost;
        frmmquery2.edBancoPost.text := FSetMain.BancoPOST;
        frmmquery2.edusuarioPost.text :=  FSetMain.UsernamePost;
        frmmquery2.edPasswrdPost.text := FSetMain.PasswordPost;
        conexao := frmmquery2.ConectPost;
        //conexao := mquery2.refreshPost;

    end;
    Result := conexao;



  except
    on E: Exception do
    begin
      // se quiser, faça log do E.Message
      Result := False;


    end;
  end;
end;

end.


