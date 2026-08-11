unit mnote_chatgpt_agent_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, chatgpt,
  aiagent_memorymap, aiagent_classifier, aiagent_decision,
  aiagent_actionbuilder, aiagent_executor, aiagent_orchestrator,
  aiagent_sourceactions, aiagent_testaction;

type
  { Thin adapter: orchestration and developer actions stay in CHATGPT. }
  TMNoteChatGPTAgentService = class
  private
    FOwner: TComponent;
    FChatGPT: TCHATGPT;
    FMemoryMap: TAIAgentMemoryMap;
    FClassifier: TAIClassifierAgent;
    FDecision: TAIDecisionAgent;
    FActionBuilder: TAIActionBuilderAgent;
    FExecutor: TAIActionExecutor;
    FOrchestrator: TAIAgentOrchestrator;
    FReadAction: TAISourceReadAction;
    FReplaceAction: TAISourceReplaceAction;
    FBuildAction: TAIProjectBuildAction;
    FTestAction: TAITrustedProjectTestAction;
    FLastError: string;
    FLastOutput: string;
    procedure RegisterDeveloperActions;
  public
    constructor Create(AOwner: TComponent; AChatGPT: TCHATGPT);
    destructor Destroy; override;
    procedure SetChatGPT(AChatGPT: TCHATGPT);
    procedure ConfigureDeveloperWorkspace(const ARoot, AProjectFile,
      ABuilderExecutable, ABuildArguments, ATestExecutable,
      ATestArguments: string);
    function Run(const AInstruction: string): Boolean;
    function ExecutePreparedPlan(const APlanJSON: string): Boolean;
    procedure BeginConversation(const AInput: string);
    procedure EndConversation;
    property Orchestrator: TAIAgentOrchestrator read FOrchestrator;
    property MemoryMap: TAIAgentMemoryMap read FMemoryMap;
    property Executor: TAIActionExecutor read FExecutor;
    property ReadAction: TAISourceReadAction read FReadAction;
    property ReplaceAction: TAISourceReplaceAction read FReplaceAction;
    property BuildAction: TAIProjectBuildAction read FBuildAction;
    property TestAction: TAITrustedProjectTestAction read FTestAction;
    property LastError: string read FLastError;
    property LastOutput: string read FLastOutput;
  end;

implementation

constructor TMNoteChatGPTAgentService.Create(AOwner: TComponent;
  AChatGPT: TCHATGPT);
begin
  inherited Create;
  FOwner := AOwner;

  FMemoryMap := TAIAgentMemoryMap.Create(FOwner);
  FClassifier := TAIClassifierAgent.Create(FOwner);
  FDecision := TAIDecisionAgent.Create(FOwner);
  FActionBuilder := TAIActionBuilderAgent.Create(FOwner);
  FExecutor := TAIActionExecutor.Create(FOwner);
  FOrchestrator := TAIAgentOrchestrator.Create(FOwner);

  FReadAction := TAISourceReadAction.Create(FOwner);
  FReplaceAction := TAISourceReplaceAction.Create(FOwner);
  FBuildAction := TAIProjectBuildAction.Create(FOwner);
  FTestAction := TAITrustedProjectTestAction.Create(FOwner);

  FOrchestrator.MemoryMap := FMemoryMap;
  FOrchestrator.Classifier := FClassifier;
  FOrchestrator.DecisionAgent := FDecision;
  FOrchestrator.ActionBuilder := FActionBuilder;
  FOrchestrator.Executor := FExecutor;
  FOrchestrator.CriarMapaAutomaticamente := False;
  FOrchestrator.RepassarMapaParaAgentes := True;

  FReadAction.MemoryMap := FMemoryMap;
  FReplaceAction.MemoryMap := FMemoryMap;
  FBuildAction.MemoryMap := FMemoryMap;
  FTestAction.MemoryMap := FMemoryMap;
  RegisterDeveloperActions;
  SetChatGPT(AChatGPT);
end;

procedure TMNoteChatGPTAgentService.RegisterDeveloperActions;
begin
  FExecutor.RegisterAction(FReadAction);
  FExecutor.RegisterAction(FReplaceAction);
  FExecutor.RegisterAction(FBuildAction);
  FExecutor.RegisterAction(FTestAction);
end;

destructor TMNoteChatGPTAgentService.Destroy;
begin
  { Components are owned by FOwner and must not be freed twice. }
  FTestAction := nil;
  FBuildAction := nil;
  FReplaceAction := nil;
  FReadAction := nil;
  FOrchestrator := nil;
  FExecutor := nil;
  FActionBuilder := nil;
  FDecision := nil;
  FClassifier := nil;
  FMemoryMap := nil;
  inherited Destroy;
end;

procedure TMNoteChatGPTAgentService.SetChatGPT(AChatGPT: TCHATGPT);
begin
  FChatGPT := AChatGPT;
  FOrchestrator.ChatGPT := FChatGPT;
  FClassifier.ChatGPT := FChatGPT;
  FDecision.ChatGPT := FChatGPT;
  FActionBuilder.ChatGPT := FChatGPT;
  FExecutor.ChatGPT := FChatGPT;
end;

procedure TMNoteChatGPTAgentService.ConfigureDeveloperWorkspace(
  const ARoot, AProjectFile, ABuilderExecutable, ABuildArguments,
  ATestExecutable, ATestArguments: string);
var
  Root: string;
begin
  Root := Trim(ARoot);
  if Root = '' then Root := GetCurrentDir;
  Root := ExpandFileName(Root);

  FReadAction.WorkspaceRoot := Root;
  FReplaceAction.WorkspaceRoot := Root;
  FBuildAction.WorkspaceRoot := Root;
  FTestAction.WorkspaceRoot := Root;

  FBuildAction.ProjectFile := AProjectFile;
  if Trim(ABuilderExecutable) <> '' then
    FBuildAction.BuilderExecutable := ABuilderExecutable
  else
    FBuildAction.BuilderExecutable := 'lazbuild';
  FBuildAction.BuildArguments := ABuildArguments;

  FTestAction.TestExecutable := ATestExecutable;
  FTestAction.TestArguments := ATestArguments;
end;

function TMNoteChatGPTAgentService.Run(const AInstruction: string): Boolean;
begin
  FLastError := '';
  FLastOutput := '';
  if Trim(AInstruction) = '' then
  begin
    FLastError := 'A instrução do agente está vazia.';
    Exit(False);
  end;
  Result := FOrchestrator.Run(AInstruction);
  if not Result then FLastError := FOrchestrator.LastError;
end;

function TMNoteChatGPTAgentService.ExecutePreparedPlan(
  const APlanJSON: string): Boolean;
begin
  FLastError := '';
  FLastOutput := '';
  if Trim(APlanJSON) = '' then
  begin
    FLastError := 'O plano de ações está vazio.';
    Exit(False);
  end;
  Result := FExecutor.ExecutePreparedActionsReal(APlanJSON, FLastOutput);
  if not Result then FLastError := FExecutor.LastError;
end;

procedure TMNoteChatGPTAgentService.BeginConversation(const AInput: string);
begin
  FOrchestrator.BeginConversation(AInput);
end;

procedure TMNoteChatGPTAgentService.EndConversation;
begin
  FOrchestrator.EndConversation;
end;

end.
