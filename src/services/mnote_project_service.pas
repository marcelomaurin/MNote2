unit mnote_project_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, mnote_service_base, mnote_git_read_service,
  aiproject_core;

type
  TMNoteProjectService = class(TMNoteServiceBase)
  private
    FProject: TAIProject;
    FStorage: TAIProjectStorage;
    FTasks: TAIProjectTasks;
    FActions: TAITaskActions;
    FFileName: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure NewProject(const AName, ARoot: string);
    function Load(const AFileName: string): Boolean;
    function Save: Boolean;
    function SaveAs(const AFileName: string): Boolean;
    function ValidateDependencies(AErrors: TStrings): Boolean;
    function CurrentGitHead(out AHead, AReason: string): Boolean;
    function ApplyTaskAction(const ATaskID, AActor: string;
      AAction: TAIProjectTaskAction; const AComment, AHeadToLink: string): Boolean;
    function ExportTaskMarkdown(const ATaskID, AOutputFolder: string;
      out AFileName, AMarkdown: string): Boolean;
    property Project: TAIProject read FProject;
    property Tasks: TAIProjectTasks read FTasks;
    property Actions: TAITaskActions read FActions;
    property FileName: string read FFileName;
  end;

implementation

function HasSensitiveField(AData: TJSONData): Boolean;
const
  SensitiveNames: array[0..6] of string = ('token', 'api_key', 'password',
    'secret', 'authorization', 'access_token', 'refresh_token');
var
  ObjectData: TJSONObject;
  ArrayData: TJSONArray;
  I, J: Integer;
begin
  Result := False;
  if AData is TJSONObject then
  begin
    ObjectData := TJSONObject(AData);
    for I := 0 to ObjectData.Count - 1 do
    begin
      for J := Low(SensitiveNames) to High(SensitiveNames) do
        if SameText(ObjectData.Names[I], SensitiveNames[J]) then Exit(True);
      if HasSensitiveField(ObjectData.Items[I]) then Exit(True);
    end;
  end
  else if AData is TJSONArray then
  begin
    ArrayData := TJSONArray(AData);
    for I := 0 to ArrayData.Count - 1 do
      if HasSensitiveField(ArrayData.Items[I]) then Exit(True);
  end;
end;

