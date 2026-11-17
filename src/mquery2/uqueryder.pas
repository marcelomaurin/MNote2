unit uqueryder;

{$mode objfpc}{$H+}{$codepage utf8}

interface

uses
  Classes, SysUtils, Math, Types, Contnrs,
  Forms, Controls, Graphics, ExtCtrls, StdCtrls, ComCtrls, Menus, Dialogs,
  LCLType, SynEdit, SynHighlighterSQL, ZConnection, ZDataset, ZDbcIntfs,
  Printers, PrintersDlgs;

type
  TDERJoinType = (jtInner, jtLeft, jtRight, jtWhere);

  TDERColumnItem = class
  public
    Name: string;
    DataType: string;
    IsPK: Boolean;
    IsFK: Boolean;
    Selected: Boolean;
  end;

  TDERForeignKeyInfo = class
  public
    ConstraintName: string;
    ColumnName: string;
    RefSchema: string;
    RefTable: string;
    RefColumn: string;
  end;

  TDERTableNode = class
  public
    SchemaName: string;
    TableName: string;
    Alias: string;
    X, Y, Width: Integer;
    Columns: TObjectList;
    ForeignKeys: TObjectList;
    constructor Create;
    destructor Destroy; override;
    function FullName: string;
    function ColumnIndex(const AName: string): Integer;
    function HeaderHeight: Integer;
    function RowHeight: Integer;
    function TotalHeight: Integer;
    function BoundsRect: TRect;
    function ColumnRect(AColIndex: Integer): TRect;
    function ColumnAnchorY(const AColName: string): Integer;
  end;

  TDERJoinEdge = class
  public
    SourceTable: TDERTableNode;
    SourceColumn: string;
    TargetTable: TDERTableNode;
    TargetColumn: string;
    JoinType: TDERJoinType;
    LabelRect: TRect;
    P1, P2, M1, M2: TPoint;
  end;

  TDERExecuteSQLCallback = procedure(Sender: TObject; const ASQL: string; ARunNow: Boolean) of object;

  { TMQueryDERPanel }

  TMQueryDERPanel = class(TPanel)
  private
    FConnection: TZConnection;
    FSchema: string;
    FEngineIndex: Integer;
    FToolbar: TPanel;
    FCbJoinType: TComboBox;
    FLblJoinHint: TLabel;
    FLblStatus: TLabel;
    FBtnSendSQL: TButton;
    FBtnRunSQL: TButton;
    FBtnArrange: TButton;
    FBtnPrint: TButton;
    FBtnClear: TButton;
    FBtnZoomOut: TButton;
    FBtnZoomIn: TButton;
    FScroll: TScrollBox;
    FPaint: TPaintBox;
    FSplitter: TSplitter;
    FBottomPanel: TPanel;
    FBottomBar: TPanel;
    FSQLEditor: TSynEdit;
    FSQLHighlighter: TSynSQLSyn;
    FOnSendSQL: TDERExecuteSQLCallback;

    FTables: TObjectList;
    FEdges: TObjectList;
    FZoom: Double;
    FSelectedTable: TDERTableNode;
    FSelectedEdge: TDERJoinEdge;
    FDragTable: TDERTableNode;
    FDragOffset: TPoint;
    FLinkingTable: TDERTableNode;
    FLinkingCol: string;
    FLinkMousePt: TPoint;
    FIsLinking: Boolean;

    FEdgeMenu: TPopupMenu;
    FTableMenu: TPopupMenu;

    function NextAlias(const ATableName: string): string;
    procedure LoadTableMetadata(ANode: TDERTableNode; ATreeNode: TTreeNode);
    procedure AutoDetectEdgesFor(ANode: TDERTableNode);
    function EdgeExists(T1: TDERTableNode; const C1: string;
      T2: TDERTableNode; const C2: string): Boolean;
    function JoinTypeCaption(AJT: TDERJoinType): string;
    function JoinTypeKeyword(AJT: TDERJoinType): string;

    function ScreenToWorld(const P: TPoint): TPoint;
    function TableAt(WX, WY: Integer; out AColIndex: Integer; out AIsCloseBtn: Boolean): TDERTableNode;
    function EdgeAt(WX, WY: Integer): TDERJoinEdge;
    function PointToSegmentDist(PX, PY, X1, Y1, X2, Y2: Integer): Double;
    procedure UpdateScrollArea;
    procedure UpdateJoinControls;
    procedure UpdateStatus;
    procedure RebuildSQL;

    procedure DrawDER(C: TCanvas; const ATitle: string = '');
    procedure PaintCanvas(Sender: TObject);
    procedure CanvasMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CanvasDblClick(Sender: TObject);
    procedure CanvasDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure CanvasDragDrop(Sender, Source: TObject; X, Y: Integer);

    procedure CbJoinTypeChange(Sender: TObject);
    procedure BtnSendSQLClick(Sender: TObject);
    procedure BtnRunSQLClick(Sender: TObject);
    procedure BtnArrangeClick(Sender: TObject);
    procedure BtnPrintClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure BtnZoomOutClick(Sender: TObject);
    procedure BtnZoomInClick(Sender: TObject);

    procedure EdgeMenuJoinClick(Sender: TObject);
    procedure EdgeMenuDeleteClick(Sender: TObject);
    procedure TableMenuSelectAllClick(Sender: TObject);
    procedure TableMenuUnselectAllClick(Sender: TObject);
    procedure TableMenuRemoveClick(Sender: TObject);

    function QuoteIdent(const AName: string): string;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor CreateForEngine(AOwner: TComponent; AEngineIndex: Integer;
      AConnection: TZConnection; const ASchema: string);
    destructor Destroy; override;
    procedure SetConnectionInfo(AConnection: TZConnection; const ASchema: string);
    procedure AddTable(const ATableName: string; ATreeNode: TTreeNode = nil;
      ADropX: Integer = -1; ADropY: Integer = -1);
    procedure RemoveTable(ANode: TDERTableNode);
    procedure ClearDER;
    procedure ArrangeTables;
    property OnSendSQL: TDERExecuteSQLCallback read FOnSendSQL write FOnSendSQL;
    property SQLEditor: TSynEdit read FSQLEditor;
  end;

implementation

const
  DER_TABLE_W = 230;
  DER_HEADER_H = 26;
  DER_ROW_H = 20;

function CleanColNameFromTree(const ARaw: string): string;
var
  P: Integer;
begin
  Result := Trim(ARaw);
  P := Pos(':', Result);
  if P > 0 then
    Result := Trim(Copy(Result, 1, P - 1));
  P := Pos(' ', Result);
  if P > 0 then
    Result := Trim(Copy(Result, 1, P - 1));
end;

{ TDERTableNode }

constructor TDERTableNode.Create;
begin
  inherited Create;
  Width := DER_TABLE_W;
  Columns := TObjectList.Create(True);
  ForeignKeys := TObjectList.Create(True);
end;

destructor TDERTableNode.Destroy;
begin
  ForeignKeys.Free;
  Columns.Free;
  inherited Destroy;
end;

function TDERTableNode.FullName: string;
begin
  if (SchemaName <> '') and not SameText(SchemaName, 'main') then
    Result := SchemaName + '.' + TableName
  else
    Result := TableName;
end;

