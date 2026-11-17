unit uquerymap;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, Dialogs,
  CheckLst, DB, Contnrs, Types, Math, LCLIntf, fphttpclient, opensslsockets;

type
  TMapPointSelectEvent = procedure(Sender: TObject; const ALabel: string) of object;
  TMapViewPinEvent = procedure(Sender: TObject; APinned: Boolean; ALat, ALon: Double; AZoom: Integer) of object;

  TQMapPoint = class
  public
    LabelText: string;
    Lat: Double;
    Lon: Double;
    Value: Double;
    ScreenPt: TPoint;
    Radius: Integer;
    Visible: Boolean;
  end;

  TQueryMapPanel = class(TPanel)
  private
    FToolbar: TPanel;
    FLblLat: TLabel;
    FCbLat: TComboBox;
    FLblLon: TLabel;
    FCbLon: TComboBox;
    FLblLabel: TLabel;
    FCbLabel: TComboBox;
    FLblVal: TLabel;
    FCbVal: TComboBox;
    FBtnZoomIn: TButton;
    FBtnZoomOut: TButton;
    FBtnCenter: TButton;
    FBtnExportPNG: TButton;
    FBtnOpenHTML: TButton;

    FQuickBar: TPanel;
    FBtnToggleUnits: TButton;
    FBtnQuickZoomIn: TButton;
    FBtnQuickZoomOut: TButton;
    FBtnQuickCenter: TButton;
    FBtnPinView: TButton;
    FLblQuickInfo: TLabel;

    FUnitPanel: TPanel;
    FUnitTopPanel: TPanel;
    FEdUnitSearch: TEdit;
    FBtnSelectAll: TButton;
    FBtnSelectNone: TButton;
    FChkUnits: TCheckListBox;

    FCanvas: TPaintBox;
    FBuffer: TBitmap;
    FDataSet: TDataSet;
    FPoints: TObjectList;
    FAllLabels: TStringList;
    FHiddenLabels: TStringList;
    FHighlightLabel: string;
    FOnPointClick: TMapPointSelectEvent;
    FCanPinView: Boolean;
    FViewPinned: Boolean;
    FPinnedLat: Double;
    FPinnedLon: Double;
    FPinnedZoom: Integer;
    FOnViewPinChange: TMapViewPinEvent;
    FZoom: Integer;
    FCenterLat: Double;
    FCenterLon: Double;
    FMinVal, FMaxVal: Double;
    FPanning: Boolean;
    FPanMoved: Boolean;
    FPanStart: TPoint;
    FPanStartCenterLat, FPanStartCenterLon: Double;
    FHoverIndex: Integer;
    FHoverPos: TPoint;
    FCacheDir: string;
    FTileCache: TFPObjectHashTable;

    procedure BuildUI;
    procedure PopulateFieldCombos;
    procedure RebuildPoints;
    procedure UpdateVisibilityAndRange;
    procedure RefreshUnitChecklist;
    procedure UpdateQuickInfo;
    procedure AutoCenter;
    procedure ControlsChange(Sender: TObject);
    procedure BtnZoomInClick(Sender: TObject);
    procedure BtnZoomOutClick(Sender: TObject);
    procedure BtnCenterClick(Sender: TObject);
    procedure BtnExportPNGClick(Sender: TObject);
    procedure BtnOpenHTMLClick(Sender: TObject);
    procedure BtnToggleUnitsClick(Sender: TObject);
    procedure BtnPinViewClick(Sender: TObject);
    procedure BtnSelectAllClick(Sender: TObject);
    procedure BtnSelectNoneClick(Sender: TObject);
    procedure UnitSearchChange(Sender: TObject);
    procedure ChkUnitsClickCheck(Sender: TObject);
    procedure CanvasPaint(Sender: TObject);
    procedure CanvasMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    function LatLonToWorldX(Lon: Double; Zoom: Integer): Double;
    function LatLonToWorldY(Lat: Double; Zoom: Integer): Double;
    function WorldToScreen(WX, WY: Double): TPoint;
    function GetTileBitmap(Z, X, Y: Integer): TBitmap;
    function HeatColor(Norm: Double): TColor;
    function FormatNum(V: Double): string;
    function ParseCoord(const S: string; out V: Double): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromDataSet(ADataSet: TDataSet);
    procedure LoadEmbedded(ADataSet: TDataSet; const ALatField, ALonField, ALblField, AValField: string);
    procedure SetToolbarVisible(AVisible: Boolean);
    procedure SetHighlightLabel(const ALabel: string);
    procedure SetCanPinView(ACanPin: Boolean);
    procedure SetFixedView(APinned: Boolean; ALat, ALon: Double; AZoom: Integer);
    function SelectedLatField: string;
    function SelectedLonField: string;
    property OnPointClick: TMapPointSelectEvent read FOnPointClick write FOnPointClick;
    property OnViewPinChange: TMapViewPinEvent read FOnViewPinChange write FOnViewPinChange;
    property CacheDir: string read FCacheDir;
  end;

implementation

{ TQueryMapPanel }

constructor TQueryMapPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPoints := TObjectList.Create(True);
  FAllLabels := TStringList.Create;
  FAllLabels.Sorted := True;
  FAllLabels.Duplicates := dupIgnore;
  FHiddenLabels := TStringList.Create;
  FHiddenLabels.Sorted := True;
  FHiddenLabels.Duplicates := dupIgnore;
  FHighlightLabel := '';
  FBuffer := TBitmap.Create;
  FTileCache := TFPObjectHashTable.Create(True);
  FZoom := 12;
  // Default center: Ribeirao Preto, SP
  FCenterLat := -21.1775;
  FCenterLon := -47.8103;
  FHoverIndex := -1;
  FCacheDir := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'map_cache';
  ForceDirectories(FCacheDir);

  BevelOuter := bvNone;
  Color := clWhite;
  BuildUI;
end;

destructor TQueryMapPanel.Destroy;
begin
  FTileCache.Free;
  FBuffer.Free;
  FHiddenLabels.Free;
  FAllLabels.Free;
  FPoints.Free;
  inherited Destroy;
