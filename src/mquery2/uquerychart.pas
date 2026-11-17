unit uquerychart;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
  Printers, PrintersDlgs, DB, Contnrs, Types, Math, uquerymap;

type
  TQChartType = (qctBar, qctHorizBar, qctLine, qctPie, qctDonut, qctMap, qctArea, qctScatter);
  TQChartAgg = (qcaSum, qcaCount, qcaAvg, qcaMax, qcaMin);

  TQChartPinEvent = procedure(Sender: TObject; const ATitle, ASQL, AWidgetKind,
    ACatField, AValField, ALatField, ALonField: string; AAggIndex, ATopIndex: Integer) of object;

  TQChartPoint = class
  public
    LabelText: string;
    Value: Double;
    Count: Integer;
    HitRect: TRect;
    StartAngle, SweepAngle: Double;
  end;

  TQueryChartPanel = class(TPanel)
  private
    FToolbar: TPanel;
    FLblType: TLabel;
    FCbType: TComboBox;
    FLblCat: TLabel;
    FCbCat: TComboBox;
    FLblVal: TLabel;
    FCbVal: TComboBox;
    FLblAgg: TLabel;
    FCbAgg: TComboBox;
    FLblTop: TLabel;
    FCbTop: TComboBox;
    FBtnRefresh: TButton;
    FBtnExport: TButton;
    FBtnPrint: TButton;
    FBtnCustomize: TButton;
    FBtnWizard: TButton;
    FBtnPinChart: TButton;
    FBtnPinKPI: TButton;

    FCanvas: TPaintBox;
    FMapView: TQueryMapPanel;
    FBuffer: TBitmap;
    FDataSet: TDataSet;
    FCurrentSQL: string;
    FChartTitle: string;
    FIs3D: Boolean;
    FTitleFontName: string;
    FTitleFontSize: Integer;
    FLegendPos: Integer;   // 0=Direita, 1=Abaixo, 2=Oculta
    FLegendStyle: Integer; // 0=Nome+Valor, 1=Nome+%, 2=Nome, 3=Nome+Valor+%
    FChartScalePct: Integer;
    FPoints: TObjectList;
    FHoverIndex: Integer;
    FHoverPos: TPoint;
    FPieCenter: TPoint;
    FPieRadius: Integer;
    FOnPinToDashboard: TQChartPinEvent;

    procedure BuildUI;
    procedure PopulateFieldCombos;
    procedure RebuildSeries;
    procedure ControlsChange(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
    procedure BtnPrintClick(Sender: TObject);
    procedure BtnCustomizeClick(Sender: TObject);
    procedure BtnWizardClick(Sender: TObject);
    procedure BtnPinChartClick(Sender: TObject);
    procedure BtnPinKPIClick(Sender: TObject);
    procedure CanvasPaint(Sender: TObject);
    procedure CanvasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawBarChart(G: TCanvas; const PlotR: TRect);
    procedure DrawHorizBarChart(G: TCanvas; const PlotR: TRect);
    procedure DrawLineChart(G: TCanvas; const PlotR: TRect);
    procedure DrawAreaChart(G: TCanvas; const PlotR: TRect);
    procedure DrawScatterChart(G: TCanvas; const PlotR: TRect);
    procedure DrawPieChart(G: TCanvas; const PlotR: TRect);
    procedure DrawLegend(G: TCanvas; const LegR: TRect);
    function DarkenColor(C: TColor; Factor: Double): TColor;
    function FormatLegendText(Pt: TQChartPoint; TotalVal: Double): string;
    function PaletteColor(Index: Integer): TColor;
    function FormatNum(V: Double): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromDataSet(ADataSet: TDataSet; const ATitle: string = ''; const ASQL: string = '');
    procedure SetDashboardButtonsVisible(AVisible: Boolean);
    property OnPinToDashboard: TQChartPinEvent read FOnPinToDashboard write FOnPinToDashboard;
  end;

implementation

const
  CHART_PALETTE: array[0..9] of TColor = (
    $FF9933, // Blue-ish (BGR)
    $55C522, // Green
    $0B9EF5, // Amber
    $4444EF, // Red
    $F65C8B, // Purple
    $B67206, // Cyan/Teal
    $1673F9, // Orange
    $9948EC, // Pink
    $A49464, // Slate
    $66CC14  // Lime
  );

{ TQueryChartPanel }

constructor TQueryChartPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPoints := TObjectList.Create(True);
  FBuffer := TBitmap.Create;
  FHoverIndex := -1;
  FIs3D := False;
  FTitleFontName := 'Segoe UI';
  FTitleFontSize := 12;
  FLegendPos := 0;
  FLegendStyle := 0;
  FChartScalePct := 100;
  BevelOuter := bvNone;
  Color := clWhite;
  BuildUI;
end;

destructor TQueryChartPanel.Destroy;
begin
  FBuffer.Free;
  FPoints.Free;
  inherited Destroy;
end;

procedure TQueryChartPanel.BuildUI;
begin
  FToolbar := TPanel.Create(Self);
  FToolbar.Parent := Self;
  FToolbar.Align := alTop;
  FToolbar.Height := 68;
  FToolbar.BevelOuter := bvNone;
  FToolbar.Color := RGBToColor(248, 250, 252);

  FLblType := TLabel.Create(Self);
  FLblType.Parent := FToolbar;
  FLblType.SetBounds(10, 8, 80, 16);
  FLblType.Caption := 'Tipo:';
  FLblType.Font.Style := [fsBold];

  FCbType := TComboBox.Create(Self);
  FCbType.Parent := FToolbar;
  FCbType.SetBounds(10, 28, 118, 24);
  FCbType.Style := csDropDownList;
  FCbType.Items.AddStrings(['Barras', 'Barras Horiz.', 'Linha', 'Pizza', 'Rosca', 'Mapa', 'Área', 'Dispersão']);
  FCbType.ItemIndex := 0;
  FCbType.OnChange := @ControlsChange;

  FLblCat := TLabel.Create(Self);
  FLblCat.Parent := FToolbar;
  FLblCat.SetBounds(134, 8, 140, 16);
  FLblCat.Caption := 'Categoria (Eixo X):';
  FLblCat.Font.Style := [fsBold];

  FCbCat := TComboBox.Create(Self);
  FCbCat.Parent := FToolbar;
  FCbCat.SetBounds(134, 28, 152, 24);
  FCbCat.Style := csDropDownList;
  FCbCat.OnChange := @ControlsChange;

  FLblVal := TLabel.Create(Self);
  FLblVal.Parent := FToolbar;
  FLblVal.SetBounds(292, 8, 140, 16);
  FLblVal.Caption := 'Valor (Eixo Y):';
  FLblVal.Font.Style := [fsBold];

  FCbVal := TComboBox.Create(Self);
  FCbVal.Parent := FToolbar;
  FCbVal.SetBounds(292, 28, 152, 24);
  FCbVal.Style := csDropDownList;
  FCbVal.OnChange := @ControlsChange;

  FLblAgg := TLabel.Create(Self);
  FLblAgg.Parent := FToolbar;
  FLblAgg.SetBounds(450, 8, 100, 16);
  FLblAgg.Caption := 'Agregação:';
  FLblAgg.Font.Style := [fsBold];

  FCbAgg := TComboBox.Create(Self);
  FCbAgg.Parent := FToolbar;
  FCbAgg.SetBounds(450, 28, 96, 24);
  FCbAgg.Style := csDropDownList;
  FCbAgg.Items.AddStrings(['Soma', 'Contagem', 'Média', 'Máximo', 'Mínimo']);
  FCbAgg.ItemIndex := 0;
  FCbAgg.OnChange := @ControlsChange;

  FLblTop := TLabel.Create(Self);
  FLblTop.Parent := FToolbar;
  FLblTop.SetBounds(552, 8, 70, 16);
  FLblTop.Caption := 'Exibir:';
  FLblTop.Font.Style := [fsBold];

  FCbTop := TComboBox.Create(Self);
  FCbTop.Parent := FToolbar;
  FCbTop.SetBounds(552, 28, 78, 24);
  FCbTop.Style := csDropDownList;
  FCbTop.Items.AddStrings(['Top 15', 'Top 30', 'Todos']);
  FCbTop.ItemIndex := 0;
  FCbTop.OnChange := @ControlsChange;

  FBtnRefresh := TButton.Create(Self);
  FBtnRefresh.Parent := FToolbar;
  FBtnRefresh.SetBounds(636, 27, 70, 26);
  FBtnRefresh.Caption := 'Atualizar';
  FBtnRefresh.OnClick := @BtnRefreshClick;

  FBtnExport := TButton.Create(Self);
  FBtnExport.Parent := FToolbar;
  FBtnExport.SetBounds(710, 27, 88, 26);
  FBtnExport.Caption := 'Exportar PNG';
  FBtnExport.OnClick := @BtnExportClick;

  FBtnPrint := TButton.Create(Self);
  FBtnPrint.Parent := FToolbar;
  FBtnPrint.SetBounds(802, 27, 74, 26);
  FBtnPrint.Caption := 'Imprimir...';
  FBtnPrint.OnClick := @BtnPrintClick;

  FBtnCustomize := TButton.Create(Self);
  FBtnCustomize.Parent := FToolbar;
  FBtnCustomize.SetBounds(880, 27, 94, 26);
  FBtnCustomize.Caption := 'Personalizar...';
  FBtnCustomize.OnClick := @BtnCustomizeClick;

  FBtnWizard := TButton.Create(Self);
  FBtnWizard.Parent := FToolbar;
  FBtnWizard.SetBounds(978, 27, 114, 26);
  FBtnWizard.Caption := 'Wizard Gráfico...';
  FBtnWizard.Font.Style := [fsBold];
  FBtnWizard.OnClick := @BtnWizardClick;

  FBtnPinChart := TButton.Create(Self);
  FBtnPinChart.Parent := FToolbar;
  FBtnPinChart.SetBounds(1098, 27, 134, 26);
  FBtnPinChart.Caption := '+ Fixar no Dashboard';
  FBtnPinChart.Font.Style := [fsBold];
  FBtnPinChart.OnClick := @BtnPinChartClick;

  FBtnPinKPI := TButton.Create(Self);
  FBtnPinKPI.Parent := FToolbar;
  FBtnPinKPI.SetBounds(1238, 27, 94, 26);
  FBtnPinKPI.Caption := '+ Fixar KPI';
  FBtnPinKPI.OnClick := @BtnPinKPIClick;

  FCanvas := TPaintBox.Create(Self);
  FCanvas.Parent := Self;
  FCanvas.Align := alClient;
  FCanvas.OnPaint := @CanvasPaint;
  FCanvas.OnMouseMove := @CanvasMouseMove;

  FMapView := TQueryMapPanel.Create(Self);
  FMapView.Parent := Self;
  FMapView.Align := alClient;
  FMapView.Visible := False;
end;

function TQueryChartPanel.DarkenColor(C: TColor; Factor: Double): TColor;
var
  R, G, B: Byte;
begin
  RedGreenBlue(ColorToRGB(C), R, G, B);
  R := Max(0, Min(255, Round(R * Factor)));
  G := Max(0, Min(255, Round(G * Factor)));
  B := Max(0, Min(255, Round(B * Factor)));
  Result := RGBToColor(R, G, B);
end;

function TQueryChartPanel.FormatLegendText(Pt: TQChartPoint; TotalVal: Double): string;
var
  Pct: Double;
begin
  if TotalVal <= 0 then TotalVal := 1;
  Pct := (Max(0, Pt.Value) / TotalVal) * 100.0;
  case FLegendStyle of
    1: Result := Format('%s (%.1f%%)', [Copy(Pt.LabelText, 1, 18), Pct]);
    2: Result := Copy(Pt.LabelText, 1, 22);
    3: Result := Format('%s: %s (%.1f%%)', [Copy(Pt.LabelText, 1, 14), FormatNum(Pt.Value), Pct]);
  else
    Result := Format('%s (%s)', [Copy(Pt.LabelText, 1, 16), FormatNum(Pt.Value)]);
  end;
end;

procedure TQueryChartPanel.DrawLegend(G: TCanvas; const LegR: TRect);
var
  I, N, XPos, YPos, ColW: Integer;
  Total: Double;
  Pt: TQChartPoint;
  Txt: string;
begin
  N := FPoints.Count;
  if (N = 0) or (FLegendPos = 2) then Exit;
  Total := 0;
  for I := 0 to N - 1 do
    Total := Total + Max(0, TQChartPoint(FPoints[I]).Value);

  G.Brush.Color := RGBToColor(248, 250, 252);
  G.Pen.Color := RGBToColor(203, 213, 225);
  G.RoundRect(LegR.Left, LegR.Top, LegR.Right, LegR.Bottom, 6, 6);

  G.Font.Name := FTitleFontName;
  G.Font.Size := 8;
  G.Font.Style := [];

  if FLegendPos = 0 then
  begin
    XPos := LegR.Left + 10;
    YPos := LegR.Top + 10;
    for I := 0 to N - 1 do
    begin
      if YPos + 18 > LegR.Bottom - 6 then Break;
      Pt := TQChartPoint(FPoints[I]);
      G.Brush.Color := PaletteColor(I);
      G.Pen.Color := G.Brush.Color;
      G.Rectangle(XPos, YPos + 2, XPos + 12, YPos + 14);
      G.Brush.Color := RGBToColor(248, 250, 252);
      G.Font.Color := RGBToColor(51, 65, 85);
      Txt := FormatLegendText(Pt, Total);
      G.TextOut(XPos + 18, YPos, Txt);
      Inc(YPos, 20);
    end;
  end
  else
  begin
    ColW := 185;
    XPos := LegR.Left + 10;
    YPos := LegR.Top + 8;
    for I := 0 to N - 1 do
    begin
      if XPos + ColW > LegR.Right - 6 then
      begin
        XPos := LegR.Left + 10;
        Inc(YPos, 20);
      end;
      if YPos + 16 > LegR.Bottom - 4 then Break;
      Pt := TQChartPoint(FPoints[I]);
      G.Brush.Color := PaletteColor(I);
      G.Pen.Color := G.Brush.Color;
      G.Rectangle(XPos, YPos + 2, XPos + 10, YPos + 12);
      G.Brush.Color := RGBToColor(248, 250, 252);
      G.Font.Color := RGBToColor(51, 65, 85);
      Txt := FormatLegendText(Pt, Total);
      G.TextOut(XPos + 14, YPos, Txt);
      Inc(XPos, ColW);
    end;
  end;
end;

function TQueryChartPanel.PaletteColor(Index: Integer): TColor;
begin
  Result := CHART_PALETTE[Index mod Length(CHART_PALETTE)];
end;

function TQueryChartPanel.FormatNum(V: Double): string;
begin
  if Abs(V - Round(V)) < 0.0001 then
    Result := FormatFloat('#,##0', V)
  else
    Result := FormatFloat('#,##0.##', V);
end;

procedure TQueryChartPanel.SetDashboardButtonsVisible(AVisible: Boolean);
begin
  if Assigned(FBtnPinChart) then FBtnPinChart.Visible := AVisible;
  if Assigned(FBtnPinKPI) then FBtnPinKPI.Visible := AVisible;
end;

procedure TQueryChartPanel.LoadFromDataSet(ADataSet: TDataSet; const ATitle: string; const ASQL: string);
begin
  FDataSet := ADataSet;
  FChartTitle := Trim(ATitle);
  if Trim(ASQL) <> '' then
    FCurrentSQL := Trim(ASQL);
  PopulateFieldCombos;
  RebuildSeries;
  if FCbType.ItemIndex = 5 then
    FMapView.LoadFromDataSet(FDataSet);
  FCanvas.Invalidate;
end;

procedure TQueryChartPanel.PopulateFieldCombos;
var
  I, FirstStrIdx, FirstNumIdx: Integer;
  F: TField;
begin
  FCbCat.Items.BeginUpdate;
  FCbVal.Items.BeginUpdate;
  try
    FCbCat.Items.Clear;
    FCbVal.Items.Clear;
    FCbVal.Items.Add('(Contagem de registros)');
    if (FDataSet = nil) or not FDataSet.Active then Exit;

    FirstStrIdx := -1;
    FirstNumIdx := -1;
    for I := 0 to FDataSet.FieldCount - 1 do
    begin
      F := FDataSet.Fields[I];
      FCbCat.Items.Add(F.FieldName);
      if F.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency,
                        ftBCD, ftLargeint, ftFMTBcd] then
      begin
        FCbVal.Items.Add(F.FieldName);
        if FirstNumIdx < 0 then
          FirstNumIdx := FCbVal.Items.Count - 1;
      end
      else if FirstStrIdx < 0 then
        FirstStrIdx := I;
    end;

    if FCbCat.Items.Count > 0 then
    begin
      if FirstStrIdx >= 0 then FCbCat.ItemIndex := FirstStrIdx
      else FCbCat.ItemIndex := 0;
    end;
    if FirstNumIdx >= 0 then
      FCbVal.ItemIndex := FirstNumIdx
    else
    begin
      FCbVal.ItemIndex := 0;
      FCbAgg.ItemIndex := 1; // Contagem
    end;
  finally
    FCbCat.Items.EndUpdate;
    FCbVal.Items.EndUpdate;
  end;
