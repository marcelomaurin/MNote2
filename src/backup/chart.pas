unit chart;

{ ObjFPC}{+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Math, DB, ZConnection, ZDataset, SynEdit, funcoes;

type
  TChartCommType = (ccNone, ccMySQL, ccPostgres);

  TChartDataPoint = record
    LabelText: string;
    Value: Double;
    Color: TColor;
  end;

  { TfrmChart }

  TfrmChart = class(TForm)
    cbGroupItem: TComboBox;
    cbItemValue: TComboBox;
    cbItemValueY: TComboBox;
    PaintBox1: TPaintBox;
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
    procedure PaintBox1Paint(Sender: TObject);
  private
    FCommType: TChartCommType;
    FDataSet: TDataSet;
    FDataPoints: array of TChartDataPoint;
    FChartType: Integer;
    function ResolveDataSet: TDataSet;
    procedure ApplyCommType;
    procedure ClearData;
    procedure AddPoint(const ALabel: string; AValue: Double);
    function PickColor(AIndex: Integer): TColor;
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

{ *.lfm}

uses mquery2;

const
  PALETTE_COLORS: array[0..9] of TColor = (
    clBlue, clRed, clGreen, clPurple, clTeal,
    clNavy, clMaroon, clOlive, clLime, clFuchsia
  );

function TfrmChart.ResolveDataSet: TDataSet;
begin
  if Assigned(FDataSet) and FDataSet.Active then
    Exit(FDataSet);

  case FCommType of
    ccMySQL:    Result := frmmquery2.zmyqry2;
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

procedure TfrmChart.ClearData;
begin
  SetLength(FDataPoints, 0);
end;

function TfrmChart.PickColor(AIndex: Integer): TColor;
begin
  Result := PALETTE_COLORS[AIndex mod Length(PALETTE_COLORS)];
end;

procedure TfrmChart.AddPoint(const ALabel: string; AValue: Double);
var
  Idx: Integer;
begin
  Idx := Length(FDataPoints);
  SetLength(FDataPoints, Idx + 1);
  FDataPoints[Idx].LabelText := ALabel;
  FDataPoints[Idx].Value := AValue;
  FDataPoints[Idx].Color := PickColor(Idx);
end;

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

  case cbTypeChart.ItemIndex of
    1: GeraPizza(group, value);
    2: GeraBarra(group, value);
    3: GeraLinha(group, value);
    4: GeraManhattan(group, value);
    5: if valuey <> '' then
         GeraLinhaConstante(group, valuey, value);
  end;
end;

procedure TfrmChart.cbTypeChartSelect(Sender: TObject);
begin
  cbItemValueY.Enabled := (cbTypeChart.ItemIndex = 5);
  Refresh;
end;

procedure TfrmChart.GeraLinhaConstante(group: string; valuey: string; valuex: string);
var
  DS: TDataSet;
  val: Double;
  groupfield: string;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  ClearData;
  FChartType := 5;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(valuey).IsNull) and (not DS.FieldByName(group).IsNull) then
      begin
        val := DS.FieldByName(valuey).AsFloat;
        groupfield := DS.FieldByName(group).AsString;
        AddPoint(groupfield, val);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;

  PaintBox1.Invalidate;
end;

procedure TfrmChart.GeraManhattan(group: string; values: string);
var
  DS: TDataSet;
  val: Double;
  groupfield: string;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  ClearData;
  FChartType := 4;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and (not DS.FieldByName(group).IsNull) then
      begin
        val := DS.FieldByName(values).AsFloat;
        groupfield := DS.FieldByName(group).AsString;
        AddPoint(groupfield, val);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;

  PaintBox1.Invalidate;
end;

procedure TfrmChart.GeraPizza(group: string; values: string);
var
  DS: TDataSet;
  val: Double;
  groupfield: string;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  ClearData;
  FChartType := 1;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and (not DS.FieldByName(group).IsNull) then
      begin
        val := DS.FieldByName(values).AsFloat;
        groupfield := DS.FieldByName(group).AsString;
        AddPoint(groupfield, val);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;

  PaintBox1.Invalidate;
end;

procedure TfrmChart.GeraLinha(group: string; values: string);
var
  DS: TDataSet;
  val: Double;
  groupfield: string;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  ClearData;
  FChartType := 3;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and (not DS.FieldByName(group).IsNull) then
      begin
        val := DS.FieldByName(values).AsFloat;
        groupfield := DS.FieldByName(group).AsString;
        AddPoint(groupfield, val);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;

  PaintBox1.Invalidate;
end;

