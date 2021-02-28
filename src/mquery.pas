unit mquery;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, DBCtrls,
  DBGrids, PairSplitter, Menus, ComCtrls, StdCtrls, SynEdit, SynHighlighterSQL,
  ZConnection, ZDataset, TypeDB, Tabela, setbanco, SetMQuery, cfgdb;

type

  { TfrmMQuery }

  TfrmMQuery = class(TForm)
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    edSearch: TEdit;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    Connect: TMenuItem;
    mnitemNew: TMenuItem;
    mnStay: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    mnconection1: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    mnFixar: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    SynEdit1: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    TabSheet1: TTabSheet;
    tvBanco: TTreeView;
    zpostcon: TZConnection;
    zmycon: TZConnection;
    zmyqry: TZQuery;
    zpostqry: TZQuery;
    zmyqry1: TZReadOnlyQuery;
    zpostqry1: TZReadOnlyQuery;

    procedure ConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure mnconection1Click(Sender: TObject);
    procedure mnitemNewClick(Sender: TObject);
    procedure mnStayClick(Sender: TObject);
    procedure mnFixarClick(Sender: TObject);
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
    sequences : TStringList;
    FSetBanco : TSetBanco;
    FSetMQuery : TSetMQuery;
    FScheme : String;
    procedure ListarTabelasMy();
    procedure ListarTabelasPost();
    procedure ProcuraTVMysql(Nome: String);
    procedure ProcuraTVPost(Nome: String);
    procedure BuscaSequence(qry:TZReadOnlyQuery;  TypeDB: TypeDatabase);
    procedure RefreshPost();
    function GeraSQL(Tabela : TTabela): string;
    function TipoConv(Tabela : TTabela; Posicao: integer): String;
    procedure CarregaContexto();
    procedure ConectarMy();
    procedure CarregaDB();
    procedure AtualizaConexoesDB();
  public

  end;

var
  frmMQuery: TfrmMQuery;

implementation

{$R *.lfm}
function Tfrmmquery.TipoConv(Tabela : TTabela; Posicao: integer): String;
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

function Tfrmmquery.GeraSQL(Tabela: TTabela): string;
var
  Comando : string;
  a : integer;
begin

  Comando := '--Criado por MQuery em '+datetostr(now)+#13+#10;
  Comando := Comando + 'CREATE TABLE '+Fscheme+'.'+Tabela.Tablename+'('+#13+#10 ;
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
        Comando := Comando + ' comment on column '+FScheme+'.'+Tabela.Tablename+'.'+ tabela.fieldname[a]+ ' is '+#39+Tabela.fieldcomment[a]+#39+';'#13+#10;

  end;
  //Comando := Comando+ ';'+#13+#10;
  result := Comando;
end;

procedure TfrmMQuery.ListarTabelasMy();
var
  Tabela : TTabela;
  tvitem : TTreeNode;
  tvcolunas : TTreeNode;
  tvindice : TTreeNode;
  tvFK : TTreeNode;
  TabelaNome : string;
  a : integer;
  banco : string;
