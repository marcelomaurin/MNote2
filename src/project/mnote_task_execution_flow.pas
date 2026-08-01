unit mnote_task_execution_flow;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils;

type
  TMNoteTaskExecutionStep = (tesPrepareContext, tesRequestSolution,
    tesValidateProposal, tesReviewDiff, tesApply, tesTest, tesConclude);
  TMNoteExecutionStatus = (esPending, esCompleted, esSkipped, esFailed);

  TMNoteExecutionStepState = record
    Status: TMNoteExecutionStatus;
    Evidence: string;
  end;

  TMNoteTaskExecutionFlow = class
  private
    FTaskID: string;
    FPlanOnly: Boolean;
    FStates: array[TMNoteTaskExecutionStep] of TMNoteExecutionStepState;
    FLastError: string;
    function PreviousReady(AStep: TMNoteTaskExecutionStep): Boolean;
  public
    constructor Create(const ATaskID: string; APlanOnly: Boolean);
    function PrepareContext(const AContextEvidence: string): Boolean;
    function RecordStep(AStep: TMNoteTaskExecutionStep;
      AStatus: TMNoteExecutionStatus; const AEvidence: string): Boolean;
    function State(AStep: TMNoteTaskExecutionStep): TMNoteExecutionStepState;
    function IsReallyCompleted: Boolean;
    property TaskID: string read FTaskID;
    property PlanOnly: Boolean read FPlanOnly;
    property LastError: string read FLastError;
  end;

implementation

constructor TMNoteTaskExecutionFlow.Create(const ATaskID: string;
  APlanOnly: Boolean);
var
  Step: TMNoteTaskExecutionStep;
begin
  inherited Create;
  FTaskID := ATaskID;
  FPlanOnly := APlanOnly;
  for Step := Low(TMNoteTaskExecutionStep) to High(TMNoteTaskExecutionStep) do
  begin
    FStates[Step].Status := esPending;
    FStates[Step].Evidence := '';
  end;
end;

function TMNoteTaskExecutionFlow.PreviousReady(
  AStep: TMNoteTaskExecutionStep): Boolean;
var
  Previous: TMNoteTaskExecutionStep;
begin
  if AStep = Low(TMNoteTaskExecutionStep) then Exit(True);
  Previous := Pred(AStep);
  Result := FStates[Previous].Status in [esCompleted, esSkipped];
end;

function TMNoteTaskExecutionFlow.PrepareContext(
  const AContextEvidence: string): Boolean;
begin
  Result := RecordStep(tesPrepareContext, esCompleted, AContextEvidence);
  if Result and FPlanOnly then
    Result := RecordStep(tesRequestSolution, esSkipped,
      'PlanOnly: nenhuma solução foi solicitada ou executada.');
end;

function TMNoteTaskExecutionFlow.RecordStep(AStep: TMNoteTaskExecutionStep;
  AStatus: TMNoteExecutionStatus; const AEvidence: string): Boolean;
begin
  FLastError := '';
  Result := False;
  if not PreviousReady(AStep) then
  begin FLastError := 'A etapa anterior ainda não foi concluída ou pulada.'; Exit; end;
  if (AStatus = esCompleted) and (Trim(AEvidence) = '') then
  begin FLastError := 'Uma etapa concluída exige evidência real.'; Exit; end;
  if FPlanOnly and (AStatus = esCompleted) and
    (AStep in [tesRequestSolution, tesReviewDiff, tesApply, tesTest, tesConclude]) then
  begin FLastError := 'PlanOnly não pode declarar execução concluída.'; Exit; end;
  if (AStep = tesConclude) and (AStatus = esCompleted) and
    ((FStates[tesApply].Status <> esCompleted) or
     (FStates[tesTest].Status <> esCompleted)) then
  begin FLastError := 'Conclusão exige Apply e testes reais.'; Exit; end;
  FStates[AStep].Status := AStatus;
  FStates[AStep].Evidence := AEvidence;
  Result := True;
end;

function TMNoteTaskExecutionFlow.State(
  AStep: TMNoteTaskExecutionStep): TMNoteExecutionStepState;
begin
  Result := FStates[AStep];
end;

function TMNoteTaskExecutionFlow.IsReallyCompleted: Boolean;
begin
  Result := (not FPlanOnly) and
    (FStates[tesConclude].Status = esCompleted);
end;

end.
