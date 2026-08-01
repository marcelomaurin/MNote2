unit jsonmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  About, setimg, config, EditBtn, ExtCtrls, ComCtrls, Grids,
  setproject, Novo, funcoes, sqleditor, sqlEditItem, NNTrainning,
  frmnntrainning, PythonEngine, mnote_version;

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
    mnNovo: TMenuItem;
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
    tvProjeto : TTreeNode;
    tvDatabase : TTreeNode;
    tvNNTrainning : TTreeNode;
    tvItem : TTreeNode;

    selecttreenode : TTreeNode;

    procedure controlelog(Sender: TObject; const OutputLine: UTF8String);
    procedure PopulaTV();
    procedure NewQuery();
    procedure NewNNTrainning();
    procedure NewNNTrainning(sql : string);
    procedure RegistraQuery(Nome : string; sql : string);
    procedure IncluiQuery(Nome: string; sql: string);

    procedure RegistraNNTrainning(nome: string; comentario : string;
      sqlitemtrainning: TSQLEditItem;
      sqlitemtest: TSQLEditItem;
      cbtypenn : integer;
      edGroupBy : string;
      InputField : string;
      InputRef: string;
      InputRefField: string;
      InputRefKey: string;
      InputFieldTester : string;
      InputRefTester: string;
      InputRefFieldTester: string;
      InputRefKeyTester: string;
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

    procedure LimpaTreeRefs;
    procedure GaranteNosRaiz;
    procedure LimpaGridPropriedades;
    procedure AtualizaGridPorSelecao;
    function NodeIsQuery(ANode: TTreeNode): Boolean;
    function NodeIsNN(ANode: TTreeNode): Boolean;
  public
  end;

var
  frmmainJSON: TfrmmainJSON;

implementation

uses
  main;

{$R *.lfm}

{ TfrmmainJSON }

procedure TfrmmainJSON.mnSairClick(Sender: TObject);
begin
  SairPrograma();
end;

procedure TfrmmainJSON.mnSalvarClick(Sender: TObject);
begin
  if Assigned(Fsetproject) then
    Fsetproject.SalvaContexto(False);
end;

procedure TfrmmainJSON.FormCreate(Sender: TObject);
begin
  selecttreenode := nil;
  tvProjeto := nil;
  tvDatabase := nil;
  tvNNTrainning := nil;
  tvItem := nil;

  pnPrincipal.Visible := False;
  LimpaGridPropriedades;

  FSetImg := TSetImg.Create();
  FSetImg.CarregaContexto();

  OpenDialog1.Filter := 'Projeto JSON|*.json|Todos os arquivos|*.*';
end;

procedure TfrmmainJSON.EditClick(Sender: TObject);
var
  item : TSQLEditItem;
begin
  if not NodeIsQuery(selecttreenode) then
  begin
    ShowMessage('Selecione uma query.');
    Exit;
  end;

  item := TSQLEditItem(selecttreenode.Data);
  if not Assigned(item) then
  begin
    ShowMessage('Item inválido.');
    Exit;
  end;

  frmSQLEditor := TfrmSQLEditor.Create(Self);
  try
    frmSQLEditor.edNome.Text := item.Nome;
    frmSQLEditor.SynEdit1.Text := item.SQL;
    frmSQLEditor.ShowModal;

    if frmSQLEditor.flgsalvar then
    begin
      item.Nome := frmSQLEditor.edNome.Text;
      item.SQL := frmSQLEditor.SynEdit1.Text;
      selecttreenode.Text := item.Nome;
      selecttreenode.Data := Pointer(item);
      AtualizaGridPorSelecao;
      if Assigned(Fsetproject) then
        Fsetproject.SalvaContexto(False);
    end;
  finally
    FreeAndNil(frmSQLEditor);
  end;
end;

procedure TfrmmainJSON.DeleteItemClick(Sender: TObject);
var
  Removed: Boolean;
  ItemObject: TObject;
begin
  if not Assigned(selecttreenode) then
  begin
    ShowMessage('Selecione um item para excluir.');
    Exit;
  end;

  if (selecttreenode = tvProjeto) or (selecttreenode = tvDatabase) or
     (selecttreenode = tvNNTrainning) then
  begin
    ShowMessage('Selecione um item filho para excluir.');
    Exit;
  end;

  if not ShowConfirm('Confirma excluir o item "' + selecttreenode.Text + '" ?') then
    Exit;

  if not Assigned(Fsetproject) then
  begin
    ShowMessage('Projeto não carregado.');
    Exit;
  end;

  ItemObject := TObject(selecttreenode.Data);
  Removed := False;
  if NodeIsQuery(selecttreenode) then
    Removed := Fsetproject.removesql(TSQLEditItem(ItemObject))
  else if NodeIsNN(selecttreenode) then
    Removed := Fsetproject.removenntrainning(TNNTrainning(ItemObject));

  if not Removed then
  begin
    ShowMessage('O item não foi excluído. Uma query usada por treinamento deve ser desvinculada primeiro.');
    Exit;
  end;

  selecttreenode.Data := nil;
  selecttreenode.Delete;
  selecttreenode := nil;
  LimpaGridPropriedades;

  if Assigned(Fsetproject) then
    Fsetproject.SalvaContexto(False);
end;

procedure TfrmmainJSON.Edit1Click(Sender: TObject);
var
  item : TNNTrainning;
begin
  if not NodeIsNN(selecttreenode) then
  begin
    ShowMessage('Selecione um treinamento.');
    Exit;
  end;

  item := TNNTrainning(selecttreenode.Data);
  if not Assigned(item) then
  begin
    ShowMessage('Treinamento inválido.');
    Exit;
  end;

  frmnntrain := Tfrmnntrain.Create(Self);
  try
    frmnntrain.Load(item);
    frmnntrain.ShowModal;
    item := frmnntrain.Save();

    if Assigned(item) then
    begin
      selecttreenode.Data := Pointer(item);
      selecttreenode.Text := item.Nome;
      AtualizaGridPorSelecao;
      if Assigned(Fsetproject) then
        Fsetproject.SalvaContexto(False);
    end;
  finally
    FreeAndNil(frmnntrain);
  end;
end;

procedure TfrmmainJSON.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetImg) then
  begin
    FSetImg.SalvaContexto(True);
    FreeAndNil(FSetImg);
  end;

  FreeAndNil(Fsetproject);