function TDERTableNode.ColumnIndex(const AName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Columns.Count - 1 do
    if SameText(TDERColumnItem(Columns[I]).Name, AName) then
      Exit(I);
  Result := -1;
end;

function TDERTableNode.HeaderHeight: Integer;
begin
  Result := DER_HEADER_H;
end;

function TDERTableNode.RowHeight: Integer;
begin
  Result := DER_ROW_H;
end;

function TDERTableNode.TotalHeight: Integer;
begin
  Result := HeaderHeight + Max(1, Columns.Count) * RowHeight + 6;
end;

function TDERTableNode.BoundsRect: TRect;
begin
  Result := Rect(X, Y, X + Width, Y + TotalHeight);
end;

function TDERTableNode.ColumnRect(AColIndex: Integer): TRect;
var
  TopY: Integer;
begin
  TopY := Y + HeaderHeight + AColIndex * RowHeight;
  Result := Rect(X + 1, TopY, X + Width - 1, TopY + RowHeight);
end;

function TDERTableNode.ColumnAnchorY(const AColName: string): Integer;
var
  Idx: Integer;
begin
  Idx := ColumnIndex(AColName);
  if Idx < 0 then
    Result := Y + HeaderHeight div 2
  else
    Result := Y + HeaderHeight + Idx * RowHeight + RowHeight div 2;
end;

{ TMQueryDERPanel }

constructor TMQueryDERPanel.CreateForEngine(AOwner: TComponent;
  AEngineIndex: Integer; AConnection: TZConnection; const ASchema: string);
var
  MI: TMenuItem;
  LblTitle: TLabel;
begin
  inherited Create(AOwner);
  FEngineIndex := AEngineIndex;
  FConnection := AConnection;
  if FConnection <> nil then
    FConnection.FreeNotification(Self);
  FSchema := ASchema;
  FTables := TObjectList.Create(True);
  FEdges := TObjectList.Create(True);
  FZoom := 1.0;

  BevelOuter := bvNone;
  Align := alClient;

  // Top Toolbar
  FToolbar := TPanel.Create(Self);
  FToolbar.Parent := Self;
  FToolbar.Align := alTop;
  FToolbar.Height := 38;
  FToolbar.BevelOuter := bvNone;
  FToolbar.Color := RGBToColor(245, 247, 250);

  FLblJoinHint := TLabel.Create(FToolbar);
  FLblJoinHint.Parent := FToolbar;
  FLblJoinHint.Caption := 'Junção da seta:';
  FLblJoinHint.SetBounds(8, 10, 88, 18);

  FCbJoinType := TComboBox.Create(FToolbar);
  FCbJoinType.Parent := FToolbar;
  FCbJoinType.Style := csDropDownList;
  FCbJoinType.SetBounds(98, 6, 132, 24);
  FCbJoinType.Items.Add('INNER JOIN');
  FCbJoinType.Items.Add('LEFT JOIN');
  FCbJoinType.Items.Add('RIGHT JOIN');
  FCbJoinType.Items.Add('WHERE (vínculo)');
  FCbJoinType.ItemIndex := 0;
  FCbJoinType.Enabled := False;
  FCbJoinType.OnChange := @CbJoinTypeChange;

  FBtnArrange := TButton.Create(FToolbar);
  FBtnArrange.Parent := FToolbar;
  FBtnArrange.Caption := 'Organizar';
  FBtnArrange.SetBounds(240, 6, 76, 25);
  FBtnArrange.OnClick := @BtnArrangeClick;

  FBtnZoomOut := TButton.Create(FToolbar);
  FBtnZoomOut.Parent := FToolbar;
  FBtnZoomOut.Caption := '-';
  FBtnZoomOut.SetBounds(322, 6, 28, 25);
  FBtnZoomOut.OnClick := @BtnZoomOutClick;

  FBtnZoomIn := TButton.Create(FToolbar);
  FBtnZoomIn.Parent := FToolbar;
  FBtnZoomIn.Caption := '+';
  FBtnZoomIn.SetBounds(354, 6, 28, 25);
  FBtnZoomIn.OnClick := @BtnZoomInClick;

  FBtnPrint := TButton.Create(FToolbar);
  FBtnPrint.Parent := FToolbar;
  FBtnPrint.Caption := 'Imprimir DER...';
  FBtnPrint.SetBounds(390, 6, 104, 25);
  FBtnPrint.OnClick := @BtnPrintClick;

  FBtnClear := TButton.Create(FToolbar);
  FBtnClear.Parent := FToolbar;
  FBtnClear.Caption := 'Limpar';
  FBtnClear.SetBounds(500, 6, 68, 25);
  FBtnClear.OnClick := @BtnClearClick;

  FBtnSendSQL := TButton.Create(FToolbar);
  FBtnSendSQL.Parent := FToolbar;
  FBtnSendSQL.Caption := 'Enviar p/ SQL';
  FBtnSendSQL.SetBounds(578, 6, 98, 25);
  FBtnSendSQL.OnClick := @BtnSendSQLClick;

  FBtnRunSQL := TButton.Create(FToolbar);
  FBtnRunSQL.Parent := FToolbar;
  FBtnRunSQL.Caption := 'Executar SELECT';
  FBtnRunSQL.SetBounds(682, 6, 112, 25);
  FBtnRunSQL.OnClick := @BtnRunSQLClick;

  // Bottom SQL Preview Panel
  FBottomPanel := TPanel.Create(Self);
  FBottomPanel.Parent := Self;
  FBottomPanel.Align := alBottom;
  FBottomPanel.Height := 160;
  FBottomPanel.BevelOuter := bvNone;

  FBottomBar := TPanel.Create(FBottomPanel);
  FBottomBar.Parent := FBottomPanel;
  FBottomBar.Align := alTop;
  FBottomBar.Height := 24;
  FBottomBar.BevelOuter := bvNone;
  FBottomBar.Color := RGBToColor(238, 242, 246);

  LblTitle := TLabel.Create(FBottomBar);
  LblTitle.Parent := FBottomBar;
  LblTitle.Caption := 'SQL SELECT gerado pelo DER';
  LblTitle.Font.Style := [fsBold];
  LblTitle.SetBounds(8, 4, 220, 16);

  FLblStatus := TLabel.Create(FBottomBar);
  FLblStatus.Parent := FBottomBar;
  FLblStatus.Caption := 'Arraste ou use o menu da TreeView para adicionar tabelas ao DER.';
  FLblStatus.Font.Color := RGBToColor(71, 85, 105);
  FLblStatus.SetBounds(230, 4, 650, 16);

  FSQLHighlighter := TSynSQLSyn.Create(Self);
  FSQLEditor := TSynEdit.Create(FBottomPanel);
  FSQLEditor.Parent := FBottomPanel;
  FSQLEditor.Align := alClient;
  FSQLEditor.Highlighter := FSQLHighlighter;
  FSQLEditor.Font.Name := 'Consolas';
  FSQLEditor.Font.Size := 10;

  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Align := alBottom;
  FSplitter.Height := 5;

  // Center Diagram ScrollBox + PaintBox
  FScroll := TScrollBox.Create(Self);
  FScroll.Parent := Self;
  FScroll.Align := alClient;
  FScroll.Color := clWhite;
  FScroll.OnDragOver := @CanvasDragOver;
  FScroll.OnDragDrop := @CanvasDragDrop;

  FPaint := TPaintBox.Create(FScroll);
  FPaint.Parent := FScroll;
  FPaint.SetBounds(0, 0, 1200, 800);
  FPaint.OnPaint := @PaintCanvas;
  FPaint.OnMouseDown := @CanvasMouseDown;
  FPaint.OnMouseMove := @CanvasMouseMove;
  FPaint.OnMouseUp := @CanvasMouseUp;
  FPaint.OnDblClick := @CanvasDblClick;
  FPaint.OnDragOver := @CanvasDragOver;
  FPaint.OnDragDrop := @CanvasDragDrop;

  // Edge context menu
  FEdgeMenu := TPopupMenu.Create(Self);
  MI := TMenuItem.Create(FEdgeMenu); MI.Caption := 'INNER JOIN'; MI.Tag := Ord(jtInner); MI.OnClick := @EdgeMenuJoinClick; FEdgeMenu.Items.Add(MI);
  MI := TMenuItem.Create(FEdgeMenu); MI.Caption := 'LEFT JOIN'; MI.Tag := Ord(jtLeft); MI.OnClick := @EdgeMenuJoinClick; FEdgeMenu.Items.Add(MI);
  MI := TMenuItem.Create(FEdgeMenu); MI.Caption := 'RIGHT JOIN'; MI.Tag := Ord(jtRight); MI.OnClick := @EdgeMenuJoinClick; FEdgeMenu.Items.Add(MI);
  MI := TMenuItem.Create(FEdgeMenu); MI.Caption := 'WHERE (vínculo por WHERE)'; MI.Tag := Ord(jtWhere); MI.OnClick := @EdgeMenuJoinClick; FEdgeMenu.Items.Add(MI);
  FEdgeMenu.Items.AddSeparator;
  MI := TMenuItem.Create(FEdgeMenu); MI.Caption := 'Remover relacionamento'; MI.OnClick := @EdgeMenuDeleteClick; FEdgeMenu.Items.Add(MI);

  // Table context menu
  FTableMenu := TPopupMenu.Create(Self);
  MI := TMenuItem.Create(FTableMenu); MI.Caption := 'Marcar todas as colunas'; MI.OnClick := @TableMenuSelectAllClick; FTableMenu.Items.Add(MI);
  MI := TMenuItem.Create(FTableMenu); MI.Caption := 'Desmarcar todas as colunas'; MI.OnClick := @TableMenuUnselectAllClick; FTableMenu.Items.Add(MI);
  FTableMenu.Items.AddSeparator;
  MI := TMenuItem.Create(FTableMenu); MI.Caption := 'Remover tabela do DER'; MI.OnClick := @TableMenuRemoveClick; FTableMenu.Items.Add(MI);
end;

destructor TMQueryDERPanel.Destroy;
begin
  FEdges.Free;
  FTables.Free;
  inherited Destroy;
end;

procedure TMQueryDERPanel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FConnection) then
    FConnection := nil;
