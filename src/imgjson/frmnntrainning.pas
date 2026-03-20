unit frmnntrainning;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ValEdit, PairSplitter, DBGrids, EditBtn, ExtCtrls, Menus, SynEdit, setproject,
  SynHighlighterPython, SynCompletion, SynHighlighterSQL, myexamplecontrol,
  SQLEditItem, NNTrainning;

type

  { Tfrmnntrain }

  Tfrmnntrain = class(TForm)
    btCancel: TButton;
    btSave: TButton;
    cbquerytest: TComboBox;
    cbtypenn: TComboBox;
    cbquerytrainning: TComboBox;
    edFilterValue: TEdit;
    edFilterValueTester: TEdit;
    edGroupBy: TEdit;
    edGroupByTester: TEdit;
    edInputCols: TEdit;
    edInputField: TEdit;
    edInputFieldTester: TEdit;
    edInputRef: TEdit;
    edInputRefTester: TEdit;
    edInputRefField: TEdit;
    edInputRefFieldTester: TEdit;
    edInputRefKey: TEdit;
    edInputRefKeyTester: TEdit;
    edNome: TEdit;
    edOutputCols: TEdit;
    edOutputField: TEdit;
    edOutputFieldTester: TEdit;
    fileJSONTester: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    melog: TMemo;
    mesqltrainning: TSynEdit;
    miReload: TMenuItem;
    Panel3: TPanel;
    pnBotton: TPanel;
    pnlog: TPanel;
    pmPython: TPopupMenu;
    Splitter1: TSplitter;
    synJSONTester: TSynEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label8: TLabel;
    meComentario: TMemo;
    mesqltest: TSynEdit;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    SynAutoComplete1: TSynAutoComplete;
    synJSONTrainning: TSynEdit;
    synJSONTrainning1: TSynEdit;
    synPython: TSynEdit;
    SynPythonSyn1: TSynPythonSyn;
    SynSQLSyn1: TSynSQLSyn;
    TabSheet1: TTabSheet;
    tsDataTest: TTabSheet;
    tsTrainning: TTabSheet;
    tsRunTest: TTabSheet;
    tsPython: TTabSheet;
    tsOutput: TTabSheet;
    tsInput: TTabSheet;
    tbGroup: TTabSheet;
    tsdados: TTabSheet;
    TabSheet3: TTabSheet;
    procedure btRUNClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure btTrainningClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbquerytestChange(Sender: TObject);
    procedure cbquerytrainningChange(Sender: TObject);
    procedure cbtypennChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miReloadClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure synJSONTesterChange(Sender: TObject);
    procedure synPythonChange(Sender: TObject);
  private
    fitem : TNNTrainning;
    procedure ReloadPython;
    procedure CarregaCombos;
    procedure LimpaTela;
    procedure AtualizaCamposCalculados;
    function  GaranteItem: TNNTrainning;
    function  ValidaCampos: Boolean;
    function  SafeSQLItemByIndex(AIndex: Integer): TSQLEditItem;
  public
    flgsalvar: boolean;
    procedure Load(item : TNNTrainning);
    function Save(): TNNTrainning;
  end;

var
  frmnntrain: Tfrmnntrain;

implementation

{$R *.lfm}

uses
  Math;

{ Tfrmnntrain }

procedure Tfrmnntrain.CarregaCombos;
begin
  cbquerytrainning.Items.Clear;
  cbquerytest.Items.Clear;
  cbtypenn.Items.Clear;

  if Assigned(Fsetproject) then
  begin
    cbquerytrainning.Items.Text := Fsetproject.SQLEdit_ListName();
    cbquerytest.Items.Text      := Fsetproject.SQLEdit_ListName();
  end;

  cbtypenn.Items.Text := 'CN_NONE' + LineEnding +
                         'RecImg' + LineEnding +
                         'NLPNeuralNetwork';
end;

procedure Tfrmnntrain.LimpaTela;
begin
  flgsalvar := False;
  fitem := nil;

  edNome.Clear;
  meComentario.Clear;

  cbquerytrainning.ItemIndex := -1;
  cbquerytest.ItemIndex := -1;
  cbtypenn.ItemIndex := -1;

  mesqltrainning.Clear;
  mesqltest.Clear;

  edGroupBy.Clear;
  edGroupByTester.Clear;

  edInputField.Clear;
  edInputRef.Clear;
  edInputRefField.Clear;
  edInputRefKey.Clear;
  edInputCols.Clear;

  edInputFieldTester.Clear;
  edInputRefTester.Clear;
  edInputRefFieldTester.Clear;
  edInputRefKeyTester.Clear;

  edOutputField.Clear;
  edOutputFieldTester.Clear;
  edOutputCols.Clear;

  edFilterValue.Clear;
  edFilterValueTester.Clear;

  synPython.Clear;
  synJSONTrainning.Clear;
  synJSONTester.Clear;
  fileJSONTester.Clear;
  melog.Clear;

  pnlog.Visible := False;
  PageControl1.PageIndex := 0;
end;