procedure TfrmChart.GeraBarra(group: string; values: string);
var
  DS: TDataSet;
  val: Double;
  groupfield: string;
begin
  DS := ResolveDataSet;
  if (DS = nil) or (not DS.Active) then Exit;

  ClearData;
  FChartType := 2;

  DS.DisableControls;
  try
    DS.First;
    while not DS.Eof do
    begin
      if (not DS.FieldByName(values).IsNull) and (not DS.FieldByName(group).IsNull) then
      begin
        val := DS.FieldByName(values).AsFloat;
        groupfield := DS.FieldByName(group).AsString;
        AddPoint(groupfield, val);
      end;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;

  PaintBox1.Invalidate;
end;

procedure TfrmChart.PaintBox1Paint(Sender: TObject);
var
  C: TCanvas;
  W, H, MarginL, MarginR, MarginT, MarginB: Integer;
  PlotW, PlotH: Integer;
  i, Count: Integer;
  MaxVal, TotalVal, ValRatio: Double;
  BarW, BarSpacing, XPos, YPos, BarH: Integer;
  AngleStart, AngleSweep, AngleEnd: Double;
  RadStart, RadEnd: Double;
  PieX, PieY, PieR: Integer;
  PtX, PtY, PrevX, PrevY: Integer;
  S: string;
  LegX, LegY, LegBoxSize: Integer;