end;

procedure TMQueryDERPanel.SetConnectionInfo(AConnection: TZConnection; const ASchema: string);
begin
  if FConnection <> AConnection then
  begin
    if FConnection <> nil then
      FConnection.RemoveFreeNotification(Self);
    FConnection := AConnection;
    if FConnection <> nil then
      FConnection.FreeNotification(Self);
  end;
  FSchema := ASchema;
end;

function TMQueryDERPanel.NextAlias(const ATableName: string): string;
var
  Base: string;
  Idx, I: Integer;
  Used: Boolean;
begin
  Base := LowerCase(Copy(Trim(ATableName), 1, 1));
  if (Base = '') or not (Base[1] in ['a'..'z']) then
    Base := 't';
  Idx := 1;
  while True do
  begin
    if Idx = 1 then
      Result := Base
    else
      Result := Base + IntToStr(Idx);
    Used := False;
    for I := 0 to FTables.Count - 1 do
      if SameText(TDERTableNode(FTables[I]).Alias, Result) then
      begin
        Used := True;
        Break;
      end;
    if not Used then Exit;
    Inc(Idx);
  end;
end;

procedure TMQueryDERPanel.LoadTableMetadata(ANode: TDERTableNode; ATreeNode: TTreeNode);
var
  Q: TZQuery;
  Meta: IZDatabaseMetadata;
  Rows: IZResultSet;
  Catalog, Schema, Protocol, ColName: string;
  Col: TDERColumnItem;
  FK: TDERForeignKeyInfo;
  Idx: Integer;
  Child, Sub: TTreeNode;
begin
  if (FConnection <> nil) and FConnection.Connected then
  begin
    Protocol := LowerCase(FConnection.Protocol);
    if Pos('sqlite', Protocol) > 0 then
    begin
      Q := TZQuery.Create(nil);
      try
        Q.Connection := FConnection;
        Q.SQL.Text := 'PRAGMA main.table_info(' + QuotedStr(ANode.TableName) + ')';
        Q.Open;
        while not Q.EOF do
        begin
          Col := TDERColumnItem.Create;
          Col.Name := Q.FieldByName('name').AsString;
          Col.DataType := Q.FieldByName('type').AsString;
          Col.IsPK := Q.FieldByName('pk').AsInteger > 0;
          Col.Selected := True;
          ANode.Columns.Add(Col);
          Q.Next;
        end;
        Q.Close;

        Q.SQL.Text := 'PRAGMA main.foreign_key_list(' + QuotedStr(ANode.TableName) + ')';
        Q.Open;
        while not Q.EOF do
        begin
          FK := TDERForeignKeyInfo.Create;
          FK.ConstraintName := 'fk_' + Q.FieldByName('id').AsString;
          FK.ColumnName := Q.FieldByName('from').AsString;
          FK.RefSchema := 'main';
          FK.RefTable := Q.FieldByName('table').AsString;
          FK.RefColumn := Q.FieldByName('to').AsString;
          ANode.ForeignKeys.Add(FK);
          Idx := ANode.ColumnIndex(FK.ColumnName);
          if Idx >= 0 then
            TDERColumnItem(ANode.Columns[Idx]).IsFK := True;
          Q.Next;
        end;
        Q.Close;
      finally
        Q.Free;
      end;
    end
    else
    begin
      try
        Meta := FConnection.DbcConnection.GetMetadata;
        Catalog := '';
        Schema := ANode.SchemaName;
        if (Pos('mysql', Protocol) > 0) or (Pos('mariadb', Protocol) > 0) or (Pos('mssql', Protocol) > 0) then
          Catalog := FConnection.Database;
        if (Pos('oracle', Protocol) > 0) and (Schema = '') then
          Schema := FConnection.User;

        Rows := Meta.GetColumns(Catalog, Schema, ANode.TableName, '%');
        while Rows.Next do
        begin
          if not SameText(Rows.GetStringByName('TABLE_NAME'), ANode.TableName) then Continue;
          if (Schema <> '') and (Rows.GetStringByName('TABLE_SCHEM') <> '') and
             not SameText(Rows.GetStringByName('TABLE_SCHEM'), Schema) then Continue;
          Col := TDERColumnItem.Create;
          Col.Name := Rows.GetStringByName('COLUMN_NAME');
          Col.DataType := Rows.GetStringByName('TYPE_NAME');
          Col.Selected := True;
          ANode.Columns.Add(Col);
        end;
        Rows.Close;

        Rows := Meta.GetPrimaryKeys(Catalog, Schema, ANode.TableName);
        while Rows.Next do
        begin
          Idx := ANode.ColumnIndex(Rows.GetStringByName('COLUMN_NAME'));
          if Idx >= 0 then
            TDERColumnItem(ANode.Columns[Idx]).IsPK := True;
        end;
        Rows.Close;

        Rows := Meta.GetImportedKeys(Catalog, Schema, ANode.TableName);
        while Rows.Next do
        begin
          FK := TDERForeignKeyInfo.Create;
          FK.ConstraintName := Rows.GetStringByName('FK_NAME');
          FK.ColumnName := Rows.GetStringByName('FKCOLUMN_NAME');
          FK.RefSchema := Rows.GetStringByName('PKTABLE_SCHEM');
          FK.RefTable := Rows.GetStringByName('PKTABLE_NAME');
          FK.RefColumn := Rows.GetStringByName('PKCOLUMN_NAME');
          ANode.ForeignKeys.Add(FK);
          Idx := ANode.ColumnIndex(FK.ColumnName);
          if Idx >= 0 then
            TDERColumnItem(ANode.Columns[Idx]).IsFK := True;
        end;
        Rows.Close;
        Rows := nil;
      except
        // Fallback to TreeView below if metadata throws
      end;
    end;
  end;

  // Fallback to TreeView child nodes if metadata returned no columns
  if (ANode.Columns.Count = 0) and (ATreeNode <> nil) then
  begin
    Child := ATreeNode.GetFirstChild;
    while Child <> nil do
    begin
      if SameText(Child.Text, 'fields') then
      begin
        Sub := Child.GetFirstChild;
        while Sub <> nil do
        begin
          ColName := CleanColNameFromTree(Sub.Text);
          if (ColName <> '') and (ANode.ColumnIndex(ColName) < 0) then
          begin
            Col := TDERColumnItem.Create;
            Col.Name := ColName;
            Col.Selected := True;
            ANode.Columns.Add(Col);
          end;
          Sub := Sub.GetNextSibling;
        end;
      end;
      Child := Child.GetNextSibling;
    end;
  end;
