unit mnote_ai_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, chatgpt, aicodeassistant, aipromptbuilder,
  aimodelregistry, aiagent_memorymap, mnote_service_base, mnote_token_estimator,
  mnote_ai_types, mnote_ai_profile, mnote_ai_router, mnote_ai_bus,
  mnote_ai_session, mnote_ai_actions, mnote_ai_plan_contract;

type
  TMNoteAIState = (aisIdle, aisPreparing, aisSending, aisReceiving,
    aisCompleted, aisFailed, aisCanceled);
  TMNoteAICodeAction = (aicaQuestion, aicaExplain, aicaFindBugs,
    aicaSuggestImprovement, aicaCompletion, aicaRouted, aicaProfileTest);

  TMNoteAIStateEvent = procedure(Sender: TObject;
    AState: TMNoteAIState) of object;
  TMNoteAICompletedEvent = procedure(Sender: TObject; ASuccess: Boolean;
    const AResponse, AError: string) of object;
  TMNoteAIProfileCallEvent = function(Sender: TObject; ARole: TMNoteAIRole;
    const AKind, AQuestion, ADeveloperMessage: string; AParentOrder,
    AAttempt: Integer; out AResponse, AError: string): Boolean of object;

  { TMNoteAIService }

  TMNoteAIService = class(TMNoteServiceBase)
  private
    FDefaultClient: TCHATGPT;
    FCodeAssistant: TAICodeAssistant;
    FPromptBuilder: TAIPromptBuilder;
    FModelRegistry: TAIModelRegistry;
    FTokenEstimator: TMNoteTokenEstimator;
    FProfiles: TMNoteAIProfiles;
    FRouter: TMNoteAIRouter;
    FBus: TMNoteAIBus;
    FSession: TMNoteAISession;
    FSessionMemory: TAIAgentMemoryMap;
    FActionExecutor: TMNoteAIActionExecutor;
    FProjectRoot: string;
    FDatabaseDictionaryCache: string;
    FPendingRequestKind: TMNoteAIRequestKind;
    FPendingProfileRole: TMNoteAIRole;
    FProfilesFileName: string;
    FProfileDefaultsPending: Boolean;
    FWorker: TThread;
    FState: TMNoteAIState;
    FCancelRequested: Boolean;
    FLastJSON: string;
    FLastURL: string;
    FOnStateChanged: TMNoteAIStateEvent;
    FOnCompleted: TMNoteAICompletedEvent;
    FOnSessionChanged: TNotifyEvent;
    FOnActionConfirm: TMNoteAIActionConfirmEvent;
    FOnProfileCall: TMNoteAIProfileCallEvent;
    FPendingActionDescriptor: TMNoteAIActionDescriptor;
    FPendingActionParameters: TJSONObject;
    FPendingActionAllowed: Boolean;
    FPendingActionReason: string;
    procedure ConfigureClient(AClient: TCHATGPT);
    procedure SetState(AState: TMNoteAIState);
    function ExecuteQuestion(const AQuestion, ADeveloperMessage: string;
      out AResponse: string): Boolean;
    function ExecuteCodeAction(AAction: TMNoteAICodeAction;
      const ACode, ADeveloperMessage: string; out AResponse: string): Boolean;
    function ExecuteRouted(AKind: TMNoteAIRequestKind; const AInput,
      ADeveloperMessage: string; out AResponse: string): Boolean;
    function ExecuteProfileCall(ARole: TMNoteAIRole; const AKind,
      AQuestion, ADeveloperMessage: string; AParentOrder, AAttempt: Integer;
      out AResponse, AError: string): Boolean;
    function ExecuteWithPolicy(ARole: TMNoteAIRole; const AKind,
      AQuestion, ADeveloperMessage: string; AParentOrder: Integer;
      out AResponse, AError: string): Boolean;
    function ExecuteWithTools(ARole: TMNoteAIRole; const AKind,
      AQuestion, ADeveloperMessage: string; AParentOrder: Integer;
      out AResponse, AError: string;
      AReadOnlyOnly: Boolean = False): Boolean;
    function IsActionRequest(const AResponse: string;
      out AActionName, AActionJSON: string): Boolean;
    function ExtractActionEnvelope(const AResponse: string;
      out AActionJSON: string): Boolean;
    function BuildToolContinuationPrompt(ARole: TMNoteAIRole;
      const AOriginalQuestion, ACatalog: string; AEvidence: TStringList;
      var AOmittedEvidence: Integer; out APrompt, AError: string): Boolean;
    function ExecuteContextualCodeAction(AAction: TMNoteAICodeAction;
      const ACode, ADeveloperMessage: string;
      out AResponse, AError: string): Boolean;
    function ValidateRecovery(const AJSON: string; out AOutput,
      ADiagnostic, AError: string): Boolean;
    function ValidateTriage(const AJSON: string; out AConfidence: Double;
      out ANeedsContext: Boolean; out AError: string): Boolean;
    function ExecuteTriage(const AInput, ADeveloperMessage: string;
      out AOutput: string; out AConfidence: Double;
      out ANeedsContext: Boolean; out AError: string): Boolean;
    function ExecutePlanning(const AInput, ADeveloperMessage: string;
      out AOutput, AError: string): Boolean;
    function ExecutorConfirm(Sender: TObject;
      ADescriptor: TMNoteAIActionDescriptor; AParameters: TJSONObject;
      out AReason: string): Boolean;
    function ExecutorDictionary(Sender: TObject; out AJSON,
      AError: string): Boolean;
    procedure SyncActionConfirmation;
    procedure ConfigureProfile(AProfile: TMNoteAIProfile);
    procedure NotifySessionChanged;
    procedure WorkerFinished(AWorker: TObject);
    function GetConfiguredContextLimit: Integer;
    procedure CalibrateFromUsage(const AInput, ADeveloperMessage,
      ARawJSON: string);
  public
    constructor Create;
    destructor Destroy; override;
    function DefaultClient: TCHATGPT;
    function LibraryVersion: string;
    function SendQuestion(const AQuestion, ADeveloperMessage: string;
      out AResponse: string): Boolean;
    function SendAsync(const AQuestion, ADeveloperMessage: string): Boolean;
    function SendRoutedAsync(AKind: TMNoteAIRequestKind; const AQuestion,
      ADeveloperMessage: string): Boolean;
    function SendProfileTestAsync(ARole: TMNoteAIRole): Boolean;
    function SendCodeActionAsync(AAction: TMNoteAICodeAction;
      const ACode, ADeveloperMessage: string): Boolean;
    function ExecuteToolRequest(ARole: TMNoteAIRole; const AKind,
      AQuestion, ADeveloperMessage: string; out AResponse,
      AError: string; AReadOnlyOnly: Boolean = False): Boolean;
    procedure Cancel;
    procedure WaitFor;
    function IsBusy: Boolean;
    function StateName: string;
    function BuildPrompt(const ARole, AObjective, ARestrictions,
      AContext, AOutputContract: string): string;
    function EstimateContext(const AText: string): TMNoteTokenEstimate;
    procedure GetProviders(AList: TStrings);
    function SaveProfiles(out AError: string): Boolean;
    function ReloadProfiles(out AError: string): Boolean;
    function Profile(ARole: TMNoteAIRole): TMNoteAIProfile;
    procedure EnsureProfileDefaults;
    procedure SetProjectRoot(const ARootPath: string);
    procedure SetDatabaseDictionaryCache(const AJSON: string);
    procedure ClearSession;
    property State: TMNoteAIState read FState;
    property LastJSON: string read FLastJSON;
    property LastURL: string read FLastURL;
    property Profiles: TMNoteAIProfiles read FProfiles;
    property Router: TMNoteAIRouter read FRouter;
    property Bus: TMNoteAIBus read FBus;
    property Session: TMNoteAISession read FSession;
    property SessionMemory: TAIAgentMemoryMap read FSessionMemory;
    property ProfilesFileName: string read FProfilesFileName;
    property OnStateChanged: TMNoteAIStateEvent read FOnStateChanged
      write FOnStateChanged;
    property OnCompleted: TMNoteAICompletedEvent read FOnCompleted
      write FOnCompleted;
    property OnSessionChanged: TNotifyEvent read FOnSessionChanged
      write FOnSessionChanged;
    property OnActionConfirm: TMNoteAIActionConfirmEvent read FOnActionConfirm
      write FOnActionConfirm;
    property OnProfileCall: TMNoteAIProfileCallEvent read FOnProfileCall
      write FOnProfileCall;
  end;

procedure InitializeMNoteAIService;
procedure FinalizeMNoteAIService;
function MNoteAI: TMNoteAIService;
function MNoteAIStateName(AState: TMNoteAIState): string;

implementation

uses
  jsonparser, LazUTF8, aiagent_flowevents, setmain, mnote_chatgpt_config,
  mnote_prompt_builder, mnote_token_usage, mnote_ai_profile_defaults;

type
  { TMNoteAIWorker }

  TMNoteAIWorker = class(TThread)
  private
    FService: TMNoteAIService;
    FAction: TMNoteAICodeAction;
    FInput: string;
    FDeveloperMessage: string;
    FResponse: string;
    FError: string;
    FSuccess: Boolean;
    procedure SyncSending;
    procedure SyncReceiving;
    procedure SyncFinished;
  protected
    procedure Execute; override;
  public
    constructor Create(AService: TMNoteAIService;
      AAction: TMNoteAICodeAction; const AInput,
      ADeveloperMessage: string);
  end;

var
  FAIService: TMNoteAIService = nil;