begin
  zmyqry.close;
  banco := '';
  //pnlProgresso.Visible:= true;
  zmyqry.sql.text :=   'select * from information_schema.tables order by table_name';
  zmyqry.open;
  zmyqry.First;
  //pgbar.Max:= zmyqry.RecordCount;
  //pgbar.Position:=0;
  posicaofieldsmy.DeleteChildren;
  while not zmyqry.EOF do
  begin
     if zmyqry.FieldByName('table_schema').asstring = Banco then
     begin
       TabelaNome := zmyqry.FieldByName('table_name').asstring;
       Tabela := TTabela.create(zmyqry1,TabelaNome, DBMysql);

       tvitem := TTreenode.Create(tvBanco.items);
       tvitem := tvBanco.Items.AddNode(tvitem,posicaofieldsmy,TabelaNome,pointer(Tabela),naAddChild);

       (*Adiciona colunas da tabela*)
       tvcolunas := tvBanco.Items.AddChildObject(tvitem,'campos', pointer(ETDBCampos));
       for a:= 0 to tabela.count-1 do
       begin
         tvBanco.items.AddChildObject(tvcolunas,tabela.fieldname[a],pointer(a));
       end;

       (*adiciona pk da tabela*)
       tvindice := tvBanco.Items.AddChildObject(tvitem,'Chave Primaria',pointer(ETDBPK));
       for a := 0 to tabela.chaves.primarykeys.Count-1 do
       begin
         tvBanco.items.AddChildObject(tvindice,tabela.chaves.primarykeys[a],pointer(a));
       end;

       (*adiciona pk da tabela*)
       tvFK := tvBanco.Items.AddChildObject(tvitem,'Chave Extrangeira',pointer(ETDBFK));
       for a := 0 to tabela.chaves.coinstraintname.Count-1 do
       begin
         tvBanco.items.AddChildObject(tvFK,tabela.chaves.coinstraintname[a],pointer(a));
       end;


     end;
     zmyqry.next;
     //pgbar.Position:=pgbar.Position+1;
     Application.ProcessMessages;
  end;
  //pnlProgresso.Visible:= false;
  tvBanco.FullExpand;
end;

procedure TfrmMQuery.CarregaDB();
var
   tvitem : TTreeNode;
   //tvitemmy : TTreeNode;
   //tvitempost : TTreeNode;
begin
  if (FSetMQuery = nil) then
  begin
        FsetMQuery := TsetMQuery.create();
  end;
  CarregaContexto();
  if (FSetBanco.TipoBanco = DBMysql) then
  begin
       tvitem := TTreeNode.Create(tvBanco.Items);
       tvitemmy := tvBanco.Items.AddObject(tvitem,'Mysql', pointer(ETDBBanco));
  end;

  if (FSetBanco.TipoBanco = DBPostgres) then
  begin
       tvitem := TTreeNode.Create(tvBanco.Items);
       tvitempost := tvBanco.Items.AddObject(tvitem,'Postgres', pointer(ETDBBanco));
  end;

end;

procedure TfrmMQuery.FormCreate(Sender: TObject);
var
  tvitem : TTreeNode;
begin

  FSetBanco := TSetBanco.create(0);
  FSetBanco.CarregaContexto();
  Fscheme := FsetBanco.scheme;
  AtualizaConexoesDB();


end;

procedure TfrmMQuery.ConnectClick(Sender: TObject);
begin
  if (FSetBanco <> nil) then
  begin
    if (FSetBanco.nrocfg <> self.tag) then
    begin
         FSetBanco.destroy();
         FSetBanco := nil;
    end;
  end;
  if (FSetBanco = nil) then
  begin
        FsetBanco := TsetBanco.create(self.tag);
  end;
  CarregaDB();
  ConectarMy();


end;

procedure TfrmMQuery.FormDestroy(Sender: TObject);
begin
  Fsetmquery.posx := Left;
  Fsetmquery.posy := top;
  Fsetmquery.SalvaContexto(false);
end;

procedure TfrmMQuery.MenuItem11Click(Sender: TObject);
begin
  Top := (Screen.DesktopHeight - Height) DIV 2;
  Left := (Screen.DesktopWidth - Width) DIV 2;
end;

procedure TfrmMQuery.MenuItem2Click(Sender: TObject);
begin

end;

procedure TfrmMQuery.mnconection1Click(Sender: TObject);
begin

end;

procedure TfrmMQuery.mnitemNewClick(Sender: TObject);
begin
  if FSetBanco = nil then
  begin
     FSetBanco := TSetBanco.create(0);
  end;
  if frmcfgdb = nil then
  begin
       frmcfgdb := Tfrmcfgdb.Create(self);
  end;
  frmcfgdb.setbanco := FSetBanco;
  frmcfgdb.ShowModal;
  if (frmcfgdb.Save = true) then
  begin
    (*Salva o contexto*)

    FSetBanco.HostName:=frmcfgdb.edHostname.text;
    FSetBanco.Password:=frmcfgdb.edPassword.text;
    FSetBanco.User:=frmcfgdb.edUsername.text;
    FSetBanco.TipoBanco:=TypeDatabase(frmcfgdb.cbdbtype.ItemIndex);
    FSetBanco.Databasename:=frmcfgdb.edDatabase.text;
    FSetBanco.SalvaContexto(false);
  end;
  AtualizaConexoesDB();
