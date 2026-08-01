program mnote_tests;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  Classes, SysUtils, fpjson, mnote_service_base, mnote_tool_windows, mnote_commands,
  mnote_fuzzy_matcher, mnote_search_types, mnote_text_search_service,
  mnote_file_search_service, mnote_file_replace_service,
  mnote_language_profile, mnote_language_registry, mnote_editor_options,
  mnote_editor_theme, mnote_completion_types, mnote_completion_provider,
  mnote_completion_aggregator, mnote_static_completion_provider,
  mnote_document_completion_provider, mnote_snippet_completion_provider,
  mnote_database_completion_provider, mnote_pascal_symbol_parser,
  mnote_project_symbol_index, mnote_token_parser,
  mnote_prompt_builder, mnote_token_estimator, mnote_token_usage,
  mnote_voice_command,
  aiproject_core, mnote_project_service, mnote_unified_diff,
  mnote_source_change_types, mnote_source_change_manager,
  mnote_ai_change_contract, mnote_task_execution_flow, mnote_git_read_service,
  mnote_task_comment_index, mnote_diagnostics, mnote_output_model,
  mnote_process_service, mnote_build_service, mnote_ai_types,
  mnote_ai_router, mnote_ai_session, mnote_ai_bus, mnote_ai_actions,
  mnote_ai_plan_contract, mnote_project_inventory_service,
  mnote_project_context,
  mnote_document_export_service, mnote_capability_catalog,
  mnote_dependency_graph_service, mnote_sql_validation_service,
  mnote_neural_api_bootstrap;

type
  TTestService = class(TMNoteServiceBase)
  public
    procedure Fail(const AMessage: string);
  end;

  TErrorObserver = class
  private
    FCallCount: Integer;
    FMessage: string;
  public
    procedure HandleError(Sender: TObject; const AError: string);
    property CallCount: Integer read FCallCount;
    property MessageText: string read FMessage;
  end;

  TToolWindowObserver = class
  private
    FCallCount: Integer;
    FLastKind: TMNoteToolWindowKind;
    FLastVisible: Boolean;
  public
    procedure HandleVisibility(Sender: TObject; AKind: TMNoteToolWindowKind;
      AVisible: Boolean);
    property CallCount: Integer read FCallCount;
    property LastKind: TMNoteToolWindowKind read FLastKind;
    property LastVisible: Boolean read FLastVisible;
  end;

  TCommandObserver = class
  private
    FExecuted: Integer;
  public
    procedure Execute(Sender: TObject);
    property Executed: Integer read FExecuted;
  end;

  TFileApplyObserver = class
  private
    FRejectIndex: Integer;
  public
    function BeforeApply(Sender: TObject; const AFileName: string;
      AFileIndex: Integer): Boolean;
    property RejectIndex: Integer read FRejectIndex write FRejectIndex;
  end;

  TActionObserver = class
  public
    function Reject(Sender: TObject; ADescriptor: TMNoteAIActionDescriptor;
      AParameters: TJSONObject; out AReason: string): Boolean;
  end;

procedure TTestService.Fail(const AMessage: string);
begin
  SetError(AMessage);
end;

procedure TErrorObserver.HandleError(Sender: TObject; const AError: string);
begin
  if Sender <> nil then
    Inc(FCallCount);
  FMessage := AError;
end;

procedure TToolWindowObserver.HandleVisibility(Sender: TObject;
  AKind: TMNoteToolWindowKind; AVisible: Boolean);
begin
  if Sender <> nil then
    Inc(FCallCount);
  FLastKind := AKind;
  FLastVisible := AVisible;
end;

procedure TCommandObserver.Execute(Sender: TObject);
begin
  if Sender <> nil then
    Inc(FExecuted);
end;

function TFileApplyObserver.BeforeApply(Sender: TObject;
  const AFileName: string; AFileIndex: Integer): Boolean;
begin
  Result := (Sender <> nil) and (AFileName <> '') and
    (AFileIndex <> FRejectIndex);
end;

function TActionObserver.Reject(Sender: TObject;
  ADescriptor: TMNoteAIActionDescriptor; AParameters: TJSONObject;
  out AReason: string): Boolean;
begin
  AReason := 'confirmação recusada pela fixture';
  Result := False;
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure SaveFixtureText(const AFileName, AText: string);
var
  FixtureFile: TFileStream;
begin
  FixtureFile := TFileStream.Create(AFileName, fmCreate);
  try
    if AText <> '' then
      FixtureFile.WriteBuffer(AText[1], Length(AText));
  finally
    FixtureFile.Free;
  end;
end;

function LoadFixtureText(const AFileName: string): string;
var
  FixtureFile: TFileStream;
begin
  FixtureFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, FixtureFile.Size);
    if FixtureFile.Size > 0 then
      FixtureFile.ReadBuffer(Result[1], FixtureFile.Size);
  finally
    FixtureFile.Free;
  end;
end;

procedure RemoveFixtureTree(const AFolder: string);
var
  AllowedRoot, FullFolder, Name: string;
  Search: TSearchRec;
begin
  AllowedRoot := IncludeTrailingPathDelimiter(ExpandFileName(
    ExtractFilePath(ParamStr(0))));
  FullFolder := IncludeTrailingPathDelimiter(ExpandFileName(AFolder));
  if (FullFolder = AllowedRoot) or
    (Pos(LowerCase(AllowedRoot), LowerCase(FullFolder)) <> 1) then Exit;
  if FindFirst(FullFolder + '*', faAnyFile, Search) = 0 then
  try
    repeat
      if (Search.Name = '.') or (Search.Name = '..') then Continue;
      Name := FullFolder + Search.Name;
      if (Search.Attr and faDirectory) <> 0 then RemoveFixtureTree(Name)
      else DeleteFile(Name);
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
  RemoveDir(ExcludeTrailingPathDelimiter(FullFolder));
end;

procedure TestCompletion;
var
  SourceOne, SourceTwo, DBValues: TStringList;
  ProviderOne, ProviderTwo, DocumentProvider: IMNoteCompletionProvider;
  DocumentProviderObject: TMNoteDocumentCompletionProvider;
  Aggregator: TMNoteCompletionAggregator;
  Context: TMNoteCompletionContext;
  Items, ParsedItems: TMNoteCompletionItems;
  Parser: TMNotePascalSymbolParser;
  CursorOffset: Integer;
  ExpandedSnippet, FixtureRoot, UnitOne, UnitTwo, CacheFile: string;
  ProjectIndex, LoadedIndex: TMNoteProjectSymbolIndex;
