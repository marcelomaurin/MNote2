unit mnote_recovery_coordinator;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, aiagent_deterministicmemory,
  mnote_multiagent_service;

type
  TMNoteRecoveryCoordinator = class
  private
    FWorkspaceRoot: string;
    function ChooseLearningMode(const ADecision: TMNoteMultiAgentDecision;
      const AReview: TAISupervisorReview): TMNoteLearningMode;
    procedure QueueLearning(const AInstruction, AOutput: string;
      const ADecision: TMNoteMultiAgentDecision;
      const AReview: TAISupervisorReview; const AStep: TMNoteSupervisorNextStep);
  public
    procedure ConfigureWorkspace(const ARoot: string);
    function Decide(AMulti: TMNoteMultiAgentService;
      const AInstruction, AFileName, AOutput: string;
      AAttempt, AMaxAttempts: Integer): TMNoteSupervisorNextStep;
  end;

function MNoteRecoveryCoordinator: TMNoteRecoveryCoordinator;

implementation

var
  GRecovery: TMNoteRecoveryCoordinator = nil;

function HasWord(const S: string; const Words: array of string): Boolean;
var I: Integer; L: string;
begin
  L := LowerCase(S);
  for I := Low(Words) to High(Words) do
    if Pos(LowerCase(Words[I]), L) > 0 then Exit(True);
  Result := False;
end;

function LearningName(M: TMNoteLearningMode): string;
begin
  case M of
    mlmRAG: Result := 'rag';
    mlmLoRA: Result := 'lora';
    mlmRAGAndLoRA: Result := 'rag+lora';
  else Result := 'none'; end;
end;

function RecoveryName(A: TMNoteRecoveryAction): string;
begin
  case A of
    mraRetrySame: Result := 'retry_same';
    mraSwitchAgent: Result := 'switch_agent';
    mraEscalateStrong: Result := 'escalate_strong';
    mraAbort: Result := 'abort';
  else Result := 'finish'; end;
end;

procedure TMNoteRecoveryCoordinator.ConfigureWorkspace(const ARoot: string);
begin
  FWorkspaceRoot := ExcludeTrailingPathDelimiter(ExpandFileName(ARoot));
end;

function TMNoteRecoveryCoordinator.ChooseLearningMode(
  const ADecision: TMNoteMultiAgentDecision;
  const AReview: TAISupervisorReview): TMNoteLearningMode;
var T: string;
begin
  if not AReview.ShouldTrain then Exit(mlmNone);
  T := AReview.FailureKind + ' ' + AReview.Notes;
  if HasWord(T, ['context','document','knowledge','regra','padrão','padrao',
    'schema','api','informação','informacao']) then Exit(mlmRAG);
  if (ADecision.SimilarEvidence >= 3) and
     (ADecision.Route.HistoricalScore > 0) and
     (ADecision.Route.HistoricalScore < 70) then Exit(mlmLoRA);
  if AReview.CorrectionsRequired > 1 then Exit(mlmRAGAndLoRA);
  Result := mlmRAG;
end;

procedure TMNoteRecoveryCoordinator.QueueLearning(const AInstruction,
  AOutput: string; const ADecision: TMNoteMultiAgentDecision;
  const AReview: TAISupervisorReview; const AStep: TMNoteSupervisorNextStep);
var Dir, FN: string; L: TStringList; O: TJSONObject;
begin
  if AStep.LearningMode = mlmNone then Exit;
  Dir := IncludeTrailingPathDelimiter(FWorkspaceRoot) + '.mnote2' + PathDelim + 'ai-training';
  ForceDirectories(Dir);
  FN := IncludeTrailingPathDelimiter(Dir) + 'pending.jsonl';
  O := TJSONObject.Create;
  L := TStringList.Create;
  try
    O.Add('timestamp', DateTimeToStr(Now));
    O.Add('fingerprint', TAIDeterministicAgentMemory.TaskFingerprint(ADecision.Qualification));
    O.Add('learning_mode', LearningName(AStep.LearningMode));
    O.Add('agent_id', ADecision.Route.AgentId);
    O.Add('model_id', ADecision.Route.ModelId);
    O.Add('domain', ADecision.Qualification.Domain);
    O.Add('task_type', ADecision.Qualification.TaskType);
    O.Add('instruction', AInstruction);
    O.Add('execution_output', AOutput);
    O.Add('reviewer_score', AReview.ReviewerScore);
    O.Add('failure_kind', AReview.FailureKind);
    O.Add('corrections_required', AReview.CorrectionsRequired);
    O.Add('notes', AReview.Notes);
    O.Add('next_action', RecoveryName(AStep.Action));
    if FileExists(FN) then L.LoadFromFile(FN);
    L.Add(O.AsJSON);
    L.SaveToFile(FN);
  finally
    L.Free;
    O.Free;
  end;
