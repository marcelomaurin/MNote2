unit mnote_ai_plan_contract;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, aiproject_core;

type
  TMNoteAIPlanContract = class
  private
    class function IsPureObject(const AText: string): Boolean; static;
    class function ValidateStringArray(AData: TJSONData;
      const AField: string; out AError: string): Boolean; static;
    class function ValidateTask(ATask: TJSONObject;
      ATaskIDs: TStrings; out AError: string): Boolean; static;
    class function ValidateDependencies(ATasks: TJSONArray;
      out AError: string): Boolean; static;
  public
    class function ValidateUnderstanding(const AJSON: string;
      out AReady: Boolean; out AQuestions, AError: string): Boolean; static;
    class function ParsePlan(const AJSON: string; out APlan: TJSONObject;
      out AError: string): Boolean; static;
    class function ApplyPlan(AProject: TAIProject; APlan: TJSONObject;
      ASelectedTaskIDs: TStrings; const AInput, ARevisionTitle: string;
      out AError: string): Boolean; static;
  end;

implementation

const
  PLAN_FIELDS: array[0..7] of string = ('tasks', 'dependencies',
    'execution_plan', 'parallel_groups', 'milestones', 'gantt', 'timeline',
    'risk_map');
  TASK_FIELDS: array[0..26] of string = ('id', 'epic_id', 'title',
    'description', 'acceptance_criteria', 'priority', 'status',
    'dependency_type', 'dependencies', 'can_run_in_parallel',
    'estimated_hours', 'suggested_skill_level', 'assigned_skill_level',
    'assigned_to', 'responsible_profile', 'estimated_duration_days',
    'deliverable', 'notes', 'progress_percent', 'revision_created',
    'revision_updated', 'long_description', 'files_affected', 'must_not_do',
    'commits', 'exclusive_files', 'origin');

function HasOnlyFields(AObject: TJSONObject; const ANames: array of string;
  out AUnknown: string): Boolean;
var
  I, J: Integer;
  Found: Boolean;
begin
  AUnknown := '';
  for I := 0 to AObject.Count - 1 do
  begin
    Found := False;
    for J := Low(ANames) to High(ANames) do
      if SameText(AObject.Names[I], ANames[J]) then
      begin
        Found := True;
        Break;
      end;
    if not Found then
    begin
      AUnknown := AObject.Names[I];
      Exit(False);
    end;
  end;
  Result := True;
end;

function HasFieldType(AObject: TJSONObject; const AName: string;
  AType: TJSONType): Boolean;
begin
  Result := (AObject.Find(AName) <> nil) and
    (AObject.Find(AName).JSONType = AType);
end;

function SelectedID(ASelected: TStrings; const AID: string): Boolean;
begin
  Result := (ASelected = nil) or (ASelected.IndexOf(AID) >= 0);
end;

procedure ReplaceJSON(AObject: TJSONObject; const AName: string;
  AValue: TJSONData);
begin
  if AObject.IndexOfName(AName) >= 0 then AObject.Delete(AName);
  AObject.Add(AName, AValue);
end;

class function TMNoteAIPlanContract.IsPureObject(const AText: string): Boolean;
var
  Text: string;
begin
  Text := Trim(AText);
  Result := (Text <> '') and (Text[1] = '{') and
    (Text[Length(Text)] = '}');
end;

class function TMNoteAIPlanContract.ValidateStringArray(AData: TJSONData;
  const AField: string; out AError: string): Boolean;
var
  Values: TJSONArray;
  I: Integer;
begin
  Result := AData is TJSONArray;
  if not Result then
  begin
    AError := AField + ' deve ser uma lista.';
    Exit;
  end;
  Values := TJSONArray(AData);
  for I := 0 to Values.Count - 1 do
    if Values.Items[I].JSONType <> jtString then
    begin
      AError := AField + ' aceita somente textos.';
      Exit(False);
    end;
end;

class function TMNoteAIPlanContract.ValidateTask(ATask: TJSONObject;
  ATaskIDs: TStrings; out AError: string): Boolean;