end;

procedure TQueryChartPanel.RebuildSeries;
var
  Bm: TBookmark;
  CatField, ValField: TField;
  CatText: string;
  ValNum: Double;
  CountOnly: Boolean;
  Agg: TQChartAgg;
  I, MaxItems: Integer;
  Pt, FoundPt: TQChartPoint;
begin
  FPoints.Clear;
  FHoverIndex := -1;
  if (FDataSet = nil) or not FDataSet.Active or FDataSet.IsEmpty then Exit;
  if FCbCat.ItemIndex < 0 then Exit;

  CatField := FDataSet.FindField(FCbCat.Text);
  if CatField = nil then Exit;

  CountOnly := (FCbVal.ItemIndex <= 0);
  if CountOnly then
    ValField := nil
  else
    ValField := FDataSet.FindField(FCbVal.Text);

  case FCbAgg.ItemIndex of
    1: Agg := qcaCount;
    2: Agg := qcaAvg;
    3: Agg := qcaMax;
    4: Agg := qcaMin;
  else
    Agg := qcaSum;
  end;
  if CountOnly then Agg := qcaCount;

  FDataSet.DisableControls;
  Bm := FDataSet.GetBookmark;
  try
    FDataSet.First;
    while not FDataSet.EOF do
    begin
      CatText := Trim(CatField.AsString);
      if CatText = '' then CatText := '(vazio)';

      if CountOnly or (ValField = nil) or ValField.IsNull then
        ValNum := 1
      else
      begin
        try
          ValNum := ValField.AsFloat;
        except
          ValNum := 0;
        end;
      end;

      FoundPt := nil;
      for I := 0 to FPoints.Count - 1 do
      begin
        Pt := TQChartPoint(FPoints[I]);
        if SameText(Pt.LabelText, CatText) then
        begin
          FoundPt := Pt;
          Break;
        end;
      end;

      if FoundPt = nil then
      begin
        FoundPt := TQChartPoint.Create;
        FoundPt.LabelText := CatText;
        FoundPt.Count := 1;
        if Agg = qcaCount then
          FoundPt.Value := 1
        else
          FoundPt.Value := ValNum;
        FPoints.Add(FoundPt);
      end
      else
      begin
        Inc(FoundPt.Count);
        case Agg of
          qcaSum, qcaAvg: FoundPt.Value := FoundPt.Value + ValNum;
          qcaCount: FoundPt.Value := FoundPt.Count;
          qcaMax: if ValNum > FoundPt.Value then FoundPt.Value := ValNum;
          qcaMin: if ValNum < FoundPt.Value then FoundPt.Value := ValNum;
        end;
      end;

      FDataSet.Next;
    end;

    if Agg = qcaAvg then
      for I := 0 to FPoints.Count - 1 do
      begin
        Pt := TQChartPoint(FPoints[I]);
        if Pt.Count > 0 then
          Pt.Value := Pt.Value / Pt.Count;
      end;
  finally
    if FDataSet.BookmarkValid(Bm) then
      FDataSet.GotoBookmark(Bm);
    FDataSet.FreeBookmark(Bm);
    FDataSet.EnableControls;
  end;

  case FCbTop.ItemIndex of
    0: MaxItems := 15;
    1: MaxItems := 30;
  else
    MaxItems := FPoints.Count;
  end;
  while FPoints.Count > MaxItems do
    FPoints.Delete(FPoints.Count - 1);
end;

procedure TQueryChartPanel.ControlsChange(Sender: TObject);
var
  IsMap: Boolean;
begin
  IsMap := (FCbType.ItemIndex = 5);
  FMapView.Visible := IsMap;
  FCanvas.Visible := not IsMap;
  FCbCat.Enabled := not IsMap;
  FCbVal.Enabled := not IsMap;
  FCbAgg.Enabled := not IsMap;
  FCbTop.Enabled := not IsMap;
  if IsMap then
    FMapView.LoadFromDataSet(FDataSet)
  else
  begin
    RebuildSeries;
    FCanvas.Invalidate;
  end;