procedure Tfrmnntrain.AtualizaCamposCalculados;
begin
  if Assigned(fitem) then
  begin
    edInputCols.Text  := IntToStr(fitem.InputCols);
    edOutputCols.Text := IntToStr(fitem.OutputCols);
  end
  else
  begin
    edInputCols.Text  := '0';
    edOutputCols.Text := '0';
  end;
end;

function Tfrmnntrain.GaranteItem: TNNTrainning;
begin
  if not Assigned(fitem) then
    fitem := TNNTrainning.Create;
  Result := fitem;
end;

function Tfrmnntrain.SafeSQLItemByIndex(AIndex: Integer): TSQLEditItem;
begin
  Result := nil;
  if Assigned(Fsetproject) and (AIndex >= 0) and (AIndex < Fsetproject.Querycount) then
    Result := Fsetproject.SQLEdit_Indexof(AIndex);
end;

function Tfrmnntrain.ValidaCampos: Boolean;
begin
  Result := False;

  if Trim(edNome.Text) = '' then
  begin
    ShowMessage('Informe o nome do treinamento.');
    edNome.SetFocus;
    Exit;
  end;

  if cbquerytrainning.ItemIndex < 0 then
  begin
    ShowMessage('Selecione a query de treinamento.');
    cbquerytrainning.SetFocus;
    Exit;
  end;

  if cbquerytest.ItemIndex < 0 then
  begin
    ShowMessage('Selecione a query de teste.');
    cbquerytest.SetFocus;
    Exit;
  end;

  if cbtypenn.ItemIndex < 0 then
  begin
    ShowMessage('Selecione o tipo de rede.');
    cbtypenn.SetFocus;
    Exit;
  end;

  Result := True;
end;

procedure Tfrmnntrain.FormCreate(Sender: TObject);
begin
  LimpaTela;
  CarregaCombos;
end;

procedure Tfrmnntrain.miReloadClick(Sender: TObject);
begin
  ReloadPython;
end;

procedure Tfrmnntrain.PageControl1Change(Sender: TObject);
begin
end;

procedure Tfrmnntrain.synJSONTesterChange(Sender: TObject);
begin
end;

procedure Tfrmnntrain.synPythonChange(Sender: TObject);
begin
end;

procedure Tfrmnntrain.ReloadPython;
var
  arq: string;
begin
  if cbtypenn.ItemIndex <> -1 then
  begin
    arq := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
           'models' + PathDelim + 'model0' + IntToStr(cbtypenn.ItemIndex) + '.py';

    if FileExists(arq) then
      synPython.Lines.LoadFromFile(arq)
    else
      ShowMessage('Modelo Python não encontrado: ' + arq);
  end;
end;

procedure Tfrmnntrain.Load(item: TNNTrainning);
begin
  LimpaTela;
  CarregaCombos;

  fitem := item;
  if not Assigned(fitem) then
    Exit;

  edNome.Text := fitem.Nome;
  meComentario.Lines.Text := fitem.Commentario;

  if Assigned(Fsetproject) then
  begin
    cbquerytrainning.ItemIndex := Fsetproject.sqlEditItem_indexof(fitem.SQLTrainning);
    cbquerytest.ItemIndex      := Fsetproject.sqlEditItem_indexof(fitem.SQLTest);
  end;

  if Assigned(fitem.SQLTrainning) then
    mesqltrainning.Lines.Text := fitem.SQLTrainning.SQL
  else
    mesqltrainning.Clear;

  if Assigned(fitem.SQLTest) then
    mesqltest.Lines.Text := fitem.SQLTest.SQL
  else
    mesqltest.Clear;

  cbtypenn.ItemIndex := Integer(fitem.ClassNNTrainning);

  edGroupBy.Text       := fitem.GroupBy;
  edGroupByTester.Text := fitem.GroupByTester;

  edInputField.Text      := fitem.InputField;
  edInputRef.Text        := fitem.InputRef;
  edInputRefField.Text   := fitem.InputRefField;
  edInputRefKey.Text     := fitem.InputRefKey;
  edInputCols.Text       := IntToStr(fitem.InputCols);

  edInputFieldTester.Text    := fitem.InputFieldTester;
  edInputRefTester.Text      := fitem.InputRefTester;
  edInputRefFieldTester.Text := fitem.InputRefFieldTester;
  edInputRefKeyTester.Text   := fitem.InputRefKeyTester;

  edOutputField.Text       := fitem.OutputField;
  edOutputCols.Text        := IntToStr(fitem.OutputCols);
  edOutputFieldTester.Text := fitem.OutputFieldTester;

  synPython.Text := fitem.Python;
  melog.Text     := fitem.logtrainning;

  synJSONTrainning.Text  := fitem.jsontrainning;
  edFilterValue.Text     := fitem.FilterValue;
  edFilterValueTester.Text := fitem.FilterValueTester;

  fileJSONTester.Text := fitem.fileJSONTester;
  synJSONTester.Text  := fitem.JSONTester;

  pnlog.Visible := Trim(melog.Text) <> '';
end;

function Tfrmnntrain.Save: TNNTrainning;
var
  itemTreino, itemTeste: TSQLEditItem;
