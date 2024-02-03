unit chart;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  TATextElements, TALEGEND, TACustomSeries, TAGRAPH, TADrawUtils,
  TAChartUtils, DB, ZConnection, ZDataset, SynEdit, TATypes, TASeries, funcoes;

type

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

  public
    procedure GeraLinhaConstante(group: string; valuey: string;valuex: string);
    procedure GeraManhattan(group: string; values: string);
    procedure GeraPizza(group: string; values: string);
    procedure GeraBarra(group: string; values: string);
    procedure GeraLinha(group: string; values: string);
    procedure Refresh();
  end;

var
  frmChart: TfrmChart;

implementation

{$R *.lfm}

uses mquery2;

{ TfrmChart }

procedure TfrmChart.btrefreshChange(Sender: TObject);
begin
     refresh();
end;

procedure TfrmChart.btViewChange(Sender: TObject);
var
  group : string;
  value : string;
  valuey : string;
begin
  if(frmmquery2.dbgridmy.DataSource.DataSet.Active) then
  begin
      group := cbGroupItem.Items[cbGroupItem.ItemIndex];
      value := cbItemValue.Items[cbItemValue.ItemIndex];
      valuey := cbItemValue.Items[cbItemValueY.ItemIndex];
      if (cbTypeChart.ItemIndex = 1) then //Gera Pizza
      begin
         GeraPizza(group, value);
      end;
      if (cbTypeChart.ItemIndex = 2) then //Gera Barra
      begin
         GeraBarra(group, value);
      end;
      if (cbTypeChart.ItemIndex = 3) then //Gera Line
      begin
         GeraLinha(group, value);
      end;
      if (cbTypeChart.ItemIndex = 4) then //Gera Manhattan
      begin
         GeraManhattan(group, value);
      end;
      if (cbTypeChart.ItemIndex = 4) then //Gera Manhattan
      begin
         GeraLinhaConstante(group, value, valuey);
      end;
  end;
end;

procedure TfrmChart.cbTypeChartSelect(Sender: TObject);
begin
  Refresh();
end;

procedure TfrmChart.GeraLinhaConstante(group: string; valuey: string;valuex: string);
var
  valorx: Variant;
  valory: Variant;
  groupfield: string;
  ConstantLine: TConstantLine;
begin
  Chart1.ClearSeries;  // Limpa as séries existentes

  frmmquery2.dbgridmy.DataSource.DataSet.DisableControls;  // Desabilita controles para otimização
  try
    frmmquery2.dbgridmy.DataSource.DataSet.First;
    while not frmmquery2.dbgridmy.DataSource.DataSet.Eof do
    begin
      if not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(valuex).IsNull and
         not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(valuey).IsNull and
         not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).IsNull then
      begin
        valorx := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(valuex).AsVariant;
        valory := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(valuey).AsVariant;
        groupfield := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).AsString;

        // Cria e configura a linha constante para cada valor distinto
        ConstantLine := TConstantLine.Create(Chart1);

        ConstantLine.Position := valorx;
        ConstantLine.Index:= valory;
        ConstantLine.Title := groupfield;

        //lsVertical, lsHorizontal
        ConstantLine.LineStyle:=lsHorizontal;
        //ConstantLine.LinePen.Width := 2;
        //ConstantLine.LinePen.Style := psSolid;
        //ConstantLine.LinePen.Color := clRed; // Defina a cor conforme necessário
        Chart1.AddSeries(ConstantLine);
      end;
      frmmquery2.dbgridmy.DataSource.DataSet.Next;
    end;
  finally
    frmmquery2.dbgridmy.DataSource.DataSet.EnableControls;  // Reabilita controles após carregamento
  end;

  // Configurações da legenda
  Chart1.Legend.Visible := True;  // Habilita a legenda
  Chart1.Legend.Alignment := laBottomLeft;  // Posição da legenda
end;



procedure TfrmChart.GeraManhattan(group: string; values: string);
var
  valor: Variant;
  groupfield: string;
  ManhattanSeries: TManhattanSeries;
begin
  Chart1.ClearSeries;  // Limpa as séries existentes
  ManhattanSeries := TManhattanSeries.Create(Chart1);
  Chart1.AddSeries(ManhattanSeries);

  // Configurações específicas para a série Manhattan
  //ManhattanSeries.UsePalette := True; // Utiliza paleta de cores para os blocos
  //ManhattanSeries.SeriesColor:=;
  //ManhattanSeries.UseColorRange := False; // Desativa a faixa de cores

  // Configurações da legenda
  Chart1.Legend.Visible := True;
  Chart1.Legend.Alignment := laBottomLeft;  // Posição da legenda

  frmmquery2.dbgridmy.DataSource.DataSet.DisableControls;  // Desabilita controles para otimização
  try
    frmmquery2.dbgridmy.DataSource.DataSet.First;
    while not frmmquery2.dbgridmy.DataSource.DataSet.Eof do
    begin
      if not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).IsNull and
         not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).IsNull then
      begin
        valor := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).AsVariant;
        groupfield := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).AsString;
        ManhattanSeries.Add(valor, groupfield);  // Adiciona o valor, o rótulo e a cor
      end;
      frmmquery2.dbgridmy.DataSource.DataSet.Next;
    end;
  finally
    frmmquery2.dbgridmy.DataSource.DataSet.EnableControls;  // Reabilita controles após carregamento
  end;
end;


procedure TfrmChart.GeraPizza(group: string; values: string);
var
  valor: Variant;
  groupfield: string;
  PieSeries: TPieSeries;