end;

procedure TQueryChartPanel.BtnRefreshClick(Sender: TObject);
begin
  if FCbType.ItemIndex = 5 then
    FMapView.LoadFromDataSet(FDataSet)
  else
  begin
    RebuildSeries;
    FCanvas.Invalidate;
  end;
end;

procedure TQueryChartPanel.BtnExportClick(Sender: TObject);
var
  Dlg: TSaveDialog;
  PNG: TPortableNetworkGraphic;
begin
  if FPoints.Count = 0 then
  begin
    ShowMessage('Execute uma consulta com resultados antes de exportar o gráfico.');
    Exit;
  end;
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Title := 'Exportar Gráfico';
    Dlg.Filter := 'Imagem PNG (*.png)|*.png';
    Dlg.DefaultExt := 'png';
    Dlg.FileName := 'grafico_querybuilder.png';
    if Dlg.Execute then
    begin
      CanvasPaint(Self);
      PNG := TPortableNetworkGraphic.Create;
      try
        PNG.Assign(FBuffer);
        PNG.SaveToFile(Dlg.FileName);
        ShowMessage('Gráfico salvo em: ' + Dlg.FileName);
      finally
        PNG.Free;
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TQueryChartPanel.BtnPrintClick(Sender: TObject);
var
  Dlg: TPrintDialog;
  PageW, PageH, Margin, TargetW, TargetH, DestX, DestY: Integer;
  Scale: Double;
begin
  if (FCbType.ItemIndex <> 5) and (FPoints.Count = 0) then
  begin
    ShowMessage('Execute uma consulta com resultados antes de imprimir o gráfico.');
    Exit;
  end;
  Dlg := TPrintDialog.Create(Self);
  try
    if Dlg.Execute then
    begin
      CanvasPaint(Self);
      if (FBuffer.Width <= 0) or (FBuffer.Height <= 0) then Exit;
      Printer.Title := 'Gráfico MQuery2 - ' + FChartTitle;
      Printer.BeginDoc;
      try
        PageW := Printer.PageWidth;
        PageH := Printer.PageHeight;
        Margin := Min(PageW, PageH) div 16;
        Scale := Min((PageW - 2 * Margin) / FBuffer.Width, (PageH - 2 * Margin) / FBuffer.Height);
        TargetW := Round(FBuffer.Width * Scale);
        TargetH := Round(FBuffer.Height * Scale);
        DestX := (PageW - TargetW) div 2;
        DestY := Margin;
        Printer.Canvas.StretchDraw(Rect(DestX, DestY, DestX + TargetW, DestY + TargetH), FBuffer);
      finally
        Printer.EndDoc;
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TQueryChartPanel.BtnCustomizeClick(Sender: TObject);
var
  Frm: TForm;
  L1, L2, L3, L4, L5, L6: TLabel;
  EdTitle, EdScale: TEdit;
  CbFont, CbSize, CbLegPos, CbLegStyle: TComboBox;
  Chk3D: TCheckBox;
  BtnOk, BtnCancel: TButton;
begin
  Frm := TForm.CreateNew(Self, 1);
  try
    Frm.Caption := 'Personalizar Gráfico e Impressão';
    Frm.Width := 460;
    Frm.Height := 390;
    Frm.Position := poScreenCenter;
    Frm.BorderStyle := bsDialog;

    L1 := TLabel.Create(Frm); L1.Parent := Frm; L1.SetBounds(18, 16, 200, 16);
    L1.Caption := 'Título do Gráfico:'; L1.Font.Style := [fsBold];
    EdTitle := TEdit.Create(Frm); EdTitle.Parent := Frm; EdTitle.SetBounds(18, 36, 416, 24);
    if FChartTitle <> '' then EdTitle.Text := FChartTitle
    else EdTitle.Text := Format('%s por %s', [FCbVal.Text, FCbCat.Text]);

    L2 := TLabel.Create(Frm); L2.Parent := Frm; L2.SetBounds(18, 72, 180, 16);
    L2.Caption := 'Tipo de Letra (Fonte):'; L2.Font.Style := [fsBold];
    CbFont := TComboBox.Create(Frm); CbFont.Parent := Frm; CbFont.SetBounds(18, 92, 230, 24);
    CbFont.Style := csDropDownList;
    CbFont.Items.AddStrings(['Segoe UI', 'Arial', 'Calibri', 'Tahoma', 'Verdana', 'Times New Roman']);
    CbFont.ItemIndex := Max(0, CbFont.Items.IndexOf(FTitleFontName));

    L3 := TLabel.Create(Frm); L3.Parent := Frm; L3.SetBounds(264, 72, 160, 16);
    L3.Caption := 'Tamanho da Fonte:'; L3.Font.Style := [fsBold];
    CbSize := TComboBox.Create(Frm); CbSize.Parent := Frm; CbSize.SetBounds(264, 92, 170, 24);
    CbSize.Style := csDropDownList;
    CbSize.Items.AddStrings(['9', '10', '11', '12', '14', '16', '18', '20', '24']);
    CbSize.ItemIndex := Max(0, CbSize.Items.IndexOf(IntToStr(FTitleFontSize)));

    Chk3D := TCheckBox.Create(Frm); Chk3D.Parent := Frm; Chk3D.SetBounds(18, 130, 250, 22);
    Chk3D.Caption := 'Exibir Gráfico em 3D';
    Chk3D.Font.Style := [fsBold];
    Chk3D.Checked := FIs3D;

    L4 := TLabel.Create(Frm); L4.Parent := Frm; L4.SetBounds(18, 164, 180, 16);
    L4.Caption := 'Posição da Legenda:'; L4.Font.Style := [fsBold];
    CbLegPos := TComboBox.Create(Frm); CbLegPos.Parent := Frm; CbLegPos.SetBounds(18, 184, 200, 24);
    CbLegPos.Style := csDropDownList;
    CbLegPos.Items.AddStrings(['À Direita', 'Abaixo', 'Ocultar Legenda']);
    CbLegPos.ItemIndex := Max(0, Min(2, FLegendPos));

    L5 := TLabel.Create(Frm); L5.Parent := Frm; L5.SetBounds(234, 164, 200, 16);
    L5.Caption := 'Tipo / Formato da Legenda:'; L5.Font.Style := [fsBold];
    CbLegStyle := TComboBox.Create(Frm); CbLegStyle.Parent := Frm; CbLegStyle.SetBounds(234, 184, 200, 24);
    CbLegStyle.Style := csDropDownList;
    CbLegStyle.Items.AddStrings(['Nome + Valor', 'Nome + %', 'Somente Nome', 'Nome + Valor + %']);
    CbLegStyle.ItemIndex := Max(0, Min(3, FLegendStyle));

    L6 := TLabel.Create(Frm); L6.Parent := Frm; L6.SetBounds(18, 222, 260, 16);
    L6.Caption := 'Tamanho do Gráfico (50% a 140%):'; L6.Font.Style := [fsBold];
    EdScale := TEdit.Create(Frm); EdScale.Parent := Frm; EdScale.SetBounds(18, 242, 100, 24);
    EdScale.Text := IntToStr(FChartScalePct);

    BtnOk := TButton.Create(Frm); BtnOk.Parent := Frm; BtnOk.SetBounds(238, 304, 96, 30);
    BtnOk.Caption := 'Aplicar'; BtnOk.Default := True; BtnOk.ModalResult := mrOk;

    BtnCancel := TButton.Create(Frm); BtnCancel.Parent := Frm; BtnCancel.SetBounds(340, 304, 94, 30);
    BtnCancel.Caption := 'Cancelar'; BtnCancel.Cancel := True; BtnCancel.ModalResult := mrCancel;

    if Frm.ShowModal = mrOk then
    begin
      FChartTitle := Trim(EdTitle.Text);
      if CbFont.ItemIndex >= 0 then FTitleFontName := CbFont.Text;
      if CbSize.ItemIndex >= 0 then FTitleFontSize := StrToIntDef(CbSize.Text, 12);
      FIs3D := Chk3D.Checked;
      if CbLegPos.ItemIndex >= 0 then FLegendPos := CbLegPos.ItemIndex;
      if CbLegStyle.ItemIndex >= 0 then FLegendStyle := CbLegStyle.ItemIndex;
      FChartScalePct := Max(50, Min(140, StrToIntDef(Trim(EdScale.Text), 100)));
      FCanvas.Invalidate;
    end;
  finally
    Frm.Free;
  end;
end;

type
  TWizBridge = class
  public
    Pages: TPageControl;
    StepsList: TListBox;
    BtnPrev, BtnNext, BtnFinish: TButton;
    LbType: TListBox;
    PreviewBox: TPaintBox;
    LblTypeDesc: TLabel;
    CbCat, CbVal, CbAgg, CbTop: TComboBox;
    EdTitle: TEdit;
    MemoSummary: TMemo;
    procedure UpdateNav;
    procedure SyncStepsList;
    procedure StepsClick(Sender: TObject);
    procedure PrevClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure TypeSelect(Sender: TObject);
    procedure PreviewPaint(Sender: TObject);
    procedure AnyChange(Sender: TObject);
  end;

procedure TWizBridge.SyncStepsList;
begin
  if (StepsList <> nil) and (Pages.ActivePageIndex >= 0) and (Pages.ActivePageIndex < StepsList.Items.Count) then
    StepsList.ItemIndex := Pages.ActivePageIndex;
end;

procedure TWizBridge.UpdateNav;
var
  P, TIdx: Integer;
const
  TYPE_DESCS: array[0..7] of string = (
    'Colunas (Barras Verticais): compara valores ou contagens entre categorias lado a lado.',
    'Barras Horizontais: ideal para rankings ou categorias com nomes longos.',
    'Linhas: compara valores ao longo do tempo ou sequência, destacando tendências.',
    'Pizza: mostra a participação percentual (%) de cada categoria no total (ideal até 8 itens).',
    'Rosca: variação moderna do gráfico de pizza para proporções em porcentagem.',
    'Mapa (Coordenadas): plota pontos geográficos usando colunas de Latitude e Longitude.',
    'Área: destaca o volume acumulado ao longo de uma sequência ou período.',
    'Dispersão (XY): exibe a distribuição dos pontos entre categoria e valor.'
  );