function MNoteAIStateName(AState: TMNoteAIState): string;
begin
  case AState of
    aisPreparing: Result := 'Preparing';
    aisSending: Result := 'Sending';
    aisReceiving: Result := 'Receiving';
    aisCompleted: Result := 'Completed';
    aisFailed: Result := 'Failed';
    aisCanceled: Result := 'Canceled';
    else Result := 'Idle';
  end;
end;

constructor TMNoteAIWorker.Create(AService: TMNoteAIService;
  AAction: TMNoteAICodeAction; const AInput, ADeveloperMessage: string);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FService := AService;
  FAction := AAction;
  FInput := AInput;
  FDeveloperMessage := ADeveloperMessage;
end;

procedure TMNoteAIWorker.SyncSending;
begin
  if not Terminated then FService.SetState(aisSending);
end;

procedure TMNoteAIWorker.SyncReceiving;
begin
  if not Terminated then FService.SetState(aisReceiving);
end;

procedure TMNoteAIWorker.SyncFinished;
begin
  FService.WorkerFinished(Self);
end;

procedure TMNoteAIWorker.Execute;
begin
  Synchronize(@SyncSending);
  if Terminated then
  begin
    Synchronize(@SyncFinished);
    Exit;
  end;
  try
    if FAction = aicaQuestion then
      FSuccess := FService.ExecuteQuestion(FInput, FDeveloperMessage,
        FResponse)
    else
      FSuccess := FService.ExecuteCodeAction(FAction, FInput,
        FDeveloperMessage, FResponse);
    FError := FService.LastError;
  except
    on E: Exception do
    begin
      FSuccess := False;
      FError := E.Message;
    end;
  end;
  Synchronize(@SyncReceiving);
  Synchronize(@SyncFinished);
end;

constructor TMNoteAIService.Create;
var
  ConfigError: string;
begin
  inherited Create;
  FDefaultClient := TCHATGPT.Create(nil);
  FCodeAssistant := TAICodeAssistant.Create(nil);
  FCodeAssistant.ChatGPT := FDefaultClient;
  FPromptBuilder := TAIPromptBuilder.Create(nil);
  FModelRegistry := TAIModelRegistry.Create(nil);
  FTokenEstimator := TMNoteTokenEstimator.Create;
  FProfiles := TMNoteAIProfiles.Create;
  FRouter := TMNoteAIRouter.Create;
  FBus := TMNoteAIBus.Create;
  FSession := TMNoteAISession.Create;
  FSessionMemory := TAIAgentMemoryMap.Create(nil);
  FSessionMemory.FlowName := 'MNote2/MultiAI';
  FSessionMemory.StoreFullPrompt := False;
  FSessionMemory.StoreFullResponse := False;
  FSessionMemory.RedactSensitiveData := True;
  FProjectRoot := GetCurrentDir;
  FActionExecutor := TMNoteAIActionExecutor.Create(FProjectRoot);
  FActionExecutor.OnConfirm := @ExecutorConfirm;
  FActionExecutor.OnGetDictionary := @ExecutorDictionary;
  FProfilesFileName := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) +
    'mnote_ai.json';
  FProfileDefaultsPending := not FileExists(FProfilesFileName);
  FProfiles.LoadFromFile(FProfilesFileName, ConfigError);
  FRouter.MaxCalls := FProfiles.MaxCalls;
  FRouter.MaxEstimatedTokens := FProfiles.MaxEstimatedTokens;
  FState := aisIdle;
end;

destructor TMNoteAIService.Destroy;
begin
  FOnCompleted := nil;
  FOnStateChanged := nil;
  FOnSessionChanged := nil;
  FOnActionConfirm := nil;
  Cancel;
  WaitFor;
  FActionExecutor.Free;
  FSessionMemory.Free;
  FSession.Free;
  FBus.Free;
  FRouter.Free;
  FProfiles.Free;
  FTokenEstimator.Free;
  FModelRegistry.Free;
  FPromptBuilder.Free;
  FCodeAssistant.Free;
  FDefaultClient.Free;
  inherited Destroy;
end;

procedure TMNoteAIService.ConfigureClient(AClient: TCHATGPT);
var
  ConfiguredModel: string;
begin
  ClearError;
  if FSetMain = nil then
  begin
    SetError('A configuração principal ainda não foi inicializada.');
    Exit;
  end;
  case FSetMain.Provider of
    1: ConfiguredModel := FSetMain.ModelOpenRouter;
    2: ConfiguredModel := FSetMain.ModelCerebras;
    3: ConfiguredModel := FSetMain.ModelLocal;
    4: ConfiguredModel := FSetMain.ModelGemini;
    else ConfiguredModel := FSetMain.ModelOpenAI;
  end;
  if Trim(ConfiguredModel) <> '' then
    FModelRegistry.ApplyModel(ConfiguredModel, AClient);
  ConfiguraChatGPTPorSetMain(AClient);
end;

procedure TMNoteAIService.SetState(AState: TMNoteAIState);
begin
  if FState = AState then Exit;
  FState := AState;
  if Assigned(FOnStateChanged) then FOnStateChanged(Self, FState);
end;

function TMNoteAIService.DefaultClient: TCHATGPT;
begin
  ConfigureClient(FDefaultClient);
  if LastError <> '' then Result := nil else Result := FDefaultClient;
end;

function TMNoteAIService.LibraryVersion: string;
begin
  Result := FDefaultClient.VersaoBiblioteca;
end;

procedure TMNoteAIService.CalibrateFromUsage(const AInput,
  ADeveloperMessage, ARawJSON: string);
var
  ActualTokens: Integer;
  UsageField, MeasuredInput: string;
begin
  if not TMNoteTokenUsage.ExtractPromptTokens(ARawJSON, ActualTokens,
    UsageField) then Exit;
  MeasuredInput := ADeveloperMessage + LineEnding + AInput;
  FTokenEstimator.Calibrate(UTF8Length(MeasuredInput), ActualTokens);
end;

function TMNoteAIService.ExecuteQuestion(const AQuestion,
  ADeveloperMessage: string; out AResponse: string): Boolean;
var
  Chat: TCHATGPT;
  MemoryStep: TAIAgentMemoryMapItem;
begin
  Result := False;
  AResponse := '';
  FLastJSON := '';
  FLastURL := '';
  Chat := DefaultClient;
  if Chat = nil then Exit;
  if not SameText(FSessionMemory.FlowName, 'MNote2/Chat') then
    FSessionMemory.StartFlow(AQuestion, 'MNote2/Chat', '', 'IDE');
  MemoryStep := FSessionMemory.BeginAgentStep('Conversa',
    tamCustom, AQuestion, ADeveloperMessage,
    FSessionMemory.CurrentOrder);
  Chat.Dev := ADeveloperMessage;
  Result := Chat.SendQuestion(AQuestion);
  FLastJSON := Chat.LastJSON;
  FLastURL := Chat.LastURL;
  CalibrateFromUsage(AQuestion, ADeveloperMessage, FLastJSON);
  AResponse := Chat.Response;
  if Result then
  begin
    FSessionMemory.EndAgentStep(MemoryStep, 'Resposta recebida',
      'Conversa concluída pelo provedor configurado', 'answer', AResponse,
      Copy(AResponse, 1, 500));
    ClearError;
  end
  else if Trim(Chat.LastError) <> '' then
  begin
    FSessionMemory.EndAgentStep(MemoryStep, 'Falha na conversa',
      Chat.LastError, 'none', AResponse, '');
    SetError(Chat.LastError);
  end
  else
  begin
    FSessionMemory.EndAgentStep(MemoryStep, 'Falha na conversa',
      'O provedor não retornou uma resposta válida.', 'none', AResponse, '');
    SetError('O provider de IA não retornou uma resposta válida.');
  end;
  if FWorker <> nil then TThread.Synchronize(FWorker, @NotifySessionChanged)
  else NotifySessionChanged;
end;

function TMNoteAIService.ExecuteCodeAction(AAction: TMNoteAICodeAction;
  const ACode, ADeveloperMessage: string; out AResponse: string): Boolean;
var
  Prompt: string;
begin
  Result := False;
  AResponse := '';
  ConfigureClient(FDefaultClient);
  if LastError <> '' then Exit;
  FDefaultClient.Dev := ADeveloperMessage;
  try
    case AAction of
      aicaRouted:
        begin
          Result := ExecuteRouted(FPendingRequestKind, ACode,
            ADeveloperMessage, AResponse);
          Exit;
        end;
      aicaProfileTest:
        begin
          FreeAndNil(FSession);
          FSession := TMNoteAISession.Create;
          FRouter.BeginSession;
          FSessionMemory.StartFlow('Teste real de perfil', 'MNote2/ProfileTest',
            '', 'Configuração');
          Result := ExecuteWithPolicy(FPendingProfileRole, 'profile_test',
            ACode, ADeveloperMessage, 0, AResponse, Prompt);
          if not Result then SetError(Prompt);
          Exit;
        end;
      aicaExplain, aicaFindBugs, aicaSuggestImprovement:
        begin
          Result := ExecuteContextualCodeAction(AAction, ACode,
            ADeveloperMessage, AResponse, Prompt);
          if Result then ClearError else SetError(Prompt);
          Exit;
        end;
      aicaCompletion:
        begin
          Prompt := BuildPrompt('assistente de conclusão de código',
            'sugerir somente a continuação imediata do código',
            'não repetir o código recebido; não usar markdown; não alterar arquivos',
            ACode, 'texto puro contendo apenas a continuação');
          Result := ExecuteQuestion(Prompt, ADeveloperMessage, AResponse);
          Exit;
        end;
      else
        Exit(ExecuteQuestion(ACode, ADeveloperMessage, AResponse));
    end;
    Result := FCodeAssistant.LastSuccess;
    if Result then ClearError else SetError(FCodeAssistant.LastError);
    FLastJSON := FDefaultClient.LastJSON;
    FLastURL := FDefaultClient.LastURL;
  except
    on E: Exception do SetError(E.Message);
  end;