end;

function TMQueryDERPanel.EdgeExists(T1: TDERTableNode; const C1: string;
  T2: TDERTableNode; const C2: string): Boolean;
var
  I: Integer;
  E: TDERJoinEdge;
begin
  for I := 0 to FEdges.Count - 1 do
  begin
    E := TDERJoinEdge(FEdges[I]);
    if ((E.SourceTable = T1) and (E.TargetTable = T2) and
        SameText(E.SourceColumn, C1) and SameText(E.TargetColumn, C2)) or
       ((E.SourceTable = T2) and (E.TargetTable = T1) and
        SameText(E.SourceColumn, C2) and SameText(E.TargetColumn, C1)) then
      Exit(True);
  end;
  Result := False;
end;

procedure TMQueryDERPanel.AutoDetectEdgesFor(ANode: TDERTableNode);
var
  I, J: Integer;
  Other: TDERTableNode;
  FK: TDERForeignKeyInfo;
  E: TDERJoinEdge;
  RefCol: string;
begin
  for I := 0 to FTables.Count - 1 do
  begin
    Other := TDERTableNode(FTables[I]);
    if Other = ANode then Continue;

    // FKs from ANode -> Other
    for J := 0 to ANode.ForeignKeys.Count - 1 do
    begin
      FK := TDERForeignKeyInfo(ANode.ForeignKeys[J]);
      if SameText(FK.RefTable, Other.TableName) then
      begin
        RefCol := FK.RefColumn;
        if (RefCol = '') and (Other.Columns.Count > 0) then
          RefCol := TDERColumnItem(Other.Columns[0]).Name;
        if not EdgeExists(ANode, FK.ColumnName, Other, RefCol) then
        begin
          E := TDERJoinEdge.Create;
          E.SourceTable := ANode;
          E.SourceColumn := FK.ColumnName;
          E.TargetTable := Other;
          E.TargetColumn := RefCol;
          E.JoinType := jtInner;
          FEdges.Add(E);
        end;
      end;
    end;

    // FKs from Other -> ANode
    for J := 0 to Other.ForeignKeys.Count - 1 do
    begin
      FK := TDERForeignKeyInfo(Other.ForeignKeys[J]);
      if SameText(FK.RefTable, ANode.TableName) then
      begin
        RefCol := FK.RefColumn;
        if (RefCol = '') and (ANode.Columns.Count > 0) then
          RefCol := TDERColumnItem(ANode.Columns[0]).Name;
        if not EdgeExists(Other, FK.ColumnName, ANode, RefCol) then
        begin
          E := TDERJoinEdge.Create;
          E.SourceTable := Other;
          E.SourceColumn := FK.ColumnName;
          E.TargetTable := ANode;
          E.TargetColumn := RefCol;
          E.JoinType := jtInner;
          FEdges.Add(E);
        end;
      end;
    end;
  end;
end;

procedure TMQueryDERPanel.AddTable(const ATableName: string; ATreeNode: TTreeNode;
  ADropX: Integer; ADropY: Integer);
var
  I, ColCount: Integer;
  Node: TDERTableNode;
  CleanName: string;
begin
  CleanName := Trim(ATableName);
  if CleanName = '' then Exit;

  for I := 0 to FTables.Count - 1 do
    if SameText(TDERTableNode(FTables[I]).TableName, CleanName) then
    begin
      FSelectedTable := TDERTableNode(FTables[I]);
      FPaint.Invalidate;
      Exit;
    end;

  Node := TDERTableNode.Create;
  Node.SchemaName := FSchema;
  Node.TableName := CleanName;
  Node.Alias := NextAlias(CleanName);
  if (ADropX >= 0) and (ADropY >= 0) then
  begin
    Node.X := Max(16, Round(ADropX / FZoom) - Node.Width div 2);
    Node.Y := Max(16, Round(ADropY / FZoom) - 12);
  end
  else
  begin
    ColCount := FTables.Count;
    Node.X := 24 + (ColCount mod 3) * (DER_TABLE_W + 70);
    Node.Y := 24 + (ColCount div 3) * 230;
  end;

  LoadTableMetadata(Node, ATreeNode);
  FTables.Add(Node);
  AutoDetectEdgesFor(Node);
  FSelectedTable := Node;
  UpdateScrollArea;
  UpdateStatus;
  RebuildSQL;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.RemoveTable(ANode: TDERTableNode);
var
  I: Integer;
  E: TDERJoinEdge;
begin
  if ANode = nil then Exit;
  for I := FEdges.Count - 1 downto 0 do
  begin
    E := TDERJoinEdge(FEdges[I]);
    if (E.SourceTable = ANode) or (E.TargetTable = ANode) then
    begin
      if FSelectedEdge = E then FSelectedEdge := nil;
      FEdges.Delete(I);
    end;
  end;
  if FSelectedTable = ANode then FSelectedTable := nil;
  FTables.Remove(ANode);
  UpdateJoinControls;
  UpdateScrollArea;
  UpdateStatus;
  RebuildSQL;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.ClearDER;
begin
  FSelectedTable := nil;
  FSelectedEdge := nil;
  FEdges.Clear;
  FTables.Clear;
  UpdateJoinControls;
  UpdateScrollArea;
  UpdateStatus;
  RebuildSQL;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.ArrangeTables;
var
  I, Cols: Integer;
  T: TDERTableNode;