end;

procedure TfrmmainJSON.MenuItem4Click(Sender: TObject);
begin
  if Assigned(Fsetproject) then
    Fsetproject.SalvaContexto(False);
end;

procedure TfrmmainJSON.miMakeTesteClick(Sender: TObject);
var
  item : TNNTrainning;
  marca : string;
begin
  if not NodeIsNN(selecttreenode) then
  begin
    ShowMessage('Selecione um treinamento.');
    Exit;
  end;

  item := TNNTrainning(selecttreenode.Data);
  if not Assigned(item) then
  begin
    ShowMessage('Treinamento inválido.');
    Exit;
  end;

  marca := Trim(item.FilterConditionTester);
  if marca = '' then
    marca := Trim(item.FilterCondition);
  if marca = '' then
    marca := 'default';

  if item.testerJSON(marca) then
    ShowMessage('Arquivo de teste gerado com sucesso!');

  selecttreenode.Data := Pointer(item);
  AtualizaGridPorSelecao;
end;

procedure TfrmmainJSON.miMakeTrainningClick(Sender: TObject);
var
  item : TNNTrainning;
begin
  if not NodeIsNN(selecttreenode) then
  begin
    ShowMessage('Selecione um treinamento.');
    Exit;
  end;

  item := TNNTrainning(selecttreenode.Data);
  if not Assigned(item) then
  begin
    ShowMessage('Treinamento inválido.');
    Exit;
  end;

  if item.trainnerJSON() then
    ShowMessage('Arquivo de treinamento gerado com sucesso!');

  selecttreenode.Data := Pointer(item);
  AtualizaGridPorSelecao;