const
  STRING_FIELDS: array[0..13] of string = ('id', 'epic_id', 'title',
    'description', 'acceptance_criteria', 'priority', 'status',
    'dependency_type', 'suggested_skill_level', 'assigned_skill_level',
    'assigned_to', 'responsible_profile', 'deliverable', 'notes');
  INTEGER_FIELDS: array[0..3] of string = ('estimated_duration_days',
    'progress_percent', 'revision_created', 'revision_updated');
  ARRAY_FIELDS: array[0..4] of string = ('dependencies', 'files_affected',
    'must_not_do', 'commits', 'exclusive_files');
  HOUR_FIELDS: array[0..3] of string = ('intern', 'junior', 'mid_level',
    'senior');
var
  Unknown, ID, PathValue: string;
  Hours: TJSONObject;
  Values: TJSONArray;
  I, J: Integer;
begin
  Result := False;
  if not HasOnlyFields(ATask, TASK_FIELDS, Unknown) then
  begin
    AError := 'Campo de tarefa não declarado: ' + Unknown;
    Exit;
  end;
  for I := Low(TASK_FIELDS) to High(TASK_FIELDS) do
    if ATask.Find(TASK_FIELDS[I]) = nil then
    begin
      AError := 'Campo obrigatório ausente na tarefa: ' + TASK_FIELDS[I];
      Exit;
    end;
  for I := Low(STRING_FIELDS) to High(STRING_FIELDS) do
    if not HasFieldType(ATask, STRING_FIELDS[I], jtString) then
    begin
      AError := STRING_FIELDS[I] + ' deve ser texto.';
      Exit;
    end;
  if not HasFieldType(ATask, 'long_description', jtString) then
  begin AError := 'long_description deve ser texto.'; Exit; end;
  if not HasFieldType(ATask, 'can_run_in_parallel', jtBoolean) then
  begin AError := 'can_run_in_parallel deve ser booleano.'; Exit; end;
  for I := Low(INTEGER_FIELDS) to High(INTEGER_FIELDS) do
    if not HasFieldType(ATask, INTEGER_FIELDS[I], jtNumber) then
    begin AError := INTEGER_FIELDS[I] + ' deve ser número.'; Exit; end;
  if not (ATask.Find('origin') is TJSONObject) then
  begin AError := 'origin deve ser objeto.'; Exit; end;
  if not (ATask.Find('estimated_hours') is TJSONObject) then
  begin AError := 'estimated_hours deve ser objeto.'; Exit; end;
  Hours := ATask.Objects['estimated_hours'];
  if Hours.Count <> Length(HOUR_FIELDS) then
  begin AError := 'estimated_hours deve conter somente os quatro níveis.'; Exit; end;
  for I := Low(HOUR_FIELDS) to High(HOUR_FIELDS) do
    if not HasFieldType(Hours, HOUR_FIELDS[I], jtNumber) then
    begin AError := 'Estimativa ausente ou inválida: ' + HOUR_FIELDS[I]; Exit; end;
  for I := Low(ARRAY_FIELDS) to High(ARRAY_FIELDS) do
    if not ValidateStringArray(ATask.Find(ARRAY_FIELDS[I]), ARRAY_FIELDS[I],
      AError) then Exit;
  ID := Trim(ATask.Strings['id']);
  if (ID = '') or (Trim(ATask.Strings['title']) = '') then
  begin AError := 'ID e título da tarefa não podem ser vazios.'; Exit; end;
  if ATaskIDs.IndexOf(ID) >= 0 then
  begin AError := 'ID de tarefa duplicado: ' + ID; Exit; end;
  ATaskIDs.Add(ID);
  for I := 0 to 1 do
  begin
    if I = 0 then Values := ATask.Arrays['files_affected']
    else Values := ATask.Arrays['exclusive_files'];
    for J := 0 to Values.Count - 1 do
    begin
      PathValue := StringReplace(Values.Strings[J], '/', PathDelim,
        [rfReplaceAll]);
      if (PathValue <> '') and ((ExtractFileDrive(PathValue) <> '') or
        (PathValue[1] = PathDelim) or (Pos('..' + PathDelim, PathValue) > 0) or
        (PathValue = '..')) then
      begin
        AError := 'Caminho inseguro na tarefa ' + ID + ': ' + Values.Strings[J];
        Exit;
      end;
    end;
  end;
  Result := True;
end;

class function TMNoteAIPlanContract.ValidateDependencies(ATasks: TJSONArray;
  out AError: string): Boolean;
