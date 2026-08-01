unit mnote_memory_map_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Graphics, Forms,
  aiagent_memorymap;

type
  TMNoteMemoryNode = record
    Bounds: TRect;
    ItemIndex: Integer;
  end;

  { TMNoteMemoryMapPanel }

  TMNoteMemoryMapPanel = class(TPanel)
  private
    FHeader: TPanel;
    FTitle: TLabel;
    FSummary: TLabel;
    FRefreshButton: TButton;
    FDetailsButton: TButton;
    FScrollBox: TScrollBox;
    FMapCanvas: TPaintBox;
    FDetails: TMemo;
    FSplitter: TSplitter;
    FTimer: TTimer;
    FMemoryMap: TAIAgentMemoryMap;
    FNodes: array of TMNoteMemoryNode;
    FSelectedIndex: Integer;
    FLastSignature: string;
    procedure PaintMap(Sender: TObject);
    procedure MapMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RefreshButtonClick(Sender: TObject);
    procedure DetailsButtonClick(Sender: TObject);
    procedure RefreshTimer(Sender: TObject);
    procedure PanelResize(Sender: TObject);
    procedure UpdateDetailsVisibility(AVisible: Boolean);
    procedure BuildNodes;
    procedure ShowDetails;
    function MapSignature: string;
    function NodeDepth(AItem: TAIAgentMemoryMapItem): Integer;
    function StatusText(AStatus: TAIAgentMemoryStepStatus): string;
    function StatusColor(AStatus: TAIAgentMemoryStepStatus): TColor;
    function ShortText(const AText: string; AMaxLength: Integer): string;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetMemoryMap(AMemoryMap: TAIAgentMemoryMap);
    procedure RefreshMap;
    property MemoryMap: TAIAgentMemoryMap read FMemoryMap;
  end;

implementation

function MapColor(ARed, AGreen, ABlue: Byte): TColor;
begin
  Result := RGBToColor(ARed, AGreen, ABlue);
end;

constructor TMNoteMemoryMapPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alClient;
  BevelOuter := bvNone;
  Color := MapColor(18, 22, 32);
  FSelectedIndex := -1;
  OnResize := @PanelResize;

  FHeader := TPanel.Create(Self);
  FHeader.Parent := Self;
  FHeader.Align := alTop;
  FHeader.Height := 48;
  FHeader.BevelOuter := bvNone;
  FHeader.Color := MapColor(28, 34, 48);
  FHeader.ParentBackground := False;

  FTitle := TLabel.Create(FHeader);
  FTitle.Parent := FHeader;
  FTitle.Left := 14;
  FTitle.Top := 7;
  FTitle.Caption := 'Mapa de memória da conversa';
  FTitle.Font.Style := [fsBold];
  FTitle.Font.Color := clWhite;
  FTitle.ParentFont := False;

  FSummary := TLabel.Create(FHeader);
  FSummary.Parent := FHeader;
  FSummary.Left := 14;
  FSummary.Top := 27;
  FSummary.Caption := 'Aguardando uma interação com a IA';
  FSummary.Font.Color := MapColor(150, 164, 190);
  FSummary.ParentFont := False;
  FSummary.AutoSize := False;
  FSummary.Width := 280;

  FRefreshButton := TButton.Create(FHeader);
  FRefreshButton.Parent := FHeader;
  FRefreshButton.Align := alRight;
  FRefreshButton.Width := 86;
  FRefreshButton.Caption := 'Atualizar';
  FRefreshButton.OnClick := @RefreshButtonClick;

  FDetailsButton := TButton.Create(FHeader);
  FDetailsButton.Parent := FHeader;
  FDetailsButton.Align := alRight;
  FDetailsButton.Width := 78;
  FDetailsButton.Caption := 'Detalhes';
  FDetailsButton.OnClick := @DetailsButtonClick;

  FDetails := TMemo.Create(Self);
  FDetails.Parent := Self;
  FDetails.Align := alRight;
  FDetails.Width := 270;
  FDetails.BorderStyle := bsNone;
  FDetails.Color := MapColor(23, 28, 40);
  FDetails.Font.Name := 'Consolas';
  FDetails.Font.Color := MapColor(212, 220, 236);
  FDetails.ParentFont := False;
  FDetails.ReadOnly := True;
  FDetails.ScrollBars := ssAutoVertical;

  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Align := alRight;
  FSplitter.Width := 5;
  FSplitter.Color := MapColor(45, 54, 72);

  FScrollBox := TScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align := alClient;
  FScrollBox.BorderStyle := bsNone;
  FScrollBox.Color := MapColor(18, 22, 32);
  FScrollBox.ParentBackground := False;
  FScrollBox.VertScrollBar.Tracking := True;

  FMapCanvas := TPaintBox.Create(FScrollBox);
  FMapCanvas.Parent := FScrollBox;
  FMapCanvas.Left := 0;
  FMapCanvas.Top := 0;
  FMapCanvas.Width := 420;
  FMapCanvas.Height := 300;
  FMapCanvas.OnPaint := @PaintMap;
  FMapCanvas.OnMouseDown := @MapMouseDown;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 350;
  FTimer.OnTimer := @RefreshTimer;
  FTimer.Enabled := True;

  ShowDetails;
  PanelResize(Self);
