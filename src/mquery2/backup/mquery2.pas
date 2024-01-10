unit mquery2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Menus, ValEdit, SynEdit, SynHighlighterSQL, SynCompletion,
  ZConnection, ZDataset, ZPgEventAlerter, Tabela, views, View, strUtils, DB,
  SynEditTypes, SynGutterBase, SynEditMarks, SynEditKeyCmds,
  SynPluginSyncroEdit, SynGutterMarks, SynGutterLineNumber, SynGutterChanges,
  SynGutter, SynGutterCodeFolding, LCLType, Grids, Buttons, PairSplitter,
  DBCtrls, DBGrids, finds, ZClasses, ZCollections, ZCompatibility, ZTokenizer,
  ZSelectSchema, ZGenericSqlAnalyser, ZDbcLogging, ZVariant, ZPlainDriver, ZURL,
  TypeDB, triggers, setmain;

type

  { TForm1 }

  { Tfrmmquery2 }

  Tfrmmquery2= class(TForm)
    btBanco: TButton;
    btcomparar: TButton;
    btConectarMy: TButton;
    btConectarPost: TButton;
    btPermissao: TToggleBox;
    btExecutar: TButton;
    btExecute: TButton;
    Button3: TButton;
    dsmy: TDataSource;
    dbgridmy: TDBGrid;
    dbnavmy: TDBNavigator;
    edBanco: TEdit;
    edBancoPost: TEdit;
    edErro: TMemo;
    edHostName: TEdit;
    edHostNamePost: TEdit;
    edPesqMy: TEdit;
    edSchemaPost: TEdit;
    edLog: TMemo;
    edPasswrd: TEdit;
    edPasswrdPost: TEdit;
    edPesqPost: TEdit;
    edSQL: TSynEdit;
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
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCol: TLabel;
    lblinha: TLabel;
    ListBox1: TListBox;
    lstfind: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    miCreate: TMenuItem;
    miOcultarPost: TMenuItem;
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
    Panel10: TPanel;
    Panel11: TPanel;
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
    pmTabelaMy: TPopupMenu;
    pnBotton: TPanel;
    pnErro: TPanel;
    pnlProgresso: TPanel;
    popSeq: TPopupMenu;
    popMenu: TPopupMenu;
    popSQL: TPopupMenu;
    popfind: TPopupMenu;
    popmenuTrigger: TPopupMenu;
    pmTabelasMy: TPopupMenu;
    pmTabelaPost: TPopupMenu;
    PopupMenuTblPost: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    SynCompletion1: TSynCompletion;
    SynPluginSyncroEdit1: TSynPluginSyncroEdit;
    SynSQLSyn2: TSynSQLSyn;
    TabSheet1: TTabSheet;
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
    procedure btBancoClick(Sender: TObject);
    procedure btbenchmarkClick(Sender: TObject);
    procedure btcompararClick(Sender: TObject);
    procedure btExecutarClick(Sender: TObject);
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
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure miCFunctionClick(Sender: TObject);
    procedure miCreateClick(Sender: TObject);
    procedure miCTriggerClick(Sender: TObject);
    procedure miEsconderClick(Sender: TObject);
    procedure miFontClick(Sender: TObject);
    procedure miMostrarClick(Sender: TObject);
    procedure miBenchmarkClick(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure miNovaPesquisaClick(Sender: TObject);
    procedure miOcultarPostClick(Sender: TObject);
    procedure mnCriarSeqClick(Sender: TObject);
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
    function GeraSQL(Tabela : TTabela): string;
    function TipoConv(Tabela : TTabela; Posicao: integer): String;
    procedure tvPostChange(Sender: TObject; Node: TTreeNode);
    procedure tvPostClick(Sender: TObject);
    procedure PostApagaTabela(Nome: string);
    procedure vlistequivalenteClick(Sender: TObject);
    procedure zconpostAfterConnect(Sender: TObject);
    procedure ZPgEventAlerter1Notify(Sender: TObject; Event: string;
      ProcessID: Integer; Payload: string);
  private
    posicaofieldsmy : TTreeNode;
    posicaofieldspost : TTreeNode;
    tvitemPost : TTreeNode;
    tvitemMy : TTreeNode;
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
    procedure CriarBanco();
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

  public
    procedure RefreshPost();
    procedure Pesquisar(sender: TObject);
    procedure ProcessaErro(message : string);
    function RectIsEmpty(const aRect:TRect):Boolean;
    function ToRect(const aTopLeft, aBottomRight:TPoint):TRect; overload;
    function ToRect(const aTop, aLeft, aBottom, aRight : LongInt):TRect; overload;
    Function RectInRect(const aOuterRect, aInnerRect:TRect):Boolean;
  end;

var
  frmmquery2: Tfrmmquery2;

implementation

{$R *.lfm}

uses benchmark;

{ TForm1 }

procedure Tfrmmquery2.FieldClickChange(Sender: TObject);
begin
    edSQL.clear;
    edSQL.text := 'ok';

end;

procedure Tfrmmquery2.ToggleBox2Change(Sender: TObject);
var
  nome : string;
begin
  if zconpost.Connected then
  begin
       nome := InputBox('Create User','Username:','username');
       edSQL.text  := 'create user root with password '+QuotedStr(nome)+';';
       zqrypost.sql.text := edSQL.text;
       Zqrypost.ExecSQL;
  end
  else
  begin
     showmessage('Postgres não conectado!');
  end;
end;

function Tfrmmquery2.TrocarPalavra(Info : String; de: String; para : String): String;
var
  a : integer;
  posicao : integer;
  buffer : string;
begin
 buffer := '';
 a:= 1;
 repeat
 begin
    posicao := Pos(uppercase(de),uppercase(Info));
    if (posicao>0) then
    begin
       buffer  := buffer + Copy(info,0,posicao-1)+para;
       Info := Copy(Info,posicao+length(de),Length(info)-1);
       a := posicao+5;
    end
    else
    begin
       buffer := buffer + Info;
    end;
 end;
 until (posicao <= 0) ;
 result := buffer;
end;


function Tfrmmquery2.FormataSQL(Info : string): string;
var
  a : integer;
  posicao : integer;
  buffer : string;
begin
 for a:= 0 to Length(info)-1 do
 begin
    if Info[a]= ',' then
    begin
       info := Copy(info,0,a)+#13+#10+Copy(Info,a+1,Length(info)-1);
    end;
 end;
 Info := TrocarPalavra(Info,'`','');
 Info := TrocarPalavra(Info, 'FROM',#13+#10+'FROM');
 Info := TrocarPalavra(Info, 'THEN','THEN'+#13+#10);
 Info := TrocarPalavra(Info, 'ELSE',#13+#10+'ELSE'+#13+#10);
 Info := TrocarPalavra(Info, 'BEGIN',#13+#10+'BEGIN'+#13+#10);
 Info := TrocarPalavra(Info, 'END;',#13+#10+'END;'+#13+#10);
 Info := TrocarPalavra(Info, 'END IF;',#13+#10'END IF;'+#13+#10);
 Info := TrocarPalavra(Info, 'WHERE',#13+#10+'WHERE');
 Info := TrocarPalavra(Info, 'SELECT',#13+#10+'SELECT');
 Info := TrocarPalavra(Info, 'INSERT',#13+#10+'INSERT');
 Info := TrocarPalavra(Info, 'UPDATE',#13+#10+'UPDATE');
 Info := TrocarPalavra(Info, 'ORDER BY',#13+#10+'ORDER BY');
 Info := TrocarPalavra(Info, 'GROUP BY',#13+#10+'GROUP BY');
 for a := 1 to vlistequivalente.RowCount do
 begin
    Info := TrocarPalavra(Info,vlistequivalente.Cells[0,a],vlistequivalente.Cells[1,a] );
 end;
 result := Info;
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
           //edsql.Text:= GeraSQL(TTabela(Node.Data))
           tvMysql.PopupMenu := pmTabelaMy;
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

function Tfrmmquery2.GeraSQL(Tabela: TTabela): string;
var
  Comando : string;
  a : integer;
begin
  Comando := '--Criado por MQuery2 em '+datetostr(now)+#13+#10;
  Comando := Comando + 'CREATE TABLE '+edSchemaPost.text+'.'+Tabela.Tablename+'('+#13+#10 ;
  for a := 0 to tabela.fieldname.count-2 do
  begin
    Comando := '   '+Comando + tabela.fieldname[a]+' '+ TipoConv(tabela,a)+','#13+#10 ;
  end;
  Comando := Comando + tabela.fieldname[tabela.count-1]+' '+ TipoConv(tabela,tabela.count-1)+#13+#10;


  (*Criando definições de chave primaria*)
  if (Tabela.chaves.primarykeys.Count<>0) then
  begin
         Comando := comando+', primary key (';
         for a := 0 to tabela.chaves.primarykeys.count-2 do
         begin
            Comando := comando+ tabela.chaves.primarykeys[a]+',';
         end;
         Comando := comando + tabela.chaves.primarykeys[tabela.chaves.primarykeys.count-1];
         Comando := comando+ ')' +#13+#10;
  end;



  (*Definição de contraint*)
  if (Tabela.chaves.coinstraintname.Count<>0) then
  begin
    for a := 0 to tabela.chaves.coinstraintname.count-2 do
    begin

       begin
            Comando := comando+', constraint ('+tabela.chaves.coinstraintcolumn_name[a]+') ' +
                       'references '+ tabela.chaves.coinstraint_Reference_Table_name[a]+'('+
                       tabela.chaves.coinstraint_Reference_column_name[a] + ')'+ #13+#10;

       end;
       Comando := comando+', constraint ('+tabela.chaves.coinstraintcolumn_name[Tabela.chaves.coinstraintname.Count-1]+') ' +
                  'references '+ tabela.chaves.coinstraint_Reference_Table_name[Tabela.chaves.coinstraintname.Count-1]+'('+
                  tabela.chaves.coinstraint_Reference_column_name[Tabela.chaves.coinstraintname.Count-1] + ')'+ #13+#10;

    end;
  end;
  Comando := Comando+ ')'+#13+#10;
  Comando := Comando+ ';'+#13+#10;
  (*Criando comentarios*)
  for a := 0 to tabela.fieldname.count-1 do
  begin
    if Tabela.fieldcomment[a]<>'' then
        Comando := Comando + ' comment on column '+edSchemaPost.text+'.'+Tabela.Tablename+'.'+ tabela.fieldname[a]+ ' is '+#39+Tabela.fieldcomment[a]+#39+';'#13+#10;

  end;
  //Comando := Comando+ ';'+#13+#10;
  result := Comando;
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
   end
   else
   begin
     showmessage('Nao encontrado');
   end;
end;


procedure Tfrmmquery2.tvPostChange(Sender: TObject; Node: TTreeNode);
begin
  if Node <> nil then
  begin
    procuraTVMysql(Node.Text);
    tvPost.PopupMenu := PopupMenuTblPost;
  end
  else
  begin
    tvPost.PopupMenu := nil;
  end;

  if (Node = posicaofieldspost) then
  begin
    tvPost.PopupMenu :=  pmTabelaPost;
  end;

end;

procedure Tfrmmquery2.tvPostClick(Sender: TObject);
begin

end;

procedure Tfrmmquery2.FormCreate(Sender: TObject);
var
  tvitem : TTreeNode;
begin
  edBanco.Text  := FSetMain.BancoMy;
  edBancoPost.text := FSetMain.BancoPOST;
  edusuario.text := FSetMain.UsernameMy;
  edusuarioPost.text := FSetMain.UsernamePost;
  edHostName.Text:= FSetMain.HostnameMy;
  edHostNamePost.text := FSetMain.HostnamePost;
  edSchemaPost.text := FSetMain.SchemaPost;
  edPasswrd.text := FSetMain.PasswordMy;
  edPasswrdPost.text := FSetMain.PasswordPost;

  TrayIcon1.Visible:= true;
  pgMain.PageIndex:=0;
  pgMysql.PageIndex:=0;
  tvitem := TTreeNode.Create(tvMysql.Items);
  tvitemmy := tvMysql.Items.AddObject(tvitem,'mysql', pointer(ETDBBanco));
  tvitemmy.ImageIndex:=-1;
  {$IFDEF WINDOWS}
  zconpost.LibraryLocation:= ExtractFilePath(application.exename) +'\libpq74.dll';
  zconmysql.LibraryLocation:= ExtractFilePath(application.exename) +'\libmysql.dll';
  {$ENDIF}
  {$IFDEF LINUX}
  zconpost.LibraryLocation:= ExtractFilePath(application.exename) +'/libs/linux64/libpq74.so';
  zconmysql.LibraryLocation:= ExtractFilePath(application.exename) +'/libs/linux64/libmysqlclient.so.21';
  {$ENDIF}

  tvitem := TTreeNode.Create(tvPost.Items);
  tvitempost := tvpost.Items.AddObject(tvitem,'Postgres', pointer(ETDBBanco));
  tvitempost.ImageIndex:=-1;


end;

procedure Tfrmmquery2.setSelLength(var textComponent:TSynEdit; newValue:integer);
begin
textComponent.SelEnd:=textComponent.SelStart+newValue ;
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

procedure Tfrmmquery2.CriarBanco;
var
  banco : string;
begin
  if zconpost.Connected then
  begin
       banco := InputBox('Create database','Banco:','database');
       edSQL.text  := 'create database '+QuotedStr(banco)+';';
       zqrypost.sql.text := edSQL.text;
       Zqrypost.ExecSQL;
  end
  else
  begin
     showmessage('Postgres não conectado!');
  end;
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

procedure Tfrmmquery2.miCreateClick(Sender: TObject);
begin
  edsql.Text:= GeraSQL(TTabela(tvMysql.Selected.Data))
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

procedure Tfrmmquery2.miOcultarPostClick(Sender: TObject);
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
  IF (vlistequivalente.RowCount<1) THEN
     vlistequivalente.RowCount:= vlistequivalente.RowCount-1;
end;

procedure Tfrmmquery2.SynCompletion1PositionChanged(Sender: TObject);
begin


end;

procedure Tfrmmquery2.ToggleBox1Change(Sender: TObject);
begin

end;

procedure Tfrmmquery2.btConectarMyClick(Sender: TObject);
var
  tvitem : TTreeNode;
begin
   try
        FSetMain.BancoMy := edBanco.Text;
        FSetMain.UsernameMy := edusuario.text;
        FSetMain.HostnameMy := edHostName.Text;
        FSetMain.PasswordMy := edPasswrd.text;

        zconmysql.Disconnect;
        {$IFDEF WINDOWS}
        zconpost.LibraryLocation:= ExtractFilePath(application.exename) +'libpq74.dll';
        zconmysql.LibraryLocation:= ExtractFilePath(application.exename) +'libmysql.dll';
        {$ENDIF}
        {$IFDEF LINUX}
        zconpost.LibraryLocation:= ExtractFilePath(application.exename) +'libs/linux64/libpq74.so';
        zconmysql.LibraryLocation:= ExtractFilePath(application.exename) +'libs/linux64/libmysqlclient.so.21';
        {$ENDIF}

        zconmysql.Database := edBanco.text;
        zconmysql.HostName := edHostName.Text;
        zconmysql.User := edusuario.text;
        zconmysql.Password := edPasswrd.Text;
        zconmysql.Connect;
        if zconmysql.Connected then
        begin
          tvitemmy.Text:= edBanco.text; //Muda para o banco de dados
          tvitemmy.ImageIndex:=13;
          posicaofieldsmy := tvMysql.Items.AddChildObject(tvitemmy, 'Tables', pointer(ETDTabelas));
          posicaofieldsmy.ImageIndex:=15;
          posicaoViewmy := tvMysql.Items.AddChildObject(tvitemmy, 'Views', pointer(ETDViews));
          posicaoProceduremy := tvMysql.Items.AddChildObject(tvitemmy, 'Procedure', pointer(ETDProcedure));
          posicaoFunctionmy := tvMysql.Items.AddChildObject(tvitemmy, 'Functions', pointer(ETDFunctions));
          tvitem := TTreeNode.Create(tvMysql.items);
          ListarTabelasMy();
          ListarViewsMy();
        end;
    finally
    end;
end;

procedure Tfrmmquery2.btPermissaoChange(Sender: TObject);
var
  nome : string;
  banco : string;
begin
  if zconpost.Connected then
  begin
       banco := InputBox('Grant Database','Database:','database');
       nome := InputBox('Grant Database','Username:','root');
       edSQL.text  := 'grant ALL PRIVILES on database '+banco+' to '+nome+';';
       zqrypost.sql.text := edSQL.text;
       Zqrypost.ExecSQL;
  end
  else
  begin
     showmessage('Postgres não conectado!');
  end;
end;

procedure Tfrmmquery2.btBancoClick(Sender: TObject);
begin
 CriaBanco();
end;

procedure Tfrmmquery2.btbenchmarkClick(Sender: TObject);
begin

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
                   edSQL.Lines.Append('Not found table:'+nome);
                   achou := true;
              end;
              if (tvMysql.Items[a].Parent = posicaoViewPost) then
              begin
                   edSQL.Lines.Append('Not found View:'+nome);
                   achou := true;
              end;
              if (tvMysql.Items[a].Parent = posicaoFunctionPost) then
              begin
                   edSQL.Lines.Append('Not Found Function:'+nome);
                   achou := true;
              end;
              if (tvMysql.Items[a].Parent = posicaoProcedurePost) then
              begin
                   edSQL.Lines.Append('Not found Procedure:'+nome);
                   achou := true;
              end;

              if (achou = false) then
              begin
                   edSQL.Lines.Append('Not found item:'+nome);
              end;

          end;

      end;

  end;


  ShowMessage('End Diff!');
end;

procedure Tfrmmquery2.btExecutarClick(Sender: TObject);
begin
  try
    zmyqry2.sql.text := edSQL.Lines.Text;

    dsmy.DataSet := zmyqry2;
    edlog.Append('SQL OPEN:'+edSQL.Lines.Text);
    dbnavmy.DataSource := dsmy;
    dbgridmy.DataSource := dsmy;
    zmyqry2.Open;
  except
     on E: Exception do
     begin
          edLog.Append('Error:'+e.message);
          ShowMessage('Error:'+e.message);
     end;

  end;

end;

procedure Tfrmmquery2.btConectarpostClick(Sender: TObject);
begin
  FSetMain.PasswordPost := edPasswrdPost.text;
  FSetMain.BancoPOST := edBancoPost.text;
  FSetMain.UsernamePost := edusuarioPost.text;
  FSetMain.HostnamePost := edHostNamePost.text;
  FSetMain.SchemaPost :=   edSchemaPost.text;
  refreshPost();
end;

procedure Tfrmmquery2.btExecuteClick(Sender: TObject);
begin
    try
    zmyqry2.sql.text := edSQL.Lines.Text;

    dsmy.DataSet := nil;
    dbnavmy.DataSource := nil;
    dbgridmy.DataSource := nil;
    edLog.Append('SQL Execute:'+edSQL.Lines.Text);
    zmyqry2.ExecSQL;

  except
     on E: Exception do
     begin
          ShowMessage('Error:'+e.message);
          edLog.Append('Error:'+e.message);
     end;
  end;
end;

procedure Tfrmmquery2.RefreshPost();
var
  tvitem : TTreeNode;
begin
     tvitempost.DeleteChildren;
     //ShapeCon.brush.color := clWhite;
     SynSQLSyn2.TableNames.clear;
     try
        tvitem := TTreeNode.Create(tvPost.items);

        zconpost.Disconnect;
        {$IFDEF WINDOWS}
        zconpost.LibraryLocation:= ExtractFilePath(application.exename) +'\libpq74.dll';
        zconmysql.LibraryLocation:= ExtractFilePath(application.exename) +'\libmysql.dll';
        {$ENDIF}
        {$IFDEF LINUX}
        zconpost.LibraryLocation:= ExtractFilePath(application.exename) +'/libs/linux64/libpq74.so';
        zconmysql.LibraryLocation:= ExtractFilePath(application.exename) +'/libs/linux64/libmysqlclient.so.21';
        {$ENDIF}

        zconpost.HostName := edHostNamePost.Text;
        zconpost.User:= edusuarioPost.text;
        zconpost.Password:= edPasswrdPost.Text;
        zconpost.Connect;
        if zconpost.Connected then
        begin
          tvitempost.Text:=edBancoPost.text;
          tvitempost.ImageIndex:=13;
          posicaofieldspost := tvPost.Items.AddChildObject(tvitemPost, 'tables',pointer(ETDTabelas));
          posicaofieldspost.ImageIndex:=15;
          posicaoSequencePost := tvPost.Items.AddChildObject(tvitemPost, 'Sequences',pointer(ETDTabelas));
          posicaoViewPost := tvPost.Items.AddChildObject(tvitemPost, 'Views', pointer(ETDViews));
          posicaoProcedurePost := tvPost.Items.AddChildObject(tvitemPost, 'Procedure', pointer(ETDProcedure));
          posicaoFunctionPost := tvPost.Items.AddChildObject(tvitemPost, 'Functions', pointer(ETDFunctions));

          ListarTabelasPost();
          BuscaSequence(zpostqry1, DBPostgres);
          ListarViewsPost();
          //ShapeCon.brush.color := clGreen;
        end;
    finally
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
  qntd : integer;
  tvitem : ttreenode;
begin
  try
  pnErro.Visible:= false;
  if zconpost.Connected then
  begin
      qntd := pos('create table',edSQL.lines.text);
      if (qntd>0) then
      begin
        //tvitem := tvPost.Items.FindNodeWithText(tvMysql.Selected.text);
        tvitem := posicaofieldsmy.FindNode(tvMysql.Selected.text);

        if (tvitem  = nil) then
        begin
          zqrypost.close;
          Zqrypost.SQL.Clear;
          zqrypost.sql.text := edSQL.text;
          zqrypost.Prepare;
          Zqrypost.ExecSQL;
        end
         else
        begin
          Showmessage('Tabela Existe');
        end;
      end;
      qntd := pos('create sequence ', edSQL.lines.text);

      if (qntd >= 0) then
      begin
        //tvitem := tvPost.Items.FindNodeWithText(tvMysql.Selected.text);
        tvitem := posicaoSequencePost.FindNode(tvMysql.Selected.text);
        if (tvitem  = nil) then
        begin
          zqrypost.close;
          Zqrypost.SQL.Clear;
          zqrypost.sql.text := edSQL.text;
          zqrypost.Prepare;
          Zqrypost.ExecSQL;
        end
         else
        begin
          Showmessage('Sequence Existe');
        end;
      end;


  end;
  except


    {$IFDEF DARWIN}
    on E: Exception  do
    {$ELSE}
    on E: EZSQLException  do
    {$ENDIF}

     begin
       pnErro.Visible:= true;
       edErro.text := E.message;
       processaErro(E.message);
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


end.


