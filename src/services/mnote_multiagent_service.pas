unit mnote_multiagent_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, jsonparser,
  aiagent_deterministicmemory, aiagent_capabilityrouter, aiagent_supervisor,
  mnote_ai_types;

type
  TMNoteRecoveryAction = (mraFinish, mraRetrySame, mraSwitchAgent,
    mraEscalateStrong, mraAbort);
  TMNoteLearningMode = (mlmNone, mlmRAG, mlmLoRA, mlmRAGAndLoRA);

  TMNoteMultiAgentDecision = record
    Qualification: TAITaskQualification;
    Route: TAIAgentRouteDecision;
    Role: TMNoteAIRole;
    SimilarEvidence: Integer;
    EscalatedToStrong: Boolean;
  end;

  TMNoteSupervisorNextStep = record
    Action: TMNoteRecoveryAction;
    LearningMode: TMNoteLearningMode;
    NextDecision: TMNoteMultiAgentDecision;
    Reason: string;
  end;

  TMNoteMultiAgentService = class
  private
    FWorkspaceRoot: string;
    FRegistry: TAIAgentMemoryRegistry;
    FRouter: TAIAgentCapabilityRouter;
    FSupervisor: TAIStrongSupervisor;
    FLastDecision: TMNoteMultiAgentDecision;
    FLastReview: TAISupervisorReview;
    FLastReviewText: string;
    FLastNextStep: TMNoteSupervisorNextStep;
    FLastError: string;
    procedure RebuildRouter;
    function AgentRole(const AAgentId: string): TMNoteAIRole;
    function BoolJSON(O: TJSONObject; const N: string; D: Boolean): Boolean;
    function FloatJSON(O: TJSONObject; const N: string; D: Double): Double;
    function IntJSON(O: TJSONObject; const N: string; D: Integer): Integer;
    function StringJSON(O: TJSONObject; const N, D: string): string;
    function StrongDecision: TMNoteMultiAgentDecision;
    function LearningModeForFailure: TMNoteLearningMode;
    procedure QueueLearningCase(const AInstruction, AExecutionOutput: string;
      const AStep: TMNoteSupervisorNextStep);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ConfigureWorkspace(const ARoot: string);
    function Qualify(const AInstruction, AFileName: string): TAITaskQualification;
    function SelectAgent(const AInstruction, AFileName: string;
      out ADecision: TMNoteMultiAgentDecision): Boolean;
    function ReviewAndRecord(const AInstruction, AExecutionOutput: string;
      ABuildPassed, ATestsPassed: Boolean; ARetries: Integer): Boolean;
    function DecideNextStep(const AInstruction, AFileName,
      AExecutionOutput: string; AAttempt, AMaxAttempts: Integer): TMNoteSupervisorNextStep;
    procedure AdoptDecision(const ADecision: TMNoteMultiAgentDecision);
    function DecisionText: string;
    function ReviewText: string;
    function NextStepText: string;
    property LastDecision: TMNoteMultiAgentDecision read FLastDecision;
    property LastReview: TAISupervisorReview read FLastReview;
    property LastNextStep: TMNoteSupervisorNextStep read FLastNextStep;
    property LastError: string read FLastError;
  end;

procedure InitializeMNoteMultiAgent;
procedure FinalizeMNoteMultiAgent;
function MNoteMultiAgent: TMNoteMultiAgentService;

implementation

uses
  mnote_ai_service, mnote_ai_profile;

var
  GMultiAgent: TMNoteMultiAgentService = nil;

function HasAny(const Text: string; const Words: array of string): Boolean;
var I: Integer; L: string;
begin
  L := LowerCase(Text);
  for I := Low(Words) to High(Words) do
    if Pos(LowerCase(Words[I]), L) > 0 then Exit(True);
  Result := False;
end;

