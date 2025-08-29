unit chart;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  TATextElements, TALEGEND, TACustomSeries, TAGRAPH, TADrawUtils,
  TAChartUtils, DB, ZConnection, ZDataset, SynEdit, TATypes, TASeries, funcoes;

type
  TChartCommType = (ccNone, ccMySQL, ccPostgres);

  { TfrmChart }

  TfrmChart = class(TForm)
    cbGroupItem: TComboBox;
    cbItemValue: TComboBox;
    cbItemValueY: TComboBox;
    Chart1: TChart;
    cbTypeChart: TComboBox;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    pcChart: TPageControl;
    btrefresh: TToggleBox;
    btView: TToggleBox;
    tsChart: TTabSheet;
    tsSetup: TTabSheet;
    procedure btrefreshChange(Sender: TObject);
    procedure btViewChange(Sender: TObject);
    procedure cbTypeChartSelect(Sender: TObject);
  private
    FCommType: TChartCommType;
    FDataSet: TDataSet;
    function ResolveDataSet: TDataSet;
    procedure ApplyCommType;
  public
    procedure SetCommType(AType: TChartCommType);
    procedure GeraLinhaConstante(group: string; valuey: string; valuex: string);
    procedure GeraManhattan(group: string; values: string);
    procedure GeraPizza(group: string; values: string);
    procedure GeraBarra(group: string; values: string);
    procedure GeraLinha(group: string; values: string);
    procedure Refresh; reintroduce;
    property CommType: TChartCommType read FCommType write SetCommType;
  end;

var
  frmChart: TfrmChart;

implementation

{$R *.lfm}

uses mquery2;

{ ====== Helpers de origem/dataset ====== }

function TfrmChart.ResolveDataSet: TDataSet;
begin
  // Se já foi setado manualmente (cache) e está ativo, usa-o
  if Assigned(FDataSet) and FDataSet.Active then
    Exit(FDataSet);

  case FCommType of
    ccMySQL:    Result := frmmquery2.zmyqry2;    // ajuste se o dataset "oficial" for outro
    ccPostgres: Result := frmmquery2.zpostqry1;
  else
    Result := nil;
  end;
end;

procedure TfrmChart.ApplyCommType;
begin
  FDataSet := ResolveDataSet;
end;

procedure TfrmChart.SetCommType(AType: TChartCommType);
begin
  if FCommType = AType then Exit;
  FCommType := AType;
  ApplyCommType;
  Refresh;
end;

{ ====== UI ====== }

procedure TfrmChart.btrefreshChange(Sender: TObject);
begin
  Refresh;
end;

procedure TfrmChart.btViewChange(Sender: TObject);
var
  DS: TDataSet;
  group  : string;
  value  : string;
  valuey : string;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  if (cbGroupItem.ItemIndex < 0) or (cbItemValue.ItemIndex < 0) then Exit;

  group  := cbGroupItem.Items[cbGroupItem.ItemIndex];
  value  := cbItemValue.Items[cbItemValue.ItemIndex];
  if cbItemValueY.Enabled and (cbItemValueY.ItemIndex >= 0) then
    valuey := cbItemValueY.Items[cbItemValueY.ItemIndex]
  else
    valuey := '';

  // Mapeamento:
  // 1 = Pizza, 2 = Barra, 3 = Linha, 4 = Manhattan, 5 = Linha Constante
  case cbTypeChart.ItemIndex of
    1: GeraPizza(group, value);
    2: GeraBarra(group, value);
    3: GeraLinha(group, value);
    4: GeraManhattan(group, value);
    5: if valuey <> '' then
         GeraLinhaConstante(group, valuey, value); // (group, Y, X)
  end;
end;

procedure TfrmChart.cbTypeChartSelect(Sender: TObject);
begin
  // habilita combo Y só quando for "Linha Constante"
  cbItemValueY.Enabled := (cbTypeChart.ItemIndex = 5);
  Refresh;
end;

{ ====== Geração de séries ====== }

