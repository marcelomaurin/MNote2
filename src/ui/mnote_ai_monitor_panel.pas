unit mnote_ai_monitor_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs, fpjson,
  mnote_ai_service, mnote_ai_session, mnote_ai_types;

type
  { TMNoteAIMonitorPanel }

  TMNoteAIMonitorPanel = class(TComponent)
  private
    FService: TMNoteAIService;
    FTree: TTreeView;
    FCalls: TListView;
    FDetail: TMemo;
    FSummary: TLabel;
    FSaveButton: TButton;
    FClearButton: TButton;
    FStopButton: TButton;
    FSaveDialog: TSaveDialog;
    FContentPanel: TPanel;
    FLeftPanel: TPanel;
    FRightPanel: TPanel;
    FMainSplitter: TSplitter;
    procedure AdjustPanelWidths;
    procedure ContentResize(Sender: TObject);
    procedure MainSplitterMoved(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure CallsSelected(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure SaveClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
  public
    procedure Initialize(AParent: TWinControl; AService: TMNoteAIService);
    procedure Refresh;
  end;

implementation

procedure TMNoteAIMonitorPanel.Initialize(AParent: TWinControl;
  AService: TMNoteAIService);
var
  Toolbar, CallsPanel, DetailPanel: TPanel;
  DetailSplitter: TSplitter;
begin
  FService := AService;
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;

  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent;
  Toolbar.Align := alTop;
  Toolbar.BevelOuter := bvNone;
  Toolbar.Height := 34;
  FSaveButton := TButton.Create(Self);
  FSaveButton.Parent := Toolbar;
  FSaveButton.Caption := 'Salvar sessão';
  FSaveButton.SetBounds(8, 5, 96, 24);
  FSaveButton.OnClick := @SaveClick;
  FClearButton := TButton.Create(Self);
  FClearButton.Parent := Toolbar;
  FClearButton.Caption := 'Limpar';
  FClearButton.SetBounds(108, 5, 70, 24);
  FClearButton.OnClick := @ClearClick;
  FStopButton := TButton.Create(Self);
  FStopButton.Parent := Toolbar;
  FStopButton.Caption := 'Parar tudo';
  FStopButton.SetBounds(182, 5, 82, 24);
  FStopButton.OnClick := @StopClick;
  FSummary := TLabel.Create(Self);
  FSummary.Parent := Toolbar;
  FSummary.SetBounds(275, 9, 500, 18);

  FContentPanel := TPanel.Create(Self);
  FContentPanel.Parent := AParent;
  FContentPanel.Align := alClient;
  FContentPanel.BevelOuter := bvNone;
  FContentPanel.OnResize := @ContentResize;

  FLeftPanel := TPanel.Create(Self);
  FLeftPanel.Parent := FContentPanel;
  FLeftPanel.Align := alLeft;
  FLeftPanel.Width := 180;
  FLeftPanel.BevelOuter := bvNone;
  FTree := TTreeView.Create(Self);
  FTree.Parent := FLeftPanel;
  FTree.Align := alClient;
  FTree.OnSelectionChanged := @SelectionChanged;

  FMainSplitter := TSplitter.Create(Self);
  FMainSplitter.Parent := FContentPanel;
  FMainSplitter.Align := alLeft;
  FMainSplitter.Width := 6;
  FMainSplitter.MinSize := 90;
  FMainSplitter.OnMoved := @MainSplitterMoved;

  FRightPanel := TPanel.Create(Self);
  FRightPanel.Parent := FContentPanel;
  FRightPanel.Align := alClient;
  FRightPanel.BevelOuter := bvNone;

  CallsPanel := TPanel.Create(Self);
  CallsPanel.Parent := FRightPanel;
  CallsPanel.Align := alTop;
  CallsPanel.Height := 190;
  CallsPanel.BevelOuter := bvNone;

  FCalls := TListView.Create(Self);
  FCalls.Parent := CallsPanel;
  FCalls.Align := alClient;
  FCalls.ViewStyle := vsReport;
  FCalls.ReadOnly := True;
  FCalls.RowSelect := True;
  FCalls.OnSelectItem := @CallsSelected;

  DetailSplitter := TSplitter.Create(Self);
  DetailSplitter.Parent := FRightPanel;
  DetailSplitter.Align := alTop;
  DetailSplitter.Height := 6;
  DetailSplitter.MinSize := 80;

  DetailPanel := TPanel.Create(Self);
  DetailPanel.Parent := FRightPanel;
  DetailPanel.Align := alClient;
  DetailPanel.BevelOuter := bvNone;
  FDetail := TMemo.Create(Self);
  FDetail.Parent := DetailPanel;
  FDetail.Align := alClient;
  FDetail.ReadOnly := True;
  FDetail.ScrollBars := ssAutoBoth;
  FDetail.WordWrap := False;
  with FCalls.Columns.Add do begin Caption := '#'; Width := 35; end;
  with FCalls.Columns.Add do begin Caption := 'Papel'; Width := 95; end;
  with FCalls.Columns.Add do begin Caption := 'Status'; Width := 75; end;
  with FCalls.Columns.Add do begin Caption := 'In/Out estimado'; Width := 105; end;
  with FCalls.Columns.Add do begin Caption := 'Latência'; Width := 75; end;
  with FCalls.Columns.Add do begin Caption := 'Tentativa'; Width := 65; end;

  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Filter := 'Sessão de IA (*.json)|*.json';
  FSaveDialog.DefaultExt := 'json';
  AdjustPanelWidths;
  Refresh;
end;

procedure TMNoteAIMonitorPanel.AdjustPanelWidths;
var
  AvailableWidth, MaximumLeftWidth: Integer;
begin
  if (FContentPanel = nil) or (FLeftPanel = nil) or
    (FMainSplitter = nil) then Exit;
  AvailableWidth := FContentPanel.ClientWidth - FMainSplitter.Width;
  if AvailableWidth <= 0 then Exit;
  MaximumLeftWidth := AvailableWidth div 3;
  if MaximumLeftWidth < 90 then MaximumLeftWidth := 90;
  if FLeftPanel.Width > MaximumLeftWidth then
    FLeftPanel.Width := MaximumLeftWidth;
end;

procedure TMNoteAIMonitorPanel.ContentResize(Sender: TObject);
begin
  AdjustPanelWidths;
end;

procedure TMNoteAIMonitorPanel.MainSplitterMoved(Sender: TObject);
begin
  AdjustPanelWidths;
end;

procedure TMNoteAIMonitorPanel.CallsSelected(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then SelectionChanged(FCalls);
end;

procedure TMNoteAIMonitorPanel.Refresh;
var
  Session: TMNoteAISession;
  Nodes: array of TTreeNode;
  RootNode, Node: TTreeNode;
  Item: TListItem;
  Step: TMNoteAISessionStep;
  I, TotalIn, TotalOut: Integer;
begin
  if (FService = nil) or (FTree = nil) then Exit;
  Session := FService.Session;
  FTree.Items.BeginUpdate;
  FCalls.Items.BeginUpdate;
  try
    FTree.Items.Clear;
    FCalls.Items.Clear;
    TotalIn := 0;
    TotalOut := 0;
    RootNode := FTree.Items.Add(nil, 'Sessão ' + Session.SessionID);
    SetLength(Nodes, Session.Count + 1);
    Nodes[0] := RootNode;
    for I := 0 to Session.Count - 1 do
    begin
      Step := Session[I];
      if (Step.ParentOrder >= 0) and
        (Step.ParentOrder < Length(Nodes)) and
        (Nodes[Step.ParentOrder] <> nil) then
        Node := FTree.Items.AddChild(Nodes[Step.ParentOrder],
          Format('%d. %s — %s', [Step.Order, MNoteAIRoleName(Step.Role),
          Step.Status]))
      else
        Node := FTree.Items.AddChild(RootNode,
          Format('%d. %s — %s', [Step.Order, MNoteAIRoleName(Step.Role),
          Step.Status]));
      Node.Data := Step;
      if Step.Order < Length(Nodes) then Nodes[Step.Order] := Node;
      Item := FCalls.Items.Add;
      Item.Caption := IntToStr(Step.Order);
      Item.SubItems.Add(MNoteAIRoleName(Step.Role));
      Item.SubItems.Add(Step.Status);
      Item.SubItems.Add(Format('%d / %d', [Step.EstimatedInput,
        Step.EstimatedOutput]));
      Item.SubItems.Add(IntToStr(Step.LatencyMS) + ' ms');
      Item.SubItems.Add(IntToStr(Step.Attempt));
      Item.Data := Step;
      Inc(TotalIn, Step.EstimatedInput);
      Inc(TotalOut, Step.EstimatedOutput);
    end;
    RootNode.Expand(True);
    FSummary.Caption := Format('%d passos | entrada estimada %d | saída reservada %d',
      [Session.Count, TotalIn, TotalOut]);
  finally
    FCalls.Items.EndUpdate;
    FTree.Items.EndUpdate;
  end;
end;

procedure TMNoteAIMonitorPanel.SelectionChanged(Sender: TObject);
var
  Step: TMNoteAISessionStep;
  Data: TJSONObject;
begin
  Step := nil;
  if (Sender = FTree) and (FTree.Selected <> nil) then
    Step := TMNoteAISessionStep(FTree.Selected.Data)
  else if (Sender = FCalls) and (FCalls.Selected <> nil) then
    Step := TMNoteAISessionStep(FCalls.Selected.Data);
  if Step = nil then Exit;
  Data := Step.ToJSON;
  try
    FDetail.Text := Data.FormatJSON;
  finally
    Data.Free;
  end;
end;

procedure TMNoteAIMonitorPanel.SaveClick(Sender: TObject);
begin
  if (FService = nil) or (not FSaveDialog.Execute) then Exit;
  FService.Session.SaveToFile(FSaveDialog.FileName);
end;

procedure TMNoteAIMonitorPanel.ClearClick(Sender: TObject);
begin
  if FService <> nil then FService.ClearSession;
end;

procedure TMNoteAIMonitorPanel.StopClick(Sender: TObject);
begin
  if FService <> nil then FService.Cancel;
end;

end.