function RecoveryActionName(A: TMNoteRecoveryAction): string;
begin
  case A of
    mraRetrySame: Result := 'retry_same';
    mraSwitchAgent: Result := 'switch_agent';
    mraEscalateStrong: Result := 'escalate_strong';
    mraAbort: Result := 'abort';
  else Result := 'finish'; end;
end;

function LearningModeName(A: TMNoteLearningMode): string;
begin
  case A of
    mlmRAG: Result := 'rag';
    mlmLoRA: Result := 'lora';
    mlmRAGAndLoRA: Result := 'rag+lora';
  else Result := 'none'; end;
end;

constructor TMNoteMultiAgentService.Create;
begin
  inherited Create;
  ConfigureWorkspace(GetCurrentDir);
end;

destructor TMNoteMultiAgentService.Destroy;
begin
  FSupervisor.Free; FRouter.Free; FRegistry.Free;
  inherited Destroy;
end;

procedure TMNoteMultiAgentService.ConfigureWorkspace(const ARoot: string);
var Root, MemoryDir: string;
begin
  Root := Trim(ARoot); if Root = '' then Root := GetCurrentDir;
  FWorkspaceRoot := ExcludeTrailingPathDelimiter(ExpandFileName(Root));
  MemoryDir := IncludeTrailingPathDelimiter(FWorkspaceRoot) + '.mnote2' + PathDelim + 'ai-memory';
  FreeAndNil(FSupervisor); FreeAndNil(FRouter); FreeAndNil(FRegistry);
  FRegistry := TAIAgentMemoryRegistry.Create(MemoryDir);
  FRouter := TAIAgentCapabilityRouter.Create(FRegistry);
  FSupervisor := TAIStrongSupervisor.Create(FRegistry, FRouter);
  RebuildRouter;
end;

procedure TMNoteMultiAgentService.RebuildRouter;
var P: TMNoteAIProfile;
  function ModelFor(R: TMNoteAIRole; const Fallback: string): string;
  begin P := MNoteAI.Profile(R); Result := Trim(P.Config.ModelName); if Result = '' then Result := Fallback; end;
begin
  FRouter.RegisterAgent('source-light', ModelFor(airLightWork, 'light-work'),
    'source', 'bug_fix,small_work,refactor', 'pascal,*', 'lazarus,*', 0.72, 0.65, 0.15, False);
  FRouter.RegisterAgent('database', ModelFor(airDatabase, 'database'),
    'database,source', 'bug_fix,database,query,transaction', 'sql,pascal,*',
    'postgresql,zeos,lazarus,*', 0.86, 0.88, 0.35, False);
  FRouter.RegisterAgent('project', ModelFor(airManagement, 'management'),
    'project,architecture,source', 'planning,architecture,refactor,project',
    'pascal,*', 'lazarus,*', 0.90, 0.90, 0.50, False);
  FRouter.RegisterAgent('strong', ModelFor(airArbiter, 'arbiter'),
    '*', '*', '*', '*', 1.0, 1.0, 0.95, True);
end;

function TMNoteMultiAgentService.AgentRole(const AAgentId: string): TMNoteAIRole;
begin
  if SameText(AAgentId, 'database') then Exit(airDatabase);
  if SameText(AAgentId, 'project') then Exit(airManagement);
  if SameText(AAgentId, 'strong') then Exit(airArbiter);
  Result := airLightWork;
end;