end;

procedure TQueryMapPanel.BuildUI;
begin
  FToolbar := TPanel.Create(Self);
  FToolbar.Parent := Self;
  FToolbar.Align := alTop;
  FToolbar.Height := 66;
  FToolbar.BevelOuter := bvNone;
  FToolbar.Color := RGBToColor(248, 250, 252);

  FLblLat := TLabel.Create(Self);
  FLblLat.Parent := FToolbar;
  FLblLat.SetBounds(10, 8, 90, 16);
  FLblLat.Caption := 'Latitude:';
  FLblLat.Font.Style := [fsBold];

  FCbLat := TComboBox.Create(Self);
  FCbLat.Parent := FToolbar;
  FCbLat.SetBounds(10, 28, 120, 24);
  FCbLat.Style := csDropDownList;
  FCbLat.OnChange := @ControlsChange;

  FLblLon := TLabel.Create(Self);
  FLblLon.Parent := FToolbar;
  FLblLon.SetBounds(136, 8, 90, 16);
  FLblLon.Caption := 'Longitude:';
  FLblLon.Font.Style := [fsBold];

  FCbLon := TComboBox.Create(Self);
  FCbLon.Parent := FToolbar;
  FCbLon.SetBounds(136, 28, 120, 24);
  FCbLon.Style := csDropDownList;
  FCbLon.OnChange := @ControlsChange;

  FLblLabel := TLabel.Create(Self);
  FLblLabel.Parent := FToolbar;
  FLblLabel.SetBounds(262, 8, 110, 16);
  FLblLabel.Caption := 'Rótulo:';
  FLblLabel.Font.Style := [fsBold];

  FCbLabel := TComboBox.Create(Self);
  FCbLabel.Parent := FToolbar;
  FCbLabel.SetBounds(262, 28, 140, 24);
  FCbLabel.Style := csDropDownList;
  FCbLabel.OnChange := @ControlsChange;

  FLblVal := TLabel.Create(Self);
  FLblVal.Parent := FToolbar;
  FLblVal.SetBounds(408, 8, 130, 16);
  FLblVal.Caption := 'Valor (Bolha/Cor):';
  FLblVal.Font.Style := [fsBold];

  FCbVal := TComboBox.Create(Self);
  FCbVal.Parent := FToolbar;
  FCbVal.SetBounds(408, 28, 140, 24);
  FCbVal.Style := csDropDownList;
  FCbVal.OnChange := @ControlsChange;

  FBtnZoomIn := TButton.Create(Self);
  FBtnZoomIn.Parent := FToolbar;
  FBtnZoomIn.SetBounds(558, 27, 30, 26);
  FBtnZoomIn.Caption := '+';
  FBtnZoomIn.Font.Style := [fsBold];
  FBtnZoomIn.OnClick := @BtnZoomInClick;

  FBtnZoomOut := TButton.Create(Self);
  FBtnZoomOut.Parent := FToolbar;
  FBtnZoomOut.SetBounds(592, 27, 30, 26);
  FBtnZoomOut.Caption := '-';
  FBtnZoomOut.Font.Style := [fsBold];
  FBtnZoomOut.OnClick := @BtnZoomOutClick;

  FBtnCenter := TButton.Create(Self);
  FBtnCenter.Parent := FToolbar;
  FBtnCenter.SetBounds(628, 27, 86, 26);
  FBtnCenter.Caption := 'Centralizar';
  FBtnCenter.OnClick := @BtnCenterClick;

  FBtnExportPNG := TButton.Create(Self);
  FBtnExportPNG.Parent := FToolbar;
  FBtnExportPNG.SetBounds(720, 27, 98, 26);
  FBtnExportPNG.Caption := 'Exportar PNG';
  FBtnExportPNG.OnClick := @BtnExportPNGClick;

  FBtnOpenHTML := TButton.Create(Self);
  FBtnOpenHTML.Parent := FToolbar;
  FBtnOpenHTML.SetBounds(824, 27, 136, 26);
  FBtnOpenHTML.Caption := 'Mapa Interativo HTML';
  FBtnOpenHTML.Font.Style := [fsBold];
  FBtnOpenHTML.OnClick := @BtnOpenHTMLClick;

  // Quick bar (always visible, even in embedded Dashboard mode)
  FQuickBar := TPanel.Create(Self);
  FQuickBar.Parent := Self;
  FQuickBar.Align := alTop;
  FQuickBar.Height := 30;
  FQuickBar.BevelOuter := bvNone;
  FQuickBar.Color := RGBToColor(241, 245, 249);

  FBtnToggleUnits := TButton.Create(Self);
  FBtnToggleUnits.Parent := FQuickBar;
  FBtnToggleUnits.SetBounds(6, 3, 148, 24);
  FBtnToggleUnits.Caption := 'Unidades (0)';
  FBtnToggleUnits.Font.Style := [fsBold];
  FBtnToggleUnits.Hint := 'Selecionar quais unidades exibir no mapa';
  FBtnToggleUnits.ShowHint := True;
  FBtnToggleUnits.OnClick := @BtnToggleUnitsClick;

  FBtnQuickZoomIn := TButton.Create(Self);
  FBtnQuickZoomIn.Parent := FQuickBar;
  FBtnQuickZoomIn.SetBounds(160, 3, 26, 24);
  FBtnQuickZoomIn.Caption := '+';
  FBtnQuickZoomIn.Font.Style := [fsBold];
  FBtnQuickZoomIn.OnClick := @BtnZoomInClick;

  FBtnQuickZoomOut := TButton.Create(Self);
  FBtnQuickZoomOut.Parent := FQuickBar;
  FBtnQuickZoomOut.SetBounds(188, 3, 26, 24);
  FBtnQuickZoomOut.Caption := '-';
  FBtnQuickZoomOut.Font.Style := [fsBold];
  FBtnQuickZoomOut.OnClick := @BtnZoomOutClick;

  FBtnQuickCenter := TButton.Create(Self);
  FBtnQuickCenter.Parent := FQuickBar;
  FBtnQuickCenter.SetBounds(218, 3, 76, 24);
  FBtnQuickCenter.Caption := 'Centralizar';
  FBtnQuickCenter.OnClick := @BtnCenterClick;

  FBtnPinView := TButton.Create(Self);
  FBtnPinView.Parent := FQuickBar;
  FBtnPinView.SetBounds(298, 3, 108, 24);
  FBtnPinView.Caption := 'Fixar Posição';
  FBtnPinView.Hint := 'Fixar posição e zoom atuais do mapa (somente edição)';
  FBtnPinView.ShowHint := True;
  FBtnPinView.Visible := FCanPinView;
  FBtnPinView.OnClick := @BtnPinViewClick;

  FLblQuickInfo := TLabel.Create(Self);
  FLblQuickInfo.Parent := FQuickBar;
  FLblQuickInfo.SetBounds(412, 7, 260, 16);
  FLblQuickInfo.Caption := '';
  FLblQuickInfo.Font.Color := RGBToColor(71, 85, 105);

  // Collapsible unit selection panel
  FUnitPanel := TPanel.Create(Self);
  FUnitPanel.Parent := Self;
  FUnitPanel.Align := alLeft;
  FUnitPanel.Width := 220;
  FUnitPanel.BevelOuter := bvLowered;
  FUnitPanel.Color := RGBToColor(248, 250, 252);
  FUnitPanel.Visible := False;

  FUnitTopPanel := TPanel.Create(Self);
  FUnitTopPanel.Parent := FUnitPanel;
  FUnitTopPanel.Align := alTop;
  FUnitTopPanel.Height := 60;
  FUnitTopPanel.BevelOuter := bvNone;
  FUnitTopPanel.Color := RGBToColor(248, 250, 252);

  FEdUnitSearch := TEdit.Create(Self);
  FEdUnitSearch.Parent := FUnitTopPanel;
  FEdUnitSearch.SetBounds(6, 6, 206, 22);
  FEdUnitSearch.TextHint := 'Filtrar unidade...';
  FEdUnitSearch.OnChange := @UnitSearchChange;

  FBtnSelectAll := TButton.Create(Self);
  FBtnSelectAll.Parent := FUnitTopPanel;
  FBtnSelectAll.SetBounds(6, 32, 98, 22);
  FBtnSelectAll.Caption := 'Todas';
  FBtnSelectAll.OnClick := @BtnSelectAllClick;

  FBtnSelectNone := TButton.Create(Self);
  FBtnSelectNone.Parent := FUnitTopPanel;
  FBtnSelectNone.SetBounds(112, 32, 100, 22);
  FBtnSelectNone.Caption := 'Nenhuma';
  FBtnSelectNone.OnClick := @BtnSelectNoneClick;

  FChkUnits := TCheckListBox.Create(Self);
  FChkUnits.Parent := FUnitPanel;
  FChkUnits.Align := alClient;
  FChkUnits.BorderStyle := bsNone;
  FChkUnits.OnClickCheck := @ChkUnitsClickCheck;

  FCanvas := TPaintBox.Create(Self);
  FCanvas.Parent := Self;
  FCanvas.Align := alClient;
  FCanvas.OnPaint := @CanvasPaint;
  FCanvas.OnMouseDown := @CanvasMouseDown;
  FCanvas.OnMouseMove := @CanvasMouseMove;
  FCanvas.OnMouseUp := @CanvasMouseUp;
  FCanvas.OnMouseWheel := @CanvasMouseWheel;