end;

procedure TfrmMQuery.AtualizaConexoesDB();
begin
  //Atualiza conexoes
  if FSetBanco <> nil then
  begin
    mnconection1.Visible:=true;
    mnconection1.Caption:= fsetbanco.Databasename;
  end;
end;

procedure TfrmMQuery.ConectarMy();
var
  tvitem : TTreeNode;
begin
   try
        tvBanco.items.clear;
        tvitem := TTreeNode.Create(tvBanco.items);
        posicaofieldsmy := tvBanco.Items.AddChildObject(tvitemmy, 'Tabelas', pointer(ETDTabelas));
        posicaoViewmy := tvBanco.Items.AddChildObject(tvitemmy, 'Views', pointer(ETDViews));
        posicaoProceduremy := tvBanco.Items.AddChildObject(tvitemmy, 'Procedure', pointer(ETDProcedure));
        posicaoFunctionmy := tvBanco.Items.AddChildObject(tvitemmy, 'Functions', pointer(ETDFunctions));
        zmycon.Disconnect;
        zmycon.HostName := FSetBanco.HostName; //edHostName.Text;
        zmycon.User:= FSetBanco.User; //edusuario.text;
        zmycon.Password:= FSetBanco.Password;//edPasswrd.Text;
        //zmycon.
        {$IFDEF WINDOWS}
        zmycon.LibraryLocation:=ExtractFilePath(application.ExeName)+'libmysql64.dll';
        {$ENDIF}
        zmycon.Connect;
        if zmycon.Connected then
        begin
          ListarTabelasMy();
        end;
    finally
    end;
end;


procedure TfrmMQuery.mnStayClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
  begin
    FormStyle:= fsStayOnTop;
    Fsetmquery.stay := true;
    mnStay.Caption:='Normal';
  end
  else
  begin
    FormStyle:=fsNormal;
    Fsetmquery.stay := false;
    mnStay.Caption:='On Top';
  end;
  refresh;
  Fsetmquery.SalvaContexto(false);
end;

procedure TfrmMQuery.mnFixarClick(Sender: TObject);
begin
    if (BorderStyle = bsNone) then
    begin
      BorderStyle:=bsSingle;
      Fsetmquery.fixar := true;
      mnFixar.Caption:='Fix';

      self.refresh;
    end
    else
    begin
      BorderStyle:=bsNone;
      Fsetmquery.fixar := false;
      mnFixar.Caption:='Move';
      //self.hide;
      //self.show;
      self.refresh;
    end;
    Fsetmquery.SalvaContexto(false);

end;

procedure TfrmMquery.CarregaContexto();
begin
  if (FSetBanco <> nil) then
  begin
       FSetBanco.CarregaContexto();
       FsetMQuery.CarregaContexto();
       Left:= FsetMQuery.posx;
       top:= FsetMQuery.posy;
       if FsetMQuery.stay then
       begin
            FormStyle:= fsStayOnTop;
       end
       else
       begin
            FormStyle:= fsNormal;
       end;
       if FSetMQuery.fixar then
       begin
            BorderStyle:=bsSingle;
       end
  else
  begin
    BorderStyle:=bsNone;
    //mnFixar.Caption:= 'Move';
    //mnFixW.caption := 'Move' ;
  end;
  end;

end;

procedure Tfrmmquery.ListarTabelasPost();
var
  Tabela : TTabela;
  tvitem : TTreeNode;
  tvcolunas : TTreeNode;
  tvindice : TTreeNode;
  tvFK : TTreeNode;
  TabelaNome : string;
  a : integer;