function TMNoteMultiAgentService.Qualify(const AInstruction, AFileName: string): TAITaskQualification;
var T, Ext: string;
begin
  FillChar(Result, SizeOf(Result), 0);
  T := LowerCase(AInstruction + ' ' + AFileName); Ext := LowerCase(ExtractFileExt(AFileName));
  Result.Domain := 'source'; Result.SubDomain := 'general'; Result.TaskType := 'bug_fix';
  Result.Scope := 'single_file'; Result.Complexity := 0.45; Result.Risk := 0.35;
  Result.RequiredCapabilities := 'source_edit,build';
  if Ext = '.pas' then Result.Language := 'pascal' else if Ext = '.sql' then Result.Language := 'sql' else Result.Language := '*';
  if (Ext = '.pas') or HasAny(T, ['lazarus','free pascal','fpc','form','lfm']) then Result.Framework := 'lazarus' else Result.Framework := '*';
  if HasAny(T, ['postgres','sql','banco','database','zeos','query','select ','insert ','update ','delete ','transaction','rollback','commit']) then
  begin
    Result.Domain := 'database'; Result.SubDomain := 'database_source';
    Result.RequiredCapabilities := 'database_reasoning,source_edit,build';
    Result.Complexity := Result.Complexity + 0.15; Result.Risk := Result.Risk + 0.20;
    if HasAny(T, ['transaction','rollback','commit','migration','alter table']) then Result.TaskType := 'transaction' else Result.TaskType := 'database';
    if HasAny(T, ['postgres']) then Result.Framework := 'postgresql';
  end;
  if HasAny(T, ['arquitetura','architecture','projeto','project','refator','múltipl','multipl','vários arquivos','varios arquivos','pacote','package']) then
  begin
    Result.Domain := 'project'; Result.SubDomain := 'architecture'; Result.TaskType := 'architecture'; Result.Scope := 'multi_file';
    Result.RequiredCapabilities := 'project_reasoning,source_edit,build,test';
    Result.Complexity := Result.Complexity + 0.25; Result.Risk := Result.Risk + 0.15;
  end;
  if HasAny(T, ['thread','concorr','mutex','critical section','ponteiro','pointer','memória','memory','segmentation','deadlock','generics','generic']) then
  begin Result.Complexity := Result.Complexity + 0.30; Result.Risk := Result.Risk + 0.25; end;
  if HasAny(T, ['só caption','so caption','texto do botão','texto do botao','rename','renomear','comentário','comentario']) then
  begin Result.Complexity := 0.20; Result.Risk := 0.15; end;
  if Result.Complexity > 1 then Result.Complexity := 1; if Result.Risk > 1 then Result.Risk := 1;
end;

function TMNoteMultiAgentService.SelectAgent(const AInstruction, AFileName: string;
  out ADecision: TMNoteMultiAgentDecision): Boolean;
var M: TAIDeterministicAgentMemory;
begin
  FLastError := ''; FillChar(ADecision, SizeOf(ADecision), 0);
  ADecision.Qualification := Qualify(AInstruction, AFileName);
  ADecision.Route := FSupervisor.ChooseAgent(ADecision.Qualification, 45);
  Result := ADecision.Route.AgentId <> '';
  if not Result then begin FLastError := ADecision.Route.Reason; Exit; end;
  ADecision.Role := AgentRole(ADecision.Route.AgentId);
  ADecision.EscalatedToStrong := SameText(ADecision.Route.AgentId, 'strong');
  M := FRegistry.AgentMemory(ADecision.Route.AgentId);
  try ADecision.SimilarEvidence := M.SimilarEvidenceCount(ADecision.Qualification); finally M.Free; end;
  FLastDecision := ADecision;
end;

procedure TMNoteMultiAgentService.AdoptDecision(const ADecision: TMNoteMultiAgentDecision);
begin
  FLastDecision := ADecision;
end;

function TMNoteMultiAgentService.BoolJSON(O: TJSONObject; const N: string; D: Boolean): Boolean;
begin if (O <> nil) and (O.Find(N) <> nil) then Result := O.Booleans[N] else Result := D; end;
function TMNoteMultiAgentService.FloatJSON(O: TJSONObject; const N: string; D: Double): Double;
begin if (O <> nil) and (O.Find(N) <> nil) then Result := O.Floats[N] else Result := D; end;
function TMNoteMultiAgentService.IntJSON(O: TJSONObject; const N: string; D: Integer): Integer;
begin if (O <> nil) and (O.Find(N) <> nil) then Result := O.Integers[N] else Result := D; end;
function TMNoteMultiAgentService.StringJSON(O: TJSONObject; const N, D: string): string;
begin if (O <> nil) and (O.Find(N) <> nil) then Result := O.Strings[N] else Result := D; end;