begin
  SourceOne := TStringList.Create;
  SourceTwo := TStringList.Create;
  DBValues := TStringList.Create;
  Aggregator := TMNoteCompletionAggregator.Create;
  Context := TMNoteCompletionContext.Create;
  Items := TMNoteCompletionItems.Create;
  ParsedItems := TMNoteCompletionItems.Create;
  Parser := TMNotePascalSymbolParser.Create;
  try
    SourceOne.Add('Alpha|documentação curta');
    SourceOne.Add('Alfred|segundo item');
    SourceTwo.Add('Alpha|documentação determinística mais completa');
    ProviderOne := TMNoteStaticCompletionProvider.Create('pascal',
      'linguagem', SourceOne);
    ProviderTwo := TMNoteStaticCompletionProvider.Create('pascal',
      'fixture', SourceTwo);
    Aggregator.AddProvider(ProviderOne);
    Aggregator.AddProvider(ProviderTwo);
    Context.LanguageID := 'pascal';
    Context.Query := 'Al';
    Aggregator.Complete(Context, Items);
    Check((Items.Count = 2) and (Items[0].Text = 'Alpha'),
      'Ranking de completion não é determinístico por prioridade/texto');
    Check(Pos('mais completa', Items[0].Documentation) > 0,
      'Agregador não removeu duplicata preservando a melhor documentação');

    Check(TMNoteTokenParser.CurrentToken('Obj.Propriedade', '._') =
      'Obj.Propriedade', 'Token qualificado Pascal incorreto');
    Check(TMNoteTokenParser.CurrentToken('ptr->member', '._:') =
      'ptr->member', 'Token qualificado C++ com -> incorreto');
    Check(TMNoteTokenParser.CurrentToken('obj.metodo', '._') =
      'obj.metodo', 'Token qualificado Python incorreto');
    Check(TMNoteTokenParser.CurrentToken('"schema"."tabela"', '._') =
      'schema"."tabela"', 'Token SQL com aspas incorreto');

    Parser.Parse('unit Demo;'#10+'interface'#10+'type'#10+
      '  TThing = class'#10+'    property Name: string;'#10+'  end;'#10+
      'const'#10+'  CCount = 2;'#10+'var'#10+'  FValue: Integer;'#10+
      'procedure DoWork(AValue: Integer);'#10+
      'function GetValue: Integer;'#10+
      '// procedure Fake;'#10+'const S = ''function AlsoFake'';',
      'demo.pas', 'documento', ParsedItems);
    Check(ParsedItems.FindByInsertText('Demo') <> nil,
      'Parser Pascal não encontrou a unit');
    Check((ParsedItems.FindByInsertText('TThing') <> nil) and
      (ParsedItems.FindByInsertText('Name') <> nil) and
      (ParsedItems.FindByInsertText('CCount') <> nil) and
      (ParsedItems.FindByInsertText('FValue') <> nil) and
      (ParsedItems.FindByInsertText('DoWork') <> nil) and
      (ParsedItems.FindByInsertText('GetValue') <> nil),
      'Parser Pascal não extraiu todos os tipos de símbolo da fixture');
    Check((ParsedItems.FindByInsertText('Fake') = nil) and
      (ParsedItems.FindByInsertText('AlsoFake') = nil),
      'Parser Pascal interpretou comentário ou string como símbolo');

    DocumentProviderObject := TMNoteDocumentCompletionProvider.Create;
    DocumentProvider := DocumentProviderObject;
    Context.DocumentText := 'unit CacheTest;'#10+'procedure CachedSymbol;';
    Context.FileName := 'cache_test.pas';
    Items.Clear;
    DocumentProvider.Collect(Context, Items);
    Items.Clear;
    DocumentProvider.Collect(Context, Items);
    Check(DocumentProviderObject.ParseCount = 1,
      'Cache do documento reprocessou buffer sem alteração');
    Context.DocumentText := Context.DocumentText + #10+'procedure NewSymbol;';
    Items.Clear;
    DocumentProvider.Collect(Context, Items);
    Check((DocumentProviderObject.ParseCount = 2) and
      (Items.FindByInsertText('NewSymbol') <> nil),
      'Cache do documento não invalidou somente o buffer alterado');

    ExpandedSnippet := TMNoteSnippetCompletionProvider.Expand(
      'procedure ${1:Nome};'#10+'begin'#10+'  $0'#10+'end;', CursorOffset);
    Check((Pos('${', ExpandedSnippet) = 0) and (Pos('$0', ExpandedSnippet) = 0)
      and (Copy(ExpandedSnippet, CursorOffset + 1, 4) = 'Nome'),
      'Expansão de snippet não posicionou o cursor no primeiro placeholder');

    FixtureRoot := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'symbol_index_fixture';
    UnitOne := IncludeTrailingPathDelimiter(FixtureRoot) + 'one.pas';
    UnitTwo := IncludeTrailingPathDelimiter(FixtureRoot) + 'two.pas';
    CacheFile := IncludeTrailingPathDelimiter(FixtureRoot) +
      '.mnote\symbols.cache';
    ForceDirectories(FixtureRoot);
    try
      SaveFixtureText(UnitOne, 'unit One;'#10+'procedure LocalSymbol;');
      SaveFixtureText(UnitTwo, 'unit Two;'#10+'function CrossUnit: Integer;');
      ProjectIndex := TMNoteProjectSymbolIndex.Create;
      try
        Check(ProjectIndex.IndexFolder(FixtureRoot) and
          (ProjectIndex.IndexedCount = 2),
          'Índice de projeto não processou as duas units');
        Check((ProjectIndex.FindDefinition('CrossUnit') <> nil) and
          SameFileName(ProjectIndex.FindDefinition('CrossUnit').FileName,
            UnitTwo), 'Definição entre units não foi encontrada');
        Check(ProjectIndex.SaveCache(CacheFile),
          'Cache persistente de símbolos não foi salvo');
      finally
        ProjectIndex.Free;
      end;
      LoadedIndex := TMNoteProjectSymbolIndex.Create;
      try
        Check(LoadedIndex.LoadCache(CacheFile) and
          (LoadedIndex.FindDefinition('CrossUnit') <> nil),
          'Cache persistente de símbolos não foi restaurado');
        Check(LoadedIndex.IndexFolder(FixtureRoot) and
          (LoadedIndex.IndexedCount = 0) and (LoadedIndex.ReusedCount = 2),
          'Segunda abertura reindexou arquivos inalterados');
      finally
        LoadedIndex.Free;
      end;
    finally
      DeleteFile(CacheFile);
      RemoveDir(ExtractFileDir(CacheFile));
      DeleteFile(UnitOne);
      DeleteFile(UnitTwo);
      RemoveDir(FixtureRoot);
    end;
    DBValues.Add('customers|Tabela|Database');
    DBValues.Add('customers.id|Coluna integer|Database');
    MNoteDatabaseCompletions.Update(DBValues);
    Context.LanguageID := 'sql';
    Context.Query := 'cust';
    Items.Clear;
    MNoteDatabaseCompletions.Collect(Context, Items);
    Check((Items.Count = 2) and (Items[0].Kind = ckTable) and
      (Items[1].Kind = ckField),
      'Provider SQL não classificou tabela e coluna do dicionário');
  finally
    MNoteDatabaseCompletions.Clear;
    DBValues.Free;
    DocumentProvider := nil;
    ProviderTwo := nil;
    ProviderOne := nil;
    Parser.Free;
    ParsedItems.Free;
    Items.Free;
    Context.Free;
    Aggregator.Free;
    SourceTwo.Free;
    SourceOne.Free;
  end;
end;

procedure TestAIUtilities;
var
  Prompt: string;
  Estimator: TMNoteTokenEstimator;
  EstimateBefore, EstimateAfter: TMNoteTokenEstimate;
  VoiceCommand: string;
  UsageTokens: Integer;
  UsageField: string;
begin
  Prompt := TMNotePromptBuilder.Build('revisor', 'confirmar o resultado',
    'não alterar arquivos', 'fixture', 'JSON válido');
  Check((Pos('[PAPEL]', Prompt) > 0) and
    (Pos('[OBJETIVO]', Prompt) > 0) and
    (Pos('[RESTRIÇÕES]', Prompt) > 0) and
    (Pos('[CONTEXTO]', Prompt) > 0) and
    (Pos('[CONTRATO DE SAÍDA]', Prompt) > 0),
    'Prompt estruturado perdeu uma camada obrigatória');
  Estimator := TMNoteTokenEstimator.Create;
  try
    EstimateBefore := Estimator.Estimate(StringOfChar('a', 400), 100);
    Check((EstimateBefore.EstimatedTokens = 100) and
      (EstimateBefore.SafetyMargin = 15) and EstimateBefore.ExceedsLimit and
      (Pos('estimativa', EstimateBefore.Method) > 0),
      'Estimador de tokens não aplicou margem ou rótulo honesto');
    Estimator.Calibrate(300, 100);
    EstimateAfter := Estimator.Estimate(StringOfChar('a', 400), 1000);
    Check(EstimateAfter.EstimatedTokens > EstimateBefore.EstimatedTokens,
      'Calibração do estimador não alterou a razão observada');
  finally
    Estimator.Free;
  end;
  Check(TMNoteVoiceCommand.TryParse('ok mnote explique esta função',
    'OK MNote', VoiceCommand) and (VoiceCommand = 'explique esta função'),
    'Palavra de ativação não reconheceu caixa ou comando UTF-8');
  Check(TMNoteVoiceCommand.TryParse('OK MNote', 'OK MNote', VoiceCommand) and
    (VoiceCommand = ''), 'Ativação isolada deveria entrar em modo de escuta');
  Check(not TMNoteVoiceCommand.TryParse('explique esta função', 'OK MNote',
    VoiceCommand), 'Comando sem palavra de ativação não deveria executar');
  Check(TMNoteTokenUsage.ExtractPromptTokens(
    '{"usage":{"prompt_tokens":37}}', UsageTokens, UsageField) and
    (UsageTokens = 37) and (UsageField = 'usage.prompt_tokens'),
    'Parser de usage OpenAI nao encontrou prompt_tokens');
  Check(TMNoteTokenUsage.ExtractPromptTokens(
    '{"usageMetadata":{"promptTokenCount":41}}', UsageTokens,
    UsageField) and (UsageTokens = 41) and
    (UsageField = 'usageMetadata.promptTokenCount'),
    'Parser de usage Gemini nao encontrou promptTokenCount');
  Check(not TMNoteTokenUsage.ExtractPromptTokens(
    '{"candidates":[]}', UsageTokens, UsageField),
    'Parser inventou usage ausente');
end;

procedure TestProjectCore;
var
  Service, Loaded: TMNoteProjectService;
  TaskOne, TaskTwo: TJSONObject;
  Errors: TStringList;
  FixtureRoot, ProjectFile, ExportFile, Markdown: string;
begin
  FixtureRoot := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'project_fixture';
  ProjectFile := IncludeTrailingPathDelimiter(FixtureRoot) +
    'fixture.mnoteproj.json';
  ForceDirectories(FixtureRoot);
  Service := TMNoteProjectService.Create;
  Loaded := TMNoteProjectService.Create;
  Errors := TStringList.Create;
  try
    Service.NewProject('Fixture', FixtureRoot);
    Service.Project.Description := 'descrição UTF-8';
    Service.Project.Goal := 'provar round-trip';
    Service.Project.ProjectData.Add('unknown_legacy_field', 'preservar');
    Check(Service.Tasks.AddTask('Primeira tarefa', 'descrição', 'high',
      'DEV', 'Autor', 4) = 'T001', 'AddTask não gerou o primeiro ID');
    Check(Service.Tasks.AddTask('Segunda tarefa', 'descrição', 'normal',
      'QA', 'Revisor', 2) = 'T002', 'AddTask não gerou ID sequencial');
    TaskOne := Service.Tasks.GetTaskByID('T001');
    TaskTwo := Service.Tasks.GetTaskByID('T002');
    Check((TaskOne.Count >= 26) and
      (TaskOne.Find('files_affected') is TJSONArray) and
      (TaskOne.Find('must_not_do') is TJSONArray) and
      (TaskOne.Find('commits') is TJSONArray) and
      (TaskOne.Find('exclusive_files') is TJSONArray),
      'Schema não contém os 21 campos legados e extensões aditivas');
    TaskOne.Arrays['dependencies'].Add('T002');
    TaskTwo.Arrays['dependencies'].Add('T001');
    Check(not Service.ValidateDependencies(Errors) and (Errors.Count > 0),
      'Ciclo de dependências não foi detectado');
    TaskTwo.Arrays['dependencies'].Clear;
    Check(Service.ValidateDependencies(Errors),
      'Dependências válidas foram recusadas');
    Check(Service.Actions.ApplyAction('T001', 'tester', taConfirmTask,
      'confirmada') and Service.Actions.ApplyAction('T001', 'tester',
      taStartTask, '') and Service.Actions.ApplyAction('T001', 'tester',
      taFinishTask, 'evidência'), 'Fluxo real de ações da tarefa falhou');
    Check((TaskOne.Get('status', '') = 'completed') and
      (TaskOne.Get('progress_percent', 0) = 100) and
      (Service.Project.ProjectData.Arrays['task_actions'].Count = 3),
      'Ação não registrou estados anterior/novo e progresso');
    Check(not Service.Actions.ApplyAction('T002', 'tester', taFinishTask, ''),
      'Transição inválida de tarefa foi aceita');
    JSONSetString(TaskOne, 'acceptance_criteria', 'Todos os testes passam.');
    TaskOne.Arrays['files_affected'].Add('src/main.pas');
    TaskOne.Arrays['must_not_do'].Add('Não alterar credenciais.');
    Check(Service.ExportTaskMarkdown('T001',
      IncludeTrailingPathDelimiter(FixtureRoot) + 'tasks', ExportFile,
      Markdown) and FileExists(ExportFile) and
      (Pos('## Critérios de aceite', Markdown) > 0) and
      (Pos('T002: Segunda tarefa', Markdown) > 0),
      'Documento de bot não preservou o contrato da tarefa');
    Check(Service.SaveAs(ProjectFile),
      'Projeto não foi salvo: ' + Service.LastError);
    Check(Loaded.Load(ProjectFile),
      'Projeto não foi reaberto: ' + Loaded.LastError);
    Check((Loaded.Project.Name = 'Fixture') and
      (Loaded.Project.Description = 'descrição UTF-8') and
      (Loaded.Project.ProjectData.Get('unknown_legacy_field', '') = 'preservar') and
      (Loaded.Tasks.Count = 2) and
      (Loaded.Tasks.GetTaskByID('T001').Arrays['files_affected'].Count = 1),
      'Round-trip perdeu campo legado, projeto, tarefa ou extensão');
    Check((Loaded.Project.ProjectData.Find('agile_documents') is TJSONObject) and
      (Loaded.Project.ProjectData.Find('agents') is TJSONArray) and
      (Loaded.Project.ProjectData.Find('planning') is TJSONObject) and
      (Loaded.Project.ProjectData.Find('task_actions') is TJSONArray) and
      (Loaded.Project.ProjectData.Find('agent_task_analysis') is TJSONArray) and
      (Loaded.Project.ProjectData.Find('revisions') is TJSONArray),
      'Schema interoperável não manteve as estruturas raiz obrigatórias');
  finally
    Errors.Free;
    Loaded.Free;
    Service.Free;
    if ExportFile <> '' then DeleteFile(ExportFile);
    RemoveDir(IncludeTrailingPathDelimiter(FixtureRoot) + 'tasks');
    DeleteFile(ProjectFile);
    RemoveDir(FixtureRoot);
  end;
end;

procedure TestProjectContext;
var
  Context: TMNoteProjectContext;
  BaseRoot, ProjectRoot, Descriptor, LazarusRoot, LPIFile, DBFile,
    InvalidDescriptor: string;
begin
  BaseRoot := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'project_context_fixture';
  ProjectRoot := IncludeTrailingPathDelimiter(BaseRoot) + 'Aplicacao';
  Descriptor := IncludeTrailingPathDelimiter(ProjectRoot) +
    'Aplicacao.mnoteproj.json';
  LazarusRoot := IncludeTrailingPathDelimiter(BaseRoot) + 'Legacy';
  LPIFile := IncludeTrailingPathDelimiter(LazarusRoot) + 'legacy.lpi';
  DBFile := IncludeTrailingPathDelimiter(LazarusRoot) + 'legacy.db';
  InvalidDescriptor := IncludeTrailingPathDelimiter(LazarusRoot) +
    'invalid.mnoteproj.json';
  ForceDirectories(BaseRoot);
  Context := TMNoteProjectContext.Create;
  try
    Check(Context.CreateNew(BaseRoot, 'Aplicacao', 'Projeto integrado', True),
      'Contexto não criou projeto: ' + Context.LastError);
    Check(Context.IsOpen and (Context.Kind = mpkMNote) and
      SameFileName(Context.RootPath, ProjectRoot) and FileExists(Descriptor) and
      (Context.DisplayName = 'Aplicacao'),
      'Novo projeto não ativou descritor, raiz e nome corretos');
    Context.Close;
    Check(not Context.IsOpen, 'Close manteve o projeto ativo');
    Check(Context.Open(ProjectRoot) and (Context.Kind = mpkMNote) and
      SameFileName(Context.ProjectFile, Descriptor),
      'Abertura por pasta não detectou o descritor MNote2');
    Check(not Context.CreateNew(BaseRoot, 'nome/inválido', '', True),
      'Nome de projeto inválido foi aceito');

    ForceDirectories(LazarusRoot);
    SaveFixtureText(InvalidDescriptor, '{invalid');
    Check((not Context.Open(InvalidDescriptor)) and Context.IsOpen and
      SameFileName(Context.RootPath, ProjectRoot),
      'Descritor inválido substituiu o contexto ativo');
    DeleteFile(InvalidDescriptor);
    SaveFixtureText(LPIFile, '<CONFIG/>');
    Check(Context.Open(LPIFile) and (Context.Kind = mpkLazarus) and
      SameFileName(Context.RootPath, LazarusRoot),
      'Projeto Lazarus não foi reconhecido');
    DeleteFile(LPIFile);
    SaveFixtureText(DBFile, 'fixture');
    Check(Context.Open(DBFile) and (Context.Kind = mpkLegacyDatabase),
      'Projeto legado .db não foi reconhecido');
  finally
    Context.Free;
    DeleteFile(DBFile);
    DeleteFile(LPIFile);
    DeleteFile(InvalidDescriptor);
    RemoveDir(LazarusRoot);
    DeleteFile(Descriptor);
    RemoveDir(ProjectRoot);
    RemoveDir(BaseRoot);
  end;
end;

function PlanTask(const AID, ATitle: string;
  ADependencies: TJSONArray): TJSONObject;
begin
  Result := TJSONObject.Create([
    'id', AID, 'epic_id', 'E001', 'title', ATitle,
    'description', 'Descrição verificável',
    'acceptance_criteria', 'Testes passam', 'priority', 'normal',
    'status', 'draft', 'dependency_type', 'serial',
    'dependencies', ADependencies, 'can_run_in_parallel', False,
    'estimated_hours', TJSONObject.Create(['intern', 4, 'junior', 3,
      'mid_level', 2, 'senior', 1]),
    'suggested_skill_level', 'mid_level',
    'assigned_skill_level', 'mid_level', 'assigned_to', '',
    'responsible_profile', 'DEV', 'estimated_duration_days', 1,
    'deliverable', 'Código e testes', 'notes', '', 'progress_percent', 0,
    'revision_created', 1, 'revision_updated', 1,
    'long_description', 'Detalhamento',
    'files_affected', TJSONArray.Create(['src/main.pas']),
    'must_not_do', TJSONArray.Create(['Não salvar credenciais']),
    'commits', TJSONArray.Create, 'exclusive_files', TJSONArray.Create,
    'origin', TJSONObject.Create(['kind', 'ai_plan'])]);
end;

function ValidPlanJSON: string;
var
  Plan: TJSONObject;
  Tasks: TJSONArray;
begin
  Tasks := TJSONArray.Create;
  Tasks.Add(PlanTask('T001', 'Base', TJSONArray.Create));
  Tasks.Add(PlanTask('T002', 'Dependente', TJSONArray.Create(['T001'])));
  Plan := TJSONObject.Create(['tasks', Tasks,
    'dependencies', TJSONArray.Create,
    'execution_plan', TJSONArray.Create,
    'parallel_groups', TJSONArray.Create,
    'milestones', TJSONArray.Create,
    'gantt', TJSONArray.Create,
    'timeline', TJSONArray.Create,
    'risk_map', TJSONArray.Create]);
  try
    Result := Plan.AsJSON;
  finally
    Plan.Free;
  end;
end;

procedure TestAIPlanContract;
var
  Project: TAIProject;
  Tasks: TAIProjectTasks;
  Plan: TJSONObject;
  Selected: TStringList;
  PlanJSON, ErrorText, Questions: string;
  Ready: Boolean;
begin
  Check(TMNoteAIPlanContract.ValidateUnderstanding(
    '{"objective":"entregar","scopes":[],"assumptions":[],' +
    '"ambiguities":[],"questions":[],"ready_to_plan":true}', Ready,
    Questions, ErrorText) and Ready and (Questions = ''),
    'Contrato Entender válido foi recusado: ' + ErrorText);
  Check(TMNoteAIPlanContract.ValidateUnderstanding(
    '{"objective":"entregar","scopes":[],"assumptions":[],' +
    '"ambiguities":["destino"],"questions":["Qual destino?"],' +
    '"ready_to_plan":false}', Ready, Questions, ErrorText) and
    (not Ready) and (Pos('destino', LowerCase(Questions)) > 0),
    'Ambiguidade não interrompeu o planejamento');
  Check(not TMNoteAIPlanContract.ValidateUnderstanding(
    '{"objective":"x","scopes":[],"assumptions":[],"ambiguities":[],' +
    '"questions":[],"ready_to_plan":false}', Ready, Questions, ErrorText),
    'Entender ambíguo sem pergunta foi aceito');

  PlanJSON := ValidPlanJSON;
  Plan := nil;
  Check(TMNoteAIPlanContract.ParsePlan(PlanJSON, Plan, ErrorText),
    'Plano válido foi recusado: ' + ErrorText);
  Project := TAIProject.Create;
  Tasks := TAIProjectTasks.Create(Project);
  Selected := TStringList.Create;
  try
    Tasks.AddTask('Anterior', 'não deve mudar sem confirmação', 'normal',
      'DEV', '', 1);
    Check(Tasks.Count = 1, 'Fixture anterior não foi criada');
    Check(TMNoteAIPlanContract.ApplyPlan(Project, Plan, nil, 'objetivo',
      'Plano 1', ErrorText), 'Plano confirmado não foi aplicado: ' + ErrorText);
    Check((Tasks.Count = 2) and
      (Project.ProjectData.Arrays['revisions'].Count = 1) and
      (Project.ProjectData.Get('last_generated_json', '') <> ''),
      'Aplicação não preservou revisão/plano gerado');
    Plan.Free;
    Plan := nil;
    Check(TMNoteAIPlanContract.ParsePlan(PlanJSON, Plan, ErrorText),
      'Plano não reabriu para seleção parcial');
    Selected.Add('T002');
    Check(not TMNoteAIPlanContract.ApplyPlan(Project, Plan, Selected,
      'objetivo', 'Plano parcial', ErrorText),
      'Seleção sem dependência obrigatória foi aceita');
    Check((Tasks.Count = 2) and
      (Project.ProjectData.Arrays['revisions'].Count = 1),
      'Plano recusado alterou o projeto antes da confirmação');
  finally
    Selected.Free;
    Plan.Free;
    Tasks.Free;
    Project.Free;
  end;
  Plan := nil;
  Check(not TMNoteAIPlanContract.ParsePlan(
    Copy(PlanJSON, 1, Length(PlanJSON) - 1) + ',"command":"write"}',
    Plan, ErrorText), 'Campo de comando desconhecido foi aceito no plano');
  Plan.Free;
end;

procedure TestSourceChanges;
const
  DiffCases: array[0..7, 0..1] of string = (
    ('b'#10'c'#10, 'a'#10'b'#10'c'#10),
    ('a'#10'c'#10, 'a'#10'b'#10'c'#10),
    ('a'#10'b'#10, 'a'#10'b'#10'c'#10),
    ('a'#10'b'#10'c'#10, 'a'#10'c'#10),
    ('a'#10'b'#10, 'a'#10'x'#10),
    ('', 'novo'#10),
    ('café'#13#10'fim'#13#10, 'início'#13#10'café'#13#10'fim'#13#10),
    ('igual'#10'igual'#10'fim', 'igual'#10'novo'#10'igual'#10'fim'));
var
  I: Integer;
  Diff, Rebuilt, DiffError: string;
  HunkSelection: array of Boolean;
  Fallback: Boolean;
  Root, OneFile, TwoFile, NewFile, PartialFile, PartialOriginal: string;
  Manager: TAISourceChangeManager;
  ChangeSet, NewFileSet, RemoveContentSet, FailureSet, HashSet, LineSet, PartialSet,
    ContractSet: TAISourceChangeSet;
  Change: TAISourceChange;
  ContractError: string;
begin
  for I := Low(DiffCases) to High(DiffCases) do
  begin
    Diff := TMNoteUnifiedDiff.Generate(DiffCases[I, 0], DiffCases[I, 1],
      'fixture.pas', Fallback);
    Check((not Fallback) and (Pos('--- a/fixture.pas', Diff) > 0) and
      (Pos('+++ b/fixture.pas', Diff) > 0),
      'Diff unificado não gerou cabeçalhos estáveis');
    Check(TMNoteUnifiedDiff.Apply(DiffCases[I, 0], Diff, Rebuilt,
      DiffError) and (Rebuilt = DiffCases[I, 1]),
      'Aplicação do diff não reconstruiu fixture ' + IntToStr(I) + ': ' + DiffError);
  end;
  Diff := TMNoteUnifiedDiff.Generate('a'#10'b', 'x'#10'y', 'large.txt',
    Fallback, 1);
  Check(Fallback and (Pos('fallback=1', Diff) > 0) and
    TMNoteUnifiedDiff.Apply('a'#10'b', Diff, Rebuilt, DiffError) and
    (Rebuilt = 'x'#10'y'), 'Fallback limitado do diff não foi explícito/exato');
  Diff := TMNoteUnifiedDiff.Generate(
    'a'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'k'#10'l'#10'm'#10'n'#10'o'#10,
    'A'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'k'#10'l'#10'm'#10'n'#10'O'#10,
    'distant.txt', Fallback);
  Check((TMNoteUnifiedDiff.HunkCount(Diff) = 2) and
    TMNoteUnifiedDiff.Apply(
      'a'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'k'#10'l'#10'm'#10'n'#10'o'#10,
      Diff, Rebuilt, DiffError) and
    (Rebuilt = 'A'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'k'#10'l'#10'm'#10'n'#10'O'#10),
    'Mudanças distantes não geraram/aplicaram dois hunks reais: ' + DiffError);

  SetLength(HunkSelection, 2);
  HunkSelection[0] := True;
  HunkSelection[1] := False;
  Diff := TMNoteUnifiedDiff.SelectHunks(Diff, HunkSelection);
  Check((TMNoteUnifiedDiff.HunkCount(Diff) = 1) and
    TMNoteUnifiedDiff.Apply(
      'a'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'k'#10'l'#10'm'#10'n'#10'o'#10,
      Diff, Rebuilt, DiffError) and
    (Rebuilt = 'A'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'k'#10'l'#10'm'#10'n'#10'o'#10),
    'Selecao de hunk nao reconstruiu somente o trecho aceito: ' + DiffError);

  Root := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'source_change_fixture';
  OneFile := IncludeTrailingPathDelimiter(Root) + 'one.pas';
  TwoFile := IncludeTrailingPathDelimiter(Root) + 'two.pas';
  NewFile := IncludeTrailingPathDelimiter(Root) + 'new.pas';
  PartialFile := IncludeTrailingPathDelimiter(Root) + 'partial.pas';
  PartialOriginal := 'a'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10 +
    'j'#10'k'#10'l'#10'm'#10'n'#10'o'#10;
  RemoveFixtureTree(Root);
  ForceDirectories(Root);
  SaveFixtureText(OneFile, 'unit one;'#13#10'old value'#13#10'end.'#13#10);
  SaveFixtureText(TwoFile, 'unit two;'#10'keep'#10'end.'#10);
  SaveFixtureText(PartialFile, PartialOriginal);
  Manager := TAISourceChangeManager.Create;
  ChangeSet := TAISourceChangeSet.Create;
  NewFileSet := TAISourceChangeSet.Create;
  RemoveContentSet := TAISourceChangeSet.Create;
  FailureSet := TAISourceChangeSet.Create;
  HashSet := TAISourceChangeSet.Create;
  LineSet := TAISourceChangeSet.Create;
  PartialSet := TAISourceChangeSet.Create;
  try
    Manager.RootPath := Root;
    Check(TMNoteAIChangeContract.Parse(
      '{"task_id":"T001","request":"fixture","model":"test",' +
      '"changes":[{"kind":"exact_replace","file":"one.pas",' +
      '"expected_text":"old value","new_text":"contract value",' +
      '"expected_count":1}]}', Manager, ContractSet, ContractError) and
      (ContractSet.Count = 1) and (ContractSet.Status = scsProposed),
      'Contrato JSON válido da IA não criou proposta: ' + ContractError);
    ContractSet.Free;
    ContractSet := nil;
    Check((not TMNoteAIChangeContract.Parse('texto {"changes":[]}', Manager,
      ContractSet, ContractError)) and (ContractSet = nil),
      'Texto misto foi aceito como contrato executável');
    Check((not TMNoteAIChangeContract.Parse(
      '{"changes":[{"kind":"new_file","file":"x.pas",' +
      '"content":"x","command":"del"}]}', Manager, ContractSet,
      ContractError)) and (Pos('desconhecido', ContractError) > 0),
      'Campo crítico desconhecido não foi rejeitado');
    Check(TMNoteAIChangeContract.MayRetry(aceInvalidContract, 0) and
      (not TMNoteAIChangeContract.MayRetry(aceInvalidContract, 1)) and
      (not TMNoteAIChangeContract.MayRetry(aceSafety, 0)) and
      (not TMNoteAIChangeContract.MayRetry(aceHash, 0)),
      'Retry não está limitado a uma correção de contrato');
    Check(Manager.ProposeExactReplace(ChangeSet, '..\escape.pas', 'a',
      'b', 1) = nil, 'Path traversal foi aceito');
    Check(Manager.ProposeNewFile(ChangeSet, 'binary.exe', 'x') = nil,
      'Extensão executável foi aceita');
    Change := Manager.ProposeExactReplace(ChangeSet, 'one.pas', 'old value',
      'new value', 1);
    Check((Change <> nil) and (Change.Status = scsProposed) and
      (Pos('-old value', Change.Diff) > 0) and
      (Pos('+new value', Change.Diff) > 0),
      'Preview exato não criou change set Proposed e diff real');
    Change := Manager.ProposeNewFile(ChangeSet, 'new.pas',
      'unit new;'#10'end.'#10);
    Check(Change <> nil, 'Proposta de arquivo novo falhou: ' + Manager.LastError);
    ChangeSet[1].Selected := False;
    Manager.DryRun := False;
    Check(not Manager.Apply(ChangeSet, False) and
      (Pos('Confirmação', Manager.LastError) > 0),
      'Apply sem confirmação explícita foi aceito');
    Check(Manager.Apply(ChangeSet, True),
      'Apply confirmado falhou: ' + Manager.LastError);
    Check((Pos('new value', LoadFixtureText(OneFile)) > 0) and
      (not FileExists(NewFile)), 'Seleção parcial alterou arquivo desmarcado');
    Check(Manager.Rollback(ChangeSet),
      'Rollback do change set falhou: ' + Manager.LastError);
    Check(Pos('old value', LoadFixtureText(OneFile)) > 0,
      'Rollback não restaurou o conteúdo original');

    Check(Manager.ProposeNewFile(NewFileSet, 'new.pas',
      'unit new;'#10'end.'#10) <> nil,
      'Arquivo novo nao foi proposto: ' + Manager.LastError);
    Check(Manager.Apply(NewFileSet, True) and FileExists(NewFile) and
      (LoadFixtureText(NewFile) = 'unit new;'#10'end.'#10),
      'Apply nao criou o arquivo novo real: ' + Manager.LastError);
    Check(Manager.Rollback(NewFileSet) and (not FileExists(NewFile)),
      'Rollback nao removeu o arquivo criado: ' + Manager.LastError);

    Check(Manager.ProposeExactReplace(RemoveContentSet, 'one.pas',
      'unit one;'#13#10'old value'#13#10'end.'#13#10, '', 1) <> nil,
      'Remocao logica nao foi proposta: ' + Manager.LastError);
    Check(Manager.Apply(RemoveContentSet, True) and
      (LoadFixtureText(OneFile) = ''),
      'Apply nao executou a remocao logica do conteudo');
    Check(Manager.Rollback(RemoveContentSet) and
      (LoadFixtureText(OneFile) =
        'unit one;'#13#10'old value'#13#10'end.'#13#10),
      'Rollback nao restaurou o arquivo removido logicamente');

    Change := PartialSet.Add;
    Change.Kind := sckExactReplace;
    Change.FileName := 'partial.pas';
    Change.OriginalHash := Manager.ContentHash(PartialOriginal);
    Change.ProposedContent := 'A'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10 +
      'h'#10'i'#10'j'#10'k'#10'l'#10'm'#10'n'#10'O'#10;
    Change.Diff := TMNoteUnifiedDiff.Generate(PartialOriginal,
      Change.ProposedContent, Change.FileName, Change.FallbackDiff);
    Change.InitializeHunks(TMNoteUnifiedDiff.HunkCount(Change.Diff));
    Check((Change.HunkCount = 2) and
      Manager.SetHunkSelected(Change, 1, False) and
      (Change.SelectedHunkCount = 1) and
      (Change.ProposedContent =
        'A'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10 +
        'k'#10'l'#10'm'#10'n'#10'o'#10),
      'Change set parcial nao manteve somente o hunk aceito: ' +
      Manager.LastError);
    Check(Manager.Apply(PartialSet, True) and
      (LoadFixtureText(PartialFile) = Change.ProposedContent),
      'Apply nao respeitou a selecao parcial de hunks: ' +
      Manager.LastError);
    Check(Manager.Rollback(PartialSet) and
      (LoadFixtureText(PartialFile) = PartialOriginal),
      'Rollback da selecao parcial nao restaurou o original');

    Check(Manager.ProposeExactReplace(FailureSet, 'one.pas', 'old value',
      'fault value', 1) <> nil, 'Fixture de falha não foi proposta');
    Manager.FailAfterTempWrite := True;
    Check(not Manager.Apply(FailureSet, True) and
      (LoadFixtureText(OneFile) = 'unit one;'#13#10'old value'#13#10'end.'#13#10) and
      (not FileExists(OneFile + '.mnote-tmp')),
      'Falha após temporário deixou arquivo parcial ou temporário');
    Manager.FailAfterTempWrite := False;

    Check(Manager.ProposeExactReplace(HashSet, 'one.pas', 'old value',
      'hash value', 1) <> nil, 'Fixture de hash não foi proposta');
    SaveFixtureText(OneFile, 'mudança externa');
    Check(not Manager.Apply(HashSet, True) and
      (Pos('Hash original mudou', Manager.LastError) > 0),
      'Mudança externa após preview não bloqueou Apply');
    SaveFixtureText(OneFile, 'unit one;'#13#10'old value'#13#10'end.'#13#10);

    Check(Manager.ProposeLineRange(LineSet, 'two.pas', 2, 2, 'keep',
      'changed') <> nil, 'Operação por intervalo válido falhou');
    Check(Manager.Apply(LineSet, True) and
      (LoadFixtureText(TwoFile) = 'unit two;'#10'changed'#10'end.'#10),
      'Operação por linhas não preservou LF/conteúdo');
    SaveFixtureText(TwoFile, 'alterado depois do apply');
    Check(not Manager.Rollback(LineSet) and
      (Pos('alterado depois', Manager.LastError) > 0),
      'Rollback sobrescreveu alteração manual posterior');
  finally
    PartialSet.Free;
    LineSet.Free;
    HashSet.Free;
    FailureSet.Free;
    RemoveContentSet.Free;
    NewFileSet.Free;
    ChangeSet.Free;
    Manager.Free;
    RemoveFixtureTree(Root);
  end;
end;

procedure TestEndToEndTaskExecution;
var
  Root, TargetFile, TaskID: string;
  Project: TMNoteProjectService;
  Flow: TMNoteTaskExecutionFlow;
  Manager: TAISourceChangeManager;
  ChangeSet: TAISourceChangeSet;
  Change: TAISourceChange;
  Task: TJSONObject;
begin
  Root := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'end_to_end_task_fixture';
  TargetFile := IncludeTrailingPathDelimiter(Root) + 'feature.txt';
  RemoveFixtureTree(Root);
  ForceDirectories(Root);
  SaveFixtureText(TargetFile, 'status=old'#10);
  Project := TMNoteProjectService.Create;
  Flow := nil;
  Manager := TAISourceChangeManager.Create;
  ChangeSet := TAISourceChangeSet.Create;
  try
    Project.NewProject('Fluxo real', Root);
    TaskID := Project.Tasks.AddTask('Atualizar fixture',
      'Alterar o estado e provar por teste.', 'high', 'DEV', 'Codex', 1);
    Task := Project.Tasks.GetTaskByID(TaskID);
    Task.Arrays['files_affected'].Add('feature.txt');
    Check(Project.Actions.ApplyAction(TaskID, 'tester', taConfirmTask,
      'escopo revisado') and Project.Actions.ApplyAction(TaskID, 'tester',
      taStartTask, 'execucao iniciada'),
      'Projeto e tarefa nao entraram em execucao real');

    Flow := TMNoteTaskExecutionFlow.Create(TaskID, False);
    Check(Flow.PrepareContext('Projeto, tarefa e feature.txt carregados.'),
      'Preparo de contexto do fluxo integrado falhou');
    Manager.RootPath := Root;
    Change := Manager.ProposeExactReplace(ChangeSet, 'feature.txt',
      'status=old', 'status=new', 1);
    Check((Change <> nil) and Flow.RecordStep(tesRequestSolution,
      esCompleted, 'Proposta exata criada para feature.txt.'),
      'Solucao real nao gerou uma proposta');
    Check((Pos('-status=old', Change.Diff) > 0) and
      (Pos('+status=new', Change.Diff) > 0) and
      Flow.RecordStep(tesValidateProposal, esCompleted,
        'Hash, caminho e diff validados.'),
      'Contrato ou diff da proposta integrada nao foi validado');
    Check(Flow.RecordStep(tesReviewDiff, esCompleted,
      'Aprovacao explicita registrada.'),
      'Revisao da proposta integrada falhou');
    Manager.DryRun := False;
    Check(Manager.Apply(ChangeSet, True) and
      Flow.RecordStep(tesApply, esCompleted,
        'Apply atomico concluido com hash preservado.'),
      'Apply integrado falhou: ' + Manager.LastError);
    Check((LoadFixtureText(TargetFile) = 'status=new'#10) and
      Flow.RecordStep(tesTest, esCompleted,
        'Conteudo final verificado no disco.'),
      'Teste real do resultado aplicado falhou');
    Check(Project.Actions.ApplyAction(TaskID, 'tester', taFinishTask,
      'fixture validada') and Flow.RecordStep(tesConclude, esCompleted,
      'Tarefa concluida somente apos o teste.') and
      Flow.IsReallyCompleted and (Task.Get('status', '') = 'completed') and
      (Task.Get('progress_percent', 0) = 100),
      'Ciclo projeto -> tarefa -> proposta -> teste -> conclusao ficou incompleto');
    Check(Manager.Rollback(ChangeSet) and
      (LoadFixtureText(TargetFile) = 'status=old'#10),
      'Limpeza do fluxo integrado nao restaurou a fixture');
  finally
    ChangeSet.Free;
    Manager.Free;
    Flow.Free;
    Project.Free;
    RemoveFixtureTree(Root);
  end;
end;

procedure TestTaskFlowAndGit;
var
  PlanFlow, RealFlow: TMNoteTaskExecutionFlow;
  Git: TMNoteGitReadService;
  GitState: TMNoteGitState;
  RepoRoot, NonGitRoot, LogText, DiffText: string;
begin
  PlanFlow := TMNoteTaskExecutionFlow.Create('T001', True);
  RealFlow := TMNoteTaskExecutionFlow.Create('T002', False);
  try
    Check(PlanFlow.PrepareContext('fixture temporária validada') and
      (PlanFlow.State(tesPrepareContext).Status = esCompleted) and
      (PlanFlow.State(tesRequestSolution).Status = esSkipped) and
      PlanFlow.RecordStep(tesValidateProposal, esCompleted,
        'contrato JSON validado') and
      (PlanFlow.State(tesReviewDiff).Status = esPending) and
      (not PlanFlow.RecordStep(tesApply, esCompleted, 'simulado')) and
      (not PlanFlow.IsReallyCompleted),
      'PlanOnly fabricou execução ou não preservou Pending/Skipped');
    Check(RealFlow.PrepareContext('contexto') and
      RealFlow.RecordStep(tesRequestSolution, esCompleted, 'resposta recebida') and
      RealFlow.RecordStep(tesValidateProposal, esCompleted, 'schema válido') and
      RealFlow.RecordStep(tesReviewDiff, esCompleted, 'aprovação humana') and
      RealFlow.RecordStep(tesApply, esCompleted, 'hash aplicado') and
      RealFlow.RecordStep(tesTest, esCompleted, 'exit code 0') and
      RealFlow.RecordStep(tesConclude, esCompleted, 'tarefa finalizada') and
      RealFlow.IsReallyCompleted,
      'Fluxo real não percorreu todas as etapas com evidência');
  finally
    RealFlow.Free;
    PlanFlow.Free;
  end;

  Git := TMNoteGitReadService.Create;
  try
    RepoRoot := ExpandFileName(IncludeTrailingPathDelimiter(
      ExtractFilePath(ParamStr(0))) + '..\..');
    Check(Git.Inspect(RepoRoot, GitState) and GitState.Available and
      (GitState.Root <> '') and (Length(GitState.Head) >= 7),
      'Serviço Git somente leitura não detectou raiz/HEAD reais: ' + Git.LastError);
    Check(Git.ShortLog(RepoRoot, 2, LogText) and (Trim(LogText) <> ''),
      'Serviço Git não retornou log curto');
    Check(Git.CommitDiff(RepoRoot, GitState.Head, DiffText) and
      (Pos('commit ', DiffText) > 0), 'Serviço Git não abriu diff do HEAD');
    NonGitRoot := IncludeTrailingPathDelimiter(GetTempDir) +
      'mnote_non_git_fixture';
    ForceDirectories(NonGitRoot);
    Check((not Git.Inspect(NonGitRoot, GitState)) and
      (not GitState.Available), 'Pasta fora de Git deveria ficar indisponível');
    RemoveDir(NonGitRoot);
  finally
    Git.Free;
  end;
end;

procedure TestTaskCommentIndex;
var
  Index: TMNoteTaskCommentIndex;
  Root, FileName: string;
begin
  Root := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'task_comment_fixture';
  FileName := IncludeTrailingPathDelimiter(Root) + 'fixture.pas';
  ForceDirectories(Root);
  SaveFixtureText(FileName, 'unit Fixture;'#10+
    '// TODO: criar teste'#10+'// FIXME corrigir UTF-8 café'#10+
    '// METHODTODO não é token'#10+'// CUSTOM - configurável'#10+'end.');
  Index := TMNoteTaskCommentIndex.Create;
  try
    Index.Tokens.Add('CUSTOM');
    Index.Scan(Root);
    Check((Index.Count = 3) and (Index[0].Token = 'TODO') and
      (Index[0].Description = 'criar teste') and (Index[0].Line = 2) and
      (Index[1].Token = 'FIXME') and
      (Pos('café', Index[1].Description) > 0) and
      (Index[2].Token = 'CUSTOM'),
      'Task List não indexou tokens configuráveis, linha ou UTF-8 corretamente');
  finally
    Index.Free;
    DeleteFile(FileName);
    RemoveDir(Root);
  end;
end;

procedure TestDiagnosticsAndOutput;
var
  Diagnostics: TMNoteDiagnostics;
  Output: TMNoteOutputModel;
begin
  Diagnostics := TMNoteDiagnostics.Create;
  Output := TMNoteOutputModel.Create;
  try
    TMNoteDiagnosticParser.Parse(
      'C:\work\main.pas(12,7) Error: (E100) Identifier not found'#10 +
      'unit1.pas(9) Warning: variável não usada'#10 +
      '/tmp/app.pas:4:2: note: compilando rotina', 'Build', Diagnostics);
    Check(Diagnostics.Count = 3,
      'Parser não reconheceu as três formas de diagnóstico');
    Check((Diagnostics[0].FileName = 'C:\work\main.pas') and
      (Diagnostics[0].Line = 12) and (Diagnostics[0].Column = 7) and
      (Diagnostics[0].Severity = mdsError) and
      (Diagnostics[0].Code = 'E100') and
      (Diagnostics[0].MessageText = 'Identifier not found'),
      'Diagnóstico FPC perdeu arquivo, posição, código ou mensagem');
    Check((Diagnostics[1].Column = 0) and
      (Diagnostics[1].Severity = mdsWarning),
      'Diagnóstico sem coluna foi interpretado incorretamente');
    Check((Diagnostics[2].Severity = mdsMessage) and
      (Diagnostics[2].Origin = 'Build'),
      'Diagnóstico no formato file:line:column perdeu severidade ou origem');

    Output.SetText(mocBuild, 'build-one');
    Output.SetText(mocAI, 'ai-one');
    Output.Clear(mocBuild);
    Check((Output.TextOf(mocBuild) = '') and
      (Pos('ai-one', Output.TextOf(mocAI)) > 0),
      'Limpeza de um canal apagou outro canal de saída');
    Output.Add(mocAI, '-two');
    Check(Pos('-two', Output.TextOf(mocAI)) > 0,
      'Canal de saída não aceitou conteúdo incremental');
  finally
    Output.Free;
    Diagnostics.Free;
  end;
end;

procedure TestProcessService;
var
  Service: TMNoteProcessService;
  Arguments: TStringList;
  ExecutableName: string;
begin
  Service := TMNoteProcessService.Create;
  Arguments := TStringList.Create;
  try
    {$IFDEF WINDOWS}
    ExecutableName := 'powershell.exe';
    Arguments.Add('-NoProfile');
    Arguments.Add('-NonInteractive');
    Arguments.Add('-Command');
    Arguments.Add('Write-Output ''stdout-ok''; ' +
      '[Console]::Error.WriteLine(''stderr-ok'')');
    {$ELSE}
    ExecutableName := '/bin/sh';
    Arguments.Add('-c');
    Arguments.Add('printf stdout-ok; printf stderr-ok >&2');
    {$ENDIF}
    Check(Service.Execute(ExecutableName, Arguments,
      ExtractFilePath(ParamStr(0)), 5000),
      'Processo controlado falhou: ' + Service.LastError);
    Check((Pos('stdout-ok', Service.StdOut) > 0) and
      (Pos('stderr-ok', Service.StdErr) > 0),
      'Captura separada de stdout/stderr falhou');

    Arguments.Clear;
    {$IFDEF WINDOWS}
    Arguments.Add('-NoProfile');
    Arguments.Add('-NonInteractive');
    Arguments.Add('-Command');
    Arguments.Add('Start-Sleep -Milliseconds 500');
    {$ELSE}
    Arguments.Add('-c');
    Arguments.Add('sleep 1');
    {$ENDIF}
    Check(not Service.Execute(ExecutableName, Arguments,
      ExtractFilePath(ParamStr(0)), 50),
      'Processo além do prazo deveria falhar');
    Check(Service.TimedOut and (not Service.Running),
      'Timeout não encerrou o processo controlado');
  finally
    Arguments.Free;
    Service.Free;
  end;
end;

procedure TestBuildPreparation;
var
  Service: TMNoteBuildService;
  Arguments: TStringList;
  ProjectRoot, ExecutableName, WorkingDirectory, ErrorText: string;
begin
  Service := TMNoteBuildService.Create;
  Arguments := TStringList.Create;
  try
    ProjectRoot := ExpandFileName(IncludeTrailingPathDelimiter(
      ExtractFilePath(ParamStr(0))) + '..\..');
    Check(Service.Prepare(ProjectRoot, False, ExecutableName,
      WorkingDirectory, Arguments, ErrorText),
      'Preparação de build falhou: ' + ErrorText);
    Check((ExecutableName <> '') and DirectoryExists(WorkingDirectory) and
      (Arguments.Count >= 2) and
      (ExtractFileExt(Arguments[Arguments.Count - 1]) = '.lpi'),
      'Build automático não selecionou executável, diretório e projeto');
    Check(Service.Prepare(ProjectRoot, True, ExecutableName,
      WorkingDirectory, Arguments, ErrorText) and
      (Arguments.IndexOf('--build-all') >= 0),
      'Rebuild não recebeu a opção de recompilação integral');
  finally
    Arguments.Free;
    Service.Free;
  end;
end;

procedure TestMultiAICore;
var
  Role: TMNoteAIRole;
  Config: TMNoteAIProfileConfig;
  ConfigJSON, LoadedJSON: TJSONObject;
  Router: TMNoteAIRouter;
  Route: TMNoteAIRoute;
  Estimator: TMNoteTokenEstimator;
  Parts: TStringList;
  Overflow: Boolean;
  Reason, Verdict, SessionJSON: string;
  Session, LoadedSession: TMNoteAISession;
  Step: TMNoteAISessionStep;
  Bus: TMNoteAIBus;
  BusMessage: TMNoteAIBusMessage;
begin
  ConfigJSON := TJSONObject.Create;
  LoadedJSON := nil;
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
  begin
    Config := TMNoteAIProfileConfig.Create(Role);
    try
      Config.ModelName := 'modelo-' + MNoteAIRoleID(Role);
      ConfigJSON.Add(MNoteAIRoleID(Role), Config.ToJSON);
      Check(Config.Validate(Reason), 'Perfil padrão inválido: ' + Reason);
    finally
      Config.Free;
    end;
  end;
  try
    Check(ConfigJSON.Count = 6, 'Configuração não preservou os seis papéis');
    Check((Pos('token', LowerCase(ConfigJSON.AsJSON)) = 0) and
      (Pos('password', LowerCase(ConfigJSON.AsJSON)) = 0),
      'Configuração multi-IA contém segredo');
    LoadedJSON := TJSONObject(GetJSON(ConfigJSON.AsJSON));
    Check(LoadedJSON.Count = 6, 'Round-trip dos perfis perdeu papéis');
  finally
    LoadedJSON.Free;
    ConfigJSON.Free;
  end;

  Router := TMNoteAIRouter.Create;
  Estimator := TMNoteTokenEstimator.Create;
  Parts := TStringList.Create;
  Session := TMNoteAISession.Create;
  LoadedSession := TMNoteAISession.Create;
  Bus := TMNoteAIBus.Create;
  try
    Route := Router.Route(aikDatabase, 10, 2000);
    Check((Route.Role = airDatabase) and
      (Router.Route(aikPlanning, 10, 2000).Role = airManagement) and
      (Router.Route(aikSmallWork, 10, 2000).Role = airLightWork),
      'Roteamento determinístico escolheu papel incorreto');
    Check(Router.ClassifyError('HTTP 401 invalid token', False, False) =
      aiePermanent, 'Erro de autenticação não foi classificado como permanente');
    Check(Router.ClassifyError('HTTP 503 timeout', False, False) =
      aieTransient, 'Erro temporário não foi classificado como transitório');
    Check(not Router.MayRetry(aiePermanent, 0),
      'Erro permanente não pode gerar retry');
    Check(Router.SplitTriage('linha um'#10'linha dois'#10'linha três', 8,
      Estimator, Parts, Overflow) and (Parts.Count >= 2),
      'Triagem acima do orçamento não foi dividida por linhas');
    Check(Router.RegisterFingerprint(Router.TaskFingerprint('mesma tarefa')) and
      (not Router.RegisterFingerprint(Router.TaskFingerprint('mesma tarefa'))),
      'Detector de repetição lógica não bloqueou fingerprint repetido');
    Check(Router.ValidateArbitration('{"executavel":"reorientar"}',
      Verdict, Reason) and (Verdict = 'executavel'),
      'Contrato válido de arbitragem foi recusado: ' + Reason);
    Check(not Router.ValidateArbitration('{"abortar":"x"}', Verdict, Reason),
      'Segunda arbitragem na mesma sessão deveria ser recusada');

    Step := Session.AddStep(airTriage, 'request', 0, 12, 5, 2000, 1,
      'token=segredo pedido', Router.TaskFingerprint('pedido'));
    Session.FinishStep(Step, 'completed', 'resumo', '', 15);
    Step := Session.AddStep(airLightWork, 'answer', 1, 20, 10, 4000, 1,
      'contexto', Router.TaskFingerprint('resposta'));
    Session.FinishStep(Step, 'failed', '', 'password=segredo', 20);
    SessionJSON := Session.AsJSON;
    Check((Pos('segredo', SessionJSON) = 0) and
      LoadedSession.LoadJSON(SessionJSON) and
      (LoadedSession.Count = 2) and (LoadedSession[1].ParentOrder = 1),
      'Sessão não redigiu segredo ou não reconstruiu OrdemPai');

    BusMessage := Bus.Ask(airManagement, airDatabase, 'liste tabelas',
      'somente metadados', 0.8, 1, 1, 1, 'management', Reason);
    Check((BusMessage <> nil) and (BusMessage.Status = 'queued'),
      'Relação permitida no barramento foi recusada: ' + Reason);
    Check(Bus.Ask(airTriage, airLightWork, 'delegar', '', 0.5, 1, 1, 1,
      'triage', Reason) = nil,
      'Triagem não pode delegar no barramento');
    Check(Bus.Ask(airDatabase, airLightWork, 'voltar', '', 0.5, 1, 2, 2,
      'database>light_work', Reason) = nil,
      'Ciclo A-B-A deveria ser recusado antes de qualquer chamada');
  finally
    Bus.Free;
    LoadedSession.Free;
    Session.Free;
    Parts.Free;
    Estimator.Free;
    Router.Free;
  end;
end;

procedure TestAIActions;
var
  Root, SourceFile, SecretFile, OutsideFile, ResultJSON, ErrorText: string;
  Executor: TMNoteAIActionExecutor;
  Observer: TActionObserver;
begin
  Root := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'ai_action_fixture';
  SourceFile := IncludeTrailingPathDelimiter(Root) + 'sample.pas';
  SecretFile := IncludeTrailingPathDelimiter(Root) + '.env';
  OutsideFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'outside-action.txt';
  ForceDirectories(Root);
  SaveFixtureText(SourceFile, 'unit sample;'#10'interface'#10+
    'procedure NeedleAction;'#10'implementation'#10+
    'procedure NeedleAction; begin end;'#10'end.');
  SaveFixtureText(SecretFile, 'TOKEN=nao-pode-vazar');
  SaveFixtureText(OutsideFile, 'fora');
  Executor := TMNoteAIActionExecutor.Create(Root);
  Observer := TActionObserver.Create;
  try
    Check(Pos('"simulated"', Executor.DescribeActions) = 0,
      'Catálogo de ações não deve anunciar simulação');
    Check(Executor.ExecuteRequest(
      '{"action":"ReadFile","parameters":{"path":"sample.pas"}}',
      airLightWork, ResultJSON, ErrorText) and
      (Pos('NeedleAction', ResultJSON) > 0) and
      (Pos('false', ResultJSON) > 0),
      'ReadFile não devolveu o conteúdo real da fixture: ' + ErrorText);
    Check(not Executor.ExecuteRequest(
      '{"action":"ReadFile","parameters":{"path":"..\\outside-action.txt"}}',
      airLightWork, ResultJSON, ErrorText),
      'ReadFile aceitou caminho fora da raiz do projeto');
    Check(not Executor.ExecuteRequest(
      '{"action":"ReadFile","parameters":{"path":".env"}}',
      airLightWork, ResultJSON, ErrorText) and
      (Pos('nao-pode-vazar', ResultJSON) = 0),
      'ReadFile expôs arquivo sensível');
    Check(not Executor.ExecuteRequest(
      'antes {"action":"ReadFile","parameters":{"path":"sample.pas"}}',
      airLightWork, ResultJSON, ErrorText),
      'Parser aceitou texto misturado ao JSON da ação');
    Check(not Executor.ExecuteRequest(
      '{"action":"ReadFile","parameters":{"path":"sample.pas","shell":"x"}}',
      airLightWork, ResultJSON, ErrorText),
      'Executor aceitou parâmetro não declarado');
    Check(not Executor.ExecuteRequest(
      '{"action":"ReadFile","parameters":{"path":"sample.pas"}}',
      airTriage, ResultJSON, ErrorText),
      'Papel de triagem executou uma ferramenta');
    Check(Executor.ExecuteRequest(
      '{"action":"SearchProject","parameters":{"query":"NeedleAction","include":"*.pas","max_results":10}}',
      airLightWork, ResultJSON, ErrorText) and
      (Pos('sample.pas', ResultJSON) > 0),
      'SearchProject não encontrou a fixture real: ' + ErrorText);
    Check(Executor.ExecuteRequest(
      '{"action":"ListSymbols","parameters":{"max_results":20}}',
      airLightWork, ResultJSON, ErrorText) and
      (Pos('NeedleAction', ResultJSON) > 0),
      'ListSymbols não indexou a fixture Pascal: ' + ErrorText);
    Check(Executor.ExecuteRequest(
      '{"action":"ListProjectFiles","parameters":{"include":"*.pas","max_results":20}}',
      airManagement, ResultJSON, ErrorText) and
      (Pos('sample.pas', ResultJSON) > 0) and
      (Pos('.env', ResultJSON) = 0),
      'ListProjectFiles não listou a fixture segura: ' + ErrorText);
    ForceDirectories(IncludeTrailingPathDelimiter(Root) + 'restricted');
    Executor.Safety.SafeBasePath := IncludeTrailingPathDelimiter(Root) +
      'restricted';
    Check(not Executor.ExecuteRequest(
      '{"action":"ReadFile","parameters":{"path":"sample.pas"}}',
      airLightWork, ResultJSON, ErrorText) and
      (Pos('Agent Safety', ErrorText) > 0),
      'A camada Agent Safety não participou da recusa por raiz segura');
    Executor.Safety.SafeBasePath := Root;
    Check(not Executor.ExecuteRequest(
      '{"action":"GitDiff","parameters":{"commit":"--help"}}',
      airLightWork, ResultJSON, ErrorText),
      'GitDiff aceitou identificador capaz de injetar opção');
    Executor.OnConfirm := @Observer.Reject;
    Check(not Executor.ExecuteRequest(
      '{"action":"Compile","parameters":{"rebuild":false}}',
      airLightWork, ResultJSON, ErrorText) and
      (Pos('confirmação recusada', ErrorText) > 0),
      'Compile não respeitou a confirmação obrigatória');
  finally
    Observer.Free;
    Executor.Free;
    DeleteFile(SourceFile);
    DeleteFile(SecretFile);
    DeleteFile(OutsideFile);
    RemoveDir(IncludeTrailingPathDelimiter(Root) + 'restricted');
    RemoveDir(Root);
  end;
end;

procedure TestIntegratedCapabilities;
var
  Root, UnitA, UnitB, ProjectFile, InventoryFile, TextFile, PDFFile: string;
  Inventory: TMNoteProjectInventoryService;
  Exporter: TMNoteDocumentExportService;
  Catalog: TMNoteCapabilityCatalog;
  Capability: TMNoteCapability;
  GraphService: TMNoteDependencyGraphService;
  ProjectService: TMNoteProjectService;
  SQLValidator: TMNoteSQLValidationService;
  TaskOne, TaskTwo: TJSONObject;
  Deadline: QWord;
  I: Integer;
  FoundFiles, FoundOutput, FoundGraph, FoundOptional: Boolean;
  Stream: TFileStream;
  Header: string;
begin
  Root := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'integrated_capabilities_fixture';
  UnitA := IncludeTrailingPathDelimiter(Root) + 'unit_a.pas';
  UnitB := IncludeTrailingPathDelimiter(Root) + 'unit_b.pas';
  ProjectFile := IncludeTrailingPathDelimiter(Root) + 'fixture.mnoteproj.json';
  TextFile := IncludeTrailingPathDelimiter(Root) + 'report.txt';
  PDFFile := IncludeTrailingPathDelimiter(Root) + 'report.pdf';
  RemoveFixtureTree(Root);
  ForceDirectories(Root);
  SaveFixtureText(UnitA, 'unit Unit_A;'#10+'interface'#10+
    'uses Unit_B;'#10+'implementation'#10+'end.');
  SaveFixtureText(UnitB, 'unit Unit_B;'#10+'interface'#10+
    'implementation'#10+'end.');

  ProjectService := TMNoteProjectService.Create;
  Inventory := TMNoteProjectInventoryService.Create;
  Exporter := TMNoteDocumentExportService.Create;
  Catalog := TMNoteCapabilityCatalog.Create;
  GraphService := TMNoteDependencyGraphService.Create;
  SQLValidator := TMNoteSQLValidationService.Create;
  try
    ProjectService.NewProject('Fixture integrada', Root);
    Check(ProjectService.Tasks.AddTask('Tarefa A', 'fixture', 'normal',
      'DEV', '', 1) = 'T001', 'Não foi possível criar tarefa A da fixture');
    Check(ProjectService.Tasks.AddTask('Tarefa B', 'fixture', 'normal',
      'QA', '', 1) = 'T002', 'Não foi possível criar tarefa B da fixture');
    TaskOne := ProjectService.Tasks.GetTaskByID('T001');
    TaskTwo := ProjectService.Tasks.GetTaskByID('T002');
    TaskOne.Arrays['dependencies'].Add('T002');
    TaskOne.Arrays['exclusive_files'].Add('src/shared.pas');
    TaskTwo.Arrays['exclusive_files'].Add('src/shared.pas');
    Check(ProjectService.SaveAs(ProjectFile),
      'Projeto da fixture não foi salvo: ' + ProjectService.LastError);

    Inventory.Scanner.ReturnOnMainThread := False;
    Check(Inventory.StartScan(Root),
      'TAIDiskTreeScanner não iniciou: ' + Inventory.LastError);
    Deadline := GetTickCount64 + 10000;
    while Inventory.Scanner.IsBusy and (GetTickCount64 < Deadline) do
      Sleep(10);
    Check(not Inventory.Scanner.IsBusy,
      'TAIDiskTreeScanner não concluiu no limite da fixture');
    Check(Inventory.Scanner.ResultCount >= 3,
      'TAIDiskTreeScanner não inventariou os arquivos reais');
    Check(Inventory.SaveDocumentationSnapshot(InventoryFile) and
      FileExists(InventoryFile),
      'TAI_DOCFILESMANAGER não salvou o inventário: ' + Inventory.LastError);

    Check(Exporter.ExportDocument('Relatório integrado',
      'conteúdo UTF-8 verificável', TextFile, mdfText) and FileExists(TextFile),
      'TAIOutputDocs não gerou TXT: ' + Exporter.LastError);
    Check(Pos('conteúdo UTF-8 verificável', LoadFixtureText(TextFile)) > 0,
      'TXT gerado não contém os dados esperados');
    Check(Exporter.ExportDocument('Relatório integrado',
      'conteúdo PDF verificável', PDFFile, mdfPDF) and FileExists(PDFFile),
      'TAIOutputDocs não gerou PDF: ' + Exporter.LastError);
    Stream := TFileStream.Create(PDFFile, fmOpenRead or fmShareDenyNone);
    try
      SetLength(Header, 4);
      Stream.ReadBuffer(Header[1], 4);
    finally
      Stream.Free;
    end;
    Check(Header = '%PDF', 'PDF gerado não possui cabeçalho PDF real');

    Catalog.Refresh(True);
    FoundFiles := False; FoundOutput := False; FoundGraph := False;
    FoundOptional := False;
    for I := 0 to Catalog.Items.Count - 1 do
    begin
      Capability := TMNoteCapability(Catalog.Items[I]);
      if SameText(Capability.PackageName, 'openai_files') and
        (Capability.State = mcsIntegrated) then FoundFiles := True;
      if SameText(Capability.PackageName, 'openai_output') and
        (Capability.State = mcsIntegrated) then FoundOutput := True;
      if SameText(Capability.PackageName, 'openai_graphcore') and
        (Capability.State = mcsIntegrated) then FoundGraph := True;
      if SameText(Capability.Name, 'TAIPipeline') and
        (Capability.State = mcsOptional) then FoundOptional := True;
    end;
    Check(FoundFiles and FoundOutput and FoundGraph and FoundOptional,
      'Catálogo não distingue integrações reais e pacote pesado opcional');

    Check(GraphService.Build(Root),
      'Grafo factual não validou: ' + GraphService.LastError);
    Check((GraphService.Graph.Edges.Count > 0) and
      (GraphService.Graph.InferredEdges.Count > 0) and
      (Pos('ARESTAS FACTUAIS', GraphService.AsText) > 0) and
      (Pos('ARESTAS INFERIDAS', GraphService.AsText) > 0),
      'Dependency Graph não separou evidência factual e inferida');

    Check(SQLValidator.ValidatePlaceholders(
      'SELECT * FROM users WHERE id = $1', 'postgresql'),
      'Placeholder PostgreSQL válido foi recusado');
    Check(not SQLValidator.ValidatePlaceholders(
      'SELECT * FROM users WHERE id = ?', 'postgresql'),
      'Placeholder MySQL foi aceito como PostgreSQL');
    Check(SQLValidator.ValidatePlaceholders(
      'SELECT * FROM users WHERE id = ?', 'mysql'),
      'Placeholder MySQL válido foi recusado');
    Check(SQLValidator.ValidatePlaceholders(
      'SELECT * FROM users WHERE id = :id', 'sqlite-3'),
      'Placeholder SQLite nomeado foi recusado');
  finally
    SQLValidator.Free;
    GraphService.Free;
    Catalog.Free;
    Exporter.Free;
    Inventory.Free;
    ProjectService.Free;
    RemoveFixtureTree(Root);
  end;
end;

procedure TestNeuralApiBootstrap;
const
  ContentsJSON =
    '[' +
    '{"name":"neural-api-setup-2.9.exe","type":"file","size":10,' +
      '"sha":"1111111111111111111111111111111111111111",' +
      '"download_url":"https://raw.githubusercontent.com/marcelomaurin/neural-api/master/bin/neural-api-setup-2.9.exe"},' +
    '{"name":"neural-api-setup-2.10.exe","type":"file","size":18,' +
      '"sha":"542608d621468510258166510c45164956338fde",' +
      '"download_url":"https://raw.githubusercontent.com/marcelomaurin/neural-api/master/bin/neural-api-setup-2.10.exe"},' +
    '{"name":"neural-api-setup-99.exe","type":"file","size":10,' +
      '"sha":"9999999999999999999999999999999999999999",' +
      '"download_url":"https://example.invalid/setup.exe"},' +
    '{"name":"readme.txt","type":"file","size":10,' +
      '"sha":"2222222222222222222222222222222222222222",' +
      '"download_url":"https://raw.githubusercontent.com/marcelomaurin/neural-api/master/bin/readme.txt"}' +
    ']';
var
  Name, URL, GitSHA, Root, ExecutableFile, NeuralFolder, FixtureFile: string;
  Size: Int64;
begin
  Check(TMNoteNeuralApiBootstrap.SelectLatestInstaller(ContentsJSON,
    Name, URL, GitSHA, Size),
    'Descoberta não encontrou um instalador válido na pasta bin');
  Check((Name = 'neural-api-setup-2.10.exe') and (Size = 18) and
    (GitSHA = '542608d621468510258166510c45164956338fde') and
    (Pos('raw.githubusercontent.com/marcelomaurin/neural-api/', URL) > 0),
    'Descoberta não selecionou a versão semântica mais recente e confiável');
  Check(not TMNoteNeuralApiBootstrap.SelectLatestInstaller('{}',
    Name, URL, GitSHA, Size),
    'Resposta sem lista de arquivos deveria ser recusada');

  Root := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'neural_api_bootstrap_fixture';
  ExecutableFile := IncludeTrailingPathDelimiter(Root) + 'MNote2.exe';
  NeuralFolder := IncludeTrailingPathDelimiter(Root) + 'neural-api';
  FixtureFile := IncludeTrailingPathDelimiter(Root) + 'installer.exe';
  RemoveFixtureTree(Root);
  ForceDirectories(Root);
  try
    Check(not TMNoteNeuralApiBootstrap.IsInstalledAt(ExecutableFile),
      'Pasta neural-api ausente foi detectada como instalada');
    ForceDirectories(NeuralFolder);
    Check(TMNoteNeuralApiBootstrap.IsInstalledAt(ExecutableFile),
      'Pasta neural-api ao lado do executável não foi detectada');
    SaveFixtureText(FixtureFile, 'fixture neural api');
    Check(TMNoteNeuralApiBootstrap.VerifyGitBlob(FixtureFile,
      '542608d621468510258166510c45164956338fde', 18),
      'Validação de tamanho e Git blob SHA-1 recusou a fixture íntegra');
    Check(not TMNoteNeuralApiBootstrap.VerifyGitBlob(FixtureFile,
      '542608d621468510258166510c45164956338fde', 17),
      'Validação de integridade aceitou tamanho divergente');
  finally
    RemoveFixtureTree(Root);
  end;
end;

var
  CommandRegistry: TMNoteCommandRegistry;
  CommandObserver: TCommandObserver;
  SearchService: TMNoteTextSearchService;
  SearchResults: TMNoteSearchResults;
  SearchOptions: TMNoteSearchOptions;
  ReplacedText: string;
  ReplaceCount: Integer;
  FileSearchService: TMNoteFileSearchService;
  FileSearchResults: TMNoteSearchResults;
  FileSearchRoot, BackupRoot: string;
  FileReplaceService: TMNoteFileReplaceService;
  FileReplacePreview: TMNoteFileReplacePreview;
  FileApplyObserver: TFileApplyObserver;
  FilesChanged, Replacements: Integer;
  FirstReplaceFile, SecondReplaceFile: string;
  LanguageRegistry: TMNoteLanguageRegistry;
  LanguageProfile: TMNoteLanguageProfile;
  CommentedText: string;
  ThemeService: TMNoteEditorThemeService;
  InvalidThemeFile, DarkThemeFile: string;

begin
  try
    TestNeuralApiBootstrap;
    Writeln('OK: descoberta, pasta e integridade do instalador neural-api');
    TestProjectCore;
    TestProjectContext;
    Writeln('OK: contexto integrado de projeto e compatibilidade legado/Lazarus');
    Writeln('OK: projeto, tarefas, ações, dependências e exportação');
    TestAIPlanContract;
    Writeln('OK: Entender, contrato de plano, revisão e confirmação');
    TestSourceChanges;
    Writeln('OK: diff, segurança, apply atômico, seleção e rollback');
    TestTaskFlowAndGit;
    Writeln('OK: fluxo de tarefa e Git somente leitura');
    TestEndToEndTaskExecution;
    Writeln('OK: ciclo integrado projeto, tarefa, proposta, apply, teste e conclusao');
    TestTaskCommentIndex;
    Writeln('OK: índice TODO/FIXME/HACK/NOTE configurável');
    TestDiagnosticsAndOutput;
    Writeln('OK: diagnósticos e canais independentes de saída');
    TestProcessService;
    Writeln('OK: processo, stdout/stderr e timeout');
    TestBuildPreparation;
    Writeln('OK: seleção automática de perfil Build/Rebuild');
    TestMultiAICore;
    TestAIActions;
    Writeln('OK: ações reais, permissões, limites e confirmação');
    Writeln('OK: perfis, router, sessão, arbitragem e barramento multi-IA');
    TestIntegratedCapabilities;
    Writeln('OK: Files, documentação, OutputDocs, grafo, catálogo e SQL');
    Check(1 + 1 = 2, 'Falha no teste mínimo do runner');
    Writeln('OK: teste mínimo');
    Check(Ord(twkSolution) = 0, 'Enumeração de tool windows perdeu a ordem inicial');
    Check(Ord(twkTaskList) = 13, 'Enumeração de tool windows está incompleta');
    Writeln('OK: TMNoteToolWindowKind');
    with TMNoteToolWindowManager.Create do
    try
      with TToolWindowObserver.Create do
      try
        OnVisibilityChanged := @HandleVisibility;
        Check(not IsVisible(twkAI), 'Janela deveria iniciar oculta');
        Show(twkAI);
        Check(IsVisible(twkAI), 'Show não exibiu a janela');
        Check((CallCount = 1) and (LastKind = twkAI) and LastVisible,
          'Evento de exibição incorreto');
        Show(twkAI);
        Check(CallCount = 1, 'Show repetido não deve disparar mudança');
        Toggle(twkAI);
        Check(not IsVisible(twkAI), 'Toggle não ocultou a janela');
        Check((CallCount = 2) and (not LastVisible),
          'Evento de ocultação incorreto');
      finally
        Free;
      end;
    finally
      Free;
    end;
    Writeln('OK: TMNoteToolWindowManager');
    CommandRegistry := TMNoteCommandRegistry.Create;
    try
      CommandObserver := TCommandObserver.Create;
      try
        CommandRegistry.RegisterCommand('test.run', 'Executar teste', 'Testes',
          0, @CommandObserver.Execute);
        Check(CommandRegistry.Count = 1,
          'Registro de comando não preservou a contagem');
        Check(CommandRegistry.Find('TEST.RUN') <> nil,
          'Busca de comando deve ignorar caixa');
        Check(CommandRegistry.Execute('test.run', CommandRegistry),
          'Comando habilitado não executou');
        Check(CommandObserver.Executed = 1,
          'Handler do comando não foi chamado');
        CommandRegistry.Commands[0].Enabled := False;
        Check(not CommandRegistry.Execute('test.run', CommandRegistry),
          'Comando desabilitado foi executado');
      finally
        CommandObserver.Free;
      end;
    finally
      CommandRegistry.Free;
    end;
    Writeln('OK: TMNoteCommandRegistry');
    Check(TMNoteFuzzyMatcher.Score('salvar tudo', 'Salvar Tudo') >
      TMNoteFuzzyMatcher.Score('salvar', 'Salvar Tudo'),
      'Correspondência exata deve superar um prefixo');
    Check(TMNoteFuzzyMatcher.Score('salvar', 'Salvar Tudo') >
      TMNoteFuzzyMatcher.Score('st', 'Salvar Tudo'),
      'Prefixo deve superar uma subsequência');
    Check(TMNoteFuzzyMatcher.Score('xyz', 'Salvar Tudo') = -1,
      'Texto sem correspondência não deve ser aceito');
    Check(TMNoteFuzzyMatcher.Score('svt', 'Salvar Tudo') =
      TMNoteFuzzyMatcher.Score('svt', 'Salvar Tudo'),
      'Ranking fuzzy deve ser determinístico');
    Writeln('OK: TMNoteFuzzyMatcher');
    SearchService := TMNoteTextSearchService.Create;
    SearchResults := TMNoteSearchResults.Create;
    try
      SearchOptions := DefaultSearchOptions;
      Check(SearchService.SearchText('alfa beta alfa', 'alfa',
        'fixture.txt', SearchOptions, SearchResults),
        'Busca literal retornou erro');
      Check((SearchResults.Count = 2) and (SearchResults[0].Column = 1) and
        (SearchResults[1].Column = 11),
        'Busca literal não encontrou início e fim corretamente');
      Check(SearchService.SearchText('início'#13#10'meio café fim'#10+
        'id id_usuario ID', 'CAFÉ', 'utf8.txt', SearchOptions,
        SearchResults), 'Busca UTF-8 insensitive retornou erro');
      Check((SearchResults.Count = 1) and (SearchResults[0].Line = 2) and
        (SearchResults[0].Column = 6) and (SearchResults[0].Length = 4),
        'Linha e coluna UTF-8/CRLF estão incorretas');
      SearchOptions.WholeWord := True;
      Check(SearchService.SearchText('id id_usuario ID', 'id', 'word.txt',
        SearchOptions, SearchResults) and (SearchResults.Count = 2),
        'Whole Word confundiu id com id_usuario');
      SearchOptions.RegularExpression := True;
      SearchOptions.WholeWord := False;
      Check(SearchService.ReplaceText('café fim', '(café) (fim)', '$2-$1',
        SearchOptions, ReplacedText, ReplaceCount) and
        (ReplacedText = 'fim-café') and (ReplaceCount = 1),
        'Replace regex não preservou grupos de captura');
      Check(SearchService.ResolveReplacement('café fim', '(café) (fim)',
        '$2-$1', SearchOptions, ReplacedText) and
        (ReplacedText = 'fim-café'),
        'Replace da ocorrência atual não resolveu grupos de captura');
      Check(not SearchService.SearchText('texto', '[', 'regex.txt',
        SearchOptions, SearchResults),
        'Regex inválida deveria retornar falha');
      Check(SearchService.LastError <> '',
        'Regex inválida não informou LastError');
      SearchResults.Clear;
      Check(SearchResults.Count = 0,
        'Clear não liberou a coleção de resultados');
    finally
      SearchResults.Free;
      SearchService.Free;
    end;
    Writeln('OK: TMNoteTextSearchService');
    FileSearchRoot := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'file_search_fixture';
    BackupRoot := IncludeTrailingPathDelimiter(FileSearchRoot) + 'backup';
    ForceDirectories(BackupRoot);
    try
      SaveFixtureText(IncludeTrailingPathDelimiter(FileSearchRoot) +
        'one.pas', 'unit one;'#10'// needle');
      SaveFixtureText(IncludeTrailingPathDelimiter(FileSearchRoot) +
        'two.txt', 'needle em arquivo fora do include');
      SaveFixtureText(IncludeTrailingPathDelimiter(BackupRoot) +
        'hidden.pas', 'needle excluído');
      SaveFixtureText(IncludeTrailingPathDelimiter(FileSearchRoot) +
        'binary.pas', 'abc'#0'needle');
      FileSearchService := TMNoteFileSearchService.Create;
      FileSearchResults := TMNoteSearchResults.Create;
      try
        SearchOptions := DefaultSearchOptions;
        SearchOptions.IncludePatterns := '*.pas';
        SearchOptions.ExcludePatterns := '!backup/**';
        Check(FileSearchService.SearchFolder(FileSearchRoot, 'needle',
          SearchOptions, FileSearchResults),
          'Busca em arquivos retornou erro: ' + FileSearchService.LastError);
        Check((FileSearchResults.Count = 1) and
          (ExtractFileName(FileSearchResults[0].FileName) = 'one.pas') and
          (FileSearchResults[0].Line = 2),
          'Include, exclude ou detecção de binário falhou');
        Check(FileSearchService.StartSearch(FileSearchRoot, 'needle',
          SearchOptions, FileSearchResults),
          'Busca assíncrona não iniciou');
        FileSearchService.Cancel;
        FileSearchService.WaitFor;
        Check(not FileSearchService.IsRunning,
          'Cancelamento não encerrou a busca assíncrona');
      finally
        FileSearchResults.Free;
        FileSearchService.Free;
      end;
    finally
      DeleteFile(IncludeTrailingPathDelimiter(FileSearchRoot) + 'one.pas');
      DeleteFile(IncludeTrailingPathDelimiter(FileSearchRoot) + 'two.txt');
      DeleteFile(IncludeTrailingPathDelimiter(FileSearchRoot) + 'binary.pas');
      DeleteFile(IncludeTrailingPathDelimiter(BackupRoot) + 'hidden.pas');
      RemoveDir(BackupRoot);
      RemoveDir(FileSearchRoot);
    end;
    Writeln('OK: TMNoteFileSearchService');
    FileSearchRoot := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'file_replace_fixture';
    ForceDirectories(FileSearchRoot);
    FirstReplaceFile := IncludeTrailingPathDelimiter(FileSearchRoot) + 'a.txt';
    SecondReplaceFile := IncludeTrailingPathDelimiter(FileSearchRoot) + 'b.txt';
    try
      SaveFixtureText(FirstReplaceFile, 'alpha em a');
      SaveFixtureText(SecondReplaceFile, 'alpha em b');
      FileSearchService := TMNoteFileSearchService.Create;
      FileSearchResults := TMNoteSearchResults.Create;
      FileReplaceService := TMNoteFileReplaceService.Create;
      FileReplacePreview := TMNoteFileReplacePreview.Create;
      FileApplyObserver := TFileApplyObserver.Create;
      try
        SearchOptions := DefaultSearchOptions;
        SearchOptions.IncludePatterns := '*.txt';
        SearchOptions.ExcludePatterns := '';
        Check(FileSearchService.SearchFolder(FileSearchRoot, 'alpha',
          SearchOptions, FileSearchResults),
          'Busca para preview de substituição falhou');
        Check(FileReplaceService.BuildPreview('alpha', 'beta', SearchOptions,
          FileSearchResults, FileReplacePreview) and
          (FileReplacePreview.Count = 2),
          'Preview de Replace in Files não agrupou os arquivos');
        FileReplacePreview[1].Enabled := False;
        Check(FileReplaceService.ApplyPreview(FileReplacePreview,
          FilesChanged, Replacements) and (FilesChanged = 1) and
          (Replacements = 1),
          'Aplicação seletiva do preview falhou');
        Check((LoadFixtureText(FirstReplaceFile) = 'beta em a') and
          (LoadFixtureText(SecondReplaceFile) = 'alpha em b'),
          'Arquivo desmarcado no preview foi alterado');

        SaveFixtureText(FirstReplaceFile, 'alpha em a');
        SaveFixtureText(SecondReplaceFile, 'alpha em b');
        Check(FileSearchService.SearchFolder(FileSearchRoot, 'alpha',
          SearchOptions, FileSearchResults) and
          FileReplaceService.BuildPreview('alpha', 'beta', SearchOptions,
            FileSearchResults, FileReplacePreview),
          'Segundo preview para rollback falhou');
        FileApplyObserver.RejectIndex := 1;
        FileReplaceService.OnBeforeApplyFile := @FileApplyObserver.BeforeApply;
        Check(not FileReplaceService.ApplyPreview(FileReplacePreview,
          FilesChanged, Replacements),
          'Falha controlada no segundo arquivo deveria cancelar a aplicação');
        Check((LoadFixtureText(FirstReplaceFile) = 'alpha em a') and
          (LoadFixtureText(SecondReplaceFile) = 'alpha em b'),
          'Rollback não restaurou o primeiro arquivo');
      finally
        FileApplyObserver.Free;
        FileReplacePreview.Free;
        FileReplaceService.Free;
        FileSearchResults.Free;
        FileSearchService.Free;
      end;
    finally
      DeleteFile(FirstReplaceFile);
      DeleteFile(SecondReplaceFile);
      RemoveDir(FileSearchRoot);
    end;
    Writeln('OK: TMNoteFileReplaceService');
    LanguageRegistry := TMNoteLanguageRegistry.Create(True);
    try
      LanguageProfile := LanguageRegistry.FindByExtension('.pas');
      Check((LanguageProfile <> nil) and
        (LanguageProfile.ID = 'pascal') and
        (LanguageProfile.TabWidth = 2),
        'Perfil Pascal não foi criado corretamente');
      Check(LanguageRegistry.FindByExtension('.py').ID = 'python',
        'Registro não resolveu Python');
      Check(LanguageRegistry.FindByExtension('.sql').ID = 'sql',
        'Registro não resolveu SQL');
      Check(LanguageRegistry.FindByExtension('.js').ID = 'javascript',
        'Registro não resolveu JavaScript');
      Check(LanguageRegistry.FindByExtension('.md').ID = 'markdown',
        'Registro não resolveu Markdown');
      CommentedText := TMNoteEditorOptions.ToggleLineComments(
        'begin'#10'  Run;', LanguageProfile);
      Check(CommentedText = '// begin'#10'  // Run;',
        'Comentário Pascal não respeitou indentação');
      Check(TMNoteEditorOptions.ToggleLineComments(CommentedText,
        LanguageProfile) = 'begin'#10'  Run;',
        'Descomentário Pascal não restaurou a fixture');
      Check(Pos('# print', TMNoteEditorOptions.ToggleLineComments('print',
        LanguageRegistry.FindByID('python'))) = 1,
        'Comentário Python incorreto');
      Check(Pos('-- SELECT', TMNoteEditorOptions.ToggleLineComments('SELECT',
        LanguageRegistry.FindByID('sql'))) = 1,
        'Comentário SQL incorreto');
      Check(Pos('// const x', TMNoteEditorOptions.ToggleLineComments('const x',
        LanguageRegistry.FindByID('javascript'))) = 1,
        'Comentário JavaScript incorreto');
    finally
      LanguageRegistry.Free;
    end;
    Writeln('OK: TMNoteLanguageRegistry e opções editoriais');
    ThemeService := TMNoteEditorThemeService.Create;
    InvalidThemeFile := IncludeTrailingPathDelimiter(
      ExtractFilePath(ParamStr(0))) + 'invalid-theme.json';
    try
      DarkThemeFile := ExpandFileName(IncludeTrailingPathDelimiter(
        ExtractFilePath(ParamStr(0))) + '..\..\themes\dark.json');
      Check(ThemeService.LoadFromFile(DarkThemeFile) and
        (ThemeService.Current.Name = 'Dark'),
        'Tema Dark versionado não foi carregado');
      SaveFixtureText(InvalidThemeFile, '{tema inválido');
      Check(not ThemeService.LoadFromFile(InvalidThemeFile),
        'JSON de tema inválido deveria ativar fallback');
      Check((ThemeService.Current.Name = 'Light') and
        (ThemeService.LastError <> ''),
        'Tema inválido não aplicou fallback com erro registrado');
    finally
      DeleteFile(InvalidThemeFile);
      ThemeService.Free;
    end;
    Writeln('OK: TMNoteEditorThemeService');
    TestCompletion;
    Writeln('OK: completion local, parser, snippets e índice de símbolos');
    TestAIUtilities;
    Writeln('OK: prompt, estimativa de contexto e palavra de ativação');
    with TTestService.Create do
    try
      with TErrorObserver.Create do
      try
        OnError := @HandleError;
        Fail('erro de teste');
        Check(LastError = 'erro de teste', 'LastError não foi atualizado');
        Check(CallCount = 1, 'OnError não foi chamado exatamente uma vez');
        Check(MessageText = LastError, 'OnError recebeu uma mensagem diferente');
        ClearError;
        Check(LastError = '', 'ClearError não limpou LastError');
      finally
        Free;
      end;
    finally
      Free;
    end;
    Writeln('OK: TMNoteServiceBase');
    Halt(0);
  except
    on E: Exception do
    begin
      Writeln(StdErr, 'FALHA: ', E.Message);
      Halt(1);
    end;
  end;
end.