end;

procedure TfrmmainJSON.miNewItemClick(Sender: TObject);
begin
  NewNNTrainning();
end;

procedure TfrmmainJSON.miruntrainningClick(Sender: TObject);
var
  item : TNNTrainning;
begin
  if not NodeIsNN(selecttreenode) then
  begin
    ShowMessage('Selecione um treinamento.');
    Exit;
  end;

  item := TNNTrainning(selecttreenode.Data);
  if not Assigned(item) then
  begin
    ShowMessage('Treinamento inválido.');
    Exit;
  end;

  item.Pythonlog := @controlelog;

  if item.RunTrainning() then
    ShowMessage('Treinamento executado com sucesso!');

  selecttreenode.Data := Pointer(item);
  AtualizaGridPorSelecao;
end;

procedure TfrmmainJSON.mitrainningClick(Sender: TObject);
var
  item : TSQLEditItem;
begin
  item := nil;
  if NodeIsQuery(selecttreenode) then
  begin
    item := TSQLEditItem(selecttreenode.Data);
    TreinaRedeNN(item);
  end
  else
    ShowMessage('Selecione uma query para criar um treinamento.');
end;

procedure TfrmmainJSON.miCloseClick(Sender: TObject);
begin
  if Assigned(Fsetproject) then
    FechaProjeto()
  else
    ShowMessage('Não existe projeto aberto');
end;

procedure TfrmmainJSON.miQueryClick(Sender: TObject);
begin
  NewQuery();
end;

procedure TfrmmainJSON.mnConfigClick(Sender: TObject);
begin
  frmConfig := TfrmConfig.Create(Self);
  try
    frmConfig.ShowModal();
  finally
    FreeAndNil(frmConfig);
  end;
end;

procedure TfrmmainJSON.mnNovoClick(Sender: TObject);
begin
  if not Assigned(Fsetproject) then
    CriaProjeto()
  else
    ShowMessage('Projeto já existe!');
end;

procedure TfrmmainJSON.mnsobreClick(Sender: TObject);
begin
  ChamaAbout();
end;

procedure TfrmmainJSON.nmOpenClick(Sender: TObject);
begin
  if AbreProjeto() then
    CarregaProjeto();
end;

procedure TfrmmainJSON.SairPrograma;
begin
  Close;
end;

procedure TfrmmainJSON.ChamaAbout;
begin
  frmAbout := TfrmAbout.Create(Self);
  try
    frmAbout.lbVersao.Caption := MNOTE_APP_VERSION;
    frmAbout.ShowModal;
  finally
    FreeAndNil(frmAbout);
  end;
end;

procedure TfrmmainJSON.LimpaTreeRefs;
begin
  tvProjeto := nil;
  tvDatabase := nil;
  tvNNTrainning := nil;
  tvItem := nil;
  selecttreenode := nil;
end;

procedure TfrmmainJSON.LimpaGridPropriedades;
begin
  StringGrid1.RowCount := 1;
  StringGrid1.ColCount := 2;
  StringGrid1.Cells[0,0] := '';
  StringGrid1.Cells[1,0] := '';
end;

procedure TfrmmainJSON.FechaProjeto;
begin
  if Assigned(Fsetproject) then
    Fsetproject.SalvaContexto(False);

  TreeView1.Items.Clear;
  LimpaGridPropriedades;
  pnPrincipal.Visible := False;
  LimpaTreeRefs;

  FreeAndNil(Fsetproject);
end;

procedure TfrmmainJSON.CriaProjeto;
begin
  frmNovo := TfrmNovo.Create(Self);
  try
    frmNovo.ShowModal();
    if frmNovo.flgsalvar then
    begin
      Fsetproject := Tsetproject.Create();
      Fsetproject.NomeProjeto := frmNovo.edProjectName.Text;
      Fsetproject.Diretorio := frmNovo.DirectoryEdit1.Text;
      Fsetproject.DataBaseType := TDatabaseType(frmNovo.cbDataBaseType.ItemIndex);
      Fsetproject.StringConnection := frmNovo.edStringConnection.Text;
      Fsetproject.Username := frmNovo.edUsername.Text;
      Fsetproject.Password := frmNovo.edPassword.Text;
      Fsetproject.HostName := frmNovo.edHostname.Text;
      Fsetproject.Database := frmNovo.edDatabase.Text;
      Fsetproject.SalvaContexto(False);
      CarregaProjeto();
    end;
  finally
    FreeAndNil(frmNovo);
  end;