begin
  P := Pages.ActivePageIndex;
  SyncStepsList;
  BtnPrev.Enabled := P > 0;
  BtnNext.Enabled := P < 2;
  TIdx := Max(0, Min(7, LbType.ItemIndex));
  if LblTypeDesc <> nil then
    LblTypeDesc.Caption := TYPE_DESCS[TIdx];
  if PreviewBox <> nil then
    PreviewBox.Invalidate;

  if (EdTitle <> nil) and (Trim(EdTitle.Text) = '') then
    EdTitle.Text := CbVal.Text + ' por ' + CbCat.Text;

  if (P = 2) and (MemoSummary <> nil) then
  begin
    MemoSummary.Lines.Clear;
    MemoSummary.Lines.Add('Resumo da Análise:');
    MemoSummary.Lines.Add('');
    MemoSummary.Lines.Add('• Título: ' + EdTitle.Text);
    MemoSummary.Lines.Add('• Tipo: ' + LbType.Items[TIdx]);
    if TIdx = 5 then
      MemoSummary.Lines.Add('• Dados: plotagem automática por Latitude / Longitude')
    else
    begin
      MemoSummary.Lines.Add('• Categoria (Eixo X): ' + CbCat.Text);
      MemoSummary.Lines.Add('• Valor (Eixo Y): ' + CbVal.Text);
      MemoSummary.Lines.Add('• Agregação: ' + CbAgg.Text);
      MemoSummary.Lines.Add('• Exibir: ' + CbTop.Text);
    end;
  end;

  CbCat.Enabled := (TIdx <> 5);
  CbVal.Enabled := (TIdx <> 5);
  CbAgg.Enabled := (TIdx <> 5);
  CbTop.Enabled := (TIdx <> 5);
end;

procedure TWizBridge.StepsClick(Sender: TObject);
begin
  if (StepsList.ItemIndex >= 0) and (StepsList.ItemIndex <= 2) then
  begin
    Pages.ActivePageIndex := StepsList.ItemIndex;
    UpdateNav;
  end;
end;

procedure TWizBridge.PrevClick(Sender: TObject);
begin
  if Pages.ActivePageIndex > 0 then
  begin
    Pages.ActivePageIndex := Pages.ActivePageIndex - 1;
    UpdateNav;
  end;
end;

procedure TWizBridge.NextClick(Sender: TObject);
begin
  if Pages.ActivePageIndex < 2 then
  begin
    Pages.ActivePageIndex := Pages.ActivePageIndex + 1;
    UpdateNav;
  end;
end;

procedure TWizBridge.TypeSelect(Sender: TObject);
begin
  UpdateNav;
end;

procedure TWizBridge.PreviewPaint(Sender: TObject);
var
  G: TCanvas;
  W, H, TIdx, CX, CY, R: Integer;
  Pts: array[0..4] of TPoint;
begin
  G := PreviewBox.Canvas;
  W := PreviewBox.Width;
  H := PreviewBox.Height;
  G.Brush.Color := clWhite;
  G.Pen.Color := RGBToColor(203, 213, 225);
  G.Rectangle(0, 0, W, H);

  TIdx := LbType.ItemIndex;
  G.Pen.Color := RGBToColor(100, 116, 139);
  case TIdx of
    0: // Colunas
      begin
        G.Line(20, H - 20, W - 16, H - 20);
        G.Line(20, 16, 20, H - 20);
        G.Brush.Color := $FF9933; G.Rectangle(32, H - 80, 54, H - 20);
        G.Brush.Color := $55C522; G.Rectangle(66, H - 120, 88, H - 20);
        G.Brush.Color := $0B9EF5; G.Rectangle(100, H - 65, 122, H - 20);
        G.Brush.Color := $4444EF; G.Rectangle(134, H - 105, 156, H - 20);
        G.Brush.Color := $F65C8B; G.Rectangle(168, H - 90, 190, H - 20);
      end;
    1: // Barras Horiz.
      begin
        G.Line(24, 16, 24, H - 20);
        G.Line(24, H - 20, W - 16, H - 20);
        G.Brush.Color := $FF9933; G.Rectangle(24, 24, 150, 42);
        G.Brush.Color := $55C522; G.Rectangle(24, 50, 195, 68);
        G.Brush.Color := $0B9EF5; G.Rectangle(24, 76, 115, 94);
        G.Brush.Color := $4444EF; G.Rectangle(24, 102, 170, 120);
      end;
    2: // Linhas
      begin
        G.Line(20, H - 20, W - 16, H - 20);
        G.Line(20, 16, 20, H - 20);
        Pts[0] := Point(28, H - 40); Pts[1] := Point(72, H - 95);
        Pts[2] := Point(116, H - 65); Pts[3] := Point(160, H - 120);
        Pts[4] := Point(204, H - 105);
        G.Pen.Color := RGBToColor(37, 99, 235); G.Pen.Width := 2;
        G.PolyLine(Pts);
        G.Pen.Width := 1;
        G.Brush.Color := RGBToColor(37, 99, 235);
        for CX := 0 to 4 do G.Ellipse(Pts[CX].X - 4, Pts[CX].Y - 4, Pts[CX].X + 4, Pts[CX].Y + 4);
      end;
    3, 4: // Pizza / Rosca
      begin
        CX := W div 2; CY := H div 2; R := Min(W, H) div 2 - 18;
        G.Brush.Color := $FF9933; G.Pie(CX - R, CY - R, CX + R, CY + R, CX + R, CY, CX, CY - R);
        G.Brush.Color := $55C522; G.Pie(CX - R, CY - R, CX + R, CY + R, CX, CY - R, CX - R, CY);
        G.Brush.Color := $0B9EF5; G.Pie(CX - R, CY - R, CX + R, CY + R, CX - R, CY, CX + R, CY);
        if TIdx = 4 then
        begin
          G.Brush.Color := clWhite;
          G.Ellipse(CX - R div 2, CY - R div 2, CX + R div 2, CY + R div 2);
        end;
      end;
    5: // Mapa
      begin
        G.Brush.Color := RGBToColor(226, 232, 240);
        G.Rectangle(12, 12, W - 12, H - 12);
        G.Brush.Color := RGBToColor(34, 197, 94); G.Ellipse(48, 45, 64, 61);
        G.Brush.Color := RGBToColor(234, 179, 8); G.Ellipse(110, 82, 132, 104);
        G.Brush.Color := RGBToColor(239, 68, 68); G.Ellipse(162, 42, 190, 70);
      end;
    6: // Area
      begin
        G.Line(20, H - 20, W - 16, H - 20);
        G.Line(20, 16, 20, H - 20);
        G.Brush.Color := RGBToColor(191, 219, 254);
        G.Pen.Color := RGBToColor(37, 99, 235);
        G.Polygon([Point(24, H - 20), Point(24, H - 45), Point(78, H - 100), Point(132, H - 70), Point(194, H - 125), Point(194, H - 20)]);
      end;
    7: // Dispersao
      begin
        G.Line(20, H - 20, W - 16, H - 20);
        G.Line(20, 16, 20, H - 20);
        G.Brush.Color := $FF9933; G.Ellipse(38, H - 52, 50, H - 40);
        G.Brush.Color := $55C522; G.Ellipse(78, H - 96, 90, H - 84);
        G.Brush.Color := $0B9EF5; G.Ellipse(118, H - 70, 130, H - 58);
        G.Brush.Color := $4444EF; G.Ellipse(158, H - 122, 170, H - 110);
        G.Brush.Color := $F65C8B; G.Ellipse(184, H - 86, 196, H - 74);
      end;
  end;
end;

procedure TWizBridge.AnyChange(Sender: TObject);
begin
  UpdateNav;
end;

procedure TQueryChartPanel.BtnWizardClick(Sender: TObject);
var
  Frm: TForm;
  Bridge: TWizBridge;
  Head, Foot, LeftSteps: TPanel;
  LTitle, LSub, LStepsHdr, LRec, L1, L2, L3, L4, L5: TLabel;
  Tab1, Tab2, Tab3: TTabSheet;
  MemoCols: TMemo;
  Bm: TBookmark;
  I, RowCount, BestCatIdx, BestValIdx, BestTypeIdx, BestAggIdx: Integer;
  HasLat, HasLon, HasDate: Boolean;
  F: TField;
  LN, RecReason: string;
  DistList: array of TStringList;