function TMNoteMultiAgentService.ReviewAndRecord(const AInstruction, AExecutionOutput: string;
  ABuildPassed, ATestsPassed: Boolean; ARetries: Integer): Boolean;
var P: TMNoteAIProfile; Response, Err, Prompt: string; D: TJSONData; O: TJSONObject;
begin
  FLastError := ''; FLastReviewText := ''; FillChar(FLastReview, SizeOf(FLastReview), 0);
  P := MNoteAI.Profile(airArbiter);
  Prompt := 'Você é o supervisor forte. Avalie a execução de um agente especialista.' + LineEnding +
    'Tarefa: ' + AInstruction + LineEnding + 'Agente: ' + FLastDecision.Route.AgentId +
    ' / modelo: ' + FLastDecision.Route.ModelId + LineEnding + 'Resultado: ' + AExecutionOutput + LineEnding +
    'Build passou: ' + BoolToStr(ABuildPassed, True) + LineEnding + 'Testes passaram: ' + BoolToStr(ATestsPassed, True) + LineEnding +
    'Retorne SOMENTE JSON: {"approved":true,"reviewer_score":0..100,"failure_kind":"",' +
    '"corrections_required":0,"should_escalate":false,"should_train":false,"notes":"..."}.';
  if not P.Execute(Prompt, 'Revisão final determinística do sistema multiagente MNote2.', Response, Err) then
  begin FLastError := Err; Exit(False); end;
  D := nil;
  try
    D := GetJSON(Response); if not (D is TJSONObject) then begin FLastError := 'Supervisor não retornou objeto JSON.'; Exit(False); end;
    O := TJSONObject(D);
    FLastReview.Approved := BoolJSON(O, 'approved', False);
    FLastReview.ReviewerScore := FloatJSON(O, 'reviewer_score', 0);
    FLastReview.FailureKind := StringJSON(O, 'failure_kind', '');
    FLastReview.CorrectionsRequired := IntJSON(O, 'corrections_required', 0);
    FLastReview.ShouldEscalate := BoolJSON(O, 'should_escalate', not FLastReview.Approved);
    FLastReview.ShouldTrain := BoolJSON(O, 'should_train', False);
    FLastReview.Notes := StringJSON(O, 'notes', '');
    FSupervisor.RecordReviewedExecution(FLastDecision.Qualification,
      FLastDecision.Route.AgentId, FLastDecision.Route.ModelId, FLastReview.Approved,
      ABuildPassed, ATestsPassed, ARetries, FLastReview);
    FLastReviewText := Response; Result := True;
  except on E: Exception do begin FLastError := E.Message; Result := False; end; end;
  D.Free;
end;

function TMNoteMultiAgentService.StrongDecision: TMNoteMultiAgentDecision;
var P: TMNoteAIProfile; M: TAIDeterministicAgentMemory;
begin
  FillChar(Result, SizeOf(Result), 0); Result.Qualification := FLastDecision.Qualification;
  P := MNoteAI.Profile(airArbiter);
  Result.Route.AgentId := 'strong'; Result.Route.ModelId := Trim(P.Config.ModelName);
  if Result.Route.ModelId = '' then Result.Route.ModelId := 'arbiter';
  Result.Route.Score := 100; Result.Route.QualificationScore := 100;
  Result.Route.Reason := 'Escalonamento explícito determinado pelo supervisor forte.';
  Result.Role := airArbiter; Result.EscalatedToStrong := True;
  M := FRegistry.AgentMemory('strong');
  try Result.SimilarEvidence := M.SimilarEvidenceCount(Result.Qualification); finally M.Free; end;
end;

