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
    edSearch: TEdit;
    ImageList2: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    Connect: TMenuItem;
    mnitemNew: TMenuItem;
    mnStay: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    mnconection1: TMenuItem;
    miedit: TMenuItem;
    miDelete: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    mnFixar: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
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
    procedure MenuItem7Click(Sender: TObject);
    procedure mieditClick(Sender: TObject);
    procedure mnconection1Click(Sender: TObject);
    procedure mnitemNewClick(Sender: TObject);
    procedure mnStayClick(Sender: TObject);
    procedure mnFixarClick(Sender: TObject);
    procedure Panel8Click(Sender: TObject);
  private
    posicaofields : TTreeNode;
    tvitem : TTreeNode;
    posicaoView : TTreeNode;
    posicaoProcedure : TTreeNode;
    posicaoFunction : TTreeNode;
    posicaoViewPost : TTreeNode;
    posicaoSequence : TTreeNode;
    sequences : TStringList;
    FSetBanco : TSetBanco;
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
    procedure ConectarPost();
    procedure CarregaDB();
    procedure AtualizaConexoesDB();
  public
    function getdatabasetype : TypeDatabase;
    function GetTables() : TStringlist;
  end;

var
  frmMQuery: TfrmMQuery;

implementation

{$R *.lfm}

function Tfrmmquery.GetTables() : TStringlist;
var
  LLista : TStringlist;
begin
  LLista := TStringlist.create;
  if FSetBanco <> nil then
  begin
       zmyqry.sql.text :=   'select * from information_schema.tables '+
       ' where table_schema = "'+ FSetBanco.Databasename +'"'+
       'order by table_name';
       zmyqry.open;
       zmyqry.First;
       while not zmyqry.EOF do
       begin
            if zmyqry.FieldByName('TABLE_SCHEMA').asstring = FSetBanco.Databasename then
            begin
                 LLista.Append(zmyqry.FieldByName('table_name').asstring);

            end;
            zmyqry.Next;
       end;
  end;
  result:= LLista;
end;

function Tfrmmquery.getdatabasetype : TypeDatabase;
begin
  if FSetBanco <> nil then
  begin
   result := FSetBanco.TipoBanco;

  end
  else
  begin
   result := DBUndefinid;
  end;
end;

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
  //tvitem : TTreeNode;
  tvcolunas : TTreeNode;
  tvindice : TTreeNode;
  tvFK : TTreeNode;
  TabelaNome : string;
  a : integer;
  banco : string;
begin
  zmyqry.close;
  banco :=  FSetBanco.Databasename;
  zmyqry.sql.text :=   'select * from information_schema.tables '+
       ' where table_schema = "'+ banco +'"'+
       'order by table_name';
  zmyqry.open;
  zmyqry.First;

  posicaofields.DeleteChildren;
  while not zmyqry.EOF do
  begin
     if zmyqry.FieldByName('TABLE_SCHEMA').asstring = Banco then
     begin
       TabelaNome := zmyqry.FieldByName('table_name').asstring;
       Tabela := TTabela.create(zmyqry1,TabelaNome, DBMysql);

       tvitem := TTreenode.Create(tvBanco.items);
       tvitem := tvBanco.Items.AddNode(tvitem,posicaofields,TabelaNome,pointer(Tabela),naAddChild);
       tvitem.ImageIndex:=17;

       (*Adiciona colunas da tabela*)
       tvcolunas := tvBanco.Items.AddChildObject(tvitem,'campos', pointer(ETDBCampos));
       for a:= 0 to tabela.count-1 do
       begin
         ttreenode(tvBanco.items.AddChildObject(tvcolunas,tabela.fieldname[a],pointer(a))).ImageIndex:=18;
       end;

       (*adiciona pk da tabela*)
       tvindice := tvBanco.Items.AddChildObject(tvitem,'Chave Primaria',pointer(ETDBPK));
       for a := 0 to tabela.chaves.primarykeys.Count-1 do
       begin
         ttreenode(tvBanco.items.AddChildObject(tvindice,tabela.chaves.primarykeys[a],pointer(a))).ImageIndex:=19;
       end;

       (*adiciona pk da tabela*)
       tvFK := tvBanco.Items.AddChildObject(tvitem,'Chave Extrangeira',pointer(ETDBFK));
       tvFk.ImageIndex:=20;
       for a := 0 to tabela.chaves.coinstraintname.Count-1 do
       begin
         ttreenode(tvBanco.items.AddChildObject(tvFK,tabela.chaves.coinstraintname[a],pointer(a))).ImageIndex:=21;
       end;


     end;
     zmyqry.next;
  end;
  tvBanco.refresh;
  Application.ProcessMessages;
  tvBanco.FullExpand;
end;

procedure TfrmMQuery.CarregaDB();
var
   ltvitem : TTreeNode;