begin
  if (FDataSet = nil) or (not FDataSet.Active) or FDataSet.IsEmpty then
  begin
    ShowMessage('Execute uma consulta com resultados antes de abrir o Assistente de Gráficos.');
    Exit;
  end;

  SetLength(DistList, FDataSet.FieldCount);
  for I := 0 to FDataSet.FieldCount - 1 do
  begin
    DistList[I] := TStringList.Create;
    DistList[I].Sorted := True;
    DistList[I].Duplicates := dupIgnore;
  end;

  HasLat := False;
  HasLon := False;
  HasDate := False;
  RowCount := 0;
  FDataSet.DisableControls;
  Bm := FDataSet.GetBookmark;
  try
    FDataSet.First;
    while (not FDataSet.EOF) and (RowCount < 200) do
    begin
      Inc(RowCount);
      for I := 0 to FDataSet.FieldCount - 1 do
        if not FDataSet.Fields[I].IsNull then
          DistList[I].Add(Trim(FDataSet.Fields[I].AsString));
      FDataSet.Next;
    end;
  finally
    if FDataSet.BookmarkValid(Bm) then FDataSet.GotoBookmark(Bm);
    FDataSet.FreeBookmark(Bm);
    FDataSet.EnableControls;
  end;

  BestCatIdx := 0;
  BestValIdx := 0;
  BestTypeIdx := 0;
  BestAggIdx := 1;
  RecReason := 'Colunas (Barras Verticais) recomendado para comparação geral entre categorias.';

  for I := 0 to FDataSet.FieldCount - 1 do
  begin
    F := FDataSet.Fields[I];
    LN := LowerCase(F.FieldName);
    if (LN = 'lat') or (Pos('latitude', LN) > 0) then HasLat := True;
    if (LN = 'lon') or (LN = 'lng') or (Pos('longitude', LN) > 0) then HasLon := True;
    if F.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] then HasDate := True;
  end;

  for I := 0 to FDataSet.FieldCount - 1 do
  begin
    F := FDataSet.Fields[I];
    if (F.DataType in [ftString, ftWideString, ftMemo]) and (DistList[I].Count >= 2) and (DistList[I].Count <= 15) then
    begin
      BestCatIdx := I;
      Break;
    end;
  end;
  if BestCatIdx = 0 then
    for I := 0 to FDataSet.FieldCount - 1 do
      if FDataSet.Fields[I].DataType in [ftString, ftWideString, ftMemo] then
      begin
        BestCatIdx := I;
        Break;
      end;

  for I := 0 to FDataSet.FieldCount - 1 do
  begin
    F := FDataSet.Fields[I];
    LN := LowerCase(F.FieldName);
    if (F.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeint, ftFMTBcd]) and
       (LN <> 'id') and (Pos('id_', LN) <> 1) then
    begin
      BestValIdx := FCbVal.Items.IndexOf(F.FieldName);
      if BestValIdx > 0 then
      begin
        BestAggIdx := 0;
        Break;
      end;
    end;
  end;

  if HasLat and HasLon then
  begin
    BestTypeIdx := 5;
    RecReason := 'Mapa recomendado: foram detectadas colunas de Latitude e Longitude.';
  end
  else if (BestCatIdx < Length(DistList)) and (DistList[BestCatIdx].Count >= 2) and (DistList[BestCatIdx].Count <= 7) then
  begin
    BestTypeIdx := 3;
    RecReason := Format('Pizza recomendada: "%s" possui %d categorias distintas (ideal para proporção %%).',
      [FDataSet.Fields[BestCatIdx].FieldName, DistList[BestCatIdx].Count]);
  end
  else if HasDate then
  begin
    BestTypeIdx := 2;
    RecReason := 'Linhas recomendado: foi detectada coluna de Data/Hora para análise de tendência.';
  end
  else if (BestCatIdx < Length(DistList)) and (DistList[BestCatIdx].Count > 10) then
  begin
    BestTypeIdx := 1;
    RecReason := Format('Barras Horizontais recomendadas: "%s" possui %d categorias.',
      [FDataSet.Fields[BestCatIdx].FieldName, DistList[BestCatIdx].Count]);
  end;

  Frm := TForm.CreateNew(Self, 1);
  Bridge := TWizBridge.Create;
  try
    Frm.Caption := 'Assistente de Gráficos (Chart Wizard)';
    Frm.Width := 760;
    Frm.Height := 510;
    Frm.Position := poScreenCenter;
    Frm.BorderStyle := bsDialog;

    Head := TPanel.Create(Frm);
    Head.Parent := Frm;
    Head.Align := alTop;
    Head.Height := 54;
    Head.BevelOuter := bvNone;
    Head.Color := RGBToColor(30, 58, 138);

    LTitle := TLabel.Create(Head);
    LTitle.Parent := Head;
    LTitle.SetBounds(16, 8, 540, 20);
    LTitle.Caption := 'Chart Wizard — Assistente de Análise de Dados';
    LTitle.Font.Size := 12;
    LTitle.Font.Style := [fsBold];
    LTitle.Font.Color := clWhite;

    LSub := TLabel.Create(Head);
    LSub.Parent := Head;
    LSub.SetBounds(16, 30, 680, 16);
    LSub.Caption := Format('Dataset analisado: %d registros (amostra) e %d colunas disponíveis.', [RowCount, FDataSet.FieldCount]);
    LSub.Font.Color := RGBToColor(219, 234, 254);

    Foot := TPanel.Create(Frm);
    Foot.Parent := Frm;
    Foot.Align := alBottom;
    Foot.Height := 48;
    Foot.BevelOuter := bvLowered;

    Bridge.BtnPrev := TButton.Create(Foot);
    Bridge.BtnPrev.Parent := Foot;
    Bridge.BtnPrev.SetBounds(318, 10, 100, 28);
    Bridge.BtnPrev.Caption := '<< Voltar';
    Bridge.BtnPrev.OnClick := @Bridge.PrevClick;

    Bridge.BtnNext := TButton.Create(Foot);
    Bridge.BtnNext.Parent := Foot;
    Bridge.BtnNext.SetBounds(424, 10, 108, 28);
    Bridge.BtnNext.Caption := 'Avançar >>';
    Bridge.BtnNext.OnClick := @Bridge.NextClick;

    Bridge.BtnFinish := TButton.Create(Foot);
    Bridge.BtnFinish.Parent := Foot;
    Bridge.BtnFinish.SetBounds(538, 10, 106, 28);
    Bridge.BtnFinish.Caption := 'Concluir';
    Bridge.BtnFinish.Font.Style := [fsBold];
    Bridge.BtnFinish.ModalResult := mrOk;

    with TButton.Create(Foot) do
    begin
      Parent := Foot;
      SetBounds(650, 10, 94, 28);
      Caption := 'Cancelar';
      ModalResult := mrCancel;
      Cancel := True;
    end;

    LeftSteps := TPanel.Create(Frm);
    LeftSteps.Parent := Frm;
    LeftSteps.Align := alLeft;
    LeftSteps.Width := 185;
    LeftSteps.BevelOuter := bvLowered;
    LeftSteps.Color := RGBToColor(248, 250, 252);

    LStepsHdr := TLabel.Create(LeftSteps);
    LStepsHdr.Parent := LeftSteps;
    LStepsHdr.SetBounds(12, 12, 160, 18);
    LStepsHdr.Caption := 'Etapas (Steps)';
    LStepsHdr.Font.Style := [fsBold];

    Bridge.StepsList := TListBox.Create(LeftSteps);
    Bridge.StepsList.Parent := LeftSteps;
    Bridge.StepsList.SetBounds(10, 36, 165, 110);
    Bridge.StepsList.BorderStyle := bsNone;
    Bridge.StepsList.Color := RGBToColor(248, 250, 252);
    Bridge.StepsList.Items.AddStrings([
      '1. Tipo de Gráfico',
      '2. Dados e Série',
      '3. Elementos do Gráfico'
    ]);
    Bridge.StepsList.OnClick := @Bridge.StepsClick;

    Bridge.Pages := TPageControl.Create(Frm);
    Bridge.Pages.Parent := Frm;
    Bridge.Pages.Align := alClient;
    Bridge.Pages.ShowTabs := False;

    Tab1 := TTabSheet.Create(Bridge.Pages); Tab1.PageControl := Bridge.Pages;
    Tab2 := TTabSheet.Create(Bridge.Pages); Tab2.PageControl := Bridge.Pages;
    Tab3 := TTabSheet.Create(Bridge.Pages); Tab3.PageControl := Bridge.Pages;

    LRec := TLabel.Create(Tab1);
    LRec.Parent := Tab1;
    LRec.SetBounds(12, 10, 540, 28);
    LRec.WordWrap := True;
    LRec.Caption := 'Sugestão automática: ' + RecReason;
    LRec.Font.Style := [fsBold];
    LRec.Font.Color := RGBToColor(21, 128, 61);

    Bridge.LbType := TListBox.Create(Tab1);
    Bridge.LbType.Parent := Tab1;
    Bridge.LbType.SetBounds(12, 46, 220, 200);
    Bridge.LbType.Items.AddStrings([
      'Colunas (Barras Verticais)',
      'Barras Horizontais',
      'Linhas',
      'Pizza',
      'Rosca',
      'Mapa (Coordenadas)',
      'Área',
      'Dispersão (XY)'
    ]);
    Bridge.LbType.ItemIndex := BestTypeIdx;
    Bridge.LbType.OnClick := @Bridge.TypeSelect;

    Bridge.PreviewBox := TPaintBox.Create(Tab1);
    Bridge.PreviewBox.Parent := Tab1;
    Bridge.PreviewBox.SetBounds(244, 46, 300, 150);
    Bridge.PreviewBox.OnPaint := @Bridge.PreviewPaint;

    Bridge.LblTypeDesc := TLabel.Create(Tab1);
    Bridge.LblTypeDesc.Parent := Tab1;
    Bridge.LblTypeDesc.SetBounds(244, 204, 300, 44);
    Bridge.LblTypeDesc.WordWrap := True;

    MemoCols := TMemo.Create(Tab1);
    MemoCols.Parent := Tab1;
    MemoCols.SetBounds(12, 256, 532, 130);
    MemoCols.ReadOnly := True;
    MemoCols.ScrollBars := ssVertical;
    MemoCols.Lines.Add('Colunas detectadas no dataset:');
    for I := 0 to FDataSet.FieldCount - 1 do
      MemoCols.Lines.Add(Format('  • %s (%d valores distintos na amostra)', [FDataSet.Fields[I].FieldName, DistList[I].Count]));

    L1 := TLabel.Create(Tab2); L1.Parent := Tab2; L1.SetBounds(20, 20, 320, 18);
    L1.Caption := 'Categoria / Agrupamento (Eixo X):'; L1.Font.Style := [fsBold];
    Bridge.CbCat := TComboBox.Create(Tab2); Bridge.CbCat.Parent := Tab2;
    Bridge.CbCat.SetBounds(20, 42, 360, 26); Bridge.CbCat.Style := csDropDownList;
    Bridge.CbCat.Items.Assign(FCbCat.Items);
    Bridge.CbCat.ItemIndex := BestCatIdx;
    Bridge.CbCat.OnChange := @Bridge.AnyChange;

    L2 := TLabel.Create(Tab2); L2.Parent := Tab2; L2.SetBounds(20, 86, 320, 18);
    L2.Caption := 'Medida / Valor (Eixo Y):'; L2.Font.Style := [fsBold];
    Bridge.CbVal := TComboBox.Create(Tab2); Bridge.CbVal.Parent := Tab2;
    Bridge.CbVal.SetBounds(20, 108, 360, 26); Bridge.CbVal.Style := csDropDownList;
    Bridge.CbVal.Items.Assign(FCbVal.Items);
    Bridge.CbVal.ItemIndex := BestValIdx;
    Bridge.CbVal.OnChange := @Bridge.AnyChange;

    L3 := TLabel.Create(Tab2); L3.Parent := Tab2; L3.SetBounds(20, 152, 320, 18);
    L3.Caption := 'Agregação / Cálculo:'; L3.Font.Style := [fsBold];
    Bridge.CbAgg := TComboBox.Create(Tab2); Bridge.CbAgg.Parent := Tab2;
    Bridge.CbAgg.SetBounds(20, 174, 240, 26); Bridge.CbAgg.Style := csDropDownList;
    Bridge.CbAgg.Items.Assign(FCbAgg.Items);
    Bridge.CbAgg.ItemIndex := BestAggIdx;
    Bridge.CbAgg.OnChange := @Bridge.AnyChange;

    L4 := TLabel.Create(Tab2); L4.Parent := Tab2; L4.SetBounds(20, 218, 320, 18);
    L4.Caption := 'Quantidade de itens a exibir:'; L4.Font.Style := [fsBold];
    Bridge.CbTop := TComboBox.Create(Tab2); Bridge.CbTop.Parent := Tab2;
    Bridge.CbTop.SetBounds(20, 240, 240, 26); Bridge.CbTop.Style := csDropDownList;
    Bridge.CbTop.Items.Assign(FCbTop.Items);
    Bridge.CbTop.ItemIndex := 0;
    Bridge.CbTop.OnChange := @Bridge.AnyChange;

    L5 := TLabel.Create(Tab3); L5.Parent := Tab3; L5.SetBounds(20, 20, 320, 18);
    L5.Caption := 'Título do Gráfico:'; L5.Font.Style := [fsBold];
    Bridge.EdTitle := TEdit.Create(Tab3); Bridge.EdTitle.Parent := Tab3;
    Bridge.EdTitle.SetBounds(20, 42, 460, 26);
    Bridge.EdTitle.Text := FChartTitle;

    Bridge.MemoSummary := TMemo.Create(Tab3);
    Bridge.MemoSummary.Parent := Tab3;
    Bridge.MemoSummary.SetBounds(20, 84, 510, 290);
    Bridge.MemoSummary.ReadOnly := True;
    Bridge.MemoSummary.Font.Size := 10;

    Bridge.Pages.ActivePageIndex := 0;
    Bridge.UpdateNav;

    if Frm.ShowModal = mrOk then
    begin
      if Bridge.LbType.ItemIndex >= 0 then
        FCbType.ItemIndex := Bridge.LbType.ItemIndex;
      if Bridge.CbCat.ItemIndex >= 0 then FCbCat.ItemIndex := Bridge.CbCat.ItemIndex;
      if Bridge.CbVal.ItemIndex >= 0 then FCbVal.ItemIndex := Bridge.CbVal.ItemIndex;
      if Bridge.CbAgg.ItemIndex >= 0 then FCbAgg.ItemIndex := Bridge.CbAgg.ItemIndex;
      if Bridge.CbTop.ItemIndex >= 0 then FCbTop.ItemIndex := Bridge.CbTop.ItemIndex;
      if Trim(Bridge.EdTitle.Text) <> '' then
        FChartTitle := Trim(Bridge.EdTitle.Text);
      ControlsChange(Self);
    end;
  finally
    for I := 0 to High(DistList) do DistList[I].Free;
    Bridge.Free;
    Frm.Free;
  end;