function TMNoteMultiAgentService.LearningModeForFailure: TMNoteLearningMode;
var F: string;
begin
  if not FLastReview.ShouldTrain then Exit(mlmNone);
  F := LowerCase(FLastReview.FailureKind + ' ' + FLastReview.Notes);
  if HasAny(F, ['context','document','knowledge','regra','padrão','padrao','api','schema','informação','informacao']) then
    Result := mlmRAG
  else if (FLastDecision.SimilarEvidence >= 3) and
          (FLastDecision.Route.HistoricalScore > 0) and
          (FLastDecision.Route.HistoricalScore < 70) then
    Result := mlmLoRA
  else if FLastReview.CorrectionsRequired > 1 then
    Result := mlmRAGAndLoRA
  else
    Result := mlmRAG;
end;

procedure TMNoteMultiAgentService.QueueLearningCase(const AInstruction,
  AExecutionOutput: string; const AStep: TMNoteSupervisorNextStep);
var Dir, FN: string; L: TStringList; O: TJSONObject;
begin
  if AStep.LearningMode = mlmNone then Exit;
  Dir := IncludeTrailingPathDelimiter(FWorkspaceRoot) + '.mnote2' + PathDelim + 'ai-training';
  ForceDirectories(Dir); FN := IncludeTrailingPathDelimiter(Dir) + 'pending.jsonl';
  O := TJSONObject.Create; L := TStringList.Create;
  try
    O.Add('timestamp', DateTimeToStr(Now));
    O.Add('fingerprint', TAIDeterministicAgentMemory.TaskFingerprint(FLastDecision.Qualification));
    O.Add('learning_mode', LearningModeName(AStep.LearningMode));
    O.Add('agent_id', FLastDecision.Route.AgentId); O.Add('model_id', FLastDecision.Route.ModelId);
    O.Add('domain', FLastDecision.Qualification.Domain); O.Add('task_type', FLastDecision.Qualification.TaskType);
    O.Add('instruction', AInstruction); O.Add('execution_output', AExecutionOutput);
    O.Add('reviewer_score', FLastReview.ReviewerScore); O.Add('failure_kind', FLastReview.FailureKind);
    O.Add('corrections_required', FLastReview.CorrectionsRequired); O.Add('notes', FLastReview.Notes);
    O.Add('next_action', RecoveryActionName(AStep.Action));
    if FileExists(FN) then L.LoadFromFile(FN); L.Add(O.AsJSON); L.SaveToFile(FN);
  finally L.Free; O.Free; end;
end;

function TMNoteMultiAgentService.DecideNextStep(const AInstruction, AFileName,
  AExecutionOutput: string; AAttempt, AMaxAttempts: Integer): TMNoteSupervisorNextStep;
var Candidate: TMNoteMultiAgentDecision;
begin
  FillChar(Result, SizeOf(Result), 0); Result.Action := mraFinish;
  Result.LearningMode := LearningModeForFailure;
  if FLastReview.Approved then
    Result.Reason := 'Supervisor aprovou a execução.'
  else if AAttempt >= AMaxAttempts then
  begin Result.Action := mraAbort; Result.Reason := 'Limite de tentativas atingido.'; end
  else if FLastReview.ShouldEscalate or (FLastReview.ReviewerScore < 55) or
          (FLastDecision.Qualification.Risk >= 0.85) then
  begin
    Result.Action := mraEscalateStrong; Result.NextDecision := StrongDecision;
    Result.Reason := 'Supervisor determinou escalonamento por baixa nota, risco ou flag explícita.';
  end
  else if (FLastReview.CorrectionsRequired <= 1) and
          (FLastReview.ReviewerScore >= 70) then
  begin
    Result.Action := mraRetrySame; Result.NextDecision := FLastDecision;
    Result.Reason := 'A solução está próxima do aceitável; repetir o mesmo especialista preserva contexto.';
  end
  else
  begin
    if SelectAgent(AInstruction + ' Falha anterior: ' + FLastReview.FailureKind +
      '. Correções necessárias: ' + IntToStr(FLastReview.CorrectionsRequired), AFileName, Candidate) then
    begin
      if SameText(Candidate.Route.AgentId, FLastDecision.Route.AgentId) then
      begin Result.Action := mraEscalateStrong; Result.NextDecision := StrongDecision;
        Result.Reason := 'O roteador escolheria o mesmo agente após reprovação; escalado para evitar ciclo.'; end
      else begin Result.Action := mraSwitchAgent; Result.NextDecision := Candidate;
        Result.Reason := 'Outro especialista tem melhor aderência após a falha registrada.'; end;
    end
    else begin Result.Action := mraEscalateStrong; Result.NextDecision := StrongDecision;
      Result.Reason := 'Nenhum especialista alternativo atingiu o score mínimo.'; end;
  end;
  FLastNextStep := Result; QueueLearningCase(AInstruction, AExecutionOutput, Result);