begin
  Cols := Max(1, Round(Sqrt(Max(1, FTables.Count))));
  if Cols < 3 then Cols := 3;
  for I := 0 to FTables.Count - 1 do
  begin
    T := TDERTableNode(FTables[I]);
    T.X := 24 + (I mod Cols) * (DER_TABLE_W + 80);
    T.Y := 24 + (I div Cols) * 240;
  end;
  UpdateScrollArea;
  FPaint.Invalidate;
end;

function TMQueryDERPanel.JoinTypeCaption(AJT: TDERJoinType): string;
begin
  case AJT of
    jtInner: Result := 'INNER';
    jtLeft: Result := 'LEFT';
    jtRight: Result := 'RIGHT';
    jtWhere: Result := 'WHERE';
  end;
end;

function TMQueryDERPanel.JoinTypeKeyword(AJT: TDERJoinType): string;
begin
  case AJT of
    jtInner: Result := 'INNER JOIN';
    jtLeft: Result := 'LEFT JOIN';
    jtRight: Result := 'RIGHT JOIN';
    jtWhere: Result := 'WHERE';
  end;
end;

function TMQueryDERPanel.QuoteIdent(const AName: string): string;
begin
  Result := AName;
end;

procedure TMQueryDERPanel.RebuildSQL;
var
  SL, SelectCols, FromTables, JoinClauses, WhereClauses: TStringList;
  UsedTables: TList;
  I, J: Integer;
  T, NextT: TDERTableNode;
  Col: TDERColumnItem;
  E: TDERJoinEdge;
  Progress: Boolean;
  Line: string;

  function IsUsed(AT: TDERTableNode): Boolean;
  begin
    Result := UsedTables.IndexOf(AT) >= 0;
  end;

  procedure AppendSelectCols(AT: TDERTableNode);
  var
    K: Integer;
    C: TDERColumnItem;
  begin
    for K := 0 to AT.Columns.Count - 1 do
    begin
      C := TDERColumnItem(AT.Columns[K]);
      if C.Selected then
        SelectCols.Add('  ' + AT.Alias + '.' + QuoteIdent(C.Name));
    end;
  end;

begin
  if FTables.Count = 0 then
  begin
    FSQLEditor.Lines.Text := '';
    Exit;
  end;

  SL := TStringList.Create;
  SelectCols := TStringList.Create;
  FromTables := TStringList.Create;
  JoinClauses := TStringList.Create;
  WhereClauses := TStringList.Create;
  UsedTables := TList.Create;
  try
    for I := 0 to FTables.Count - 1 do
      AppendSelectCols(TDERTableNode(FTables[I]));

    if SelectCols.Count = 0 then
      SelectCols.Add('  *');

    // Start FROM with first table
    T := TDERTableNode(FTables[0]);
    UsedTables.Add(T);
    FromTables.Add(T.FullName + ' ' + T.Alias);

    // Resolve JOIN edges iteratively
    repeat
      Progress := False;
      for I := 0 to FEdges.Count - 1 do
      begin
        E := TDERJoinEdge(FEdges[I]);
        if E.JoinType = jtWhere then Continue;

        if IsUsed(E.SourceTable) and not IsUsed(E.TargetTable) then
        begin
          NextT := E.TargetTable;
          UsedTables.Add(NextT);
          JoinClauses.Add(Format('%s %s %s ON %s.%s = %s.%s',
            [JoinTypeKeyword(E.JoinType), NextT.FullName, NextT.Alias,
             E.SourceTable.Alias, E.SourceColumn,
             E.TargetTable.Alias, E.TargetColumn]));
          Progress := True;
        end
        else if IsUsed(E.TargetTable) and not IsUsed(E.SourceTable) then
        begin
          NextT := E.SourceTable;
          UsedTables.Add(NextT);
          JoinClauses.Add(Format('%s %s %s ON %s.%s = %s.%s',
            [JoinTypeKeyword(E.JoinType), NextT.FullName, NextT.Alias,
             E.SourceTable.Alias, E.SourceColumn,
             E.TargetTable.Alias, E.TargetColumn]));
          Progress := True;
        end;
      end;
    until not Progress;

    // Any remaining tables (disconnected or connected only via WHERE) go into FROM
    for I := 0 to FTables.Count - 1 do
    begin
      T := TDERTableNode(FTables[I]);
      if not IsUsed(T) then
      begin
        UsedTables.Add(T);
        FromTables.Add(T.FullName + ' ' + T.Alias);
      end;
    end;

    // Emit WHERE join conditions (or extra JOINs between already-used tables)
    for I := 0 to FEdges.Count - 1 do
    begin
      E := TDERJoinEdge(FEdges[I]);
      if E.JoinType = jtWhere then
      begin
        WhereClauses.Add(Format('%s.%s = %s.%s',
          [E.SourceTable.Alias, E.SourceColumn,
           E.TargetTable.Alias, E.TargetColumn]));
      end;
    end;

    SL.Add('SELECT');
    for I := 0 to SelectCols.Count - 1 do
    begin
      Line := SelectCols[I];
      if I < SelectCols.Count - 1 then
        Line := Line + ',';
      SL.Add(Line);
    end;

    Line := 'FROM ' + FromTables[0];
    for I := 1 to FromTables.Count - 1 do
      Line := Line + ', ' + FromTables[I];
    SL.Add(Line);

    for I := 0 to JoinClauses.Count - 1 do
      SL.Add(JoinClauses[I]);

    if WhereClauses.Count > 0 then
    begin
      SL.Add('WHERE ' + WhereClauses[0]);
      for I := 1 to WhereClauses.Count - 1 do
        SL.Add('  AND ' + WhereClauses[I]);
    end;

    FSQLEditor.Lines.Assign(SL);
  finally
    UsedTables.Free;
    WhereClauses.Free;
    JoinClauses.Free;
    FromTables.Free;
    SelectCols.Free;
    SL.Free;
  end;
end;

function TMQueryDERPanel.ScreenToWorld(const P: TPoint): TPoint;
begin
  Result.X := Round(P.X / FZoom);
  Result.Y := Round(P.Y / FZoom);
end;

function TMQueryDERPanel.TableAt(WX, WY: Integer; out AColIndex: Integer; out AIsCloseBtn: Boolean): TDERTableNode;
var
  I, J: Integer;
  T: TDERTableNode;
  R, CloseR, ColR: TRect;
begin
  AColIndex := -1;
  AIsCloseBtn := False;
  for I := FTables.Count - 1 downto 0 do
  begin
    T := TDERTableNode(FTables[I]);
    R := T.BoundsRect;
    if PtInRect(R, Point(WX, WY)) then
    begin
      CloseR := Rect(T.X + T.Width - 22, T.Y + 4, T.X + T.Width - 4, T.Y + 22);
      if PtInRect(CloseR, Point(WX, WY)) then
        AIsCloseBtn := True
      else if WY > T.Y + T.HeaderHeight then
      begin
        for J := 0 to T.Columns.Count - 1 do
        begin
          ColR := T.ColumnRect(J);
          if PtInRect(ColR, Point(WX, WY)) then
          begin
            AColIndex := J;
            Break;
          end;
        end;
      end;
      Exit(T);
    end;
  end;
  Result := nil;
end;

function TMQueryDERPanel.PointToSegmentDist(PX, PY, X1, Y1, X2, Y2: Integer): Double;
var
  DX, DY, Len2, T, ProjX, ProjY: Double;