end;

procedure TfrmmainJSON.GaranteNosRaiz;
begin
  if not Assigned(Fsetproject) then Exit;

  if not Assigned(tvProjeto) then
  begin
    tvProjeto := TreeView1.Items.Add(nil, Fsetproject.NomeProjeto);
    tvProjeto.ImageIndex := 0;
    tvProjeto.Data := Pointer(ptProject);
  end;

  if not Assigned(tvDatabase) then
  begin
    tvDatabase := TreeView1.Items.AddChild(tvProjeto, 'Database');
    tvDatabase.ImageIndex := 1;
    tvDatabase.Data := Pointer(ptDatabase);
  end;

  if not Assigned(tvNNTrainning) then
  begin
    tvNNTrainning := TreeView1.Items.AddChild(tvProjeto, 'Neural Network');
    tvNNTrainning.ImageIndex := 8;
    tvNNTrainning.Data := Pointer(ptNNGroupNN);
  end;
end;

procedure TfrmmainJSON.PopulaTV;
begin
  TreeView1.Items.Clear;

  TreeView1.Items.BeginUpdate;
  try
    LimpaTreeRefs;
    GaranteNosRaiz;
    if Assigned(tvProjeto) then
      tvProjeto.Expand(True);
  finally
    TreeView1.Items.EndUpdate;
  end;
end;

procedure TfrmmainJSON.NewQuery;
begin
  if not Assigned(Fsetproject) then
  begin
    ShowMessage('Abra ou crie um projeto antes.');
    Exit;
  end;

  frmSQLEditor := TfrmSQLEditor.Create(Self);
  try
    frmSQLEditor.ShowModal;
    if frmSQLEditor.flgsalvar then
      IncluiQuery(frmSQLEditor.edNome.Text, frmSQLEditor.SynEdit1.Lines.Text);
  finally
    FreeAndNil(frmSQLEditor);
  end;
end;

procedure TfrmmainJSON.NewNNTrainning;
var
  fsqlitemtrainning : TSQLEditItem;
  fsqlitemtest : TSQLEditItem;
begin
  if not Assigned(Fsetproject) then
  begin
    ShowMessage('Abra ou crie um projeto antes.');
    Exit;
  end;

  frmnntrain := Tfrmnntrain.Create(Self);
  try
    frmnntrain.ShowModal;
    if frmnntrain.flgsalvar then
    begin
      fsqlitemtrainning := Fsetproject.SQLEdit_Indexof(frmnntrain.cbquerytrainning.ItemIndex);
      fsqlitemtest := Fsetproject.SQLEdit_Indexof(frmnntrain.cbquerytest.ItemIndex);

      IncluiNNTrainning(
        frmnntrain.edNome.Text,
        frmnntrain.meComentario.Lines.Text,
        fsqlitemtrainning,
        fsqlitemtest,
        frmnntrain.cbtypenn.ItemIndex,
        frmnntrain.edGroupBy.Text,
        frmnntrain.edInputField.Text,
        frmnntrain.edInputRef.Text,
        frmnntrain.edInputRefField.Text,
        frmnntrain.edInputRefKey.Text,
        frmnntrain.edInputFieldTester.Text,
        frmnntrain.edInputRefTester.Text,
        frmnntrain.edInputRefFieldTester.Text,
        frmnntrain.edInputRefKeyTester.Text,
        frmnntrain.edOutputField.Text,
        frmnntrain.edOutputFieldTester.Text,
        frmnntrain.synPython.Text,
        frmnntrain.synJSONTrainning.Text,
        frmnntrain.edFilterValue.Text,
        frmnntrain.edFilterValueTester.Text,
        frmnntrain.fileJSONTester.Text,
        frmnntrain.synJSONTester.Text
      );
    end;
  finally
    FreeAndNil(frmnntrain);
  end;
