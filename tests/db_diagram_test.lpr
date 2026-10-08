program db_diagram_test;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, SysUtils, Controls, Graphics, ExtCtrls, ComCtrls, Menus,
  ZConnection, ZDataset, mnote_db_diagram_model, mnote_db_diagram_reader,
  mnote_db_diagram_form, mnote_db_diagram_layout, mnote_db_diagram_job, mnote_solution_explorer_panel, mnote_project_context;
type TContextObserver = class
  LastContext, LastTable: string;
  CancelAfterProgress: Boolean;
  procedure Progress(const Stage: string; Position, Total: Integer; var Cancelled: Boolean);
  procedure OpenDiagram(Sender: TObject; const AContext, ATable: string);
end;
procedure TContextObserver.OpenDiagram(Sender: TObject; const AContext, ATable: string);
begin LastContext := AContext; LastTable := ATable; end;
procedure TContextObserver.Progress(const Stage: string; Position, Total: Integer; var Cancelled: Boolean);
begin Cancelled := CancelAfterProgress and (Total > 0) and (Position >= 1); end;
var Checks: Integer;
procedure Check(Value: Boolean; const Msg: string);
begin
  if not Value then raise Exception.Create('FAIL: ' + Msg);
  Inc(Checks);
end;
procedure WaitJob(const Job: IDiagramJob);
var Deadline: QWord;
begin
  Deadline := GetTickCount64 + 15000;
  while not Job.Status.Done do begin
    if GetTickCount64 > Deadline then raise Exception.Create('Async job timeout');
    Application.ProcessMessages; Sleep(5);
  end;
end;
procedure WaitDiagram(Diagram: TDatabaseDiagramForm);
var Deadline: QWord;
begin
  Deadline := GetTickCount64 + 15000;
  while Diagram.Loading do begin
    if GetTickCount64 > Deadline then raise Exception.Create('Diagram timeout');
    Application.ProcessMessages; Sleep(5);
  end;
end;
procedure Run;
var C: TZConnection; Q: TZQuery; M: TDiagramModel; Context, Other: TDiagramContext;
  T: TDiagramTable; R: TDiagramRelation; P: TDiagramPair;
  I: Integer; Rejected: Boolean; Diagram: TDatabaseDiagramForm;
  Host: TForm; Panel: TMNoteSolutionExplorerPanel; Tables: TStringList;
  Observer: TContextObserver; Tree: TTreeView; Node: TTreeNode; J: Integer;
  FixturePath: string; Job: IDiagramJob; AsyncModel: TDiagramModel; Started: QWord;
  LayoutPath: string; Zoom: Double; LayoutText: TStringList;