end;

procedure TMNoteMemoryMapPanel.SetMemoryMap(AMemoryMap: TAIAgentMemoryMap);
begin
  FMemoryMap := AMemoryMap;
  FSelectedIndex := -1;
  FLastSignature := '';
  RefreshMap;
end;

function TMNoteMemoryMapPanel.MapSignature: string;
var
  LastItem: TAIAgentMemoryMapItem;
begin
  if FMemoryMap = nil then Exit('nil');
  Result := FMemoryMap.SessionId + '|' + IntToStr(FMemoryMap.Items.Count) +
    '|' + IntToStr(FMemoryMap.CurrentOrder);
  if FMemoryMap.Items.Count > 0 then
  begin
    LastItem := FMemoryMap.Items[FMemoryMap.Items.Count - 1];
    Result := Result + '|' + IntToStr(Ord(LastItem.Status)) + '|' +
      LastItem.Analise + '|' + LastItem.Erro;
  end;
end;

procedure TMNoteMemoryMapPanel.RefreshTimer(Sender: TObject);
var
  Signature: string;
begin
  try
    Signature := MapSignature;
    if Signature <> FLastSignature then RefreshMap;
  except
    { A memória pode trocar de sessão enquanto o worker conclui uma etapa. }
  end;
end;

procedure TMNoteMemoryMapPanel.RefreshButtonClick(Sender: TObject);
begin
  RefreshMap;
end;

procedure TMNoteMemoryMapPanel.DetailsButtonClick(Sender: TObject);
begin
  UpdateDetailsVisibility(not FDetails.Visible);
  RefreshMap;
end;

procedure TMNoteMemoryMapPanel.UpdateDetailsVisibility(AVisible: Boolean);
begin
  FDetails.Visible := AVisible;
  FSplitter.Visible := AVisible;
  if AVisible then FDetailsButton.Caption := 'Ocultar'
  else FDetailsButton.Caption := 'Detalhes';
end;

procedure TMNoteMemoryMapPanel.PanelResize(Sender: TObject);
begin
  if (FDetails = nil) or (FDetailsButton = nil) then Exit;
  FSummary.Width := ClientWidth - FSummary.Left - 180;
  if FSummary.Width < 80 then FSummary.Width := 80;
  UpdateDetailsVisibility(ClientWidth >= 620);
  if (FMapCanvas = nil) or (FScrollBox = nil) then Exit;
  BuildNodes;
  if FMapCanvas <> nil then FMapCanvas.Invalidate;
end;

function TMNoteMemoryMapPanel.NodeDepth(
  AItem: TAIAgentMemoryMapItem): Integer;
var
  ParentItem: TAIAgentMemoryMapItem;
begin
  Result := 0;
  if (FMemoryMap = nil) or (AItem = nil) then Exit;
  ParentItem := FMemoryMap.Items.FindByOrder(AItem.OrdemPai);
  while (ParentItem <> nil) and (Result < 4) do
  begin
    Inc(Result);
    ParentItem := FMemoryMap.Items.FindByOrder(ParentItem.OrdemPai);
  end;
end;

procedure TMNoteMemoryMapPanel.BuildNodes;
const
  NodeHeight = 78;
  NodeGap = 24;
var
  I, Depth, CanvasWidth, NodeWidth: Integer;
begin
  if FMemoryMap = nil then
    SetLength(FNodes, 0)
  else
    SetLength(FNodes, FMemoryMap.Items.Count);

  CanvasWidth := FScrollBox.ClientWidth;
  if CanvasWidth < 360 then CanvasWidth := 360;
  FMapCanvas.Width := CanvasWidth;
  FMapCanvas.Height := 70 + Length(FNodes) * (NodeHeight + NodeGap);
  if FMapCanvas.Height < FScrollBox.ClientHeight then
    FMapCanvas.Height := FScrollBox.ClientHeight;

  for I := 0 to High(FNodes) do
  begin
    FNodes[I].ItemIndex := I;
    Depth := NodeDepth(FMemoryMap.Items[I]);
    NodeWidth := CanvasWidth - 70 - (Depth * 28);
    if NodeWidth < 210 then NodeWidth := 210;
    FNodes[I].Bounds := Rect(38 + Depth * 28,
      42 + I * (NodeHeight + NodeGap),
      38 + Depth * 28 + NodeWidth,
      42 + I * (NodeHeight + NodeGap) + NodeHeight);
  end;
