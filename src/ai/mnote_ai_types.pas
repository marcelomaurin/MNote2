unit mnote_ai_types;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson;

type
  TMNoteAIRole = (airTriage, airLightWork, airRecovery, airArbiter,
    airDatabase, airManagement);
  TMNoteAIRequestKind = (aikClassify, aikExtract, aikSmallWork,
    aikDatabase, aikPlanning, aikArbitrate, aikConversation);
  TMNoteAIErrorClass = (aieNone, aiePermanent, aieTransient,
    aieInvalidContract, aieLowConfidence);

  { TMNoteAIProfileConfig }

  TMNoteAIProfileConfig = class
  public
    Role: TMNoteAIRole;
    Provider: Integer;
    ModelName: string;
    Endpoint: string;
    Enabled: Boolean;
    InputBudget: Integer;
    OutputBudget: Integer;
    ContextWindow: Integer;
    Temperature: Double;
    SystemPrompt: string;
    TimeoutMS: Integer;
    constructor Create(ARole: TMNoteAIRole);
    function Validate(out AError: string): Boolean;
    function ToJSON: TJSONObject;
    procedure FromJSON(AObject: TJSONObject);
  end;

  TMNoteAIResult = record
    Success: Boolean;
    Role: TMNoteAIRole;
    Attempts: Integer;
    Escalated: Boolean;
    Arbitrated: Boolean;
    ErrorClass: TMNoteAIErrorClass;
    ErrorText: string;
    StepOrder: Integer;
    Response: string;
  end;

function MNoteAIRoleName(ARole: TMNoteAIRole): string;
function MNoteAIRoleID(ARole: TMNoteAIRole): string;
function MNoteAIRoleFromID(const AValue: string; out ARole: TMNoteAIRole): Boolean;
function MNoteAIErrorClassName(AClass: TMNoteAIErrorClass): string;

implementation

function MNoteAIRoleName(ARole: TMNoteAIRole): string;
begin
  case ARole of
    airTriage: Result := 'Triagem';
    airLightWork: Result := 'Trabalho Leve';
    airRecovery: Result := 'Recuperação';
    airArbiter: Result := 'Árbitro';
    airDatabase: Result := 'Banco';
  else
    Result := 'Gestão';
  end;
end;

function MNoteAIRoleID(ARole: TMNoteAIRole): string;
begin
  case ARole of
    airTriage: Result := 'triage';
    airLightWork: Result := 'light_work';
    airRecovery: Result := 'recovery';
    airArbiter: Result := 'arbiter';
    airDatabase: Result := 'database';
  else
    Result := 'management';
  end;
end;

function MNoteAIRoleFromID(const AValue: string;
  out ARole: TMNoteAIRole): Boolean;
var
  Role: TMNoteAIRole;
begin
  Result := False;
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
    if SameText(MNoteAIRoleID(Role), AValue) then
    begin
      ARole := Role;
      Exit(True);
    end;
end;

function MNoteAIErrorClassName(AClass: TMNoteAIErrorClass): string;
begin
  case AClass of
    aiePermanent: Result := 'permanent';
    aieTransient: Result := 'transient';
    aieInvalidContract: Result := 'invalid_contract';
    aieLowConfidence: Result := 'low_confidence';
  else
    Result := 'none';
  end;
end;

function JSONInteger(AObject: TJSONObject; const AName: string;
  ADefault: Integer): Integer;
var
  Data: TJSONData;
begin
  Result := ADefault;
  Data := AObject.Find(AName);
  if Data <> nil then Result := Data.AsInteger;
end;

function JSONString(AObject: TJSONObject; const AName,
  ADefault: string): string;
var
  Data: TJSONData;
begin
  Result := ADefault;
  Data := AObject.Find(AName);
  if Data <> nil then Result := Data.AsString;
end;

function JSONBoolean(AObject: TJSONObject; const AName: string;
  ADefault: Boolean): Boolean;
var
  Data: TJSONData;
begin
  Result := ADefault;
  Data := AObject.Find(AName);
  if Data <> nil then Result := Data.AsBoolean;
end;

constructor TMNoteAIProfileConfig.Create(ARole: TMNoteAIRole);
begin
  inherited Create;
  Role := ARole;
  Provider := 0;
  Enabled := True;
  case Role of
    airTriage: begin InputBudget := 2000; OutputBudget := 500; end;
    airLightWork: begin InputBudget := 4000; OutputBudget := 1500; end;
    airRecovery: begin InputBudget := 4500; OutputBudget := 1500; end;
    airArbiter: begin InputBudget := 2500; OutputBudget := 500; end;
    airDatabase: begin InputBudget := 6000; OutputBudget := 1800; end;
  else
    begin InputBudget := 7000; OutputBudget := 2200; end;
  end;
  ContextWindow := 0;
  Temperature := 0.2;
  TimeoutMS := 360000;
  SystemPrompt := 'Você atua no papel ' + MNoteAIRoleName(Role) +
    ' dentro da IDE MNote2.';
end;

function TMNoteAIProfileConfig.Validate(out AError: string): Boolean;
begin
  AError := '';
  if InputBudget < 1 then AError := 'O orçamento de entrada deve ser positivo.'
  else if OutputBudget < 1 then AError := 'O orçamento de saída deve ser positivo.'
  else if (ContextWindow > 0) and
    (InputBudget + OutputBudget > ContextWindow) then
    AError := 'Entrada estimada e saída reservada excedem a janela de contexto.'
  else if (Temperature < 0) or (Temperature > 2) then
    AError := 'A temperatura deve estar entre 0 e 2.'
  else if TimeoutMS < 1000 then
    AError := 'O timeout deve ser de pelo menos 1000 ms.';
  Result := AError = '';
end;

function TMNoteAIProfileConfig.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('role', MNoteAIRoleID(Role));
  Result.Add('provider', Provider);
  Result.Add('model_name', ModelName);
  Result.Add('endpoint', Endpoint);
  Result.Add('enabled', Enabled);
  Result.Add('input_budget', InputBudget);
  Result.Add('output_budget', OutputBudget);
  Result.Add('context_window', ContextWindow);
  Result.Add('temperature', Temperature);
  Result.Add('system_prompt', SystemPrompt);
  Result.Add('timeout_ms', TimeoutMS);
end;

procedure TMNoteAIProfileConfig.FromJSON(AObject: TJSONObject);
begin
  if AObject = nil then Exit;
  Provider := JSONInteger(AObject, 'provider', Provider);
  ModelName := JSONString(AObject, 'model_name', ModelName);
  Endpoint := JSONString(AObject, 'endpoint', Endpoint);
  Enabled := JSONBoolean(AObject, 'enabled', Enabled);
  InputBudget := JSONInteger(AObject, 'input_budget', InputBudget);
  OutputBudget := JSONInteger(AObject, 'output_budget', OutputBudget);
  ContextWindow := JSONInteger(AObject, 'context_window', ContextWindow);
  if AObject.Find('temperature') <> nil then
    Temperature := AObject.Floats['temperature'];
  SystemPrompt := JSONString(AObject, 'system_prompt', SystemPrompt);
  TimeoutMS := JSONInteger(AObject, 'timeout_ms', TimeoutMS);
end;

end.
