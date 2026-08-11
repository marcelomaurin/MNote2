unit mnote_chatgpt_agent_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, chatgpt,
  aiagent_memorymap, aiagent_classifier, aiagent_decision,
  aiagent_actionbuilder, aiagent_executor, aiagent_orchestrator,
  aiagent_sourceactions;

type
  { Thin MNote2 adapter. Agent orchestration and developer actions live in CHATGPT. }
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
    FReadSource: TAISourceReadAction;
    FReplaceSource: TAISourceReplaceAction;
    FBuildProject: TAIProjectBuildAction;
    FRunTests: TAIProjectTestAction;
    FWorkspaceRoot: string;
    FLastError: string;
    procedure WireDeveloperActions;
  public
    constructor Create(AOwner: TComponent; AChatGPT: TCHATGPT);
    destructor Destroy; override;
    procedure SetChatGPT(AChatGPT: TCHATGPT);
    procedure ConfigureDeveloperWorkspace(const ARoot, AProjectFile,
      ATestExecutable, ABuildArguments, ATestArguments: string);
    function Run(const AInstruction: string): Boolean;
    function RunSourceCorrection(const AInstruction: string): Boolean;
    procedure BeginConversation(const AInput: string);
    procedure EndConversation;
    property Orchestrator: TAIAgentOrchestrator read FOrchestrator;
    property MemoryMap: TAIAgentMemoryMap read FMemoryMap;
    property Executor: TAIActionExecutor read FExecutor;
    property WorkspaceRoot: string read FWorkspaceRoot;
    property ReadSourceAction: TAISourceReadAction read FReadSource;
    property ReplaceSourceAction: TAISourceReplaceAction read FReplaceSource;
    property BuildProjectAction: TAIProjectBuildAction read FBuildProject;
    property RunTestsAction: TAIProjectTestAction read FRunTests;
    property LastError: string read FLastError;
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

  FReadSource := TAISourceReadAction.Create(FOwner);
  FReplaceSource := TAISourceReplaceAction.Create(FOwner);
  FBuildProject := TAIProjectBuildAction.Create(FOwner);
  FRunTests := TAIProjectTestAction.Create(FOwner);

  FOrchestrator.MemoryMap := FMemoryMap;
  FOrchestrator.Classifier := FClassifier;
  FOrchestrator.DecisionAgent := FDecision;
  FOrchestrator.ActionBuilder := FActionBuilder;
  FOrchestrator.Executor := FExecutor;
  FOrchestrator.CriarMapaAutomaticamente := False;
  FOrchestrator.RepassarMapaParaAgentes := True;

  WireDeveloperActions;
  SetChatGPT(AChatGPT);
end;

procedure TMNoteChatGPTAgentService.WireDeveloperActions;
begin
  FReadSource.MemoryMap := FMemoryMap;
  FReplaceSource.MemoryMap := FMemoryMap;
  FBuildProject.MemoryMap := FMemoryMap;
  FRunTests.MemoryMap := FMemoryMap;

  FExecutor.RegisterAction(FReadSource);
  FExecutor.RegisterAction(FReplaceSource);
  FExecutor.RegisterAction(FBuildProject);
  FExecutor.RegisterAction(FRunTests);
end;

destructor TMNoteChatGPTAgentService.Destroy;
begin
  { Components are owned by FOwner and must not be freed twice. }
  FRunTests := nil;
  FBuildProject := nil;
  FReplaceSource := nil;
  FReadSource := nil;
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

procedure TMNoteChatGPTAgentService.ConfigureDeveloperWorkspace(const ARoot,
  AProjectFile, ATestExecutable, ABuildArguments, ATestArguments: string);
begin
  FWorkspaceRoot := ExpandFileName(Trim(ARoot));
  FReadSource.WorkspaceRoot := FWorkspaceRoot;
  FReplaceSource.WorkspaceRoot := FWorkspaceRoot;
  FBuildProject.WorkspaceRoot := FWorkspaceRoot;
  FRunTests.WorkspaceRoot := FWorkspaceRoot;

  FBuildProject.ProjectFile := AProjectFile;
  FBuildProject.BuildArguments := ABuildArguments;
  FRunTests.TestExecutable := ATestExecutable;
  FRunTests.TestArguments := ATestArguments;
end;

function TMNoteChatGPTAgentService.Run(const AInstruction: string): Boolean;
begin
  FLastError := '';
  if Trim(AInstruction) = '' then
  begin
    FLastError := 'A instrução do agente está vazia.';
    Exit(False);
  end;
  Result := FOrchestrator.Run(AInstruction);
  if not Result then FLastError := FOrchestrator.LastError;
end;

function TMNoteChatGPTAgentService.RunSourceCorrection(
  const AInstruction: string): Boolean;
var
  Prompt: string;
begin
  FLastError := '';
  if Trim(FWorkspaceRoot) = '' then
  begin
    FLastError := 'Workspace de desenvolvimento não configurado.';
    Exit(False);
  end;

  Prompt :=
    'Você é o agente de correção de fontes do projeto. ' +
    'Trabalhe somente dentro do workspace configurado. ' +
    'Use read_source para inspecionar fontes. ' +
    'Para alterar um arquivo use replace_source com file, old_text e new_text. ' +
    'Após alterações use build_project. Se houver teste configurado use run_tests. ' +
    'Se build ou teste falhar, analise a saída, corrija o fonte e tente novamente. ' +
    'Nunca invente caminhos fora do workspace e não use comandos externos arbitrários.' +
    LineEnding + LineEnding + 'Solicitação: ' + AInstruction;

  Result := Run(Prompt);
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
