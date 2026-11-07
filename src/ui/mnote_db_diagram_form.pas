unit mnote_db_diagram_form;
{$mode objfpc}{$H+}{$codepage utf8}
interface
uses Classes, SysUtils, Math, Types, Forms, Controls, Graphics, ExtCtrls,
  StdCtrls, Dialogs, ComCtrls, Menus, LCLType, CheckLst, ZConnection, fpjson, jsonparser,
  mnote_db_diagram_model, mnote_db_diagram_reader, mnote_db_diagram_layout, mnote_db_diagram_job;
type
  TDatabaseDiagramForm = class(TForm)
  private
    FConnection: TZConnection;
    FJob: IDiagramJob;
    FPoll: TTimer;
    FProgress: TProgressBar;
    FRefreshButton, FCancelButton, FRemoveButton: TButton;
    FContext: TDiagramContext;
    FRequestedTable: string;
    FModel: TDiagramModel;
    FScroll: TScrollBox;
    FPaint: TPaintBox;
    FStatus: TLabel;
    FFilter: TEdit;
    FZoom: Double;
    FDrag: TDiagramTable;
    FSelected: TDiagramTable;
    FOffset: TPoint;
    FMenu: TPopupMenu;
    FMenuRemove, FMenuShowHidden, FMenuInclude, FMenuIncludeRelated: TMenuItem;
    FExporting: Boolean;
    procedure PollJob(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    function GetLoading: Boolean;
    function GetStatusText: string;
    function TableVisible(T: TDiagramTable): Boolean;
    function TableHeight(T: TDiagramTable): Integer;
    function TableAt(X, Y: Integer): TDiagramTable;
    procedure FilterChanged(Sender: TObject);
    procedure FitClick(Sender: TObject);
    procedure ShowAllClick(Sender: TObject);
    procedure DrawDiagram(C: TCanvas);
    procedure PaintDiagram(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure MouseDownDiagram(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMoveDiagram(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MouseUpDiagram(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseWheelDiagram(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);
    procedure KeyDownDiagram(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RemoveClick(Sender: TObject);
    procedure IncludeClick(Sender: TObject);
    procedure IncludeRelatedClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure IncludeTables(AList: TList);
    procedure ShowHiddenClick(Sender: TObject);
    procedure MenuPopup(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure ArrangeClick(Sender: TObject);
    procedure ZoomClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure CloseDiagram(Sender: TObject; var CloseAction: TCloseAction);
    procedure SetZoomAt(ANewZoom: Double; const AScreenPoint: TPoint);
    procedure UpdateStatus;
    procedure ResizeCanvas;
    function LayoutFile: string;
    procedure RestoreLayout;
    function RenderBitmap: TBitmap;
    procedure ExportPNG(const AFileName: string);
    procedure ExportJPG(const AFileName: string);
    procedure ExportPDF(const AFileName: string);
    procedure ExportMarkdown(const AFileName: string);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor CreateFor(AOwner: TComponent; C: TZConnection; const Context: TDiagramContext; const ATable: string = '');
    destructor Destroy; override;
    { Exporta a visao atual; o formato sai da extensao: .png, .jpg/.jpeg, .pdf ou .md }
    procedure ExportImage(const AFileName: string);
    procedure RefreshDatabase;
    procedure CancelLoading;
    property Loading: Boolean read GetLoading;
    property StatusText: string read GetStatusText;
  end;
procedure OpenDatabaseDiagram(AOwner: TComponent; C: TZConnection; const ASchema: string; const ATable: string = '');
implementation
const
  TABLE_WIDTH = 290;
  ZOOM_STEP = 1.1;
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
  function AddButton(const ACaption: string; ALeft, AWidth, ATag: Integer; Handler: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self); Result.Parent := Bar; Result.Caption := ACaption;
    Result.SetBounds(ALeft, 5, AWidth, 28); Result.Tag := ATag; Result.OnClick := Handler;
  end;
begin
  inherited CreateNew(AOwner);
  FRequestedTable := ATable;
  FConnection := C; C.FreeNotification(Self); FContext := Context; FZoom := 1;
  Caption := 'Diagrama — ' + Context.Protocol + ' — ' + Context.Host +
    ' / ' + Context.DatabaseName + ' / ' + Context.SchemaName;
  Width := 1180; Height := 760; Position := poScreenCenter;
  OnClose := @CloseDiagram;
  KeyPreview := True; OnKeyDown := @KeyDownDiagram;
  Bar := TPanel.Create(Self); Bar.Parent := Self; Bar.Align := alTop; Bar.Height := 40;
  FRefreshButton := AddButton('Atualizar', 5, 85, 0, @RefreshClick);
  AddButton('Organizar', 95, 85, 0, @ArrangeClick);
  AddButton('−', 185, 32, -1, @ZoomClick).Hint := 'Diminuir zoom (ou role a roda do mouse para trás)';
  AddButton('+', 222, 32, 1, @ZoomClick).Hint := 'Aumentar zoom (ou role a roda do mouse para frente)';
  AddButton('Salvar posições', 259, 115, 0, @SaveClick).Hint :=
    'Salvar posições, zoom e quais tabelas estão no diagrama';
  AddButton('Exportar...', 379, 95, 0, @ExportClick).Hint := 'Salvar a visão atual em PDF, JPG, PNG ou Markdown';
  AddButton('Ajustar', 479, 70, 0, @FitClick);
  FCancelButton := AddButton('Cancelar', 749, 80, 0, @CancelClick); FCancelButton.Enabled := False;
  AddButton('Todas', 834, 60, 0, @ShowAllClick).Hint := 'Limpar filtro e foco e mostrar todas as tabelas';
  AddButton('Incluir...', 899, 85, 0, @IncludeClick).Hint :=
    'Incluir tabelas no diagrama; os vínculos (FK) aparecem sozinhos';
  FRemoveButton := AddButton('Remover', 989, 75, 0, @RemoveClick);
  FRemoveButton.Hint := 'Remover a tabela selecionada do diagrama (tecla Delete). Não apaga do banco.';
  FRemoveButton.Enabled := False;
  AddButton('Limpar', 1069, 70, 0, @ClearClick).Hint :=
    'Esvaziar o diagrama para montar só com as tabelas que você incluir';
  Bar.ShowHint := True;
  FFilter := TEdit.Create(Self); FFilter.Parent := Bar;
  FFilter.SetBounds(554, 7, 190, 24); FFilter.TextHint := 'Filtrar schema ou tabela';
  FFilter.OnChange := @FilterChanged;
  FStatus := TLabel.Create(Self); FStatus.Parent := Self; FStatus.Align := alBottom;
  FStatus.AutoSize := False; FStatus.Height := 38;
  FProgress := TProgressBar.Create(Self); FProgress.Parent := Self;
  FProgress.Align := alBottom; FProgress.Height := 16; FProgress.Visible := False;

  FMenu := TPopupMenu.Create(Self); FMenu.OnPopup := @MenuPopup;
  FMenuInclude := TMenuItem.Create(FMenu); FMenuInclude.Caption := 'Incluir tabelas...';
  FMenuInclude.OnClick := @IncludeClick; FMenu.Items.Add(FMenuInclude);
  FMenuIncludeRelated := TMenuItem.Create(FMenu); FMenuIncludeRelated.Caption := 'Incluir tabelas ligadas a esta';
  FMenuIncludeRelated.OnClick := @IncludeRelatedClick; FMenu.Items.Add(FMenuIncludeRelated);
  FMenu.Items.AddSeparator;
  FMenuRemove := TMenuItem.Create(FMenu); FMenuRemove.Caption := 'Remover do diagrama';
  FMenuRemove.ShortCut := ShortCut(VK_DELETE, []); FMenuRemove.OnClick := @RemoveClick;
  FMenu.Items.Add(FMenuRemove);
  FMenuShowHidden := TMenuItem.Create(FMenu); FMenuShowHidden.Caption := 'Mostrar tabelas removidas';
  FMenuShowHidden.OnClick := @ShowHiddenClick; FMenu.Items.Add(FMenuShowHidden);

  FScroll := TScrollBox.Create(Self); FScroll.Parent := Self; FScroll.Align := alClient;
  FScroll.OnMouseWheel := @MouseWheelDiagram;
  FPaint := TPaintBox.Create(Self); FPaint.Parent := FScroll;
  FPaint.OnPaint := @PaintDiagram; FPaint.OnMouseDown := @MouseDownDiagram;
  FPaint.OnMouseMove := @MouseMoveDiagram; FPaint.OnMouseUp := @MouseUpDiagram;
  FPaint.OnMouseWheel := @MouseWheelDiagram;
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
procedure TDatabaseDiagramForm.UpdateStatus;
var Hidden: Integer;
begin
  if FModel = nil then Exit;
  FStatus.Caption := Format('%d tabelas; %d relacionamentos. Zoom %d%%.',
    [FModel.Tables.Count, FModel.Relations.Count, Round(FZoom * 100)]);
  Hidden := FModel.HiddenCount;
  if Hidden > 0 then
    FStatus.Caption := FStatus.Caption + Format(' %d fora do diagrama ("Incluir..." ou "Todas" para mostrar).', [Hidden]);
  if FModel.Warnings.Count > 0 then FStatus.Caption := FStatus.Caption + LineEnding + FModel.Warnings[0];
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
  FDrag := nil; FSelected := nil; FRemoveButton.Enabled := False;
  SetCaptureControl(nil); FModel.Free; FModel := NewModel;
  UpdateStatus;
  FStatus.Caption := FStatus.Caption + ' Snapshot de ' + TimeToStr(Now) + '.';
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
function TDatabaseDiagramForm.TableHeight(T: TDiagramTable): Integer;
begin Result := 32 + 20 * T.Columns.Count; end;
function TDatabaseDiagramForm.TableAt(X, Y: Integer): TDiagramTable;
var I: Integer; T: TDiagramTable;
begin
  // X e Y em coordenadas do diagrama (sem zoom); a tabela desenhada por cima vence
  Result := nil;
  if FModel = nil then Exit;
  for I := FModel.Tables.Count - 1 downto 0 do begin
    T := TDiagramTable(FModel.Tables[I]);
    if not TableVisible(T) then Continue;
    if (X >= T.X) and (X <= T.X + TABLE_WIDTH) and (Y >= T.Y) and (Y <= T.Y + TableHeight(T)) then
      Exit(T);
  end;
end;
procedure TDatabaseDiagramForm.FilterChanged(Sender: TObject);
begin
  if FModel <> nil then FModel.FilterText := FFilter.Text;
  ResizeCanvas;
end;
procedure TDatabaseDiagramForm.ShowAllClick(Sender: TObject);
begin
  if FModel <> nil then begin
    FModel.FocusKey := ''; FModel.FilterText := ''; FModel.ShowHiddenTables;
  end;
  FFilter.Text := ''; ResizeCanvas; UpdateStatus;
end;
procedure TDatabaseDiagramForm.FitClick(Sender: TObject);
begin
  FZoom := 1; ResizeCanvas;
  FZoom := EnsureRange(Min(FScroll.ClientWidth / Max(1, FPaint.Width),
    FScroll.ClientHeight / Max(1, FPaint.Height)), DIAGRAM_ZOOM_MIN, DIAGRAM_ZOOM_MAX);
  ResizeCanvas; FScroll.HorzScrollBar.Position := 0; FScroll.VertScrollBar.Position := 0;
  UpdateStatus;
end;
procedure TDatabaseDiagramForm.PaintDiagram(Sender: TObject);
begin DrawDiagram(FPaint.Canvas); end;
procedure TDatabaseDiagramForm.DrawDiagram(C: TCanvas);
var I, J, N, X1, X2, Y1, Y2, Bend, ArrowX: Integer;
  T, A, B: TDiagramTable; Col: TDiagramColumn; R: TDiagramRelation; P: TDiagramPair; S: string;
  function Z(V: Integer): Integer; begin Result := Round(V * FZoom); end;
begin
  C.Brush.Color := clWhite; C.FillRect(Rect(0, 0, FPaint.Width, FPaint.Height));
  if FModel = nil then Exit;
  C.Font.Size := Max(5, Round(9 * FZoom));
  C.Pen.Color := $886644; C.Pen.Width := 1;
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
      Y2 := B.Y + 40 + N * 20; X1 := A.X + TABLE_WIDTH; X2 := B.X;
      if A.X = B.X then begin X2 := B.X + TABLE_WIDTH; Bend := X1 + 25 + (I mod 6) * 8; end
      else begin
        if B.X < A.X then begin X1 := A.X; X2 := B.X + TABLE_WIDTH; end;
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
    T := TDiagramTable(FModel.Tables[I]); if not TableVisible(T) then Continue;
    // Tabela selecionada ganha borda azul (nao aparece na exportacao)
    if (T = FSelected) and not FExporting then begin C.Pen.Color := $D07820; C.Pen.Width := 3; end
    else begin C.Pen.Color := clGray; C.Pen.Width := 1; end;
    C.Brush.Color := $FFF6EB;
    C.Rectangle(Z(T.X), Z(T.Y), Z(T.X + TABLE_WIDTH), Z(T.Y + TableHeight(T)));
    C.Brush.Color := $E8D5BE;
    C.Rectangle(Z(T.X), Z(T.Y), Z(T.X + TABLE_WIDTH), Z(T.Y + 29));
    C.Pen.Width := 1;
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
var T: TDiagramTable; DX, DY: Integer;
begin
  if FModel = nil then Exit;
  DX := Round(X / FZoom); DY := Round(Y / FZoom);
  T := TableAt(DX, DY);
  FSelected := T; FRemoveButton.Enabled := T <> nil; FPaint.Invalidate;
  if Button = mbRight then begin
    FMenu.PopUp; Exit;
  end;
  if Button <> mbLeft then Exit;
  // Arrasta pelo cabecalho, como antes
  if (T <> nil) and (DY <= T.Y + 29) then begin
    FDrag := T; FOffset := Point(DX - T.X, DY - T.Y); SetCaptureControl(FPaint);
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
procedure TDatabaseDiagramForm.SetZoomAt(ANewZoom: Double; const AScreenPoint: TPoint);
var P, V: TPoint; LX, LY: Double;
begin
  ANewZoom := EnsureRange(ANewZoom, DIAGRAM_ZOOM_MIN, DIAGRAM_ZOOM_MAX);
  if SameValue(ANewZoom, FZoom, 0.0001) then Exit;
  // Mantem o ponto sob o cursor no mesmo lugar da tela
  P := FPaint.ScreenToClient(AScreenPoint);
  V := FScroll.ScreenToClient(AScreenPoint);
  LX := P.X / FZoom; LY := P.Y / FZoom;
  FZoom := ANewZoom;
  ResizeCanvas;
  FScroll.HorzScrollBar.Position := Max(0, Round(LX * FZoom) - V.X);
  FScroll.VertScrollBar.Position := Max(0, Round(LY * FZoom) - V.Y);
  UpdateStatus;
end;
procedure TDatabaseDiagramForm.MouseWheelDiagram(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  // Roda para frente aumenta o zoom; para tras diminui
  Handled := True;
  if (FModel = nil) or (WheelDelta = 0) then Exit;
  if WheelDelta > 0 then SetZoomAt(FZoom * ZOOM_STEP, Mouse.CursorPos)
  else SetZoomAt(FZoom / ZOOM_STEP, Mouse.CursorPos);
end;
procedure TDatabaseDiagramForm.KeyDownDiagram(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (FSelected <> nil) and not (ActiveControl is TCustomEdit) then begin
    RemoveClick(nil); Key := 0;
  end;
end;
procedure TDatabaseDiagramForm.RemoveClick(Sender: TObject);
begin
  // Remove so do diagrama (visao); o banco de dados nao e alterado
  if (FModel = nil) or (FSelected = nil) then Exit;
  FSelected.Hidden := True;
  if FModel.FocusKey = FSelected.Key then FModel.FocusKey := '';
  FSelected := nil; FDrag := nil; FRemoveButton.Enabled := False;
  ResizeCanvas; UpdateStatus;
end;
procedure TDatabaseDiagramForm.ShowHiddenClick(Sender: TObject);
begin
  if FModel = nil then Exit;
  FModel.ShowHiddenTables; ResizeCanvas; UpdateStatus;
end;
procedure TDatabaseDiagramForm.MenuPopup(Sender: TObject);
var Hidden: Integer;
begin
  FMenuIncludeRelated.Enabled := FSelected <> nil;
  if FSelected <> nil then FMenuIncludeRelated.Caption := 'Incluir tabelas ligadas a ' + FSelected.Caption
  else FMenuIncludeRelated.Caption := 'Incluir tabelas ligadas a esta';
  FMenuRemove.Enabled := FSelected <> nil;
  if FSelected <> nil then FMenuRemove.Caption := 'Remover do diagrama: ' + FSelected.Caption
  else FMenuRemove.Caption := 'Remover do diagrama';
  Hidden := 0;
  if FModel <> nil then Hidden := FModel.HiddenCount;
  FMenuShowHidden.Enabled := Hidden > 0;
  FMenuShowHidden.Caption := Format('Mostrar tabelas removidas (%d)', [Hidden]);
end;
{ ---------------------------------------------------------------- Incluir tabelas }

type
  { Janela de escolha das tabelas a incluir no diagrama }
  TIncludeTablesDialog = class(TForm)
  private
    FSearch: TEdit;
    FList: TCheckListBox;
    FRelated: TCheckBox;
    FCandidates: TList;      // TDiagramTable fora do diagrama
    FChecked: TStringList;   // chaves marcadas (sobrevive a pesquisa)
    procedure Fill;
    procedure SearchChange(Sender: TObject);
    procedure ListClickCheck(Sender: TObject);
    procedure MarkAll(Sender: TObject);
  public
    constructor CreateFor(AOwner: TComponent; ACandidates: TList);
    destructor Destroy; override;
    procedure Selected(AList: TList);
    function IncludeRelated: Boolean;
  end;

constructor TIncludeTablesDialog.CreateFor(AOwner: TComponent; ACandidates: TList);
var Bar: TPanel; B: TButton;
begin
  inherited CreateNew(AOwner);
  FCandidates := ACandidates;
  FChecked := TStringList.Create; FChecked.Sorted := True; FChecked.Duplicates := dupIgnore;
  Caption := 'Incluir tabelas no diagrama';
  Width := 440; Height := 520; Position := poOwnerFormCenter; BorderStyle := bsSizeToolWin;

  FSearch := TEdit.Create(Self); FSearch.Parent := Self; FSearch.Align := alTop;
  FSearch.BorderSpacing.Around := 8; FSearch.TextHint := 'Pesquisar tabela';
  FSearch.OnChange := @SearchChange;

  Bar := TPanel.Create(Self); Bar.Parent := Self; Bar.Align := alBottom;
  Bar.Height := 84; Bar.BevelOuter := bvNone;
  FRelated := TCheckBox.Create(Self); FRelated.Parent := Bar;
  FRelated.SetBounds(10, 6, 420, 22);
  FRelated.Caption := 'Incluir também as tabelas ligadas por chave estrangeira';
  B := TButton.Create(Self); B.Parent := Bar; B.Caption := 'Marcar visíveis';
  B.SetBounds(10, 42, 120, 30); B.OnClick := @MarkAll;
  B := TButton.Create(Self); B.Parent := Bar; B.Caption := 'Incluir';
  B.SetBounds(Width - 220, 42, 100, 30); B.ModalResult := mrOk; B.Default := True;
  B.Anchors := [akRight, akBottom];
  B := TButton.Create(Self); B.Parent := Bar; B.Caption := 'Cancelar';
  B.SetBounds(Width - 112, 42, 100, 30); B.ModalResult := mrCancel; B.Cancel := True;
  B.Anchors := [akRight, akBottom];

  FList := TCheckListBox.Create(Self); FList.Parent := Self; FList.Align := alClient;
  FList.BorderSpacing.Left := 8; FList.BorderSpacing.Right := 8;
  FList.OnClickCheck := @ListClickCheck;
  Fill;
end;
destructor TIncludeTablesDialog.Destroy;
begin FChecked.Free; inherited Destroy; end;
procedure TIncludeTablesDialog.Fill;
var I, N: Integer; T: TDiagramTable; Busca: string;
begin
  Busca := LowerCase(Trim(FSearch.Text));
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to FCandidates.Count - 1 do begin
      T := TDiagramTable(FCandidates[I]);
      if (Busca <> '') and (Pos(Busca, LowerCase(T.Caption)) = 0) then Continue;
      N := FList.Items.AddObject(T.Caption, T);
      FList.Checked[N] := FChecked.IndexOf(T.Key) >= 0;
    end;
  finally FList.Items.EndUpdate; end;
end;
procedure TIncludeTablesDialog.SearchChange(Sender: TObject);
begin Fill; end;
procedure TIncludeTablesDialog.ListClickCheck(Sender: TObject);
var I, P: Integer; K: string;
begin
  for I := 0 to FList.Items.Count - 1 do begin
    K := TDiagramTable(FList.Items.Objects[I]).Key;
    P := FChecked.IndexOf(K);
    if FList.Checked[I] and (P < 0) then FChecked.Add(K)
    else if not FList.Checked[I] and (P >= 0) then FChecked.Delete(P);
  end;
end;
procedure TIncludeTablesDialog.MarkAll(Sender: TObject);
var I: Integer;
begin
  for I := 0 to FList.Items.Count - 1 do FList.Checked[I] := True;
  ListClickCheck(nil);
end;
procedure TIncludeTablesDialog.Selected(AList: TList);
var I: Integer; T: TDiagramTable;
begin
  for I := 0 to FCandidates.Count - 1 do begin
    T := TDiagramTable(FCandidates[I]);
    if FChecked.IndexOf(T.Key) >= 0 then AList.Add(T);
  end;
end;
function TIncludeTablesDialog.IncludeRelated: Boolean;
begin Result := FRelated.Checked; end;

procedure TDatabaseDiagramForm.IncludeTables(AList: TList);
{ Torna visiveis as tabelas da lista, posicionando-as a direita das que ja
  estao no diagrama. Os vinculos (FK) aparecem sozinhos quando as duas
  pontas ficam visiveis. }
var
  I, MaxRight, NextY, Novos, Antes: Integer; T, A, B: TDiagramTable; R: TDiagramRelation;
  function VinculosVisiveis: Integer;
  var J: Integer;
  begin
    Result := 0;
    for J := 0 to FModel.Relations.Count - 1 do begin
      R := TDiagramRelation(FModel.Relations[J]);
      A := FModel.FindTable(R.SourceKey); B := FModel.FindTable(R.TargetKey);
      if (A <> nil) and (B <> nil) and TableVisible(A) and TableVisible(B) then Inc(Result);
    end;
  end;
begin
  if (FModel = nil) or (AList.Count = 0) then Exit;
  Antes := VinculosVisiveis;
  MaxRight := -1;
  for I := 0 to FModel.Tables.Count - 1 do begin
    T := TDiagramTable(FModel.Tables[I]);
    if TableVisible(T) then MaxRight := Max(MaxRight, T.X + TABLE_WIDTH);
  end;
  if MaxRight < 0 then MaxRight := 30 - 60;  // diagrama vazio: comeca na margem
  NextY := Max(30, Round(FScroll.VertScrollBar.Position / FZoom) + 30);
  Novos := 0;
  for I := 0 to AList.Count - 1 do begin
    T := TDiagramTable(AList[I]);
    if TableVisible(T) then Continue;
    T.Hidden := False;
    T.X := MaxRight + 60; T.Y := NextY;
    Inc(NextY, TableHeight(T) + 40);
    Inc(Novos);
  end;
  if Novos = 0 then Exit;
  FSelected := TDiagramTable(AList[0]); FRemoveButton.Enabled := True;
  ResizeCanvas;
  FScroll.HorzScrollBar.Position := Max(0, Round((MaxRight + 60) * FZoom) - 40);
  UpdateStatus;
  FStatus.Caption := Format('%d tabela(s) incluída(s); %d vínculo(s) novo(s). ',
    [Novos, VinculosVisiveis - Antes]) + FStatus.Caption;
end;
procedure TDatabaseDiagramForm.IncludeClick(Sender: TObject);
var Candidatos, Escolhidas, Extras: TList; Dlg: TIncludeTablesDialog; I, J: Integer; T: TDiagramTable;
begin
  if FModel = nil then Exit;
  // Filtro/foco viram "tabelas fora do diagrama", senao a inclusao seria escondida
  FModel.MaterializeView; FFilter.Text := '';
  Candidatos := TList.Create; Escolhidas := TList.Create; Extras := TList.Create;
  try
    for I := 0 to FModel.Tables.Count - 1 do begin
      T := TDiagramTable(FModel.Tables[I]);
      if not TableVisible(T) then Candidatos.Add(T);
    end;
    if Candidatos.Count = 0 then begin
      ResizeCanvas; UpdateStatus;
      FStatus.Caption := 'Todas as tabelas já estão no diagrama. ' + FStatus.Caption;
      Exit;
    end;
    Dlg := TIncludeTablesDialog.CreateFor(Self, Candidatos);
    try
      if Dlg.ShowModal <> mrOk then begin ResizeCanvas; Exit; end;
      Dlg.Selected(Escolhidas);
      if Dlg.IncludeRelated then begin
        for I := 0 to Escolhidas.Count - 1 do
          FModel.AddNeighbours(TDiagramTable(Escolhidas[I]), Extras);
        for J := 0 to Extras.Count - 1 do
          if Escolhidas.IndexOf(Extras[J]) < 0 then Escolhidas.Add(Extras[J]);
      end;
    finally Dlg.Free; end;
    IncludeTables(Escolhidas);
    if Escolhidas.Count = 0 then ResizeCanvas;
  finally Extras.Free; Escolhidas.Free; Candidatos.Free; end;
end;
procedure TDatabaseDiagramForm.IncludeRelatedClick(Sender: TObject);
var Vizinhos: TList;
begin
  if (FModel = nil) or (FSelected = nil) then Exit;
  FModel.MaterializeView; FFilter.Text := '';
  Vizinhos := TList.Create;
  try
    FModel.AddNeighbours(FSelected, Vizinhos);
    if Vizinhos.Count = 0 then begin
      FStatus.Caption := FSelected.Caption + ' não tem tabelas ligadas por chave estrangeira.';
      Exit;
    end;
    IncludeTables(Vizinhos);
  finally Vizinhos.Free; end;
end;
procedure TDatabaseDiagramForm.ClearClick(Sender: TObject);
begin
  if FModel = nil then Exit;
  FModel.HideAllTables; FFilter.Text := '';
  FSelected := nil; FDrag := nil; FRemoveButton.Enabled := False;
  ResizeCanvas; UpdateStatus;
  FStatus.Caption := 'Diagrama vazio. Use "Incluir..." para adicionar tabelas. ' + FStatus.Caption;
end;
procedure TDatabaseDiagramForm.ArrangeClick(Sender: TObject);
begin if FModel <> nil then FModel.Arrange; ResizeCanvas; end;
procedure TDatabaseDiagramForm.ZoomClick(Sender: TObject);
var Centro: TPoint;
begin
  Centro := FScroll.ClientToScreen(Point(FScroll.ClientWidth div 2, FScroll.ClientHeight div 2));
  if TControl(Sender).Tag > 0 then SetZoomAt(FZoom * ZOOM_STEP, Centro)
  else SetZoomAt(FZoom / ZOOM_STEP, Centro);
end;
function TDatabaseDiagramForm.LayoutFile: string;
begin Result := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) + 'diagrams' + PathDelim + DiagramContextKey(FContext) + '.json'; end;
procedure TDatabaseDiagramForm.SaveClick(Sender: TObject);
begin
  if FModel = nil then Exit;
  try
    SaveDiagramLayout(FModel, FZoom, LayoutFile);
    FStatus.Caption := 'Posições, zoom e tabelas removidas salvos para este banco.';
  except on E: Exception do FStatus.Caption := 'Erro ao salvar: ' + E.Message; end;
end;
procedure TDatabaseDiagramForm.RestoreLayout;
begin LoadDiagramLayout(FModel, FZoom, LayoutFile); end;

{ ---------------------------------------------------------------- Exportacao }

function TDatabaseDiagramForm.RenderBitmap: TBitmap;
begin
  if FModel = nil then raise Exception.Create('Carregue o diagrama antes de exportar.');
  if (FPaint.Width > 16000) or (FPaint.Height > 16000) or
    (Int64(FPaint.Width) * FPaint.Height > 32000000) then
    raise Exception.Create('Reduza o zoom antes de exportar este diagrama.');
  Result := TBitmap.Create;
  FExporting := True;
  try
    Result.PixelFormat := pf24bit;
    Result.SetSize(FPaint.Width, FPaint.Height);
    DrawDiagram(Result.Canvas);
  except
    FExporting := False; Result.Free; raise;
  end;
  FExporting := False;
end;
procedure TDatabaseDiagramForm.ExportPNG(const AFileName: string);
var Bitmap: TBitmap; PNG: TPortableNetworkGraphic;
begin
  Bitmap := RenderBitmap; PNG := TPortableNetworkGraphic.Create;
  try PNG.Assign(Bitmap); PNG.SaveToFile(AFileName);
  finally PNG.Free; Bitmap.Free; end;
end;
procedure TDatabaseDiagramForm.ExportJPG(const AFileName: string);
var Bitmap: TBitmap; JPG: TJPEGImage;
begin
  Bitmap := RenderBitmap; JPG := TJPEGImage.Create;
  try
    JPG.CompressionQuality := 92; JPG.Assign(Bitmap); JPG.SaveToFile(AFileName);
  finally JPG.Free; Bitmap.Free; end;
end;
procedure TDatabaseDiagramForm.ExportPDF(const AFileName: string);
{ PDF de uma pagina A4 com a imagem do diagrama em JPEG (DCTDecode).
  Escrito direto, sem depender de biblioteca de PDF. }
var
  Bitmap: TBitmap; JPG: TJPEGImage; Img: TMemoryStream; F: TFileStream;
  Offs: array[1..5] of Int64; I: Integer; XRef: Int64;
  PW, PH, Escala, DW, DH, PX, PY: Double; FS: TFormatSettings; Conteudo: string;
  procedure W(const S: string);
  begin if S <> '' then F.WriteBuffer(S[1], Length(S)); end;
begin
  FS := DefaultFormatSettings; FS.DecimalSeparator := '.';
  Bitmap := RenderBitmap; JPG := TJPEGImage.Create; Img := TMemoryStream.Create;
  try
    JPG.CompressionQuality := 92; JPG.Assign(Bitmap); JPG.SaveToStream(Img);
    // A4 em pontos; paisagem quando o diagrama e mais largo que alto
    if Bitmap.Width >= Bitmap.Height then begin PW := 842; PH := 595; end
    else begin PW := 595; PH := 842; end;
    Escala := Min((PW - 48) / Bitmap.Width, (PH - 48) / Bitmap.Height);
    DW := Bitmap.Width * Escala; DH := Bitmap.Height * Escala;
    PX := (PW - DW) / 2; PY := (PH - DH) / 2;
    Conteudo := Format('q %.2f 0 0 %.2f %.2f %.2f cm /Im1 Do Q', [DW, DH, PX, PY], FS);

    F := TFileStream.Create(AFileName, fmCreate);
    try
      W('%PDF-1.4'#10);
      Offs[1] := F.Position;
      W('1 0 obj'#10'<< /Type /Catalog /Pages 2 0 R >>'#10'endobj'#10);
      Offs[2] := F.Position;
      W('2 0 obj'#10'<< /Type /Pages /Kids [3 0 R] /Count 1 >>'#10'endobj'#10);
      Offs[3] := F.Position;
      W(Format('3 0 obj'#10'<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.0f %.0f] ' +
        '/Resources << /XObject << /Im1 4 0 R >> >> /Contents 5 0 R >>'#10'endobj'#10, [PW, PH], FS));
      Offs[4] := F.Position;
      W(Format('4 0 obj'#10'<< /Type /XObject /Subtype /Image /Width %d /Height %d ' +
        '/ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length %d >>'#10'stream'#10,
        [Bitmap.Width, Bitmap.Height, Img.Size]));
      Img.Position := 0; F.CopyFrom(Img, Img.Size);
      W(#10'endstream'#10'endobj'#10);
      Offs[5] := F.Position;
      W(Format('5 0 obj'#10'<< /Length %d >>'#10'stream'#10, [Length(Conteudo)]));
      W(Conteudo);
      W(#10'endstream'#10'endobj'#10);
      XRef := F.Position;
      W('xref'#10'0 6'#10'0000000000 65535 f'#13#10);
      for I := 1 to 5 do W(Format('%.10d 00000 n'#13#10, [Offs[I]]));
      W(Format('trailer'#10'<< /Size 6 /Root 1 0 R >>'#10'startxref'#10'%d'#10'%%%%EOF'#10, [XRef]));
    finally F.Free; end;
  finally Img.Free; JPG.Free; Bitmap.Free; end;
end;
procedure TDatabaseDiagramForm.ExportMarkdown(const AFileName: string);
{ Markdown com: imagem PNG ao lado do .md, diagrama Mermaid (erDiagram),
  tabelas com colunas e lista de relacionamentos. So o que esta visivel. }
var
  L: TStringList; I, J, K, Visiveis, Rels: Integer;
  T, A, B: TDiagramTable; Col: TDiagramColumn; R: TDiagramRelation; P: TDiagramPair;
  ImgName, Chave, Cols: string;

  function Ident(const S: string): string;
  var C: Char;
  begin
    // Nome aceito pelo Mermaid: letras, numeros e sublinhado
    Result := '';
    for C in S do
      if C in ['A'..'Z', 'a'..'z', '0'..'9', '_'] then Result := Result + C
      else Result := Result + '_';
    if Result = '' then Result := '_';
    if Result[1] in ['0'..'9'] then Result := '_' + Result;
  end;
  function Cell(const S: string): string;
  begin Result := StringReplace(S, '|', '\|', [rfReplaceAll]); end;
  function Mermaid(const S: string): string;
  begin Result := StringReplace(S, '"', '''', [rfReplaceAll]); end;

begin
  if FModel = nil then raise Exception.Create('Carregue o diagrama antes de exportar.');
  ImgName := ChangeFileExt(ExtractFileName(AFileName), '.png');
  ExportPNG(ChangeFileExt(AFileName, '.png'));

  L := TStringList.Create;
  try
    Visiveis := 0;
    for I := 0 to FModel.Tables.Count - 1 do
      if TableVisible(TDiagramTable(FModel.Tables[I])) then Inc(Visiveis);
    Rels := 0;
    for I := 0 to FModel.Relations.Count - 1 do begin
      R := TDiagramRelation(FModel.Relations[I]);
      A := FModel.FindTable(R.SourceKey); B := FModel.FindTable(R.TargetKey);
      if (A <> nil) and (B <> nil) and TableVisible(A) and TableVisible(B) then Inc(Rels);
    end;

    L.Add('# Diagrama — ' + FContext.Protocol + ' / ' + FContext.DatabaseName +
      ' / ' + FContext.SchemaName);
    L.Add('');
    L.Add(Format('Gerado em %s. %d tabela(s) e %d relacionamento(s) nesta visão.',
      [FormatDateTime('dd/mm/yyyy hh:nn', Now), Visiveis, Rels]));
    if FModel.FilterText <> '' then L.Add('Filtro: `' + FModel.FilterText + '`.');
    L.Add('');
    L.Add('![Diagrama](' + StringReplace(ImgName, ' ', '%20', [rfReplaceAll]) + ')');
    L.Add('');

    L.Add('## Diagrama (Mermaid)');
    L.Add('');
    L.Add('```mermaid');
    L.Add('erDiagram');
    for I := 0 to FModel.Tables.Count - 1 do begin
      T := TDiagramTable(FModel.Tables[I]); if not TableVisible(T) then Continue;
      L.Add('  ' + Ident(T.Caption) + ' {');
      for J := 0 to T.Columns.Count - 1 do begin
        Col := TDiagramColumn(T.Columns[J]);
        Chave := '';
        if Col.PrimaryPosition > 0 then Chave := 'PK';
        if Col.ForeignKey then begin
          if Chave <> '' then Chave := Chave + ', ';
          Chave := Chave + 'FK';
        end;
        if Chave <> '' then Chave := ' ' + Chave;
        L.Add('    ' + Ident(Col.DataType) + ' ' + Ident(Col.Name) + Chave);
      end;
      L.Add('  }');
    end;
    for I := 0 to FModel.Relations.Count - 1 do begin
      R := TDiagramRelation(FModel.Relations[I]);
      A := FModel.FindTable(R.SourceKey); B := FModel.FindTable(R.TargetKey);
      if (A = nil) or (B = nil) or not TableVisible(A) or not TableVisible(B) then Continue;
      L.Add('  ' + Ident(A.Caption) + ' }o--|| ' + Ident(B.Caption) + ' : "' + Mermaid(R.Name) + '"');
    end;
    L.Add('```');
    L.Add('');

    L.Add('## Tabelas');
    for I := 0 to FModel.Tables.Count - 1 do begin
      T := TDiagramTable(FModel.Tables[I]); if not TableVisible(T) then Continue;
      L.Add('');
      L.Add('### ' + Cell(T.Caption));
      L.Add('');
      L.Add('| Coluna | Tipo | Chave | Aceita nulo |');
      L.Add('|---|---|---|---|');
      for J := 0 to T.Columns.Count - 1 do begin
        Col := TDiagramColumn(T.Columns[J]);
        Chave := '';
        if Col.PrimaryPosition > 0 then Chave := 'PK';
        if Col.ForeignKey then begin
          if Chave <> '' then Chave := Chave + ', ';
          Chave := Chave + 'FK';
        end;
        if Col.Nullable then
          L.Add('| ' + Cell(Col.Name) + ' | ' + Cell(Col.DataType) + ' | ' + Chave + ' | sim |')
        else
          L.Add('| ' + Cell(Col.Name) + ' | ' + Cell(Col.DataType) + ' | ' + Chave + ' | não |');
      end;
    end;
    L.Add('');

    L.Add('## Relacionamentos');
    L.Add('');
    if Rels = 0 then L.Add('Nenhum relacionamento entre as tabelas desta visão.')
    else begin
      L.Add('| Nome | Origem | Destino | Colunas |');
      L.Add('|---|---|---|---|');
      for I := 0 to FModel.Relations.Count - 1 do begin
        R := TDiagramRelation(FModel.Relations[I]);
        A := FModel.FindTable(R.SourceKey); B := FModel.FindTable(R.TargetKey);
        if (A = nil) or (B = nil) or not TableVisible(A) or not TableVisible(B) then Continue;
        Cols := '';
        for K := 0 to R.Pairs.Count - 1 do begin
          P := TDiagramPair(R.Pairs[K]);
          if Cols <> '' then Cols := Cols + ', ';
          Cols := Cols + P.SourceColumn + ' → ' + P.TargetColumn;
        end;
        L.Add('| ' + Cell(R.Name) + ' | ' + Cell(A.Caption) + ' | ' + Cell(B.Caption) +
          ' | ' + Cell(Cols) + ' |');
      end;
    end;

    L.WriteBOM := False;
    L.SaveToFile(AFileName);
  finally L.Free; end;
end;
procedure TDatabaseDiagramForm.ExportImage(const AFileName: string);
var Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  if (Ext = '.jpg') or (Ext = '.jpeg') then ExportJPG(AFileName)
  else if Ext = '.pdf' then ExportPDF(AFileName)
  else if (Ext = '.md') or (Ext = '.markdown') then ExportMarkdown(AFileName)
  else ExportPNG(AFileName);
end;
procedure TDatabaseDiagramForm.ExportClick(Sender: TObject);
const
  Extensoes: array[1..4] of string = ('.pdf', '.jpg', '.png', '.md');
var Dialog: TSaveDialog; Nome: string;
begin
  Dialog := TSaveDialog.Create(Self);
  try
    Dialog.Title := 'Salvar visão do diagrama';
    Dialog.Filter := 'Documento PDF|*.pdf|Imagem JPG|*.jpg;*.jpeg|Imagem PNG|*.png|Markdown (com imagem PNG ao lado)|*.md';
    Dialog.FilterIndex := 1; Dialog.DefaultExt := 'pdf';
    Dialog.Options := Dialog.Options + [ofOverwritePrompt];
    if Dialog.Execute then begin
      Nome := Dialog.FileName;
      // Se o usuario nao digitou extensao valida, usa a do tipo escolhido
      if Pos(LowerCase(ExtractFileExt(Nome)), '.pdf.jpg.jpeg.png.md.markdown') = 0 then
        Nome := ChangeFileExt(Nome, Extensoes[EnsureRange(Dialog.FilterIndex, 1, 4)]);
      try
        ExportImage(Nome);
        FStatus.Caption := 'Visão exportada: ' + Nome;
      except on E: Exception do FStatus.Caption := 'Erro ao exportar: ' + E.Message; end;
    end;
  finally Dialog.Free; end;
end;
end.