end;

procedure TfrmmainJSON.NewNNTrainning(sql: string);
begin
  // mantido por compatibilidade
  // se quiser depois dá para pré-carregar a SQL na tela
  NewNNTrainning();
end;

procedure TfrmmainJSON.RegistraQuery(Nome: string; sql: string);
var
  item : TSQLEditItem;
begin
  GaranteNosRaiz;

  item := TSQLEditItem.Create;
  item.Nome := Nome;
  item.SQL := sql;

  tvItem := TreeView1.Items.AddChild(tvDatabase, Nome);
  tvItem.ImageIndex := 2;
  tvItem.Data := Pointer(item);
end;

procedure TfrmmainJSON.IncluiQuery(Nome: string; sql: string);
var
  item : TSQLEditItem;
begin
  if not Assigned(Fsetproject) then Exit;

  GaranteNosRaiz;

  item := TSQLEditItem.Create;
  item.Nome := Nome;
  item.SQL := sql;

  tvItem := TreeView1.Items.AddChild(tvDatabase, Nome);
  tvItem.ImageIndex := 2;
  tvItem.Data := Pointer(item);

  Fsetproject.addsql(item);
  Fsetproject.SalvaContexto(False);
end;

procedure TfrmmainJSON.RegistraNNTrainning(nome: string; comentario: string;
  sqlitemtrainning: TSQLEditItem; sqlitemtest: TSQLEditItem; cbtypenn: integer;
  edGroupBy: string; InputField: string; InputRef: string;
  InputRefField: string; InputRefKey: string; InputFieldTester: string;
  InputRefTester: string; InputRefFieldTester: string;
  InputRefKeyTester: string; OutputField: string; OutputFieldTester: string;
  Python: string; jsontrainning: string; FilterValue: string;
  FilterValueTester: string; fileJSONTester: string; LJSONTester: string);
var
  item : TNNTrainning;
begin
  GaranteNosRaiz;

  item := TNNTrainning.Create;
  item.Nome := nome;
  item.Commentario := comentario;
  item.SQLTrainning := sqlitemtrainning;
  item.SQLTest := sqlitemtest;
  item.ClassNNTrainning := TClasseNNTrainning(cbtypenn);
  item.GroupBy := edGroupBy;
  item.InputField := InputField;
  item.InputRef := InputRef;
  item.InputRefField := InputRefField;
  item.InputRefKey := InputRefKey;
  item.InputFieldTester := InputFieldTester;
  item.InputRefTester := InputRefTester;
  item.InputRefFieldTester := InputRefFieldTester;
  item.InputRefKeyTester := InputRefKeyTester;
  item.OutputField := OutputField;
  item.OutputFieldTester := OutputFieldTester;
  item.Python := Python;
  item.jsontrainning := jsontrainning;
  item.FilterValue := FilterValue;
  item.FilterValueTester := FilterValueTester;
  item.fileJSONTester := fileJSONTester;
  item.JSONTester := LJSONTester;

  tvItem := TreeView1.Items.AddChild(tvNNTrainning, nome);
  tvItem.ImageIndex := 8;
  tvItem.Data := Pointer(item);
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
  if not Assigned(Fsetproject) then Exit;

  GaranteNosRaiz;

  item := TNNTrainning.Create;
  item.Nome := nome;
  item.Commentario := comentario;
  item.SQLTrainning := sqlitemtrainning;
  item.SQLTest := sqlitemtest;
  item.ClassNNTrainning := TClasseNNTrainning(cbtypenn);
  item.GroupBy := edGroupBy;
  item.InputField := InputField;
  item.InputRef := InputRef;
  item.InputRefField := InputRefField;
  item.InputRefKey := InputRefKey;
  item.InputFieldTester := InputFieldTester;
  item.InputRefTester := InputRefTester;
  item.InputRefFieldTester := InputRefFieldTester;
  item.InputRefKeyTester := InputRefKeyTester;
  item.OutputField := OutputField;
  item.OutputFieldTester := OutputFieldTester;
  item.Python := Python;
  item.jsontrainning := jsontrainning;
  item.FilterValue := FilterValue;
  item.FilterValueTester := FilterValueTester;
  item.fileJSONTester := fileJSONTester;
  item.JSONTester := LJSONTester;

  tvItem := TreeView1.Items.AddChild(tvNNTrainning, nome);
  tvItem.ImageIndex := 8;
  tvItem.Data := Pointer(item);

  Fsetproject.addnntrainning(item);
  Fsetproject.SalvaContexto(False);