begin
  Chart1.ClearSeries;  // Limpa as séries existentes
  PieSeries := TPieSeries.Create(Chart1);
  Chart1.AddSeries(PieSeries);

  // Configurações da série de pizza para exibir os rótulos (nomes dos grupos)
  PieSeries.Marks.Style := smsLabel; // Mostra o rótulo de cada fatia
  PieSeries.Marks.Visible := True;

  // Configurações da legenda
  Chart1.Legend.Visible := True;
  (*
     laTopLeft, laCenterLeft, laBottomLeft,
    laTopCenter, laBottomCenter, // laCenterCenter makes no sense.
    laTopRight, laCenterRight, laBottomRight);
  *)
  Chart1.Legend.Alignment := laBottomLeft;  // Posição da legenda

  frmmquery2.dbgridmy.DataSource.DataSet.DisableControls;  // Desabilita controles para otimização
  try
    frmmquery2.dbgridmy.DataSource.DataSet.First;
    while not frmmquery2.dbgridmy.DataSource.DataSet.Eof do
    begin
      if not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).IsNull and
         not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).IsNull then
      begin
        valor := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).AsVariant;
        groupfield := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).AsString;
        PieSeries.Add(valor, groupfield);  // Adiciona o valor e o rótulo (nome do grupo)
      end;
      frmmquery2.dbgridmy.DataSource.DataSet.Next;
    end;
  finally
    frmmquery2.dbgridmy.DataSource.DataSet.EnableControls;  // Reabilita controles após carregamento
  end;
end;

procedure TfrmChart.GeraLinha(group: string; values: string);
var
  valor: Variant;
  groupfield: string;
  LineSeries: TLineSeries;
begin
  Chart1.ClearSeries;  // Limpa as séries existentes
  LineSeries := TLineSeries.Create(Chart1);
  Chart1.AddSeries(LineSeries);

  // Configurações da série de linha
  LineSeries.ShowPoints := True; // Mostra pontos para cada valor
  LineSeries.LinePen.Width := 2; // Configura a espessura da linha

  // Configurações da legenda
  Chart1.Legend.Visible := True;
  Chart1.Legend.Alignment := laBottomLeft;  // Posição da legenda

  frmmquery2.dbgridmy.DataSource.DataSet.DisableControls;  // Desabilita controles para otimização
  try
    frmmquery2.dbgridmy.DataSource.DataSet.First;
    while not frmmquery2.dbgridmy.DataSource.DataSet.Eof do
    begin
      if not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).IsNull and
         not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).IsNull then
      begin
        valor := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).AsVariant;
        groupfield := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).AsString;
        LineSeries.Add(valor, groupfield);  // Adiciona o valor e o rótulo (nome do grupo)
      end;
      frmmquery2.dbgridmy.DataSource.DataSet.Next;
    end;
  finally
    frmmquery2.dbgridmy.DataSource.DataSet.EnableControls;  // Reabilita controles após carregamento
  end;
end;


procedure TfrmChart.GeraBarra(group: string; values: string);
var
  valor: Variant;
  groupfield: string;
  BarSeries: TBarSeries;
begin
  Chart1.ClearSeries;  // Limpa as séries existentes
  BarSeries := TBarSeries.Create(Chart1);
  Chart1.AddSeries(BarSeries);

  // Configurações da legenda
  Chart1.Legend.Visible := True;
  (*
    laTopLeft, laCenterLeft, laBottomLeft,
    laTopCenter, laBottomCenter, // laCenterCenter makes no sense.
    laTopRight, laCenterRight, laBottomRight);
    *)
  Chart1.Legend.Alignment := laBottomLeft;  // Posição da legenda

  frmmquery2.dbgridmy.DataSource.DataSet.DisableControls;  // Desabilita controles para otimização
  try
    frmmquery2.dbgridmy.DataSource.DataSet.First;
    while not frmmquery2.dbgridmy.DataSource.DataSet.Eof do
    begin
      if not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).IsNull and
         not frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).IsNull then
      begin
        valor := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(values).AsVariant;
        groupfield := frmmquery2.dbgridmy.DataSource.DataSet.FieldByName(group).AsString;
        BarSeries.Add(valor, groupfield);  // Adiciona o valor e o rótulo (nome do grupo)
      end;
      frmmquery2.dbgridmy.DataSource.DataSet.Next;
    end;
  finally
    frmmquery2.dbgridmy.DataSource.DataSet.EnableControls;  // Reabilita controles após carregamento
  end;
end;

procedure TfrmChart.Refresh;
begin
  if(frmmquery2.dbgridmy.DataSource.DataSet.Active) then
  begin
      cbGroupItem.Items.text := PegaFields(frmmquery2.dbgridmy.DataSource.DataSet).Text;
      cbGroupItem.ItemIndex := -1;
      cbGroupItem.Text:='';
      cbItemValue.Items.text := PegaFields(frmmquery2.dbgridmy.DataSource.DataSet).Text;
      cbItemValue.ItemIndex:= -1;
      cbItemValue.text := '';
      cbItemValueY.Items.text := PegaFields(frmmquery2.dbgridmy.DataSource.DataSet).Text;
      cbItemValueY.ItemIndex:= -1;
      cbItemValueY.text := '';
      if (cbGroupItem.ItemIndex=3) then
      begin
          cbItemValueY.Enabled:=true;
      end
      else
      begin
          cbItemValueY.Enabled:=false;
      end;
  end;

end;


end.