begin
  if (FSetMQuery = nil) then
  begin
        FsetMQuery := TsetMQuery.create();
  end;
  CarregaContexto();
  if (FSetBanco.TipoBanco = DBMysql) then
  begin
       ltvitem := TTreeNode.Create(tvBanco.Items);
       tvitem := tvBanco.Items.AddObject(ltvitem,'Mysql', pointer(ETDBBanco));
       tvitem.ImageIndex:= 1;
  end;

  if (FSetBanco.TipoBanco = DBPostgres) then
  begin
       ltvitem := TTreeNode.Create(tvBanco.Items);
       tvitem := tvBanco.Items.AddObject(ltvitem,'Postgres', pointer(ETDBBanco));
       tvitem.ImageIndex:= 1;
  end;

end;

procedure TfrmMQuery.FormCreate(Sender: TObject);
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
  if (FSetBanco.TipoBanco = DBMysql) then
  begin
    ConectarMy();
  end;
  if (FSetBanco.TipoBanco = DBPostgres) then
  begin
    ConectarPost();
  end;



end;

procedure TfrmMQuery.FormDestroy(Sender: TObject);
begin
  if (Fsetmquery<> nil) then
  begin
       Fsetmquery.posx := Left;
       Fsetmquery.posy := top;
       Fsetmquery.SalvaContexto(false);

  end;

end;

procedure TfrmMQuery.MenuItem11Click(Sender: TObject);
begin
  Top := (Screen.DesktopHeight - Height) DIV 2;
  Left := (Screen.DesktopWidth - Width) DIV 2;
end;

procedure TfrmMQuery.MenuItem2Click(Sender: TObject);
begin

end;

procedure TfrmMQuery.MenuItem7Click(Sender: TObject);
begin
  close;
end;

procedure TfrmMQuery.mieditClick(Sender: TObject);
begin
    tvBanco.items.clear;
  zmycon.Connected:=false;
  zpostcon.connected := false;
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
    FSetBanco.Port := frmcfgdb.edPort.text;
    FSetBanco.Databasename:=frmcfgdb.edDatabase.text;

    FSetBanco.SalvaContexto(false);
  end;
  AtualizaConexoesDB();
end;

procedure TfrmMQuery.mnconection1Click(Sender: TObject);
begin

end;

procedure TfrmMQuery.mnitemNewClick(Sender: TObject);
begin
  tvBanco.items.clear;
  zmycon.Connected:=false;
  zpostcon.connected := false;
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
    FSetBanco.Port := frmcfgdb.edPort.text;
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
    miedit.Visible:=true;
    miDelete.Visible:=true;
    mnconection1.Caption:= fsetbanco.Databasename;
  end;
end;

procedure TfrmMQuery.ConectarMy();
var
  ltvitem : TTreeNode;
  location : string;
begin
   try
        //tvBanco.items.clear;

        zmycon.Disconnect;
        zmycon.HostName := FSetBanco.HostName; //edHostName.Text;
        zmycon.User:= FSetBanco.User; //edusuario.text;
        zmycon.Catalog:= FSetBanco.Databasename;
        if FSetBanco.Password = '' then
        begin
           zmycon.LoginPrompt:=true;
        end
        else
        begin
           zmycon.LoginPrompt:=false;
           zmycon.Password:= FSetBanco.Password;//edPasswrd.Text;
        end;
        zmycon.port := 3306;
        {$IFDEF WINDOWS}
        zmycon.LibraryLocation:=ExtractFilePath(application.ExeName)+'libmysql64.dll';
        {$ENDIF}
        {$IFDEF DARWIN}
         location := '/usr/local/mysql-connector-c-6.1.11-macos10.12-x86_64/lib/libmysqlclient.dylib';
         if FileExists(location) then
         begin
            zmycon.LibLocation:= location;
            //zmycon.LibraryLocation:='/usr/local/mysql-connector-c-6.1.11-macos10.12-x86_64/lib/libmysqlclient.dylib';
         end
         else
         begin
            showmessage('Lib not found:'+location);
            close;
         end;
        {$ENDIF}
        {$IFDEF LINUX}
         zmycon.LibraryLocation:='/usr/lib/x86_64-linux-gnu/libmysqlclient.so';
        {$ENDIF}
        zmycon.Connect;
        if zmycon.Connected then
        begin
           ltvitem := TTreeNode.Create(tvBanco.items);
           posicaofields := tvBanco.Items.AddChildObject(tvitem, 'Tabelas', pointer(ETDTabelas));
           posicaofields.ImageIndex:= 3;
           posicaoView := tvBanco.Items.AddChildObject(tvitem, 'Views', pointer(ETDViews));
           posicaoView.ImageIndex:= 16;
           posicaoProcedure := tvBanco.Items.AddChildObject(tvitem, 'Procedure', pointer(ETDProcedure));
           posicaoProcedure.ImageIndex:=14;
           posicaoFunction := tvBanco.Items.AddChildObject(tvitem, 'Functions', pointer(ETDFunctions));
           posicaoFunction.ImageIndex:=15;
           ListarTabelasMy();
        end;
    except
      showmessage('Erro ao tentar conectar no banco de dados!');
    end;