end;

procedure TfrmmainJSON.CarregaQuerys;
var
  a : integer;
  nome : string;
  sql : string;
  fitem : TSQLEditItem;
begin
  if not Assigned(Fsetproject) then Exit;

  for a := 0 to Fsetproject.Querycount - 1 do
  begin
    fitem := Fsetproject.SQLEdit_Indexof(a);
    if Assigned(fitem) then
    begin
      nome := fitem.Nome;
      sql := fitem.SQL;
      RegistraQuery(nome, sql);
    end;
  end;
end;

procedure TfrmmainJSON.CarregaNNTrainning;
var
  a : integer;
  nome : string;
  comentario: string;
  fitem : TNNTrainning;
begin
  if not Assigned(Fsetproject) then Exit;

  for a := 0 to Fsetproject.NNcount - 1 do
  begin
    fitem := Fsetproject.NNTrainning_Indexof(a);
    if Assigned(fitem) then
    begin
      nome := fitem.Nome;
      comentario := fitem.Commentario;

      RegistraNNTrainning(
        nome,
        comentario,
        fitem.SQLTrainning,
        fitem.SQLTest,
        Integer(fitem.ClassNNTrainning),
        fitem.GroupBy,
        fitem.InputField,
        fitem.InputRef,
        fitem.InputRefField,
        fitem.InputRefKey,
        fitem.InputFieldTester,
        fitem.InputRefTester,
        fitem.InputRefFieldTester,
        fitem.InputRefKeyTester,
        fitem.OutputField,
        fitem.OutputFieldTester,
        fitem.Python,
        fitem.jsontrainning,
        fitem.FilterValue,
        fitem.FilterValueTester,
        fitem.fileJSONTester,
        fitem.JSONTester
      );
    end;
  end;
end;

procedure TfrmmainJSON.CarregaProjeto;
begin
  if Assigned(Fsetproject) then
  begin
    pnPrincipal.Visible := True;
    PopulaTV();
    PopulaPropertys(StringGrid1, Fsetproject);
    CarregaDatabase();
    CarregaNN();
    CarregaQuerys();
    CarregaNNTrainning();
    AtualizaGridPorSelecao;
  end
  else
    pnPrincipal.Visible := False;
end;

procedure TfrmmainJSON.CarregaDatabase;
begin
  GaranteNosRaiz;
end;

procedure TfrmmainJSON.CarregaNN;
begin
  GaranteNosRaiz;
end;

function TfrmmainJSON.AbreProjeto: boolean;
begin
  Result := False;

  if not Assigned(Fsetproject) then
  begin
    if OpenDialog1.Execute then
    begin
      Fsetproject := Tsetproject.Create();
      Fsetproject.Diretorio := ExtractFileDir(OpenDialog1.FileName);
      Fsetproject.Filename := ExtractFileName(OpenDialog1.FileName);
      Fsetproject.CarregaContexto();
      Result := True;
    end;
  end
  else
  begin
    ShowMessage('Projeto já foi aberto');
    Result := False;
  end;
end;

function TfrmmainJSON.AbreProjetofield: boolean;
var
  nome : string;
  filename : string;
