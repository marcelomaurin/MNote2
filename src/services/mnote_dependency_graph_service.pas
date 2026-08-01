unit mnote_dependency_graph_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_service_base, aidependencygraph;

type
  { TMNoteDependencyGraphService }

  TMNoteDependencyGraphService = class(TMNoteServiceBase)
  private
    FGraph: TAIDependencyGraph;
    FRootPath: string;
    procedure ScanDirectory(const APath: string);
    procedure ScanPascalFile(const AFileName: string);
    procedure AddTaskRelations;
  public
    constructor Create;
    destructor Destroy; override;
    function Build(const ARootPath: string): Boolean;
    function AsText: string;
    property Graph: TAIDependencyGraph read FGraph;
  end;

implementation

uses
  StrUtils, fpjson, jsonparser;

function CleanUnitToken(const AValue: string): string;
var
  I: Integer;
begin
  Result := Trim(AValue);
  I := Pos(' in ', LowerCase(Result));
  if I > 0 then Result := Trim(Copy(Result, 1, I - 1));
  while (Result <> '') and (Result[Length(Result)] in [',', ';']) do
    Delete(Result, Length(Result), 1);
end;

constructor TMNoteDependencyGraphService.Create;
begin
  inherited Create;
  FGraph := TAIDependencyGraph.Create(nil);
end;

destructor TMNoteDependencyGraphService.Destroy;
begin
  FGraph.Free;
  inherited Destroy;
end;

procedure TMNoteDependencyGraphService.ScanDirectory(const APath: string);
var
  Search: TSearchRec;
  FullName: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(APath) + '*', faAnyFile,
    Search) <> 0 then Exit;
  try
    repeat
      if (Search.Name = '.') or (Search.Name = '..') then Continue;
      FullName := IncludeTrailingPathDelimiter(APath) + Search.Name;
      if (Search.Attr and faDirectory) <> 0 then
      begin
        if SameText(Search.Name, '.git') or SameText(Search.Name, '.mnote') or
          SameText(Search.Name, 'backup') or SameText(Search.Name, 'lib') or
          SameText(Search.Name, 'bin') then Continue;
        ScanDirectory(FullName);
      end
      else if SameText(ExtractFileExt(Search.Name), '.pas') or
        SameText(ExtractFileExt(Search.Name), '.lpr') then
        ScanPascalFile(FullName);
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
end;

procedure TMNoteDependencyGraphService.ScanPascalFile(const AFileName: string);
var
  Lines, Tokens: TStringList;
  I, J, StartPos: Integer;
  ParsedUnitName, Clause, Token, UnitId, TargetId, RelativeName: string;
  InUses: Boolean;
  Evidence: TAIDependencyEvidence;
begin
  Lines := TStringList.Create;
  Tokens := TStringList.Create;
  try
    Lines.LoadFromFile(AFileName);
    ParsedUnitName := ChangeFileExt(ExtractFileName(AFileName), '');
    for I := 0 to Lines.Count - 1 do
      if AnsiStartsText('unit ', Trim(Lines[I])) or
        AnsiStartsText('program ', Trim(Lines[I])) then
      begin
        ParsedUnitName := CleanUnitToken(Copy(Trim(Lines[I]),
          Pos(' ', Trim(Lines[I])) + 1, MaxInt));
        Break;
      end;
    RelativeName := ExtractRelativePath(IncludeTrailingPathDelimiter(FRootPath),
      AFileName);
    UnitId := MakeAIDependencyNodeId(AIDG_NODE_UNIT, ParsedUnitName);
    Evidence := MakeAIDependencyEvidence(RelativeName, 1, 'pascal-uses');
    FGraph.AddNode(UnitId, AIDG_NODE_UNIT, ParsedUnitName, RelativeName, Evidence);
    FGraph.AddEdge('repository:mnote-project', UnitId, AIDG_EDGE_CONTAINS,
      Evidence);

    InUses := False;
    Clause := '';
    StartPos := 0;
    for I := 0 to Lines.Count - 1 do
    begin
      if not InUses then
      begin
        StartPos := Pos('uses', LowerCase(Trim(Lines[I])));
        if StartPos <> 1 then Continue;
        InUses := True;
        Clause := Copy(Trim(Lines[I]), 5, MaxInt);
      end
      else
        Clause := Clause + ' ' + Trim(Lines[I]);
      if Pos(';', Clause) = 0 then Continue;
      Clause := Copy(Clause, 1, Pos(';', Clause) - 1);
      Tokens.StrictDelimiter := True;
      Tokens.Delimiter := ',';
      Tokens.DelimitedText := Clause;
      for J := 0 to Tokens.Count - 1 do
      begin
        Token := CleanUnitToken(Tokens[J]);
        if Token = '' then Continue;
        TargetId := MakeAIDependencyNodeId(AIDG_NODE_UNIT, Token);
        Evidence := MakeAIDependencyEvidence(RelativeName, I + 1,
          'pascal-uses');
        FGraph.AddNode(TargetId, AIDG_NODE_UNIT, Token, '', Evidence);
        FGraph.AddEdge(UnitId, TargetId, AIDG_EDGE_USES_UNIT, Evidence);
      end;
      InUses := False;
      Clause := '';
    end;
  except
    on E: Exception do
      SetError('Falha ao analisar ' + AFileName + ': ' + E.Message);
  end;
  Tokens.Free;
  Lines.Free;
end;