begin
  DX := X2 - X1;
  DY := Y2 - Y1;
  Len2 := DX * DX + DY * DY;
  if Len2 < 1e-6 then
    Exit(Sqrt(Sqr(PX - X1) + Sqr(PY - Y1)));
  T := ((PX - X1) * DX + (PY - Y1) * DY) / Len2;
  if T < 0 then T := 0 else if T > 1 then T := 1;
  ProjX := X1 + T * DX;
  ProjY := Y1 + T * DY;
  Result := Sqrt(Sqr(PX - ProjX) + Sqr(PY - ProjY));
end;

function TMQueryDERPanel.EdgeAt(WX, WY: Integer): TDERJoinEdge;
var
  I: Integer;
  E: TDERJoinEdge;
  D: Double;
begin
  for I := FEdges.Count - 1 downto 0 do
  begin
    E := TDERJoinEdge(FEdges[I]);
    if PtInRect(E.LabelRect, Point(WX, WY)) then
      Exit(E);
    D := Min(PointToSegmentDist(WX, WY, E.P1.X, E.P1.Y, E.M1.X, E.M1.Y),
             Min(PointToSegmentDist(WX, WY, E.M1.X, E.M1.Y, E.M2.X, E.M2.Y),
                 PointToSegmentDist(WX, WY, E.M2.X, E.M2.Y, E.P2.X, E.P2.Y)));
    if D <= 8.0 then
      Exit(E);
  end;
  Result := nil;
end;

procedure TMQueryDERPanel.UpdateScrollArea;
var
  I, MaxX, MaxY: Integer;
  T: TDERTableNode;
begin
  MaxX := 900;
  MaxY := 600;
  for I := 0 to FTables.Count - 1 do
  begin
    T := TDERTableNode(FTables[I]);
    MaxX := Max(MaxX, T.X + T.Width + 120);
    MaxY := Max(MaxY, T.Y + T.TotalHeight + 120);
  end;
  FPaint.SetBounds(0, 0, Max(FScroll.ClientWidth, Round(MaxX * FZoom)),
                         Max(FScroll.ClientHeight, Round(MaxY * FZoom)));
end;

procedure TMQueryDERPanel.UpdateJoinControls;
begin
  if FSelectedEdge <> nil then
  begin
    FCbJoinType.Enabled := True;
    FCbJoinType.ItemIndex := Ord(FSelectedEdge.JoinType);
  end
  else
  begin
    FCbJoinType.Enabled := False;
  end;
end;

procedure TMQueryDERPanel.UpdateStatus;
begin
  if FSelectedEdge <> nil then
    FLblStatus.Caption := Format('Relacionamento selecionado: %s.%s = %s.%s (%s) — altere na barra ou clique com o botão direito.',
      [FSelectedEdge.SourceTable.TableName, FSelectedEdge.SourceColumn,
       FSelectedEdge.TargetTable.TableName, FSelectedEdge.TargetColumn,
       JoinTypeKeyword(FSelectedEdge.JoinType)])
  else
    FLblStatus.Caption := Format('%d tabela(s), %d relacionamento(s). Clique na seta para mudar INNER/LEFT/RIGHT/WHERE; arraste entre colunas para vincular.',
      [FTables.Count, FEdges.Count]);
end;

procedure TMQueryDERPanel.DrawDER(C: TCanvas; const ATitle: string);
var
  I, J, YRow, MidX, LX, LY, LW, LH: Integer;
  T, SrcT, DstT: TDERTableNode;
  Col: TDERColumnItem;
  E: TDERJoinEdge;
  R, BoxR: TRect;
  S, Badge, Lbl: string;
  SrcRight: Boolean;
  P1, P2, M1, M2: TPoint;