end;

function TQueryMapPanel.FormatNum(V: Double): string;
begin
  if Abs(V - Round(V)) < 0.0001 then
    Result := FormatFloat('#,##0', V)
  else
    Result := FormatFloat('#,##0.##', V);
end;

function TQueryMapPanel.ParseCoord(const S: string; out V: Double): Boolean;
var
  Clean: string;
  FS: TFormatSettings;
begin
  Clean := StringReplace(Trim(S), ',', '.', [rfReplaceAll]);
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  Result := TryStrToFloat(Clean, V, FS);
end;

procedure TQueryMapPanel.LoadFromDataSet(ADataSet: TDataSet);
begin
  FDataSet := ADataSet;
  PopulateFieldCombos;
  RebuildPoints;
  AutoCenter;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.SetToolbarVisible(AVisible: Boolean);
begin
  if Assigned(FToolbar) then
    FToolbar.Visible := AVisible;
end;

procedure TQueryMapPanel.SetHighlightLabel(const ALabel: string);
begin
  FHighlightLabel := Trim(ALabel);
  UpdateQuickInfo;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.SetCanPinView(ACanPin: Boolean);
begin
  FCanPinView := ACanPin;
  if Assigned(FBtnPinView) then
  begin
    FBtnPinView.Visible := FCanPinView;
    if FViewPinned then
      FBtnPinView.Caption := 'Desafixar Posição'
    else
      FBtnPinView.Caption := 'Fixar Posição';
  end;
  if Assigned(FLblQuickInfo) then
  begin
    if FCanPinView then
      FLblQuickInfo.Left := 412
    else
      FLblQuickInfo.Left := 302;
  end;
end;

procedure TQueryMapPanel.SetFixedView(APinned: Boolean; ALat, ALon: Double; AZoom: Integer);
begin
  FViewPinned := APinned;
  FPinnedLat := ALat;
  FPinnedLon := ALon;
  FPinnedZoom := Max(2, Min(18, AZoom));
  if FViewPinned then
  begin
    FCenterLat := FPinnedLat;
    FCenterLon := FPinnedLon;
    FZoom := FPinnedZoom;
  end;
  if Assigned(FBtnPinView) then
  begin
    if FViewPinned then
      FBtnPinView.Caption := 'Desafixar Posição'
    else
      FBtnPinView.Caption := 'Fixar Posição';
  end;
  UpdateQuickInfo;
  FCanvas.Invalidate;
end;

function TQueryMapPanel.SelectedLatField: string;
begin
  Result := FCbLat.Text;
end;