end;

function TMNoteAIService.ExecuteContextualCodeAction(
  AAction: TMNoteAICodeAction; const ACode, ADeveloperMessage: string;
  out AResponse, AError: string): Boolean;
var
  Objective, KindName, RelativePath, TargetUnitName, DependencyResult,
  DiagnosticResult, Catalog, Payload, FullPayload, WorkPrompt,
  BasePrompt, ActionRequest: string;
  InputBudget, PayloadBudget, OmittedLines, ParentOrder: Integer;
  ParametersObject: TJSONObject;
  ActionStep: TMNoteAISessionStep;
  StartedAt: QWord;

  function MetadataValue(const AName: string): string;
  var
    Lines: TStringList;
    I: Integer;
  begin
    Result := '';
    Lines := TStringList.Create;
    try
      Lines.Text := StringReplace(ADeveloperMessage, #13#10, #10,
        [rfReplaceAll]);
      for I := 0 to Lines.Count - 1 do
        if Pos(LowerCase(AName) + ':', LowerCase(Trim(Lines[I]))) = 1 then
          Exit(Trim(Copy(Trim(Lines[I]), Length(AName) + 2, MaxInt)));
    finally
      Lines.Free;
    end;
  end;

  function ExecutePrecontextAction(const AName: string;
    AParameters: TJSONObject; out AResult: string): Boolean;
  var
    LocalRequest: TJSONObject;
    LocalError, LocalFingerprint: string;
  begin
    LocalRequest := TJSONObject.Create;
    try
      LocalRequest.Add('action', AName);
      LocalRequest.Add('parameters', AParameters);
      ActionRequest := LocalRequest.AsJSON;
    finally
      LocalRequest.Free;
    end;
    LocalFingerprint := FRouter.StepFingerprint(airLightWork,
      ActionRequest, aieNone);
    ActionStep := FSession.AddStep(airLightWork,
      'tool:' + AName + ':precontext', ParentOrder,
      FTokenEstimator.Estimate(ActionRequest, 0).TotalWithMargin,
      0, 0, 1, ActionRequest, LocalFingerprint);
    StartedAt := GetTickCount64;
    Result := FActionExecutor.ExecuteRequest(ActionRequest, airLightWork,
      AResult, LocalError);
    if Result then
      FSession.FinishStep(ActionStep, 'completed', AResult, '',
        GetTickCount64 - StartedAt)
    else
      FSession.FinishStep(ActionStep, 'failed', AResult, LocalError,
        GetTickCount64 - StartedAt);
    ParentOrder := ActionStep.Order;
  end;

  function MakePrompt(const APayload: string): string;
  begin
    Result := BuildPrompt('Trabalho Leve', Objective,
      'somente analisar; não modificar arquivos; não executar comandos; usar apenas ferramentas de leitura',
      APayload + #10#10'FERRAMENTAS DISPONÍVEIS:'#10 + Catalog,
      'resposta técnica verificável, indicando evidências e incertezas');
  end;