end;

function TMNoteRecoveryCoordinator.Decide(AMulti: TMNoteMultiAgentService;
  const AInstruction, AFileName, AOutput: string; AAttempt,
  AMaxAttempts: Integer): TMNoteSupervisorNextStep;
var
  Prev, Candidate: TMNoteMultiAgentDecision;
  R: TAISupervisorReview;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Action := mraFinish;
  Prev := AMulti.LastDecision;
  R := AMulti.LastReview;
  Result.LearningMode := ChooseLearningMode(Prev, R);

  if R.Approved then
    Result.Reason := 'Supervisor aprovou a execução.'
  else if AAttempt >= AMaxAttempts then
  begin
    Result.Action := mraAbort;
    Result.Reason := 'Limite determinístico de tentativas atingido.';
  end
  else if R.ShouldEscalate or (R.ReviewerScore < 55) or
          (Prev.Qualification.Risk >= 0.85) then
  begin
    if AMulti.SelectAgent(AInstruction + ' Requer revisão forte por falha anterior.',
      AFileName, Candidate) and SameText(Candidate.Route.AgentId, 'strong') then
      Result.NextDecision := Candidate
    else
    begin
      Result.NextDecision := Prev;
      Result.NextDecision.Route.AgentId := 'strong';
      Result.NextDecision.Role := airArbiter;
      Result.NextDecision.EscalatedToStrong := True;
      Result.NextDecision.Route.ModelId := 'arbiter';
      Result.NextDecision.Route.Score := 100;
      Result.NextDecision.Route.Reason := 'Escalonamento forçado pelo supervisor.';
    end;
    AMulti.AdoptDecision(Prev);
    Result.Action := mraEscalateStrong;
    Result.Reason := 'Baixa nota, alto risco ou supervisor solicitou escalonamento.';
  end
  else if (R.ReviewerScore >= 70) and (R.CorrectionsRequired <= 1) then
  begin
    Result.Action := mraRetrySame;
    Result.NextDecision := Prev;
    Result.Reason := 'Resposta próxima do aceitável; mantém especialista e contexto.';
  end
  else
  begin
    if AMulti.SelectAgent(AInstruction + ' Falha anterior: ' + R.FailureKind +
      '. Necessita correções: ' + IntToStr(R.CorrectionsRequired), AFileName,
      Candidate) and not SameText(Candidate.Route.AgentId, Prev.Route.AgentId) then
    begin
      Result.Action := mraSwitchAgent;
      Result.NextDecision := Candidate;
      Result.Reason := 'Roteador encontrou especialista alternativo mais adequado.';
    end
    else
    begin
      Result.Action := mraEscalateStrong;
      Result.NextDecision := Prev;
      Result.NextDecision.Route.AgentId := 'strong';
      Result.NextDecision.Role := airArbiter;
      Result.NextDecision.EscalatedToStrong := True;
      Result.NextDecision.Route.ModelId := 'arbiter';
      Result.NextDecision.Route.Score := 100;
      Result.NextDecision.Route.Reason := 'Mesmo agente seria repetido; evita ciclo escalando.';
      Result.Reason := 'Não houve especialista alternativo seguro.';
    end;
    AMulti.AdoptDecision(Prev);
  end;
  QueueLearning(AInstruction, AOutput, Prev, R, Result);
end;

function MNoteRecoveryCoordinator: TMNoteRecoveryCoordinator;
begin
  if GRecovery = nil then GRecovery := TMNoteRecoveryCoordinator.Create;
  Result := GRecovery;
end;

finalization
  FreeAndNil(GRecovery);

end.