begin
  C.Brush.Color := clWhite;
  C.FillRect(0, 0, C.Width, C.Height);

  if ATitle <> '' then
  begin
    C.Font.Name := 'Segoe UI';
    C.Font.Size := 12;
    C.Font.Style := [fsBold];
    C.Font.Color := RGBToColor(30, 41, 59);
    C.TextOut(16, 8, ATitle);
  end;

  if FTables.Count = 0 then
  begin
    C.Font.Name := 'Segoe UI';
    C.Font.Size := 11;
    C.Font.Style := [];
    C.Font.Color := RGBToColor(120, 130, 145);
    C.TextOut(32, 42, 'Use a TreeView à esquerda (clique direito -> "Adicionar ao DER" ou arraste a tabela) para montar seu SELECT visual.');
    Exit;
  end;

  // Draw relationship edges first
  for I := 0 to FEdges.Count - 1 do
  begin
    E := TDERJoinEdge(FEdges[I]);
    SrcT := E.SourceTable;
    DstT := E.TargetTable;
    SrcRight := (SrcT.X + SrcT.Width div 2) <= (DstT.X + DstT.Width div 2);

    if SrcRight then
    begin
      P1 := Point(SrcT.X + SrcT.Width, SrcT.ColumnAnchorY(E.SourceColumn));
      P2 := Point(DstT.X, DstT.ColumnAnchorY(E.TargetColumn));
    end
    else
    begin
      P1 := Point(SrcT.X, SrcT.ColumnAnchorY(E.SourceColumn));
      P2 := Point(DstT.X + DstT.Width, DstT.ColumnAnchorY(E.TargetColumn));
    end;
    MidX := (P1.X + P2.X) div 2;
    M1 := Point(MidX, P1.Y);
    M2 := Point(MidX, P2.Y);

    E.P1 := P1; E.P2 := P2; E.M1 := M1; E.M2 := M2;

    if E = FSelectedEdge then
    begin
      C.Pen.Color := RGBToColor(234, 88, 12);
      C.Pen.Width := 3;
    end
    else if E.JoinType = jtWhere then
    begin
      C.Pen.Color := RGBToColor(124, 58, 237);
      C.Pen.Width := 2;
    end
    else
    begin
      C.Pen.Color := RGBToColor(37, 99, 235);
      C.Pen.Width := 2;
    end;

    if E.JoinType = jtWhere then
      C.Pen.Style := psDash
    else
      C.Pen.Style := psSolid;

    C.PolyLine([P1, M1, M2, P2]);
    C.Pen.Style := psSolid;

    // Endpoint circle at source, arrow at target
    C.Brush.Color := C.Pen.Color;
    C.Ellipse(P1.X - 4, P1.Y - 4, P1.X + 4, P1.Y + 4);
    if SrcRight then
      C.Polygon([P2, Point(P2.X - 8, P2.Y - 4), Point(P2.X - 8, P2.Y + 4)])
    else
      C.Polygon([P2, Point(P2.X + 8, P2.Y - 4), Point(P2.X + 8, P2.Y + 4)]);

    // Join type badge in the middle
    Lbl := JoinTypeCaption(E.JoinType);
    C.Font.Name := 'Segoe UI';
    C.Font.Size := 8;
    C.Font.Style := [fsBold];
    LW := C.TextWidth(Lbl) + 12;
    LH := 18;
    LX := MidX - LW div 2;
    LY := ((P1.Y + P2.Y) div 2) - LH div 2;
    E.LabelRect := Rect(LX, LY, LX + LW, LY + LH);

    if E = FSelectedEdge then
      C.Brush.Color := RGBToColor(255, 237, 213)
    else
      C.Brush.Color := RGBToColor(239, 246, 255);
    C.RoundRect(E.LabelRect.Left, E.LabelRect.Top, E.LabelRect.Right, E.LabelRect.Bottom, 6, 6);
    C.Font.Color := C.Pen.Color;
    C.TextOut(LX + 6, LY + 2, Lbl);
    C.Pen.Width := 1;
  end;

  // Draw live link preview if dragging column-to-column
  if FIsLinking and (FLinkingTable <> nil) then
  begin
    C.Pen.Color := RGBToColor(234, 88, 12);
    C.Pen.Width := 2;
    C.Pen.Style := psDot;
    C.Line(FLinkingTable.X + FLinkingTable.Width div 2,
           FLinkingTable.ColumnAnchorY(FLinkingCol),
           FLinkMousePt.X, FLinkMousePt.Y);
    C.Pen.Style := psSolid;
    C.Pen.Width := 1;
  end;

  // Draw table boxes
  for I := 0 to FTables.Count - 1 do
  begin
    T := TDERTableNode(FTables[I]);
    BoxR := T.BoundsRect;

    // Shadow
    C.Brush.Color := RGBToColor(226, 232, 240);
    C.Pen.Color := RGBToColor(226, 232, 240);
    C.FillRect(BoxR.Left + 3, BoxR.Top + 3, BoxR.Right + 3, BoxR.Bottom + 3);

    // Body
    C.Brush.Color := clWhite;
    if T = FSelectedTable then
    begin
      C.Pen.Color := RGBToColor(37, 99, 235);
      C.Pen.Width := 2;
    end
    else
    begin
      C.Pen.Color := RGBToColor(148, 163, 184);
      C.Pen.Width := 1;
    end;
    C.Rectangle(BoxR);
    C.Pen.Width := 1;

    // Header
    if T = FSelectedTable then
      C.Brush.Color := RGBToColor(30, 64, 175)
    else
      C.Brush.Color := RGBToColor(51, 65, 85);
    C.FillRect(T.X + 1, T.Y + 1, T.X + T.Width - 1, T.Y + T.HeaderHeight);

    C.Font.Name := 'Segoe UI';
    C.Font.Size := 9;
    C.Font.Style := [fsBold];
    C.Font.Color := clWhite;
    C.Brush.Style := bsClear;
    C.TextOut(T.X + 8, T.Y + 5, T.TableName + ' (' + T.Alias + ')');
    C.TextOut(T.X + T.Width - 16, T.Y + 4, 'x');
    C.Brush.Style := bsSolid;

    // Columns
    for J := 0 to T.Columns.Count - 1 do
    begin
      Col := TDERColumnItem(T.Columns[J]);
      R := T.ColumnRect(J);
      YRow := R.Top;

      if J mod 2 = 1 then
        C.Brush.Color := RGBToColor(248, 250, 252)
      else
        C.Brush.Color := clWhite;
      C.FillRect(R);

      // Checkbox
      C.Pen.Color := RGBToColor(100, 116, 139);
      C.Brush.Color := clWhite;
      C.Rectangle(T.X + 8, YRow + 4, T.X + 20, YRow + 16);
      if Col.Selected then
      begin
        C.Pen.Color := RGBToColor(22, 163, 74);
        C.Pen.Width := 2;
        C.Line(T.X + 10, YRow + 10, T.X + 13, YRow + 14);
        C.Line(T.X + 13, YRow + 14, T.X + 18, YRow + 6);
        C.Pen.Width := 1;
      end;

      Badge := '';
      if Col.IsPK then Badge := 'PK'
      else if Col.IsFK then Badge := 'FK';

      C.Font.Name := 'Segoe UI';
      C.Font.Size := 8;
      if Badge <> '' then
      begin
        C.Font.Style := [fsBold];
        if Col.IsPK then
          C.Font.Color := RGBToColor(217, 119, 6)
        else
          C.Font.Color := RGBToColor(37, 99, 235);
        C.Brush.Style := bsClear;
        C.TextOut(T.X + 24, YRow + 3, Badge);
        C.Brush.Style := bsSolid;
      end;

      C.Font.Style := [];
      if Col.IsPK then
        C.Font.Style := [fsBold];
      C.Font.Color := RGBToColor(30, 41, 59);
      S := Col.Name;
      if Col.DataType <> '' then
        S := S + ' : ' + LowerCase(Col.DataType);
      C.Brush.Style := bsClear;
      C.TextOut(T.X + 46, YRow + 3, Copy(S, 1, 28));
      C.Brush.Style := bsSolid;
    end;
  end;
end;

procedure TMQueryDERPanel.PaintCanvas(Sender: TObject);
begin
  DrawDER(FPaint.Canvas);
end;

procedure TMQueryDERPanel.CanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  WP: TPoint;
  T: TDERTableNode;
  E: TDERJoinEdge;
  ColIdx: Integer;
  IsClose: Boolean;
  Col: TDERColumnItem;
  ScrPt: TPoint;
begin
  WP := ScreenToWorld(Point(X, Y));
  T := TableAt(WP.X, WP.Y, ColIdx, IsClose);

  if T <> nil then
  begin
    FSelectedTable := T;
    FSelectedEdge := nil;
    UpdateJoinControls;

    if (Button = mbLeft) and IsClose then
    begin
      RemoveTable(T);
      Exit;
    end;

    if (Button = mbRight) then
    begin
      FPaint.Invalidate;
      ScrPt := FPaint.ClientToScreen(Point(X, Y));
      FTableMenu.Popup(ScrPt.X, ScrPt.Y);
      Exit;
    end;

    if (Button = mbLeft) and (ColIdx >= 0) then
    begin
      Col := TDERColumnItem(T.Columns[ColIdx]);
      // Click on checkbox (left 26px) toggles column selection;
      // Dragging from column body starts manual relationship linking!
      if WP.X <= T.X + 28 then
      begin
        Col.Selected := not Col.Selected;
        RebuildSQL;
        FPaint.Invalidate;
      end
      else
      begin
        FIsLinking := True;
        FLinkingTable := T;
        FLinkingCol := Col.Name;
        FLinkMousePt := WP;
      end;
      Exit;
    end;

    if Button = mbLeft then
    begin
      // Drag table by header
      FDragTable := T;
      FDragOffset := Point(WP.X - T.X, WP.Y - T.Y);
      FPaint.Invalidate;
    end;
    Exit;
  end;

  E := EdgeAt(WP.X, WP.Y);
  if E <> nil then
  begin
    FSelectedEdge := E;
    FSelectedTable := nil;
    UpdateJoinControls;
    UpdateStatus;
    FPaint.Invalidate;
    if Button = mbRight then
    begin
      ScrPt := FPaint.ClientToScreen(Point(X, Y));
      FEdgeMenu.Popup(ScrPt.X, ScrPt.Y);
    end;
    Exit;
  end;

  FSelectedTable := nil;
  FSelectedEdge := nil;
  UpdateJoinControls;
  UpdateStatus;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.CanvasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  WP: TPoint;
begin
  WP := ScreenToWorld(Point(X, Y));
  if FDragTable <> nil then
  begin
    FDragTable.X := Max(8, WP.X - FDragOffset.X);
    FDragTable.Y := Max(8, WP.Y - FDragOffset.Y);
    UpdateScrollArea;
    FPaint.Invalidate;
  end
  else if FIsLinking then
  begin
    FLinkMousePt := WP;
    FPaint.Invalidate;
  end;
end;