end;

procedure TfrmMQuery.ConectarPost();
var
  ltvitem : TTreeNode;
begin
   try
        tvBanco.items.clear;

        zpostcon.Disconnect;
        zpostcon.HostName := FSetBanco.HostName; //edHostName.Text;
        zpostcon.User:= FSetBanco.User; //edusuario.text;
        if FSetBanco.Password = '' then
        begin
             zpostcon.LoginPrompt:=true;
        end
        else
        begin
             zpostcon.LoginPrompt:=false;
             zpostcon.Password:= FSetBanco.Password;//edPasswrd.Text;
        end;
        //zmycon.

        {$IFDEF WINDOWS}
        zpostcon.LibraryLocation:=ExtractFilePath(application.ExeName)+'libmysql64.dll';
        {$ENDIF}
        {$IFDEF DARWIN}
         zmycon.LibraryLocation:=ExtractFilePath(application.ExeName)+'libmysql64.dll';
        {$ENDIF}
        {$IFDEF LINUX}
         zpostcon.LibraryLocation:=ExtractFilePath(application.ExeName)+'libmysql64.dll';
        {$ENDIF}
        zpostcon.Connect;
        if zpostcon.Connected then
        begin
             ltvitem := TTreeNode.Create(tvBanco.items);
             posicaofields := tvBanco.Items.AddChildObject(ltvitem, 'Tabelas', pointer(ETDTabelas));
             posicaofields.ImageIndex:= 3;
             posicaoView := tvBanco.Items.AddChildObject(ltvitem, 'Views', pointer(ETDViews));
             posicaoView.ImageIndex:= 16;
             posicaoProcedure := tvBanco.Items.AddChildObject(ltvitem, 'Procedure', pointer(ETDProcedure));
             posicaoProcedure.ImageIndex:=14;
             posicaoFunction := tvBanco.Items.AddChildObject(ltvitem, 'Functions', pointer(ETDFunctions));
             posicaoFunction.ImageIndex:=15;
             ListarTabelasPost();
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

procedure TfrmMQuery.Panel8Click(Sender: TObject);
begin

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
  ltvitem : TTreeNode;
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
    posicaofields.DeleteChildren;
    while not zpostqry.EOF do
    begin
      if zpostqry.FieldByName('table_schema').asstring = FScheme then
      begin
        TabelaNome := zpostqry.FieldByName('table_name').asstring;
        Tabela := TTabela.create(zpostqry1,TabelaNome, DBPostgres);
        ltvitem := TTreenode.Create(tvBanco.items);
        ltvitem := tvBanco.Items.AddNode(ltvitem,posicaofields,TabelaNome,pointer(Tabela),naAddChild);
      end;

      (*Adiciona colunas da tabela*)
      tvcolunas := tvBanco.Items.AddChildObject(ltvitem,'campos', pointer(ETDBCampos));
      for a:= 0 to tabela.count-1 do
      begin
        tvBanco.items.AddChildObject(tvcolunas,tabela.fieldname[a],pointer(a));
      end;

      (*adiciona pk da tabela*)
      tvindice := tvBanco.Items.AddChildObject(ltvitem,'Chave Primaria',pointer(ETDBPK));
      for a := 0 to tabela.chaves.primarykeys.Count-1 do
      begin
        tvBanco.items.AddChildObject(tvindice,tabela.chaves.primarykeys[a],pointer(a));
      end;

      (*adiciona pk da tabela*)
      tvFK := tvBanco.Items.AddChildObject(ltvitem,'Chave Extrangeira',pointer(ETDBFK));
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
  ltvitem : TTreeNode;
begin
     tvitem.DeleteChildren;
     //ShapeCon.brush.color := clWhite;
     try
        ltvitem := TTreeNode.Create(tvBanco.items);
        posicaofields := tvBanco.Items.AddChildObject(tvitem, 'Tabelas',pointer(ETDTabelas));
        posicaoSequence := tvBanco.Items.AddChildObject(tvitem, 'Sequences',pointer(ETDTabelas));
        posicaoView := tvBanco.Items.AddChildObject(tvitem, 'Views', pointer(ETDViews));
        posicaoProcedure := tvBanco.Items.AddChildObject(tvitem, 'Procedure', pointer(ETDProcedure));
        posicaoFunction := tvBanco.Items.AddChildObject(tvitem, 'Functions', pointer(ETDFunctions));
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