end;

procedure TQueryChartPanel.BtnPinChartClick(Sender: TObject);
var
  Kind, TitleText, LatF, LonF: string;
begin
  if Trim(FCurrentSQL) = '' then
  begin
    ShowMessage('Execute uma consulta com resultados antes de fixar no Dashboard.');
    Exit;
  end;
  if (FCbType.ItemIndex <> 5) and (FPoints.Count = 0) then
  begin
    ShowMessage('Execute uma consulta com resultados antes de fixar no Dashboard.');
    Exit;
  end;
  LatF := '';
  LonF := '';
  case FCbType.ItemIndex of
    1: Kind := 'hbar';
    2: Kind := 'line';
    3: Kind := 'pie';
    4: Kind := 'donut';
    5: begin
         Kind := 'map';
         LatF := FMapView.SelectedLatField;
         LonF := FMapView.SelectedLonField;
       end;
  else
    Kind := 'bar';
  end;
  TitleText := FChartTitle;
  if TitleText = '' then
  begin
    if Kind = 'map' then TitleText := 'Mapa de Unidades'
    else TitleText := Format('%s por %s', [FCbVal.Text, FCbCat.Text]);
  end;
  if Assigned(FOnPinToDashboard) then
    FOnPinToDashboard(Self, TitleText, FCurrentSQL, Kind, FCbCat.Text, FCbVal.Text,
      LatF, LonF, FCbAgg.ItemIndex, FCbTop.ItemIndex);
end;

procedure TQueryChartPanel.BtnPinKPIClick(Sender: TObject);
var
  TitleText: string;
begin
  if (FPoints.Count = 0) or (Trim(FCurrentSQL) = '') then
  begin
    ShowMessage('Execute uma consulta com resultados antes de fixar um KPI.');
    Exit;
  end;
  TitleText := FChartTitle;
  if TitleText = '' then
    TitleText := FCbVal.Text + ' (' + FCbAgg.Text + ')';
  if Assigned(FOnPinToDashboard) then
    FOnPinToDashboard(Self, TitleText, FCurrentSQL, 'kpi', FCbCat.Text, FCbVal.Text,
      '', '', FCbAgg.ItemIndex, FCbTop.ItemIndex);
end;

procedure TQueryChartPanel.DrawBarChart(G: TCanvas; const PlotR: TRect);
var
  I, N, SlotW, BarW, BarX, BarTop, ZeroY, GridY: Integer;
  MaxV, StepV: Double;
  Pt: TQChartPoint;
  Lbl: string;
begin
  N := FPoints.Count;
  MaxV := 0;
  for I := 0 to N - 1 do
    if TQChartPoint(FPoints[I]).Value > MaxV then
      MaxV := TQChartPoint(FPoints[I]).Value;
  if MaxV <= 0 then MaxV := 1;
  MaxV := MaxV * 1.12;

  // Gridlines & Y labels
  G.Font.Name := 'Segoe UI';
  G.Font.Size := 8;
  G.Font.Color := RGBToColor(100, 116, 139);
  for I := 0 to 5 do
  begin
    GridY := PlotR.Bottom - Round((I / 5.0) * (PlotR.Bottom - PlotR.Top));
    G.Pen.Color := RGBToColor(226, 232, 240);
    G.Line(PlotR.Left, GridY, PlotR.Right, GridY);
    StepV := (MaxV * I) / 5.0;
    Lbl := FormatNum(StepV);
    G.TextOut(PlotR.Left - G.TextWidth(Lbl) - 8, GridY - 7, Lbl);
  end;

  G.Pen.Color := RGBToColor(148, 163, 184);
  G.Line(PlotR.Left, PlotR.Top, PlotR.Left, PlotR.Bottom);
  G.Line(PlotR.Left, PlotR.Bottom, PlotR.Right, PlotR.Bottom);

  ZeroY := PlotR.Bottom;
  SlotW := Max(16, (PlotR.Right - PlotR.Left) div N);
  BarW := Max(10, Min(64, (SlotW * 65) div 100));

  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    BarX := PlotR.Left + I * SlotW + (SlotW - BarW) div 2;
    BarTop := ZeroY - Round((Max(0, Pt.Value) / MaxV) * (PlotR.Bottom - PlotR.Top));
    Pt.HitRect := Rect(BarX, BarTop, BarX + BarW, ZeroY);

    if I = FHoverIndex then
      G.Brush.Color := RGBToColor(30, 64, 175)
    else
      G.Brush.Color := PaletteColor(I);
    G.Pen.Color := G.Brush.Color;
    G.Rectangle(Pt.HitRect);

    if FIs3D and (ZeroY - BarTop > 2) then
    begin
      // 3D top face
      G.Brush.Color := DarkenColor(G.Brush.Color, 0.85);
      G.Pen.Color := DarkenColor(G.Brush.Color, 0.7);
      G.Polygon([Point(BarX, BarTop), Point(BarX + 8, BarTop - 8),
                 Point(BarX + BarW + 8, BarTop - 8), Point(BarX + BarW, BarTop)]);
      // 3D right side face
      G.Brush.Color := DarkenColor(PaletteColor(I), 0.65);
      G.Polygon([Point(BarX + BarW, BarTop), Point(BarX + BarW + 8, BarTop - 8),
                 Point(BarX + BarW + 8, ZeroY - 8), Point(BarX + BarW, ZeroY)]);
    end;

    G.Brush.Color := clWhite;
    G.Font.Size := 8;
    G.Font.Color := RGBToColor(30, 41, 59);
    Lbl := FormatNum(Pt.Value);
    G.TextOut(BarX + (BarW - G.TextWidth(Lbl)) div 2, BarTop - 16, Lbl);

    Lbl := Copy(Pt.LabelText, 1, 14);
    G.Font.Color := RGBToColor(71, 85, 105);
    G.TextOut(BarX + (BarW - G.TextWidth(Lbl)) div 2, ZeroY + 6, Lbl);
  end;
end;

procedure TQueryChartPanel.DrawHorizBarChart(G: TCanvas; const PlotR: TRect);
var
  I, N, SlotH, BarH, BarY, BarRight, LeftMargin: Integer;
  MaxV: Double;
  Pt: TQChartPoint;
  Lbl: string;
begin
  N := FPoints.Count;
  MaxV := 0;
  for I := 0 to N - 1 do
    if TQChartPoint(FPoints[I]).Value > MaxV then
      MaxV := TQChartPoint(FPoints[I]).Value;
  if MaxV <= 0 then MaxV := 1;
  MaxV := MaxV * 1.12;

  LeftMargin := PlotR.Left + 80;
  if LeftMargin > PlotR.Right - 100 then LeftMargin := PlotR.Left;

  G.Pen.Color := RGBToColor(148, 163, 184);
  G.Line(LeftMargin, PlotR.Top, LeftMargin, PlotR.Bottom);
  G.Line(LeftMargin, PlotR.Bottom, PlotR.Right, PlotR.Bottom);

  SlotH := Max(18, (PlotR.Bottom - PlotR.Top) div N);
  BarH := Max(10, Min(32, (SlotH * 65) div 100));

  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    BarY := PlotR.Top + I * SlotH + (SlotH - BarH) div 2;
    BarRight := LeftMargin + Round((Max(0, Pt.Value) / MaxV) * (PlotR.Right - LeftMargin - 40));
    Pt.HitRect := Rect(LeftMargin, BarY, BarRight, BarY + BarH);

    if I = FHoverIndex then
      G.Brush.Color := RGBToColor(30, 64, 175)
    else
      G.Brush.Color := PaletteColor(I);
    G.Pen.Color := G.Brush.Color;
    G.Rectangle(Pt.HitRect);

    if FIs3D and (BarRight - LeftMargin > 2) then
    begin
      G.Brush.Color := DarkenColor(G.Brush.Color, 0.85);
      G.Pen.Color := DarkenColor(G.Brush.Color, 0.7);
      G.Polygon([Point(LeftMargin, BarY), Point(LeftMargin + 7, BarY - 7),
                 Point(BarRight + 7, BarY - 7), Point(BarRight, BarY)]);
      G.Brush.Color := DarkenColor(PaletteColor(I), 0.65);
      G.Polygon([Point(BarRight, BarY), Point(BarRight + 7, BarY - 7),
                 Point(BarRight + 7, BarY + BarH - 7), Point(BarRight, BarY + BarH)]);
    end;

    G.Brush.Color := clWhite;
    G.Font.Name := 'Segoe UI';
    G.Font.Size := 8;
    G.Font.Color := RGBToColor(51, 65, 85);
    Lbl := Copy(Pt.LabelText, 1, 20);
    G.TextOut(Max(8, LeftMargin - G.TextWidth(Lbl) - 8), BarY + (BarH - 14) div 2, Lbl);
    G.TextOut(BarRight + 6, BarY + (BarH - 14) div 2, FormatNum(Pt.Value));
  end;