procedure TMNoteDependencyGraphService.AddTaskRelations;
var
  Search: TSearchRec;
  FileName: string;
  Raw: TStringList;
  Data: TJSONData;
  Tasks, Dependencies, FilesA, FilesB: TJSONArray;
  TaskA, TaskB: TJSONObject;
  I, J, K, L: Integer;
  IdA, IdB, FileA: string;
  Evidence: TAIDependencyEvidence;
begin
  if FindFirst(IncludeTrailingPathDelimiter(FRootPath) + '*.mnoteproj.json',
    faAnyFile, Search) <> 0 then Exit;
  FileName := IncludeTrailingPathDelimiter(FRootPath) + Search.Name;
  FindClose(Search);
  Raw := TStringList.Create;
  Data := nil;
  try
    Raw.LoadFromFile(FileName);
    Data := GetJSON(Raw.Text);
    if not (Data is TJSONObject) then Exit;
    if not (TJSONObject(Data).Find('planning') is TJSONObject) or
      not (TJSONObject(Data).Objects['planning'].Find('tasks') is TJSONArray) then
      Exit;
    Tasks := TJSONObject(Data).Objects['planning'].Arrays['tasks'];
    for I := 0 to Tasks.Count - 1 do
    begin
      TaskA := Tasks.Objects[I];
      IdA := TaskA.Get('id', '');
      Evidence := MakeAIDependencyEvidence(ExtractFileName(FileName), 1,
        'mnote-project-schema');
      FGraph.AddNode('task:' + LowerCase(IdA), 'task', IdA, '', Evidence);
      if TaskA.Find('dependencies') is TJSONArray then
      begin
        Dependencies := TaskA.Arrays['dependencies'];
        for J := 0 to Dependencies.Count - 1 do
        begin
          IdB := Dependencies.Strings[J];
          FGraph.AddNode('task:' + LowerCase(IdB), 'task', IdB, '', Evidence);
          FGraph.AddEdge('task:' + LowerCase(IdA), 'task:' + LowerCase(IdB),
            'depends_on', Evidence);
        end;
      end;
    end;
    for I := 0 to Tasks.Count - 1 do
      for J := I + 1 to Tasks.Count - 1 do
      begin
        TaskA := Tasks.Objects[I]; TaskB := Tasks.Objects[J];
        if not (TaskA.Find('exclusive_files') is TJSONArray) or
          not (TaskB.Find('exclusive_files') is TJSONArray) then Continue;
        FilesA := TaskA.Arrays['exclusive_files'];
        FilesB := TaskB.Arrays['exclusive_files'];
        for K := 0 to FilesA.Count - 1 do
        begin
          FileA := FilesA.Strings[K];
          for L := 0 to FilesB.Count - 1 do
            if SameText(FileA, FilesB.Strings[L]) then
            begin
              FGraph.AddInferredEdge('task:' + LowerCase(TaskA.Get('id', '')),
                'task:' + LowerCase(TaskB.Get('id', '')), 'shared_exclusive_file',
                0.75, FileA);
              Break;
            end;
        end;
      end;
  finally
    Data.Free;
    Raw.Free;
  end;
end;

function TMNoteDependencyGraphService.Build(const ARootPath: string): Boolean;
var
  Evidence: TAIDependencyEvidence;
  Validation: TAIDependencyValidation;
begin
  ClearError;
  FGraph.Clear;
  FRootPath := ExcludeTrailingPathDelimiter(ExpandFileName(ARootPath));
  if not DirectoryExists(FRootPath) then
  begin
    SetError('A raiz do projeto não existe.');
    Exit(False);
  end;
  Evidence := MakeAIDependencyEvidence(FRootPath, 1, 'project-root');
  FGraph.AddNode('repository:mnote-project', AIDG_NODE_REPOSITORY,
    ExtractFileName(FRootPath), FRootPath, Evidence);
  ScanDirectory(FRootPath);
  AddTaskRelations;
  Validation := FGraph.Validate;
  Result := Validation.Passed;
  if not Result then SetError(Format(
    'Grafo inválido: %d arestas quebradas, %d sem evidência, %d ciclos próprios.',
    [Validation.BrokenEdges, Validation.NoEvidence, Validation.SelfEdges]));
end;

function TMNoteDependencyGraphService.AsText: string;
var
  Lines: TStringList;
  I: Integer;
  Edge: TAIDependencyEdge;
begin
  Lines := TStringList.Create;
  try
    Lines.Add(Format('Nós: %d | Arestas factuais: %d | Inferidas: %d',
      [FGraph.NodeCount, FGraph.Edges.Count, FGraph.InferredEdges.Count]));
    Lines.Add('');
    Lines.Add('ARESTAS FACTUAIS');
    for I := 0 to FGraph.Edges.Count - 1 do
    begin
      Edge := FGraph.Edges[I];
      Lines.Add(Format('%s --%s--> %s [%s:%d; %s]',
        [Edge.FromId, Edge.EdgeType, Edge.ToId, Edge.Evidence.SourceFile,
         Edge.Evidence.Line, Edge.Evidence.Parser]));
    end;
    Lines.Add('');
    Lines.Add('ARESTAS INFERIDAS');
    if FGraph.InferredEdges.Count = 0 then Lines.Add('(nenhuma inferência)');
    for I := 0 to FGraph.InferredEdges.Count - 1 do
    begin
      Edge := FGraph.InferredEdges[I];
      Lines.Add(Format('%s --%s--> %s [confiança %.2f; %s]',
        [Edge.FromId, Edge.EdgeType, Edge.ToId, Edge.Confidence, Edge.Source]));
    end;
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

end.
