unit mnote_db_diagram_form;
{$mode objfpc}{$H+}{$codepage utf8}
interface
uses Classes, SysUtils, Math, Types, Forms, Controls, Graphics, ExtCtrls,
  StdCtrls, Dialogs, ComCtrls, ZConnection, fpjson, jsonparser,
  mnote_db_diagram_model, mnote_db_diagram_reader, mnote_db_diagram_layout, mnote_db_diagram_job;
type
  TDatabaseDiagramForm = class(TForm)
  private
    FConnection: TZConnection;
    FJob: IDiagramJob;
    FPoll: TTimer;
    FProgress: TProgressBar;
    FRefreshButton, FCancelButton: TButton;
    FContext: TDiagramContext;
    FRequestedTable: string;
    FModel: TDiagramModel;
    FScroll: TScrollBox;
    FPaint: TPaintBox;
    FStatus: TLabel;
    FFilter: TEdit;
    FZoom: Double;
    FDrag: TDiagramTable;
    FOffset: TPoint;
    procedure PollJob(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    function GetLoading: Boolean;
    function GetStatusText: string;
    function TableVisible(T: TDiagramTable): Boolean;
    procedure FilterChanged(Sender: TObject);
    procedure FitClick(Sender: TObject);
    procedure ShowAllClick(Sender: TObject);
    procedure DrawDiagram(C: TCanvas);
    procedure PaintDiagram(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure MouseDownDiagram(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMoveDiagram(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MouseUpDiagram(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RefreshClick(Sender: TObject);
    procedure ArrangeClick(Sender: TObject);
    procedure ZoomClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure CloseDiagram(Sender: TObject; var CloseAction: TCloseAction);
    procedure ResizeCanvas;
    function LayoutFile: string;
    procedure RestoreLayout;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor CreateFor(AOwner: TComponent; C: TZConnection; const Context: TDiagramContext; const ATable: string = '');
    destructor Destroy; override;
    procedure ExportImage(const AFileName: string);
    procedure RefreshDatabase;
    procedure CancelLoading;
    property Loading: Boolean read GetLoading;
    property StatusText: string read GetStatusText;
  end;
procedure OpenDatabaseDiagram(AOwner: TComponent; C: TZConnection; const ASchema: string; const ATable: string = '');
implementation
procedure OpenDatabaseDiagram(AOwner: TComponent; C: TZConnection; const ASchema: string; const ATable: string);
var F: TDatabaseDiagramForm;
begin
  if (C = nil) or not C.Connected then begin
    MessageDlg('Diagrama', 'Conecte o banco desta pasta antes de abrir o diagrama.', mtInformation, [mbOK], 0); Exit;
  end;
  F := TDatabaseDiagramForm.CreateFor(AOwner, C, DiagramConnectionContext(C, ASchema), ATable);
  F.Show;
end;
constructor TDatabaseDiagramForm.CreateFor(AOwner: TComponent; C: TZConnection; const Context: TDiagramContext; const ATable: string);
var Bar: TPanel;
  procedure AddButton(const ACaption: string; ALeft, AWidth, ATag: Integer; Handler: TNotifyEvent);
  var B: TButton;
  begin
    B := TButton.Create(Self); B.Parent := Bar; B.Caption := ACaption;
    B.SetBounds(ALeft, 5, AWidth, 28); B.Tag := ATag; B.OnClick := Handler;
    if ALeft = 5 then FRefreshButton := B;
    if ALeft = 845 then FCancelButton := B;
  end;
begin
  inherited CreateNew(AOwner);
  FRequestedTable := ATable;
  FConnection := C; C.FreeNotification(Self); FContext := Context; FZoom := 1;
  Caption := 'Diagrama — ' + Context.Protocol + ' — ' + Context.Host +
    ' / ' + Context.DatabaseName + ' / ' + Context.SchemaName;
  Width := 1100; Height := 760; Position := poScreenCenter;
  OnClose := @CloseDiagram;
  Bar := TPanel.Create(Self); Bar.Parent := Self; Bar.Align := alTop; Bar.Height := 40;
  AddButton('Atualizar', 5, 90, 0, @RefreshClick);
  AddButton('Organizar', 100, 90, 0, @ArrangeClick);
  AddButton('−', 195, 40, -1, @ZoomClick);
  AddButton('+', 240, 40, 1, @ZoomClick);
  AddButton('Salvar posições', 285, 125, 0, @SaveClick);
  AddButton('Exportar PNG', 415, 115, 0, @ExportClick);
  AddButton('Ajustar', 535, 80, 0, @FitClick);
  AddButton('Todas', 935, 65, 0, @ShowAllClick);
  AddButton('Cancelar', 845, 85, 0, @CancelClick); FCancelButton.Enabled := False;
  FFilter := TEdit.Create(Self); FFilter.Parent := Bar;
  FFilter.SetBounds(620, 7, 220, 24); FFilter.TextHint := 'Filtrar schema ou tabela';
  FFilter.OnChange := @FilterChanged;
  FStatus := TLabel.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom;
  FStatus.AutoSize := False; FStatus.Height := 38;
  FProgress := TProgressBar.Create(Self); FProgress.Parent := Self;
  FProgress.Align := alBottom; FProgress.Height := 16; FProgress.Visible := False;
  FScroll := TScrollBox.Create(Self); FScroll.Parent := Self; FScroll.Align := alClient;
  FPaint := TPaintBox.Create(Self); FPaint.Parent := FScroll;
  FPaint.OnPaint := @PaintDiagram; FPaint.OnMouseDown := @MouseDownDiagram;
  FPaint.OnMouseMove := @MouseMoveDiagram; FPaint.OnMouseUp := @MouseUpDiagram;
  FPoll := TTimer.Create(Self); FPoll.Interval := 100; FPoll.Enabled := False;
  FPoll.OnTimer := @PollJob;
  RefreshClick(nil);
end;
destructor TDatabaseDiagramForm.Destroy;
begin
  if FPoll <> nil then FPoll.Enabled := False;
  if FJob <> nil then FJob.Cancel;
  FJob := nil; FModel.Free; inherited Destroy;
end;
procedure TDatabaseDiagramForm.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FConnection) then begin
    FConnection := nil;
    if FJob <> nil then FJob.Cancel;
  end;
end;
procedure TDatabaseDiagramForm.CloseDiagram(Sender: TObject; var CloseAction: TCloseAction);
begin CloseAction := caFree; end;
procedure TDatabaseDiagramForm.RefreshDatabase;
begin RefreshClick(nil); end;
procedure TDatabaseDiagramForm.CancelLoading;
begin CancelClick(nil); end;
function TDatabaseDiagramForm.GetLoading: Boolean;
begin Result := FJob <> nil; end;
function TDatabaseDiagramForm.GetStatusText: string;
begin Result := FStatus.Caption; end;
procedure TDatabaseDiagramForm.CancelClick(Sender: TObject);
begin
  if FJob = nil then Exit;
  FJob.Cancel; FCancelButton.Enabled := False;
  FStatus.Caption := 'Cancelamento solicitado. Aguardando a operação do driver; snapshot anterior preservado.';
end;
procedure TDatabaseDiagramForm.RefreshClick(Sender: TObject);
begin
  if FJob <> nil then Exit;
  try
    FJob := StartDiagramJob(FConnection, FContext);
    FRefreshButton.Enabled := False; FCancelButton.Enabled := True;
    FProgress.Position := 0; FProgress.Visible := True;
    FStatus.Caption := 'Lendo metadados em segundo plano...'; FPoll.Enabled := True;
  except on E: Exception do FStatus.Caption := E.Message; end;
end;
procedure TDatabaseDiagramForm.PollJob(Sender: TObject);
var State: TDiagramJobStatus; NewModel: TDiagramModel; FirstLoad: Boolean;
begin
  if FJob = nil then Exit;
  if (FConnection = nil) or not FConnection.Connected then FJob.Cancel
  else if DiagramContextKey(DiagramConnectionContext(FConnection, FContext.SchemaName)) <>
    DiagramContextKey(FContext) then FJob.Cancel;
  State := FJob.Status;
  if not State.Done then begin
    if not State.Cancelled then begin
      FStatus.Caption := Format('%s (%d/%d)', [State.Stage, State.Position, State.Total]);
      FProgress.Max := Max(1, State.Total); FProgress.Position := State.Position;
    end;
    Exit;
  end;
  FPoll.Enabled := False; FRefreshButton.Enabled := True; FCancelButton.Enabled := False;
  FProgress.Visible := False;
  NewModel := FJob.TakeModel; FJob := nil;
  if State.Cancelled then begin
    NewModel.Free; FStatus.Caption := 'Leitura cancelada; snapshot anterior preservado.'; Exit;
  end;
  if (State.ErrorText <> '') or (NewModel = nil) then begin
    NewModel.Free; FStatus.Caption := 'Falha na leitura; snapshot anterior preservado. ' + State.ErrorText; Exit;
  end;
  FirstLoad := FModel = nil;
  NewModel.PreserveView(FModel);
  FDrag := nil; SetCaptureControl(nil); FModel.Free; FModel := NewModel;
  FStatus.Caption := Format('%d tabelas; %d relacionamentos. Snapshot de %s.',
    [FModel.Tables.Count, FModel.Relations.Count, TimeToStr(Now)]);
  if FModel.Warnings.Count > 0 then FStatus.Caption := FStatus.Caption + LineEnding + FModel.Warnings[0];
  if FirstLoad then
    try
      RestoreLayout;
      if FRequestedTable <> '' then FModel.FocusTable(FRequestedTable);
    except on E: Exception do FStatus.Caption := E.Message; end;
  FFilter.Text := FModel.FilterText;
  ResizeCanvas;
end;
procedure TDatabaseDiagramForm.ResizeCanvas;
var I, W, H: Integer; T: TDiagramTable;
begin
  W := 1000; H := 600;
  if FModel <> nil then for I := 0 to FModel.Tables.Count - 1 do begin
    T := TDiagramTable(FModel.Tables[I]); if not TableVisible(T) then Continue; W := Max(W, T.X + 360);
    H := Max(H, T.Y + 70 + T.Columns.Count * 20);
  end;
  FPaint.SetBounds(0, 0, Round(W * FZoom), Round(H * FZoom)); FPaint.Invalidate;
end;
function TDatabaseDiagramForm.TableVisible(T: TDiagramTable): Boolean;
begin Result := (FModel <> nil) and FModel.MatchesView(T); end;
procedure TDatabaseDiagramForm.FilterChanged(Sender: TObject);
begin
  if FModel <> nil then FModel.FilterText := FFilter.Text;
  ResizeCanvas;
end;
procedure TDatabaseDiagramForm.ShowAllClick(Sender: TObject);
begin
  if FModel <> nil then begin FModel.FocusKey := ''; FModel.FilterText := ''; end;
  FFilter.Text := ''; ResizeCanvas;
end;
procedure TDatabaseDiagramForm.FitClick(Sender: TObject);
begin
  FZoom := 1; ResizeCanvas;
  FZoom := EnsureRange(Min(FScroll.ClientWidth / Max(1, FPaint.Width),
    FScroll.ClientHeight / Max(1, FPaint.Height)), 0.4, 2.0);
  ResizeCanvas; FScroll.HorzScrollBar.Position := 0; FScroll.VertScrollBar.Position := 0;
end;
procedure TDatabaseDiagramForm.PaintDiagram(Sender: TObject);
begin DrawDiagram(FPaint.Canvas); end;
procedure TDatabaseDiagramForm.DrawDiagram(C: TCanvas);
var I, J, N, X1, X2, Y1, Y2, Bend, ArrowX: Integer;
  T, A, B: TDiagramTable; Col: TDiagramColumn; R: TDiagramRelation; P: TDiagramPair; S: string;
  function Z(V: Integer): Integer; begin Result := Round(V * FZoom); end;
begin
  C.Brush.Color := clWhite; C.FillRect(FPaint.ClientRect);
  if FModel = nil then Exit;
  C.Font.Size := Max(6, Round(9 * FZoom));
  C.Pen.Color := $886644;
  for I := 0 to FModel.Relations.Count - 1 do begin
    R := TDiagramRelation(FModel.Relations[I]);
    A := FModel.FindTable(R.SourceKey); B := FModel.FindTable(R.TargetKey);
    if (A = nil) or (B = nil) then Continue;
    if not TableVisible(A) or not TableVisible(B) then Continue;
    case I mod 3 of
      0: C.Pen.Color := $995522;
      1: C.Pen.Color := $338833;
      2: C.Pen.Color := $774499;
    end;
    for J := 0 to R.Pairs.Count - 1 do begin
      P := TDiagramPair(R.Pairs[J]); N := A.ColumnIndex(P.SourceColumn);
      if N < 0 then Continue;
      Y1 := A.Y + 40 + N * 20; N := B.ColumnIndex(P.TargetColumn);
      if N < 0 then Continue;
      Y2 := B.Y + 40 + N * 20; X1 := A.X + 290; X2 := B.X;
      if A.X = B.X then begin X2 := B.X + 290; Bend := X1 + 25 + (I mod 6) * 8; end
      else begin
        if B.X < A.X then begin X1 := A.X; X2 := B.X + 290; end;
        Bend := (X1 + X2) div 2 + (I mod 5 - 2) * 4;
      end;
      C.MoveTo(Z(X1), Z(Y1)); C.LineTo(Z(Bend), Z(Y1));
      C.LineTo(Z(Bend), Z(Y2)); C.LineTo(Z(X2), Z(Y2));
      C.Ellipse(Z(X1 - 3), Z(Y1 - 3), Z(X1 + 3), Z(Y1 + 3));
      if X2 = B.X then ArrowX := X2 - 7 else ArrowX := X2 + 7;
      C.MoveTo(Z(ArrowX), Z(Y2 - 4)); C.LineTo(Z(X2), Z(Y2)); C.LineTo(Z(ArrowX), Z(Y2 + 4));
    end;
  end;
  for I := 0 to FModel.Tables.Count - 1 do begin
    T := TDiagramTable(FModel.Tables[I]); if not TableVisible(T) then Continue; C.Pen.Color := clGray;
    C.Brush.Color := $FFF6EB;
    C.Rectangle(Z(T.X), Z(T.Y), Z(T.X + 290), Z(T.Y + 32 + 20 * T.Columns.Count));
    C.Brush.Color := $E8D5BE;
    C.Rectangle(Z(T.X), Z(T.Y), Z(T.X + 290), Z(T.Y + 29));
    C.Font.Color := clBlack; C.Font.Style := [fsBold];
    C.TextRect(Rect(Z(T.X + 4), Z(T.Y + 3), Z(T.X + 287), Z(T.Y + 27)),
      Z(T.X + 5), Z(T.Y + 5), T.Caption);
    C.Font.Style := []; C.Brush.Color := $FFF6EB;
    for J := 0 to T.Columns.Count - 1 do begin
      Col := TDiagramColumn(T.Columns[J]); S := '';
      if Col.PrimaryPosition > 0 then S := 'PK ';
      if Col.ForeignKey then S := S + 'FK ';
      S := S + Col.Name + ' : ' + Col.DataType;
      if not Col.Nullable then S := S + ' *';
      C.TextRect(Rect(Z(T.X + 4), Z(T.Y + 30 + J * 20), Z(T.X + 287), Z(T.Y + 50 + J * 20)),
        Z(T.X + 5), Z(T.Y + 31 + J * 20), S);
    end;
  end;
end;
procedure TDatabaseDiagramForm.MouseDownDiagram(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var I: Integer; T: TDiagramTable;
begin
  if (Button <> mbLeft) or (FModel = nil) then Exit;
  X := Round(X / FZoom); Y := Round(Y / FZoom);
  for I := FModel.Tables.Count - 1 downto 0 do begin
    T := TDiagramTable(FModel.Tables[I]);
    if not TableVisible(T) then Continue;
    if (X >= T.X) and (X <= T.X + 290) and (Y >= T.Y) and (Y <= T.Y + 29) then begin
      FDrag := T; FOffset := Point(X - T.X, Y - T.Y); SetCaptureControl(FPaint); Exit;
    end;
  end;
end;
procedure TDatabaseDiagramForm.MouseMoveDiagram(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FDrag = nil then Exit;
  FDrag.X := Max(0, Round(X / FZoom) - FOffset.X);
  FDrag.Y := Max(0, Round(Y / FZoom) - FOffset.Y); FPaint.Invalidate;
end;
procedure TDatabaseDiagramForm.MouseUpDiagram(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin FDrag := nil; SetCaptureControl(nil); ResizeCanvas; end;
procedure TDatabaseDiagramForm.ArrangeClick(Sender: TObject);
begin if FModel <> nil then FModel.Arrange; ResizeCanvas; end;
procedure TDatabaseDiagramForm.ZoomClick(Sender: TObject);
begin FZoom := EnsureRange(FZoom + TControl(Sender).Tag * 0.1, 0.4, 2.0); ResizeCanvas; end;
function TDatabaseDiagramForm.LayoutFile: string;
begin Result := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) + 'diagrams' + PathDelim + DiagramContextKey(FContext) + '.json'; end;
procedure TDatabaseDiagramForm.SaveClick(Sender: TObject);
begin
  if FModel = nil then Exit;
  try
    SaveDiagramLayout(FModel, FZoom, LayoutFile);
    FStatus.Caption := 'Posições salvas para este banco.';
  except on E: Exception do FStatus.Caption := 'Erro ao salvar: ' + E.Message; end;
end;
procedure TDatabaseDiagramForm.RestoreLayout;
begin LoadDiagramLayout(FModel, FZoom, LayoutFile); end;
procedure TDatabaseDiagramForm.ExportImage(const AFileName: string);
var Bitmap: TBitmap; PNG: TPortableNetworkGraphic;
begin
  if FModel = nil then raise Exception.Create('Carregue o diagrama antes de exportar.');
  if (FPaint.Width > 16000) or (FPaint.Height > 16000) or
    (Int64(FPaint.Width) * FPaint.Height > 32000000) then
    raise Exception.Create('Reduza o zoom antes de exportar este diagrama.');
  Bitmap := TBitmap.Create; PNG := TPortableNetworkGraphic.Create;
  try
    Bitmap.SetSize(FPaint.Width, FPaint.Height); DrawDiagram(Bitmap.Canvas);
    PNG.Assign(Bitmap); PNG.SaveToFile(AFileName);
  finally PNG.Free; Bitmap.Free; end;
end;
procedure TDatabaseDiagramForm.ExportClick(Sender: TObject);
var Dialog: TSaveDialog;
begin
  Dialog := TSaveDialog.Create(Self);
  try
    Dialog.Filter := 'Imagem PNG|*.png'; Dialog.DefaultExt := 'png';
    Dialog.Options := Dialog.Options + [ofOverwritePrompt];
    if Dialog.Execute then
      try ExportImage(Dialog.FileName); FStatus.Caption := 'Imagem exportada.';
      except on E: Exception do FStatus.Caption := 'Erro ao exportar: ' + E.Message; end;
  finally Dialog.Free; end;
end;
end.