procedure TfrmChart.GeraLinhaConstante(group: string; valuey: string; valuex: string);
var
  DS: TDataSet;
  valorx: Variant;
  valory: Variant;
  groupfield: string;
  ConstantLine: TConstantLine;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  Chart1.ClearSeries;  // Limpa as séries existentes

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(valuex).IsNull) and
         (not DS.FieldByName(valuey).IsNull) and
         (not DS.FieldByName(group).IsNull) then
      begin
        valorx := DS.FieldByName(valuex).AsVariant;
        valory := DS.FieldByName(valuey).AsVariant;
        groupfield := DS.FieldByName(group).AsString;

        // Cria e configura a linha constante para cada valor
        ConstantLine := TConstantLine.Create(Chart1);
        ConstantLine.Position := valorx;
        ConstantLine.Index := valory;
        ConstantLine.Title := groupfield;
        ConstantLine.LineStyle := lsHorizontal; // ou lsVertical

        Chart1.AddSeries(ConstantLine);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;

  // Configurações da legenda
  Chart1.Legend.Visible := True;
  Chart1.Legend.Alignment := laBottomLeft;
end;

procedure TfrmChart.GeraManhattan(group: string; values: string);
var
  DS: TDataSet;
  valor: Variant;
  groupfield: string;
  ManhattanSeries: TManhattanSeries;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  Chart1.ClearSeries;
  ManhattanSeries := TManhattanSeries.Create(Chart1);
  Chart1.AddSeries(ManhattanSeries);

  // Legenda
  Chart1.Legend.Visible := True;
  Chart1.Legend.Alignment := laBottomLeft;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and
         (not DS.FieldByName(group).IsNull) then
      begin
        valor := DS.FieldByName(values).AsVariant;
        groupfield := DS.FieldByName(group).AsString;
        ManhattanSeries.Add(valor, groupfield);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;
end;

procedure TfrmChart.GeraPizza(group: string; values: string);
var
  DS: TDataSet;
  valor: Variant;
  groupfield: string;
  PieSeries: TPieSeries;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  Chart1.ClearSeries;
  PieSeries := TPieSeries.Create(Chart1);
  Chart1.AddSeries(PieSeries);

  // Rótulos
  PieSeries.Marks.Style := smsLabel;
  PieSeries.Marks.Visible := True;

  // Legenda
  Chart1.Legend.Visible := True;
  Chart1.Legend.Alignment := laBottomLeft;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and
         (not DS.FieldByName(group).IsNull) then
      begin
        valor := DS.FieldByName(values).AsVariant;
        groupfield := DS.FieldByName(group).AsString;
        PieSeries.Add(valor, groupfield);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;
end;

procedure TfrmChart.GeraLinha(group: string; values: string);
var
  DS: TDataSet;
  valor: Variant;
  groupfield: string;
  LineSeries: TLineSeries;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  Chart1.ClearSeries;
  LineSeries := TLineSeries.Create(Chart1);
  Chart1.AddSeries(LineSeries);

  // Estilo da linha
  LineSeries.ShowPoints := True;
  LineSeries.LinePen.Width := 2;

  // Legenda
  Chart1.Legend.Visible := True;
  Chart1.Legend.Alignment := laBottomLeft;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and
         (not DS.FieldByName(group).IsNull) then
      begin
        valor := DS.FieldByName(values).AsVariant;
        groupfield := DS.FieldByName(group).AsString;
        LineSeries.Add(valor, groupfield);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;
end;

procedure TfrmChart.GeraBarra(group: string; values: string);
var
  DS: TDataSet;
  valor: Variant;
  groupfield: string;
  BarSeries: TBarSeries;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  Chart1.ClearSeries;
  BarSeries := TBarSeries.Create(Chart1);
  Chart1.AddSeries(BarSeries);

  // Legenda
  Chart1.Legend.Visible := True;
  Chart1.Legend.Alignment := laBottomLeft;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and
         (not DS.FieldByName(group).IsNull) then
      begin
        valor := DS.FieldByName(values).AsVariant;
        groupfield := DS.FieldByName(group).AsString;
        BarSeries.Add(valor, groupfield);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;
end;

{ ====== Refresh único por tipo ====== }

procedure TfrmChart.Refresh;
var
  DS: TDataSet;
  fieldsText: string;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  fieldsText := PegaFields(DS).Text;

  cbGroupItem.Items.Text  := fieldsText;
  cbGroupItem.ItemIndex   := -1;
  cbGroupItem.Text        := '';

  cbItemValue.Items.Text  := fieldsText;
  cbItemValue.ItemIndex   := -1;
  cbItemValue.Text        := '';

  cbItemValueY.Items.Text := fieldsText;
  cbItemValueY.ItemIndex  := -1;
  cbItemValueY.Text       := '';

  // habilita Y apenas quando o tipo for Linha Constante (índice 5)
  cbItemValueY.Enabled := (cbTypeChart.ItemIndex = 5);
end;

end.