begin
  Result := False;
  AResponse := '';
  AError := '';
  case AAction of
    aicaExplain:
      begin Objective := 'explicar o código e suas relações relevantes';
        KindName := 'code_explain'; end;
    aicaFindBugs:
      begin Objective := 'localizar bugs no código usando evidências do projeto';
        KindName := 'code_find_bugs'; end;
    aicaSuggestImprovement:
      begin Objective := 'sugerir melhorias sem aplicar alterações';
        KindName := 'code_improve'; end;
  else
    begin AError := 'Ação de código contextual não suportada.'; Exit; end;
  end;

  FreeAndNil(FSession);
  FSession := TMNoteAISession.Create;
  FRouter.BeginSession;
  FSessionMemory.StartFlow(Objective, 'MNote2/CodeAnalysis', '', 'IDE');
  ParentOrder := 0;
  RelativePath := MetadataValue('arquivo_relativo');
  if (RelativePath <> '') and (RelativePath <> '(não salvo)') then
    TargetUnitName := ChangeFileExt(ExtractFileName(RelativePath), '')
  else
    TargetUnitName := '';

  ParametersObject := TJSONObject.Create;
  if (RelativePath <> '') and (RelativePath <> '(não salvo)') then
    ParametersObject.Add('path_contains', RelativePath);
  ExecutePrecontextAction('BuildDiagnostics', ParametersObject,
    DiagnosticResult);

  if TargetUnitName <> '' then
  begin
    ParametersObject := TJSONObject.Create;
    ParametersObject.Add('unit_name', TargetUnitName);
    ParametersObject.Add('direction', 'both');
    ExecutePrecontextAction('DependencyGraph', ParametersObject,
      DependencyResult);
  end
  else
    DependencyResult := '{"ok":true,"data":{"edges":[]}}';

  Catalog := FActionExecutor.DescribeActions(True);
  FullPayload := 'CONTEXTO DO EDITOR:'#10 + ADeveloperMessage + #10#10 +
    'CÓDIGO/SELEÇÃO:'#10 + ACode + #10#10 +
    'DEPENDÊNCIAS DIRETAS:'#10 + DependencyResult + #10#10 +
    'DIAGNÓSTICOS DO ÚLTIMO BUILD:'#10 + DiagnosticResult;
  InputBudget := FProfiles.Profile(airLightWork).Config.InputBudget;
  BasePrompt := MakePrompt('CONTEXTO DO EDITOR:'#10 + ADeveloperMessage);
  if FTokenEstimator.Estimate(BasePrompt, InputBudget).TotalWithMargin >
    InputBudget then
  begin
    AError := 'O contexto fixo e o catálogo de ferramentas não cabem no orçamento do perfil Trabalho Leve.';
    Exit;
  end;
  PayloadBudget := InputBudget -
    FTokenEstimator.Estimate(BasePrompt, InputBudget).TotalWithMargin - 16;
  if PayloadBudget < 32 then PayloadBudget := 32;
  repeat
    Payload := FTokenEstimator.TruncateAtLine(FullPayload, PayloadBudget,
      OmittedLines);
    WorkPrompt := MakePrompt(Payload);
    if FTokenEstimator.Estimate(WorkPrompt, InputBudget).TotalWithMargin <=
      InputBudget then Break;
    Dec(PayloadBudget, 32);
  until PayloadBudget < 32;
  if PayloadBudget < 32 then
  begin
    AError := 'Não foi possível ajustar o contexto da ação de código ao orçamento sem truncar o catálogo.';
    Exit;
  end;
  Result := ExecuteWithTools(airLightWork, KindName, WorkPrompt,
    ADeveloperMessage, ParentOrder, AResponse, AError, True);
end;

procedure TMNoteAIService.ConfigureProfile(AProfile: TMNoteAIProfile);
begin
  if AProfile = nil then Exit;
  EnsureProfileDefaults;
  ConfigureClient(AProfile.Client);
  AProfile.ApplyConfig;
end;

procedure TMNoteAIService.EnsureProfileDefaults;
var
  ModelName: string;
begin
  if (not FProfileDefaultsPending) or (FSetMain = nil) then Exit;
  case FSetMain.Provider of
    1: ModelName := FSetMain.ModelOpenRouter;
    2: ModelName := FSetMain.ModelCerebras;
    3: ModelName := FSetMain.ModelLocal;
    4: ModelName := FSetMain.ModelGemini;
    else ModelName := FSetMain.ModelOpenAI;
  end;
  ApplyMainAIToProfiles(FProfiles, FSetMain.Provider, ModelName,
    FSetMain.IPLocalIA);
  FProfileDefaultsPending := False;
end;

function RoleMapType(ARole: TMNoteAIRole): TAITipoAgenteMapa;
begin
  if ARole = airTriage then Result := tamClassificador
  else Result := tamCustom;
end;

function RequestKindName(AKind: TMNoteAIRequestKind): string;
begin
  case AKind of
    aikClassify: Result := 'classify';
    aikExtract: Result := 'extract';
    aikSmallWork: Result := 'small_work';
    aikDatabase: Result := 'database';
    aikPlanning: Result := 'planning';
    aikArbitrate: Result := 'arbitrate';
  else
    Result := 'conversation';
  end;
end;

function TMNoteAIService.ExecuteProfileCall(ARole: TMNoteAIRole;
  const AKind, AQuestion, ADeveloperMessage: string; AParentOrder,
  AAttempt: Integer; out AResponse, AError: string): Boolean;
var
  AIProfile: TMNoteAIProfile;
  Estimate: TMNoteTokenEstimate;
  LimitReason, ConfigError: string;
  SessionStep: TMNoteAISessionStep;
  ProfileStep, GlobalStep: TAIAgentMemoryMapItem;
  StartedAt: QWord;
begin
  Result := False;
  AResponse := '';
  AError := '';
  AIProfile := FProfiles.Profile(ARole);
  if not AIProfile.Config.Validate(ConfigError) then
  begin AError := ConfigError; Exit; end;
  if not AIProfile.Config.Enabled then
  begin AError := 'O perfil ' + MNoteAIRoleName(ARole) + ' está desabilitado.'; Exit; end;
  Estimate := FTokenEstimator.Estimate(AQuestion,
    AIProfile.Config.ContextWindow);
  if Estimate.TotalWithMargin > AIProfile.Config.InputBudget then
  begin
    AError := Format('A estimativa de %d tokens excede o orçamento de entrada %d do perfil %s.',
      [Estimate.TotalWithMargin, AIProfile.Config.InputBudget,
       MNoteAIRoleName(ARole)]);
    Exit;
  end;
  if not FRouter.CanCall(Estimate.TotalWithMargin +
    AIProfile.Config.OutputBudget, LimitReason) then
  begin AError := 'Sessão interrompida: ' + LimitReason; Exit; end;
  if not Assigned(FOnProfileCall) then
  begin
    ConfigureProfile(AIProfile);
    if LastError <> '' then begin AError := LastError; Exit; end;
  end;

  SessionStep := FSession.AddStep(ARole, AKind, AParentOrder,
    Estimate.TotalWithMargin, AIProfile.Config.OutputBudget,
    AIProfile.Config.InputBudget, AAttempt, AQuestion,
    FRouter.StepFingerprint(ARole, AQuestion, aieNone));
  ProfileStep := AIProfile.MemoryMap.BeginAgentStep(MNoteAIRoleName(ARole),
    RoleMapType(ARole), AQuestion, ADeveloperMessage, AParentOrder);
  GlobalStep := FSessionMemory.BeginAgentStep(MNoteAIRoleName(ARole),
    RoleMapType(ARole), AQuestion, ADeveloperMessage, AParentOrder);
  StartedAt := GetTickCount64;
  if Assigned(FOnProfileCall) then
  begin
    Result := FOnProfileCall(Self, ARole, AKind, AQuestion,
      AIProfile.Config.SystemPrompt + LineEnding + ADeveloperMessage,
      AParentOrder, AAttempt, AResponse, AError);
    FLastJSON := '';
    FLastURL := '';
  end
  else
  begin
    Result := AIProfile.Execute(AQuestion,
      AIProfile.Config.SystemPrompt + LineEnding + ADeveloperMessage,
      AResponse, AError);
    FLastJSON := AIProfile.Client.LastJSON;
    FLastURL := AIProfile.Client.LastURL;
    CalibrateFromUsage(AQuestion, AIProfile.Config.SystemPrompt + LineEnding +
      ADeveloperMessage, FLastJSON);
  end;
  if Result then
  begin
    FSession.FinishStep(SessionStep, 'completed', AResponse, '',
      GetTickCount64 - StartedAt);
    AIProfile.MemoryMap.EndAgentStep(ProfileStep, 'Resposta recebida',
      'Chamada real concluída', 'answer', AResponse, Copy(AResponse, 1, 500));
    FSessionMemory.EndAgentStep(GlobalStep, 'Resposta recebida',
      'Chamada real concluída', 'answer', AResponse, Copy(AResponse, 1, 500));
  end
  else
  begin
    FSession.FinishStep(SessionStep, 'failed', AResponse, AError,
      GetTickCount64 - StartedAt);
    AIProfile.MemoryMap.EndAgentStep(ProfileStep, 'Falha real do provider',
      AError, 'none', AResponse, '');
    FSessionMemory.EndAgentStep(GlobalStep, 'Falha real do provider',
      AError, 'none', AResponse, '');
  end;
  if FWorker <> nil then TThread.Synchronize(FWorker, @NotifySessionChanged)
  else NotifySessionChanged;
end;

procedure TMNoteAIService.NotifySessionChanged;
begin
  if Assigned(FOnSessionChanged) then FOnSessionChanged(Self);
end;

function TMNoteAIService.ExecuteWithPolicy(ARole: TMNoteAIRole;
  const AKind, AQuestion, ADeveloperMessage: string; AParentOrder: Integer;
  out AResponse, AError: string): Boolean;
var
  Attempts: Integer;
  ErrorClass: TMNoteAIErrorClass;
  FailedOutput, RecoveryPrompt, RecoveryError, RecoveryJSON,
  RecoveryDiagnostic: string;
begin
  Attempts := 0;
  Result := ExecuteProfileCall(ARole, AKind, AQuestion, ADeveloperMessage,
    AParentOrder, Attempts + 1, AResponse, AError);
  Inc(Attempts);
  if Result then Exit;
  FailedOutput := AResponse;
  ErrorClass := FRouter.ClassifyError(AError, False, False);
  if FRouter.MayRetry(ErrorClass, Attempts) and (not FCancelRequested) then
  begin
    Sleep(250);
    Result := ExecuteProfileCall(ARole, AKind, AQuestion, ADeveloperMessage,
      AParentOrder, Attempts + 1, AResponse, AError);
    Inc(Attempts);
    if Result then Exit;
    ErrorClass := FRouter.ClassifyError(AError, False, False);
  end;
  if (ErrorClass = aiePermanent) or FCancelRequested then Exit;
  if not FProfiles.Profile(airRecovery).Config.Enabled then Exit;
  RecoveryPrompt := BuildPrompt('Recuperação',
    'diagnosticar a falha e produzir uma saída corrigida',
    'uma única tentativa; preservar o erro; responder JSON puro com diagnostic e output',
    'PEDIDO ORIGINAL:'#10 + AQuestion + #10'SAÍDA FALHA:'#10 + FailedOutput +
    #10'CLASSE/ERRO:'#10 + MNoteAIErrorClassName(ErrorClass) + ': ' + AError,
    '{"diagnostic":"...","output":"..."}');
  Result := ExecuteProfileCall(airRecovery, 'recovery', RecoveryPrompt,
    ADeveloperMessage, AParentOrder, 1, RecoveryJSON, RecoveryError);
  if not Result then
    AError := RecoveryError
  else if not ValidateRecovery(RecoveryJSON, AResponse,
    RecoveryDiagnostic, RecoveryError) then
  begin
    Result := False;
    AError := 'Contrato de Recuperação inválido: ' + RecoveryError;
  end
  else
    AError := '';
end;

function TMNoteAIService.ValidateRecovery(const AJSON: string;
  out AOutput, ADiagnostic, AError: string): Boolean;
var
  Data: TJSONData;
  Root: TJSONObject;
begin
  Result := False;
  AOutput := '';
  ADiagnostic := '';
  AError := '';
  Data := nil;
  if (Trim(AJSON) = '') or (Trim(AJSON)[1] <> '{') or
    (Trim(AJSON)[Length(Trim(AJSON))] <> '}') then
  begin
    AError := 'A resposta deve conter somente um objeto JSON.';
    Exit;
  end;
  try
    try
      Data := GetJSON(AJSON);
      if not (Data is TJSONObject) then
      begin
        AError := 'Objeto JSON esperado.';
        Exit;
      end;
      Root := TJSONObject(Data);
      if (Root.Count <> 2) or
        (Root.Find('diagnostic') = nil) or
        (Root.Find('diagnostic').JSONType <> jtString) or
        (Root.Find('output') = nil) or
        (Root.Find('output').JSONType <> jtString) then
      begin
        AError := 'Os campos de texto diagnostic e output são obrigatórios.';
        Exit;
      end;
      ADiagnostic := Root.Strings['diagnostic'];
      AOutput := Root.Strings['output'];
      Result := Trim(AOutput) <> '';
      if not Result then AError := 'output não pode ser vazio.';
    except
      on E: Exception do AError := E.Message;
    end;
  finally
    Data.Free;
  end;
end;

function TMNoteAIService.ExtractActionEnvelope(const AResponse: string;
  out AActionJSON: string): Boolean;
var
  Value, Header, Body: string;
  LineEnd: Integer;
begin
  Result := False;
  AActionJSON := '';
  Value := Trim(AResponse);
  if Value = '' then Exit;
  if Copy(Value, 1, 3) = '```' then
  begin
    LineEnd := Pos(#10, Value);
    if LineEnd = 0 then Exit;
    Header := Trim(Copy(Value, 1, LineEnd - 1));
    if (Header <> '```') and (not SameText(Header, '```json')) then Exit;
    if Copy(Value, Length(Value) - 2, 3) <> '```' then Exit;
    Body := Trim(Copy(Value, LineEnd + 1,
      Length(Value) - LineEnd - 3));
    if Pos('```', Body) > 0 then Exit;
    Value := Body;
  end;
  if (Value = '') or (Value[1] <> '{') or
    (Value[Length(Value)] <> '}') then Exit;
  AActionJSON := Value;
  Result := True;
end;

function TMNoteAIService.IsActionRequest(const AResponse: string;
  out AActionName, AActionJSON: string): Boolean;
var
  Data: TJSONData;
  Root: TJSONObject;
begin
  Result := False;
  AActionName := '';
  AActionJSON := '';
  Data := nil;
  if not ExtractActionEnvelope(AResponse, AActionJSON) then Exit;
  try
    try
      Data := GetJSON(AActionJSON);
      if not (Data is TJSONObject) then Exit;
      Root := TJSONObject(Data);
      if (Root.Find('action') = nil) or
        (Root.Find('action').JSONType <> jtString) then Exit;
      AActionName := Root.Strings['action'];
      Result := AActionName <> '';
    except
      Result := Pos('"action"', LowerCase(AActionJSON)) > 0;
    end;
  finally
    Data.Free;
  end;
end;

function TMNoteAIService.BuildToolContinuationPrompt(ARole: TMNoteAIRole;
  const AOriginalQuestion, ACatalog: string; AEvidence: TStringList;
  var AOmittedEvidence: Integer; out APrompt, AError: string): Boolean;
var
  InputBudget, EvidenceBudget, OmittedLines: Integer;
  Candidate, BasePrompt, TruncatedEvidence: string;

  function EvidenceText: string;
  var
    J: Integer;
  begin
    Result := '';
    for J := 0 to AEvidence.Count - 1 do
    begin
      if Result <> '' then Result := Result + LineEnding + LineEnding;
      Result := Result + AEvidence[J];
    end;
    if Result = '' then Result := '(nenhuma evidência disponível)';
  end;

  function ComposePrompt: string;
  var
    OmissionNotice: string;
  begin
    if AOmittedEvidence > 0 then
      OmissionNotice := Format('%d evidência(s) antiga(s) omitida(s) por limite de contexto.',
        [AOmittedEvidence])
    else
      OmissionNotice := 'Nenhuma evidência foi omitida.';
    Result := BuildPrompt(MNoteAIRoleName(ARole),
      'continuar o pedido usando todas as evidências reais disponíveis',
      'não inventar resultados; responder ao usuário ou solicitar uma nova ação JSON válida',
      'PEDIDO ORIGINAL:'#10 + AOriginalQuestion + #10#10 +
      'EVIDÊNCIAS ACUMULADAS:'#10 + OmissionNotice + #10 + EvidenceText +
      #10#10'FERRAMENTAS DISPONÍVEIS:'#10 + ACatalog,
      'resposta direta ou {"action":"Nome","parameters":{...}}');
  end;
begin
  Result := False;
  APrompt := '';
  AError := '';
  InputBudget := FProfiles.Profile(ARole).Config.InputBudget;

  Candidate := ComposePrompt;
  if FTokenEstimator.Estimate(Candidate, InputBudget).TotalWithMargin <=
    InputBudget then
  begin
    APrompt := Candidate;
    Exit(True);
  end;

  while AEvidence.Count > 1 do
  begin
    AEvidence.Delete(0);
    Inc(AOmittedEvidence);
    Candidate := ComposePrompt;
    if FTokenEstimator.Estimate(Candidate, InputBudget).TotalWithMargin <=
      InputBudget then
    begin
      APrompt := Candidate;
      Exit(True);
    end;
  end;

  if AEvidence.Count = 1 then
  begin
    TruncatedEvidence := AEvidence[0];
    AEvidence.Clear;
    BasePrompt := ComposePrompt;
    EvidenceBudget := InputBudget -
      FTokenEstimator.Estimate(BasePrompt, InputBudget).TotalWithMargin - 16;
    if EvidenceBudget < 32 then EvidenceBudget := 32;
    repeat
      TruncatedEvidence := FTokenEstimator.TruncateAtLine(
        TruncatedEvidence, EvidenceBudget, OmittedLines);
      AEvidence.Clear;
      AEvidence.Add(TruncatedEvidence);
      Candidate := ComposePrompt;
      if FTokenEstimator.Estimate(Candidate, InputBudget).TotalWithMargin <=
        InputBudget then
      begin
        APrompt := Candidate;
        Exit(True);
      end;
      Dec(EvidenceBudget, 32);
    until EvidenceBudget < 32;
    AEvidence.Clear;
  end;

  BasePrompt := ComposePrompt;
  if FTokenEstimator.Estimate(BasePrompt, InputBudget).TotalWithMargin >
    InputBudget then
    AError := 'O catálogo completo de ferramentas e o pedido original não cabem no orçamento de entrada; o catálogo não será truncado.'
  else
    AError := 'Não foi possível ajustar as evidências ao orçamento de entrada sem truncar o catálogo de ferramentas.';
end;

procedure TMNoteAIService.SyncActionConfirmation;
begin
  FPendingActionAllowed := False;
  if Assigned(FOnActionConfirm) then
    FPendingActionAllowed := FOnActionConfirm(Self,
      FPendingActionDescriptor, FPendingActionParameters,
      FPendingActionReason)
  else
    FPendingActionReason := 'A ação exige confirmação explícita do usuário.';
end;

function TMNoteAIService.ExecutorConfirm(Sender: TObject;
  ADescriptor: TMNoteAIActionDescriptor; AParameters: TJSONObject;
  out AReason: string): Boolean;
begin
  FPendingActionDescriptor := ADescriptor;
  FPendingActionParameters := AParameters;
  FPendingActionReason := '';
  FPendingActionAllowed := False;
  if FWorker <> nil then
    TThread.Synchronize(FWorker, @SyncActionConfirmation)
  else
    SyncActionConfirmation;
  AReason := FPendingActionReason;
  Result := FPendingActionAllowed;
  FPendingActionDescriptor := nil;
  FPendingActionParameters := nil;
end;

function TMNoteAIService.ExecutorDictionary(Sender: TObject;
  out AJSON, AError: string): Boolean;
begin
  AJSON := FDatabaseDictionaryCache;
  Result := Trim(AJSON) <> '';
  if Result then AError := ''
  else AError := 'Nenhum dicionário de banco foi gerado nesta sessão.';
end;

function TMNoteAIService.ExecuteWithTools(ARole: TMNoteAIRole;
  const AKind, AQuestion, ADeveloperMessage: string; AParentOrder: Integer;
  out AResponse, AError: string; AReadOnlyOnly: Boolean): Boolean;
var
  ActionName, ActionRequest, ActionResult, ActionError, NextPrompt, Catalog,
  ContractError, CorrectionPrompt, CorrectedResponse,
  Fingerprint, ArbitrationPrompt, ArbitrationJSON, Verdict,
  ArbitrationReason: string;
  RoundNumber, ParentOrder, OmittedEvidence, RemainingCalls: Integer;
  ActionSuccess, CorrectionUsed: Boolean;
  ActionStep: TMNoteAISessionStep;
  StartedAt: QWord;
  Evidence: TStringList;

  function ReadOnlyRejectionJSON(const AName, AMessage: string): string;
  var
    Output: TJSONObject;
  begin
    Output := TJSONObject.Create;
    try
      Output.Add('ok', False);
      Output.Add('action', AName);
      Output.Add('simulated', False);
      Output.Add('truncated', False);
      Output.Add('data', TJSONNull.Create);
      Output.Add('error', AMessage);
      Result := Output.AsJSON;
    finally
      Output.Free;
    end;
  end;
begin
  Catalog := FActionExecutor.DescribeActions(AReadOnlyOnly);
  Evidence := TStringList.Create;
  try
    Result := ExecuteWithPolicy(ARole, AKind, AQuestion, ADeveloperMessage,
      AParentOrder, AResponse, AError);
    RoundNumber := 0;
    ParentOrder := AParentOrder;
    OmittedEvidence := 0;
    while Result and IsActionRequest(AResponse, ActionName, ActionRequest) do
    begin
      if FCancelRequested then
      begin
        AError := 'Operação cancelada.';
        Exit(False);
      end;

      RemainingCalls := FRouter.MaxCalls - FRouter.CallCount;
      if RemainingCalls <= 0 then
      begin
        AError := Format('Sessão interrompida pelo freio global após %d rodada(s); %d chamada(s) restante(s).',
          [RoundNumber, RemainingCalls]);
        Exit(False);
      end;
      if RoundNumber >= FProfiles.MaxToolRounds then
      begin
        AError := Format('A sessão excedeu o limite configurado de %d rodadas de ferramentas; %d chamada(s) restante(s).',
          [FProfiles.MaxToolRounds, RemainingCalls]);
        Exit(False);
      end;
      Inc(RoundNumber);

      CorrectionUsed := False;
      while not FActionExecutor.ValidateRequestContract(ActionRequest,
        ActionName, ContractError) do
      begin
        if CorrectionUsed then
        begin
          AError := 'Contrato de ferramenta inválido após uma correção: ' +
            ContractError;
          Exit(False);
        end;
        RemainingCalls := FRouter.MaxCalls - FRouter.CallCount;
        if RemainingCalls <= 0 then
        begin
          AError := Format('Sessão interrompida pelo freio global durante a correção da rodada %d; %d chamada(s) restante(s).',
            [RoundNumber, RemainingCalls]);
          Exit(False);
        end;
        CorrectionUsed := True;
        CorrectionPrompt := BuildPrompt(MNoteAIRoleName(ARole),
          'corrigir somente o contrato JSON da ação de ferramenta',
          'não responder ao pedido; não usar markdown; não adicionar texto fora do objeto JSON; uma única correção',
          'ERRO DE CONTRATO: ' + ContractError + #10 +
          'RESPOSTA A CORRIGIR:'#10 + ActionRequest + #10#10 +
          'FERRAMENTAS DISPONÍVEIS:'#10 + Catalog,
          '{"action":"Nome","parameters":{...}}');
        if not ExecuteProfileCall(ARole, AKind + '_tool_contract_correction',
          CorrectionPrompt, ADeveloperMessage, ParentOrder, 1,
          CorrectedResponse, AError) then Exit(False);
        if not IsActionRequest(CorrectedResponse, ActionName,
          ActionRequest) then
        begin
          AError := 'A correção do contrato não retornou uma ação JSON isolada.';
          Exit(False);
        end;
      end;

      Fingerprint := FRouter.StepFingerprint(ARole, ActionRequest, aieNone);
      if not FRouter.RegisterFingerprint(Fingerprint) then
      begin
        ArbitrationPrompt := BuildPrompt('Árbitro',
          'decidir uma repetição lógica detectada antes de nova execução',
          'não executar ferramentas; uma única decisão; JSON puro',
          'PAPEL: ' + MNoteAIRoleName(ARole) + #10 +
          'AÇÃO REPETIDA: ' + ActionRequest,
          '{"executavel":"razão"} ou {"faltam_informacoes":"razão"} ou {"abortar":"razão"}');
        if not ExecuteProfileCall(airArbiter, 'arbitration',
          ArbitrationPrompt, ADeveloperMessage, ParentOrder, 1,
          ArbitrationJSON, ArbitrationReason) then
        begin
          AError := ArbitrationReason;
          Exit(False);
        end;
        if not FRouter.ValidateArbitration(ArbitrationJSON, Verdict,
          ArbitrationReason) then
        begin
          AError := 'Contrato do Árbitro inválido: ' + ArbitrationReason;
          Exit(False);
        end;
        if Verdict = 'faltam_informacoes' then
        begin
          AResponse := 'Preciso de mais informações para continuar com segurança. ' +
            ArbitrationJSON;
          Exit(True);
        end;
        if Verdict = 'abortar' then
        begin
          AError := 'O Árbitro interrompeu o ciclo: ' + ArbitrationJSON;
          Exit(False);
        end;
      end;

      ParentOrder := FSession.Count;
      ActionStep := FSession.AddStep(ARole, 'tool:' + ActionName,
        ParentOrder, FTokenEstimator.Estimate(ActionRequest, 0).TotalWithMargin,
        0, 0, RoundNumber, ActionRequest, Fingerprint);
      StartedAt := GetTickCount64;
      if AReadOnlyOnly and
        (not FActionExecutor.ActionIsReadOnly(ActionName)) then
      begin
        ActionSuccess := False;
        ActionError := 'Este fluxo permite somente ferramentas de leitura.';
        ActionResult := ReadOnlyRejectionJSON(ActionName, ActionError);
      end
      else
        ActionSuccess := FActionExecutor.ExecuteRequest(ActionRequest, ARole,
          ActionResult, ActionError);
      if ActionSuccess then
        FSession.FinishStep(ActionStep, 'completed', ActionResult, '',
          GetTickCount64 - StartedAt)
      else
        FSession.FinishStep(ActionStep, 'failed', ActionResult, ActionError,
          GetTickCount64 - StartedAt);
      if FWorker <> nil then TThread.Synchronize(FWorker, @NotifySessionChanged)
      else NotifySessionChanged;

      Evidence.Add(Format('EVIDÊNCIA %d'#10'AÇÃO: %s'#10+
        'PARÂMETROS/REQUISIÇÃO: %s'#10'RESULTADO REAL: %s',
        [RoundNumber, ActionName, ActionRequest, ActionResult]));
      if not BuildToolContinuationPrompt(ARole, AQuestion, Catalog,
        Evidence, OmittedEvidence, NextPrompt, AError) then Exit(False);

      RemainingCalls := FRouter.MaxCalls - FRouter.CallCount;
      if RemainingCalls <= 0 then
      begin
        AError := Format('Sessão interrompida pelo freio global após %d rodada(s); %d chamada(s) restante(s).',
          [RoundNumber, RemainingCalls]);
        Exit(False);
      end;
      Result := ExecuteWithPolicy(ARole, AKind + '_after_tool', NextPrompt,
        ADeveloperMessage, ActionStep.Order, AResponse, AError);
    end;
  finally
    Evidence.Free;
  end;
end;

function TMNoteAIService.ValidateTriage(const AJSON: string;
  out AConfidence: Double; out ANeedsContext: Boolean;
  out AError: string): Boolean;
var
  Data: TJSONData;
  Root: TJSONObject;
begin
  Result := False;
  AConfidence := 0;
  ANeedsContext := False;
  AError := '';
  if (Trim(AJSON) = '') or (Trim(AJSON)[1] <> '{') then
  begin AError := 'A Triagem deve retornar somente JSON puro.'; Exit; end;
  Data := nil;
  try
    try
      Data := GetJSON(AJSON);
      if not (Data is TJSONObject) then begin AError := 'Objeto JSON esperado.'; Exit; end;
      Root := TJSONObject(Data);
      if (Root.Find('intention') = nil) or (Root.Find('confidence') = nil) or
        (Root.Find('entities') = nil) or (Root.Find('summary') = nil) or
        (Root.Find('needs_context') = nil) then
      begin AError := 'Campos obrigatórios da Triagem ausentes.'; Exit; end;
      if (Root.Find('intention').JSONType <> jtString) or
        (Root.Find('confidence').JSONType <> jtNumber) or
        not (Root.Find('entities') is TJSONArray) or
        (Root.Find('summary').JSONType <> jtString) or
        (Root.Find('needs_context').JSONType <> jtBoolean) or
        ((Root.Find('question') <> nil) and
         (Root.Find('question').JSONType <> jtString)) then
      begin AError := 'Tipos de campos inválidos no contrato da Triagem.'; Exit; end;
      AConfidence := Root.Floats['confidence'];
      ANeedsContext := Root.Booleans['needs_context'];
      Result := (AConfidence >= 0) and (AConfidence <= 1);
      if not Result then AError := 'confidence deve estar entre 0 e 1.';
    except
      on E: Exception do AError := E.Message;
    end;
  finally
    Data.Free;
  end;
end;

function TMNoteAIService.ExecuteTriage(const AInput,
  ADeveloperMessage: string; out AOutput: string; out AConfidence: Double;
  out ANeedsContext: Boolean; out AError: string): Boolean;
var
  Parts, Intentions, Summaries, Questions, Entities: TStringList;
  TemplatePrompt, Prompt, RawOutput, ValidationError: string;
  TemplateEstimate: TMNoteTokenEstimate;
  Data: TJSONData;
  Root, Aggregate: TJSONObject;
  EntityArray: TJSONArray;
  PartConfidence: Double;
  PartNeedsContext, IndivisibleOverflow, CorrectionUsed: Boolean;
  AvailableBudget, I, J, ParentOrder: Integer;
begin
  Result := False;
  AOutput := '';
  AConfidence := 1.0;
  ANeedsContext := False;
  AError := '';
  Parts := TStringList.Create;
  Intentions := TStringList.Create;
  Summaries := TStringList.Create;
  Questions := TStringList.Create;
  Entities := TStringList.Create;
  Entities.Sorted := True;
  Entities.Duplicates := dupIgnore;
  try
    TemplatePrompt := BuildPrompt('Triagem',
      'classificar a intenção sem produzir a resposta final',
      'não executar ações; não escolher provider/modelo; JSON puro', '',
      '{"intention":"...","confidence":0.0,"entities":[],"summary":"...","needs_context":false,"question":""}');
    TemplateEstimate := FTokenEstimator.Estimate(TemplatePrompt, 0);
    AvailableBudget := FProfiles.Profile(airTriage).Config.InputBudget -
      TemplateEstimate.TotalWithMargin;
    if AvailableBudget < 64 then
    begin
      AError := 'O orçamento da Triagem não comporta o próprio contrato.';
      Exit;
    end;
    if FTokenEstimator.Estimate(AInput, 0).TotalWithMargin <= AvailableBudget then
      Parts.Add(AInput)
    else if not FRouter.SplitTriage(AInput, AvailableBudget,
      FTokenEstimator, Parts, IndivisibleOverflow) then
    begin
      AError := 'Não foi possível dividir a entrada para Triagem.';
      Exit;
    end;
    if IndivisibleOverflow then
    begin
      AError := 'TRIAGE_INDIVISIBLE_OVERFLOW';
      Exit;
    end;

    CorrectionUsed := False;
    ParentOrder := 0;
    for I := 0 to Parts.Count - 1 do
    begin
      Prompt := BuildPrompt('Triagem',
        'classificar a intenção sem produzir a resposta final',
        'não executar ações; não escolher provider/modelo; JSON puro; parte ' +
          IntToStr(I + 1) + ' de ' + IntToStr(Parts.Count), Parts[I],
        '{"intention":"...","confidence":0.0,"entities":[],"summary":"...","needs_context":false,"question":""}');
      if not ExecuteProfileCall(airTriage, 'triage_part', Prompt,
        ADeveloperMessage, ParentOrder, 1, RawOutput, AError) then Exit;
      ParentOrder := FSession.Count;
      if not ValidateTriage(RawOutput, PartConfidence, PartNeedsContext,
        ValidationError) then
      begin
        if CorrectionUsed then
        begin
          AError := 'Contrato de Triagem inválido: ' + ValidationError;
          Exit;
        end;
        CorrectionUsed := True;
        Prompt := 'Corrija somente o contrato JSON da Triagem. Erro: ' +
          ValidationError + LineEnding + 'Resposta anterior:' + LineEnding +
          RawOutput;
        if not ExecuteProfileCall(airTriage, 'triage_contract_correction',
          Prompt, ADeveloperMessage, ParentOrder, 2, RawOutput, AError) then Exit;
        ParentOrder := FSession.Count;
        if not ValidateTriage(RawOutput, PartConfidence,
          PartNeedsContext, ValidationError) then
        begin
          AError := 'Contrato de Triagem inválido: ' + ValidationError;
          Exit;
        end;
      end;
      if Parts.Count = 1 then AOutput := RawOutput;
      if PartConfidence < AConfidence then AConfidence := PartConfidence;
      ANeedsContext := ANeedsContext or PartNeedsContext;
      Data := GetJSON(RawOutput);
      try
        Root := TJSONObject(Data);
        Intentions.Add(Root.Strings['intention']);
        Summaries.Add(Root.Strings['summary']);
        if (Root.Find('question') <> nil) and
          (Trim(Root.Strings['question']) <> '') then
          Questions.Add(Root.Strings['question']);
        EntityArray := TJSONArray(Root.Find('entities'));
        for J := 0 to EntityArray.Count - 1 do
          if EntityArray.Items[J].JSONType = jtString then
            Entities.Add(EntityArray.Strings[J]);
      finally
        Data.Free;
      end;
    end;

    if Parts.Count > 1 then
    begin
      Aggregate := TJSONObject.Create;
      try
        if Intentions.Count = 0 then Aggregate.Add('intention', 'unknown')
        else
        begin
          Intentions.Sort;
          if SameText(Intentions[0], Intentions[Intentions.Count - 1]) then
            Aggregate.Add('intention', Intentions[0])
          else
            Aggregate.Add('intention', 'multiple');
        end;
        Aggregate.Add('confidence', AConfidence);
        EntityArray := TJSONArray.Create;
        for I := 0 to Entities.Count - 1 do EntityArray.Add(Entities[I]);
        Aggregate.Add('entities', EntityArray);
        Aggregate.Add('summary', Trim(Summaries.Text));
        Aggregate.Add('needs_context', ANeedsContext);
        Aggregate.Add('question', Trim(Questions.Text));
        AOutput := Aggregate.AsJSON;
      finally
        Aggregate.Free;
      end;
    end;
    Result := True;
  finally
    Entities.Free;
    Questions.Free;
    Summaries.Free;
    Intentions.Free;
    Parts.Free;
  end;
end;

function TMNoteAIService.ExecutePlanning(const AInput,
  ADeveloperMessage: string; out AOutput, AError: string): Boolean;
var
  UnderstandPrompt, UnderstandJSON, Questions, ValidationError,
  PlanPrompt, PlanJSON: string;
  Ready: Boolean;
  Plan: TJSONObject;
  ParentOrder: Integer;
begin
  Result := False;
  AOutput := '';
  AError := '';
  UnderstandPrompt := BuildPrompt('Gestão — Entender',
    'confirmar o objetivo e decidir se há informação suficiente para planejar',
    'não gerar tarefas; não executar ferramentas; não inferir resposta para ambiguidade; JSON puro',
    AInput,
    '{"objective":"...","scopes":[],"assumptions":[],"ambiguities":[],"questions":[],"ready_to_plan":true}');
  if not ExecuteProfileCall(airManagement, 'planning_understand',
    UnderstandPrompt, ADeveloperMessage, 0, 1, UnderstandJSON, AError) then Exit;
  if not TMNoteAIPlanContract.ValidateUnderstanding(UnderstandJSON, Ready,
    Questions, ValidationError) then
  begin
    UnderstandPrompt := 'Corrija somente o contrato JSON da etapa Entender. ' +
      'Não acrescente markdown ou explicações. Erro: ' + ValidationError +
      LineEnding + 'Resposta anterior:' + LineEnding + UnderstandJSON;
    if not ExecuteProfileCall(airManagement, 'planning_understand_correction',
      UnderstandPrompt, ADeveloperMessage, FSession.Count, 2,
      UnderstandJSON, AError) then Exit;
    if not TMNoteAIPlanContract.ValidateUnderstanding(UnderstandJSON, Ready,
      Questions, ValidationError) then
    begin
      AError := 'Contrato da etapa Entender inválido: ' + ValidationError +
        LineEnding + 'Resposta bruta: ' + UnderstandJSON;
      Exit;
    end;
  end;
  if not Ready then
  begin
    AOutput := 'PLANNING_NEEDS_INFORMATION' + LineEnding + UnderstandJSON;
    Exit(True);
  end;

  ParentOrder := FSession.Count;
  PlanPrompt := BuildPrompt('Gestão — Planejar',
    'gerar um plano executável no schema leve do projeto MNote2',
    'usar caminhos relativos reais obtidos pelas ferramentas; caminho incerto fica vazio e é explicado em notes; ' +
    'não alterar arquivos; JSON puro; todos os campos são obrigatórios',
    'PEDIDO:'#10 + AInput + #10'ENTENDIMENTO VALIDADO:'#10 + UnderstandJSON +
      #10#10'FERRAMENTAS DISPONÍVEIS:'#10 + FActionExecutor.DescribeActions,
    '{"tasks":[{"id":"T001","epic_id":"E001","title":"...",' +
      '"description":"...","acceptance_criteria":"...","priority":"normal",' +
      '"status":"draft","dependency_type":"serial","dependencies":[],' +
      '"can_run_in_parallel":false,"estimated_hours":{"intern":1,"junior":1,' +
      '"mid_level":1,"senior":1},"suggested_skill_level":"mid_level",' +
      '"assigned_skill_level":"mid_level","assigned_to":"",' +
      '"responsible_profile":"DEV","estimated_duration_days":1,' +
      '"deliverable":"...","notes":"","progress_percent":0,' +
      '"revision_created":1,"revision_updated":1,"long_description":"...",' +
      '"files_affected":[],"must_not_do":[],"commits":[],"exclusive_files":[],' +
      '"origin":{}}],"dependencies":[],"execution_plan":[],"parallel_groups":[],' +
      '"milestones":[],"gantt":[],"timeline":[],"risk_map":[]}');
  if not ExecuteWithTools(airManagement, 'planning_generate', PlanPrompt,
    ADeveloperMessage, ParentOrder, PlanJSON, AError) then Exit;
  Plan := nil;
  if not TMNoteAIPlanContract.ParsePlan(PlanJSON, Plan, ValidationError) then
  begin
    PlanPrompt := 'Corrija somente o contrato JSON do plano. Não acrescente ' +
      'markdown nem invente caminhos. Erro: ' + ValidationError + LineEnding +
      'Resposta anterior:' + LineEnding + PlanJSON;
    if not ExecuteProfileCall(airManagement, 'planning_contract_correction',
      PlanPrompt, ADeveloperMessage, FSession.Count, 2, PlanJSON, AError) then Exit;
    if not TMNoteAIPlanContract.ParsePlan(PlanJSON, Plan,
      ValidationError) then
    begin
      AError := 'Contrato de plano inválido: ' + ValidationError +
        LineEnding + 'Resposta bruta: ' + PlanJSON;
      Exit;
    end;
  end;
  Plan.Free;
  AOutput := PlanJSON;
  Result := True;
end;

function TMNoteAIService.ExecuteRouted(AKind: TMNoteAIRequestKind;
  const AInput, ADeveloperMessage: string; out AResponse: string): Boolean;
var
  Estimate: TMNoteTokenEstimate;
  Route: TMNoteAIRoute;
  TriageOutput, TriageError, WorkPrompt, ErrorText: string;
  Confidence: Double;
  NeedsContext: Boolean;
  ParentOrder, OmittedLines: Integer;
  OverflowStep: TMNoteAISessionStep;
begin
  Result := False;
  AResponse := '';
  FreeAndNil(FSession);
  FSession := TMNoteAISession.Create;
  FRouter.BeginSession;
  FSessionMemory.StartFlow(AInput, 'MNote2/MultiAI', '', 'IDE');
  Estimate := FTokenEstimator.Estimate(AInput, 0);
  Route := FRouter.Route(AKind, Estimate.TotalWithMargin,
    FProfiles.Profile(airTriage).Config.InputBudget);
  if not FProfiles.Profile(Route.Role).Config.Enabled then
  begin
    SetError('O perfil ' + MNoteAIRoleName(Route.Role) + ' está desabilitado.');
    Exit;
  end;

  if AKind = aikPlanning then
  begin
    Result := ExecutePlanning(AInput, ADeveloperMessage, AResponse, ErrorText);
    if Result then ClearError else SetError(ErrorText);
    Exit;
  end;

  if AKind in [aikConversation, aikClassify, aikExtract] then
  begin
    if not ExecuteTriage(AInput, ADeveloperMessage, TriageOutput,
      Confidence, NeedsContext, TriageError) then
    begin
      if TriageError = 'TRIAGE_INDIVISIBLE_OVERFLOW' then
      begin
        OverflowStep := FSession.AddStep(airTriage, 'triage_overflow', 0,
          Estimate.TotalWithMargin, 0,
          FProfiles.Profile(airTriage).Config.InputBudget, 1, AInput,
          FRouter.StepFingerprint(airTriage, AInput, aieLowConfidence));
        FSession.FinishStep(OverflowStep, 'escalated', '',
          'Unidade indivisível acima do orçamento; escalada para Trabalho Leve.', 0);
        WorkPrompt := BuildPrompt('Trabalho Leve',
          'atender ao pedido que não pôde ser dividido pela Triagem',
          'registrar a incerteza; não inventar contexto; usar somente ações declaradas',
          AInput + #10#10'FERRAMENTAS DISPONÍVEIS:'#10 +
            FActionExecutor.DescribeActions,
          'resposta direta ou ação JSON válida');
        WorkPrompt := FTokenEstimator.TruncateAtLine(WorkPrompt,
          FProfiles.Profile(airLightWork).Config.InputBudget, OmittedLines);
        Result := ExecuteWithTools(airLightWork, 'triage_escalation',
          WorkPrompt, ADeveloperMessage, OverflowStep.Order, AResponse,
          ErrorText);
        if Result then ClearError else SetError(ErrorText);
        Exit;
      end;
      SetError(TriageError);
      Exit;
    end;
    if AKind <> aikConversation then
    begin
      AResponse := TriageOutput;
      Exit(True);
    end;
    if NeedsContext or (Confidence < 0.60) then
    begin
      AResponse := 'Preciso confirmar algumas informações antes de responder. ' +
        'A Triagem registrou confiança ' + FormatFloat('0.00', Confidence) +
        '. Detalhes: ' + TriageOutput;
      Exit(True);
    end;
    ParentOrder := FSession.Count;
    WorkPrompt := BuildPrompt('Trabalho Leve',
      'responder ao pedido do usuário com base na Triagem confirmada',
      'não alterar arquivos diretamente; usar somente uma ação declarada por vez',
      'TRIAGEM:'#10 + TriageOutput + #10'PEDIDO:'#10 + AInput +
      #10#10'FERRAMENTAS DISPONÍVEIS:'#10 + FActionExecutor.DescribeActions,
      'resposta direta ao usuário ou {"action":"Nome","parameters":{...}}');
    Result := ExecuteWithTools(airLightWork, 'answer', WorkPrompt,
      ADeveloperMessage, ParentOrder, AResponse, ErrorText);
  end
  else
  begin
    WorkPrompt := BuildPrompt(MNoteAIRoleName(Route.Role),
      'atender ao pedido roteado deterministicamente',
      'não alterar arquivos diretamente; usar somente uma ação declarada por vez',
      AInput + #10#10'FERRAMENTAS DISPONÍVEIS:'#10 +
        FActionExecutor.DescribeActions,
      'resposta compatível com o pedido ou ação JSON válida');
    Result := ExecuteWithTools(Route.Role, RequestKindName(AKind), WorkPrompt,
      ADeveloperMessage, 0, AResponse, ErrorText);
  end;
  if Result then ClearError else SetError(ErrorText);
end;

function TMNoteAIService.SendQuestion(const AQuestion,
  ADeveloperMessage: string; out AResponse: string): Boolean;
begin
  if IsBusy then
  begin
    AResponse := '';
    SetError('Já existe uma operação de IA em andamento.');
    Exit(False);
  end;
  SetState(aisPreparing);
  SetState(aisSending);
  Result := ExecuteQuestion(AQuestion, ADeveloperMessage, AResponse);
  SetState(aisReceiving);
  if Result then SetState(aisCompleted) else SetState(aisFailed);
end;

function TMNoteAIService.SendAsync(const AQuestion,
  ADeveloperMessage: string): Boolean;
begin
  Result := SendCodeActionAsync(aicaQuestion, AQuestion, ADeveloperMessage);
end;

function TMNoteAIService.SendRoutedAsync(AKind: TMNoteAIRequestKind;
  const AQuestion, ADeveloperMessage: string): Boolean;
begin
  FPendingRequestKind := AKind;
  Result := SendCodeActionAsync(aicaRouted, AQuestion, ADeveloperMessage);
end;

function TMNoteAIService.SendProfileTestAsync(ARole: TMNoteAIRole): Boolean;
var
  ConfigError: string;
begin
  if not FProfiles.Profile(ARole).Config.Validate(ConfigError) then
  begin SetError(ConfigError); Exit(False); end;
  FPendingProfileRole := ARole;
  Result := SendCodeActionAsync(aicaProfileTest,
    'Responda exatamente com uma frase curta confirmando o papel ' +
    MNoteAIRoleName(ARole) + '.',
    'Este é um teste real de provider/modelo solicitado pelo usuário.');
end;

function TMNoteAIService.SendCodeActionAsync(AAction: TMNoteAICodeAction;
  const ACode, ADeveloperMessage: string): Boolean;
begin
  Result := False;
  if IsBusy then
  begin
    SetError('Já existe uma operação de IA em andamento.');
    Exit;
  end;
  if (FWorker <> nil) and FWorker.Finished then FreeAndNil(FWorker);
  FCancelRequested := False;
  ClearError;
  SetState(aisPreparing);
  FWorker := TMNoteAIWorker.Create(Self, AAction, ACode,
    ADeveloperMessage);
  FWorker.Start;
  Result := True;
end;

function TMNoteAIService.ExecuteToolRequest(ARole: TMNoteAIRole;
  const AKind, AQuestion, ADeveloperMessage: string; out AResponse,
  AError: string; AReadOnlyOnly: Boolean): Boolean;
begin
  if IsBusy then
  begin
    AResponse := '';
    AError := 'Já existe uma operação de IA em andamento.';
    Exit(False);
  end;
  FreeAndNil(FSession);
  FSession := TMNoteAISession.Create;
  FRouter.BeginSession;
  FSessionMemory.StartFlow(AQuestion, 'MNote2/ToolRequest', '', 'IDE');
  Result := ExecuteWithTools(ARole, AKind, AQuestion, ADeveloperMessage,
    0, AResponse, AError, AReadOnlyOnly);
  if Result then ClearError else SetError(AError);
end;

procedure TMNoteAIService.Cancel;
begin
  if (FWorker = nil) or FWorker.Finished then Exit;
  FCancelRequested := True;
  FWorker.Terminate;
  FDefaultClient.Cancel;
  FProfiles.CancelAll;
  FActionExecutor.Cancel;
  SetState(aisCanceled);
end;

procedure TMNoteAIService.WaitFor;
begin
  if FWorker = nil then Exit;
  while not FWorker.Finished do
  begin
    CheckSynchronize(10);
    Sleep(1);
  end;
  FWorker.WaitFor;
  FreeAndNil(FWorker);
end;

function TMNoteAIService.IsBusy: Boolean;
begin
  Result := (FWorker <> nil) and (not FWorker.Finished);
end;

procedure TMNoteAIService.WorkerFinished(AWorker: TObject);
var
  Worker: TMNoteAIWorker;
begin
  Worker := TMNoteAIWorker(AWorker);
  if FCancelRequested or Worker.Terminated then
  begin
    SetState(aisCanceled);
    if Assigned(FOnCompleted) then
      FOnCompleted(Self, False, '', 'Operação cancelada.');
    Exit;
  end;
  if Worker.FSuccess then
  begin
    ClearError;
    SetState(aisCompleted);
  end
  else
  begin
    if Worker.FError <> '' then SetError(Worker.FError);
    SetState(aisFailed);
  end;
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, Worker.FSuccess, Worker.FResponse, Worker.FError);
end;

function TMNoteAIService.StateName: string;
begin
  Result := MNoteAIStateName(FState);
end;

function TMNoteAIService.BuildPrompt(const ARole, AObjective,
  ARestrictions, AContext, AOutputContract: string): string;
var
  ComponentInventory: string;
begin
  ComponentInventory := FPromptBuilder.BuildFromComponents([FDefaultClient]);
  Result := TMNotePromptBuilder.Build(ARole, AObjective, ARestrictions,
    AContext + #10#10 + '[CAPACIDADES DISPONÍVEIS]'#10 + ComponentInventory,
    AOutputContract);
end;

function TMNoteAIService.GetConfiguredContextLimit: Integer;
var
  I: Integer;
  ModelName: string;
begin
  Result := 4096;
  if FSetMain = nil then Exit;
  case FSetMain.Provider of
    1: ModelName := FSetMain.ModelOpenRouter;
    2: ModelName := FSetMain.ModelCerebras;
    3: ModelName := FSetMain.ModelLocal;
    4: ModelName := FSetMain.ModelGemini;
    else ModelName := FSetMain.ModelOpenAI;
  end;
  for I := 0 to FModelRegistry.Models.Count - 1 do
    if SameText(FModelRegistry.Models[I].InternalName, ModelName) or
      SameText(FModelRegistry.Models[I].FriendlyName, ModelName) then
      Exit(FModelRegistry.Models[I].MaxTokens);
end;

function TMNoteAIService.EstimateContext(
  const AText: string): TMNoteTokenEstimate;
begin
  Result := FTokenEstimator.Estimate(AText, GetConfiguredContextLimit);
end;

procedure TMNoteAIService.GetProviders(AList: TStrings);
begin
  FModelRegistry.GetProviders(AList);
end;

function TMNoteAIService.SaveProfiles(out AError: string): Boolean;
begin
  EnsureProfileDefaults;
  FProfiles.MaxCalls := FRouter.MaxCalls;
  FProfiles.MaxEstimatedTokens := FRouter.MaxEstimatedTokens;
  Result := FProfiles.SaveToFile(FProfilesFileName, AError);
  if Result then FProfileDefaultsPending := False;
end;

function TMNoteAIService.ReloadProfiles(out AError: string): Boolean;
begin
  FProfileDefaultsPending := not FileExists(FProfilesFileName);
  Result := FProfiles.LoadFromFile(FProfilesFileName, AError);
  if Result then EnsureProfileDefaults;
  if Result then
  begin
    FRouter.MaxCalls := FProfiles.MaxCalls;
    FRouter.MaxEstimatedTokens := FProfiles.MaxEstimatedTokens;
  end;
end;

function TMNoteAIService.Profile(ARole: TMNoteAIRole): TMNoteAIProfile;
begin
  Result := FProfiles.Profile(ARole);
  ConfigureProfile(Result);
end;

procedure TMNoteAIService.SetProjectRoot(const ARootPath: string);
var
  NewRoot: string;
begin
  if IsBusy or not DirectoryExists(ARootPath) then Exit;
  NewRoot := ExcludeTrailingPathDelimiter(ExpandFileName(ARootPath));
  if SameFileName(NewRoot, FProjectRoot) then Exit;
  FProjectRoot := NewRoot;
  FreeAndNil(FActionExecutor);
  FActionExecutor := TMNoteAIActionExecutor.Create(FProjectRoot);
  FActionExecutor.OnConfirm := @ExecutorConfirm;
  FActionExecutor.OnGetDictionary := @ExecutorDictionary;
end;

procedure TMNoteAIService.SetDatabaseDictionaryCache(const AJSON: string);
begin
  if IsBusy then Exit;
  FDatabaseDictionaryCache := AJSON;
end;

procedure TMNoteAIService.ClearSession;
begin
  if IsBusy then Exit;
  FreeAndNil(FSession);
  FSession := TMNoteAISession.Create;
  FSessionMemory.StartFlow('', 'MNote2/MultiAI', '', 'IDE');
  NotifySessionChanged;
end;

procedure InitializeMNoteAIService;
begin
  if FAIService = nil then FAIService := TMNoteAIService.Create;
end;

procedure FinalizeMNoteAIService;
begin
  FreeAndNil(FAIService);
end;

function MNoteAI: TMNoteAIService;
begin
  if FAIService = nil then
    raise Exception.Create('TMNoteAIService não foi inicializado.');
  Result := FAIService;
end;

end.