var
  IDs: TStringList;
  State: array of Byte;
  I: Integer;
  procedure Visit(AIndex: Integer);
  var
    Dependencies: TJSONArray;
    J, DependencyIndex: Integer;
    DependencyID: string;
  begin
    if AError <> '' then Exit;
    if State[AIndex] = 1 then
    begin
      AError := 'Dependência circular envolvendo ' +
        ATasks.Objects[AIndex].Strings['id'];
      Exit;
    end;
    if State[AIndex] = 2 then Exit;
    State[AIndex] := 1;
    Dependencies := ATasks.Objects[AIndex].Arrays['dependencies'];
    for J := 0 to Dependencies.Count - 1 do
    begin
      DependencyID := Dependencies.Strings[J];
      DependencyIndex := IDs.IndexOf(DependencyID);
      if DependencyIndex < 0 then
      begin
        AError := ATasks.Objects[AIndex].Strings['id'] +
          ': dependência inexistente ' + DependencyID;
        Exit;
      end;
      Visit(DependencyIndex);
    end;
    State[AIndex] := 2;
  end;
begin
  AError := '';
  IDs := TStringList.Create;
  try
    IDs.CaseSensitive := False;
    for I := 0 to ATasks.Count - 1 do IDs.Add(ATasks.Objects[I].Strings['id']);
    SetLength(State, ATasks.Count);
    for I := 0 to ATasks.Count - 1 do Visit(I);
    Result := AError = '';
  finally
    IDs.Free;
  end;
end;

class function TMNoteAIPlanContract.ValidateUnderstanding(const AJSON: string;
  out AReady: Boolean; out AQuestions, AError: string): Boolean;
const
  FIELDS: array[0..5] of string = ('objective', 'scopes', 'assumptions',
    'ambiguities', 'questions', 'ready_to_plan');
var
  Data: TJSONData;
  Root: TJSONObject;
  Unknown: string;
  Questions: TJSONArray;
  I: Integer;
begin
  Result := False;
  AReady := False;
  AQuestions := '';
  AError := '';
  if not IsPureObject(AJSON) then
  begin AError := 'A etapa Entender deve retornar somente JSON puro.'; Exit; end;
  Data := nil;
  try
    try
      Data := GetJSON(AJSON);
      if not (Data is TJSONObject) then
      begin AError := 'Objeto JSON esperado.'; Exit; end;
      Root := TJSONObject(Data);
      if not HasOnlyFields(Root, FIELDS, Unknown) then
      begin AError := 'Campo não declarado em Entender: ' + Unknown; Exit; end;
      if Root.Count <> Length(FIELDS) then
      begin AError := 'Todos os seis campos de Entender são obrigatórios.'; Exit; end;
      if not HasFieldType(Root, 'objective', jtString) or
        not HasFieldType(Root, 'ready_to_plan', jtBoolean) or
        not ValidateStringArray(Root.Find('scopes'), 'scopes', AError) or
        not ValidateStringArray(Root.Find('assumptions'), 'assumptions', AError) or
        not ValidateStringArray(Root.Find('ambiguities'), 'ambiguities', AError) or
        not ValidateStringArray(Root.Find('questions'), 'questions', AError) then
      begin
        if AError = '' then AError := 'Tipos inválidos no contrato Entender.';
        Exit;
      end;
      AReady := Root.Booleans['ready_to_plan'];
      Questions := Root.Arrays['questions'];
      for I := 0 to Questions.Count - 1 do
      begin
        if AQuestions <> '' then AQuestions := AQuestions + LineEnding;
        AQuestions := AQuestions + Questions.Strings[I];
      end;
      if AReady and (Questions.Count > 0) then
      begin
        AError := 'ready_to_plan não pode ser verdadeiro enquanto houver perguntas.';
        Exit;
      end;
      if (not AReady) and (Questions.Count = 0) then
      begin
        AError := 'Uma ambiguidade deve produzir pelo menos uma pergunta.';
        Exit;
      end;
      Result := Trim(Root.Strings['objective']) <> '';
      if not Result then AError := 'objective não pode ser vazio.';
    except
      on E: Exception do AError := E.Message;
    end;
  finally
    Data.Free;
  end;
end;

class function TMNoteAIPlanContract.ParsePlan(const AJSON: string;
  out APlan: TJSONObject; out AError: string): Boolean;