end;

function TMNoteMemoryMapPanel.StatusText(
  AStatus: TAIAgentMemoryStepStatus): string;
begin
  case AStatus of
    semIniciada: Result := 'INICIADA';
    semEmAnalise: Result := 'EM ANÁLISE';
    semAguardandoInformacao: Result := 'AGUARDANDO';
    semConcluida: Result := 'CONCLUÍDA';
    semExecutada: Result := 'EXECUTADA';
    semFalhou: Result := 'FALHOU';
    semCancelada: Result := 'CANCELADA';
    else Result := 'DESCONHECIDA';
  end;
end;

function TMNoteMemoryMapPanel.StatusColor(
  AStatus: TAIAgentMemoryStepStatus): TColor;
begin
  case AStatus of
    semConcluida, semExecutada: Result := MapColor(55, 190, 125);
    semFalhou: Result := MapColor(232, 88, 95);
    semCancelada: Result := MapColor(145, 150, 165);
    semAguardandoInformacao: Result := MapColor(235, 178, 75);
    else Result := MapColor(78, 134, 255);
  end;
end;

function TMNoteMemoryMapPanel.ShortText(const AText: string;
  AMaxLength: Integer): string;
begin
  Result := StringReplace(Trim(AText), LineEnding, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  if Length(Result) > AMaxLength then
    Result := Copy(Result, 1, AMaxLength - 3) + '...';
end;

procedure TMNoteMemoryMapPanel.PaintMap(Sender: TObject);
var
  I, ParentIndex: Integer;
  NodeRect, ParentRect: TRect;
  Item: TAIAgentMemoryMapItem;
  Accent: TColor;
begin
  FMapCanvas.Canvas.Brush.Color := MapColor(18, 22, 32);
  FMapCanvas.Canvas.FillRect(FMapCanvas.ClientRect);

  if Length(FNodes) = 0 then
  begin
    FMapCanvas.Canvas.Brush.Style := bsClear;
    FMapCanvas.Canvas.Font.Color := MapColor(137, 151, 179);
    FMapCanvas.Canvas.Font.Height := -15;
    FMapCanvas.Canvas.TextOut(36, 48,
      'O fluxo da conversa aparecerá aqui após a primeira pergunta.');
    Exit;
  end;

  for I := 0 to High(FNodes) do
  begin
    if (FMemoryMap = nil) or (I >= FMemoryMap.Items.Count) then Break;
    Item := FMemoryMap.Items[I];
    NodeRect := FNodes[I].Bounds;
    ParentIndex := -1;
    if Item.OrdemPai > 0 then
      for ParentIndex := 0 to I - 1 do
        if (ParentIndex < FMemoryMap.Items.Count) and
          (FMemoryMap.Items[ParentIndex].Ordem = Item.OrdemPai) then Break;
    if (ParentIndex < 0) or (ParentIndex >= I) or
      (ParentIndex >= FMemoryMap.Items.Count) or
      (FMemoryMap.Items[ParentIndex].Ordem <> Item.OrdemPai) then
      ParentIndex := I - 1;
    if ParentIndex >= 0 then
    begin
      ParentRect := FNodes[ParentIndex].Bounds;
      FMapCanvas.Canvas.Pen.Color := MapColor(70, 85, 112);
      FMapCanvas.Canvas.Pen.Width := 2;
      FMapCanvas.Canvas.Line(ParentRect.Left + 18, ParentRect.Bottom,
        NodeRect.Left + 18, NodeRect.Top);
    end;

    Accent := StatusColor(Item.Status);
    FMapCanvas.Canvas.Brush.Color := MapColor(28, 34, 48);
    if I = FSelectedIndex then
      FMapCanvas.Canvas.Pen.Color := MapColor(125, 164, 255)
    else
      FMapCanvas.Canvas.Pen.Color := MapColor(50, 61, 82);
    FMapCanvas.Canvas.Pen.Width := 1;
    FMapCanvas.Canvas.RoundRect(NodeRect.Left, NodeRect.Top, NodeRect.Right,
      NodeRect.Bottom, 12, 12);

    FMapCanvas.Canvas.Pen.Style := psClear;
    FMapCanvas.Canvas.Brush.Color := Accent;
    FMapCanvas.Canvas.RoundRect(NodeRect.Left, NodeRect.Top,
      NodeRect.Left + 6, NodeRect.Bottom, 6, 6);
    FMapCanvas.Canvas.Pen.Style := psSolid;

    FMapCanvas.Canvas.Brush.Style := bsClear;
    FMapCanvas.Canvas.Font.Name := 'Segoe UI';
    FMapCanvas.Canvas.Font.Style := [fsBold];
    FMapCanvas.Canvas.Font.Color := clWhite;
    FMapCanvas.Canvas.Font.Height := -15;
    FMapCanvas.Canvas.TextOut(NodeRect.Left + 18, NodeRect.Top + 11,
      Format('%d. %s', [Item.Ordem, Item.NomeAgente]));
    FMapCanvas.Canvas.Font.Style := [];
    FMapCanvas.Canvas.Font.Height := -12;
    FMapCanvas.Canvas.Font.Color := Accent;
    FMapCanvas.Canvas.TextOut(NodeRect.Right - 92, NodeRect.Top + 13,
      StatusText(Item.Status));
    FMapCanvas.Canvas.Font.Color := MapColor(164, 177, 202);
    FMapCanvas.Canvas.Font.Height := -13;
    FMapCanvas.Canvas.TextOut(NodeRect.Left + 18, NodeRect.Top + 40,
      ShortText(Item.PedidoRecebido, 72));
  end;
end;

procedure TMNoteMemoryMapPanel.MapMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if Button <> mbLeft then Exit;
  for I := 0 to High(FNodes) do
    if (X >= FNodes[I].Bounds.Left) and (X < FNodes[I].Bounds.Right) and
      (Y >= FNodes[I].Bounds.Top) and (Y < FNodes[I].Bounds.Bottom) then
    begin
      FSelectedIndex := I;
      ShowDetails;
      FMapCanvas.Invalidate;
      Exit;
    end;
end;

procedure TMNoteMemoryMapPanel.ShowDetails;
var
  Item: TAIAgentMemoryMapItem;
begin
  FDetails.Clear;
  FDetails.Lines.Add('DETALHES DA MEMÓRIA');
  FDetails.Lines.Add('');
  if FMemoryMap = nil then
  begin
    FDetails.Lines.Add('Memória não conectada.');
    Exit;
  end;

  FDetails.Lines.Add('Fluxo: ' + FMemoryMap.FlowName);
  FDetails.Lines.Add('Sessão: ' + FMemoryMap.SessionId);
  FDetails.Lines.Add('Etapas: ' + IntToStr(FMemoryMap.Items.Count));
  FDetails.Lines.Add('');
  FDetails.Lines.Add('Solicitação original:');
  FDetails.Lines.Add(FMemoryMap.SolicitacaoOriginal);

  if (FSelectedIndex < 0) or (FSelectedIndex >= FMemoryMap.Items.Count) then
    Exit;

  Item := FMemoryMap.Items[FSelectedIndex];
  FDetails.Lines.Add('');
  FDetails.Lines.Add('------------------------------');
  FDetails.Lines.Add(Format('Etapa %d | Pai %d',
    [Item.Ordem, Item.OrdemPai]));
  FDetails.Lines.Add('Agente: ' + Item.NomeAgente);
  FDetails.Lines.Add('Estado: ' + StatusText(Item.Status));
  FDetails.Lines.Add('');
  FDetails.Lines.Add('Pedido:');
  FDetails.Lines.Add(Item.PedidoRecebido);
  if Item.Analise <> '' then
  begin
    FDetails.Lines.Add('');
    FDetails.Lines.Add('Análise:');
    FDetails.Lines.Add(Item.Analise);
  end;
  if Item.Explicacao <> '' then
  begin
    FDetails.Lines.Add('');
    FDetails.Lines.Add('Explicação:');
    FDetails.Lines.Add(Item.Explicacao);
  end;
  if Item.AcaoTomada <> '' then
    FDetails.Lines.Add('Ação: ' + Item.AcaoTomada);
  if Item.ResumoParaProximoAgente <> '' then
  begin
    FDetails.Lines.Add('');
    FDetails.Lines.Add('Resumo para o próximo agente:');
    FDetails.Lines.Add(Item.ResumoParaProximoAgente);
  end;
  if Item.Erro <> '' then
  begin
    FDetails.Lines.Add('');
    FDetails.Lines.Add('Erro: ' + Item.Erro);
  end;
  if Item.Alertas.Count > 0 then
  begin
    FDetails.Lines.Add('');
    FDetails.Lines.Add('Alertas:');
    FDetails.Lines.AddStrings(Item.Alertas);
  end;
end;

procedure TMNoteMemoryMapPanel.RefreshMap;
begin
  FLastSignature := MapSignature;
  BuildNodes;
  if (FSelectedIndex >= Length(FNodes)) then FSelectedIndex := -1;
  if (FSelectedIndex < 0) and (Length(FNodes) > 0) then
    FSelectedIndex := High(FNodes);

  if FMemoryMap = nil then
    FSummary.Caption := 'Memória não conectada'
  else
    FSummary.Caption := Format('%s  |  %d etapa(s)',
      [FMemoryMap.FlowName, FMemoryMap.Items.Count]);
  ShowDetails;
  FMapCanvas.Invalidate;
end;

end.