end;

procedure TQueryChartPanel.DrawLineChart(G: TCanvas; const PlotR: TRect);
var
  I, N, StepX, PX, PY, GridY: Integer;
  MaxV, StepV: Double;
  Pt: TQChartPoint;
  Pts: array of TPoint;
  Lbl: string;
begin
  N := FPoints.Count;
  MaxV := 0;
  for I := 0 to N - 1 do
    if TQChartPoint(FPoints[I]).Value > MaxV then
      MaxV := TQChartPoint(FPoints[I]).Value;
  if MaxV <= 0 then MaxV := 1;
  MaxV := MaxV * 1.12;

  G.Font.Name := 'Segoe UI';
  G.Font.Size := 8;
  G.Font.Color := RGBToColor(100, 116, 139);
  for I := 0 to 5 do
  begin
    GridY := PlotR.Bottom - Round((I / 5.0) * (PlotR.Bottom - PlotR.Top));
    G.Pen.Color := RGBToColor(226, 232, 240);
    G.Line(PlotR.Left, GridY, PlotR.Right, GridY);
    StepV := (MaxV * I) / 5.0;
    Lbl := FormatNum(StepV);
    G.TextOut(PlotR.Left - G.TextWidth(Lbl) - 8, GridY - 7, Lbl);
  end;

  G.Pen.Color := RGBToColor(148, 163, 184);
  G.Line(PlotR.Left, PlotR.Top, PlotR.Left, PlotR.Bottom);
  G.Line(PlotR.Left, PlotR.Bottom, PlotR.Right, PlotR.Bottom);

  SetLength(Pts, N);
  if N > 1 then
    StepX := (PlotR.Right - PlotR.Left - 40) div (N - 1)
  else
    StepX := 0;

  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    if N = 1 then
      PX := (PlotR.Left + PlotR.Right) div 2
    else
      PX := PlotR.Left + 20 + I * StepX;
    PY := PlotR.Bottom - Round((Max(0, Pt.Value) / MaxV) * (PlotR.Bottom - PlotR.Top));
    Pts[I] := Point(PX, PY);
    Pt.HitRect := Rect(PX - 7, PY - 7, PX + 7, PY + 7);
  end;

  if N > 1 then
  begin
    G.Pen.Color := RGBToColor(37, 99, 235);
    G.Pen.Width := 2;
    G.PolyLine(Pts);
    G.Pen.Width := 1;
  end;

  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    if I = FHoverIndex then
      G.Brush.Color := RGBToColor(234, 88, 12)
    else
      G.Brush.Color := RGBToColor(37, 99, 235);
    G.Pen.Color := clWhite;
    G.Ellipse(Pts[I].X - 5, Pts[I].Y - 5, Pts[I].X + 5, Pts[I].Y + 5);

    G.Brush.Color := clWhite;
    G.Font.Color := RGBToColor(30, 41, 59);
    Lbl := FormatNum(Pt.Value);
    G.TextOut(Pts[I].X - G.TextWidth(Lbl) div 2, Pts[I].Y - 18, Lbl);

    Lbl := Copy(Pt.LabelText, 1, 12);
    G.Font.Color := RGBToColor(71, 85, 105);
    G.TextOut(Pts[I].X - G.TextWidth(Lbl) div 2, PlotR.Bottom + 6, Lbl);
  end;
end;

procedure TQueryChartPanel.DrawAreaChart(G: TCanvas; const PlotR: TRect);
var
  I, N, StepX, PX, PY, GridY: Integer;
  MaxV, StepV: Double;
  Pt: TQChartPoint;
  Pts: array of TPoint;
  PolyPts: array of TPoint;
  Lbl: string;
begin
  N := FPoints.Count;
  MaxV := 0;
  for I := 0 to N - 1 do
    if TQChartPoint(FPoints[I]).Value > MaxV then
      MaxV := TQChartPoint(FPoints[I]).Value;
  if MaxV <= 0 then MaxV := 1;
  MaxV := MaxV * 1.12;

  G.Font.Name := 'Segoe UI';
  G.Font.Size := 8;
  G.Font.Color := RGBToColor(100, 116, 139);
  for I := 0 to 5 do
  begin
    GridY := PlotR.Bottom - Round((I / 5.0) * (PlotR.Bottom - PlotR.Top));
    G.Pen.Color := RGBToColor(226, 232, 240);
    G.Line(PlotR.Left, GridY, PlotR.Right, GridY);
    StepV := (MaxV * I) / 5.0;
    Lbl := FormatNum(StepV);
    G.TextOut(PlotR.Left - G.TextWidth(Lbl) - 8, GridY - 7, Lbl);
  end;

  G.Pen.Color := RGBToColor(148, 163, 184);
  G.Line(PlotR.Left, PlotR.Top, PlotR.Left, PlotR.Bottom);
  G.Line(PlotR.Left, PlotR.Bottom, PlotR.Right, PlotR.Bottom);

  SetLength(Pts, N);
  if N > 1 then
    StepX := (PlotR.Right - PlotR.Left - 40) div (N - 1)
  else
    StepX := 0;

  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    if N = 1 then PX := (PlotR.Left + PlotR.Right) div 2 else PX := PlotR.Left + 20 + I * StepX;
    PY := PlotR.Bottom - Round((Max(0, Pt.Value) / MaxV) * (PlotR.Bottom - PlotR.Top));
    Pts[I] := Point(PX, PY);
    Pt.HitRect := Rect(PX - 7, PY - 7, PX + 7, PY + 7);
  end;

  if N > 1 then
  begin
    SetLength(PolyPts, N + 2);
    for I := 0 to N - 1 do PolyPts[I] := Pts[I];
    PolyPts[N] := Point(Pts[N - 1].X, PlotR.Bottom);
    PolyPts[N + 1] := Point(Pts[0].X, PlotR.Bottom);
    G.Brush.Color := RGBToColor(191, 219, 254);
    G.Pen.Color := RGBToColor(37, 99, 235);
    G.Polygon(PolyPts);
    G.Pen.Width := 2;
    G.PolyLine(Pts);
    G.Pen.Width := 1;
  end;

  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    if I = FHoverIndex then G.Brush.Color := RGBToColor(234, 88, 12) else G.Brush.Color := RGBToColor(37, 99, 235);
    G.Pen.Color := clWhite;
    G.Ellipse(Pts[I].X - 5, Pts[I].Y - 5, Pts[I].X + 5, Pts[I].Y + 5);
    G.Brush.Color := clWhite;
    G.Font.Color := RGBToColor(30, 41, 59);
    Lbl := FormatNum(Pt.Value);
    G.TextOut(Pts[I].X - G.TextWidth(Lbl) div 2, Pts[I].Y - 18, Lbl);
    Lbl := Copy(Pt.LabelText, 1, 12);
    G.Font.Color := RGBToColor(71, 85, 105);
    G.TextOut(Pts[I].X - G.TextWidth(Lbl) div 2, PlotR.Bottom + 6, Lbl);
  end;
end;

procedure TQueryChartPanel.DrawScatterChart(G: TCanvas; const PlotR: TRect);
var
  I, N, StepX, PX, PY, GridY: Integer;
  MaxV, StepV: Double;
  Pt: TQChartPoint;
  Lbl: string;
begin
  N := FPoints.Count;
  MaxV := 0;
  for I := 0 to N - 1 do
    if TQChartPoint(FPoints[I]).Value > MaxV then
      MaxV := TQChartPoint(FPoints[I]).Value;
  if MaxV <= 0 then MaxV := 1;
  MaxV := MaxV * 1.12;

  G.Font.Name := 'Segoe UI';
  G.Font.Size := 8;
  G.Font.Color := RGBToColor(100, 116, 139);
  for I := 0 to 5 do
  begin
    GridY := PlotR.Bottom - Round((I / 5.0) * (PlotR.Bottom - PlotR.Top));
    G.Pen.Color := RGBToColor(226, 232, 240);
    G.Line(PlotR.Left, GridY, PlotR.Right, GridY);
    StepV := (MaxV * I) / 5.0;
    Lbl := FormatNum(StepV);
    G.TextOut(PlotR.Left - G.TextWidth(Lbl) - 8, GridY - 7, Lbl);
  end;

  G.Pen.Color := RGBToColor(148, 163, 184);
  G.Line(PlotR.Left, PlotR.Top, PlotR.Left, PlotR.Bottom);
  G.Line(PlotR.Left, PlotR.Bottom, PlotR.Right, PlotR.Bottom);

  if N > 1 then StepX := (PlotR.Right - PlotR.Left - 40) div (N - 1) else StepX := 0;
  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    if N = 1 then PX := (PlotR.Left + PlotR.Right) div 2 else PX := PlotR.Left + 20 + I * StepX;
    PY := PlotR.Bottom - Round((Max(0, Pt.Value) / MaxV) * (PlotR.Bottom - PlotR.Top));
    Pt.HitRect := Rect(PX - 8, PY - 8, PX + 8, PY + 8);
    if I = FHoverIndex then G.Brush.Color := RGBToColor(234, 88, 12) else G.Brush.Color := PaletteColor(I);
    G.Pen.Color := clWhite;
    G.Pen.Width := 2;
    G.Ellipse(PX - 7, PY - 7, PX + 7, PY + 7);
    G.Pen.Width := 1;
    G.Brush.Color := clWhite;
    G.Font.Color := RGBToColor(30, 41, 59);
    Lbl := FormatNum(Pt.Value);
    G.TextOut(PX - G.TextWidth(Lbl) div 2, PY - 20, Lbl);
    Lbl := Copy(Pt.LabelText, 1, 10);
    G.Font.Color := RGBToColor(71, 85, 105);
    G.TextOut(PX - G.TextWidth(Lbl) div 2, PlotR.Bottom + 6, Lbl);
  end;
end;

procedure TQueryChartPanel.DrawPieChart(G: TCanvas; const PlotR: TRect);
var
  I, N, D, Depth3D, LegX, LegY, X1, Y1, X2, Y2: Integer;
  Total, CurAngle, Sweep, Rad1, Rad2: Double;
  Pt: TQChartPoint;
  Lbl: string;