function TQueryMapPanel.SelectedLonField: string;
begin
  Result := FCbLon.Text;
end;

procedure TQueryMapPanel.LoadEmbedded(ADataSet: TDataSet; const ALatField, ALonField, ALblField, AValField: string);
var
  Idx: Integer;
begin
  FDataSet := ADataSet;
  PopulateFieldCombos;
  if ALatField <> '' then begin Idx := FCbLat.Items.IndexOf(ALatField); if Idx >= 0 then FCbLat.ItemIndex := Idx; end;
  if ALonField <> '' then begin Idx := FCbLon.Items.IndexOf(ALonField); if Idx >= 0 then FCbLon.ItemIndex := Idx; end;
  if ALblField <> '' then begin Idx := FCbLabel.Items.IndexOf(ALblField); if Idx >= 0 then FCbLabel.ItemIndex := Idx; end;
  if AValField <> '' then begin Idx := FCbVal.Items.IndexOf(AValField); if Idx >= 0 then FCbVal.ItemIndex := Idx; end;
  RebuildPoints;
  AutoCenter;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.PopulateFieldCombos;
var
  I, LatIdx, LonIdx, LblIdx, ValIdx: Integer;
  F: TField;
  LN: string;
begin
  FCbLat.Items.BeginUpdate;
  FCbLon.Items.BeginUpdate;
  FCbLabel.Items.BeginUpdate;
  FCbVal.Items.BeginUpdate;
  try
    FCbLat.Items.Clear;
    FCbLon.Items.Clear;
    FCbLabel.Items.Clear;
    FCbVal.Items.Clear;
    FCbVal.Items.Add('(Tamanho fixo)');
    if (FDataSet = nil) or not FDataSet.Active then Exit;

    LatIdx := -1; LonIdx := -1; LblIdx := -1; ValIdx := -1;
    for I := 0 to FDataSet.FieldCount - 1 do
    begin
      F := FDataSet.Fields[I];
      LN := LowerCase(F.FieldName);
      FCbLat.Items.Add(F.FieldName);
      FCbLon.Items.Add(F.FieldName);
      FCbLabel.Items.Add(F.FieldName);

      if (LatIdx < 0) and ((LN = 'lat') or (Pos('latitude', LN) > 0)) then
        LatIdx := I;
      if (LonIdx < 0) and ((LN = 'lon') or (LN = 'lng') or (Pos('longitude', LN) > 0)) then
        LonIdx := I;
      if (LblIdx < 0) and (F.DataType in [ftString, ftWideString, ftMemo]) then
        LblIdx := I;
      if F.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeint, ftFMTBcd] then
      begin
        FCbVal.Items.Add(F.FieldName);
        if (ValIdx < 0) and (Pos('lat', LN) = 0) and (Pos('lon', LN) = 0) and (Pos('lng', LN) = 0) then
          ValIdx := FCbVal.Items.Count - 1;
      end;
    end;

    if LatIdx >= 0 then FCbLat.ItemIndex := LatIdx else if FCbLat.Items.Count > 0 then FCbLat.ItemIndex := 0;
    if LonIdx >= 0 then FCbLon.ItemIndex := LonIdx else if FCbLon.Items.Count > 1 then FCbLon.ItemIndex := 1 else if FCbLon.Items.Count > 0 then FCbLon.ItemIndex := 0;
    if LblIdx >= 0 then FCbLabel.ItemIndex := LblIdx else if FCbLabel.Items.Count > 0 then FCbLabel.ItemIndex := 0;
    if ValIdx >= 0 then FCbVal.ItemIndex := ValIdx else FCbVal.ItemIndex := 0;
  finally
    FCbLat.Items.EndUpdate;
    FCbLon.Items.EndUpdate;
    FCbLabel.Items.EndUpdate;
    FCbVal.Items.EndUpdate;
  end;
end;

procedure TQueryMapPanel.RebuildPoints;
var
  Bm: TBookmark;
  LatF, LonF, LblF, ValF: TField;
  LatV, LonV, ValV: Double;
  Pt: TQMapPoint;
begin
  FPoints.Clear;
  FAllLabels.Clear;
  FHoverIndex := -1;
  FMinVal := 0;
  FMaxVal := 0;
  if (FDataSet = nil) or not FDataSet.Active or FDataSet.IsEmpty then
  begin
    RefreshUnitChecklist;
    UpdateQuickInfo;
    Exit;
  end;

  LatF := FDataSet.FindField(FCbLat.Text);
  LonF := FDataSet.FindField(FCbLon.Text);
  LblF := FDataSet.FindField(FCbLabel.Text);
  if FCbVal.ItemIndex > 0 then
    ValF := FDataSet.FindField(FCbVal.Text)
  else
    ValF := nil;

  if (LatF = nil) or (LonF = nil) then
  begin
    RefreshUnitChecklist;
    UpdateQuickInfo;
    Exit;
  end;

  FDataSet.DisableControls;
  Bm := FDataSet.GetBookmark;
  try
    FDataSet.First;
    while not FDataSet.EOF do
    begin
      if not LatF.IsNull and not LonF.IsNull and
         ParseCoord(LatF.AsString, LatV) and ParseCoord(LonF.AsString, LonV) and
         (LatV >= -85.0) and (LatV <= 85.0) and (LonV >= -180.0) and (LonV <= 180.0) and
         ((Abs(LatV) > 0.0001) or (Abs(LonV) > 0.0001)) then
      begin
        Pt := TQMapPoint.Create;
        Pt.Lat := LatV;
        Pt.Lon := LonV;
        if LblF <> nil then
          Pt.LabelText := Trim(LblF.AsString)
        else
          Pt.LabelText := Format('%.4f, %.4f', [LatV, LonV]);
        if Pt.LabelText = '' then
          Pt.LabelText := Format('%.4f, %.4f', [LatV, LonV]);
        if (ValF <> nil) and not ValF.IsNull then
        begin
          try
            ValV := ValF.AsFloat;
          except
            ValV := 1;
          end;
        end
        else
          ValV := 1;
        Pt.Value := ValV;
        Pt.Visible := FHiddenLabels.IndexOf(Pt.LabelText) < 0;
        FAllLabels.Add(Pt.LabelText);
        FPoints.Add(Pt);
      end;
      FDataSet.Next;
    end;
  finally
    if FDataSet.BookmarkValid(Bm) then
      FDataSet.GotoBookmark(Bm);
    FDataSet.FreeBookmark(Bm);
    FDataSet.EnableControls;
  end;

  UpdateVisibilityAndRange;
  RefreshUnitChecklist;