var
  Data: TJSONData;
  Root: TJSONObject;
  IDs: TStringList;
  Unknown: string;
  I: Integer;
begin
  Result := False;
  APlan := nil;
  AError := '';
  if not IsPureObject(AJSON) then
  begin AError := 'O plano deve conter somente um objeto JSON.'; Exit; end;
  Data := nil;
  IDs := TStringList.Create;
  try
    IDs.CaseSensitive := False;
    try
      Data := GetJSON(AJSON);
      if not (Data is TJSONObject) then
      begin AError := 'Objeto JSON esperado.'; Exit; end;
      Root := TJSONObject(Data);
      if not HasOnlyFields(Root, PLAN_FIELDS, Unknown) then
      begin AError := 'Campo de plano não declarado: ' + Unknown; Exit; end;
      if Root.Count <> Length(PLAN_FIELDS) then
      begin AError := 'O plano deve conter exatamente os oito campos declarados.'; Exit; end;
      for I := Low(PLAN_FIELDS) to High(PLAN_FIELDS) do
        if not (Root.Find(PLAN_FIELDS[I]) is TJSONArray) then
        begin AError := PLAN_FIELDS[I] + ' deve ser uma lista.'; Exit; end;
      if Root.Arrays['tasks'].Count = 0 then
      begin AError := 'O plano precisa conter ao menos uma tarefa.'; Exit; end;
      for I := 0 to Root.Arrays['tasks'].Count - 1 do
      begin
        if not (Root.Arrays['tasks'].Items[I] is TJSONObject) then
        begin AError := 'Cada tarefa deve ser um objeto.'; Exit; end;
        if not ValidateTask(Root.Arrays['tasks'].Objects[I], IDs, AError) then Exit;
      end;
      if not ValidateDependencies(Root.Arrays['tasks'], AError) then Exit;
      APlan := Root;
      Data := nil;
      Result := True;
    except
      on E: Exception do AError := E.Message;
    end;
  finally
    IDs.Free;
    Data.Free;
  end;
end;

class function TMNoteAIPlanContract.ApplyPlan(AProject: TAIProject;
  APlan: TJSONObject; ASelectedTaskIDs: TStrings; const AInput,
  ARevisionTitle: string; out AError: string): Boolean;
var
  SourceTasks, NewTasks: TJSONArray;
  Planning, Agile: TJSONObject;
  Task: TJSONObject;
  Dependencies: TJSONArray;
  I, J: Integer;
begin
  Result := False;
  AError := '';
  if (AProject = nil) or (APlan = nil) then
  begin AError := 'Projeto ou plano não informado.'; Exit; end;
  SourceTasks := APlan.Arrays['tasks'];
  NewTasks := TJSONArray.Create;
  try
    for I := 0 to SourceTasks.Count - 1 do
    begin
      Task := SourceTasks.Objects[I];
      if not SelectedID(ASelectedTaskIDs, Task.Strings['id']) then Continue;
      Dependencies := Task.Arrays['dependencies'];
      for J := 0 to Dependencies.Count - 1 do
        if not SelectedID(ASelectedTaskIDs, Dependencies.Strings[J]) then
        begin
          AError := Task.Strings['id'] + ' depende da tarefa não selecionada ' +
            Dependencies.Strings[J] + '.';
          Exit;
        end;
      NewTasks.Add(Task.Clone);
    end;
    if NewTasks.Count = 0 then
    begin AError := 'Selecione pelo menos uma tarefa.'; Exit; end;
    AProject.AddRevision(ARevisionTitle, AInput, APlan.FormatJSON);
    Planning := AProject.ProjectData.Objects['planning'];
    ReplaceJSON(Planning, 'tasks', NewTasks);
    NewTasks := nil;
    for I := 1 to 6 do
      ReplaceJSON(Planning, PLAN_FIELDS[I], APlan.Arrays[PLAN_FIELDS[I]].Clone);
    Agile := AProject.ProjectData.Objects['agile_documents'];
    ReplaceJSON(Agile, 'risk_map', APlan.Arrays['risk_map'].Clone);
    JSONSetString(AProject.ProjectData, 'last_generated_json', APlan.FormatJSON);
    Result := True;
  finally
    NewTasks.Free;
  end;
end;

end.
