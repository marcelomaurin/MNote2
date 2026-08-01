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
  Toolbar, LeftPanel, DetailPanel: TPanel;
  SplitterOne, SplitterTwo: TSplitter;
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

  LeftPanel := TPanel.Create(Self);
  LeftPanel.Parent := AParent;
  LeftPanel.Align := alLeft;
  LeftPanel.Width := 220;
  LeftPanel.BevelOuter := bvNone;
  FTree := TTreeView.Create(Self);
  FTree.Parent := LeftPanel;
  FTree.Align := alClient;
  FTree.OnSelectionChanged := @SelectionChanged;
  SplitterOne := TSplitter.Create(Self);
  SplitterOne.Parent := AParent;
  SplitterOne.Align := alLeft;

  DetailPanel := TPanel.Create(Self);
  DetailPanel.Parent := AParent;
  DetailPanel.Align := alRight;
  DetailPanel.Width := 300;
  DetailPanel.BevelOuter := bvNone;
  FDetail := TMemo.Create(Self);
  FDetail.Parent := DetailPanel;
  FDetail.Align := alClient;
  FDetail.ReadOnly := True;
  FDetail.ScrollBars := ssAutoBoth;
  FDetail.WordWrap := False;
  SplitterTwo := TSplitter.Create(Self);
  SplitterTwo.Parent := AParent;
  SplitterTwo.Align := alRight;

  FCalls := TListView.Create(Self);
  FCalls.Parent := AParent;
  FCalls.Align := alClient;
  FCalls.ViewStyle := vsReport;
  FCalls.ReadOnly := True;
  FCalls.RowSelect := True;
  FCalls.OnSelectItem := @CallsSelected;
  with FCalls.Columns.Add do begin Caption := '#'; Width := 35; end;
  with FCalls.Columns.Add do begin Caption := 'Papel'; Width := 95; end;
  with FCalls.Columns.Add do begin Caption := 'Status'; Width := 75; end;
  with FCalls.Columns.Add do begin Caption := 'In/Out estimado'; Width := 105; end;
  with FCalls.Columns.Add do begin Caption := 'Latência'; Width := 75; end;
  with FCalls.Columns.Add do begin Caption := 'Tentativa'; Width := 65; end;

  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Filter := 'Sessão de IA (*.json)|*.json';
  FSaveDialog.DefaultExt := 'json';
  Refresh;
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