end;

procedure TQueryMapPanel.UpdateVisibilityAndRange;
var
  I: Integer;
  Pt: TQMapPoint;
  HasFirst: Boolean;
begin
  FMinVal := 0;
  FMaxVal := 0;
  HasFirst := False;
  for I := 0 to FPoints.Count - 1 do
  begin
    Pt := TQMapPoint(FPoints[I]);
    Pt.Visible := FHiddenLabels.IndexOf(Pt.LabelText) < 0;
    if Pt.Visible then
    begin
      if not HasFirst then
      begin
        FMinVal := Pt.Value;
        FMaxVal := Pt.Value;
        HasFirst := True;
      end
      else
      begin
        if Pt.Value < FMinVal then FMinVal := Pt.Value;
        if Pt.Value > FMaxVal then FMaxVal := Pt.Value;
      end;
    end;
  end;
  UpdateQuickInfo;
end;

procedure TQueryMapPanel.RefreshUnitChecklist;
var
  I, Idx: Integer;
  FilterTxt, Lbl: string;
begin
  FilterTxt := LowerCase(Trim(FEdUnitSearch.Text));
  FChkUnits.Items.BeginUpdate;
  try
    FChkUnits.Items.Clear;
    for I := 0 to FAllLabels.Count - 1 do
    begin
      Lbl := FAllLabels[I];
      if (FilterTxt = '') or (Pos(FilterTxt, LowerCase(Lbl)) > 0) then
      begin
        Idx := FChkUnits.Items.Add(Lbl);
        FChkUnits.Checked[Idx] := FHiddenLabels.IndexOf(Lbl) < 0;
      end;
    end;
  finally
    FChkUnits.Items.EndUpdate;
  end;
  UpdateQuickInfo;
end;

procedure TQueryMapPanel.UpdateQuickInfo;
var
  I, VisCount: Integer;
begin
  VisCount := 0;
  for I := 0 to FPoints.Count - 1 do
    if TQMapPoint(FPoints[I]).Visible then
      Inc(VisCount);

  if FPoints.Count = 0 then
    FBtnToggleUnits.Caption := 'Unidades (0)'
  else if VisCount = FPoints.Count then
    FBtnToggleUnits.Caption := Format('Unidades (%d)', [FAllLabels.Count])
  else
    FBtnToggleUnits.Caption := Format('Unidades (%d/%d)', [VisCount, FPoints.Count]);

  if FHighlightLabel <> '' then
    FLblQuickInfo.Caption := 'Selecionada: ' + FHighlightLabel
  else if FViewPinned then
    FLblQuickInfo.Caption := Format('Posição fixada (Zoom %d)', [FPinnedZoom])
  else if (FPoints.Count > 0) and (VisCount < FPoints.Count) then
    FLblQuickInfo.Caption := Format('Exibindo %d de %d pontos', [VisCount, FPoints.Count])
  else
    FLblQuickInfo.Caption := '';
end;

procedure TQueryMapPanel.AutoCenter;
var
  I, VisCount: Integer;
  MinLat, MaxLat, MinLon, MaxLon, Span: Double;
  Pt: TQMapPoint;
  UseVisibleOnly: Boolean;
begin
  if FViewPinned then
  begin
    FCenterLat := FPinnedLat;
    FCenterLon := FPinnedLon;
    FZoom := FPinnedZoom;
    Exit;
  end;
  if FPoints.Count = 0 then Exit;
  VisCount := 0;
  for I := 0 to FPoints.Count - 1 do
    if TQMapPoint(FPoints[I]).Visible then Inc(VisCount);
  UseVisibleOnly := VisCount > 0;

  MinLat := 90; MaxLat := -90;
  MinLon := 180; MaxLon := -180;
  for I := 0 to FPoints.Count - 1 do
  begin
    Pt := TQMapPoint(FPoints[I]);
    if UseVisibleOnly and not Pt.Visible then Continue;
    if Pt.Lat < MinLat then MinLat := Pt.Lat;
    if Pt.Lat > MaxLat then MaxLat := Pt.Lat;
    if Pt.Lon < MinLon then MinLon := Pt.Lon;
    if Pt.Lon > MaxLon then MaxLon := Pt.Lon;
  end;
  FCenterLat := (MinLat + MaxLat) / 2.0;
  FCenterLon := (MinLon + MaxLon) / 2.0;
  Span := Max(MaxLat - MinLat, MaxLon - MinLon);
  if Span <= 0.02 then FZoom := 14
  else if Span <= 0.08 then FZoom := 12
  else if Span <= 0.3 then FZoom := 10
  else if Span <= 1.5 then FZoom := 8
  else if Span <= 6.0 then FZoom := 6
  else FZoom := 4;
end;

function TQueryMapPanel.LatLonToWorldX(Lon: Double; Zoom: Integer): Double;
begin
  Result := ((Lon + 180.0) / 360.0) * 256.0 * (1 shl Zoom);
end;

function TQueryMapPanel.LatLonToWorldY(Lat: Double; Zoom: Integer): Double;
var
  RadLat, SinLat: Double;
begin
  RadLat := DegToRad(Max(-85.0, Min(85.0, Lat)));
  SinLat := Sin(RadLat);
  Result := (0.5 - Ln((1.0 + SinLat) / (1.0 - SinLat)) / (4.0 * Pi)) * 256.0 * (1 shl Zoom);
end;

function TQueryMapPanel.WorldToScreen(WX, WY: Double): TPoint;
var
  CenterWX, CenterWY: Double;