begin
  Result := fitem;

  if not flgsalvar then
    Exit;

  if not ValidaCampos then
    Exit(nil);

  Result := GaranteItem;

  Result.Nome        := Trim(edNome.Text);
  Result.Commentario := meComentario.Lines.Text;

  itemTreino := SafeSQLItemByIndex(cbquerytrainning.ItemIndex);
  itemTeste  := SafeSQLItemByIndex(cbquerytest.ItemIndex);

  Result.SQLTrainning := itemTreino;
  Result.SQLTest      := itemTeste;

  if Assigned(Result.SQLTrainning) then
    Result.SQLTrainning.SQL := mesqltrainning.Lines.Text;

  if Assigned(Result.SQLTest) then
    Result.SQLTest.SQL := mesqltest.Lines.Text;

  Result.ClassNNTrainning := TClasseNNTrainning(Max(0, cbtypenn.ItemIndex));

  Result.GroupBy       := Trim(edGroupBy.Text);
  Result.GroupByTester := Trim(edGroupByTester.Text);

  Result.InputField    := Trim(edInputField.Text);
  Result.InputRef      := Trim(edInputRef.Text);
  Result.InputRefField := Trim(edInputRefField.Text);
  Result.InputRefKey   := Trim(edInputRefKey.Text);

  Result.InputFieldTester    := Trim(edInputFieldTester.Text);
  Result.InputRefTester      := Trim(edInputRefTester.Text);
  Result.InputRefFieldTester := Trim(edInputRefFieldTester.Text);
  Result.InputRefKeyTester   := Trim(edInputRefKeyTester.Text);

  Result.OutputField       := Trim(edOutputField.Text);
  Result.OutputFieldTester := Trim(edOutputFieldTester.Text);

  Result.Python := synPython.Text;

  Result.jsontrainning    := synJSONTrainning.Text;
  Result.FilterValue      := Trim(edFilterValue.Text);
  Result.FilterValueTester:= Trim(edFilterValueTester.Text);

  Result.fileJSONTester := Trim(fileJSONTester.Text);
  Result.JSONTester     := synJSONTester.Text;

  AtualizaCamposCalculados;
end;

procedure Tfrmnntrain.btSaveClick(Sender: TObject);
begin
  if not ValidaCampos then
    Exit;

  flgsalvar := True;
  Save;
  ModalResult := mrOk;
end;

procedure Tfrmnntrain.btRUNClick(Sender: TObject);
var
  ItemAtual: TNNTrainning;
  marca: string;
begin
  ItemAtual := Save;
  if not Assigned(ItemAtual) then
    Exit;

  marca := Trim(ItemAtual.FilterConditionTester);
  if marca = '' then
    marca := Trim(ItemAtual.FilterCondition);
  if marca = '' then
    marca := Trim(ItemAtual.FilterValueTester);
  if marca = '' then
    marca := Trim(ItemAtual.FilterValue);

  if marca = '' then
    marca := 'default';

  if ItemAtual.testerJSON(marca) then
  begin
    synJSONTester.Text := ItemAtual.JSONTester;
    fileJSONTester.Text := ItemAtual.fileJSONTester;
    ShowMessage('JSON de teste gerado com sucesso.');
  end;
end;

procedure Tfrmnntrain.btTrainningClick(Sender: TObject);
var
  ItemAtual: TNNTrainning;
begin
  ItemAtual := Save;
  if not Assigned(ItemAtual) then
    Exit;

  if ItemAtual.trainnerJSON() then
  begin
    synJSONTrainning.Text := ItemAtual.jsontrainning;
    AtualizaCamposCalculados;
    ShowMessage('JSON de treinamento gerado com sucesso.');
  end;
end;

procedure Tfrmnntrain.Button1Click(Sender: TObject);
var
  ItemAtual: TNNTrainning;
begin
  ItemAtual := Save;
  if not Assigned(ItemAtual) then
    Exit;

  pnlog.Visible := True;
  melog.Clear;
  ItemAtual.Pythonlog := nil;

  if ItemAtual.RunTrainning() then
  begin
    melog.Lines.Text := ItemAtual.logtrainning;
    pnlog.Visible := Trim(melog.Text) <> '';
    ShowMessage('Treinamento executado com sucesso.');
  end
  else
  begin
    melog.Lines.Text := ItemAtual.logtrainning;
    pnlog.Visible := True;
    ShowMessage('Falha ao executar treinamento.');
  end;
end;

procedure Tfrmnntrain.cbquerytestChange(Sender: TObject);
var
  item: TSQLEditItem;
begin
  item := SafeSQLItemByIndex(cbquerytest.ItemIndex);
  if Assigned(item) then
    mesqltest.Lines.Text := item.SQL
  else
    mesqltest.Clear;
end;

procedure Tfrmnntrain.cbquerytrainningChange(Sender: TObject);
var
  item: TSQLEditItem;
begin
  item := SafeSQLItemByIndex(cbquerytrainning.ItemIndex);
  if Assigned(item) then
    mesqltrainning.Lines.Text := item.SQL
  else
    mesqltrainning.Clear;
end;

procedure Tfrmnntrain.cbtypennChange(Sender: TObject);
begin
  ReloadPython;
end;

end.