end;

function TMNoteMultiAgentService.DecisionText: string;
begin
  with FLastDecision do Result := 'Agente escolhido: ' + Route.AgentId + LineEnding +
    'Modelo: ' + Route.ModelId + LineEnding + 'Score final: ' + FormatFloat('0.0', Route.Score) + LineEnding +
    'Score da questão: ' + FormatFloat('0.0', Route.QualificationScore) + LineEnding +
    'Score histórico: ' + FormatFloat('0.0', Route.HistoricalScore) + LineEnding +
    'Evidências semelhantes: ' + IntToStr(SimilarEvidence) + LineEnding +
    'Domínio: ' + Qualification.Domain + '/' + Qualification.SubDomain + LineEnding +
    'Tipo: ' + Qualification.TaskType + LineEnding + 'Complexidade: ' + FormatFloat('0.00', Qualification.Complexity) + LineEnding +
    'Risco: ' + FormatFloat('0.00', Qualification.Risk) + LineEnding + 'Motivo: ' + Route.Reason;
end;

function TMNoteMultiAgentService.ReviewText: string;
begin
  Result := 'Aprovado: ' + BoolToStr(FLastReview.Approved, True) + LineEnding +
    'Nota: ' + FormatFloat('0.0', FLastReview.ReviewerScore) + LineEnding + 'Falha: ' + FLastReview.FailureKind + LineEnding +
    'Correções: ' + IntToStr(FLastReview.CorrectionsRequired) + LineEnding +
    'Escalar: ' + BoolToStr(FLastReview.ShouldEscalate, True) + LineEnding +
    'Priorizar treino: ' + BoolToStr(FLastReview.ShouldTrain, True) + LineEnding + 'Notas: ' + FLastReview.Notes;
end;

function TMNoteMultiAgentService.NextStepText: string;
begin
  Result := 'Próxima ação: ' + RecoveryActionName(FLastNextStep.Action) + LineEnding +
    'Aprendizado: ' + LearningModeName(FLastNextStep.LearningMode) + LineEnding +
    'Motivo: ' + FLastNextStep.Reason;
  if FLastNextStep.Action in [mraRetrySame, mraSwitchAgent, mraEscalateStrong] then
    Result := Result + LineEnding + 'Próximo agente: ' + FLastNextStep.NextDecision.Route.AgentId +
      ' / ' + FLastNextStep.NextDecision.Route.ModelId;
end;

procedure InitializeMNoteMultiAgent;
begin if GMultiAgent = nil then GMultiAgent := TMNoteMultiAgentService.Create; end;
procedure FinalizeMNoteMultiAgent;
begin FreeAndNil(GMultiAgent); end;
function MNoteMultiAgent: TMNoteMultiAgentService;
begin if GMultiAgent = nil then InitializeMNoteMultiAgent; Result := GMultiAgent; end;

finalization
  FinalizeMNoteMultiAgent;

end.