begin
  CenterWX := LatLonToWorldX(FCenterLon, FZoom);
  CenterWY := LatLonToWorldY(FCenterLat, FZoom);
  Result.X := (FCanvas.Width div 2) + Round(WX - CenterWX);
  Result.Y := (FCanvas.Height div 2) + Round(WY - CenterWY);
end;

function TQueryMapPanel.GetTileBitmap(Z, X, Y: Integer): TBitmap;
var
  Key, FilePath, URL: string;
  PNG: TPortableNetworkGraphic;
  HTTP: TFPHTTPClient;
  MS: TMemoryStream;
  MaxTile: Integer;
begin
  Result := nil;
  MaxTile := (1 shl Z);
  if (Y < 0) or (Y >= MaxTile) then Exit;
  X := ((X mod MaxTile) + MaxTile) mod MaxTile;

  Key := Format('%d_%d_%d', [Z, X, Y]);
  Result := TBitmap(FTileCache.Items[Key]);
  if Result <> nil then Exit;

  FilePath := IncludeTrailingPathDelimiter(FCacheDir) + Key + '.png';
  if not FileExists(FilePath) then
  begin
    URL := Format('https://tile.openstreetmap.org/%d/%d/%d.png', [Z, X, Y]);
    HTTP := TFPHTTPClient.Create(nil);
    MS := TMemoryStream.Create;
    try
      HTTP.ConnectTimeout := 1500;
      HTTP.IOTimeout := 2000;
      HTTP.AddHeader('User-Agent', 'QueryBuilderSMSEquipamentos/2.1');
      try
        HTTP.Get(URL, MS);
        if MS.Size > 100 then
        begin
          MS.Position := 0;
          MS.SaveToFile(FilePath);
        end;
      except
      end;
    finally
      MS.Free;
      HTTP.Free;
    end;
  end;

  if FileExists(FilePath) then
  begin
    PNG := TPortableNetworkGraphic.Create;
    Result := TBitmap.Create;
    try
      try
        PNG.LoadFromFile(FilePath);
        Result.Assign(PNG);
        FTileCache.Add(Key, Result);
      except
        FreeAndNil(Result);
      end;
    finally
      PNG.Free;
    end;
  end;
end;

function TQueryMapPanel.HeatColor(Norm: Double): TColor;
var
  R, G, B: Byte;
begin
  Norm := Max(0.0, Min(1.0, Norm));
  if Norm < 0.5 then
  begin
    // Green -> Yellow
    R := Round((Norm * 2.0) * 235);
    G := 185;
    B := 40;
  end
  else
  begin
    // Yellow -> Red
    R := 235;
    G := Round((1.0 - (Norm - 0.5) * 2.0) * 185);
    B := 40;
  end;
  Result := RGBToColor(R, G, B);
end;

procedure TQueryMapPanel.CanvasPaint(Sender: TObject);
var
  W, H, I, TX, TY, StartTX, EndTX, StartTY, EndTY, LegX, LegY, VisCount: Integer;
  CenterWX, CenterWY, TopLeftWX, TopLeftWY, Norm: Double;
  TileBmp: TBitmap;
  G: TCanvas;
  Pt: TQMapPoint;
  Scr: TPoint;
  TipText: string;
  TipW, TipX, TipY: Integer;