begin
  try
    zpostqry.close;
    //pnlProgresso1.Visible:= true;
    zpostqry.sql.text := 'select * from information_schema.tables '+
                 ' where table_schema = '+#39+FScheme+#39+
                 ' and table_type = '+#39+'BASE TABLE'+ #39+
                 ' order by table_name ';



    //zmycon.sql.text :=   'select * from tb_parametro';
    zpostqry.open;
    zpostqry.First;
    //pgbar1.Max:= zpostqry.RecordCount;
    //pgbar1.Position:=0;
    posicaofieldspost.DeleteChildren;
    while not zpostqry.EOF do
    begin
      if zpostqry.FieldByName('table_schema').asstring = FScheme then
      begin
        TabelaNome := zpostqry.FieldByName('table_name').asstring;
        Tabela := TTabela.create(zpostqry1,TabelaNome, DBPostgres);
        tvitem := TTreenode.Create(tvBanco.items);
        tvitem := tvBanco.Items.AddNode(tvitem,posicaofieldspost,TabelaNome,pointer(Tabela),naAddChild);
      end;

      (*Adiciona colunas da tabela*)
      tvcolunas := tvBanco.Items.AddChildObject(tvitem,'campos', pointer(ETDBCampos));
      for a:= 0 to tabela.count-1 do
      begin
        tvBanco.items.AddChildObject(tvcolunas,tabela.fieldname[a],pointer(a));
      end;

      (*adiciona pk da tabela*)
      tvindice := tvBanco.Items.AddChildObject(tvitem,'Chave Primaria',pointer(ETDBPK));
      for a := 0 to tabela.chaves.primarykeys.Count-1 do
      begin
        tvBanco.items.AddChildObject(tvindice,tabela.chaves.primarykeys[a],pointer(a));
      end;

      (*adiciona pk da tabela*)
      tvFK := tvBanco.Items.AddChildObject(tvitem,'Chave Extrangeira',pointer(ETDBFK));
      for a := 0 to tabela.chaves.coinstraintname.Count-1 do
      begin
        tvBanco.items.AddChildObject(tvFK,tabela.chaves.coinstraintname[a],pointer(a));
      end;


      zpostqry.next;
      //pgbar1.Position:=pgbar1.Position+1;
      Application.ProcessMessages;
    end;

  finally
    //pnlProgresso1.Visible:= false;
    tvBanco.FullExpand;

  end;
end;

procedure TfrmMQuery.ProcuraTVMysql(Nome: String);
begin

end;

procedure TfrmMQuery.ProcuraTVPost(Nome: String);
begin

end;

procedure TfrmMQuery.BuscaSequence(qry: TZReadOnlyQuery; TypeDB: TypeDatabase);
begin

end;

procedure Tfrmmquery.RefreshPost();
var
  tvitem : TTreeNode;
begin
     tvitempost.DeleteChildren;
     //ShapeCon.brush.color := clWhite;
     try
        tvitem := TTreeNode.Create(tvBanco.items);
        posicaofieldspost := tvBanco.Items.AddChildObject(tvitemPost, 'Tabelas',pointer(ETDTabelas));
        posicaoSequencePost := tvBanco.Items.AddChildObject(tvitemPost, 'Sequences',pointer(ETDTabelas));
        posicaoViewPost := tvBanco.Items.AddChildObject(tvitemPost, 'Views', pointer(ETDViews));
        posicaoProcedurePost := tvBanco.Items.AddChildObject(tvitemPost, 'Procedure', pointer(ETDProcedure));
        posicaoFunctionPost := tvBanco.Items.AddChildObject(tvitemPost, 'Functions', pointer(ETDFunctions));
        zpostcon.Disconnect;
        zpostcon.HostName := FSetBanco.HostName;
        zpostcon.User:= FSetBanco.User;
        zpostcon.Password:= FSetBanco.Password;
        zpostcon.Connect;
        if zpostcon.Connected then
        begin
          ListarTabelasPost();
          BuscaSequence(zpostqry1, DBPostgres);
          //ShapeCon.brush.color := clGreen;
        end;
    finally
    end;
end;


end.

