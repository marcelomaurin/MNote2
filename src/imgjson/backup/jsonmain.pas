unit jsonmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  About, setimg, config, EditBtn, ExtCtrls, ComCtrls, Grids,
  setproject, Novo, funcoes, base, sqleditor, sqlEditItem, NNTrainning,
  frmnntrainning, PythonEngine;



type

  { TfrmmainJSON }

  TfrmmainJSON = class(TForm)
    DeleteItem1: TMenuItem;
    Edit1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    mnitemrunTeste: TMenuItem;
    miruntrainning: TMenuItem;
    miMake: TMenuItem;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    Edit: TMenuItem;
    Export: TMenuItem;
    DeleteItem: TMenuItem;
    MenuItem2: TMenuItem;
    miMakeTrainning: TMenuItem;
    miMakeTeste: TMenuItem;
    miNewItem: TMenuItem;
    mitrainning: TMenuItem;
    miQuery: TMenuItem;
    miClose: TMenuItem;
    mnConfig: TMenuItem;
    mnNovo: TMenuItem;
    mnsobre: TMenuItem;
    mnTools: TMenuItem;
    mnSair: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    pcgrade: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    pmNNGroup: TPopupMenu;
    pmNNTrainning: TPopupMenu;
    pnMenu: TPanel;
    pnGrade: TPanel;
    pnPrincipal: TPanel;
    pmProject: TPopupMenu;
    pmDatabase: TPopupMenu;
    pmSQLEditItem: TPopupMenu;
    Separator1: TMenuItem;
    mnSalvar: TMenuItem;
    nmOpen: TMenuItem;
    mnFile: TMenuItem;
    Separator2: TMenuItem;
    Splitter1: TSplitter;
    StringGrid1: TStringGrid;
    tspropriedades: TTabSheet;
    tsTreeview: TTabSheet;
    TreeView1: TTreeView;
    procedure DeleteItemClick(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure miMakeTesteClick(Sender: TObject);
    procedure miMakeTrainningClick(Sender: TObject);
    procedure miNewItemClick(Sender: TObject);
    procedure miruntrainningClick(Sender: TObject);
    procedure mitrainningClick(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure miQueryClick(Sender: TObject);
    procedure mnConfigClick(Sender: TObject);
    procedure mnNovoClick(Sender: TObject);
    procedure mnSairClick(Sender: TObject);
    procedure mnSalvarClick(Sender: TObject);
    procedure mnsobreClick(Sender: TObject);
    procedure nmOpenClick(Sender: TObject);
    procedure SairPrograma();
    procedure ChamaAbout();
    procedure FechaProjeto();
    procedure CriaProjeto();
    procedure CarregaProjeto();
    procedure CarregaDatabase();
    procedure CarregaNN();
    procedure CarregaQuerys();
    procedure CarregaNNTrainning();
    function AbreProjeto() : boolean;
    function AbreProjetofield() : boolean;
    procedure Splitter1Moved(Sender: TObject);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1Exit(Sender: TObject);
    procedure StringGrid1GetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure TreeView1Changing(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure TreeView1Click(Sender: TObject);
    procedure TreinaRedeNN(item: TSQLEditItem);


  private
    tvProjeto : TTreenode;
    tvDatabase : TTreenode;
    tvNNTrainning : TTreenode;
    tvItem : TTreenode;

    selecttreenode : TTreeNode;
    procedure controlelog(Sender: TObject; const OutputLine: String);
    procedure PopulaTV();
    procedure NewQuery();
    procedure NewNNTrainning();
    procedure NewNNTrainning(sql : string);
    procedure RegistraQuery(Nome : string; sql : string);
    procedure IncluiQuery(Nome: string; sql: string);

    procedure RegistraNNTrainning(nome: string;comentario : string ;
      sqlitemtrainning: TSQLEditItem;
      sqlitemtest: TSQLEditItem;
      cbtypenn : integer ;
      edGroupBy : string;
      InputField : string;
      InputRef: string;        //Novo
      InputRefField: string;   //Novo
      InputRefKey: string;     //Novo
      InputFieldTester : string;
      InputRefTester: string;        //Novo
      InputRefFieldTester: string;   //Novo
      InputRefKeyTester: string;     //Novo
      OutputField: string;
      OutputFieldTester: string;
      Python : string;
      jsontrainning : string;
      FilterValue: string;
      FilterValueTester: string;
      fileJSONTester : string;
      LJSONTester : string
      );
    procedure IncluiNNTrainning(
      nome: string;
      comentario: string;
      sqlitemtrainning: TSQLEditItem;
      sqlitemtest: TSQLEditItem;
      cbtypenn: integer;
      edGroupBy: string;
      InputField: string;
      InputRef: string;
      InputRefField: string;
      InputRefKey: string;
      InputFieldTester: string;
      InputRefTester: string;
      InputRefFieldTester: string;
      InputRefKeyTester: string;
      OutputField: string;
      OutputFieldTester: string;
      Python: string;
      jsontrainning: string;
      FilterValue: string;
      FilterValueTester: string;
      fileJSONTester: string;
      LJSONTester: string
      );

  public

  end;

var
  frmmainJSON: TfrmmainJSON;

implementation

uses main;

{$R *.lfm}

{ TfrmmainJSON }

procedure TfrmmainJSON.mnSairClick(Sender: TObject);
begin
    SairPrograma();

end;

procedure TfrmmainJSON.mnSalvarClick(Sender: TObject);
begin
  if (Fsetproject <> nil) then
  begin
       Fsetproject.SalvaContexto(false);
  end;
end;

procedure TfrmmainJSON.FormCreate(Sender: TObject);
begin
  selecttreenode := nil;
  FSetImg := TSetImg.create();
  FSetImg.CarregaContexto();

end;

procedure TfrmmainJSON.EditClick(Sender: TObject);
var
   //item : TNNTrainning;
  item : TSQLEditItem;
begin
  //Edita valor ja registrado
  item := TSQLEditItem(selecttreenode.Data);
  frmSQLEditor := TfrmSQLEditor.create(self);
  frmSQLEditor.edNome.text := item.Nome;
  frmSQLEditor.SynEdit1.Text := item.SQL;
  frmSQLEditor.showmodal;
  if(frmSQLEditor.flgsalvar) then
  begin
       item.Nome:= frmSQLEditor.edNome.text;
       item.sql := frmSQLEditor.SynEdit1.Text;
       selecttreenode.data := pointer(item);
  end;
  frmSQLEditor.Free;
  frmSQLEditor := nil;

end;

procedure TfrmmainJSON.DeleteItemClick(Sender: TObject);
begin

end;

procedure TfrmmainJSON.Edit1Click(Sender: TObject);
var
   item : TNNTrainning;
begin
  //Edita valor ja registrado
  item := TNNTrainning(selecttreenode.Data);
  frmnntrain := Tfrmnntrain.Create(self);
  frmnntrain.load(item); //Carrega o item no form
  frmnntrain.ShowModal;
  item := frmnntrain.save(); //Salva o item no form
  selecttreenode.Data := pointer(item);
  frmnntrain.Free;
  frmnntrain := nil;

end;

procedure TfrmmainJSON.FormDestroy(Sender: TObject);
begin
  FSetImg.SalvaContexto(true);
  FSetImg.free;
  FSetImg := nil;
end;

procedure TfrmmainJSON.MenuItem4Click(Sender: TObject);
begin
  if (Fsetproject <> nil) then
  begin

       Fsetproject.SalvaContexto(false);
  end;
end;

procedure TfrmmainJSON.miMakeTesteClick(Sender: TObject);
var
   item : TNNTrainning;
   arquivo : Tstringlist;
   marca : string;
   filter : string;
begin
  //Questiona o projeto que quer usar
  //AbreProjetofield();
  //Produzindo os dados de teste (JSON)
  arquivo := TStringList.create();
  //Edita valor ja registrado

  item := TNNTrainning(selecttreenode.Data);
  filter := item.FilterValueTester;
  item.FilterValueTester:=filter;
  marca := item.FilterCondition;
  //Rodando Teste JSON
  if( item.testerJSON(marca)) then
  begin
    ShowMessage('File Make!');
    //Atualiza o json de treinamento
    //item.jsontrainning :=  arquivo.LoadFromFile('training_data.json');
  end;
  selecttreenode.Data := pointer(item);

end;

procedure TfrmmainJSON.miMakeTrainningClick(Sender: TObject);
var
   item : TNNTrainning;
   arquivo : Tstringlist;
begin
  arquivo := TStringList.create();
  //Edita valor ja registrado
  item := TNNTrainning(selecttreenode.Data);
  if( item.trainnerJSON()) then
  begin
    ShowMessage('File Make!');
    //Atualiza o json de treinamento
    //item.jsontrainning :=  arquivo.LoadFromFile('training_data.json');
  end;
  selecttreenode.Data := pointer(item);
end;

procedure TfrmmainJSON.miNewItemClick(Sender: TObject);
begin
  NewNNTrainning();
end;

procedure TfrmmainJSON.miruntrainningClick(Sender: TObject);
var
   item : TNNTrainning;
   arquivo : Tstringlist;
   //trainfile : TStringList;
begin
  arquivo := TStringList.create();

  item := TNNTrainning(selecttreenode.Data);
  item.Pythonlog := @controlelog;


  if(item.RunTrainning()) then
  begin
    ShowMessage('File Make!');
  end;
  selecttreenode.Data := pointer(item);
end;

procedure TfrmmainJSON.mitrainningClick(Sender: TObject);
var

  item : TSQLEditItem;
begin
  item := nil;
  if (selecttreenode <> nil) then
  begin
       item := TSQLEditItem(selecttreenode.Data);
       TreinaRedeNN(item);
  end;
end;

procedure TfrmmainJSON.miCloseClick(Sender: TObject);
begin
  if(Fsetproject<>nil) then
  begin
     FechaProjeto();
  end
  else
  begin
    ShowMessage('Não existe projeto aberto');
  end;

end;

procedure TfrmmainJSON.miQueryClick(Sender: TObject);
begin
  NewQuery();
end;

procedure TfrmmainJSON.mnConfigClick(Sender: TObject);
begin
  frmConfig := TfrmConfig.create(self);
  frmConfig.showmodal();
  frmConfig.free();
end;

procedure TfrmmainJSON.mnNovoClick(Sender: TObject);
begin
  if(Fsetproject=nil) then
  begin
    CriaProjeto();
  end
  else
  begin
    ShowMessage('Projeto Já existe!');
  end;
end;

procedure TfrmmainJSON.mnsobreClick(Sender: TObject);
begin
  ChamaAbout();
end;

procedure TfrmmainJSON.nmOpenClick(Sender: TObject);
begin
  if(AbreProjeto()) then
  begin

       CarregaProjeto();
  end;
end;

procedure TfrmmainJSON.SairPrograma;
begin
  close;
end;

procedure TfrmmainJSON.ChamaAbout;
begin
  frmAbout := TfrmAbout.Create(self);
  frmAbout.lbVersao.Caption := versao;
  frmAbout.ShowModal;
  frmAbout.free;
  frmAbout := nil;
end;

procedure TfrmmainJSON.FechaProjeto;
begin

end;

procedure TfrmmainJSON.CriaProjeto;
begin
     frmNovo := TfrmNovo.create(Self);
     frmNovo.showmodal();
     if (frmNovo.flgsalvar ) then
     begin
          Fsetproject := Tsetproject.create();
          Fsetproject.NomeProjeto := frmNovo.edProjectName.text ;
          Fsetproject.Diretorio := frmNovo.DirectoryEdit1.Text;
          Fsetproject.DataBaseType:= TDatabaseType(frmNovo.cbDataBaseType.ItemIndex);
          Fsetproject.StringConnection:= frmNovo.edStringConnection.text;
          Fsetproject.Username:= frmNovo.edUsername.text;
          Fsetproject.Password:= frmNovo.edPassword.text;
          Fsetproject.HostName:= frmNovo.edHostname.text;
          Fsetproject.Database:= frmNovo.edDatabase.text;
          Fsetproject.SalvaContexto(false);
          //CarregaProjeto();
     end;
     frmNovo.Free;
     frmNovo := nil;
end;

procedure TfrmmainJSON.PopulaTV();
var
  i: Integer;

begin
  TreeView1.Items.Clear; // Limpa todos os itens existentes

  TreeView1.Items.BeginUpdate; // Inicia a atualização do TreeView
  try
      // Adiciona um novo item (nó) ao TreeView
      tvProjeto := TreeView1.Items.Add(nil, Fsetproject.NomeProjeto);
      tvProjeto.ImageIndex:= 0;
      tvProjeto.Data := pointer(ptProject);

  finally
    TreeView1.Items.EndUpdate; // Finaliza a atualização do TreeView
  end;
end;

procedure TfrmmainJSON.NewQuery;
begin
  if(frmSQLEditor= nil) then
  begin
    frmSQLEditor := TfrmSQLEditor.create(self);
    frmSQLEditor.showmodal;
    if (frmSQLEditor.flgsalvar) then
    begin
      IncluiQuery(frmSQLEditor.edNome.text, frmSQLEditor.SynEdit1.Lines.Text);
    end;
    frmSQLEditor.Free;
    frmSQLEditor := nil;

  end;
end;

procedure TfrmmainJSON.NewNNTrainning();
var
  fsqlitemtrainning : TSQLEditItem;
  fsqlitemtest : TSQLEditItem;
begin
  //Precisa implementar tela de trainamento
  if(frmnntrain= nil) then
  begin
    frmnntrain := Tfrmnntrain.create(self);
    frmnntrain.showmodal;
    if (frmnntrain.flgsalvar) then
    begin
      fsqlitemtrainning := Fsetproject.SQLEdit_Indexof(frmnntrain.cbquerytrainning.ItemIndex);
      fsqlitemtest := Fsetproject.SQLEdit_Indexof(frmnntrain.cbquerytest.ItemIndex);
      // RegistraNNTrainning(nome: string;comentario : string ; sql: string);
      //RegistraNNTrainning(
      IncluiNNTrainning(
         frmnntrain.edNome.text,
         frmnntrain.meComentario.Lines.Text,
         fsqlitemtrainning,
         fsqlitemtest,
         frmnntrain.cbtypenn.ItemIndex,
         frmnntrain.edGroupBy.Text,
         frmnntrain.edInputField.text,
         frmnntrain.edInputRef.text,
         frmnntrain.edInputRefField.text,
         frmnntrain.edInputRefKey.text,
         frmnntrain.edInputFieldTester.text,
         frmnntrain.edInputRefTester.text,        //Novo
         frmnntrain.edInputRefFieldTester.text,   //Novo
         frmnntrain.edInputRefKeyTester.text,     //Novo

         frmnntrain.edOutputField.text,
         frmnntrain.edOutputFieldTester.text, //Novo
         frmnntrain.synPython.Text,
         frmnntrain.synJSONTrainning.text,
         frmnntrain.edFilterValue.Text,
         frmnntrain.edFilterValueTester.Text,
         frmnntrain.fileJSONTester.Text,
         frmnntrain.synJSONTester.text
         );
    end;
    frmnntrain.free();
    frmnntrain := nil;

  end;

end;

procedure TfrmmainJSON.NewNNTrainning(sql: string);
begin
  //Precisa implementar tela de trainamento
  if(Tfrmnntrain= nil) then
  begin
    frmnntrain := Tfrmnntrain.create(self);
    //frmnntrain.mesql.Lines.text := sql;


    frmnntrain.showmodal;
    if (frmnntrain.flgsalvar) then
    begin
      //RegistraNNTrainning(
      IncluiNNTrainning(
         frmnntrain.edNome.text,
         frmnntrain.meComentario.Lines.Text,
         Fsetproject.SQLEdit_Indexof(frmnntrain.cbquerytrainning.ItemIndex),
         Fsetproject.SQLEdit_Indexof(frmnntrain.cbquerytest.ItemIndex),
         frmnntrain.cbtypenn.ItemIndex,
         frmnntrain.edGroupBy.Text,
         frmnntrain.edInputField.text,
         frmnntrain.edInputRef.text,
         frmnntrain.edInputRefField.text,
         frmnntrain.edInputRefKey.text,
         frmnntrain.edInputFieldTester.text,
         frmnntrain.edInputRefTester.text,        //Novo
         frmnntrain.edInputRefFieldTester.text,   //Novo
         frmnntrain.edInputRefKeyTester.text,     //Novo
         frmnntrain.edOutputField.text,
         frmnntrain.edOutputFieldTester.text,
         frmnntrain.synPython.Lines.text,
         frmnntrain.synJSONTrainning.text,
         frmnntrain.edFilterValue.text,
         frmnntrain.edFilterValueTester.text,
         frmnntrain.fileJSONTester.Text,
         frmnntrain.synJSONTester.Text
         );
    end;
    frmnntrain.free;
    frmnntrain := nil;

  end;


end;

procedure TfrmmainJSON.RegistraQuery(Nome: string; sql: string);
var
  item : TSQLEditItem;

begin
  item := TSQLEditItem.Create;
  item.Nome:= nome;
  item.SQL:= sql;
  tvItem := TreeView1.Items.AddChild(tvDatabase,Nome);
  tvItem.ImageIndex:= 2;
  tvItem.Data := pointer(item);

  //Fsetproject.addsql(Item);   //Adiciona o sql ao conjunto de sql
end;

procedure TfrmmainJSON.IncluiQuery(Nome: string; sql: string);
var
  item : TSQLEditItem;

begin
  item := TSQLEditItem.Create;
  item.Nome:= nome;
  item.SQL:= sql;
  tvItem := TreeView1.Items.AddChild(tvDatabase,Nome);
  tvItem.ImageIndex:= 2;
  tvItem.Data := pointer(item);

  Fsetproject.addsql(Item);   //Adiciona o sql ao conjunto de sql
end;


procedure TfrmmainJSON.RegistraNNTrainning(nome: string; comentario: string;
  sqlitemtrainning: TSQLEditItem; sqlitemtest: TSQLEditItem; cbtypenn: integer;
  edGroupBy: string; InputField: string; InputRef: string;
  InputRefField: string; InputRefKey: string;
  InputFieldTester: string; InputRefTester: string;
  InputRefFieldTester: string; InputRefKeyTester: string; OutputField: string;
  OutputFieldTester: string; Python: string; jsontrainning: string;
  FilterValue: string; FilterValueTester: string; fileJSONTester: string;
  LJSONTester: string);
var
  item : TNNTrainning;

begin
  item := TNNTrainning.Create;
  item.Nome:= nome;
  item.Commentario:= comentario;
  item.SQLTrainning:= sqlitemtrainning;
  item.SQLTest := sqlitemtest;
  item.ClassNNTrainning := TClasseNNTrainning(cbtypenn);
  item.GroupBy :=  edGroupBy;
  item.InputField :=  InputField;
  item.InputRef := InputRef;
  item.InputRefField := InputRefField;
  item.InputRefKey:= InputRefKey;

  item.InputFieldTester :=  InputFieldTester;
  item.InputRefTester := InputRefTester;             //Novo
  item.InputRefFieldTester := InputRefFieldTester;   //Novo
  item.InputRefKeyTester:= InputRefKeyTester;        //Novo


  item.OutputField:=  OutputField;
  item.OutputFieldTester:=  OutputFieldTester; //novo
  item.Python :=  Python;
  item.jsontrainning :=  jsontrainning;
  item.FilterValue:= FilterValue;
  item.FilterValueTester:= FilterValueTester;  //novo
  item.fileJSONTester :=  fileJSONTester;
  item.JSONTester:=  LJSONTester;

  //Adiciona no treeview
  tvItem := TreeView1.Items.AddChild(tvNNTrainning,Nome);
  tvItem.ImageIndex:= 8;
  tvItem.Data := pointer(item);
  //Fsetproject.addnntrainning(Item);   //Adiciona o sql ao conjunto de sql


end;

procedure TfrmmainJSON.IncluiNNTrainning(
  nome: string;
  comentario: string;
  sqlitemtrainning: TSQLEditItem;
  sqlitemtest: TSQLEditItem;
  cbtypenn: integer;
  edGroupBy: string;
  InputField: string;
  InputRef: string;
  InputRefField: string;
  InputRefKey: string;
  InputFieldTester: string;
  InputRefTester: string;
  InputRefFieldTester: string;
  InputRefKeyTester: string;
  OutputField: string;
  OutputFieldTester: string;
  Python: string;
  jsontrainning: string;
  FilterValue: string;
  FilterValueTester: string;
  fileJSONTester: string;
  LJSONTester: string
  );
var
  item : TNNTrainning;

begin
  item := TNNTrainning.Create;
  item.Nome:= nome;
  item.Commentario:= comentario;
  item.SQLTrainning:= sqlitemtrainning;
  item.SQLTest := sqlitemtest;
  item.ClassNNTrainning := TClasseNNTrainning(cbtypenn);
  item.GroupBy :=  edGroupBy;
  item.InputField :=  InputField;
  item.InputRef := InputRef;
  item.InputRefField := InputRefField;
  item.InputRefKey:= InputRefKey;

  item.InputFieldTester :=  InputFieldTester;        //Novo
  item.InputRefTester := InputRefTester;             //Novo
  item.InputRefFieldTester := InputRefFieldTester;   //Novo
  item.InputRefKeyTester:= InputRefKeyTester;        //Novo

  item.OutputField:=  OutputField;
  item.OutputFieldTester:=  OutputFieldTester;       //Novo
  item.Python :=  Python;
  item.jsontrainning :=  jsontrainning;
  item.FilterValue:= FilterValue;
  item.fileJSONTester :=  fileJSONTester;  //Novo
  item.JSONTester:=  LJSONTester;

  //Adiciona no treeview
  tvItem := TreeView1.Items.AddChild(tvNNTrainning,Nome);
  tvItem.ImageIndex:= 8;
  tvItem.Data := pointer(item);
  Fsetproject.addnntrainning(Item);   //Adiciona o sql ao conjunto de sql

end;

procedure TfrmmainJSON.CarregaQuerys();
var
  a : integer;
  nome : string;
  sql : string;
  fitem : TSQLEditItem;

begin

  for a := 0 to Fsetproject.Querycount-1 do
  begin
       fitem := Fsetproject.SQLEdit_Indexof(a);
       if( fitem<>nil) then
       begin
            nome := fitem.Nome;
            sql := fitem.SQL;
            RegistraQuery(Nome, sql);
       end;
  end;
end;

procedure TfrmmainJSON.CarregaNNTrainning;
var
  a : integer;
  nome : string;
  comentario: string;
  sql : string;
  fitem : TNNTrainning;

begin

  for a := 0 to Fsetproject.NNcount-1 do
  begin
       fitem := Fsetproject.NNTrainning_Indexof(a);
       if( fitem<>nil) then
       begin
            nome := fitem.Nome;
            comentario := fitem.Commentario;

            RegistraNNTrainning(
               nome,
               comentario,
               fitem.SQLTrainning,
               fitem.SQLTest,
               integer(fitem.ClassNNTrainning),
               fitem.GroupBy,
               fitem.InputField,
               fitem.InputRef,
               fitem.InputRefField,
               fitem.InputRefKey,
               fitem.InputFieldTester,      //NOVO
               fitem.InputRefTester,        //NOVO
               fitem.InputRefFieldTester,   //NOVO
               fitem.InputRefKeyTester,     //NOVO
               fitem.OutputField,
               fitem.OutputFieldTester,    //NOVO
               fitem.Python,
               fitem.jsontrainning,
               fitem.FilterValue,
               fitem.FilterValueTester,   //NOVO
               fitem.fileJSONTester,
               fitem.JSONTester
               );

       end;
  end;


end;

procedure TfrmmainJSON.CarregaProjeto;
begin
  if ( Fsetproject <> nil) then
  begin
    pnPrincipal.Visible:= true;
    PopulaTV();
    PopulaPropertys(StringGrid1, Fsetproject);
    CarregaDatabase();
    CarregaNN();
    CarregaQuerys();
    CarregaNNTrainning();

  end
  else
  begin
    pnPrincipal.Visible:= false;
  end;
end;

procedure TfrmmainJSON.CarregaDatabase();
var
  filename : string;
begin
  if (dmBase =nil) then
  begin
    try
       if(Fsetproject.DataBaseType=dbMysql) then
       begin
         dmBase := TdmBase.Create(self);
         filename := FSetImg.DLLPath+'\libs\mysql\win64\lib64\libmysql.dll';
         if (not FileExists(filename)) then
         begin
            filename := ExtractFileDir(ApplicationName)+'\libs\mysql\win64\lib64\libmysql.dll';
            if(not FileExists(filename)) then
            begin
              ShowMessage('Inclua a pasta libs no diretorio do seu projeto!');
              Application.Terminate;
            end;
         end;
         if FileExists(filename) then
         begin
             dmBase.loadlib(filename);
             dmBase.Connect( Fsetproject.Username, Fsetproject.Password, Fsetproject.hostname, Fsetproject.Database);
             //Cria grupo de sql
             tvDatabase := TreeView1.Items.Add(nil, fsetproject.database);
             tvDatabase.ImageIndex:= 1;
             tvDatabase.Data := pointer(ptDatabase);
             (*Só cria grupo de neural network com sql montado*)

             //Cria grupo de rede
             tvNNTrainning := TreeView1.Items.Add(nil, 'Neural Network');
             tvNNTrainning.ImageIndex:= 8;
             tvNNTrainning.Data := pointer(ptNNGroupNN);

         end
         else
         begin
           ShowMessage('Arquivo não existe');
         end;
       end;
    except
       showmessage('Falha na conexao!');
    end;
  end;
end;

procedure TfrmmainJSON.CarregaNN();
var
  filename : string;
begin
  if (dmBase =nil) then
  begin
    try
       tvNNTrainning := TreeView1.Items.Add(nil, 'Neural Network');
       tvNNTrainning.ImageIndex:= 8;
       tvNNTrainning.Data := pointer(ptNNGroupNN);
    except
       showmessage('Falha na conexao!');
    end;
  end;
end;

function TfrmmainJSON.AbreProjeto: boolean;
begin

  if(Fsetproject = nil) then
  begin
    if (OpenDialog1.Execute) then
    begin
      Fsetproject := Tsetproject.create();
      Fsetproject.Diretorio := ExtractFileDir(OpenDialog1.FileName);
      Fsetproject.Filename:= ExtractFileName(OpenDialog1.FileName);
      Fsetproject.CarregaContexto();
      result := true;
    end;
  end
   else
   begin
     ShowMessage('Projeto já foi aberto');
     result := false;
   end;

end;


//Abre  o projeto perguntando o parametro de teste do treinamento
function TfrmmainJSON.AbreProjetofield: boolean;
var
  nome : string;
  filename : string;
begin
  if(Fsetproject = nil) then
  begin
    nome := InputBox('Qual a marca','Marca:','' );
    if (nome <> '') then
    begin
      showmessage('Marca vazia');
      result := false;
    end;
    filename := ExtractFileDir(ApplicationName)+'\'+nome+'\'+nome+'.json';
    if(FileExists(filename)) then
    begin
      Fsetproject := Tsetproject.create();
      Fsetproject.Diretorio := ExtractFileDir(ApplicationName)+'\'+name;
      Fsetproject.Filename:= nome+'.json';
      Fsetproject.CarregaContexto();
      result := true;
    end
    else
    begin
         showmessage('Projeto JSON não foi encontrado');
    end;
  end
   else
   begin
     ShowMessage('Projeto já foi aberto');
     result := false;
   end;

end;

procedure TfrmmainJSON.Splitter1Moved(Sender: TObject);
begin

end;

procedure TfrmmainJSON.StringGrid1EditingDone(Sender: TObject);
begin

end;

procedure TfrmmainJSON.StringGrid1Exit(Sender: TObject);
begin

end;

procedure TfrmmainJSON.StringGrid1GetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
  showmessage(StringGrid1.Cells[acol,arow]);
end;

procedure TfrmmainJSON.TreeView1Changing(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  selecttreenode := node;
  TreeView1.PopupMenu:= nil;
  if(node=tvProjeto) then
  begin
    TreeView1.PopupMenu := pmProject;
  end;
  if(node=tvDatabase) then
  begin
      TreeView1.PopupMenu := pmDatabase;
  end;
  if(node=tvNNTrainning) then
  begin
      TreeView1.PopupMenu := pmNNGroup;
  end;
  if(node.Parent= tvDatabase) then
  begin
    TreeView1.PopupMenu := pmSQLEditItem;
  end;
  if(node.Parent= tvNNTrainning) then
  begin
    TreeView1.PopupMenu := pmNNTrainning;
  end;



end;

procedure TfrmmainJSON.TreeView1Click(Sender: TObject);
begin

end;

procedure TfrmmainJSON.TreinaRedeNN(item: TSQLEditItem);
begin
     NewNNTrainning();
end;

procedure TfrmmainJSON.controlelog(Sender: TObject; const OutputLine: String);
begin
  frmnntrain.pnlog.Visible:=true;
  frmnntrain.melog.Append(outputline);
end;



end.