function TaskIndexByID(ATasks: TJSONArray; const AID: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to ATasks.Count - 1 do
    if SameText(ATasks.Objects[I].Get('id', ''), AID) then Exit(I);
end;

function SafeSlug(const AText: string): string;
var
  C: Char;
begin
  Result := '';
  for C in LowerCase(AText) do
    if C in ['a'..'z', '0'..'9'] then Result := Result + C
    else if (C in [' ', '-', '_']) and ((Result = '') or (Result[Length(Result)] <> '-')) then
      Result := Result + '-';
  while (Result <> '') and (Result[Length(Result)] = '-') do Delete(Result, Length(Result), 1);
  if Result = '' then Result := 'task';
end;

constructor TMNoteProjectService.Create;
begin
  inherited Create;
  FProject := TAIProject.Create;
  FStorage := TAIProjectStorage.Create(FProject);
  FTasks := TAIProjectTasks.Create(FProject);
  FActions := TAITaskActions.Create(FProject, FTasks);
end;

destructor TMNoteProjectService.Destroy;
begin
  FActions.Free;
  FTasks.Free;
  FStorage.Free;
  FProject.Free;
  inherited Destroy;
end;

procedure TMNoteProjectService.NewProject(const AName, ARoot: string);
begin
  ClearError;
  FProject.NewProject;
  FProject.Name := AName;
  FProject.Root := '.';
  if ARoot <> '' then
    FFileName := IncludeTrailingPathDelimiter(ExpandFileName(ARoot)) + AName + '.mnoteproj.json'
  else
    FFileName := '';
end;

function TMNoteProjectService.Load(const AFileName: string): Boolean;
begin
  ClearError;
  Result := FStorage.LoadFromFile(AFileName);
  if Result then FFileName := ExpandFileName(AFileName)
  else SetError(FStorage.LastError);
end;

function TMNoteProjectService.Save: Boolean;
begin
  Result := SaveAs(FFileName);
end;

function TMNoteProjectService.SaveAs(const AFileName: string): Boolean;
begin
  ClearError;
  Result := False;
  if AFileName = '' then
  begin
    SetError('Informe o arquivo .mnoteproj.json.');
    Exit;
  end;
  if HasSensitiveField(FProject.ProjectData) then
  begin
    SetError('O schema de projeto contém possível credencial e não foi salvo.');
    Exit;
  end;
  Result := FStorage.SaveToFile(AFileName);
  if Result then FFileName := ExpandFileName(AFileName)
  else SetError(FStorage.LastError);
end;

function TMNoteProjectService.CurrentGitHead(out AHead,
  AReason: string): Boolean;
var
  Git: TMNoteGitReadService;
  State: TMNoteGitState;
begin
  AHead := '';
  AReason := '';
  Git := TMNoteGitReadService.Create;
  try
    Result := Git.Inspect(ExtractFileDir(FFileName), State);
    if Result then AHead := State.Head
    else
    begin
      AReason := Git.LastError;
      if AReason = '' then AReason := State.ErrorMessage;
      if AReason = '' then AReason := 'A pasta do projeto não é um repositório Git.';
    end;
  finally
    Git.Free;
  end;
end;

function TMNoteProjectService.ApplyTaskAction(const ATaskID, AActor: string;
  AAction: TAIProjectTaskAction; const AComment, AHeadToLink: string): Boolean;
begin
  ClearError;
  Result := FActions.ApplyAction(ATaskID, AActor, AAction, AComment);
  if not Result then
  begin
    SetError(FActions.LastError);
    Exit;
  end;
  if (AAction = taFinishTask) and (Trim(AHeadToLink) <> '') and
    (not FTasks.LinkCommit(ATaskID, Trim(AHeadToLink))) then
  begin
    SetError(FTasks.LastError);
    Exit(False);
  end;
end;

function TMNoteProjectService.ValidateDependencies(AErrors: TStrings): Boolean;
var
  TaskArray, Dependencies: TJSONArray;
  State: array of Byte;
  I, J: Integer;
  procedure Visit(AIndex: Integer);
  var
    DependencyID: string;
    DependencyIndex, K: Integer;
  begin
    if State[AIndex] = 1 then
    begin
      AErrors.Add('Dependência circular envolvendo ' + TaskArray.Objects[AIndex].Get('id', ''));
      Exit;
    end;
    if State[AIndex] = 2 then Exit;
    State[AIndex] := 1;
    if TaskArray.Objects[AIndex].Find('dependencies') is TJSONArray then
    begin
      Dependencies := TaskArray.Objects[AIndex].Arrays['dependencies'];
      for K := 0 to Dependencies.Count - 1 do
      begin
        DependencyID := Dependencies.Strings[K];
        DependencyIndex := TaskIndexByID(TaskArray, DependencyID);
        if DependencyIndex < 0 then
          AErrors.Add(TaskArray.Objects[AIndex].Get('id', '') + ': dependência inexistente ' + DependencyID)
        else Visit(DependencyIndex);
      end;
    end;
    State[AIndex] := 2;
  end;
begin
  AErrors.Clear;
  TaskArray := FTasks.Tasks;
  SetLength(State, TaskArray.Count);
  for I := 0 to TaskArray.Count - 1 do State[I] := 0;
  for J := 0 to TaskArray.Count - 1 do Visit(J);
  Result := AErrors.Count = 0;
end;

function TMNoteProjectService.ExportTaskMarkdown(const ATaskID,
  AOutputFolder: string; out AFileName, AMarkdown: string): Boolean;
var
  Task, DependencyTask: TJSONObject;
  Dependencies, Files, Forbidden: TJSONArray;
  Lines: TStringList;
  I: Integer;
  Stream: TFileStream;
begin
  Result := False;
  ClearError;
  AFileName := '';
  AMarkdown := '';
  Task := FTasks.GetTaskByID(ATaskID);
  if Task = nil then
  begin
    SetError('Tarefa não encontrada: ' + ATaskID);
    Exit;
  end;
  if Trim(Task.Get('acceptance_criteria', '')) = '' then
  begin
    SetError('A tarefa precisa de critérios de aceite antes da exportação.');
    Exit;
  end;
  Lines := TStringList.Create;
  try
    Lines.Add('# ' + ATaskID + ' — ' + Task.Get('title', ''));
    Lines.Add(''); Lines.Add('## Descrição'); Lines.Add('');
    Lines.Add(Task.Get('description', ''));
    Lines.Add(''); Lines.Add('## Critérios de aceite'); Lines.Add('');
    Lines.Add(Task.Get('acceptance_criteria', ''));
    Lines.Add(''); Lines.Add('## Dependências'); Lines.Add('');
    if Task.Find('dependencies') is TJSONArray then
    begin
      Dependencies := Task.Arrays['dependencies'];
      for I := 0 to Dependencies.Count - 1 do
      begin
        DependencyTask := FTasks.GetTaskByID(Dependencies.Strings[I]);
        if DependencyTask <> nil then Lines.Add('- ' + Dependencies.Strings[I] + ': ' + DependencyTask.Get('title', ''))
        else Lines.Add('- ' + Dependencies.Strings[I] + ' (não encontrada)');
      end;
    end;
    Lines.Add(''); Lines.Add('## Arquivos afetados'); Lines.Add('');
    if Task.Find('files_affected') is TJSONArray then
    begin
      Files := Task.Arrays['files_affected'];
      for I := 0 to Files.Count - 1 do Lines.Add('- ' + Files.Strings[I]);
    end;
    Lines.Add(''); Lines.Add('## NÃO fazer'); Lines.Add('');
    if Task.Find('must_not_do') is TJSONArray then
    begin
      Forbidden := Task.Arrays['must_not_do'];
      for I := 0 to Forbidden.Count - 1 do Lines.Add('- ' + Forbidden.Strings[I]);
    end;
    AMarkdown := Lines.Text;
    ForceDirectories(AOutputFolder);
    AFileName := IncludeTrailingPathDelimiter(AOutputFolder) + ATaskID + '_' +
      SafeSlug(Task.Get('title', '')) + '.md';
    Stream := TFileStream.Create(AFileName, fmCreate);
    try
      if AMarkdown <> '' then Stream.WriteBuffer(AMarkdown[1], Length(AMarkdown));
    finally
      Stream.Free;
    end;
    Result := True;
  finally
    Lines.Free;
  end;
end;

end.
