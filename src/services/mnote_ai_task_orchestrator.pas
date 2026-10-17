unit mnote_ai_task_orchestrator;
{$mode objfpc}{$H+}
{$codepage utf8}
interface
uses Classes, SysUtils, Contnrs, fpjson, jsonparser, mnote_ai_service;

type
  TMNoteAITaskState = (atsPending, atsRunning, atsCompleted, atsFailed, atsBlocked);
  TMNoteAITask = class
  public
    ID, Title, Category, Instruction, Evidence, ErrorText: string;
    DependsOn: string;
    State: TMNoteAITaskState;
    constructor Create(const AID, ATitle, ACategory, AInstruction,
      ADependsOn: string);
  end;

  TMNoteAITaskOrchestrator = class
  private
    FTasks: TObjectList;
    FProjectRoot: string;
    FRequest: string;
    FLastError: string;
    function TaskFile: string;
    function GetCount: Integer;
    function GetTask(AIndex: Integer): TMNoteAITask;
    function GetByID(const AID: string): TMNoteAITask;
    function DependenciesReady(ATask: TMNoteAITask): Boolean;
    procedure Add(const AID, ATitle, ACategory, AInstruction,
      ADependsOn: string);
  public
    constructor Create(const ARoot: string);
    destructor Destroy; override;
    procedure Plan(const ARequest: string; AIncludeSQL: Boolean);
    function ExecuteNext: Boolean;
    procedure Save;
    procedure Load;
    function HasPending: Boolean;
    property Count: Integer read GetCount;
    property Tasks[AIndex: Integer]: TMNoteAITask read GetTask;
    property LastError: string read FLastError;
    property Request: string read FRequest;
  end;

function MNoteTaskStateName(AState: TMNoteAITaskState): string;

implementation

function MNoteTaskStateName(AState: TMNoteAITaskState): string;
begin
  case AState of
    atsPending: Result := 'pendente';
    atsRunning: Result := 'executando';
    atsCompleted: Result := 'concluída';
    atsFailed: Result := 'falhou';
    atsBlocked: Result := 'bloqueada';
  end;
end;

constructor TMNoteAITask.Create(const AID, ATitle, ACategory, AInstruction,
  ADependsOn: string);
begin
  inherited Create;
  ID := AID;
  Title := ATitle;
  Category := ACategory;
  Instruction := AInstruction;
  DependsOn := ADependsOn;
  State := atsPending;
end;

constructor TMNoteAITaskOrchestrator.Create(const ARoot: string);
begin
  inherited Create;
  FTasks := TObjectList.Create(True);
  FProjectRoot := ExpandFileName(ARoot);
  Load;
end;

destructor TMNoteAITaskOrchestrator.Destroy;
begin
  FTasks.Free;
  inherited Destroy;
end;

function TMNoteAITaskOrchestrator.TaskFile: string;
begin
  Result := IncludeTrailingPathDelimiter(FProjectRoot) +
    '.mnote' + PathDelim + 'ai_tasks.json';
end;

function TMNoteAITaskOrchestrator.GetCount: Integer;
begin
  Result := FTasks.Count;
end;

function TMNoteAITaskOrchestrator.GetTask(AIndex: Integer): TMNoteAITask;
begin
  Result := TMNoteAITask(FTasks[AIndex]);
end;

function TMNoteAITaskOrchestrator.GetByID(const AID: string): TMNoteAITask;
var I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if SameText(Tasks[I].ID, AID) then Exit(Tasks[I]);
end;

procedure TMNoteAITaskOrchestrator.Add(const AID, ATitle, ACategory,
  AInstruction, ADependsOn: string);
begin
  FTasks.Add(TMNoteAITask.Create(AID, ATitle, ACategory, AInstruction, ADependsOn));
end;

procedure TMNoteAITaskOrchestrator.Plan(const ARequest: string; AIncludeSQL: Boolean);
begin
  FTasks.Clear;
  FRequest := Trim(ARequest);
  Add('inventory', 'Inventário do projeto', 'file',
    'Analise a estrutura de arquivos, linguagens e dependências do projeto. ' +
    'Responda com evidências, indicando o que não pôde ser verificado.', '');
  Add('source', 'Análise de código', 'file',
    'Investigue problemas de código, padrões, segurança e manutenibilidade. ' +
    'Cite arquivos, símbolos e evidências; não modifique arquivos.', 'inventory');
  if AIncludeSQL then
    Add('sql', 'Análise SQL', 'sql',
      'Analise riscos de consultas SQL, transações, relacionamentos e índices ' +
      'com base nas evidências disponíveis. Não execute SQL e não presuma acesso ao banco.', 'inventory');
  Add('ai', 'Revisão técnica por IA', 'ai',
    'Confronte a análise de código com evidências, priorize problemas ' +
    'e não invente testes ou resultados.', 'source');
  if AIncludeSQL then
    Add('report', 'Relatório consolidado', 'review',
      'Consolide achados de código e SQL sem duplicar problemas. ' +
      'Registre severidade, evidências, limitações e próximos passos.', 'ai,sql')
  else
    Add('report', 'Relatório consolidado', 'review',
      'Consolide achados sem duplicar problemas. Registre severidade, ' +
      'evidências, limitações e próximos passos.', 'ai');
  Save;
end;

