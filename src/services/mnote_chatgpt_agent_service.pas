unit mnote_chatgpt_agent_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, chatgpt,
  aiagent_memorymap, aiagent_classifier, aiagent_decision,
  aiagent_actionbuilder, aiagent_executor, aiagent_orchestrator;

type
  { Adapter thin by design: all orchestration stays in the CHATGPT package. }
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
    FLastError: string;
  public
    constructor Create(AOwner: TComponent; AChatGPT: TCHATGPT);
    destructor Destroy; override;
    procedure SetChatGPT(AChatGPT: TCHATGPT);
    function Run(const AInstruction: string): Boolean;
    procedure BeginConversation(const AInput: string);
    procedure EndConversation;
    property Orchestrator: TAIAgentOrchestrator read FOrchestrator;
    property MemoryMap: TAIAgentMemoryMap read FMemoryMap;
    property Executor: TAIActionExecutor read FExecutor;
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

  FOrchestrator.MemoryMap := FMemoryMap;
  FOrchestrator.Classifier := FClassifier;
  FOrchestrator.DecisionAgent := FDecision;
  FOrchestrator.ActionBuilder := FActionBuilder;
  FOrchestrator.Executor := FExecutor;
  FOrchestrator.CriarMapaAutomaticamente := False;
  FOrchestrator.RepassarMapaParaAgentes := True;

  SetChatGPT(AChatGPT);
end;

destructor TMNoteChatGPTAgentService.Destroy;
begin
  { Components are owned by FOwner and must not be freed twice. }
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

procedure TMNoteChatGPTAgentService.BeginConversation(const AInput: string);
begin
  FOrchestrator.BeginConversation(AInput);
end;

procedure TMNoteChatGPTAgentService.EndConversation;
begin
  FOrchestrator.EndConversation;
end;

end.