begin
  N := FPoints.Count;
  Total := 0;
  for I := 0 to N - 1 do
    Total := Total + Max(0, TQChartPoint(FPoints[I]).Value);
  if Total <= 0 then Total := 1;

  if FLegendPos = 2 then
  begin
    FPieRadius := Min((PlotR.Right - PlotR.Left) div 2, (PlotR.Bottom - PlotR.Top) div 2) - 16;
    if FPieRadius < 40 then FPieRadius := 40;
    FPieCenter.X := (PlotR.Left + PlotR.Right) div 2;
  end
  else
  begin
    FPieRadius := Min((PlotR.Right - PlotR.Left) div 3, (PlotR.Bottom - PlotR.Top) div 2) - 10;
    if FPieRadius < 40 then FPieRadius := 40;
    FPieCenter.X := PlotR.Left + FPieRadius + 30;
  end;
  FPieCenter.Y := (PlotR.Top + PlotR.Bottom) div 2;

  if FIs3D then
  begin
    Depth3D := 12;
    for D := Depth3D downto 1 do
    begin
      CurAngle := 0;
      for I := 0 to N - 1 do
      begin
        Pt := TQChartPoint(FPoints[I]);
        Sweep := (Max(0, Pt.Value) / Total) * 360.0;
        if Sweep > 0.1 then
        begin
          Rad1 := DegToRad(CurAngle);
          Rad2 := DegToRad(CurAngle + Sweep);
          X1 := FPieCenter.X + Round(Cos(Rad1) * FPieRadius);
          Y1 := (FPieCenter.Y + D) - Round(Sin(Rad1) * FPieRadius);
          X2 := FPieCenter.X + Round(Cos(Rad2) * FPieRadius);
          Y2 := (FPieCenter.Y + D) - Round(Sin(Rad2) * FPieRadius);
          G.Brush.Color := DarkenColor(PaletteColor(I), 0.70);
          G.Pen.Color := G.Brush.Color;
          G.Pie(FPieCenter.X - FPieRadius, FPieCenter.Y + D - FPieRadius,
                FPieCenter.X + FPieRadius, FPieCenter.Y + D + FPieRadius,
                X1, Y1, X2, Y2);
        end;
        CurAngle := CurAngle + Sweep;
      end;
    end;
  end;

  CurAngle := 0;
  LegX := FPieCenter.X + FPieRadius + 40;
  LegY := PlotR.Top + 10;

  for I := 0 to N - 1 do
  begin
    Pt := TQChartPoint(FPoints[I]);
    Sweep := (Max(0, Pt.Value) / Total) * 360.0;
    Pt.StartAngle := CurAngle;
    Pt.SweepAngle := Sweep;

    if Sweep > 0.1 then
    begin
      Rad1 := DegToRad(CurAngle);
      Rad2 := DegToRad(CurAngle + Sweep);
      X1 := FPieCenter.X + Round(Cos(Rad1) * FPieRadius);
      Y1 := FPieCenter.Y - Round(Sin(Rad1) * FPieRadius);
      X2 := FPieCenter.X + Round(Cos(Rad2) * FPieRadius);
      Y2 := FPieCenter.Y - Round(Sin(Rad2) * FPieRadius);

      G.Brush.Color := PaletteColor(I);
      if I = FHoverIndex then
        G.Pen.Width := 2
      else
        G.Pen.Width := 1;
      G.Pen.Color := clWhite;
      G.Pie(FPieCenter.X - FPieRadius, FPieCenter.Y - FPieRadius,
            FPieCenter.X + FPieRadius, FPieCenter.Y + FPieRadius,
            X1, Y1, X2, Y2);
      G.Pen.Width := 1;
    end;

    if (FLegendPos <> 2) and (LegY + 20 < PlotR.Bottom) then
    begin
      G.Brush.Color := PaletteColor(I);
      G.Pen.Color := G.Brush.Color;
      G.Rectangle(LegX, LegY + 3, LegX + 12, LegY + 15);
      G.Brush.Color := clWhite;
      G.Font.Name := 'Segoe UI';
      G.Font.Size := 8;
      G.Font.Color := RGBToColor(30, 41, 59);
      Lbl := FormatLegendText(Pt, Total);
      G.TextOut(LegX + 18, LegY + 2, Lbl);
      Inc(LegY, 20);
    end;

    CurAngle := CurAngle + Sweep;
  end;

  if FCbType.ItemIndex = 4 then
  begin
    G.Brush.Color := clWhite;
    G.Pen.Color := clWhite;
    G.Ellipse(FPieCenter.X - (FPieRadius * 48) div 100,
              FPieCenter.Y - (FPieRadius * 48) div 100,
              FPieCenter.X + (FPieRadius * 48) div 100,
              FPieCenter.Y + (FPieRadius * 48) div 100);
  end;
end;

procedure TQueryChartPanel.CanvasPaint(Sender: TObject);
var
  G: TCanvas;
  W, H, TipW, TipX, TipY, ScaleW, ScaleH: Integer;
  PlotR, LegR: TRect;
  TitleText, TipText: string;
  Pt: TQChartPoint;
begin
  W := FCanvas.Width;
  H := FCanvas.Height;
  if (W <= 0) or (H <= 0) then Exit;

  FBuffer.SetSize(W, H);
  G := FBuffer.Canvas;
  G.Brush.Color := clWhite;
  G.FillRect(0, 0, W, H);

  if FPoints.Count = 0 then
  begin
    G.Font.Name := 'Segoe UI';
    G.Font.Size := 11;
    G.Font.Color := RGBToColor(120, 130, 145);
    G.TextOut(32, 36, 'Execute uma consulta na prévia para gerar gráficos automaticamente.');
    FCanvas.Canvas.Draw(0, 0, FBuffer);
    Exit;
  end;

  TitleText := FChartTitle;
  if TitleText = '' then
    TitleText := Format('%s por %s', [FCbVal.Text, FCbCat.Text]);

  G.Font.Name := FTitleFontName;
  G.Font.Size := FTitleFontSize;
  G.Font.Style := [fsBold];
  G.Font.Color := RGBToColor(30, 41, 59);
  G.TextOut(24, 12, TitleText);
  G.Font.Style := [];

  PlotR := Rect(70, 22 + FTitleFontSize * 2, W - 28, H - 36);
  if (FCbType.ItemIndex <> 3) and (FCbType.ItemIndex <> 4) then
  begin
    if FLegendPos = 0 then
    begin
      LegR := Rect(W - 220, PlotR.Top, W - 14, H - 20);
      PlotR.Right := LegR.Left - 16;
    end
    else if FLegendPos = 1 then
    begin
      LegR := Rect(24, H - 72, W - 18, H - 10);
      PlotR.Bottom := LegR.Top - 24;
    end;
  end;

  if FChartScalePct <> 100 then
  begin
    ScaleW := Round((PlotR.Right - PlotR.Left) * (FChartScalePct / 100.0));
    ScaleH := Round((PlotR.Bottom - PlotR.Top) * (FChartScalePct / 100.0));
    PlotR.Left := PlotR.Left + ((PlotR.Right - PlotR.Left) - ScaleW) div 2;
    PlotR.Top := PlotR.Top + ((PlotR.Bottom - PlotR.Top) - ScaleH) div 2;
    PlotR.Right := PlotR.Left + ScaleW;
    PlotR.Bottom := PlotR.Top + ScaleH;
  end;

  if (PlotR.Right <= PlotR.Left + 40) or (PlotR.Bottom <= PlotR.Top + 40) then
  begin
    FCanvas.Canvas.Draw(0, 0, FBuffer);
    Exit;
  end;

  case FCbType.ItemIndex of
    1: DrawHorizBarChart(G, PlotR);
    2: DrawLineChart(G, PlotR);
    3, 4: DrawPieChart(G, PlotR);
    6: DrawAreaChart(G, PlotR);
    7: DrawScatterChart(G, PlotR);
  else
    DrawBarChart(G, PlotR);
  end;

  if (FCbType.ItemIndex <> 3) and (FCbType.ItemIndex <> 4) and (FLegendPos <> 2) then
    DrawLegend(G, LegR);

  if (FHoverIndex >= 0) and (FHoverIndex < FPoints.Count) then
  begin
    Pt := TQChartPoint(FPoints[FHoverIndex]);
    TipText := Pt.LabelText + ': ' + FormatNum(Pt.Value);
    G.Font.Name := 'Segoe UI';
    G.Font.Size := 8;
    G.Font.Style := [fsBold];
    TipW := G.TextWidth(TipText) + 16;
    TipX := Min(W - TipW - 8, FHoverPos.X + 12);
    TipY := Max(8, FHoverPos.Y - 26);
    G.Brush.Color := RGBToColor(15, 23, 42);
    G.Pen.Color := RGBToColor(15, 23, 42);
    G.RoundRect(TipX, TipY, TipX + TipW, TipY + 22, 6, 6);
    G.Font.Color := clWhite;
    G.TextOut(TipX + 8, TipY + 4, TipText);
    G.Font.Style := [];
  end;

  FCanvas.Canvas.Draw(0, 0, FBuffer);
end;

procedure TQueryChartPanel.CanvasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  I, NewHover: Integer;
  Pt: TQChartPoint;
  DX, DY, Dist, Ang: Double;
begin
  NewHover := -1;
  FHoverPos := Point(X, Y);

  if FCbType.ItemIndex in [3, 4] then
  begin
    DX := X - FPieCenter.X;
    DY := FPieCenter.Y - Y;
    Dist := Sqrt(DX * DX + DY * DY);
    if Dist <= FPieRadius then
    begin
      Ang := RadToDeg(ArcTan2(DY, DX));
      if Ang < 0 then Ang := Ang + 360.0;
      for I := 0 to FPoints.Count - 1 do
      begin
        Pt := TQChartPoint(FPoints[I]);
        if (Ang >= Pt.StartAngle) and (Ang <= Pt.StartAngle + Pt.SweepAngle) then
        begin
          NewHover := I;
          Break;
        end;
      end;
    end;
  end
  else
  begin
    for I := 0 to FPoints.Count - 1 do
    begin
      Pt := TQChartPoint(FPoints[I]);
      if PtInRect(Pt.HitRect, Point(X, Y)) then
      begin
        NewHover := I;
        Break;
      end;
    end;
  end;

  if NewHover <> FHoverIndex then
  begin
    FHoverIndex := NewHover;
    FCanvas.Invalidate;
  end
  else if FHoverIndex >= 0 then
    FCanvas.Invalidate;
end;

end.