procedure TMQueryDERPanel.CanvasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  WP: TPoint;
  TargetT: TDERTableNode;
  ColIdx: Integer;
  IsClose: Boolean;
  TargetCol: string;
  E: TDERJoinEdge;
begin
  if FIsLinking then
  begin
    WP := ScreenToWorld(Point(X, Y));
    TargetT := TableAt(WP.X, WP.Y, ColIdx, IsClose);
    if (TargetT <> nil) and (TargetT <> FLinkingTable) and (ColIdx >= 0) then
    begin
      TargetCol := TDERColumnItem(TargetT.Columns[ColIdx]).Name;
      if not EdgeExists(FLinkingTable, FLinkingCol, TargetT, TargetCol) then
      begin
        E := TDERJoinEdge.Create;
        E.SourceTable := FLinkingTable;
        E.SourceColumn := FLinkingCol;
        E.TargetTable := TargetT;
        E.TargetColumn := TargetCol;
        E.JoinType := jtInner;
        FEdges.Add(E);
        FSelectedEdge := E;
        UpdateJoinControls;
        UpdateStatus;
        RebuildSQL;
      end;
    end;
    FIsLinking := False;
    FLinkingTable := nil;
    FPaint.Invalidate;
  end;
  FDragTable := nil;
end;

procedure TMQueryDERPanel.CanvasDblClick(Sender: TObject);
begin
  if FSelectedEdge <> nil then
  begin
    // Cycle join type on double-click: INNER -> LEFT -> RIGHT -> WHERE
    FSelectedEdge.JoinType := TDERJoinType((Ord(FSelectedEdge.JoinType) + 1) mod 4);
    UpdateJoinControls;
    UpdateStatus;
    RebuildSQL;
    FPaint.Invalidate;
  end;
end;

procedure TMQueryDERPanel.CanvasDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TTreeView);
end;

procedure TMQueryDERPanel.CanvasDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  TV: TTreeView;
  Node, Cur: TTreeNode;
  P: TPoint;
begin
  if not (Source is TTreeView) then Exit;
  TV := TTreeView(Source);
  Node := TV.Selected;
  if Node = nil then Exit;

  // Walk up if a field/index/PK node was dragged
  Cur := Node;
  while (Cur <> nil) and (Cur.Parent <> nil) do
  begin
    if SameText(Cur.Parent.Text, 'tables') then
    begin
      Node := Cur;
      Break;
    end;
    Cur := Cur.Parent;
  end;

  if (Node.Parent <> nil) and SameText(Node.Parent.Text, 'tables') then
  begin
    P := FPaint.ScreenToClient(TControl(Sender).ClientToScreen(Point(X, Y)));
    AddTable(Node.Text, Node, P.X, P.Y);
  end;
end;

procedure TMQueryDERPanel.CbJoinTypeChange(Sender: TObject);
begin
  if (FSelectedEdge <> nil) and (FCbJoinType.ItemIndex >= 0) then
  begin
    FSelectedEdge.JoinType := TDERJoinType(FCbJoinType.ItemIndex);
    UpdateStatus;
    RebuildSQL;
    FPaint.Invalidate;
  end;
end;

procedure TMQueryDERPanel.EdgeMenuJoinClick(Sender: TObject);
begin
  if FSelectedEdge = nil then Exit;
  FSelectedEdge.JoinType := TDERJoinType(TMenuItem(Sender).Tag);
  UpdateJoinControls;
  UpdateStatus;
  RebuildSQL;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.EdgeMenuDeleteClick(Sender: TObject);
begin
  if FSelectedEdge = nil then Exit;
  FEdges.Remove(FSelectedEdge);
  FSelectedEdge := nil;
  UpdateJoinControls;
  UpdateStatus;
  RebuildSQL;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.TableMenuSelectAllClick(Sender: TObject);
var
  I: Integer;
begin
  if FSelectedTable = nil then Exit;
  for I := 0 to FSelectedTable.Columns.Count - 1 do
    TDERColumnItem(FSelectedTable.Columns[I]).Selected := True;
  RebuildSQL;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.TableMenuUnselectAllClick(Sender: TObject);
var
  I: Integer;
begin
  if FSelectedTable = nil then Exit;
  for I := 0 to FSelectedTable.Columns.Count - 1 do
    TDERColumnItem(FSelectedTable.Columns[I]).Selected := False;
  RebuildSQL;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.TableMenuRemoveClick(Sender: TObject);
begin
  if FSelectedTable <> nil then
    RemoveTable(FSelectedTable);
end;

procedure TMQueryDERPanel.BtnSendSQLClick(Sender: TObject);
begin
  if Assigned(FOnSendSQL) then
    FOnSendSQL(Self, FSQLEditor.Lines.Text, False);
end;

procedure TMQueryDERPanel.BtnRunSQLClick(Sender: TObject);
begin
  if Assigned(FOnSendSQL) then
    FOnSendSQL(Self, FSQLEditor.Lines.Text, True);
end;

procedure TMQueryDERPanel.BtnArrangeClick(Sender: TObject);
begin
  ArrangeTables;
end;

procedure TMQueryDERPanel.BtnPrintClick(Sender: TObject);
var
  Dlg: TPrintDialog;
  Bmp: TBitmap;
  I, MaxX, MaxY, PrintW, PrintH: Integer;
  T: TDERTableNode;
  Scale: Double;
  DstR: TRect;
begin
  if FTables.Count = 0 then
  begin
    ShowMessage('Adicione pelo menos uma tabela ao DER antes de imprimir.');
    Exit;
  end;

  Dlg := TPrintDialog.Create(Self);
  try
    if not Dlg.Execute then Exit;

    MaxX := 600;
    MaxY := 400;
    for I := 0 to FTables.Count - 1 do
    begin
      T := TDERTableNode(FTables[I]);
      MaxX := Max(MaxX, T.X + T.Width + 40);
      MaxY := Max(MaxY, T.Y + T.TotalHeight + 40);
    end;

    Bmp := TBitmap.Create;
    try
      Bmp.SetSize(MaxX, MaxY + 40);
      DrawDER(Bmp.Canvas, 'DER — Relacionamentos e Consulta SELECT');

      Printer.Title := 'DER - MQuery2';
      Printer.BeginDoc;
      try
        Scale := Min((Printer.PageWidth * 0.94) / Bmp.Width,
                     (Printer.PageHeight * 0.94) / Bmp.Height);
        PrintW := Round(Bmp.Width * Scale);
        PrintH := Round(Bmp.Height * Scale);
        DstR := Rect((Printer.PageWidth - PrintW) div 2,
                     (Printer.PageHeight - PrintH) div 2,
                     (Printer.PageWidth + PrintW) div 2,
                     (Printer.PageHeight + PrintH) div 2);
        Printer.Canvas.StretchDraw(DstR, Bmp);
      finally
        Printer.EndDoc;
      end;
    finally
      Bmp.Free;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TMQueryDERPanel.BtnClearClick(Sender: TObject);
begin
  ClearDER;
end;

procedure TMQueryDERPanel.BtnZoomOutClick(Sender: TObject);
begin
  FZoom := Max(0.6, FZoom - 0.1);
  UpdateScrollArea;
  FPaint.Invalidate;
end;

procedure TMQueryDERPanel.BtnZoomInClick(Sender: TObject);
begin
  FZoom := Min(1.5, FZoom + 0.1);
  UpdateScrollArea;
  FPaint.Invalidate;
end;

end.