function TMNoteAITaskOrchestrator.DependenciesReady(ATask: TMNoteAITask): Boolean;
var Names: TStringList; I: Integer; Dep: TMNoteAITask;
begin
  Result := True;
  if Trim(ATask.DependsOn) = '' then Exit;
  Names := TStringList.Create;
  try
    Names.StrictDelimiter := True;
    Names.Delimiter := ',';
    Names.DelimitedText := ATask.DependsOn;
    for I := 0 to Names.Count - 1 do
    begin
      Dep := GetByID(Trim(Names[I]));
      if (Dep = nil) or (Dep.State <> atsCompleted) then Exit(False);
    end;
  finally
    Names.Free;
  end;
end;

function TMNoteAITaskOrchestrator.ExecuteNext: Boolean;
var I, J: Integer; Task: TMNoteAITask; Context, Answer: string;
begin
  Result := False;
  FLastError := '';
  if MNoteAI.IsBusy then
  begin
    FLastError := 'Outro processamento de IA está em andamento.';
    Exit;
  end;
  Task := nil;
  for I := 0 to Count - 1 do
    if (Tasks[I].State = atsPending) and DependenciesReady(Tasks[I]) then
    begin
      Task := Tasks[I];
      Break;
    end;
  if Task = nil then
  begin
    FLastError := 'Nenhuma tarefa pronta. Confira falhas e dependências.';
    Exit;
  end;
  Context := 'PROJETO: ' + FProjectRoot + LineEnding +
    'PEDIDO: ' + FRequest + LineEnding +
    'TAREFA: ' + Task.Title + LineEnding +
    'Esta etapa é SOMENTE LEITURA. Não execute comandos nem modifique arquivos.' +
    LineEnding + 'RESULTADOS DAS TAREFAS ANTERIORES:' + LineEnding;
  for J := 0 to Count - 1 do
    if Tasks[J].State = atsCompleted then
      Context := Context + Tasks[J].Title + ':' + LineEnding +
        Copy(Tasks[J].Evidence, 1, 10000) + LineEnding;
  Task.State := atsRunning;
  Save;
  try
    if MNoteAI.SendQuestion(Task.Instruction, Context, Answer) then
    begin
      Task.Evidence := Answer;
      Task.State := atsCompleted;
      Result := True;
    end
    else
    begin
      Task.State := atsFailed;
      Task.ErrorText := MNoteAI.LastError;
      FLastError := Task.ErrorText;
    end;
  except
    on E: Exception do
    begin
      Task.State := atsFailed;
      Task.ErrorText := E.Message;
      FLastError := E.Message;
    end;
  end;
  Save;
end;

function TMNoteAITaskOrchestrator.HasPending: Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
    if Tasks[I].State = atsPending then Exit(True);
end;

procedure TMNoteAITaskOrchestrator.Save;
var Root: TJSONObject; Arr: TJSONArray; O: TJSONObject;
  I: Integer; Lines: TStringList;
begin
  Root := TJSONObject.Create;
  Lines := TStringList.Create;
  try
    Root.Add('schema', 1);
    Root.Add('request', FRequest);
    Arr := TJSONArray.Create;
    Root.Add('tasks', Arr);
    for I := 0 to Count - 1 do
    begin
      O := TJSONObject.Create;
      O.Add('id', Tasks[I].ID);
      O.Add('title', Tasks[I].Title);
      O.Add('category', Tasks[I].Category);
      O.Add('instruction', Tasks[I].Instruction);
      O.Add('depends_on', Tasks[I].DependsOn);
      O.Add('state', Ord(Tasks[I].State));
      O.Add('evidence', Tasks[I].Evidence);
      O.Add('error', Tasks[I].ErrorText);
      Arr.Add(O);
    end;
    ForceDirectories(ExtractFileDir(TaskFile));
    Lines.Text := Root.FormatJSON;
    Lines.SaveToFile(TaskFile);
  finally
    Lines.Free;
    Root.Free;
  end;
end;

procedure TMNoteAITaskOrchestrator.Load;
var Lines: TStringList; Data: TJSONData; Obj, Item: TJSONObject;
  Arr: TJSONArray; I, S: Integer; Task: TMNoteAITask;
begin
  if not FileExists(TaskFile) then Exit;
  Lines := TStringList.Create;
  Data := nil;
  try
    Lines.LoadFromFile(TaskFile);
    Data := GetJSON(Lines.Text);
    if not (Data is TJSONObject) then Exit;
    Obj := TJSONObject(Data);
    if Obj.Get('schema', 0) <> 1 then Exit;
    FRequest := Obj.Get('request', '');
    if not (Obj.Find('tasks') is TJSONArray) then Exit;
    Arr := TJSONArray(Obj.Find('tasks'));
    FTasks.Clear;
    for I := 0 to Arr.Count - 1 do
    begin
      if not (Arr.Items[I] is TJSONObject) then Continue;
      Item := TJSONObject(Arr.Items[I]);
      Task := TMNoteAITask.Create(Item.Get('id', ''), Item.Get('title', ''),
        Item.Get('category', ''), Item.Get('instruction', ''),
        Item.Get('depends_on', ''));
      S := Item.Get('state', 0);
      if (S >= Ord(Low(TMNoteAITaskState))) and
         (S <= Ord(High(TMNoteAITaskState))) then
        Task.State := TMNoteAITaskState(S);
      if Task.State = atsRunning then Task.State := atsPending;
      Task.Evidence := Item.Get('evidence', '');
      Task.ErrorText := Item.Get('error', '');
      FTasks.Add(Task);
    end;
  except
    on E: Exception do FLastError := 'Falha ao carregar tarefas: ' + E.Message;
  end;
  Data.Free;
  Lines.Free;
end;

end.