begin
  C := TZConnection.Create(nil); Q := TZQuery.Create(nil); M := nil;
  try
    FixturePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'diagram-' + IntToStr(GetTickCount64) + '.db';
    C.Name := 'TestSQLite'; C.Protocol := 'sqlite'; C.Database := FixturePath;
    C.LibraryLocation := ParamStr(1); C.Connect; Q.Connection := C;
    Q.SQL.Text := 'CREATE TABLE parent (a INTEGER, b INTEGER, PRIMARY KEY(a,b))'; Q.ExecSQL;
    Q.SQL.Text := 'CREATE TABLE child (id INTEGER PRIMARY KEY, a INTEGER, b INTEGER, '+
      'manager INTEGER, FOREIGN KEY(a,b) REFERENCES parent, '+
      'FOREIGN KEY(manager) REFERENCES child(id), FOREIGN KEY(b,a) REFERENCES parent(b,a))'; Q.ExecSQL;
    Q.SQL.Text := 'CREATE TABLE standalone (name TEXT)'; Q.ExecSQL;
    Q.SQL.Text := 'SELECT 42 AS preserved'; Q.Open;
    Context := DiagramConnectionContext(C, ''); Other := Context; Other.Host := 'another-server';
    Check(DiagramContextKey(Context) <> DiagramContextKey(Other), 'server isolation');
    Other := Context; Other.SchemaName := 'another-schema';
    Check(DiagramContextKey(Context) <> DiagramContextKey(Other), 'schema isolation');
    Check(DiagramObjectKey('a', 'bc', 'd') <> DiagramObjectKey('ab', 'c', 'd'), 'unambiguous object key');
    Check(DiagramObjectKey('', 'one', 'table') <> DiagramObjectKey('', 'two', 'table'), 'qualified names');
    M := ReadDatabaseDiagram(C, Context);
    Check(M.Tables.Count = 3, 'table count');
    Check(M.Relations.Count = 3, 'separate constraints');
    Check(Q.Active and (Q.Fields[0].AsInteger = 42), 'user query preserved');
    T := M.FindTable(DiagramObjectKey('', 'main', 'child'));
    Check((T <> nil) and (T.Columns.Count = 4), 'child columns');
    Check(TDiagramColumn(T.Columns[T.ColumnIndex('id')]).PrimaryPosition = 1, 'primary key');
    Check(TDiagramColumn(T.Columns[T.ColumnIndex('manager')]).ForeignKey, 'foreign key marker');
    for I := 0 to M.Relations.Count - 1 do begin
      R := TDiagramRelation(M.Relations[I]);
      if R.TargetKey = T.Key then Check(R.Pairs.Count = 1, 'self reference')
      else begin
        Check(R.Pairs.Count = 2, 'composite key grouped');
        P := TDiagramPair(R.Pairs[0]); Check(P.Position = 1, 'ordered pair');
        Check(P.TargetColumn <> '', 'implicit PK reference resolved');
        Check(TDiagramPair(R.Pairs[1]).Position = 2, 'second pair');
      end;
    end;
    Other := Context; Other.Host := 'another-server';
    Rejected := False;
    try ReadDatabaseDiagram(C, Other).Free; except on E: Exception do Rejected := True; end;
    Check(Rejected, 'changed connection rejected');
    Observer := TContextObserver.Create;
    try
      Observer.CancelAfterProgress := True; Rejected := False;
      try ReadDatabaseDiagram(C, Context, @Observer.Progress).Free;
      except on E: EDiagramCancelled do Rejected := True; end;
      Check(Rejected, 'reader cancellation after first table');
    finally Observer.Free; end;
    LayoutPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'test-layout.json';
    M.FocusTable('main.child');
    Check(M.MatchesView(T), 'focused table visible');
    Check(M.MatchesView(M.FindTable(DiagramObjectKey('', 'main', 'parent'))), 'related table visible');
    Check(not M.MatchesView(M.FindTable(DiagramObjectKey('', 'main', 'standalone'))), 'unrelated table hidden');
    M.FilterText := 'child';
    T.X := 123; T.Y := 456; Zoom := 1.3;
    SaveDiagramLayout(M, Zoom, LayoutPath); T.X := 20; T.Y := 30; Zoom := 1;
    M.FilterText := ''; M.FocusKey := '';
    LoadDiagramLayout(M, Zoom, LayoutPath);
    Check((T.X = 123) and (T.Y = 456) and (Abs(Zoom - 1.3) < 0.01), 'layout round trip');
    Check((M.FilterText = 'child') and (M.FocusKey = T.Key), 'view state restored');
    M.Context := Other; Rejected := False;
    try LoadDiagramLayout(M, Zoom, LayoutPath); except on E: Exception do Rejected := True; end;
    Check(Rejected, 'cross database layout rejected'); M.Context := Context;
    LayoutText := TStringList.Create;
    try
      LayoutText.LoadFromFile(LayoutPath);
      Check(Pos('password', LowerCase(LayoutText.Text)) = 0, 'no password in layout');
      LayoutText.Text := StringReplace(LayoutText.Text, '456', '-1', [rfReplaceAll]);
      LayoutText.SaveToFile(LayoutPath); T.X := 20; T.Y := 30;
      Rejected := False;
      try LoadDiagramLayout(M, Zoom, LayoutPath); except on E: Exception do Rejected := True; end;
      Check(Rejected and (T.X = 20) and (T.Y = 30), 'invalid layout leaves positions unchanged');
    finally LayoutText.Free; end;
    Job := StartDiagramJob(C, Context); C.Disconnect; WaitJob(Job);
    Check((Job.Status.ErrorText = '') and Job.Status.Done, 'worker independent of original connection lifetime');
    AsyncModel := Job.TakeModel; AsyncModel.Free; Job := nil;
    C.Connect; Q.SQL.Text := 'SELECT 42 AS preserved'; Q.Open;
    Started := GetTickCount64;
    Job := StartDiagramJob(C, Context);
    Check(GetTickCount64 - Started < 1000, 'start does not perform database IO on UI thread');
    WaitJob(Job); Check(Job.Status.ErrorText = '', 'async reader succeeds: ' + Job.Status.ErrorText);
    AsyncModel := Job.TakeModel;
    try Check((AsyncModel <> nil) and (AsyncModel.Tables.Count = 3), 'async model returned');
    finally AsyncModel.Free; end;
    Check(Q.Active and (Q.Fields[0].AsInteger = 42), 'async preserves source query');
    Job := StartDiagramJob(C, Context); Job.Cancel; WaitJob(Job);
    Check(Job.Status.Cancelled and (Job.TakeModel = nil), 'cancel discards result'); Job := nil;
    Diagram := TDatabaseDiagramForm.CreateFor(nil, C, Context, 'child');
    try
      WaitDiagram(Diagram);
      Check(Pos(ExtractFileName(FixturePath), Diagram.Caption) > 0, 'visible database context');
      Diagram.ExportImage(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'diagram-preview.png');
      Diagram.RefreshDatabase; Diagram.CancelLoading; WaitDiagram(Diagram);
      Check(Pos('cancelada', Diagram.StatusText) > 0, 'UI cancel state');
      Diagram.ExportImage(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'diagram-cancelled.png');
    finally Diagram.Free; end;
    Host := TForm.CreateNew(nil); Panel := TMNoteSolutionExplorerPanel.Create(nil);
    Tables := TStringList.Create; Observer := TContextObserver.Create;
    try
      Panel.Initialize(Host); Panel.SetProject(GetCurrentDir, 'Diagram test', '', mpkNone);
      Tables.Add('parent'); Tables.Add('child');
      Panel.AddDatabaseContext('Oracle / server-a / sales', 'context-a', Tables);
      Panel.AddDatabaseContext('SQL Server / server-b / sales', 'context-b', Tables);
      Panel.Refresh;
      Panel.OnOpenDatabaseDiagram := @Observer.OpenDiagram;
      Tree := nil;
      for I := 0 to Host.ControlCount - 1 do
        if Host.Controls[I] is TTreeView then Tree := TTreeView(Host.Controls[I]);
      Check(Tree <> nil, 'tree available');
      Node := Tree.Items.GetFirstNode;
      while Node <> nil do begin
        if (Node.Data <> nil) and (TMNoteSolutionNodeData(Node.Data).DatabaseContextId <> '') then begin
          Tree.Selected := Node;
          for J := 0 to Tree.PopupMenu.Items.Count - 1 do
            if Pos('diagrama', Tree.PopupMenu.Items[J].Caption) > 0 then Tree.PopupMenu.Items[J].Click;
          Check(Observer.LastContext = TMNoteSolutionNodeData(Node.Data).DatabaseContextId,
            'context action matches selected folder or table');
          Check(Observer.LastTable = TMNoteSolutionNodeData(Node.Data).DatabaseTable, 'selected table forwarded');
        end;
        Node := Node.GetNext;
      end;
      Check(Panel.ContainsNode('Oracle / server-a / sales'), 'first database folder');
      Check(Panel.ContainsNode('SQL Server / server-b / sales'), 'second database folder');
      Panel.ClearDatabase;
      Check(not Panel.ContainsNode('Oracle / server-a / sales'), 'clear contexts');
    finally Observer.Free; Tables.Free; Panel.Free; Host.Free; end;
    Q.Close;
    Q.SQL.Text := 'ALTER TABLE standalone RENAME TO renamed_table'; Q.ExecSQL;
    Job := StartDiagramJob(C, Context); WaitJob(Job); AsyncModel := Job.TakeModel;
    try
      Check(AsyncModel <> nil, 'reload after rename');
      AsyncModel.PreserveView(M);
      Check(AsyncModel.FindTable(DiagramObjectKey('', 'main', 'standalone')) = nil, 'removed name absent');
      Check(AsyncModel.FindTable(DiagramObjectKey('', 'main', 'renamed_table')) <> nil, 'new name present');
      Check(AsyncModel.FindTable(T.Key).X = T.X, 'existing positions preserved');
      Check(AsyncModel.FilterText = M.FilterText, 'filter preserved on refresh');
    finally AsyncModel.Free; end;
    for I := 0 to 299 do begin
      Q.SQL.Text := Format('CREATE TABLE bulk_%d (id INTEGER PRIMARY KEY, parent_id INTEGER REFERENCES child(id))', [I]);
      Q.ExecSQL;
    end;
    Started := GetTickCount64;
    Job := StartDiagramJob(C, Context); WaitJob(Job); AsyncModel := Job.TakeModel;
    try
      Check((AsyncModel <> nil) and (AsyncModel.Tables.Count = 303), '303 table load');
      Check(AsyncModel.Relations.Count = 303, '303 relations preserved');
      WriteLn('PERF: 303 tables, 303 relations, ', GetTickCount64 - Started, ' ms');
    finally AsyncModel.Free; end;
    Job := nil;
    Diagram := TDatabaseDiagramForm.CreateFor(nil, C, Context);
    Started := GetTickCount64; Diagram.Free;
    Check(GetTickCount64 - Started < 1000, 'closing loading form does not wait for driver');
    // Let the detached cancelled worker observe its token before test process exits.
    Sleep(100);
    C.Disconnect; Rejected := False;
    try ReadDatabaseDiagram(C, Context).Free; except on E: Exception do Rejected := True; end;
    Check(Rejected, 'disconnected connection rejected');
  finally M.Free; Q.Free; C.Free; if FileExists(FixturePath) then DeleteFile(FixturePath); end;
end;
begin
  Application.Initialize;
  try Run; WriteLn('PASS: ', Checks, ' diagram checks');
  except on E: Exception do begin WriteLn(E.Message); Halt(1); end; end;
end.