begin
  C := PaintBox1.Canvas;
  W := PaintBox1.Width;
  H := PaintBox1.Height;

  C.Brush.Color := clWindow;
  C.Brush.Style := bsSolid;
  C.FillRect(0, 0, W, H);

  Count := Length(FDataPoints);
  if Count = 0 then
  begin
    C.Font.Color := clGray;
    C.Font.Size := 10;
    S := 'Selecione os campos e clique em View';
    C.TextOut((W - C.TextWidth(S)) div 2, (H - C.TextHeight(S)) div 2, S);
    Exit;
  end;

  MarginL := 65;
  MarginR := 150;
  MarginT := 30;
  MarginB := 50;
  PlotW := W - MarginL - MarginR;
  PlotH := H - MarginT - MarginB;
  if (PlotW < 40) or (PlotH < 40) then Exit;

  MaxVal := 0;
  TotalVal := 0;
  for i := 0 to Count - 1 do
  begin
    if FDataPoints[i].Value > MaxVal then
      MaxVal := FDataPoints[i].Value;
    TotalVal := TotalVal + Abs(FDataPoints[i].Value);
  end;
  if MaxVal <= 0 then MaxVal := 1;
  if TotalVal <= 0 then TotalVal := 1;

  case FChartType of
    1:
      begin
        PieR := Min(PlotW, PlotH) div 2 - 15;
        if PieR < 15 then PieR := 15;
        PieX := MarginL + PlotW div 2;
        PieY := MarginT + PlotH div 2;

        AngleStart := 0;
        for i := 0 to Count - 1 do
        begin
          AngleSweep := (Abs(FDataPoints[i].Value) / TotalVal) * 360.0;
          AngleEnd := AngleStart + AngleSweep;

          C.Brush.Color := FDataPoints[i].Color;
          C.Pen.Color := clWhite;
          C.Pen.Width := 2;

          RadStart := DegToRad(AngleStart);
          RadEnd := DegToRad(AngleEnd);
          C.Pie(PieX - PieR, PieY - PieR, PieX + PieR, PieY + PieR,
            PieX + Round(PieR * Cos(RadStart)), PieY - Round(PieR * Sin(RadStart)),
            PieX + Round(PieR * Cos(RadEnd)), PieY - Round(PieR * Sin(RadEnd)));

          AngleStart := AngleEnd;
        end;
      end;

    2, 4:
      begin
        C.Pen.Color := clGray;
        C.Pen.Width := 1;
        C.Line(MarginL, MarginT, MarginL, MarginT + PlotH);
        C.Line(MarginL, MarginT + PlotH, MarginL + PlotW, MarginT + PlotH);

        for i := 0 to 4 do
        begin
          YPos := MarginT + PlotH - Round((i / 4.0) * PlotH);
          //C.Pen.Color := ;
          C.Line(MarginL, YPos, MarginL + PlotW, YPos);
          C.Font.Size := 8;
          C.Font.Color := clGray;
          S := FloatToStrF((i / 4.0) * MaxVal, ffGeneral, 4, 2);
          C.TextOut(MarginL - C.TextWidth(S) - 4, YPos - C.TextHeight(S) div 2, S);
        end;

        BarSpacing := PlotW div (Count + 1);
        BarW := Max(8, Min(35, BarSpacing - 6));

        for i := 0 to Count - 1 do
        begin
          XPos := MarginL + (i + 1) * BarSpacing - BarW div 2;
          BarH := Round((FDataPoints[i].Value / MaxVal) * PlotH);
          YPos := MarginT + PlotH - BarH;

          C.Brush.Color := FDataPoints[i].Color;
          C.Pen.Color := FDataPoints[i].Color;
          C.Rectangle(XPos, YPos, XPos + BarW, MarginT + PlotH);

          C.Font.Color := clBlack;
          C.Font.Size := 8;
          S := FloatToStrF(FDataPoints[i].Value, ffGeneral, 4, 2);
          C.TextOut(XPos + (BarW - C.TextWidth(S)) div 2, YPos - C.TextHeight(S) - 2, S);

          S := FDataPoints[i].LabelText;
          if Length(S) > 9 then S := Copy(S, 1, 7) + '..';
          C.TextOut(XPos + (BarW - C.TextWidth(S)) div 2, MarginT + PlotH + 4, S);
        end;
      end;

    3, 5:
      begin
        C.Pen.Color := clGray;
        C.Pen.Width := 1;
        C.Line(MarginL, MarginT, MarginL, MarginT + PlotH);
        C.Line(MarginL, MarginT + PlotH, MarginL + PlotW, MarginT + PlotH);

        for i := 0 to 4 do
        begin
          YPos := MarginT + PlotH - Round((i / 4.0) * PlotH);
          //C.Pen.Color := ;
          C.Line(MarginL, YPos, MarginL + PlotW, YPos);
          C.Font.Size := 8;
          C.Font.Color := clGray;
          S := FloatToStrF((i / 4.0) * MaxVal, ffGeneral, 4, 2);
          C.TextOut(MarginL - C.TextWidth(S) - 4, YPos - C.TextHeight(S) div 2, S);
        end;

        BarSpacing := PlotW div Max(1, Count);
        PrevX := 0;
        PrevY := 0;

        for i := 0 to Count - 1 do
        begin
          PtX := MarginL + i * BarSpacing + BarSpacing div 2;
          PtY := MarginT + PlotH - Round((FDataPoints[i].Value / MaxVal) * PlotH);

          if i > 0 then
          begin
            //C.Pen.Color := ;
            C.Pen.Width := 2;
            C.Line(PrevX, PrevY, PtX, PtY);
          end;

          C.Brush.Color := FDataPoints[i].Color;
          C.Pen.Color := clBlack;
          C.Pen.Width := 1;
          C.Ellipse(PtX - 4, PtY - 4, PtX + 4, PtY + 4);

          C.Font.Color := clBlack;
          C.Font.Size := 8;
          S := FloatToStrF(FDataPoints[i].Value, ffGeneral, 4, 2);
          C.TextOut(PtX - C.TextWidth(S) div 2, PtY - C.TextHeight(S) - 4, S);

          S := FDataPoints[i].LabelText;
          if Length(S) > 8 then S := Copy(S, 1, 6) + '..';
          C.TextOut(PtX - C.TextWidth(S) div 2, MarginT + PlotH + 4, S);

          PrevX := PtX;
          PrevY := PtY;
        end;
      end;
  end;

  LegX := W - MarginR + 10;
  LegY := MarginT;
  LegBoxSize := 10;
  C.Font.Size := 8;

  //C.Brush.Color := ;
  C.Pen.Color := ;
  C.Rectangle(LegX - 4, LegY - 4, W - 8, Min(H - 8, LegY + Count * 18 + 8));

  for i := 0 to Min(Count - 1, 15) do
  begin
    C.Brush.Color := FDataPoints[i].Color;
    C.Pen.Color := clBlack;
    C.Pen.Width := 1;
    C.Rectangle(LegX, LegY + i * 18, LegX + LegBoxSize, LegY + i * 18 + LegBoxSize);

    C.Font.Color := clBlack;
    S := FDataPoints[i].LabelText;
    if FChartType = 1 then
    begin
      ValRatio := (Abs(FDataPoints[i].Value) / TotalVal) * 100.0;
      S := S + Format(' (%.1f%%)', [ValRatio]);
    end;
    if Length(S) > 16 then S := Copy(S, 1, 14) + '..';
    C.TextOut(LegX + LegBoxSize + 4, LegY + i * 18 - 1, S);
  end;
end;

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

  cbItemValueY.Enabled := (cbTypeChart.ItemIndex = 5);
end;

end.