begin
  W := FCanvas.Width;
  H := FCanvas.Height;
  if (W <= 0) or (H <= 0) then Exit;

  FBuffer.SetSize(W, H);
  G := FBuffer.Canvas;
  G.Brush.Color := RGBToColor(226, 232, 240);
  G.FillRect(0, 0, W, H);

  CenterWX := LatLonToWorldX(FCenterLon, FZoom);
  CenterWY := LatLonToWorldY(FCenterLat, FZoom);
  TopLeftWX := CenterWX - (W div 2);
  TopLeftWY := CenterWY - (H div 2);

  StartTX := Floor(TopLeftWX / 256.0);
  EndTX := Floor((TopLeftWX + W) / 256.0);
  StartTY := Floor(TopLeftWY / 256.0);
  EndTY := Floor((TopLeftWY + H) / 256.0);

  for TX := StartTX to EndTX do
    for TY := StartTY to EndTY do
    begin
      TileBmp := GetTileBitmap(FZoom, TX, TY);
      if TileBmp <> nil then
        G.Draw(Round(TX * 256.0 - TopLeftWX), Round(TY * 256.0 - TopLeftWY), TileBmp);
    end;

  if FPoints.Count = 0 then
  begin
    G.Brush.Color := clWhite;
    G.Pen.Color := RGBToColor(148, 163, 184);
    G.RoundRect(20, 20, 520, 74, 8, 8);
    G.Font.Name := 'Segoe UI';
    G.Font.Size := 10;
    G.Font.Color := RGBToColor(51, 65, 85);
    G.TextOut(34, 38, 'Execute uma consulta com colunas de Latitude/Longitude para plotar no mapa.');
    FCanvas.Canvas.Draw(0, 0, FBuffer);
    Exit;
  end;

  // Plot markers
  VisCount := 0;
  for I := 0 to FPoints.Count - 1 do
  begin
    Pt := TQMapPoint(FPoints[I]);
    if not Pt.Visible then Continue;
    Inc(VisCount);
    Scr := WorldToScreen(LatLonToWorldX(Pt.Lon, FZoom), LatLonToWorldY(Pt.Lat, FZoom));
    Pt.ScreenPt := Scr;
    if FMaxVal > FMinVal then
      Norm := (Pt.Value - FMinVal) / (FMaxVal - FMinVal)
    else
      Norm := 0.5;
    Pt.Radius := 7 + Round(Norm * 15);

    if (Scr.X + Pt.Radius < 0) or (Scr.X - Pt.Radius > W) or
       (Scr.Y + Pt.Radius < 0) or (Scr.Y - Pt.Radius > H) then
      Continue;

    if (FHighlightLabel <> '') and not SameText(FHighlightLabel, Pt.LabelText) then
      G.Brush.Color := RGBToColor(148, 163, 184)
    else
      G.Brush.Color := HeatColor(Norm);

    if (I = FHoverIndex) or ((FHighlightLabel <> '') and SameText(FHighlightLabel, Pt.LabelText)) then
    begin
      G.Pen.Color := clBlack;
      G.Pen.Width := 3;
    end
    else
    begin
      G.Pen.Color := clWhite;
      G.Pen.Width := 2;
    end;
    G.Ellipse(Scr.X - Pt.Radius, Scr.Y - Pt.Radius, Scr.X + Pt.Radius, Scr.Y + Pt.Radius);
    G.Pen.Width := 1;

    if Pt.LabelText <> '' then
    begin
      G.Font.Name := 'Segoe UI';
      G.Font.Size := 8;
      G.Font.Style := [fsBold];
      G.Brush.Style := bsClear;
      if (FHighlightLabel <> '') and not SameText(FHighlightLabel, Pt.LabelText) then
        G.Font.Color := RGBToColor(100, 116, 139)
      else
        G.Font.Color := RGBToColor(15, 23, 42);
      G.TextOut(Scr.X + Pt.Radius + 4, Scr.Y - 7, Copy(Pt.LabelText, 1, 22));
      G.Brush.Style := bsSolid;
    end;
  end;

  // Legend box (bottom-left)
  LegX := 14;
  LegY := H - 68;
  G.Brush.Color := clWhite;
  G.Pen.Color := RGBToColor(148, 163, 184);
  G.RoundRect(LegX, LegY, LegX + 230, LegY + 54, 6, 6);
  G.Font.Name := 'Segoe UI';
  G.Font.Size := 8;
  G.Font.Style := [fsBold];
  G.Font.Color := RGBToColor(30, 41, 59);
  if VisCount = FPoints.Count then
    G.TextOut(LegX + 10, LegY + 6, Format('Pontos: %d | Zoom: %d', [FPoints.Count, FZoom]))
  else
    G.TextOut(LegX + 10, LegY + 6, Format('Pontos: %d/%d | Zoom: %d', [VisCount, FPoints.Count, FZoom]));
  G.Brush.Color := HeatColor(0.0); G.Rectangle(LegX + 10, LegY + 26, LegX + 55, LegY + 38);
  G.Brush.Color := HeatColor(0.5); G.Rectangle(LegX + 55, LegY + 26, LegX + 100, LegY + 38);
  G.Brush.Color := HeatColor(1.0); G.Rectangle(LegX + 100, LegY + 26, LegX + 145, LegY + 38);
  G.Brush.Color := clWhite;
  G.Font.Style := [];
  G.TextOut(LegX + 152, LegY + 25, FormatNum(FMinVal) + '..' + FormatNum(FMaxVal));

  // Hover tooltip
  if (FHoverIndex >= 0) and (FHoverIndex < FPoints.Count) then
  begin
    Pt := TQMapPoint(FPoints[FHoverIndex]);
    TipText := Format('%s | Valor: %s (%.4f, %.4f)', [Pt.LabelText, FormatNum(Pt.Value), Pt.Lat, Pt.Lon]);
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
  end;

  FCanvas.Canvas.Draw(0, 0, FBuffer);
end;

procedure TQueryMapPanel.ControlsChange(Sender: TObject);
begin
  RebuildPoints;
  AutoCenter;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.BtnZoomInClick(Sender: TObject);
begin
  if FZoom < 18 then Inc(FZoom);
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.BtnZoomOutClick(Sender: TObject);
begin
  if FZoom > 2 then Dec(FZoom);
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.BtnCenterClick(Sender: TObject);
begin
  AutoCenter;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.BtnExportPNGClick(Sender: TObject);
var
  Dlg: TSaveDialog;
  PNG: TPortableNetworkGraphic;