begin
  Result := False;

  if not Assigned(Fsetproject) then
  begin
    nome := Trim(InputBox('Qual a marca', 'Marca:', ''));

    if nome = '' then
    begin
      ShowMessage('Marca vazia');
      Exit(False);
    end;

    filename := IncludeTrailingPathDelimiter(ExtractFileDir(ApplicationName)) +
                nome + PathDelim + nome + '.json';

    if FileExists(filename) then
    begin
      Fsetproject := Tsetproject.Create();
      Fsetproject.Diretorio := IncludeTrailingPathDelimiter(ExtractFileDir(ApplicationName)) + nome;
      Fsetproject.Filename := nome + '.json';
      Fsetproject.CarregaContexto();
      Result := True;
    end
    else
      ShowMessage('Projeto JSON não foi encontrado');
  end
  else
  begin
    ShowMessage('Projeto já foi aberto');
    Result := False;
  end;
end;

procedure TfrmmainJSON.Splitter1Moved(Sender: TObject);
begin
end;

procedure TfrmmainJSON.StringGrid1EditingDone(Sender: TObject);
begin
  // ponto reservado para gravação reversa caso exista helper no projeto
end;

procedure TfrmmainJSON.StringGrid1Exit(Sender: TObject);
begin
  // ponto reservado para gravação reversa caso exista helper no projeto
end;

procedure TfrmmainJSON.StringGrid1GetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: string);
begin
  // removido ShowMessage de debug
end;

procedure TfrmmainJSON.TreeView1Changing(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  if Node = nil then Exit;

  selecttreenode := Node;
  TreeView1.PopupMenu := nil;

  if Node = tvProjeto then
    TreeView1.PopupMenu := pmProject
  else
  if Node = tvDatabase then
    TreeView1.PopupMenu := pmDatabase
  else
  if Node = tvNNTrainning then
    TreeView1.PopupMenu := pmNNGroup
  else
  if Assigned(Node.Parent) and (Node.Parent = tvDatabase) then
    TreeView1.PopupMenu := pmSQLEditItem
  else
  if Assigned(Node.Parent) and (Node.Parent = tvNNTrainning) then
    TreeView1.PopupMenu := pmNNTrainning;
end;

procedure TfrmmainJSON.TreeView1Click(Sender: TObject);
begin
  AtualizaGridPorSelecao;
end;

procedure TfrmmainJSON.TreinaRedeNN(item: TSQLEditItem);
begin
  NewNNTrainning();
end;

procedure TfrmmainJSON.controlelog(Sender: TObject; const OutputLine: UTF8String);
begin
  if Assigned(frmnntrain) then
  begin
    frmnntrain.pnlog.Visible := True;
    frmnntrain.melog.Append(OutputLine);
  end;
end;

function TfrmmainJSON.NodeIsQuery(ANode: TTreeNode): Boolean;
begin
  Result := Assigned(ANode) and Assigned(ANode.Parent) and (ANode.Parent = tvDatabase);
end;

function TfrmmainJSON.NodeIsNN(ANode: TTreeNode): Boolean;
begin
  Result := Assigned(ANode) and Assigned(ANode.Parent) and (ANode.Parent = tvNNTrainning);
end;

procedure TfrmmainJSON.AtualizaGridPorSelecao;
begin
  if not Assigned(selecttreenode) then
  begin
    LimpaGridPropriedades;
    Exit;
  end;

  if selecttreenode = tvProjeto then
  begin
    if Assigned(Fsetproject) then
      PopulaPropertys(StringGrid1, Fsetproject)
    else
      LimpaGridPropriedades;
    Exit;
  end;

  if NodeIsQuery(selecttreenode) and Assigned(selecttreenode.Data) then
  begin
    PopulaPropertys(StringGrid1, TObject(selecttreenode.Data));
    Exit;
  end;

  if NodeIsNN(selecttreenode) and Assigned(selecttreenode.Data) then
  begin
    PopulaPropertys(StringGrid1, TObject(selecttreenode.Data));
    Exit;
  end;

  LimpaGridPropriedades;
end;

end.