begin
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Title := 'Exportar Mapa';
    Dlg.Filter := 'Imagem PNG (*.png)|*.png';
    Dlg.DefaultExt := 'png';
    Dlg.FileName := 'mapa_querybuilder.png';
    if Dlg.Execute then
    begin
      CanvasPaint(Self);
      PNG := TPortableNetworkGraphic.Create;
      try
        PNG.Assign(FBuffer);
        PNG.SaveToFile(Dlg.FileName);
        ShowMessage('Mapa salvo em: ' + Dlg.FileName);
      finally
        PNG.Free;
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TQueryMapPanel.BtnOpenHTMLClick(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
  Pt: TQMapPoint;
  FS: TFormatSettings;
  HtmlFile, JSPoints, EscLbl: string;
begin
  if FPoints.Count = 0 then
  begin
    ShowMessage('Execute uma consulta com Latitude/Longitude antes de abrir o mapa HTML.');
    Exit;
  end;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  JSPoints := '';
  for I := 0 to FPoints.Count - 1 do
  begin
    Pt := TQMapPoint(FPoints[I]);
    if not Pt.Visible then Continue;
    EscLbl := StringReplace(Pt.LabelText, '"', '\"', [rfReplaceAll]);
    if JSPoints <> '' then JSPoints := JSPoints + ',';
    JSPoints := JSPoints + Format('{"lat":%s,"lon":%s,"val":%s,"label":"%s"}', [
      FloatToStr(Pt.Lat, FS), FloatToStr(Pt.Lon, FS), FloatToStr(Pt.Value, FS), EscLbl]);
  end;

  HtmlFile := IncludeTrailingPathDelimiter(FCacheDir) + 'mapa_interativo.html';
  SL := TStringList.Create;
  try
    SL.Add('<!DOCTYPE html><html><head><meta charset="utf-8"><title>QueryBuilder - Mapa</title>');
    SL.Add('<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>');
    SL.Add('<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>');
    SL.Add('<style>html,body,#map{height:100%;margin:0;padding:0;font-family:Segoe UI,sans-serif;}</style></head><body>');
    SL.Add('<div id="map"></div><script>');
    SL.Add(Format('var map = L.map("map").setView([%s,%s], %d);', [
      FloatToStr(FCenterLat, FS), FloatToStr(FCenterLon, FS), FZoom]));
    SL.Add('L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",{attribution:"© OpenStreetMap"}).addTo(map);');
    SL.Add('var pts = [' + JSPoints + '];');
    SL.Add('var maxV = Math.max.apply(null, pts.map(p=>p.val)) || 1;');
    SL.Add('pts.forEach(p=>{ var r = 8 + (p.val/maxV)*18;');
    SL.Add('L.circleMarker([p.lat,p.lon],{radius:r,color:"#fff",weight:2,fillColor:"#ef4444",fillOpacity:0.8}).bindPopup("<b>"+p.label+"</b><br>Valor: "+p.val).addTo(map); });');
    SL.Add('</script></body></html>');
    SL.SaveToFile(HtmlFile);
    OpenDocument(HtmlFile);
  finally
    SL.Free;
  end;
end;

procedure TQueryMapPanel.BtnToggleUnitsClick(Sender: TObject);
begin
  FUnitPanel.Visible := not FUnitPanel.Visible;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.BtnPinViewClick(Sender: TObject);
begin
  if not FCanPinView then Exit;
  if not FViewPinned then
  begin
    FViewPinned := True;
    FPinnedLat := FCenterLat;
    FPinnedLon := FCenterLon;
    FPinnedZoom := FZoom;
    FBtnPinView.Caption := 'Desafixar Posição';
  end
  else
  begin
    FViewPinned := False;
    FBtnPinView.Caption := 'Fixar Posição';
  end;
  UpdateQuickInfo;
  if Assigned(FOnViewPinChange) then
    FOnViewPinChange(Self, FViewPinned, FPinnedLat, FPinnedLon, FPinnedZoom);
end;

procedure TQueryMapPanel.BtnSelectAllClick(Sender: TObject);
var
  I: Integer;
  Lbl: string;
begin
  for I := 0 to FChkUnits.Items.Count - 1 do
  begin
    FChkUnits.Checked[I] := True;
    Lbl := FChkUnits.Items[I];
    while FHiddenLabels.IndexOf(Lbl) >= 0 do
      FHiddenLabels.Delete(FHiddenLabels.IndexOf(Lbl));
  end;
  UpdateVisibilityAndRange;
  AutoCenter;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.BtnSelectNoneClick(Sender: TObject);
var
  I: Integer;
  Lbl: string;
begin
  for I := 0 to FChkUnits.Items.Count - 1 do
  begin
    FChkUnits.Checked[I] := False;
    Lbl := FChkUnits.Items[I];
    if FHiddenLabels.IndexOf(Lbl) < 0 then
      FHiddenLabels.Add(Lbl);
  end;
  UpdateVisibilityAndRange;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.UnitSearchChange(Sender: TObject);
begin
  RefreshUnitChecklist;
end;

procedure TQueryMapPanel.ChkUnitsClickCheck(Sender: TObject);
var
  I, HIdx: Integer;
  Lbl: string;
begin
  for I := 0 to FChkUnits.Items.Count - 1 do
  begin
    Lbl := FChkUnits.Items[I];
    HIdx := FHiddenLabels.IndexOf(Lbl);
    if FChkUnits.Checked[I] then
    begin
      if HIdx >= 0 then FHiddenLabels.Delete(HIdx);
    end
    else
    begin
      if HIdx < 0 then FHiddenLabels.Add(Lbl);
    end;
  end;
  UpdateVisibilityAndRange;
  FCanvas.Invalidate;
end;

procedure TQueryMapPanel.CanvasMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FPanning := True;
    FPanMoved := False;
    FPanStart := Point(X, Y);
    FPanStartCenterLat := FCenterLat;
    FPanStartCenterLon := FCenterLon;
  end;
end;

procedure TQueryMapPanel.CanvasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  I, NewHover: Integer;
  Pt: TQMapPoint;
  DX, DY: Integer;
  ScaleDegPerPx: Double;
begin
  FHoverPos := Point(X, Y);
  if FPanning then
  begin
    if (Abs(X - FPanStart.X) > 4) or (Abs(Y - FPanStart.Y) > 4) then
      FPanMoved := True;
    ScaleDegPerPx := 360.0 / (256.0 * (1 shl FZoom));
    FCenterLon := FPanStartCenterLon - (X - FPanStart.X) * ScaleDegPerPx;
    FCenterLat := Max(-85.0, Min(85.0, FPanStartCenterLat + (Y - FPanStart.Y) * ScaleDegPerPx * Cos(DegToRad(FCenterLat))));
    FCanvas.Invalidate;
    Exit;
  end;

  NewHover := -1;
  for I := FPoints.Count - 1 downto 0 do
  begin
    Pt := TQMapPoint(FPoints[I]);
    if not Pt.Visible then Continue;
    DX := X - Pt.ScreenPt.X;
    DY := Y - Pt.ScreenPt.Y;
    if DX * DX + DY * DY <= Pt.Radius * Pt.Radius then
    begin
      NewHover := I;
      Break;
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

procedure TQueryMapPanel.CanvasMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I, DX, DY: Integer;
  Pt: TQMapPoint;
begin
  if (Button = mbLeft) and FPanning and (not FPanMoved) then
  begin
    for I := FPoints.Count - 1 downto 0 do
    begin
      Pt := TQMapPoint(FPoints[I]);
      if not Pt.Visible then Continue;
      DX := X - Pt.ScreenPt.X;
      DY := Y - Pt.ScreenPt.Y;
      if DX * DX + DY * DY <= Pt.Radius * Pt.Radius then
      begin
        if SameText(FHighlightLabel, Pt.LabelText) then
          FHighlightLabel := ''
        else
          FHighlightLabel := Pt.LabelText;
        UpdateQuickInfo;
        FCanvas.Invalidate;
        if Assigned(FOnPointClick) then
          FOnPointClick(Self, Pt.LabelText);
        Break;
      end;
    end;
  end;
  FPanning := False;
  FPanMoved := False;
end;

procedure TQueryMapPanel.CanvasMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta > 0 then
    BtnZoomInClick(Self)
  else if WheelDelta < 0 then
    BtnZoomOutClick(Self);
  Handled := True;
end;

end.
